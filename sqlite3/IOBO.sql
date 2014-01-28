-- Creator:       MySQL Workbench 5.2.37/ExportSQLite plugin 2009.12.02
-- Author:        Shawn Rynearson
-- Caption:       New Model
-- Project:       Name of the project
-- Changed:       2013-11-18 14:40
-- Created:       2013-11-11 10:17
PRAGMA foreign_keys = OFF;

-- Schema: IOBO
BEGIN;
CREATE TABLE "gene_info"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "image_gene" VARCHAR(45) NOT NULL,
  "hugo_gene" VARCHAR(45),
  "complex_name" VARCHAR(45),
  "genetic_alterations" VARCHAR(45),
  "conferred_capabilities" VARCHAR(45),
  "mutation_type" VARCHAR(45),
  "pathway" VARCHAR(45),
  "definition" VARCHAR(100),
  "dbxref" VARCHAR(45),
  "location" VARCHAR(45) NOT NULL
);
CREATE TABLE "relationships"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "subject" INTEGER NOT NULL,
  "predicate" VARCHAR(45) NOT NULL,
  "object" VARCHAR(45) NOT NULL,
  CONSTRAINT "fk_relationship_gene_info1"
    FOREIGN KEY("subject")
    REFERENCES "gene_info"("id")
);

CREATE TABLE "gene_list"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"name" VARCHAR(45) NOT NULL
);

CREATE TABLE "complex_info"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"name" VARCHAR(45) NOT NULL,
	"parts" VARCHAR(45) NOT NULL,
	"pathway" VARCHAR(45) NOT NULL
);

CREATE TABLE "metabolic_list"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"name" VARCHAR(45) NOT NULL
);

CREATE TABLE "protein_list"(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	"name" VARCHAR(45) NOT NULL
);

CREATE INDEX "relationships.fk_relationship_gene_info1" ON "relationships"("subject");
COMMIT;








