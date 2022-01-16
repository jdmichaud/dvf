import pandas as pd
import sqlite3
import sys

if len(sys.argv) != 3:
  print('error: expecting 2 arguments')
  print('usage: load <filename> <db>')
  sys.exit(1)

df = pd.read_csv(sys.argv[1], sep='|', low_memory=False)
con = sqlite3.connect(sys.argv[2])
df.to_sql('vente2', con)

