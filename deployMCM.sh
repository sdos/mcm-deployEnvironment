#!/usr/bin/env bash
#	Project MCM
#
#	Copyright (C) <2015-2017> <University of Stuttgart>
#
#	This software may be modified and distributed under the terms
#	of the MIT license.  See the LICENSE file for details.


echo ">>>>>>MCM deploy>>>>>>>> preparing environment"
cd
cp mcm-deployEnvironment/linux-conf/.* .
source .profile
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt dist-upgrade
sudo apt install -y npm nodejs-legacy screen python3-pip git daemontools libpq-dev librdkafka1 yarn docker.io htop
pip3 install --upgrade pip
pip3 install --user virtualenv
A=$(whoami)
sudo usermod -a -G docker $A


echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> deploying SDOS"
cd
git clone https://github.com/timwaizenegger/mcm-sdos.git
cd mcm-sdos
chmod +x run.sh
virtualenv venvSDOS
. setenv.sh
pip install -r requirements.txt
cp mcm/sdos/configuration.example.py mcm/sdos/configuration.py
deactivate


echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> deploying metadataExtractor"
cd
git clone https://github.com/timwaizenegger/mcm-metadataExtractor.git
cd mcm-metadataExtractor
chmod +x run.sh
virtualenv venvME
. setenv.sh
pip install -r requirements.txt
cp mcm/metadataExtractor/configuration.example.py mcm/metadataExtractor/configuration.py
deactivate


echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> deploying Bluebox"
cd
git clone https://github.com/timwaizenegger/mcm-bluebox.git
cd mcm-bluebox
chmod +x run.sh
virtualenv venvBB
. setenv.sh
pip install -r requirements.txt
cd mcm/Bluebox/angular
yarn install
cd ../../../
cp mcm/Bluebox/configuration.example.py mcm/Bluebox/configuration.py
deactivate


echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> deploying Nodered"
cd
yarn add node-red-node-sqlite node-red-contrib-postgres node-red


echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> deploying docker containers"
cd
sudo docker run -d --name mcm_warehouse -p 5432:5432 --env POSTGRES_PASSWORD=testing postgres
sudo docker run -d --name mcm_kafka -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST="localhost" --env ADVERTISED_PORT=9092 spotify/kafka




echo
echo
echo
echo ">>>>>>MCM deploy>>>>>>>> All done! configure the Swift backend in: $HOME/mcm-sdos/mcm/sdos/configuration.py"
echo ">>>>>>MCM deploy>>>>>>>> All done! then set the tenant-ID in: $HOME/mcm-metadataExtractor/mcm/metadataExtractor/configuration.py"
echo ">>>>>>MCM deploy>>>>>>>> Then start the services"
echo ">>>>>>MCM deploy>>>>>>>> SDOS: cd mcm-sdos; ./run.sh"
echo ">>>>>>MCM deploy>>>>>>>> Bluebox: cd mcm-bluebox; ./run.sh"
echo ">>>>>>MCM deploy>>>>>>>> Metadata Extractor: cd mcm-bluebox; ./run.sh"
echo ">>>>>>MCM deploy>>>>>>>> Nodered: cd mcm-deployEnvironment/nodered-runner; supervise ."
echo '>>>>>>MCM deploy>>>>>>>> Kafka: docker run -d --name mcm_broker -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST="localhost" --env ADVERTISED_PORT=9092 <ID>'
echo '>>>>>>MCM deploy>>>>>>>> Kafka: docker run -d --name mcm_warehouse -e POSTGRES_PASSWORD=testing -p 5432:5432 postgres'
