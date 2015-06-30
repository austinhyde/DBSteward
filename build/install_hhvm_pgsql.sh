#!/usr/bin/env bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "$DIR"

if [[ "$(php --version)" == HipHop* ]] ; then
  # install deps
  sudo apt-get install python-software-properties
  sudo add-apt-repository -y ppa:mapnik/boost
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
  echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list
  sudo apt-get update
  sudo apt-get install hhvm-dev

  # clone it
  git clone https://github.com/PocketRent/hhvm-pgsql.git
  cd hhvm-pgsql

  # build it
  hphpize
  cmake .
  make

  # install it
  cp pgsql.so /etc/hhvm/pgsql.so
  echo 'extension_dir = /etc/hhvm' >> /etc/hhvm/php.ini
  echo 'hhvm.extensions[pgsql] = pgsql.so' >> /etc/hhvm/php.ini
fi