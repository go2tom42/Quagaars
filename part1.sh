#!/bin/bash

while getopts n: flag
do
    case "${flag}" in
        n) filename=${OPTARG};;
    esac
done

apt-get install git curl libjpeg-dev autoconf automake imagemagick gcc p7zip-full -y 

mkdir /wikidump
chmod 777 /wikidump
