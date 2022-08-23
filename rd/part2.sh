7z x /wikidump/reddwarffandomcom-20220813-wikidump.7z -o/wikidump


cd /wikidump/reddwarffandomcom-20220813-wikidump

sed -i 's/#DDDDDD/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#dddddd/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#CCCCCC/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#cccccc/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#EFEFEF/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#efefef/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#F9F9F9/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#f9f9f9/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#FFFFDD/#000000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#ffffdd/#000000/g' ./reddwarffandomcom-20220813-current.xml


sed -i 's/#DDD/#000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#ddd/#000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#CCC/#000/g' ./reddwarffandomcom-20220813-current.xml
sed -i 's/#ccc/#000/g' ./reddwarffandomcom-20220813-current.xml

cd /bitnami/mediawiki

sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importDump.php --conf ./LocalSettings.php /wikidump/reddwarffandomcom-20220813-wikidump/reddwarffandomcom-20220813-current.xml --username-prefix="" 
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importImages.php /wikidump/reddwarffandomcom-20220813-wikidump/images
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/updateArticleCount.php --update
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/rebuildall.php
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/update.php


chmod -R 777 /bitnami/mediawiki/images/thumb
