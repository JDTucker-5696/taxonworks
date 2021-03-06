#!/bin/bash
set -e
set -x
apt-get update
apt-get build-dep -y libmagickcore-dev
cd /usr/src/
[ ! -d libheif-* ] && curl -sL $(curl -s https://api.github.com/repos/strukturag/libheif/releases/latest | jq --raw-output '.assets[0] | .browser_download_url') | tar xzf -
[ ! -d libde265-* ] && curl -sL $(curl -s https://api.github.com/repos/strukturag/libde265/releases/latest | jq --raw-output '.assets[0] | .browser_download_url') | tar xzf -
[ ! -d ImageMagick-7* ] && curl -sL https://www.imagemagick.org/download/ImageMagick.tar.gz | tar xzf -
cd libde265-*
./autogen.sh
./configure
make -j${MAKE_JOBS-3}
make install
cd ../libheif-*
./autogen.sh
./configure
make -j${MAKE_JOBS-3}
make install
cd ../ImageMagick-7*
./configure --with-modules=yes
make -j${MAKE_JOBS-3}
make install
ldconfig
