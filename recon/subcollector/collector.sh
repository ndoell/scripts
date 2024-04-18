#!/bin/sh

cd /data

# Uniq/Combine all .subs files.
cat *.subs | anew combined.subs

# Remove *. from domain names.
#sed -i -e 's/*.//' combined.subs 

# Put https:// in front of each line.
cat combined.subs | sed -e 's/*.//' combined.subs | sed -e 's#^#https://#' > combined.hosts

# Send output to slack.
# If you want to get DOS'd
#notify -silent -provider slack -provider-config /data/notify/provider-config.yaml -data domains.out -bulk
if [ -f /setup/provider-config.yaml ]; then
    echo "Recon Job Complete" | notify -silent -provider slack -provider-config /setup/provider-config.yaml
fi