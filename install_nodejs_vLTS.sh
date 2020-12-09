#! /bin/bash
# getting a packaged nodejs LTS version:
# ref: https://github.com/nodesource/distributions/blob/master/README.md
########################################################################

time (
set -x
curl -sL https://deb.nodesource.com/setup_lts.x > node_setup_lts.sh
bash node_setup_lts.sh
nsPkgVer=$(apt-cache show nodejs | awk '/Version: .*nodesource/ {print $2}')
if [[ -n "$nsPkgVer" ]]; then
   apt-get install -y nodejs=$nsPkgVer
else
  echo node LTS version not availble from nodesource,\
  review https://github.com/nodesource/distributions/blob/master/README.md
fi
# end of scriptlet
) 2>&1 | tee /var/tmp/nodejsInstall.$(date +%Y%m%d.%H%M%S).log
