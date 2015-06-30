#!/usr/bin/env bash

# exit on first error
set -e

# get the directory this script is in (build/) and cd to it
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$DIR"

if [[ "$(php --version)" == HipHop* ]] ; then
  # install deps: gcc-4.8, hhvm-dev, libpq, boost, jemalloc, glog
  sudo apt-get install python-software-properties
  sudo add-apt-repository -y ppa:mapnik/boost
  sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
  sudo add-apt-repository -y ppa:boost-latest/ppa
  sudo apt-add-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu precise main'
  echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list
  
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CBCB082A1BB943DB

  sudo apt-get update
  sudo apt-get install gcc-4.8 g++-4.8 hhvm-dev libpq-dev libboost1.55-all-dev libjemalloc-dev
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
  sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50

  # glog needs installed from source
  wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
  tar zxvf glog-0.3.3.tar.gz
  cd glog-0.3.3
  ./configure
  make
  sudo make install
  cd $DIR

  # clone it
  git clone https://github.com/PocketRent/hhvm-pgsql.git
  cd hhvm-pgsql
  # only known working checkout...
  git checkout 3.7.2

  # build it
  hphpize
  cmake .
  make

  # install it
  sudo cp pgsql.so /etc/hhvm/pgsql.so
  sudo sh -c 'echo "extension_dir = /etc/hhvm" >> /etc/hhvm/php.ini'
  sudo sh -c 'echo "hhvm.extensions[pgsql] = pgsql.so" >> /etc/hhvm/php.ini'
fi