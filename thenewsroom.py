#!/usr/bin/env python3

import json
import feedparser
import requests
import logging
import hashlib
import operator
import argparse
import os
import re
import psycopg2
from psycopg2.extensions import AsIs
import random
from goose3 import Goose
from tfidf import TfIdf
from time import mktime
from datetime import datetime, timedelta
from LSA import LSA


DB_USER = os.environ.get("TNR_DB_USER", "newsroom")
DB_PASS = os.environ.get("TNR_DB_PASS", "newsroom")
DB_NAME = os.environ.get("TNR_DB_NAME", "newsroom")
DB_HOST = os.environ.get("TNR_DB_HOST", "127.0.0.1")
LOG_FILE = os.environ.get("TRN_LOGFILE", "feed_kraken.log")


class FeedKraken:
    def __init__(self, outputpath=".", **kwargs):
        self.outputpath = outputpath
        # select the appropriate log level
        log_level = logging.DEBUG if kwargs.get("debug", False) else logging.INFO
        # configure loglevel
        logging.basicConfig(
            # filename=kwargs.get("logpath", LOG_FILE),
            level=log_level)
        logging.getLogger("requests").setLevel(logging.ERROR)
        logging.info('+------------------------+')
        logging.info('   RELEASE THE KRAKEN!!   ')
        logging.info('+------------------------+')
        logging.info('-- %s' % datetime.now())

        self.dbuser = kwargs.get("db_user", DB_USER)
        self.dbpass = kwargs.get("db_pass", DB_PASS)
        self.dbname = kwargs.get("db_name", DB_NAME)
        self.dbhost = kwargs.get("db_host", DB_HOST)

    def grabUrls(self):
        logging.info('* grab urls')
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()
        c.execute(
            'SELECT url, last_update, feed_id, etag, modified FROM feeds WHERE active = 1')
        for f in c.fetchall():
            try:
                modified, updated, etag = self.parse(f[0], f[1], f[2], f[3], f[4])
                c.execute('UPDATE feeds SET last_update = %s, etag = %s, modified = %s  WHERE feed_id = %s',
                          (updated, etag, modified, f[2]))
                self.db.commit()
            except Exception as e:
                print(f"failed to update {f[0]}: {e}")
        c.close()
        self.db.close()
        logging.info('* grab urls complete')

    def parse(self, url, start_date, feed_id, etag=None, modified=None):

        f = feedparser.parse(url, etag=etag, modified=modified)
        c = self.db.cursor()

        if not hasattr(f, 'status'):
            print(f)
            raise ValueError("unknown feed status")

        if hasattr(f, 'etag') and f.status != 304:
            etag = f.etag
        if hasattr(f, 'modified_parsed'):
            modified = datetime.fromtimestamp(mktime(f.modified_parsed))

        print(f'{url} {modified} ({etag}) {f.status}')

        count = 0
        tmp_dates = [start_date]
        for entry in f.entries:
            published = datetime.fromtimestamp(mktime(entry.published_parsed))
            logging.debug('%s - %s = %d seconds' % (published,
                                                    start_date, (published - start_date).total_seconds()))
            if (published - start_date).total_seconds() > 0:

                # CHECK IF IT IS ALREADY PRESENT WITH THE SAME DATE ON THE DATABASE
                resp = requests.head(entry.link, headers={
                                     'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.73.11 (KHTML, like Gecko) Version/7.0.1 Safari/537.73.11'})
                canonical_url = resp.url
                sha1_hash = hashlib.sha1(canonical_url.encode()).hexdigest()
                c.execute(
                    'SELECT published FROM articles WHERE hash = %s', (sha1_hash,))
                row = c.fetchone()
                if row is not None:
                    logging.warn(f"URL with hash {sha1_hash} exists with date {row[0]}, new date is {published}")
                    query_data = (sha1_hash, published)
                    c.execute('SELECT article_hash,updated_on FROM articles_update WHERE article_hash = %s AND updated_on = %s', query_data)
                    if c.fetchone() is None:
                        query_data = (sha1_hash, published, published)
                        c.execute("INSERT INTO articles_update(article_hash, updated_on, article_day) VALUES (%s,%s,%s)", query_data)
                    else:
                        query_data = (sha1_hash, published)  # not necessary but here for readability
                        c.execute("UPDATE articles_update SET count_duplicate = count_duplicate + 1 WHERE article_hash = %s AND updated_on = %s", query_data)

                else:
                    count += 1
                    tmp_dates.append(published)
                    data = (feed_id,
                            entry.get('id', None),
                            canonical_url,
                            entry.get('title', None),
                            entry.get('category', None),
                            published,
                            entry.get('author', None),
                            entry.get('description', None),
                            sha1_hash
                            )
                    c.execute(
                        "INSERT INTO articles (feed_id,article_id,url,title,category,published,author,description,hash) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s)", data)
        logging.info(f'feed id {feed_id} has {count} entries after {start_date}')
        return (modified, max(tmp_dates), etag)

    def loadCountries(self):
        c = self.db.cursor()
        c.execute('SELECT "isoAlpha3", "keywords" FROM countries_keywords')
        data = {}
        for row in c.fetchall():
            data[row[0]] = [x.strip()
                            for x in row[1] if x is not None and x != '']
        c.close()

        return data

    def createJsonForMatrix(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        out = {'nodes_source': [], 'nodes_target': [], 'links': []}
        nodes_index_source = []
        nodes_index_target = []
        # load nodes
        c.execute(
            'SELECT "countryName", "isoAlpha3", "continent" FROM countries c ORDER BY "countryName"')
        i = 1
        for row in c.fetchall():

            if row[2] == 'AF':
                group = 1
            if row[2] == 'AN':
                group = 2
            if row[2] == 'AS':
                group = 3
            if row[2] == 'EU':
                group = 4
            if row[2] == 'NA':
                group = 5
            if row[2] == 'OC':
                group = 6
            if row[2] == 'SA':
                group = 7

            out['nodes_source'].append(
                {'name': row[0], 'group': 1, 'index': i})
            nodes_index_source.append(row[1])
            i += 1

        c.execute(
            "SELECT distinct article_day FROM article_country ORDER BY article_day")
        for row in c.fetchall():
            out['nodes_target'].append(
                {'name': str(row[0]), 'group': 1, 'index': i})
            nodes_index_target.append(str(row[0]))
            i += 1
        # load links and calculate the score
        c.execute("SELECT article_day, country_iso3, country, articles_num, sources_num, in_title, score FROM aggregate_article_country")
        for row in c.fetchall():
            day = row[0]
            iso3 = row[1]
            articles_num = row[3]
            sources_num = row[4]
            in_title_flag = row[5]
            # score = 1 + (articles_num * .5) * (sources_num / 2)
            score = row[6]

            i_cn = nodes_index_source.index(iso3)
            i_day = nodes_index_target.index(str(day))

            out['links'].append(
                {'source': i_cn, 'target': i_day, 'value': str(score)})

        with open(os.path.join(self.outputpath, "aggregate_data.json"), "w") as ag:
            ag.write(json.dumps(out, indent=2))

        # now records the titles of the news
        headlines = {}
        c.execute("SELECT article_day,country,title,url FROM articles_headlines")
        for row in c.fetchall():
            lista = headlines.get(str(row[0])+'-'+row[1])
            if lista is None:
                headlines[str(row[0])+'-'+row[1]
                          ] = [{'title': row[2], 'url': row[3]}]
            else:
                headlines[str(row[0])+'-'+row[1]
                          ].append({'title': row[2], 'url': row[3]})

        with open(os.path.join(self.outputpath, "aggregate_headlines.json"), "w") as ag:
            ag.write(json.dumps(headlines, indent=2))

        # nows feeds # AVAILABLE THROUGHT API
        headlines = []
        c.execute("SELECT title,url,article_day,country,published,country_iso3 FROM articles_headlines_feed limit 100")
        for row in c.fetchall():
            headlines.append({'title': row[0], 'url': row[1], 'country': row[3], 'published': str(row[4]), 'iso': row[5]})

        with open(os.path.join(self.outputpath, "aggregate_news_feed.json"), "w") as ag:
            ag.write(json.dumps(headlines, indent=2))

        # top scores # AVAILABLE THROUGHT API
        scores = []
        c.execute("SELECT country,total_score,country_iso3 FROM top_country_last_week ")
        for row in c.fetchall():
            if row[1] > 1:
                scores.append((row[0], str(row[1]), row[2]))

        with open(os.path.join(self.outputpath, "aggregate_top_scores.json"), "w") as ag:
            ag.write(json.dumps(scores, indent=2))

        # tree map
        treemap = {'name': 'news', 'children': []}
        continets = {}
        c.execute(
            "SELECT continent,country,total_score FROM top_country_last_week ")
        for row in c.fetchall():
            continet = row[0]
            cn = continets.get(continet)
            if cn is None:
                continets[continet] = [{'name': row[1], 'size':str(row[2]*5)}]
            else:
                continets[continet].append(
                    {'name': row[1], 'size': str(row[2]*5)})
        for cn, cos in continets.items():
            treemap['children'].append({'name': cn, 'children': cos})

        with open(os.path.join(self.outputpath, "aggregate_tremap.json"), "w") as ag:
            ag.write(json.dumps(treemap, indent=2))

        # streamgraph
        dates = []
        countries = []
        csv_streamgraph = []
        c.execute(
            "SELECT DISTINCT article_day FROM aggregate_article_country WHERE article_day > '2013-12-22' ORDER BY article_day")
        for row in c.fetchall():
            dates.append(row[0])
        c.execute(
            'SELECT country_iso3 FROM top_countries WHERE country_iso3 IS NOT NULL')
        for row in c.fetchall():
            countries.append(row[0])

        for country in countries:
            for day in dates:
                c.execute(
                    "SELECT score FROM aggregate_article_country WHERE country_iso3 = %s AND article_day = %s", (country, day))
                row = c.fetchone()
                if row is None:
                    csv_streamgraph.append('%s,%s,%s\n' %
                                           (country, '0', str(day)))
                else:
                    csv_streamgraph.append('%s,%s,%s\n' %
                                           (country, str(row[0]), str(day)))

        with open(os.path.join(self.outputpath, "streamgraph_data.csv"), "w") as ag:
            ag.write('key,value,date\n')
            for line in csv_streamgraph:
                ag.write(line)

        self.db.close()

    def exportCountryArticleDetails(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        # get the maximum and miniumum date frm aggregate_article_country
        c.execute("SELECT max(article_day) as max_day, min(article_day) as min_day FROM aggregate_article_country WHERE article_day > '2013-12-22'")
        row = c.fetchone()
        length = (row[0]-row[1]).days
        dates = [row[1]+timedelta(n) for n in range(length+1)]

        c.execute('SELECT "isoAlpha3" FROM  countries ORDER BY "countryName"')
        for row in c.fetchall():
            isoAlpha3 = row[0]
            with open(os.path.join(self.outputpath, "details_data_%s.tsv" % isoAlpha3), "w") as out_:
                out_.write("date\tscore\tarticles\tsources\n")

                for date in dates:
                    c.execute(
                        'SELECT article_day,score,articles_num,sources_num FROM aggregate_article_country WHERE country_iso3 = %s AND article_day = %s', (isoAlpha3, date))
                    row2 = c.fetchone()
                    if row2 is None:
                        out_.write('%s\t%f\t%d\t%d\n' % (date, 0, 0, 0))
                        continue
                    out_.write('%s\t%f\t%d\t%d\n' %
                               (row2[0], row2[1], row2[2], row2[3]))

                # c.execute('SELECT article_day,score,articles_num,sources_num FROM aggregate_article_country WHERE country_iso3 = %s ORDER BY article_day', (isoAlpha3,))
                # for row2 in c.fetchall():
                # 	out_.write('%s\t%f\t%d\t%d\n' % (row2[0],row2[1],row2[2],row2[3]))

        self.db.close()

    def exportFeedsInfo(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        # build the blocks for the pivot queries
        feed_names = []
        q2_params = []
        c.execute(
            'SELECT DISTINCT "name" FROM feeds WHERE active = 1 ORDER BY feeds."name"')
        for row in c.fetchall():
            feed_names.append(row[0])
            q2_params.append(
                'COALESCE(sum(case when "name" = \'%s\' then num end), 0) as "%s"' % (row[0], row[0]))

        # first pivot
        with open(os.path.join(self.outputpath, "feed_details.tsv"), "w") as out_:
            out_.write("date\t%s\n" % '\t'.join(feed_names))

            # first pivot query
            q = 'SELECT "day", %s from feeds_articles GROUP BY "day" ORDER BY "day" ' % ','.join(
                q2_params)

            c.execute(q)
            for row in c.fetchall():
                out_.write('\t'.join([str(row[i])
                                      for i in range(len(feed_names) + 1)]))
                out_.write('\n')
        # second pivot
        with open(os.path.join(self.outputpath, "feed_details_unique.tsv"), "w") as out_:
            out_.write("date\t%s\n" % '\t'.join(feed_names))

            # first pivot query
            q = 'SELECT "day", %s from feeds_articles_unique GROUP BY "day" ORDER BY "day" ' % ','.join(
                q2_params)

            c.execute(q)
            for row in c.fetchall():
                out_.write('\t'.join([str(row[i])
                                      for i in range(len(feed_names) + 1)]))
                out_.write('\n')

        self.db.close()

    def exportMatrixCountries(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()
        # first generate the matrix index
        c_index = {}

        c.execute(
            'SELECT DISTINCT "isoAlpha3","countryName" FROM countries ORDER BY "isoAlpha3"')
        index = 0

        with open(os.path.join(self.outputpath, "countries.csv"), "w") as out_:
            out_.write('name,color\n')
            for row in c.fetchall():
                out_.write('%s,"hsl( %d , 100%%, 75%%)"\n' %
                           (row[1], random.randint(0, 360)))
                c_index[row[0]] = index
                index += 1

        matrix = [[0 for x in range(len(c_index))]
                  for x in range(len(c_index))]
        # now the fun begins
        q = """SELECT ac.article_day, array_agg(ac.country_iso3)
FROM article_country ac
WHERE ac.frequency > 0.2
AND article_day = '2013-12-25'
GROUP BY ac.article_day, ac.article_hash
ORDER BY ac.article_day """

        total = 0
        c.execute(q)
        for row in c.fetchall():
            for iso1 in row[1]:
                for iso2 in row[1]:
                    total += 1
                    matrix[c_index[iso1]][c_index[iso2]] += 1

        matrix = [[float(col) / float(index) for col in row] for row in matrix]

        with open(os.path.join(self.outputpath, "news_one_day_chord.json"), "w") as out_:
            out_.write(json.dumps(matrix, indent=2))

        self.db.close()

    def createPHPtable(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        table_data = [[0 for x in range(48)] for i in range(260)]
        nodes_index = {}

        # load nodes
        c.execute(
            'SELECT "countryName", "isoAlpha3", "continent" FROM countries c ORDER BY "countryName"')
        i = 1
        for row in c.fetchall():
            table_data[i][0] = row[0]
            nodes_index[row[1]] = i
            i += 1

        c.execute(
            "SELECT distinct article_day FROM article_country ORDER BY article_day DESC")
        i = 1
        for row in c.fetchall():
            table_data[0][i] = str(row[0])
            nodes_index[str(row[0])] = i
            i += 1
        # load links and calculate the score
        c.execute(
            "SELECT article_day, country_iso3, country, articles_num, sources_num, in_title FROM aggregate_article_country")
        for row in c.fetchall():
            day = row[0]
            iso3 = row[1]
            articles_num = row[3]
            sources_num = row[4]
            in_title_flag = row[5]

            i_cn = nodes_index.get(iso3)
            i_day = nodes_index.get(str(day))

            score = 1 + (articles_num * .5) * (sources_num / 2)
            table_data[i_cn][i_day] = score

        with open(os.path.join(self.outputpath, "table_data.json"), "w") as ag:
            ag.write(json.dumps(table_data, indent=2))

        self.db.close()

    def createTFIDFTopics(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        headlines = {}
        c.execute(
            "SELECT article_day,country,title,url,article_hash FROM articles_headlines")
        for row in c.fetchall():
            title = row[2]
            # c.execute('SELECT content from articles where hash = ?',(row[4],))
            # content = c.fetchone()[0]

            lista = headlines.get(str(row[0])+'-'+row[1])
            if lista is None:
                # headlines[str(row[0])+'-'+row[1]] = [title + ' ' + content]
                headlines[str(row[0])+'-'+row[1]] = [title]
            else:
                # headlines[str(row[0])+'-'+row[1]].append(title + ' ' + content)
                headlines[str(row[0])+'-'+row[1]].append(title)
        self.db.close()

        for hd, contents in headlines.items():
            print(f'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> {hd}')
            with open('stopwords.txt', 'r') as st:
                tfidf = TfIdf(stopwords=[x.strip() for x in st.readlines()])
                tfidf.parse(contents)

    def runLSA(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        headlines = []

        stopwords = []
        ingnore_chars = ''',:'!'''
        with open('stopwords.txt', 'r') as st:
            stopwords = [x.strip() for x in st.readlines()]

        lsa = LSA(stopwords, ingnore_chars)

        c.execute("SELECT content FROM articles_headlines ah,articles_content ac WHERE ah.country = 'Russia' and ah.article_hash = ac.article_hash")
        for row in c.fetchall():
            text = row[0]
            lsa.parse(text)
        self.db.close()

        lsa.build()
        lsa.printA()
        lsa.calc()
        lsa.printSVD()
        lsa.computeSimilarity()
        # lsa.toImage()

    def extractArticlesText(self):
        headers = {}
        proxy = '178.18.25.171:3128'
        proxyDict = {
            "http": proxy,
            "https": proxy
        }

        logging.info('* extract text')
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()

        c.execute(
            'SELECT DISTINCT hash, url, title, published, feed_id FROM articles WHERE flag_text_extract = 0 ORDER BY published')
        urls = c.fetchall()

        for u in urls:
            url = u[1]
            hash_ = u[0]
            title = u[2]
            published = u[3]
            feed_id = u[4]

            try:
                print(f"hash: {hash_} {url}")
                # response = requests.get(url, proxies=proxyDict, headers=headers)
                response = requests.get(url, headers=headers)

                g = Goose()
                article_cnt = g.extract(raw_html=response.content)

                text = article_cnt.cleaned_text

                img = None
                try:
                    img = article_cnt.top_image.src
                except Exception:
                    pass

                lang = article_cnt.meta_lang
                meta_description = article_cnt.meta_description
                # print article_cnt.meta_keywords
                # print article_cnt.meta_lang
                # print article_cnt.tags

                tags = list(article_cnt.tags)
                if article_cnt.meta_keywords is not None:
                    tags.extend([x.strip()
                                 for x in article_cnt.meta_keywords.split(',')])

                # print text
                extraction_method = 'goose'
                c.execute("INSERT INTO articles_content(article_hash, content, meta_description) VALUES (%s, %s, %s)",
                          (hash_, text, meta_description))
                c.execute("UPDATE articles SET flag_text_extract = 1, extraction_method = %s, img_url = %s, tags = %s, lang = %s WHERE hash = %s",
                          (extraction_method, img, tags, lang, hash_))
                self.db.commit()
            except Exception as e:
                c.execute(
                    "UPDATE articles SET errors = errors + 1 WHERE hash = %s", (hash_,))
                self.db.commit()
                raise e

        self.db.close()

    def aggregateCountries(self):
        self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (
            self.dbname, self.dbuser, self.dbpass, self.dbhost))
        c = self.db.cursor()
        c_article_country = self.db.cursor()
        c_article_content = self.db.cursor()

        countries = self.loadCountries()

        c.execute('SELECT DISTINCT hash, url, title, published, feed_id FROM articles WHERE flag_text_extract = 1 AND flag_text_parsed = 0 ORDER BY published')
        urls = c.fetchall()
        for u in urls:
            url = u[1]
            hash_ = u[0]
            title = u[2]
            published = u[3]
            feed_id = u[4]

            # get the text from the article content
            c_article_content.execute(
                'SELECT content FROM articles_content WHERE article_hash = %s', (hash_,))
            text = c_article_content.fetchone()[0]
            # print text

            country_values = {}
            sum_values = 0

            try:
                country_in_title = 0

                for iso, names in countries.items():

                    # count the nations
                    for name in names:
                        # count = text.count(name)

                        count = len(re.findall(
                            r'\b{0}\b'.format(name), text, re.UNICODE))
                        old_value = country_values.get(iso)
                        if old_value is None:
                            old_value = 0
                        country_values[iso] = old_value + count
                        sum_values += count
                        # check the title
                        # count = title.count(name)
                        count = len(re.findall(
                            r'\b{0}\b'.format(name), title, re.UNICODE))
                        if count > 0:
                            country_values[iso] = country_values[iso] + count
                            country_in_title = 1
                            sum_values += count

                print('***********************************\n' * 3)
                print(f"title :{title} - {url}")
                logging.debug(text)
                sorted_x = sorted(country_values.items(),
                                  key=operator.itemgetter(1))
                for t in sorted_x:
                    if t[1] > 0:
                        c_article_country.execute('INSERT INTO article_country( article_hash, country_iso3, article_day, source_feed_id, country_in_title, frequency, occurrences) VALUES (%s,%s,%s,%s,%s,%s,%s)', (
                            hash_, t[0], published.date(), feed_id, country_in_title, float(t[1])/sum_values, t[1]))
                        print(f'{t[0]}: {t[1]:3d} ({float(t[1])/sum_values:.2f})')
                c_article_country.execute(
                    "UPDATE articles SET flag_text_parsed = 1 WHERE hash = %s", (hash_,))
                self.db.commit()

            except Exception as e:
                self.db.close()
                raise e
        self.db.close()

    def computeArticleTitleSimilarity(self):
        self.db = psycopg2.connect(
            f"dbname={self.dbname} user={self.dbuser} password={self.dbpass} host={self.dbhost}"
        )
        c = self.db.cursor()

        days = []
        countries = []

        # get all the days
        c.execute(
            'SELECT DISTINCT article_day FROM article_country ORDER BY article_day DESC')
        for row in c.fetchall():
            days.append(row[0])

        # get countries with at least s news
        c.execute(
            'SELECT DISTINCT country_iso3 FROM article_country ORDER BY country_iso3')
        for row in c.fetchall():
            countries.append(row[0])

        # have fun, calculate the similarity between title articles of the same day of the same country
        for day in days:
            for iso in countries:
                print(f'>> >> Correlation for {iso} on {day}')
                q = 'SELECT a.hash, a.title FROM articles a, article_country ac, aggregate_article_country aac WHERE aac.article_day = %s AND aac.country_iso3 = %s AND ac.article_day = aac.article_day AND ac.country_iso3 = aac.country_iso3 AND a.hash = ac.article_hash;'
                c.execute(q, (day, iso))
                titles = {}
                hashes = []
                for row in c.fetchall():
                    print(f'news {row[0]:40s} title {row[1]}')
                    title = re.sub(
                        r'\W', ' ', row[1].lower(), flags=re.UNICODE)
                    words = [w for w in title.split() if w not in [
                        'the', 'but', 'a', 'to', 'from', 'in', 'for', 's', 'and', 'on', 'of']]
                    words = list(set(words))
                    words.sort()
                    titles[row[0]] = words
                    hashes.append(row[0])

                groups = {}

                for i in range(len(hashes)):
                    words = titles[hashes[i]]
                    for j in range(i+1, len(hashes)):
                        _words_ = titles[hashes[j]]

                        _common_ = [word for word in words if word in _words_]
                        similarity = float(len(_common_)) / \
                            float(len(set(words + _words_)))

                        if similarity > 0.08:
                            print(f'similarity {similarity:.2f} between {hashes[i]:40s} - {hashes[j]:40s}')
                            print(str(words))
                            print(str(_words_))
                            print(str(_common_))
                            print('')

                            group = groups.get(hashes[i])
                            if group is None:
                                groups[hashes[i]] = [hashes[j]]
                            else:
                                groups[hashes[i]].append(hashes[j])

                print(json.dumps(groups, indent=2))

        self.db.close()


def import_feeds(feeds_file):
    db = psycopg2.connect(
        f"dbname={DB_NAME} user={DB_USER} password={DB_PASS} host={DB_HOST}"
    )
    c = db.cursor()
    print(f"loading feeds from {feeds_file}")
    q_in = "INSERT INTO feeds(%s) VALUES %s ON CONFLICT DO NOTHING;"
    with open(feeds_file) as fp:
        records, inserts = 0, 0
        for feed in json.load(fp).get("feeds", []):
            columns = feed.keys()
            values = [feed[column] for column in columns]
            c.execute(q_in, (AsIs(','.join(columns)), tuple(values)))
            inserts += c.rowcount
            records += 1
    print(f"import completed, processed {records} records, imported {inserts}")
    db.commit()
    db.close()


def cmd_aggregate(args):
    feed = FeedKraken(outputpath='./www/data', debug=args.debug)
    feed.grabUrls()
    feed.extractArticlesText()
    feed.aggregateCountries()
    # feed.createJsonForMatrix()
    # feed.exportCountryArticleDetails()
    # feed.exportFeedsInfo()
    # feed.exportMatrixCountries()


def cmd_export(args):
    feed = FeedKraken(outputpath='./www/data', debug=args.debug)
    feed.createJsonForMatrix()
    feed.exportCountryArticleDetails()
    # feed.exportFeedsInfo()
    feed.exportMatrixCountries()
    feed.createPHPtable()


def cmd_import_feeds(args):
    import_feeds(args.file_path)


if __name__ == "__main__":
    args = [
        {
            'name': 'aggregate',
            'help': 'start the top up service',
            'target': cmd_aggregate,
            'opts': [
                {
                    "names": ["-debug"],
                    "default": False,
                    "action": "store_true",
                    "help": "the json file containing the list of feeds to process",
                }
            ]
        },
        {
            'name': 'export',
            'help': 'start the top up service',
            'target': cmd_export,
            'opts': [
                {
                    "names": ["-debug"],
                    "default": False,
                    "action": "store_true",
                    "help": "the json file containing the list of feeds to process",
                }
            ]
        },
        {
            'name': 'import',
            'help': 'populate the feed list',
            'target': cmd_import_feeds,
            'opts': [
                {
                    "names": ["-f", "--file-path"],
                    "default": "feeds.json",
                    "help": "the json file containing the list of feeds to process",
                }
            ]
        },
    ]
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()
    subparsers.required = True
    subparsers.dest = 'command'
    # register all the commands
    for c in args:
        subparser = subparsers.add_parser(c['name'], help=c['help'])
        subparser.set_defaults(func=c['target'])
        # add the sub arguments
        for sa in c.get('opts', []):
            subparser.add_argument(*sa['names'],
                                   help=sa['help'],
                                   action=sa.get('action'),
                                   default=sa.get('default'))

    # parse the arguments
    args = parser.parse_args()
    # call the function
    args.func(args)

    # options=1|2|3|4
    # 1=grab data and generate stats,
    # 2=generate stats,
    # 3=print tfidf,
    # 4=print articles similarity""" % (sys.argv[1], sys.argv[0]))

    # if sys.argv[1] == '3':
    #    feed.createTFIDFTopics()
    # if sys.argv[1] == '4':
    #    feed.computeArticleTitleSimilarity()
    # else:
    #    feed.runLSA()

    # http://garage.tyk.li/?a=98e5d974&t=760ca0ec0c9b83a70e05c6cad09a38fa
