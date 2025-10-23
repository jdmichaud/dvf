#!/usr/bin/env bash

for url in $(cat urls)
do
  # Download following redirects
  curl -LO -s -L "$url"

  # Get final redirected URL
  final_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "$url")

  # Extract filename from final URL
  filename=$(basename "$final_url")

  # Extract original filename used by -O
  orig_filename=$(basename "$url")

  # Rename if different
  if [ "$filename" != "$orig_filename" ]; then
      mv "$orig_filename" "$filename"
  fi
done

