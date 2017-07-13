#!/bin/bash -ex
# ---
# RightScript Name: install_apache.sh
# Description: Installs apache and sets the default webpage to display hostname.
# Inputs: {}
# Attachments: []
# ...

hostname=`hostname`
sudo apt-get -y install apache2
cat <<EOF | sudo tee /var/www/html/index.html /dev/null 
<html>
<head>
<title>$hostname</title>
</head>
<body>$hostname</body>
<html>
EOF
