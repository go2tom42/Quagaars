#!/bin/bash

filename=${1}

apt-get install git curl libjpeg-dev autoconf automake imagemagick gcc p7zip-full -y 

mkdir /wikidump
chmod 777 /wikidump

wget -O /wikidump/site.sh https://raw.githubusercontent.com/go2tom42/Quagaars/master/$filename/$filename.sh

chmod u+x /wikidump/site.sh
source /wikidump/site.sh

echo "end of start.sh"
