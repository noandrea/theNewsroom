
DROP VIEW aggregate_article_country;
CREATE VIEW aggregate_article_country AS 
SELECT ac.article_day, 
	ac.country_iso3, 
	ci.Country as country, 
	ci.Continent as continent, 
	count(distinct ac.article_hash) as articles_num, 
	count(distinct ac.source_feed_id) as sources_num, 
	max(ac.country_in_title) as in_title,
	((count(distinct ac.article_hash) * 0.25) * (count(distinct ac.source_feed_id) / 2)) as score 
FROM article_country ac, country_info ci
WHERE ac.frequency >= 0.2
AND ci.IsPrimary = 1
AND ci.ISO3 = ac.country_iso3
GROUP BY article_day,country_iso3 
ORDER BY article_day, country_iso3;

DROP VIEW articles_headlines ;
CREATE VIEW articles_headlines AS
SELECT DISTINCT ac.article_day as article_day, ci.Country as country, a.title as title, a.url as url, a.hash as article_hash
FROM article_country ac, articles a, country_info ci
WHERE ac.frequency >= 0.2 
AND ci.IsPrimary = 1
AND a.hash = ac.article_hash 
AND ci.ISO3 = ac.country_iso3
ORDER BY a.published DESC;

DROP VIEW top_country_last_week;
CREATE VIEW top_country_last_week AS
SELECT country, continent , sum(score) as total_score 
FROM aggregate_article_country
WHERE article_day > date('now','-7 day')
GROUP BY country
ORDER BY total_score DESC;

DROP VIEW top_country_last_2week;
CREATE VIEW top_country_last_week AS
SELECT country, sum(1 + (articles_num * 0.5) * (sources_num / 2)) as score 
FROM aggregate_article_country
WHERE article_day > date('now','-14 day')
GROUP BY country
ORDER BY score DESC;

