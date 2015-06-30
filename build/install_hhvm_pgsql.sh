#!/usr/bin/env bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "$DIR"

if [[ "$(php --version)" == HipHop* ]] ; then
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