DROP TABLE IF EXISTS "feeds";
CREATE TABLE feeds (
	"feed_id" SERIAL PRIMARY KEY,
	"name" VARCHAR(255), 
	"url" VARCHAR(255) not null unique, 
	"lang" VARCHAR(3), 
	"general_topic" VARCHAR(255),
	"active" INTEGER DEFAULT 1,
	"last_update" TIMESTAMP
);

DROP TABLE IF EXISTS "articles";
CREATE TABLE "articles" (
	 "feed_id" INTEGER,
	 "article_id" TEXT,
	 "url" TEXT,
	 "hash" CHAR(40),
	 "title" TEXT,
	 "category" TEXT,
	 "published" TIMESTAMP,
	 "last_update" TIMESTAMP,
	 "author" VARCHAR(255),
	 "description" TEXT,
	 "meta_categories" TEXT,
	 "flag_text_extract" SMALLINT DEFAULT 0,
	 "flag_text_parsed" SMALLINT DEFAULT 0,
	 "flag_tyk_upload" SMALLINT DEFAULT 0,
	 "content" TEXT,
	 "extraction_method" VARCHAR(255)
);

DROP TABLE IF EXISTS "article_country";
CREATE TABLE "article_country" (
	 "article_hash" CHAR(40),
	 "country_iso3" CHAR(3),
	 "article_day" date,
	 "source_feed_id" INTEGER,
	 "country_in_title" SMALLINT,
	 "frequency" REAL,
	 "occurrences" INTEGER,
	PRIMARY KEY("article_hash","country_iso3")
);


-- POSTGRE articles scored by country/day
DROP VIEW IF EXISTS aggregate_article_country;
CREATE VIEW aggregate_article_country AS 
SELECT ac."article_day", 
	c."isoAlpha3" as iso, 
	c."countryName" as country, 
	c."continentName" as continent, 
	count(distinct ac."article_hash") as articles_num, 
	count(distinct ac."source_feed_id") as sources_num, 
	max(ac."country_in_title") as in_title,
	((count(distinct ac."article_hash") * 0.25) * (count(distinct ac."source_feed_id") / 2)) as score 
FROM article_country ac, countries c
WHERE ac."frequency" >= 0.2
AND c."isoAlpha3" = ac."country_iso3"
GROUP BY ac."article_day", c."isoAlpha3"
ORDER BY ac."article_day", c."isoAlpha3";
-- POSTGRE headlines
DROP VIEW IF EXISTS articles_headlines ;
CREATE VIEW articles_headlines AS
SELECT DISTINCT ac.article_day as article_day, c."countryName" as country, a.title as title, a.url as url, a.hash as article_hash, a.published as published
FROM article_country ac, articles a, countries c
WHERE ac.frequency >= 0.2 
AND a.hash = ac.article_hash 
AND c."isoAlpha3" = ac.country_iso3
ORDER BY a.published DESC;
-- POSTGRE articles by day
DROP VIEW IF EXISTS articles_headlines_feed ;
CREATE VIEW articles_headlines_feed AS
SELECT DISTINCT ac.article_day as article_day, 
	array_agg(DISTINCT c."isoAlpha3") as iso3, 
	array_agg(DISTINCT c."countryName") as country, 
	a.title as title, 
	a.url as url, 
	a.hash as article_hash, 
	a.published as published

FROM article_country ac, articles a, countries c
WHERE ac.frequency >= 0.2 
AND a.hash = ac.article_hash 
AND c."isoAlpha3" = ac.country_iso3
GROUP BY a.hash, a.title, a.url, a.published, ac.article_day
ORDER BY a.published DESC;
-- POSTGRE top countries
DROP VIEW IF EXISTS top_country_last_week;
CREATE VIEW top_country_last_week AS
SELECT country, iso, continent , sum(score) as total_score, avg(score) as avg_score
FROM aggregate_article_country
WHERE article_day > current_date - INTEGER '7'
GROUP BY country, iso, continent
ORDER BY total_score DESC;

-- END POSTGRES --


-- articles scored by country/day
DROP VIEW aggregate_article_country;
CREATE VIEW aggregate_article_country AS 
SELECT ac.article_day, 
	ac.country_iso3, 
	ci.country as country, 
	ci.continent as continent, 
	count(distinct ac.article_hash) as articles_num, 
	count(distinct ac.source_feed_id) as sources_num, 
	max(ac.country_in_title) as in_title,
	((count(distinct ac.article_hash) * 0.25) * (count(distinct ac.source_feed_id) / 2)) as score 
FROM article_country ac, country_info ci
WHERE ac.frequency >= 0.2
AND ci.iso3 = ac.country_iso3
GROUP BY ac.article_day, ac.country_iso3 
ORDER BY ac.article_day, ac.country_iso3



-- headlines
DROP VIEW articles_headlines ;
CREATE VIEW articles_headlines AS
SELECT DISTINCT ac.article_day as article_day, ci.country as country, a.title as title, a.url as url, a.hash as article_hash, a.published as published
FROM article_country ac, articles a, country_info ci
WHERE ac.frequency >= 0.2 
AND ci.is_primary = 1
AND a.hash = ac.article_hash 
AND ci.iso3 = ac.country_iso3
ORDER BY a.published DESC;



-- articles by day
DROP VIEW articles_headlines_feed ;
CREATE VIEW articles_headlines_feed AS
SELECT DISTINCT ac.article_day as article_day, 
	group_concat(ci.ISO3) as iso3, 
	group_concat(ci.Country) as country, 
	a.title as title, 
	a.url as url, 
	a.hash as article_hash, 
	a.published as published,

FROM article_country ac, articles a, country_info ci
WHERE ac.frequency >= 0.2 
AND ci.IsPrimary = 1
AND a.hash = ac.article_hash 
AND ci.ISO3 = ac.country_iso3
GROUP BY a.hash
ORDER BY a.published DESC;





-- top countries
DROP VIEW top_country_last_week;
CREATE VIEW top_country_last_week AS
SELECT country, country_iso3, continent , sum(score) as total_score, avg(score) as avg_score
FROM aggregate_article_country
WHERE article_day > date('now','-7 day')
GROUP BY country
ORDER BY total_score DESC;



DROP VIEW top_country_last_2week;
CREATE VIEW top_country_last_week AS
SELECT country, sum(score) as total_score, avg(score) as avg_score
FROM aggregate_article_country
WHERE article_day > date('now','-14 day')
GROUP BY country
ORDER BY score DESC;

