#!/bin/bash

cd `dirname "$0"`

if [[ `which xidel` == "" ]]; then echo "error: xidel must be installed"; exit 1; fi
if [[ `which curl` == "" ]]; then echo "error: curl be installed"; exit 1; fi
if [[ `which gzip` == "" ]]; then echo "error: gzip must be installed"; exit 1; fi
  
git remote update
git reset --hard origin/master

# Open the DVF page, look for anything that look like a dataset in the "resources" section and download it.
echo "Downloading files..."
xidel --silent https://www.data.gouv.fr/en/datasets/demandes-de-valeurs-foncieres/ -e '//*[@id="resources"]/parent::*[1]//a[contains(@href, "https://static.data.gouv.fr/resources/")]' | \
  sed '/^$/d' | \
  xargs -i{} curl -sOL {}

# Compress everything. -n to make it deterministic.
echo "Compressing files..."
gzip -n --force --best *.txt *.pdf

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

