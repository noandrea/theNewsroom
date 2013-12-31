/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : PostgreSQL
 Source Server Version : 90301
 Source Host           : localhost
 Source Database       : thenewsroom
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90301
 File Encoding         : utf-8

 Date: 12/31/2013 18:57:42 PM
*/

-- ----------------------------
--  Table structure for countries_alternative_names
-- ----------------------------
DROP TABLE IF EXISTS "public"."countries_alternative_names";
CREATE TABLE "public"."countries_alternative_names" (
	"iso3" char(3) NOT NULL COLLATE "default",
	"alterntaive_name" varchar(255) NOT NULL COLLATE "default",
	"alternative_for" varchar(30) NOT NULL DEFAULT 'country_name'::character varying COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."countries_alternative_names" OWNER TO "anchorman";

-- ----------------------------
--  Records of countries_alternative_names
-- ----------------------------
BEGIN;
INSERT INTO "public"."countries_alternative_names" VALUES ('UKR', 'Kiev', 'capital_name');
INSERT INTO "public"."countries_alternative_names" VALUES ('GBR', 'England', 'country_name');
INSERT INTO "public"."countries_alternative_names" VALUES ('GBR', 'Britain', 'country_name');
INSERT INTO "public"."countries_alternative_names" VALUES ('USA', 'U.S.', 'country_name');
INSERT INTO "public"."countries_alternative_names" VALUES ('NLD', 'Holland', 'country_name');
COMMIT;

-- ----------------------------
--  Primary key structure for table countries_alternative_names
-- ----------------------------
ALTER TABLE "public"."countries_alternative_names" ADD PRIMARY KEY ("iso3", "alterntaive_name") NOT DEFERRABLE INITIALLY IMMEDIATE;

