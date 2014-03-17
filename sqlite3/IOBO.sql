-- Creator:       MySQL Workbench 5.2.37/ExportSQLite plugin 2009.12.02
-- Author:        Shawn Rynearson
-- Caption:       New Model
-- Project:       Name of the project
-- Changed:       2013-11-18 14:40
-- Created:       2013-11-11 10:17
PRAGMA foreign_keys = OFF;

-- Schema: IOBO
BEGIN;
CREATE TABLE "add_protein"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "protein_name" VARCHAR(45) NOT NULL,
  "genetic_alterations" VARCHAR(45),
  "conferred_capabilities" VARCHAR(45),
  "mutation_type" VARCHAR(45),
  "pathway" VARCHAR(45),
  "location" VARCHAR(45) NOT NULL
);

CREATE TABLE "relationships"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "subject" INTEGER NOT NULL,
  "predicate" VARCHAR(45) NOT NULL,
  "object" VARCHAR(45) NOT NULL,
  "originating" VARCHAR(45) NOT NULL,
  "pathway" VARCHAR(45)
);

CREATE TABLE add_hugo_annotation(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "protein_name" VARCHAR(45) NOT NULL,
    "comment_list" VARCHAR(100) NOT NULL,
    "hugo_list" VARCHAR(100) NOT NULL,
    "pathway" VARCHAR(45)
);

CREATE TABLE "add_complex"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"complex" VARCHAR(45) NOT NULL,
	"pathway" VARCHAR(45) NOT NULL
);

CREATE TABLE "metabolite_list"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"name" VARCHAR(45) NOT NULL
);

CREATE TABLE "add_comment"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"comment" VARCHAR(100) NOT NULL,
	"pathway" VARCHAR(45),
	"entity" VARCHAR(45),
	"originating" VARCHAR(45) NOT NULL
);
COMMIT;








