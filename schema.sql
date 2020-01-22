/*
 Navicat Premium Data Transfer

 Source Server         : The Newsroom AWS
 Source Server Type    : PostgreSQL
 Source Server Version : 90111
 Source Host           : localhost
 Source Database       : thenewsroom
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90111
 File Encoding         : utf-8

 Date: 01/08/2014 14:43:21 PM
*/

-- ----------------------------
--  Sequence structure for feeds_feed_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."feeds_feed_id_seq" CASCADE;
CREATE SEQUENCE "public"."feeds_feed_id_seq" INCREMENT 1 START 8 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;

-- ----------------------------
--  Table structure for feeds
-- ----------------------------
DROP TABLE IF EXISTS "public"."feeds" CASCADE;
CREATE TABLE "public"."feeds" (
	"feed_id" int4 NOT NULL DEFAULT nextval('feeds_feed_id_seq'::regclass),
	"name" varchar(255) COLLATE "default",
	"url" varchar(255) NOT NULL COLLATE "default",
  	"etag" varchar(255) COLLATE "default",
	"lang" varchar(3) COLLATE "default",
	"general_topic" varchar(255) COLLATE "default",
	"active" int4 DEFAULT 1,
	"last_update" timestamp(6) NULL,
	"modified" timestamp(6) NULL
);

-- ----------------------------
--  Table structure for countries_alternative_names
-- ----------------------------
DROP TABLE IF EXISTS "public"."countries_alternative_names" CASCADE;
CREATE TABLE "public"."countries_alternative_names" (
	"isoAlpha3" char(3) NOT NULL COLLATE "default",
	"alterntaive_name" varchar(255) NOT NULL COLLATE "default",
	"alternative_for" varchar(30) NOT NULL DEFAULT 'country_name'::character varying COLLATE "default"
);

-- ----------------------------
--  Table structure for countries
-- ----------------------------
DROP TABLE IF EXISTS "public"."countries" CASCADE;
CREATE TABLE "public"."countries" (
	"countryCode" char(2) COLLATE "default",
	"countryName" varchar(255) COLLATE "default",
	"currencyCode" varchar(255) COLLATE "default",
	"fipsCode" varchar(255) COLLATE "default",
	"isoNumeric" int4,
	"capital" varchar(255) COLLATE "default",
	"continentName" varchar(255) COLLATE "default",
	"continent" char(2) COLLATE "default",
	"languages" varchar(255) COLLATE "default",
	"isoAlpha3" char(3) NOT NULL COLLATE "default",
	"geonameId" int4
);

-- ----------------------------
--  Table structure for article_country
-- ----------------------------
DROP TABLE IF EXISTS "public"."article_country" CASCADE;
CREATE TABLE "public"."article_country" (
	"article_hash" char(40) NOT NULL COLLATE "default",
	"country_iso3" char(3) NOT NULL COLLATE "default",
	"article_day" date,
	"source_feed_id" int4,
	"country_in_title" int2,
	"frequency" float4,
	"occurrences" int4
);

-- ----------------------------
--  Table structure for articles_update
-- ----------------------------
DROP TABLE IF EXISTS "public"."articles_update" CASCADE;
CREATE TABLE "public"."articles_update" (
	"article_hash" char(40) NOT NULL COLLATE "default",
	"updated_on" timestamp(6) NOT NULL,
	"article_day" date NOT NULL,
	"count_duplicate" int4 DEFAULT 0
);

-- ----------------------------
--  Table structure for articles
-- ----------------------------
DROP TABLE IF EXISTS "public"."articles" CASCADE;
CREATE TABLE "public"."articles" (
	"feed_id" int4,
	"article_id" text COLLATE "default",
	"url" text COLLATE "default",
	"hash" char(40) NOT NULL COLLATE "default",
	"title" text COLLATE "default",
	"category" text COLLATE "default",
	"published" timestamp(6) NULL,
	"author" varchar(255) COLLATE "default",
	"description" text COLLATE "default",
	"img_url" varchar(500) COLLATE "default",
	"tags" text[],
	"lang" varchar(20) COLLATE "default",
	"meta_categories" text COLLATE "default",
	"flag_text_extract" int2 DEFAULT 0,
	"flag_text_parsed" int2 DEFAULT 0,
	"flag_tyk_upload" int2 DEFAULT 0,
	"content" text COLLATE "default",
	"extraction_method" varchar(255) COLLATE "default",
	"errors" int4 NOT NULL DEFAULT 0
);

-- ----------------------------
--  Table structure for articles_content
-- ----------------------------
DROP TABLE IF EXISTS "public"."articles_content" CASCADE;
CREATE TABLE "public"."articles_content" (
	"article_hash" char(40),
	"content" text COLLATE "default",
	"meta_description" text COLLATE "default"
);

