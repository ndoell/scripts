#!/bin/bash


# 
echo "********************Running katana.********************"
cat hosts | katana -jc -kf all -hl -o katana.out -silent -nc &
katanaPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running katana."
    exit 1
fi

# 
echo "********************Running gau********************"
cat hosts | gau --o gau.out &
gauPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running gau."
    exit 1
fi

# 
echo "********************Running hakrawler********************"
cat hosts | hakrawler -subs > hakrawler.out &
hakrawlerPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running hakrawler."
    exit 1
fi

# 
echo "********************Running gospider********************"
gospider -S hosts -o gospiderOut --subs --sitemap -a -c 10 -d 2 -q -t 4
gospiderPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running gospider."
    exit 1
fi

# Wait for assetfinder and findomain to finish before processing the output.
while kill -0 $katanaPID && kill -0 $gauPID && kill -0 $hakrawlerPID && kill -0 $gospiderPID; do
    echo "Waiting for katana, gau, hakrawler and gospider to finish. Check again in another 10 seconds."
    sleep 10
done

# Clean up gospider output.
echo "Cleaning up gospider output"
cat gospiderOut/* | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > gospiderOut.clean
if [ $? -ne 0 ]; then
    echo "Error cleaning gospider output."
    exit 1
fi

# Combine output.
sort -u katana.out -o links
cat gau.out | anew links
cat hakrawler.out | anew links
cat gospiderOut.clean | anew links
if [ $? -ne 0 ]; then
    echo "Error combining output."
    exit 1
fi

# remove images, fonts, pdf.
echo "********************Link Cleanup.********************"
grep -i -E -v '.png|.jpg|.woff|.pdf|.svg' links > links.cleaned
if [ $? -ne 0 ]; then
    echo "Error Running cleanup."
    exit 1
fi

# Keep only links that result in 200.
httpx -mc 200 -l links.cleaned -silent -nc -o links.200

# Go to every URL and grab any links to JS files.
subjs -i links.200 | anew links.200

# Capture the responses for every url.
httpx -mc 200 -l links.200 -srd httpxout -fr -silent -nc

# Search all files for secrets.
trufflehog filesystem --directory=httpxout --only-verified -j > trufflehog.out