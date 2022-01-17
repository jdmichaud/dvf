# Cadastre

https://cadastre.data.gouv.fr/datasets/cadastre-etalab

Le cadastre produit des fichiers dans un format obscure (EDIGEO?) et Etalab les convertit en Shapefile et GeoJSON.

GeoJSON: https://files.data.gouv.fr/cadastre/etalab-cadastre/2018-10-01/geojson/

`fetch-cadastre` est un script qui aspire tous les fichiers (sauf les fichiers 'raw') du cadastre.

# Structure

Les fichiers se structurent au niveau national (france), departemental et communal.
A chaque niveau sera present trois structures:
- Les communes, qui se subdivisent en
- sections, qui se subdivisent en
- feuilles.

# Spatialite

On Ubuntu, install spatialite module for sqlite:
```
apt install libsqlite3-mod-spatialite
```
For testing purposes, you can install spatialite-bin which provide a sqlite3 like cli tool to execute SQL request versus the spatialite tables.
```
apt install spatialite-bin
```
In order to load the geojson file to spatialite, you will need `geojson-to-sqlite` a python utility:
```
pip install geojson-to-sqlite
```
Load the files:
```
geojson-to-sqlite cadastre.db sections france/cadastre-france-sections.json --spatialite
geojson-to-sqlite cadastre.db communes france/cadastre-france-communes.json --spatialite
geojson-to-sqlite cadastre.db feuilles france/cadastre-france-feuilles.json --spatialite
geojson-to-sqlite cadastre.db prefixes_sections france/cadastre-france-prefixes_sections.json --spatialite
```
To check that everything works:
```
$ spatialite cadastre.db
spatialite> select * from communes where within(GeomFromText('POINT(2.3481569732881167 48.85342813406896)'), communes.geometry);
```