-- ----------------------------
--  View structure for top_countries
-- ----------------------------
DROP VIEW IF EXISTS "public"."top_countries" CASCADE;
CREATE VIEW "public"."top_countries" AS SELECT aac.country, aac.country_iso3, aac.continent, sum(aac.score) AS total_score, avg(aac.score) AS avg_score FROM (countries c LEFT JOIN aggregate_article_country aac ON ((c."isoAlpha3" = aac.country_iso3))) GROUP BY aac.country, aac.country_iso3, aac.continent ORDER BY avg(aac.score);

-- ----------------------------
--  View structure for aggregate_article_country
-- ----------------------------
DROP VIEW IF EXISTS "public"."aggregate_article_country" CASCADE;
CREATE VIEW "public"."aggregate_article_country" AS SELECT ac.article_day, c."isoAlpha3" AS country_iso3, c."countryName" AS country, c."continentName" AS continent, count(DISTINCT ac.article_hash) AS articles_num, count(DISTINCT ac.source_feed_id) AS sources_num, max(ac.country_in_title) AS in_title, (((count(DISTINCT ac.article_hash))::numeric * 0.25) * ((count(DISTINCT ac.source_feed_id) / 2))::numeric) AS score FROM countries c, (article_country ac LEFT JOIN articles_update au ON (((au.article_hash = ac.article_hash) AND (au.article_day = ac.article_day)))) WHERE ((ac.frequency >= (0.2)::double precision) AND (c."isoAlpha3" = ac.country_iso3)) GROUP BY ac.article_day, c."isoAlpha3" ORDER BY ac.article_day, c."isoAlpha3";

-- ----------------------------
--  View structure for articles_headlines
-- ----------------------------
DROP VIEW IF EXISTS "public"."articles_headlines" CASCADE;
CREATE VIEW "public"."articles_headlines" AS SELECT DISTINCT ac.article_day, c."countryName" AS country, a.title, a.url, a.hash AS article_hash, a.published FROM article_country ac, articles a, countries c WHERE (((ac.frequency >= (0.2)::double precision) AND (a.hash = ac.article_hash)) AND (c."isoAlpha3" = ac.country_iso3)) ORDER BY a.published DESC;

-- ----------------------------
--  View structure for articles_headlines_feed
-- ----------------------------
DROP VIEW IF EXISTS "public"."articles_headlines_feed" CASCADE;
CREATE VIEW "public"."articles_headlines_feed" AS SELECT DISTINCT ac.article_day, array_agg(DISTINCT c."isoAlpha3") AS country_iso3, array_agg(DISTINCT c."countryName") AS country, a.title, a.url, a.hash AS article_hash, a.published FROM article_country ac, articles a, countries c WHERE (((ac.frequency >= (0.2)::double precision) AND (a.hash = ac.article_hash)) AND (c."isoAlpha3" = ac.country_iso3)) GROUP BY a.hash, a.title, a.url, a.published, ac.article_day ORDER BY a.published DESC;

-- ----------------------------
--  View structure for top_country_last_week
-- ----------------------------
DROP VIEW IF EXISTS "public"."top_country_last_week" CASCADE;
CREATE VIEW "public"."top_country_last_week" AS SELECT aggregate_article_country.country, aggregate_article_country.country_iso3, aggregate_article_country.continent, sum(aggregate_article_country.score) AS total_score, avg(aggregate_article_country.score) AS avg_score FROM aggregate_article_country WHERE (aggregate_article_country.article_day > (('now'::text)::date - 7)) GROUP BY aggregate_article_country.country, aggregate_article_country.country_iso3, aggregate_article_country.continent ORDER BY sum(aggregate_article_country.score) DESC;

-- ----------------------------
--  View structure for countries_keywords
-- ----------------------------
DROP VIEW IF EXISTS "public"."countries_keywords" CASCADE;
CREATE VIEW "public"."countries_keywords" AS SELECT c."isoAlpha3", array_append(array_append(alt."altNames", c."countryName"), c.capital) AS keywords FROM (countries c LEFT JOIN (SELECT can."isoAlpha3", array_agg(can.alterntaive_name) AS "altNames" FROM countries_alternative_names can GROUP BY can."isoAlpha3") alt ON ((c."isoAlpha3" = alt."isoAlpha3")));


