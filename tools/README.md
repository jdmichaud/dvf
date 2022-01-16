# Load a dataset

To load a DVF dataset to an sqlite database:
```
./load_valeurfonciere.sh valeurfonciere_2035.txt dvf.db
```

This will replace all , with ., create a table, populate it and fix a primary key.

# Publish a REST api

```
sandman2ctl sqlite+pysqlite:///dvf.db
```
Then
```
curl localhost:5000/vente/?Commune="BESANCON"\&Voie="%Fontaine%" | jq .
```

