# -*- coding: utf-8 -*-

import time,json, feedparser, requests, sqlite3, logging, hashlib, string, operator, os, re, psycopg2
from tfidf import TfIdf
from bs4 import BeautifulSoup
from bs4.element import NavigableString
from bs4.element import Tag
from time import mktime
from datetime import datetime,timedelta

import sys
reload(sys) 
sys.setdefaultencoding('utf-8')


def splitArticlesTable():
	_postgre_ = psycopg2.connect("dbname=thenewsroom user=anchorman password=newsdesk host=127.0.0.1")
	_postgre_cursor = _postgre_.cursor()

	_postgre_cursor.execute('SELECT hash, count(hash) as num FROM articles GROUP BY hash HAVING count(hash) > 1 ORDER BY num DESC')
	for row in _postgre_cursor.fetchall():
		print '%s has %d occurrences' % (row[0],row[1])
		_postgre_cursor.execute('SELECT hash, published FROM articles WHERE hash = %s AND published > (SELECT min(published) from articles WHERE hash = %s)', (row[0],row[0]))
		for row2 in _postgre_cursor.fetchall():
			_postgre_cursor.execute('SELECT article_hash,updated_on FROM articles_update WHERE article_hash = %s AND updated_on = %s',row2)
			if _postgre_cursor.fetchone() is None:
				_postgre_cursor.execute('INSERT INTO articles_update("article_hash","updated_on","article_day") VALUES (%s,%s,%s)', (row2[0],row2[1],row2[1]))
			else:
				_postgre_cursor.execute("UPDATE articles_update SET count_duplicate = count_duplicate + 1 WHERE article_hash = %s AND updated_on = %s", row2)	
			_postgre_cursor.execute('DELETE FROM articles WHERE "hash" = %s AND published = %s', row2)
	_postgre_.commit()

	# the nasty ones
	fields = ["feed_id", "article_id", "url", "hash", "title", "category", "published", "last_update", "author", "description", "meta_categories", "flag_text_extract", "flag_text_parsed", "flag_tyk_upload", "content", "extraction_method"]
	nasty_hash = ["'b2e62af1785f2ab12e3f3f9ef642dc9d949b0dd6'",	"'b4435361578ff53be81f39afdd949ab0db71e50c'",	"'8772fae5a1d68c191057f681e3c86df91f7a852a'",	"'ee4a13cfc51aabbd8980cea4ec74f7590b09a825'"]
	_postgre_cursor.execute("SELECT distinct %s FROM articles WHERE hash IN ( %s );" % (','.join(fields),','.join(nasty_hash)))
	nasty_rows = []
	for row in _postgre_cursor.fetchall():
		nasty_rows.append(row)
	_postgre_cursor.execute("DELETE FROM articles WHERE hash IN ( %s );" % (','.join(nasty_hash),))
	_postgre_.commit()
	for row in nasty_rows:
		query = 'INSERT INTO articles (%s) values (%s)' %  (','.join(fields), ','.join(['%s' for x in fields]) )
		_postgre_cursor.execute( query , row    )
	_postgre_.commit()

	post_queries = [
		'ALTER TABLE "public"."articles" ADD COLUMN "errors" INTEGER NOT NULL DEFAULT 0;'
		'DELETE FROM "public"."article_country" WHERE "source_feed_id" = 6;',
		'ALTER TABLE "public"."articles" DROP COLUMN "last_update";',
		'ALTER TABLE "public"."articles" ALTER COLUMN "hash" SET NOT NULL',
		'ALTER TABLE "public"."articles" ADD PRIMARY KEY ("hash")',
		'ALTER TABLE "public"."articles_update" ADD CONSTRAINT "au_articles_fk" FOREIGN KEY ("article_hash") REFERENCES "public"."articles" ("hash") ON UPDATE CASCADE ON DELETE CASCADE',
		'ALTER TABLE "public"."article_country" ADD CONSTRAINT "ac_countries_fk" FOREIGN KEY ("country_iso3") REFERENCES "public"."countries" ("isoAlpha3") ON UPDATE CASCADE ON DELETE CASCADE;'
		'ALTER TABLE "public"."article_country" ADD CONSTRAINT "ac_articles_fk" FOREIGN KEY ("article_hash") REFERENCES "public"."articles" ("hash") ON UPDATE CASCADE ON DELETE CASCADE;'
		'ALTER TABLE "public"."articles" ADD CONSTRAINT "a_feeds_fk" FOREIGN KEY ("feed_id") REFERENCES "public"."feeds" ("feed_id") ON UPDATE CASCADE ON DELETE SET NULL;'
	]
	
	for q in post_queries:
		_postgre_cursor.execute(q)
		_postgre_.commit()


	_postgre_cursor.close()
	_postgre_.close()

def migrateTable():
	_sqlite_ = sqlite3.connect('kraken.db', detect_types=sqlite3.PARSE_DECLTYPES)
	_sqlite_cursor = _sqlite_.cursor()

	_postgre_ = psycopg2.connect("dbname=thenewsroom user=anchorman password=newsdesk host=127.0.0.1")
	_postgre_cursor = _postgre_.cursor()

	_postgre_cursor.execute(open("countries.sql", "r").read())
	_postgre_.commit()

	tables = {
		'feeds' : ['name','url','lang','general_topic','active','last_update'],
		'articles' : ["feed_id","article_id","url","hash","title","category","published","last_update","author","description","meta_categories","flag_text_extract","flag_text_parsed","flag_tyk_upload","content","extraction_method"],
		'article_country' : ["article_hash","country_iso3","article_day","source_feed_id","country_in_title","frequency","occurrences"]
	}

	
	for table, fields in tables.iteritems():
		
		print '--- BEGIN TABLE %s MIGRATION ---' % table
		placeholders = ['%s' for x in fields]

		count = 1
		query_truncate = "TRUNCATE TABLE %s" % table
		query_select = "SELECT %s FROM %s" % (','.join(fields), table)
		query_insert = "INSERT INTO %s(%s) VALUES(%s)" % (table, ','.join(fields), ','.join(placeholders))

		print query_truncate
		print query_select
		print query_insert

		_postgre_cursor.execute(query_truncate)
		_sqlite_cursor.execute(query_select);
		
		for row in _sqlite_cursor.fetchall():
			_postgre_cursor.execute(query_insert, row)
			count += 1
		_postgre_.commit()
		print '%s migrated %d records' % (table, count)	
		print '--- END TABLE %s MIGRATION ---' % table


	_sqlite_cursor.close()
	_sqlite_.close()

	_postgre_cursor.close()
	_postgre_.close()
	
if __name__ == "__main__": 
	migrateTable()
	splitArticlesTable()

   	

