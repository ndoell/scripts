#!/bin/bash


# Pipe wildcards to `assetfinder` then to `anew` which keeps unique strings.
echo "********************Running assetfinder.********************"
cat wildcards| assetfinder --subs-only | anew domains &
assetfinderPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running assetfinder."
    exit 1
fi

# Run findomain and sernd output to findomain.out.
echo "********************Running findomain********************"
findomain -f wildcards > from-findomain &
findomainPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running findomain."
    exit 1
fi

# Run subfinder and sernd output to subfinder.out.
echo "********************Running subfinder********************"
subfinder -t 20 -dL wildcards -silent -o subfinder.out &
subfinderPID=$!
if [ $? -ne 0 ]; then
    echo "Error Running subfinder."
    exit 1
fi

# Wait for assetfinder and findomain to finish before processing the output.
while kill -0 $assetfinderPID && kill -0 $findomainPID && kill -0 $subfinderPID; do
    echo "Waiting for assetfinder, findomain and subfinder to finish. Check again in another 10 seconds."
    sleep 10
done

# Clean up findomain output.
cat from-findomain | grep .com | grep -v '>' > from-findomain.out
if [ $? -ne 0 ]; then
    echo "Error cleaning findomain output."
    exit 1
fi

# Combine output.
# cat *.out | anew domains
cat from-findomain.out | anew domains
cat subfinder.out | anew domains
if [ $? -ne 0 ]; then
    echo "Error combining output."
    exit 1
fi

# Seed amass with domains found.
echo "********************Running amass.********************"
#amass enum -brute -min-for-recursive 3 -df wildcards -nf domains -o amass.out
#amass enum -brute -df wildcards -nf domains -o amass.out
#if [ $? -ne 0 ]; then
#    echo "Error Running amass."
#    exit 1
#fi

#cat amass.out| anew domains

# Noticed an issue where the process ends and the file update lags.
# Running this after amass should compensate for the delay.
cat subfinder.out | anew domains

echo "All Done"