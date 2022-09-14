#!/bin/bash

function pause(){
   read -p "$*" </dev/tty
}


base=${1}
date=${2}

FILE=/wikidump/$base-$date-wikidump.7z
[ -f "$FILE" ] || { echo "File $FILE not found" && exit 0; }

title=apple2games
titlenospace=apple2games
logoextension=gif
theme=vector
url=apple2games.off-line.site


ParserFunctions=false
TemplateStyles=false
PortableInfobox=false
Capiunto=false
TemplateData=false
Cite=false
PageImages=false
DisplayTitle=false
WikiaLikeGallery=false
VisualEditor=false
Variables=false
Scribunto=false
TabberNeue=false
DummyFandoomMainpageTags=false
EmbedVideo=true
Collection=false
debug=false

# ############################################################################################
wget -O /home/bitnami/stack/mediawiki/resources/assets/logo.$logoextension https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/logo.$logoextension
wget -O /home/bitnami/stack/mediawiki/favicon.ico https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/favicon.ico	

sed -i "s/Bitnami MediaWiki/${title}/g" /bitnami/mediawiki/LocalSettings.php
sed -i "s/Bitnami_MediaWiki/${titlenospace}/g" /bitnami/mediawiki/LocalSettings.php
sed -i "s/192.168.1.18/${url}/g" /bitnami/mediawiki/LocalSettings.php
sed -i 's/wiki.png/logo.$logoextension/g' /bitnami/mediawiki/LocalSettings.php
sed -i "s/vector/$vector/g" /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgEnableUploads = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgUseImageMagick = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgImageMagickConvertCommand = "/usr/bin/convert";' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgUseTidy = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgDefaultUserOptions["visualeditor-enable"] = 1;' >> /bitnami/mediawiki/LocalSettings.php
echo '# Disable anonymous editing' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgGroupPermissions["*"]["edit"] = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '# Prevent new user registrations except by sysops' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgGroupPermissions["*"]["createaccount"] = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgHTTPTimeout = 550;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgAsyncHTTPTimeout = 550;' >> /bitnami/mediawiki/LocalSettings.php

if [ "$debug" = true ] ; then
    echo '$wgDebugLogFile = "/var/log/mediawiki-debug.log";' >> /bitnami/mediawiki/LocalSettings.php
fi

if [ "$ParserFunctions" = true ] ; then
	echo 'wfLoadExtension( "ParserFunctions" );' >> /bitnami/mediawiki/LocalSettings.php
fi

if [ "$TemplateStyles" = true ] ; then
    echo 'wfLoadExtension( "TemplateStyles" );' >> /bitnami/mediawiki/LocalSettings.php
fi

if [ "$PortableInfobox" = true ] ; then
    echo 'wfLoadExtension( "PortableInfobox" );' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgPortableInfoboxUseTidy = false;' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgPortableInfoboxUseHeadings=false;' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone https://github.com/Universal-Omega/PortableInfobox.git --depth=1
fi

if [ "$Capiunto" = true ] ; then
    echo 'wfLoadExtension( "Capiunto" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Capiunto
fi

if [ "$TemplateData" = true ] ; then
    echo 'wfLoadExtension( "TemplateData" );' >> /bitnami/mediawiki/LocalSettings.php
	
fi

if [ "$Cite" = true ] ; then
    echo 'wfLoadExtension( "Cite" );' >> /bitnami/mediawiki/LocalSettings.php
fi

if [ "$PageImages" = true ] ; then
    echo 'wfLoadExtension( "PageImages" );' >> /bitnami/mediawiki/LocalSettings.php
fi


if [ "$DisplayTitle" = true ] ; then
    echo 'wfLoadExtension( "DisplayTitle" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/DisplayTitle
fi


if [ "$WikiaLikeGallery" = true ] ; then
    echo 'wfLoadExtension( "WikiaLikeGallery" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone https://github.com/garc0/WikiaLikeGallery
fi

if [ "$VisualEditor" = true ] ; then
    echo 'wfLoadExtension( "VisualEditor" );' >> /bitnami/mediawiki/LocalSettings.php
fi

if [ "$Variables" = true ] ; then
    echo 'wfLoadExtension( "Variables" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables
fi

if [ "$Scribunto" = true ] ; then
    echo 'wfLoadExtension( "Scribunto" );' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgScribuntoDefaultEngine = "luastandalone";' >> /bitnami/mediawiki/LocalSettings.php
	chmod 755 /bitnami/mediawiki/extensions/Scribunto/includes/engines/LuaStandalone/binaries/lua5_1_5_linux_64_generic/lua
	
fi

if [ "$TabberNeue" = true ] ; then
	echo 'wfLoadExtension( "TabberNeue" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
    sudo -Hu bitnami git clone https://github.com/StarCitizenTools/mediawiki-extensions-TabberNeue.git TabberNeue
fi

if [ "$DummyFandoomMainpageTags" = true ] ; then
    echo 'wfLoadExtension( "DummyFandoomMainpageTags" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone https://github.com/ciencia/mediawiki-extensions-DummyFandoomMainpageTags DummyFandoomMainpageTags --branch master
fi

if [ "$EmbedVideo" = true ] ; then
    echo 'wfLoadExtension( "EmbedVideo" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone https://gitlab.com/hydrawiki/extensions/EmbedVideo.git
fi

if [ "$Collection" = true ] ; then
    echo 'wfLoadExtension( "Collection" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Collection	
fi

if [ "$TemplateStyles" = true ] ; then
    echo 'wfLoadExtension( "TemplateStyles" );' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/extensions
	sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles
fi

if [ "$ImageMap" = true ] ; then
    echo 'wfLoadExtension( "ImageMap" );' >> /bitnami/mediawiki/LocalSettings.php
	
fi

if [ "$theme" = "Citizen" ] ; then
    echo 'wfLoadSkin( "Citizen" );' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgCitizenThemeDefault = "dark";' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgCitizenEnableCollapsibleSections = false;' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgCitizenShowPageTools = "login";' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgCitizenEnableDrawerSiteStats = false;' >> /bitnami/mediawiki/LocalSettings.php
	echo '$wgCitizenEnableSearch = false;' >> /bitnami/mediawiki/LocalSettings.php
	cd /bitnami/mediawiki/skins
	sudo -Hu bitnami git clone https://github.com/StarCitizenTools/mediawiki-skins-Citizen Citizen
fi

new_string="ServerName www.example.com\n  AllowEncodedSlashes NoDecode"
sed -i "s/ServerName www.example.com/$new_string/" /opt/bitnami/apache2/conf/vhosts/mediawiki-vhost.conf

sudo /opt/bitnami/ctlscript.sh restart apache

sudo -Hu bitnami 7z x /wikidump/$base-$date-wikidump.7z -o/wikidump

sed -i 's/http:/https:/g' /wikidump/$base-$date-wikidump/$base-$date-current.xml

cd /bitnami/mediawiki

sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importDump.php --conf ./LocalSettings.php /wikidump/$base-$date-wikidump/$base-$date-current.xml --username-prefix="" 
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/importImages.php /wikidump/$base-$date-wikidump/images
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/updateArticleCount.php --update
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/rebuildall.php
sudo -Hu bitnami php /opt/bitnami/mediawiki/maintenance/update.php
echo

chmod -R 777 /bitnami/mediawiki/images/thumb
curl https://$url -o /dev/null

echo "end of apple2gamescom_w.sh"