-- ----------------------------
--  Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."feeds_feed_id_seq" RESTART 9 OWNED BY "feeds"."feed_id";
-- ----------------------------
--  Primary key structure for table feeds
-- ----------------------------
ALTER TABLE "public"."feeds" ADD PRIMARY KEY ("feed_id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Uniques structure for table feeds
-- ----------------------------
ALTER TABLE "public"."feeds" ADD CONSTRAINT "feeds_url_key" UNIQUE ("url") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table feeds
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38066" AFTER UPDATE ON "public"."feeds" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38066" ON "public"."feeds" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38065" AFTER DELETE ON "public"."feeds" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_setnull_del"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38065" ON "public"."feeds" IS NULL;

-- ----------------------------
--  Primary key structure for table countries_alternative_names
-- ----------------------------
ALTER TABLE "public"."countries_alternative_names" ADD PRIMARY KEY ("isoAlpha3", "alterntaive_name") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table countries_alternative_names
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_34832" AFTER UPDATE ON "public"."countries_alternative_names" FROM "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_34832" ON "public"."countries_alternative_names" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_34831" AFTER INSERT ON "public"."countries_alternative_names" FROM "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_ins"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_34831" ON "public"."countries_alternative_names" IS NULL;

-- ----------------------------
--  Primary key structure for table countries
-- ----------------------------
ALTER TABLE "public"."countries" ADD PRIMARY KEY ("isoAlpha3") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table countries
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_34830" AFTER UPDATE ON "public"."countries" FROM "public"."countries_alternative_names" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_34830" ON "public"."countries" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_34829" AFTER DELETE ON "public"."countries" FROM "public"."countries_alternative_names" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_del"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_34829" ON "public"."countries" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38056" AFTER UPDATE ON "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38056" ON "public"."countries" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38055" AFTER DELETE ON "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_del"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38055" ON "public"."countries" IS NULL;

-- ----------------------------
--  Primary key structure for table article_country
-- ----------------------------
ALTER TABLE "public"."article_country" ADD PRIMARY KEY ("article_hash", "country_iso3") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table article_country
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38058" AFTER UPDATE ON "public"."article_country" FROM "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38058" ON "public"."article_country" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38057" AFTER INSERT ON "public"."article_country" FROM "public"."countries" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_ins"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38057" ON "public"."article_country" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38063" AFTER UPDATE ON "public"."article_country" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38063" ON "public"."article_country" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38062" AFTER INSERT ON "public"."article_country" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_ins"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38062" ON "public"."article_country" IS NULL;

-- ----------------------------
--  Primary key structure for table articles_update
-- ----------------------------
ALTER TABLE "public"."articles_update" ADD PRIMARY KEY ("article_hash", "updated_on") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table articles_update
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38053" AFTER UPDATE ON "public"."articles_update" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38053" ON "public"."articles_update" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38052" AFTER INSERT ON "public"."articles_update" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_ins"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38052" ON "public"."articles_update" IS NULL;

-- ----------------------------
--  Primary key structure for table articles
-- ----------------------------
ALTER TABLE "public"."articles" ADD PRIMARY KEY ("hash") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table articles
-- ----------------------------
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38051" AFTER UPDATE ON "public"."articles" FROM "public"."articles_update" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38051" ON "public"."articles" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38050" AFTER DELETE ON "public"."articles" FROM "public"."articles_update" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_del"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38050" ON "public"."articles" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38068" AFTER UPDATE ON "public"."articles" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38068" ON "public"."articles" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38067" AFTER INSERT ON "public"."articles" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_check_ins"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38067" ON "public"."articles" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38061" AFTER UPDATE ON "public"."articles" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_upd"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38061" ON "public"."articles" IS NULL;
-- CREATE CONSTRAINT TRIGGER "RI_ConstraintTrigger_38060" AFTER DELETE ON "public"."articles" NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE "RI_FKey_cascade_del"();
-- COMMENT ON TRIGGER "RI_ConstraintTrigger_38060" ON "public"."articles" IS NULL;

-- ----------------------------
--  Foreign keys structure for table countries_alternative_names
-- ----------------------------
ALTER TABLE "public"."countries_alternative_names" ADD CONSTRAINT "can_countries_fk" FOREIGN KEY ("isoAlpha3") REFERENCES "public"."countries" ("isoAlpha3") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Foreign keys structure for table article_country
-- ----------------------------
ALTER TABLE "public"."article_country" ADD CONSTRAINT "ac_countries_fk" FOREIGN KEY ("country_iso3") REFERENCES "public"."countries" ("isoAlpha3") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "public"."article_country" ADD CONSTRAINT "ac_articles_fk" FOREIGN KEY ("article_hash") REFERENCES "public"."articles" ("hash") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Foreign keys structure for table articles_update
-- ----------------------------
ALTER TABLE "public"."articles_update" ADD CONSTRAINT "au_articles_fk" FOREIGN KEY ("article_hash") REFERENCES "public"."articles" ("hash") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Foreign keys structure for table articles
-- ----------------------------
ALTER TABLE "public"."articles" ADD CONSTRAINT "a_feeds_fk" FOREIGN KEY ("feed_id") REFERENCES "public"."feeds" ("feed_id") ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE INITIALLY IMMEDIATE;

