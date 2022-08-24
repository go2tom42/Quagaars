apt-get install git curl libjpeg-dev autoconf automake imagemagick gcc p7zip-full -y 
#curl -fsSL https://deb.nodesource.com/setup_12.x | bash - 
#apt-get install -y nodejs 
#npm -g config set user root 
#npm i -g mwoffliner

mkdir /wikidump
chmod 777 /wikidump

wget -O /home/bitnami/stack/mediawiki/resources/assets/RedDwarf.svg https://github.com/go2tom42/stolen_stuff/raw/master/tests/RedDwarf.svg
wget -O /home/bitnami/stack/mediawiki/favicon.ico https://raw.githubusercontent.com/go2tom42/stolen_stuff/master/tests/favicon.ico

sed -i 's/"Bitnami MediaWiki"/"12 Monkeys Wiki "/g' /bitnami/mediawiki/LocalSettings.php
sed -i 's/"Bitnami_MediaWiki"/"12_Monkeys_Wiki "/g' /bitnami/mediawiki/LocalSettings.php
sed -i 's/wiki.png/logo.svg/g' /bitnami/mediawiki/LocalSettings.php
sed -i 's/"vector"/"Citizen"/g' /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php
echo '' >> /bitnami/mediawiki/LocalSettings.php

echo '$wgDebugLogFile = "/var/log/mediawiki-debug.log";' >> /bitnami/mediawiki/LocalSettings.php

echo '$wgCitizenThemeDefault = "dark";' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgCitizenEnableCollapsibleSections = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgCitizenShowPageTools = "login";' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgCitizenEnableDrawerSiteStats = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgCitizenEnableSearch = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgScribuntoDefaultEngine = "luastandalone";' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgPortableInfoboxUseTidy = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgPortableInfoboxUseHeadings=false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgUseTidy = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgDefaultUserOptions["visualeditor-enable"] = 1;' >> /bitnami/mediawiki/LocalSettings.php
echo '# Disable anonymous editing' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgGroupPermissions["*"]["edit"] = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '# Prevent new user registrations except by sysops' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgGroupPermissions["*"]["createaccount"] = false;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgHTTPTimeout = 550;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgAsyncHTTPTimeout = 550;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgPFEnableStringFunctions = true;' >> /bitnami/mediawiki/LocalSettings.php

echo 'wfLoadExtension( "ParserFunctions" );' >> /bitnami/mediawiki/LocalSettings.php

echo 'wfLoadExtension( "TemplateStyles" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "PortableInfobox" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "Capiunto" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "TemplateData" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "Cite" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "PageImages" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "DisplayTitle" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "WikiaLikeGallery" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "VisualEditor" );' >> /bitnami/mediawiki/LocalSettings.php
# echo 'wfLoadExtension( "Variables" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "Scribunto" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "TabberNeue" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "DummyFandoomMainpageTags" );' >> /bitnami/mediawiki/LocalSettings.php
# echo 'wfLoadExtension( "EmbedVideo" );' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgEnableUploads = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgUseImageMagick = true;' >> /bitnami/mediawiki/LocalSettings.php
echo '$wgImageMagickConvertCommand = "/usr/bin/convert";' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadExtension( "ImageMap" );' >> /bitnami/mediawiki/LocalSettings.php
echo 'wfLoadSkin( "Citizen" );' >> /bitnami/mediawiki/LocalSettings.php

cd /bitnami/mediawiki/extensions

sudo -Hu bitnami git clone https://github.com/garc0/WikiaLikeGallery
sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/DisplayTitle
sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Collection
sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles
sudo -Hu bitnami git clone https://github.com/Universal-Omega/PortableInfobox.git --depth=1
# sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables
sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/MobileFrontend 
sudo -Hu bitnami git clone https://github.com/ciencia/mediawiki-extensions-DummyFandoomMainpageTags DummyFandoomMainpageTags --branch master
sudo -Hu bitnami git clone https://github.com/StarCitizenTools/mediawiki-extensions-TabberNeue.git TabberNeue
# sudo -Hu bitnami git clone https://gitlab.com/hydrawiki/extensions/EmbedVideo.git
sudo -Hu bitnami git clone -b REL1_37 https://gerrit.wikimedia.org/r/mediawiki/extensions/Capiunto
cd /bitnami/mediawiki/skins
sudo -Hu bitnami git clone https://github.com/StarCitizenTools/mediawiki-skins-Citizen Citizen




new_string="ServerName www.example.com\n  AllowEncodedSlashes NoDecode"
sed -i "s/ServerName www.example.com/$new_string/" /opt/bitnami/apache2/conf/vhosts/mediawiki-vhost.conf
chmod 755 /bitnami/mediawiki/extensions/Scribunto/includes/engines/LuaStandalone/binaries/lua5_1_5_linux_64_generic/lua
sudo reboot 0

