#!/bin/sh

cd /data
#cat katana.crawl | anew combined_links.out
#cat findomain.out | anew combined_domains.subs
#cat assetfinder.out | anew combined_domains.subs
#cat amass.out | anew combined_domains.subs
cat *.crawl | anew combined.crawl

# remove images, fonts, pdf.
#grep -i -E -v '.png|.jpg|.woff|.pdf|.svg' combined.crawl > combined_clean.crawl

# Keep only links that result in 200.
#httpx -mc 200 -l combined_links_cleaned.out -silent -nc -o combined_links_cleaned_200.out
grep -i -E -v '.png|.jpg|.woff|.pdf|.svg' combined.crawl | httpx -mc 200 -silent -nc -o combined_clean.crawl

# Go to every URL and grab any links to JS files.
subjs -i combined_clean.crawl | anew combined_clean.crawl

# Capture the responses for every url.
httpx -mc 200 -l combined_clean.crawl -srd httpxout -fr -silent -nc

#cat combined_links_cleaned.out | subjs | httpx -mc 200 -srd httpxout -fr -silent -nc

# Send output to slack.
# If you want to get DOS'd
#notify -silent -provider slack -provider-config /data/notify/provider-config.yaml -data domains.out -bulk
echo "Crawl Job Complete" | notify -silent -provider slack -provider-config /setup/provider-config.yaml