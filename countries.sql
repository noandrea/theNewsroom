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

 Date: 12/31/2013 18:57:34 PM
*/
DROP VIEW IF EXISTS countries_keywords;
DROP VIEW IF EXISTS top_country_last_week;
DROP VIEW IF EXISTS articles_headlines_feed ;
DROP VIEW IF EXISTS articles_headlines ;
DROP VIEW IF EXISTS aggregate_article_country;
DROP TABLE IF EXISTS "public"."countries_alternative_names";
DROP TABLE IF EXISTS "article_country";
DROP TABLE IF EXISTS "articles_update";
DROP TABLE IF EXISTS "public"."countries";
DROP TABLE IF EXISTS "articles";
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


CREATE TABLE "articles_update" (
	"article_hash" char(40) NOT NULL,
	"updated_on" timestamp NOT NULL,
	"article_day" date NOT NULL,
	"count_duplicate" INTEGER DEFAULT 0,
	PRIMARY KEY ("article_hash", "updated_on")
);


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

-- ----------------------------
--  Table structure for countries
-- ----------------------------

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
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."countries" OWNER TO "anchorman";

-- ----------------------------
--  Records of countries
-- ----------------------------
BEGIN;
INSERT INTO "public"."countries" VALUES ('AI', 'Anguilla', 'XCD', 'AV', '660', 'The Valley', 'North America', 'NA', 'en-AI', 'AIA', '3573511');
INSERT INTO "public"."countries" VALUES ('AM', 'Armenia', 'AMD', 'AM', '51', 'Yerevan', 'Asia', 'AS', 'hy', 'ARM', '174982');
INSERT INTO "public"."countries" VALUES ('AQ', 'Antarctica', '', 'AY', '10', '', 'Antarctica', 'AN', '', 'ATA', '6697173');
INSERT INTO "public"."countries" VALUES ('AS', 'American Samoa', 'USD', 'AQ', '16', 'Pago Pago', 'Oceania', 'OC', 'en-AS,sm,to', 'ASM', '5880801');
INSERT INTO "public"."countries" VALUES ('AU', 'Australia', 'AUD', 'AS', '36', 'Canberra', 'Oceania', 'OC', 'en-AU', 'AUS', '2077456');
INSERT INTO "public"."countries" VALUES ('AX', 'Åland', 'EUR', '', '248', 'Mariehamn', 'Europe', 'EU', 'sv-AX', 'ALA', '661882');
INSERT INTO "public"."countries" VALUES ('BD', 'Bangladesh', 'BDT', 'BG', '50', 'Dhaka', 'Asia', 'AS', 'bn-BD,en', 'BGD', '1210997');
INSERT INTO "public"."countries" VALUES ('BF', 'Burkina Faso', 'XOF', 'UV', '854', 'Ouagadougou', 'Africa', 'AF', 'fr-BF', 'BFA', '2361809');
INSERT INTO "public"."countries" VALUES ('BH', 'Bahrain', 'BHD', 'BA', '48', 'Manama', 'Asia', 'AS', 'ar-BH,en,fa,ur', 'BHR', '290291');
INSERT INTO "public"."countries" VALUES ('BJ', 'Benin', 'XOF', 'BN', '204', 'Porto-Novo', 'Africa', 'AF', 'fr-BJ', 'BEN', '2395170');
INSERT INTO "public"."countries" VALUES ('BM', 'Bermuda', 'BMD', 'BD', '60', 'Hamilton', 'North America', 'NA', 'en-BM,pt', 'BMU', '3573345');
INSERT INTO "public"."countries" VALUES ('BO', 'Bolivia', 'BOB', 'BL', '68', 'Sucre', 'South America', 'SA', 'es-BO,qu,ay', 'BOL', '3923057');
INSERT INTO "public"."countries" VALUES ('BR', 'Brazil', 'BRL', 'BR', '76', 'Brasília', 'South America', 'SA', 'pt-BR,es,en,fr', 'BRA', '3469034');
INSERT INTO "public"."countries" VALUES ('BT', 'Bhutan', 'BTN', 'BT', '64', 'Thimphu', 'Asia', 'AS', 'dz', 'BTN', '1252634');
INSERT INTO "public"."countries" VALUES ('BW', 'Botswana', 'BWP', 'BC', '72', 'Gaborone', 'Africa', 'AF', 'en-BW,tn-BW', 'BWA', '933860');
INSERT INTO "public"."countries" VALUES ('BZ', 'Belize', 'BZD', 'BH', '84', 'Belmopan', 'North America', 'NA', 'en-BZ,es', 'BLZ', '3582678');
INSERT INTO "public"."countries" VALUES ('CC', 'Cocos [Keeling] Islands', 'AUD', 'CK', '166', 'West Island', 'Asia', 'AS', 'ms-CC,en', 'CCK', '1547376');
INSERT INTO "public"."countries" VALUES ('CF', 'Central African Republic', 'XAF', 'CT', '140', 'Bangui', 'Africa', 'AF', 'fr-CF,sg,ln,kg', 'CAF', '239880');
INSERT INTO "public"."countries" VALUES ('CH', 'Switzerland', 'CHF', 'SZ', '756', 'Berne', 'Europe', 'EU', 'de-CH,fr-CH,it-CH,rm', 'CHE', '2658434');
INSERT INTO "public"."countries" VALUES ('CK', 'Cook Islands', 'NZD', 'CW', '184', 'Avarua', 'Oceania', 'OC', 'en-CK,mi', 'COK', '1899402');
INSERT INTO "public"."countries" VALUES ('CM', 'Cameroon', 'XAF', 'CM', '120', 'Yaoundé', 'Africa', 'AF', 'en-CM,fr-CM', 'CMR', '2233387');
INSERT INTO "public"."countries" VALUES ('CO', 'Colombia', 'COP', 'CO', '170', 'Bogotá', 'South America', 'SA', 'es-CO', 'COL', '3686110');
INSERT INTO "public"."countries" VALUES ('CU', 'Cuba', 'CUP', 'CU', '192', 'Havana', 'North America', 'NA', 'es-CU', 'CUB', '3562981');
INSERT INTO "public"."countries" VALUES ('CW', 'Curacao', 'ANG', 'UC', '531', 'Willemstad', 'North America', 'NA', 'nl,pap', 'CUW', '7626836');
INSERT INTO "public"."countries" VALUES ('CY', 'Cyprus', 'EUR', 'CY', '196', 'Nicosia', 'Europe', 'EU', 'el-CY,tr-CY,en', 'CYP', '146669');
INSERT INTO "public"."countries" VALUES ('DE', 'Germany', 'EUR', 'GM', '276', 'Berlin', 'Europe', 'EU', 'de', 'DEU', '2921044');
INSERT INTO "public"."countries" VALUES ('DK', 'Denmark', 'DKK', 'DA', '208', 'Copenhagen', 'Europe', 'EU', 'da-DK,en,fo,de-DK', 'DNK', '2623032');
INSERT INTO "public"."countries" VALUES ('DO', 'Dominican Republic', 'DOP', 'DR', '214', 'Santo Domingo', 'North America', 'NA', 'es-DO', 'DOM', '3508796');
INSERT INTO "public"."countries" VALUES ('EC', 'Ecuador', 'USD', 'EC', '218', 'Quito', 'South America', 'SA', 'es-EC', 'ECU', '3658394');
INSERT INTO "public"."countries" VALUES ('EG', 'Egypt', 'EGP', 'EG', '818', 'Cairo', 'Africa', 'AF', 'ar-EG,en,fr', 'EGY', '357994');
INSERT INTO "public"."countries" VALUES ('ER', 'Eritrea', 'ERN', 'ER', '232', 'Asmara', 'Africa', 'AF', 'aa-ER,ar,tig,kun,ti-ER', 'ERI', '338010');
INSERT INTO "public"."countries" VALUES ('ET', 'Ethiopia', 'ETB', 'ET', '231', 'Addis Ababa', 'Africa', 'AF', 'am,en-ET,om-ET,ti-ET,so-ET,sid', 'ETH', '337996');
INSERT INTO "public"."countries" VALUES ('FJ', 'Fiji', 'FJD', 'FJ', '242', 'Suva', 'Oceania', 'OC', 'en-FJ,fj', 'FJI', '2205218');
INSERT INTO "public"."countries" VALUES ('FR', 'France', 'EUR', 'FR', '250', 'Paris', 'Europe', 'EU', 'fr-FR,frp,br,co,ca,eu,oc', 'FRA', '3017382');
INSERT INTO "public"."countries" VALUES ('GB', 'United Kingdom', 'GBP', 'UK', '826', 'London', 'Europe', 'EU', 'en-GB,cy-GB,gd', 'GBR', '2635167');
INSERT INTO "public"."countries" VALUES ('GE', 'Georgia', 'GEL', 'GG', '268', 'Tbilisi', 'Asia', 'AS', 'ka,ru,hy,az', 'GEO', '614540');
INSERT INTO "public"."countries" VALUES ('GG', 'Guernsey', 'GBP', 'GK', '831', 'St Peter Port', 'Europe', 'EU', 'en,fr', 'GGY', '3042362');
INSERT INTO "public"."countries" VALUES ('GI', 'Gibraltar', 'GIP', 'GI', '292', 'Gibraltar', 'Europe', 'EU', 'en-GI,es,it,pt', 'GIB', '2411586');
INSERT INTO "public"."countries" VALUES ('GM', 'Gambia', 'GMD', 'GA', '270', 'Banjul', 'Africa', 'AF', 'en-GM,mnk,wof,wo,ff', 'GMB', '2413451');
INSERT INTO "public"."countries" VALUES ('GP', 'Guadeloupe', 'EUR', 'GP', '312', 'Basse-Terre', 'North America', 'NA', 'fr-GP', 'GLP', '3579143');
INSERT INTO "public"."countries" VALUES ('GR', 'Greece', 'EUR', 'GR', '300', 'Athens', 'Europe', 'EU', 'el-GR,en,fr', 'GRC', '390903');
INSERT INTO "public"."countries" VALUES ('GT', 'Guatemala', 'GTQ', 'GT', '320', 'Guatemala City', 'North America', 'NA', 'es-GT', 'GTM', '3595528');
INSERT INTO "public"."countries" VALUES ('GW', 'Guinea-Bissau', 'XOF', 'PU', '624', 'Bissau', 'Africa', 'AF', 'pt-GW,pov', 'GNB', '2372248');
INSERT INTO "public"."countries" VALUES ('HK', 'Hong Kong', 'HKD', 'HK', '344', 'Hong Kong', 'Asia', 'AS', 'zh-HK,yue,zh,en', 'HKG', '1819730');
INSERT INTO "public"."countries" VALUES ('HN', 'Honduras', 'HNL', 'HO', '340', 'Tegucigalpa', 'North America', 'NA', 'es-HN', 'HND', '3608932');
INSERT INTO "public"."countries" VALUES ('HT', 'Haiti', 'HTG', 'HA', '332', 'Port-au-Prince', 'North America', 'NA', 'ht,fr-HT', 'HTI', '3723988');
INSERT INTO "public"."countries" VALUES ('ID', 'Indonesia', 'IDR', 'ID', '360', 'Jakarta', 'Asia', 'AS', 'id,en,nl,jv', 'IDN', '1643084');
INSERT INTO "public"."countries" VALUES ('IL', 'Israel', 'ILS', 'IS', '376', '', 'Asia', 'AS', 'he,ar-IL,en-IL,', 'ISR', '294640');
INSERT INTO "public"."countries" VALUES ('IQ', 'Iraq', 'IQD', 'IZ', '368', 'Baghdad', 'Asia', 'AS', 'ar-IQ,ku,hy', 'IRQ', '99237');
INSERT INTO "public"."countries" VALUES ('IS', 'Iceland', 'ISK', 'IC', '352', 'Reykjavik', 'Europe', 'EU', 'is,en,de,da,sv,no', 'ISL', '2629691');
INSERT INTO "public"."countries" VALUES ('JE', 'Jersey', 'GBP', 'JE', '832', 'Saint Helier', 'Europe', 'EU', 'en,pt', 'JEY', '3042142');
INSERT INTO "public"."countries" VALUES ('JO', 'Jordan', 'JOD', 'JO', '400', 'Amman', 'Asia', 'AS', 'ar-JO,en', 'JOR', '248816');
INSERT INTO "public"."countries" VALUES ('KE', 'Kenya', 'KES', 'KE', '404', 'Nairobi', 'Africa', 'AF', 'en-KE,sw-KE', 'KEN', '192950');
INSERT INTO "public"."countries" VALUES ('KH', 'Cambodia', 'KHR', 'CB', '116', 'Phnom Penh', 'Asia', 'AS', 'km,fr,en', 'KHM', '1831722');
INSERT INTO "public"."countries" VALUES ('KM', 'Comoros', 'KMF', 'CN', '174', 'Moroni', 'Africa', 'AF', 'ar,fr-KM', 'COM', '921929');
INSERT INTO "public"."countries" VALUES ('KP', 'North Korea', 'KPW', 'KN', '408', 'Pyongyang', 'Asia', 'AS', 'ko-KP', 'PRK', '1873107');
INSERT INTO "public"."countries" VALUES ('KW', 'Kuwait', 'KWD', 'KU', '414', 'Kuwait City', 'Asia', 'AS', 'ar-KW,en', 'KWT', '285570');
INSERT INTO "public"."countries" VALUES ('KZ', 'Kazakhstan', 'KZT', 'KZ', '398', 'Astana', 'Asia', 'AS', 'kk,ru', 'KAZ', '1522867');
INSERT INTO "public"."countries" VALUES ('LB', 'Lebanon', 'LBP', 'LE', '422', 'Beirut', 'Asia', 'AS', 'ar-LB,fr-LB,en,hy', 'LBN', '272103');
INSERT INTO "public"."countries" VALUES ('LI', 'Liechtenstein', 'CHF', 'LS', '438', 'Vaduz', 'Europe', 'EU', 'de-LI', 'LIE', '3042058');
INSERT INTO "public"."countries" VALUES ('LR', 'Liberia', 'LRD', 'LI', '430', 'Monrovia', 'Africa', 'AF', 'en-LR', 'LBR', '2275384');
INSERT INTO "public"."countries" VALUES ('LT', 'Lithuania', 'LTL', 'LH', '440', 'Vilnius', 'Europe', 'EU', 'lt,ru,pl', 'LTU', '597427');
INSERT INTO "public"."countries" VALUES ('LV', 'Latvia', 'LVL', 'LG', '428', 'Riga', 'Europe', 'EU', 'lv,ru,lt', 'LVA', '458258');
INSERT INTO "public"."countries" VALUES ('MA', 'Morocco', 'MAD', 'MO', '504', 'Rabat', 'Africa', 'AF', 'ar-MA,fr', 'MAR', '2542007');
INSERT INTO "public"."countries" VALUES ('MD', 'Moldova', 'MDL', 'MD', '498', 'Chişinău', 'Europe', 'EU', 'ro,ru,gag,tr', 'MDA', '617790');
INSERT INTO "public"."countries" VALUES ('MF', 'Saint Martin', 'EUR', 'RN', '663', 'Marigot', 'North America', 'NA', 'fr', 'MAF', '3578421');
INSERT INTO "public"."countries" VALUES ('ML', 'Mali', 'XOF', 'ML', '466', 'Bamako', 'Africa', 'AF', 'fr-ML,bm', 'MLI', '2453866');
INSERT INTO "public"."countries" VALUES ('MN', 'Mongolia', 'MNT', 'MG', '496', 'Ulan Bator', 'Asia', 'AS', 'mn,ru', 'MNG', '2029969');
INSERT INTO "public"."countries" VALUES ('MP', 'Northern Mariana Islands', 'USD', 'CQ', '580', 'Saipan', 'Oceania', 'OC', 'fil,tl,zh,ch-MP,en-MP', 'MNP', '4041468');
INSERT INTO "public"."countries" VALUES ('MR', 'Mauritania', 'MRO', 'MR', '478', 'Nouakchott', 'Africa', 'AF', 'ar-MR,fuc,snk,fr,mey,wo', 'MRT', '2378080');
INSERT INTO "public"."countries" VALUES ('MT', 'Malta', 'EUR', 'MT', '470', 'Valletta', 'Europe', 'EU', 'mt,en-MT', 'MLT', '2562770');
INSERT INTO "public"."countries" VALUES ('MV', 'Maldives', 'MVR', 'MV', '462', 'Malé', 'Asia', 'AS', 'dv,en', 'MDV', '1282028');
INSERT INTO "public"."countries" VALUES ('MX', 'Mexico', 'MXN', 'MX', '484', 'Mexico City', 'North America', 'NA', 'es-MX', 'MEX', '3996063');
INSERT INTO "public"."countries" VALUES ('MZ', 'Mozambique', 'MZN', 'MZ', '508', 'Maputo', 'Africa', 'AF', 'pt-MZ,vmw', 'MOZ', '1036973');
INSERT INTO "public"."countries" VALUES ('NC', 'New Caledonia', 'XPF', 'NC', '540', 'Noumea', 'Oceania', 'OC', 'fr-NC', 'NCL', '2139685');
INSERT INTO "public"."countries" VALUES ('NF', 'Norfolk Island', 'AUD', 'NF', '574', 'Kingston', 'Oceania', 'OC', 'en-NF', 'NFK', '2155115');
INSERT INTO "public"."countries" VALUES ('NI', 'Nicaragua', 'NIO', 'NU', '558', 'Managua', 'North America', 'NA', 'es-NI,en', 'NIC', '3617476');
INSERT INTO "public"."countries" VALUES ('NO', 'Norway', 'NOK', 'NO', '578', 'Oslo', 'Europe', 'EU', 'no,nb,nn,se,fi', 'NOR', '3144096');
INSERT INTO "public"."countries" VALUES ('AF', 'Afghanistan', 'AFN', 'AF', '4', 'Kabul', 'Asia', 'AS', 'fa-AF,ps,uz-AF,tk', 'AFG', '1149361');
INSERT INTO "public"."countries" VALUES ('NZ', 'New Zealand', 'NZD', 'NZ', '554', 'Wellington', 'Oceania', 'OC', 'en-NZ,mi', 'NZL', '2186224');
INSERT INTO "public"."countries" VALUES ('PA', 'Panama', 'PAB', 'PM', '591', 'Panama City', 'North America', 'NA', 'es-PA,en', 'PAN', '3703430');
INSERT INTO "public"."countries" VALUES ('PF', 'French Polynesia', 'XPF', 'FP', '258', 'Papeete', 'Oceania', 'OC', 'fr-PF,ty', 'PYF', '4030656');
INSERT INTO "public"."countries" VALUES ('PH', 'Philippines', 'PHP', 'RP', '608', 'Manila', 'Asia', 'AS', 'tl,en-PH,fil', 'PHL', '1694008');
INSERT INTO "public"."countries" VALUES ('PL', 'Poland', 'PLN', 'PL', '616', 'Warsaw', 'Europe', 'EU', 'pl', 'POL', '798544');
INSERT INTO "public"."countries" VALUES ('PN', 'Pitcairn Islands', 'NZD', 'PC', '612', 'Adamstown', 'Oceania', 'OC', 'en-PN', 'PCN', '4030699');
INSERT INTO "public"."countries" VALUES ('PS', 'Palestine', 'ILS', 'WE', '275', '', 'Asia', 'AS', 'ar-PS', 'PSE', '6254930');
INSERT INTO "public"."countries" VALUES ('QA', 'Qatar', 'QAR', 'QA', '634', 'Doha', 'Asia', 'AS', 'ar-QA,es', 'QAT', '289688');
INSERT INTO "public"."countries" VALUES ('RO', 'Romania', 'RON', 'RO', '642', 'Bucharest', 'Europe', 'EU', 'ro,hu,rom', 'ROU', '798549');
INSERT INTO "public"."countries" VALUES ('RU', 'Russia', 'RUB', 'RS', '643', 'Moscow', 'Europe', 'EU', 'ru,tt,xal,cau,ady,kv,ce,tyv,cv,udm,tut,mns,bua,myv,mdf,chm,ba,inh,tut,kbd,krc,ava,sah,nog', 'RUS', '2017370');
INSERT INTO "public"."countries" VALUES ('SA', 'Saudi Arabia', 'SAR', 'SA', '682', 'Riyadh', 'Asia', 'AS', 'ar-SA', 'SAU', '102358');
INSERT INTO "public"."countries" VALUES ('SC', 'Seychelles', 'SCR', 'SE', '690', 'Victoria', 'Africa', 'AF', 'en-SC,fr-SC', 'SYC', '241170');
INSERT INTO "public"."countries" VALUES ('SE', 'Sweden', 'SEK', 'SW', '752', 'Stockholm', 'Europe', 'EU', 'sv-SE,se,sma,fi-SE', 'SWE', '2661886');
INSERT INTO "public"."countries" VALUES ('SH', 'Saint Helena', 'SHP', 'SH', '654', 'Jamestown', 'Africa', 'AF', 'en-SH', 'SHN', '3370751');
INSERT INTO "public"."countries" VALUES ('SJ', 'Svalbard and Jan Mayen', 'NOK', 'SV', '744', 'Longyearbyen', 'Europe', 'EU', 'no,ru', 'SJM', '607072');
INSERT INTO "public"."countries" VALUES ('SL', 'Sierra Leone', 'SLL', 'SL', '694', 'Freetown', 'Africa', 'AF', 'en-SL,men,tem', 'SLE', '2403846');
INSERT INTO "public"."countries" VALUES ('SN', 'Senegal', 'XOF', 'SG', '686', 'Dakar', 'Africa', 'AF', 'fr-SN,wo,fuc,mnk', 'SEN', '2245662');
INSERT INTO "public"."countries" VALUES ('SR', 'Suriname', 'SRD', 'NS', '740', 'Paramaribo', 'South America', 'SA', 'nl-SR,en,srn,hns,jv', 'SUR', '3382998');
INSERT INTO "public"."countries" VALUES ('ST', 'São Tomé and Príncipe', 'STD', 'TP', '678', 'São Tomé', 'Africa', 'AF', 'pt-ST', 'STP', '2410758');
INSERT INTO "public"."countries" VALUES ('SX', 'Sint Maarten', 'ANG', 'NN', '534', 'Philipsburg', 'North America', 'NA', 'nl,en', 'SXM', '7609695');
INSERT INTO "public"."countries" VALUES ('SZ', 'Swaziland', 'SZL', 'WZ', '748', 'Mbabane', 'Africa', 'AF', 'en-SZ,ss-SZ', 'SWZ', '934841');
INSERT INTO "public"."countries" VALUES ('TD', 'Chad', 'XAF', 'CD', '148', 'N''Djamena', 'Africa', 'AF', 'fr-TD,ar-TD,sre', 'TCD', '2434508');
INSERT INTO "public"."countries" VALUES ('TG', 'Togo', 'XOF', 'TO', '768', 'Lomé', 'Africa', 'AF', 'fr-TG,ee,hna,kbp,dag,ha', 'TGO', '2363686');
INSERT INTO "public"."countries" VALUES ('TJ', 'Tajikistan', 'TJS', 'TI', '762', 'Dushanbe', 'Asia', 'AS', 'tg,ru', 'TJK', '1220409');
INSERT INTO "public"."countries" VALUES ('TM', 'Turkmenistan', 'TMT', 'TX', '795', 'Ashgabat', 'Asia', 'AS', 'tk,ru,uz', 'TKM', '1218197');
INSERT INTO "public"."countries" VALUES ('TL', 'East Timor', 'USD', 'TT', '626', 'Dili', 'Oceania', 'OC', 'tet,pt-TL,id,en', 'TLS', '1966436');
INSERT INTO "public"."countries" VALUES ('TO', 'Tonga', 'TOP', 'TN', '776', 'Nuku''alofa', 'Oceania', 'OC', 'to,en-TO', 'TON', '4032283');
INSERT INTO "public"."countries" VALUES ('TT', 'Trinidad and Tobago', 'TTD', 'TD', '780', 'Port of Spain', 'North America', 'NA', 'en-TT,hns,fr,es,zh', 'TTO', '3573591');
INSERT INTO "public"."countries" VALUES ('TW', 'Taiwan', 'TWD', 'TW', '158', 'Taipei', 'Asia', 'AS', 'zh-TW,zh,nan,hak', 'TWN', '1668284');
INSERT INTO "public"."countries" VALUES ('UA', 'Ukraine', 'UAH', 'UP', '804', 'Kyiv', 'Europe', 'EU', 'uk,ru-UA,rom,pl,hu', 'UKR', '690791');
INSERT INTO "public"."countries" VALUES ('UM', 'U.S. Minor Outlying Islands', 'USD', '', '581', '', 'Oceania', 'OC', 'en-UM', 'UMI', '5854968');
INSERT INTO "public"."countries" VALUES ('UY', 'Uruguay', 'UYU', 'UY', '858', 'Montevideo', 'South America', 'SA', 'es-UY', 'URY', '3439705');
INSERT INTO "public"."countries" VALUES ('VA', 'Vatican City', 'EUR', 'VT', '336', 'Vatican', 'Europe', 'EU', 'la,it,fr', 'VAT', '3164670');
INSERT INTO "public"."countries" VALUES ('VE', 'Venezuela', 'VEF', 'VE', '862', 'Caracas', 'South America', 'SA', 'es-VE', 'VEN', '3625428');
INSERT INTO "public"."countries" VALUES ('VI', 'U.S. Virgin Islands', 'USD', 'VQ', '850', 'Charlotte Amalie', 'North America', 'NA', 'en-VI', 'VIR', '4796775');
INSERT INTO "public"."countries" VALUES ('VU', 'Vanuatu', 'VUV', 'NH', '548', 'Port Vila', 'Oceania', 'OC', 'bi,en-VU,fr-VU', 'VUT', '2134431');
INSERT INTO "public"."countries" VALUES ('WS', 'Samoa', 'WST', 'WS', '882', 'Apia', 'Oceania', 'OC', 'sm,en-WS', 'WSM', '4034894');
INSERT INTO "public"."countries" VALUES ('YE', 'Yemen', 'YER', 'YM', '887', 'Sanaa', 'Asia', 'AS', 'ar-YE', 'YEM', '69543');
INSERT INTO "public"."countries" VALUES ('ZA', 'South Africa', 'ZAR', 'SF', '710', 'Pretoria', 'Africa', 'AF', 'zu,xh,af,nso,en-ZA,tn,st,ts,ss,ve,nr', 'ZAF', '953987');
INSERT INTO "public"."countries" VALUES ('ZW', 'Zimbabwe', 'ZWL', 'ZI', '716', 'Harare', 'Africa', 'AF', 'en-ZW,sn,nr,nd', 'ZWE', '878675');
INSERT INTO "public"."countries" VALUES ('AD', 'Andorra', 'EUR', 'AN', '20', 'Andorra la Vella', 'Europe', 'EU', 'ca', 'AND', '3041565');
INSERT INTO "public"."countries" VALUES ('AE', 'United Arab Emirates', 'AED', 'AE', '784', 'Abu Dhabi', 'Asia', 'AS', 'ar-AE,fa,en,hi,ur', 'ARE', '290557');
INSERT INTO "public"."countries" VALUES ('AG', 'Antigua and Barbuda', 'XCD', 'AC', '28', 'St. John''s', 'North America', 'NA', 'en-AG', 'ATG', '3576396');
INSERT INTO "public"."countries" VALUES ('AL', 'Albania', 'ALL', 'AL', '8', 'Tirana', 'Europe', 'EU', 'sq,el', 'ALB', '783754');
INSERT INTO "public"."countries" VALUES ('AO', 'Angola', 'AOA', 'AO', '24', 'Luanda', 'Africa', 'AF', 'pt-AO', 'AGO', '3351879');
INSERT INTO "public"."countries" VALUES ('AR', 'Argentina', 'ARS', 'AR', '32', 'Buenos Aires', 'South America', 'SA', 'es-AR,en,it,de,fr,gn', 'ARG', '3865483');
INSERT INTO "public"."countries" VALUES ('AT', 'Austria', 'EUR', 'AU', '40', 'Vienna', 'Europe', 'EU', 'de-AT,hr,hu,sl', 'AUT', '2782113');
INSERT INTO "public"."countries" VALUES ('AW', 'Aruba', 'AWG', 'AA', '533', 'Oranjestad', 'North America', 'NA', 'nl-AW,es,en', 'ABW', '3577279');
INSERT INTO "public"."countries" VALUES ('AZ', 'Azerbaijan', 'AZN', 'AJ', '31', 'Baku', 'Asia', 'AS', 'az,ru,hy', 'AZE', '587116');
INSERT INTO "public"."countries" VALUES ('BA', 'Bosnia and Herzegovina', 'BAM', 'BK', '70', 'Sarajevo', 'Europe', 'EU', 'bs,hr-BA,sr-BA', 'BIH', '3277605');
INSERT INTO "public"."countries" VALUES ('BB', 'Barbados', 'BBD', 'BB', '52', 'Bridgetown', 'North America', 'NA', 'en-BB', 'BRB', '3374084');
INSERT INTO "public"."countries" VALUES ('BE', 'Belgium', 'EUR', 'BE', '56', 'Brussels', 'Europe', 'EU', 'nl-BE,fr-BE,de-BE', 'BEL', '2802361');
INSERT INTO "public"."countries" VALUES ('BG', 'Bulgaria', 'BGN', 'BU', '100', 'Sofia', 'Europe', 'EU', 'bg,tr-BG', 'BGR', '732800');
INSERT INTO "public"."countries" VALUES ('BI', 'Burundi', 'BIF', 'BY', '108', 'Bujumbura', 'Africa', 'AF', 'fr-BI,rn', 'BDI', '433561');
INSERT INTO "public"."countries" VALUES ('BL', 'Saint Barthélemy', 'EUR', 'TB', '652', 'Gustavia', 'North America', 'NA', 'fr', 'BLM', '3578476');
INSERT INTO "public"."countries" VALUES ('BN', 'Brunei', 'BND', 'BX', '96', 'Bandar Seri Begawan', 'Asia', 'AS', 'ms-BN,en-BN', 'BRN', '1820814');
INSERT INTO "public"."countries" VALUES ('BQ', 'Bonaire', 'USD', '', '535', '', 'North America', 'NA', 'nl,pap,en', 'BES', '7626844');
INSERT INTO "public"."countries" VALUES ('BS', 'Bahamas', 'BSD', 'BF', '44', 'Nassau', 'North America', 'NA', 'en-BS', 'BHS', '3572887');
INSERT INTO "public"."countries" VALUES ('BV', 'Bouvet Island', 'NOK', 'BV', '74', '', 'Antarctica', 'AN', '', 'BVT', '3371123');
INSERT INTO "public"."countries" VALUES ('BY', 'Belarus', 'BYR', 'BO', '112', 'Minsk', 'Europe', 'EU', 'be,ru', 'BLR', '630336');
INSERT INTO "public"."countries" VALUES ('CA', 'Canada', 'CAD', 'CA', '124', 'Ottawa', 'North America', 'NA', 'en-CA,fr-CA,iu', 'CAN', '6251999');
INSERT INTO "public"."countries" VALUES ('CD', 'Democratic Republic of the Congo', 'CDF', 'CG', '180', 'Kinshasa', 'Africa', 'AF', 'fr-CD,ln,kg', 'COD', '203312');
INSERT INTO "public"."countries" VALUES ('CG', 'Republic of the Congo', 'XAF', 'CF', '178', 'Brazzaville', 'Africa', 'AF', 'fr-CG,kg,ln-CG', 'COG', '2260494');
INSERT INTO "public"."countries" VALUES ('CI', 'Ivory Coast', 'XOF', 'IV', '384', 'Yamoussoukro', 'Africa', 'AF', 'fr-CI', 'CIV', '2287781');
INSERT INTO "public"."countries" VALUES ('CL', 'Chile', 'CLP', 'CI', '152', 'Santiago', 'South America', 'SA', 'es-CL', 'CHL', '3895114');
INSERT INTO "public"."countries" VALUES ('CN', 'China', 'CNY', 'CH', '156', 'Beijing', 'Asia', 'AS', 'zh-CN,yue,wuu,dta,ug,za', 'CHN', '1814991');
INSERT INTO "public"."countries" VALUES ('CR', 'Costa Rica', 'CRC', 'CS', '188', 'San José', 'North America', 'NA', 'es-CR,en', 'CRI', '3624060');
INSERT INTO "public"."countries" VALUES ('CV', 'Cape Verde', 'CVE', 'CV', '132', 'Praia', 'Africa', 'AF', 'pt-CV', 'CPV', '3374766');
INSERT INTO "public"."countries" VALUES ('CX', 'Christmas Island', 'AUD', 'KT', '162', 'The Settlement', 'Asia', 'AS', 'en,zh,ms-CC', 'CXR', '2078138');
INSERT INTO "public"."countries" VALUES ('CZ', 'Czechia', 'CZK', 'EZ', '203', 'Prague', 'Europe', 'EU', 'cs,sk', 'CZE', '3077311');
INSERT INTO "public"."countries" VALUES ('DJ', 'Djibouti', 'DJF', 'DJ', '262', 'Djibouti', 'Africa', 'AF', 'fr-DJ,ar,so-DJ,aa', 'DJI', '223816');
INSERT INTO "public"."countries" VALUES ('DM', 'Dominica', 'XCD', 'DO', '212', 'Roseau', 'North America', 'NA', 'en-DM', 'DMA', '3575830');
INSERT INTO "public"."countries" VALUES ('DZ', 'Algeria', 'DZD', 'AG', '12', 'Algiers', 'Africa', 'AF', 'ar-DZ', 'DZA', '2589581');
INSERT INTO "public"."countries" VALUES ('EE', 'Estonia', 'EUR', 'EN', '233', 'Tallinn', 'Europe', 'EU', 'et,ru', 'EST', '453733');
INSERT INTO "public"."countries" VALUES ('EH', 'Western Sahara', 'MAD', 'WI', '732', 'El Aaiún', 'Africa', 'AF', 'ar,mey', 'ESH', '2461445');
INSERT INTO "public"."countries" VALUES ('ES', 'Spain', 'EUR', 'SP', '724', 'Madrid', 'Europe', 'EU', 'es-ES,ca,gl,eu,oc', 'ESP', '2510769');
INSERT INTO "public"."countries" VALUES ('FI', 'Finland', 'EUR', 'FI', '246', 'Helsinki', 'Europe', 'EU', 'fi-FI,sv-FI,smn', 'FIN', '660013');
INSERT INTO "public"."countries" VALUES ('MH', 'Marshall Islands', 'USD', 'RM', '584', 'Majuro', 'Oceania', 'OC', 'mh,en-MH', 'MHL', '2080185');
INSERT INTO "public"."countries" VALUES ('NR', 'Nauru', 'AUD', 'NR', '520', '', 'Oceania', 'OC', 'na,en-NR', 'NRU', '2110425');
INSERT INTO "public"."countries" VALUES ('FK', 'Falkland Islands', 'FKP', 'FK', '238', 'Stanley', 'South America', 'SA', 'en-FK', 'FLK', '3474414');
INSERT INTO "public"."countries" VALUES ('FM', 'Micronesia', 'USD', 'FM', '583', 'Palikir', 'Oceania', 'OC', 'en-FM,chk,pon,yap,kos,uli,woe,nkr,kpg', 'FSM', '2081918');
INSERT INTO "public"."countries" VALUES ('FO', 'Faroe Islands', 'DKK', 'FO', '234', 'Tórshavn', 'Europe', 'EU', 'fo,da-FO', 'FRO', '2622320');
INSERT INTO "public"."countries" VALUES ('GA', 'Gabon', 'XAF', 'GB', '266', 'Libreville', 'Africa', 'AF', 'fr-GA', 'GAB', '2400553');
INSERT INTO "public"."countries" VALUES ('GD', 'Grenada', 'XCD', 'GJ', '308', 'St. George''s', 'North America', 'NA', 'en-GD', 'GRD', '3580239');
INSERT INTO "public"."countries" VALUES ('GF', 'French Guiana', 'EUR', 'FG', '254', 'Cayenne', 'South America', 'SA', 'fr-GF', 'GUF', '3381670');
INSERT INTO "public"."countries" VALUES ('GH', 'Ghana', 'GHS', 'GH', '288', 'Accra', 'Africa', 'AF', 'en-GH,ak,ee,tw', 'GHA', '2300660');
INSERT INTO "public"."countries" VALUES ('GL', 'Greenland', 'DKK', 'GL', '304', 'Nuuk', 'North America', 'NA', 'kl,da-GL,en', 'GRL', '3425505');
INSERT INTO "public"."countries" VALUES ('GN', 'Guinea', 'GNF', 'GV', '324', 'Conakry', 'Africa', 'AF', 'fr-GN', 'GIN', '2420477');
INSERT INTO "public"."countries" VALUES ('GQ', 'Equatorial Guinea', 'XAF', 'EK', '226', 'Malabo', 'Africa', 'AF', 'es-GQ,fr', 'GNQ', '2309096');
INSERT INTO "public"."countries" VALUES ('GS', 'South Georgia and the South Sandwich Islands', 'GBP', 'SX', '239', 'Grytviken', 'Antarctica', 'AN', 'en', 'SGS', '3474415');
INSERT INTO "public"."countries" VALUES ('GU', 'Guam', 'USD', 'GQ', '316', 'Hagåtña', 'Oceania', 'OC', 'en-GU,ch-GU', 'GUM', '4043988');
INSERT INTO "public"."countries" VALUES ('GY', 'Guyana', 'GYD', 'GY', '328', 'Georgetown', 'South America', 'SA', 'en-GY', 'GUY', '3378535');
INSERT INTO "public"."countries" VALUES ('HM', 'Heard Island and McDonald Islands', 'AUD', 'HM', '334', '', 'Antarctica', 'AN', '', 'HMD', '1547314');
INSERT INTO "public"."countries" VALUES ('HR', 'Croatia', 'HRK', 'HR', '191', 'Zagreb', 'Europe', 'EU', 'hr-HR,sr', 'HRV', '3202326');
INSERT INTO "public"."countries" VALUES ('HU', 'Hungary', 'HUF', 'HU', '348', 'Budapest', 'Europe', 'EU', 'hu-HU', 'HUN', '719819');
INSERT INTO "public"."countries" VALUES ('IE', 'Ireland', 'EUR', 'EI', '372', 'Dublin', 'Europe', 'EU', 'en-IE,ga-IE', 'IRL', '2963597');
INSERT INTO "public"."countries" VALUES ('IM', 'Isle of Man', 'GBP', 'IM', '833', 'Douglas', 'Europe', 'EU', 'en,gv', 'IMN', '3042225');
INSERT INTO "public"."countries" VALUES ('IN', 'India', 'INR', 'IN', '356', 'New Delhi', 'Asia', 'AS', 'en-IN,hi,bn,te,mr,ta,ur,gu,kn,ml,or,pa,as,bh,sat,ks,ne,sd,kok,doi,mni,sit,sa,fr,lus,inc', 'IND', '1269750');
INSERT INTO "public"."countries" VALUES ('IO', 'British Indian Ocean Territory', 'USD', 'IO', '86', '', 'Asia', 'AS', 'en-IO', 'IOT', '1282588');
INSERT INTO "public"."countries" VALUES ('IR', 'Iran', 'IRR', 'IR', '364', 'Tehran', 'Asia', 'AS', 'fa-IR,ku', 'IRN', '130758');
INSERT INTO "public"."countries" VALUES ('IT', 'Italy', 'EUR', 'IT', '380', 'Rome', 'Europe', 'EU', 'it-IT,de-IT,fr-IT,sc,ca,co,sl', 'ITA', '3175395');
INSERT INTO "public"."countries" VALUES ('JM', 'Jamaica', 'JMD', 'JM', '388', 'Kingston', 'North America', 'NA', 'en-JM', 'JAM', '3489940');
INSERT INTO "public"."countries" VALUES ('JP', 'Japan', 'JPY', 'JA', '392', 'Tokyo', 'Asia', 'AS', 'ja', 'JPN', '1861060');
INSERT INTO "public"."countries" VALUES ('KG', 'Kyrgyzstan', 'KGS', 'KG', '417', 'Bishkek', 'Asia', 'AS', 'ky,uz,ru', 'KGZ', '1527747');
INSERT INTO "public"."countries" VALUES ('KI', 'Kiribati', 'AUD', 'KR', '296', 'Tarawa', 'Oceania', 'OC', 'en-KI,gil', 'KIR', '4030945');
INSERT INTO "public"."countries" VALUES ('KN', 'Saint Kitts and Nevis', 'XCD', 'SC', '659', 'Basseterre', 'North America', 'NA', 'en-KN', 'KNA', '3575174');
INSERT INTO "public"."countries" VALUES ('KR', 'South Korea', 'KRW', 'KS', '410', 'Seoul', 'Asia', 'AS', 'ko-KR,en', 'KOR', '1835841');
INSERT INTO "public"."countries" VALUES ('KY', 'Cayman Islands', 'KYD', 'CJ', '136', 'George Town', 'North America', 'NA', 'en-KY', 'CYM', '3580718');
INSERT INTO "public"."countries" VALUES ('LA', 'Laos', 'LAK', 'LA', '418', 'Vientiane', 'Asia', 'AS', 'lo,fr,en', 'LAO', '1655842');
INSERT INTO "public"."countries" VALUES ('LC', 'Saint Lucia', 'XCD', 'ST', '662', 'Castries', 'North America', 'NA', 'en-LC', 'LCA', '3576468');
INSERT INTO "public"."countries" VALUES ('LK', 'Sri Lanka', 'LKR', 'CE', '144', 'Colombo', 'Asia', 'AS', 'si,ta,en', 'LKA', '1227603');
INSERT INTO "public"."countries" VALUES ('LS', 'Lesotho', 'LSL', 'LT', '426', 'Maseru', 'Africa', 'AF', 'en-LS,st,zu,xh', 'LSO', '932692');
INSERT INTO "public"."countries" VALUES ('LU', 'Luxembourg', 'EUR', 'LU', '442', 'Luxembourg', 'Europe', 'EU', 'lb,de-LU,fr-LU', 'LUX', '2960313');
INSERT INTO "public"."countries" VALUES ('LY', 'Libya', 'LYD', 'LY', '434', 'Tripoli', 'Africa', 'AF', 'ar-LY,it,en', 'LBY', '2215636');
INSERT INTO "public"."countries" VALUES ('MC', 'Monaco', 'EUR', 'MN', '492', 'Monaco', 'Europe', 'EU', 'fr-MC,en,it', 'MCO', '2993457');
INSERT INTO "public"."countries" VALUES ('ME', 'Montenegro', 'EUR', 'MJ', '499', 'Podgorica', 'Europe', 'EU', 'sr,hu,bs,sq,hr,rom', 'MNE', '3194884');
INSERT INTO "public"."countries" VALUES ('MG', 'Madagascar', 'MGA', 'MA', '450', 'Antananarivo', 'Africa', 'AF', 'fr-MG,mg', 'MDG', '1062947');
INSERT INTO "public"."countries" VALUES ('MK', 'Macedonia', 'MKD', 'MK', '807', 'Skopje', 'Europe', 'EU', 'mk,sq,tr,rmm,sr', 'MKD', '718075');
INSERT INTO "public"."countries" VALUES ('MM', 'Myanmar [Burma]', 'MMK', 'BM', '104', 'Nay Pyi Taw', 'Asia', 'AS', 'my', 'MMR', '1327865');
INSERT INTO "public"."countries" VALUES ('MO', 'Macao', 'MOP', 'MC', '446', 'Macao', 'Asia', 'AS', 'zh,zh-MO,pt', 'MAC', '1821275');
INSERT INTO "public"."countries" VALUES ('MQ', 'Martinique', 'EUR', 'MB', '474', 'Fort-de-France', 'North America', 'NA', 'fr-MQ', 'MTQ', '3570311');
INSERT INTO "public"."countries" VALUES ('MS', 'Montserrat', 'XCD', 'MH', '500', 'Plymouth', 'North America', 'NA', 'en-MS', 'MSR', '3578097');
INSERT INTO "public"."countries" VALUES ('MU', 'Mauritius', 'MUR', 'MP', '480', 'Port Louis', 'Africa', 'AF', 'en-MU,bho,fr', 'MUS', '934292');
INSERT INTO "public"."countries" VALUES ('MW', 'Malawi', 'MWK', 'MI', '454', 'Lilongwe', 'Africa', 'AF', 'ny,yao,tum,swk', 'MWI', '927384');
INSERT INTO "public"."countries" VALUES ('MY', 'Malaysia', 'MYR', 'MY', '458', 'Kuala Lumpur', 'Asia', 'AS', 'ms-MY,en,zh,ta,te,ml,pa,th', 'MYS', '1733045');
INSERT INTO "public"."countries" VALUES ('NA', 'Namibia', 'NAD', 'WA', '516', 'Windhoek', 'Africa', 'AF', 'en-NA,af,de,hz,naq', 'NAM', '3355338');
INSERT INTO "public"."countries" VALUES ('NE', 'Niger', 'XOF', 'NG', '562', 'Niamey', 'Africa', 'AF', 'fr-NE,ha,kr,dje', 'NER', '2440476');
INSERT INTO "public"."countries" VALUES ('NG', 'Nigeria', 'NGN', 'NI', '566', 'Abuja', 'Africa', 'AF', 'en-NG,ha,yo,ig,ff', 'NGA', '2328926');
INSERT INTO "public"."countries" VALUES ('NL', 'Netherlands', 'EUR', 'NL', '528', 'Amsterdam', 'Europe', 'EU', 'nl-NL,fy-NL', 'NLD', '2750405');
INSERT INTO "public"."countries" VALUES ('NP', 'Nepal', 'NPR', 'NP', '524', 'Kathmandu', 'Asia', 'AS', 'ne,en', 'NPL', '1282988');
INSERT INTO "public"."countries" VALUES ('NU', 'Niue', 'NZD', 'NE', '570', 'Alofi', 'Oceania', 'OC', 'niu,en-NU', 'NIU', '4036232');
INSERT INTO "public"."countries" VALUES ('OM', 'Oman', 'OMR', 'MU', '512', 'Muscat', 'Asia', 'AS', 'ar-OM,en,bal,ur', 'OMN', '286963');
INSERT INTO "public"."countries" VALUES ('PE', 'Peru', 'PEN', 'PE', '604', 'Lima', 'South America', 'SA', 'es-PE,qu,ay', 'PER', '3932488');
INSERT INTO "public"."countries" VALUES ('PG', 'Papua New Guinea', 'PGK', 'PP', '598', 'Port Moresby', 'Oceania', 'OC', 'en-PG,ho,meu,tpi', 'PNG', '2088628');
INSERT INTO "public"."countries" VALUES ('PK', 'Pakistan', 'PKR', 'PK', '586', 'Islamabad', 'Asia', 'AS', 'ur-PK,en-PK,pa,sd,ps,brh', 'PAK', '1168579');
INSERT INTO "public"."countries" VALUES ('PM', 'Saint Pierre and Miquelon', 'EUR', 'SB', '666', 'Saint-Pierre', 'North America', 'NA', 'fr-PM', 'SPM', '3424932');
INSERT INTO "public"."countries" VALUES ('PR', 'Puerto Rico', 'USD', 'RQ', '630', 'San Juan', 'North America', 'NA', 'en-PR,es-PR', 'PRI', '4566966');
INSERT INTO "public"."countries" VALUES ('PT', 'Portugal', 'EUR', 'PO', '620', 'Lisbon', 'Europe', 'EU', 'pt-PT,mwl', 'PRT', '2264397');
INSERT INTO "public"."countries" VALUES ('PW', 'Palau', 'USD', 'PS', '585', 'Melekeok - Palau State Capital', 'Oceania', 'OC', 'pau,sov,en-PW,tox,ja,fil,zh', 'PLW', '1559582');
INSERT INTO "public"."countries" VALUES ('PY', 'Paraguay', 'PYG', 'PA', '600', 'Asunción', 'South America', 'SA', 'es-PY,gn', 'PRY', '3437598');
INSERT INTO "public"."countries" VALUES ('RE', 'Réunion', 'EUR', 'RE', '638', 'Saint-Denis', 'Africa', 'AF', 'fr-RE', 'REU', '935317');
INSERT INTO "public"."countries" VALUES ('RS', 'Serbia', 'RSD', 'RI', '688', 'Belgrade', 'Europe', 'EU', 'sr,hu,bs,rom', 'SRB', '6290252');
INSERT INTO "public"."countries" VALUES ('RW', 'Rwanda', 'RWF', 'RW', '646', 'Kigali', 'Africa', 'AF', 'rw,en-RW,fr-RW,sw', 'RWA', '49518');
INSERT INTO "public"."countries" VALUES ('SB', 'Solomon Islands', 'SBD', 'BP', '90', 'Honiara', 'Oceania', 'OC', 'en-SB,tpi', 'SLB', '2103350');
INSERT INTO "public"."countries" VALUES ('SD', 'Sudan', 'SDG', 'SU', '729', 'Khartoum', 'Africa', 'AF', 'ar-SD,en,fia', 'SDN', '366755');
INSERT INTO "public"."countries" VALUES ('SG', 'Singapore', 'SGD', 'SN', '702', 'Singapore', 'Asia', 'AS', 'cmn,en-SG,ms-SG,ta-SG,zh-SG', 'SGP', '1880251');
INSERT INTO "public"."countries" VALUES ('SI', 'Slovenia', 'EUR', 'SI', '705', 'Ljubljana', 'Europe', 'EU', 'sl,sh', 'SVN', '3190538');
INSERT INTO "public"."countries" VALUES ('SK', 'Slovakia', 'EUR', 'LO', '703', 'Bratislava', 'Europe', 'EU', 'sk,hu', 'SVK', '3057568');
INSERT INTO "public"."countries" VALUES ('SM', 'San Marino', 'EUR', 'SM', '674', 'San Marino', 'Europe', 'EU', 'it-SM', 'SMR', '3168068');
INSERT INTO "public"."countries" VALUES ('SO', 'Somalia', 'SOS', 'SO', '706', 'Mogadishu', 'Africa', 'AF', 'so-SO,ar-SO,it,en-SO', 'SOM', '51537');
INSERT INTO "public"."countries" VALUES ('SS', 'South Sudan', 'SSP', 'OD', '728', 'Juba', 'Africa', 'AF', 'en', 'SSD', '7909807');
INSERT INTO "public"."countries" VALUES ('SV', 'El Salvador', 'USD', 'ES', '222', 'San Salvador', 'North America', 'NA', 'es-SV', 'SLV', '3585968');
INSERT INTO "public"."countries" VALUES ('SY', 'Syria', 'SYP', 'SY', '760', 'Damascus', 'Asia', 'AS', 'ar-SY,ku,hy,arc,fr,en', 'SYR', '163843');
INSERT INTO "public"."countries" VALUES ('TC', 'Turks and Caicos Islands', 'USD', 'TK', '796', 'Cockburn Town', 'North America', 'NA', 'en-TC', 'TCA', '3576916');
INSERT INTO "public"."countries" VALUES ('TF', 'French Southern Territories', 'EUR', 'FS', '260', 'Port-aux-Français', 'Antarctica', 'AN', 'fr', 'ATF', '1546748');
INSERT INTO "public"."countries" VALUES ('TH', 'Thailand', 'THB', 'TH', '764', 'Bangkok', 'Asia', 'AS', 'th,en', 'THA', '1605651');
INSERT INTO "public"."countries" VALUES ('TK', 'Tokelau', 'NZD', 'TL', '772', '', 'Oceania', 'OC', 'tkl,en-TK', 'TKL', '4031074');
INSERT INTO "public"."countries" VALUES ('TN', 'Tunisia', 'TND', 'TS', '788', 'Tunis', 'Africa', 'AF', 'ar-TN,fr', 'TUN', '2464461');
INSERT INTO "public"."countries" VALUES ('TR', 'Turkey', 'TRY', 'TU', '792', 'Ankara', 'Asia', 'AS', 'tr-TR,ku,diq,az,av', 'TUR', '298795');
INSERT INTO "public"."countries" VALUES ('TV', 'Tuvalu', 'AUD', 'TV', '798', 'Funafuti', 'Oceania', 'OC', 'tvl,en,sm,gil', 'TUV', '2110297');
INSERT INTO "public"."countries" VALUES ('TZ', 'Tanzania', 'TZS', 'TZ', '834', 'Dodoma', 'Africa', 'AF', 'sw-TZ,en,ar', 'TZA', '149590');
INSERT INTO "public"."countries" VALUES ('UG', 'Uganda', 'UGX', 'UG', '800', 'Kampala', 'Africa', 'AF', 'en-UG,lg,sw,ar', 'UGA', '226074');
INSERT INTO "public"."countries" VALUES ('US', 'United States', 'USD', 'US', '840', 'Washington', 'North America', 'NA', 'en-US,es-US,haw,fr', 'USA', '6252001');
INSERT INTO "public"."countries" VALUES ('UZ', 'Uzbekistan', 'UZS', 'UZ', '860', 'Tashkent', 'Asia', 'AS', 'uz,ru,tg', 'UZB', '1512440');
INSERT INTO "public"."countries" VALUES ('VC', 'Saint Vincent and the Grenadines', 'XCD', 'VC', '670', 'Kingstown', 'North America', 'NA', 'en-VC,fr', 'VCT', '3577815');
INSERT INTO "public"."countries" VALUES ('VG', 'British Virgin Islands', 'USD', 'VI', '92', 'Road Town', 'North America', 'NA', 'en-VG', 'VGB', '3577718');
INSERT INTO "public"."countries" VALUES ('VN', 'Vietnam', 'VND', 'VM', '704', 'Hanoi', 'Asia', 'AS', 'vi,en,fr,zh,km', 'VNM', '1562822');
INSERT INTO "public"."countries" VALUES ('WF', 'Wallis and Futuna', 'XPF', 'WF', '876', 'Mata-Utu', 'Oceania', 'OC', 'wls,fud,fr-WF', 'WLF', '4034749');
INSERT INTO "public"."countries" VALUES ('XK', 'Kosovo', 'EUR', 'KV', '0', 'Pristina', 'Europe', 'EU', 'sq,sr', 'XKX', '831053');
INSERT INTO "public"."countries" VALUES ('YT', 'Mayotte', 'EUR', 'MF', '175', 'Mamoutzou', 'Africa', 'AF', 'fr-YT', 'MYT', '1024031');
INSERT INTO "public"."countries" VALUES ('ZM', 'Zambia', 'ZMK', 'ZA', '894', 'Lusaka', 'Africa', 'AF', 'en-ZM,bem,loz,lun,lue,ny,toi', 'ZMB', '895949');
COMMIT;

