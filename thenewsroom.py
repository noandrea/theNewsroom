# -*- coding: utf-8 -*-

import time,json, feedparser, requests, logging, hashlib, string, operator, os, re, psycopg2
from tfidf import TfIdf
from bs4 import BeautifulSoup
from bs4.element import NavigableString
from bs4.element import Tag
from time import mktime
from datetime import datetime,timedelta

import sys
reload(sys) 
sys.setdefaultencoding('utf-8')



class FeedKraken:
	
	
	def __init__(self, outputpath=".", logpath='feed_kraken.log', dbuser='anchorman',dbpass='newsdesk',dbname='thenewsroom', dbhost='127.0.0.1'):
		self.outputpath = outputpath
		logging.basicConfig(filename=logpath,level=logging.INFO)
		logging.getLogger("requests").setLevel(logging.ERROR)
		logging.info('+------------------------+')
		logging.info('   RELEASE THE KRAKEN!!   ')
		logging.info('+------------------------+')
		logging.info('-- %s' % datetime.now())

		self.dbuser = dbuser
		self.dbpass = dbpass
		self.dbname = dbname
		self.dbhost = dbhost
	
	def grabUrls(self):
		logging.info('* grab urls')
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()
		c.execute('SELECT url, last_update, feed_id FROM feeds WHERE active = 1')
		feeds = c.fetchall()
		for f in feeds:
			updated = self.parse(f[0], f[1], f[2])
			c.execute('UPDATE feeds SET last_update = %s WHERE feed_id = %s', (updated, f[2]))
			self.db.commit()
		c.close()
		self.db.close()
		logging.info('* grab urls complete')
		
	def parse(self,url,start_date, feed_id):
	
		f = feedparser.parse(url)
		c = self.db.cursor()
		
		count = 0
		tmp_dates = [start_date]
		for entry in f.entries:
			published = datetime.fromtimestamp(mktime(entry.published_parsed))
			logging.debug('%s - %s = %d seconds' % (published,start_date,(published - start_date).total_seconds()))
			if (published - start_date).total_seconds() > 0:

				# CHECK IF IT IS ALREADY PRESENT WITH THE SAME DATE ON THE DATABASE
				sha1_hash = hashlib.sha1(entry.link).hexdigest()
				c.execute('SELECT published FROM articles WHERE hash = %s', (sha1_hash,))
				row = c.fetchone()
				if row is not None:
					logging.warn('url with hash %s exists with date %s, new date is %s ' % (sha1_hash, row[0], published))
					c.execute('SELECT article_hash,updated_on FROM articles_update WHERE article_hash = %s AND updated_on = %s', (sha1_hash,published))
					if c.fetchone() is None:
						c.execute("INSERT INTO articles_update(article_hash, updated_on, article_day) VALUES (%s,%s,%s)", (sha1_hash,published, published))
					else:
						c.execute("UPDATE articles_update SET count_duplicate = count_duplicate + 1 WHERE article_hash = %s AND updated_on = %s", (sha1_hash,published))	
					
				else:
					count += 1
					tmp_dates.append(published)
					data = (feed_id, 
						entry.get('id',None), 
						entry.link, 
						entry.get('title',None),
						entry.get('category',None),
						published, 
						entry.get('author',None),
						entry.get('description',None),
						sha1_hash
						)
					c.execute("INSERT INTO articles (feed_id,article_id,url,title,category,published,author,description,hash) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s)", data)
		logging.info('feed id %d has %d entries after %s' % (feed_id, count, start_date)) 
		return max(tmp_dates)

	def loadCountries(self):
		c = self.db.cursor()
		c.execute('SELECT "isoAlpha3", "keywords" FROM countries_keywords')
		data = {}
		for row in c.fetchall():
			data[row[0]] = [x.strip() for x in row[1] if x is not None and x != '']
		c.close()

		return data

	def createJsonForMatrix(self):
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()
		

		out = {'nodes_source':[],'nodes_target':[], 'links':[]}
		nodes_index_source = []
		nodes_index_target = []
		# load nodes
		c.execute('SELECT "countryName", "isoAlpha3", "continent" FROM countries c ORDER BY "countryName"')
		i=1;
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

			out['nodes_source'].append({'name':row[0], 'group':1, 'index':i})
			nodes_index_source.append(row[1])
			i+=1

		c.execute("SELECT distinct article_day FROM article_country ORDER BY article_day")
		for row in c.fetchall():
			out['nodes_target'].append({'name':str(row[0]), 'group':1,'index':i})
			nodes_index_target.append(str(row[0]))
			i+=1
		# load links and calculate the score
		c.execute("SELECT article_day, country_iso3, country, articles_num, sources_num, in_title, score FROM aggregate_article_country")
		for row in c.fetchall():
			day = row[0]
			iso3 = row[1]
			articles_num = row[3]
			sources_num = row[4]
			in_title_flag = row[5]
			score = row[6] #score = 1 + (articles_num * .5) * (sources_num / 2)
			
			i_cn = nodes_index_source.index(iso3)
			i_day = nodes_index_target.index(str(day))

			out['links'].append({'source': i_cn, 'target': i_day, 'value': str(score) })
		
		with open(os.path.join(self.outputpath,"aggregate_data.json"),"w") as ag:
			ag.write(json.dumps(out, indent=2))

		# now records the titles of the news
		headlines = {}
		c.execute("SELECT article_day,country,title,url FROM articles_headlines")
		for row in c.fetchall():
			lista = headlines.get(str(row[0])+'-'+row[1])
			if lista is None:
				headlines[str(row[0])+'-'+row[1]] = [{'title':row[2], 'url': row[3]}]	
			else:
				headlines[str(row[0])+'-'+row[1]].append({'title':row[2], 'url': row[3]}) 

		with open(os.path.join(self.outputpath,"aggregate_headlines.json"),"w") as ag:
			ag.write(json.dumps(headlines, indent=2))

		# nows feeds
		headlines = []
		c.execute("SELECT title,url,article_day,country,published,country_iso3 FROM articles_headlines_feed limit 100")
		for row in c.fetchall():
			headlines.append({'title':row[0], 'url':row[1] , 'country':row[3], 'published':str(row[4]), 'iso':row[5]})

		with open(os.path.join(self.outputpath,"aggregate_news_feed.json"),"w") as ag:
			ag.write(json.dumps(headlines, indent=2))

		# top scores
		scores = []
		c.execute("SELECT country,total_score,country_iso3 FROM top_country_last_week ")
		for row in c.fetchall():
			if row[1] > 1:
				scores.append((row[0],str(row[1]),row[2]))

		with open(os.path.join(self.outputpath,"aggregate_top_scores.json"),"w") as ag:
			ag.write(json.dumps(scores, indent=2))

		# tree map
		treemap = {'name':'news', 'children':[]}
		continets = {}
		c.execute("SELECT continent,country,total_score FROM top_country_last_week ")
		for row in c.fetchall():
			continet = row[0]
			cn = continets.get(continet)
			if cn is None:
				continets[continet] = [{'name':row[1], 'size':str(row[2]*5)}]
			else:
				continets[continet].append({'name':row[1], 'size':str(row[2]*5)})
		for cn,cos in continets.iteritems():
			treemap['children'].append({'name':cn, 'children':cos})

		with open(os.path.join(self.outputpath,"aggregate_tremap.json"),"w") as ag:
			ag.write(json.dumps(treemap, indent=2))

		# streamgraph
		dates = []
		countries = []
		csv_streamgraph = []
		c.execute("SELECT DISTINCT article_day FROM aggregate_article_country WHERE article_day > '2013-12-22' ORDER BY article_day")
		for row in c.fetchall():
			dates.append(row[0])
		c.execute('SELECT country_iso3 FROM top_countries WHERE country_iso3 IS NOT NULL')
		for row in c.fetchall():
			countries.append(row[0])

		for country in countries:
			for day in dates:
				c.execute("SELECT score FROM aggregate_article_country WHERE country_iso3 = %s AND article_day = %s", (country,day))
				row = c.fetchone()
				if row is None:
					csv_streamgraph.append('%s,%s,%s\n'%(country,'0',str(day)))
				else:
					csv_streamgraph.append('%s,%s,%s\n'%(country,str(row[0]),str(day)))
		
		with open(os.path.join(self.outputpath,"streamgraph_data.csv"),"w") as ag:
			ag.write('key,value,date\n')
			for line in csv_streamgraph:
				ag.write(line)

		self.db.close()

	def exportCountryArticleDetails(self):
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()

		# get the maximum and miniumum date frm aggregate_article_country
		c.execute("SELECT max(article_day) as max_day, min(article_day) as min_day FROM aggregate_article_country WHERE article_day > '2013-12-22'")
		row = c.fetchone()
		length=(row[0]-row[1]).days
		dates=[row[1]+timedelta(n) for n in range(length+1)]

		c.execute('SELECT "isoAlpha3" FROM  countries ORDER BY "countryName"')
		for row in c.fetchall():
			isoAlpha3 = row[0]
			with open(os.path.join(self.outputpath,"details_data_%s.tsv" % isoAlpha3),"w") as out_:
				out_.write("date\tscore\tarticles\tsources\n")

				for date in dates:
					c.execute('SELECT article_day,score,articles_num,sources_num FROM aggregate_article_country WHERE country_iso3 = %s AND article_day = %s', (isoAlpha3,date))					
					row2 = c.fetchone()
					if row2 is None:
						out_.write('%s\t%f\t%d\t%d\n' % (date,0,0,0))
						continue
					out_.write('%s\t%f\t%d\t%d\n' % (row2[0],row2[1],row2[2],row2[3]))


				# c.execute('SELECT article_day,score,articles_num,sources_num FROM aggregate_article_country WHERE country_iso3 = %s ORDER BY article_day', (isoAlpha3,))
				# for row2 in c.fetchall():
				# 	out_.write('%s\t%f\t%d\t%d\n' % (row2[0],row2[1],row2[2],row2[3]))



		self.db.close()


	def createPHPtable(self):
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()

		table_data = [ [0 for x in range(48)] for i in range(260)]
		nodes_index= {}
	
		# load nodes
		c.execute('SELECT "countryName", "isoAlpha3", "continent" FROM countries c ORDER BY "countryName"')
		i=1;
		for row in c.fetchall():
			table_data[i][0] = row[0]
			nodes_index[row[1]] = i
			i+=1

		c.execute("SELECT distinct article_day FROM article_country ORDER BY article_day DESC")
		i=1;
		for row in c.fetchall():
			table_data[0][i] = str(row[0]);
			nodes_index[str(row[0])] = i
			i+=1
		# load links and calculate the score
		c.execute("SELECT article_day, country_iso3, country, articles_num, sources_num, in_title FROM aggregate_article_country")
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
		
		with open(os.path.join(self.outputpath,"table_data.json"),"w") as ag:
			ag.write(json.dumps(table_data, indent=2))


		self.db.close()

	def createTFIDFTopics(self):
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()

		headlines = {}
		c.execute("SELECT article_day,country,title,url,article_hash FROM articles_headlines")
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

		for hd,contents in headlines.iteritems():
			print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> '+hd
			with open('stopwords.txt','r') as st:
				tfidf = TfIdf(stopwords = [x.strip() for x in st.readlines()])
				tfidf.parse(contents)
	
	def extractArticlesText(self):
		headers = {}
		proxy = '178.18.25.171:3128'
		proxyDict = { 
			"http"  : proxy, 
			"https" : proxy 
		}

		logging.info('* extract text')
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()
		
		c.execute('SELECT DISTINCT hash, url, title, published, feed_id FROM articles WHERE flag_text_extract = 0 ORDER BY published')
		urls = c.fetchall()


		for u in urls:
			url = u[1]
			hash_ = u[0]
			title = u[2]
			published = u[3]
			feed_id = u[4]

			try:
				print "######################################################"
				print "######################################################"
				print "######################################################"
				print "######################################################"
				print "######################################################"
				print "######################################################"
				print hash_
				#response = requests.get(url, proxies=proxyDict, headers=headers)
				response = requests.get(url, headers=headers)
				
				soup = BeautifulSoup(response.content, "lxml")
				# remove styles and scripts
				[s.extract() for s in soup('script')]
				[s.extract() for s in soup('style')]

				text = ''
				extraction_method = None
				textFound = False
				# check if there is <meta name="geo"> or <span itemprop="about" itemscope itemtype="http://schema.org/Place"><span itemprop="name">NAME</span></span>
				#soup.find_all('meta',)

				# first check the articleBody property
				contents = soup.find_all(attrs={"itemprop" : "articleBody"})
				if len(contents) > 0:
					print '!!! schema.org content'
					for ab in contents:
						text += ab.get_text(" ",strip=True)
					extraction_method = 'schema.org/articleBody'
					textFound = True
				if not textFound: # bbc word news
					contents = soup.find_all(attrs={"class" : "story-body"})
					if len(contents) > 0:
						print '!!! BBC content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'BBC/story-body'
						textFound = True
				if not textFound: # reuters
					contents = soup.find_all(attrs={"id" : "articleText"})
					if len(contents) > 0:
						print '!!! reuters content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'reuters/articleText'
						textFound = True
				if not textFound: # reuters
					contents = soup.find_all(attrs={"class" : "DetailedSummary"})
					if len(contents) > 0:
						print '!!! aljazeera content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'aljazeera/DetailedSummary'
						textFound = True
				if not textFound: # reuters
					contents = soup.find_all(attrs={"class" : "articleContent"})
					if len(contents) > 0:
						print '!!! indipendent content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'theindipendent/articleContent'
						textFound = True
				if not textFound: # reuters
					contents = soup.find_all(attrs={"class" : "entry-content"})
					if len(contents) > 0:
						print '!!! nyt blog content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'nyt-blog/entry-content'
						textFound = True
				if not textFound: # SPIEGEL ONLINE
					contents = soup.find_all(attrs={"class" : "article-section"})
					if len(contents) > 0:
						print '!!! SPIEGEL ONLINE content'
						for ab in contents:
							text += ab.get_text(" ",strip=True)
						extraction_method = 'spiegel/article-section'
						textFound = True

				if not textFound:
					text = soup.find("body").get_text(" ",strip=True)
					extraction_method = 'html/body'


				print title
				print url
				print text

				c.execute("UPDATE articles SET flag_text_extract = 1, content = %s, extraction_method = %s WHERE hash = %s", (text, extraction_method, hash_))
				self.db.commit()
			except Exception, e:
				c.execute("UPDATE articles SET errors = errors + 1 WHERE hash = %s", (hash_,))
				self.db.commit()
				
		self.db.close()		

	def aggregateCountries(self):
		self.db = psycopg2.connect("dbname=%s user=%s password=%s host=%s" % (self.dbname, self.dbuser, self.dbpass, self.dbhost))
		c = self.db.cursor()
		c_article_country = self.db.cursor()
		
		countries = self.loadCountries()
		
		c.execute('SELECT DISTINCT hash, url, title, published, feed_id, content FROM articles WHERE flag_text_extract = 1 AND flag_text_parsed = 0 ORDER BY published')
		urls = c.fetchall()
		for u in urls:
			url = u[1]
			hash_ = u[0]
			title = u[2]
			published = u[3]
			feed_id = u[4]
			text = u[5]

			country_values = {}
			sum_values = 0

			try:
				country_in_title = 0


				for iso,names in countries.iteritems():
					# count the nations
					for name in names:
						#count = text.count(name)

						count = len(re.findall(r'\b{0}\b'.format(name),text,re.UNICODE))
						old_value = country_values.get(iso)
						if old_value is None:
							old_value = 0
						country_values[iso] = old_value + count
						sum_values += count
						# check the title
						#count = title.count(name)
						count = len(re.findall(r'\b{0}\b'.format(name),title,re.UNICODE))
						if count > 0:
							country_values[iso] = country_values[iso] + count
							country_in_title = 1
							sum_values += count				

				print '***********************************'
				print '***********************************'
				print '***********************************'
				print title
				print url
				print text
				sorted_x = sorted(country_values.iteritems(), key=operator.itemgetter(1))	
				for t in sorted_x:
					if t[1] > 0:
						c_article_country.execute('INSERT INTO article_country( article_hash, country_iso3, article_day, source_feed_id, country_in_title, frequency, occurrences) VALUES (%s,%s,%s,%s,%s,%s,%s)', (hash_,t[0] ,published.date(), feed_id, country_in_title, float(t[1])/sum_values,t[1]))
						print '%s: %3d (%f)' % (t[0],t[1], float(t[1])/sum_values)
				c_article_country.execute("UPDATE articles SET flag_text_parsed = 1 WHERE hash = %s", (hash_,))
				self.db.commit()


			except Exception, e:
				self.db.close()
				raise e
		self.db.close()
			
	
if __name__ == "__main__": 
	feed = FeedKraken(outputpath='./www/data')
	#time.sleep(3600*3)
	# feed.setup()
	feed.grabUrls()
	feed.extractArticlesText()
	feed.aggregateCountries()
	feed.createJsonForMatrix()
	feed.createPHPtable()
	# feed.createTFIDFTopics()
	# http://garage.tyk.li/?a=98e5d974&t=760ca0ec0c9b83a70e05c6cad09a38fa
   	

