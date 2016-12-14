#!/usr/bin/env bash
#	Project Bluebox
#
#	Copyright (C) <2015> <University of Stuttgart>
#
#	This software may be modified and distributed under the terms
#	of the MIT license.  See the LICENSE file for details.


echo ">>>>>>MCM deploy>>>>>>>> preparing environment"
cd
cp mcm-deployEnvironment/linux-conf/.* .
source .profile
sudo apt update
sudo apt dist-upgrade
sudo apt install -y npm nodejs-legacy screen python3-pip git daemontools libpq-dev librdkafka1
pip3 install virtualenv
npm install yarn


echo ">>>>>>MCM deploy>>>>>>>> deploying SDOS"
git clone https://github.com/timwaizenegger/mcm-sdos.git
cd mcm-sdos/
virtualenv venvSDOS
. setenv.sh
pip install -r requirements.txt
cp mcm/sdos/configuration.example.py mcm/sdos/configuration.py
deactivate

echo ">>>>>>MCM deploy>>>>>>>> deploying Bluebox"
cd
git clone https://github.com/timwaizenegger/mcm-bluebox.git
cd mcm-bluebox/
virtualenv venvBB
. setenv.sh
pip install -r requirements.txt
cd mcm/Bluebox/angular
yarn install
cd ../../../
cp mcm/Bluebox/appConfig.example.py mcm/Bluebox/appConfig.py
deactivate

echo ">>>>>>MCM deploy>>>>>>>> deploying Nodered"
cd
yarn install node-red-node-sqlite node-red-nodes-cf-sqldb-dashdb node-red-contrib-postgres node-red


echo ">>>>>>MCM deploy>>>>>>>> All done!\  modify the config files in:\n $HOME/mcm-sdos/mcm/sdos/configuration.py\n $HOME/mcm-bluebox/mcm/Bluebox/appConfig.py"