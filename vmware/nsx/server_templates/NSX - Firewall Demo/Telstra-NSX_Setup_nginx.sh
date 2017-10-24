#!/bin/bash -ex
# ---
# RightScript Name: Telstra - NSX Setup nginx
# Inputs:
#   PORT1:
#     Category: Uncategorized
#     Input Type: single
#     Required: true
#     Advanced: false
#   PORT2:
#     Category: Uncategorized
#     Input Type: single
#     Required: true
#     Advanced: false
# Attachments: []
# ...

sudo apt-get -y update && sudo apt-get install -y nginx
cd /etc/nginx/sites-enabled
sudo rm -rf ./*

cd /etc/nginx/sites-available
for f in *; do
  if [ "$f" != "default" ]; then
    sudo rm -rf $f
  fi
done

sudo sed "s/80/$PORT1/g" default | sudo tee port_$PORT1 > /dev/null
sudo sed "s/80/$PORT2/g" default | sudo tee port_$PORT2 > /dev/null

sudo ln -s ../sites-available/port_$PORT1 ../sites-enabled/port_$PORT1
sudo ln -s ../sites-available/port_$PORT2 ../sites-enabled/port_$PORT2

echo "Hello Telstra" | sudo tee /var/www/html/index.html > /dev/null
sudo service nginx restart
