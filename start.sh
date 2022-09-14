#!/bin/bash

base=${1}
date=${2}

apt-get install git curl libjpeg-dev autoconf automake imagemagick gcc p7zip-full -y 

mkdir /wikidump
chmod 777 /wikidump

wget -O /wikidump/site.sh https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/$base.sh

chmod u+x /wikidump/site.sh

/wikidump/site.sh $base $date

echo "end of start.sh"
