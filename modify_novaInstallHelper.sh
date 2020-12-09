#! /bin/bash
# get, modify, and run novaInstallHelper.sh from Datasoft
#
# NOTE:
# Some of the modifications to novaInstallHelper.sh will
# modify some of the content downloaded by novaInstallHelper.sh
########################################################################
time (
   set -x
   nodeVerNew=$(node --version)
   nodeVerOld="v0.8.5"
   export BUILDDIR=/usr/local/src/nova
   [[ -d $BUILDDIR ]] || mkdir -p $BUILDDIR
   cd $BUILDDIR

   wget https://raw.github.com/DataSoft/Nova/master/debian/novaInstallHelper.sh

   # update novaInstallHelper.sh to:
   # - replace pkg "libcurl3" with "libcurl4"
   # - append pkgs2append
   # - comment out chown of node-$ media and source
   # - update Nova/Quasar/getDependencies.sh (this is immediately after `cd ${BUILDDIR}/Nova/Quasar`)
   # - - appending "-e" to "#! /bin/bash"
   # - - current download path for libv8-convert-20120219.tar.gz
   pkgs2append="libev-dev"
   tsNIH=$(date -d@$(stat -c %Y $BUILDDIR/novaInstallHelper.sh) +%Y%m%d.%H%M%S)
   sed -i.$tsNIH \
   -e '/^apt-get -y install/s/ libcurl3 / libcurl4 /' \
   -e '/^apt-get -y install/s/$/ '"$pkgs2append"'/' \
   -e '/chown .* node-'"$nodeVerOld"'/s/^/#/' \
   -e '/bash getDependencies.sh/i \
   FILES=`grep -irl "BOOST_FILESYSTEM_VERSION 2" ../` \
   sed -i -e "s/BOOST_FILESYSTEM_VERSION 2/BOOST_FILESYSTEM_VERSION 3/" ${FILES} ' \
   -e '/bash getDependencies.sh/i \
   FILES=`grep -irl "boost::property_tree::xml_writer_settings<char>" ../` \
   sed -i -e "s/boost::property_tree::xml_writer_settings<char>/boost::property_tree::xml_writer_settings<std::string>/" ${FILES} ' \
   -e '/bash getDependencies.sh/i \
   FILES=`grep -irl "if( honeydConfFile == NULL)" ../` \
   sed -i -e "s/if( honeydConfFile == NULL)/if(\\!honeydConfFile)/" ${FILES} ' \
   -e '/bash getDependencies.sh/i \
   FILES=`grep -irl "if(getline (ipListFileStream,line) == 0)" ../` \
   sed -i -e "s/if(getline (ipListFileStream,line) == 0)/getline (ipListFileStream,line); if(ipListFileStream.gcount() == 0)/" ${FILES} ' \
   -e '/bash getDependencies.sh/i \
   tsGD=$(date -d@$(stat -c %Y ./getDependencies.sh) +%Y%m%d.%H%M%S) \
   url_broke="http://v8-juice.googlecode.com/files/libv8-convert-20120219.tar.gz" \
   url_works="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/v8-juice/libv8-convert-20120219.tar.gz" \
   sed -i.$tsGD -e "1s/$/ -e/;s,$url_broke,$url_works,;/^if .*$nodeVerOld/,/^fi/s/^/##/" ./getDependencies.sh' \
   $BUILDDIR/novaInstallHelper.sh

   # these happen inside ${BUILDDIR}/Nova/Quasar/getDependencies.sh
   # git clone git://github.com/DataSoft/Honeyd.git
   # git clone git://github.com/DataSoft/Nova.git
   export HONEYD_SOURCE=$BUILDDIR/Honeyd
   export NOVA_SOURCE=$BUILDDIR/Nova

   bash novaInstallHelper.sh

   # end of install
 ) 2>&1 | tee /var/tmp/novaInstall.$(date +%Y%m%d.%H%M%S).log