-- ----------------------------
--  Primary key structure for table countries
-- ----------------------------
ALTER TABLE "public"."countries" ADD PRIMARY KEY ("isoAlpha3") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Table structure for countries_alternative_names
-- ----------------------------

CREATE TABLE "public"."countries_alternative_names" (
	"isoAlpha3" char(3) NOT NULL COLLATE "default",
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
ALTER TABLE "public"."countries_alternative_names" ADD PRIMARY KEY ("isoAlpha3", "alterntaive_name") NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "public"."countries_alternative_names" ADD CONSTRAINT "can_countries_fk" FOREIGN KEY ("isoAlpha3") REFERENCES "public"."countries" ("isoAlpha3") ON UPDATE CASCADE ON DELETE CASCADE;





-- VIEWS
-- POSTGRE articles scored by country/day

CREATE VIEW aggregate_article_country AS 
SELECT ac."article_day", 
	c."isoAlpha3" as "country_iso3", 
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

CREATE VIEW articles_headlines AS
SELECT DISTINCT ac.article_day as article_day, c."countryName" as country, a.title as title, a.url as url, a.hash as article_hash, a.published as published
FROM article_country ac, articles a, countries c
WHERE ac.frequency >= 0.2 
AND a.hash = ac.article_hash 
AND c."isoAlpha3" = ac.country_iso3
ORDER BY a.published DESC;
-- POSTGRE articles by day

CREATE VIEW articles_headlines_feed AS
SELECT DISTINCT ac.article_day as article_day, 
	array_agg(DISTINCT c."isoAlpha3") as country_iso3, 
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

CREATE VIEW top_country_last_week AS
SELECT country, "country_iso3", continent , sum(score) as total_score, avg(score) as avg_score
FROM aggregate_article_country
WHERE article_day > current_date - INTEGER '7'
GROUP BY country, "country_iso3", continent
ORDER BY total_score DESC;

CREATE VIEW countries_keywords AS
select c."isoAlpha3", array_append(array_append(alt."altNames", c."countryName"), c.capital) as keywords
FROM countries c LEFT JOIN 
	( SELECT can."isoAlpha3", array_agg(can.alterntaive_name) as "altNames"
	  FROM countries_alternative_names can 
      GROUP BY can."isoAlpha3" ) alt
ON c."isoAlpha3" = alt."isoAlpha3";
