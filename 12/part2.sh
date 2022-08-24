7z x /wikidump/12_monkeysfandomcom-20220823-wikidump.7z -o/wikidump



#cd /wikidump/12_monkeysfandomcom-20220823-wikidump

#sed -i 's/#DDDDDD/#000000/g' ./reddwarffandomcom-20220813-current.xml
#sed -i 's/#DDD/#000/g' ./reddwarffandomcom-20220813-current.xml

cd /bitnami/mediawiki

sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importDump.php --conf ./LocalSettings.php /wikidump/12_monkeysfandomcom-20220823-wikidump/12_monkeysfandomcom-20220823-current.xml --username-prefix="" 
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importImages.php /wikidump/12_monkeysfandomcom-20220823-wikidump/images
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/updateArticleCount.php --update
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/rebuildall.php
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/update.php


chmod -R 777 /bitnami/mediawiki/images/thumb

