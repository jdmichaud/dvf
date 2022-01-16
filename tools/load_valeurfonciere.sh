#!/bin/bash

if [ $# -ne 2 ]
then
  echo "error: expecting 2 arguments"
  echo "usage: $0 <filename> <db>"
  exit 1
fi

file=$1
db=$2

sed -e 's/\([0-9]\),\([0-9]\)/\1.\2/g' $file > $file-pp
python load_valeurfonciere.py $file-pp $db
rm -fr $file-pp
# Now use the index column added by pandas to create a primary key in a table called vente
# There is going to be an error re-creating an index, it can be ignored.
echo '.schema' | sqlite3 $db | sed -e 's/"index" INTEGER/"index" INTEGER PRIMARY KEY/g' | sed -e 's/CREATE TABLE IF NOT EXISTS.*/CREATE TABLE IF NOT EXISTS "vente" \(/g' | sqlite3 $db
echo 'INSERT INTO vente SELECT * FROM vente2;' | sqlite3 $db
echo 'DROP TABLE vente2;' | sqlite3 $db
echo 'VACUUM;' | sqlite3 $db

