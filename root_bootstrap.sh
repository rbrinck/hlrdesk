#!/usr/bin/env bash

apt-get update
apt-get install -y postgresql

sudo -u postgres psql postgres

sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'password';"

sudo -u postgres createdb hlrdesk


apt-get install -y git
apt-get install -y make
apt-get install -y redis-server
#sudo -u postgres psql postgres
#apt-get install npm -y

#apt-get install curl -y
#curl https://raw.githubusercontent.com/creationix/nvm/v0.11.1/install.sh | bash
#source ~/.profile
#nvm install v0.11.1
