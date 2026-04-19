#!/bin/bash

cd `dirname "$0"`

if [[ `which jq` == "" ]]; then echo "error: jq must be installed"; exit 1; fi
if [[ `which curl` == "" ]]; then echo "error: curl be installed"; exit 1; fi
if [[ `which gzip` == "" ]]; then echo "error: gzip must be installed"; exit 1; fi

# Query the data.gouv.fr API for the dataset's resources and download the yearly zipped text files.
echo "Downloading files..."
curl --silent --show-error -L https://www.data.gouv.fr/api/1/datasets/demandes-de-valeurs-foncieres/ | \
  jq -r '.resources[] | select(.format == "txt.zip") | .url' | \
  xargs -i{} curl --silent --show-error -w "Download of %{url} finished\n" -OL {}

# Decompress any zip files
echo "Decompressing downloaded zip files..."
ls *.zip | xargs -L 1 unzip
rm -f *.zip

# Normalize filenames to lowercase (archives now ship as ValeursFoncieres-YYYY.txt).
for f in *.txt; do
  lower=`echo "$f" | tr '[:upper:]' '[:lower:]'`
  [[ "$f" != "$lower" ]] && mv -- "$f" "$lower"
done

# Compress everything. -n to make it deterministic.
echo "Compressing files..."
gzip -n --force --best *.txt

# Remove parquet files than may have been downloaded
rm -f *.parquet

# If anything changed, commit and push it to the git repo.
git diff --exit-code
if [[ $? -ne 0 ]];
then
  echo "Something changed"
  git add .
  git commit -m "Update of `date`"
  git push
fi

echo "done."
