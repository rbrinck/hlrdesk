#!/usr/bin/env bash

cp /vagrant/vagrant_pam_environment ~/.pam_environment

cd /home/vagrant

# Installing nvm
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh

# This enables NVM without a logout/login
export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Install a node and alias
nvm install 4.1.2
nvm alias default 4.1.2

# You can also install other stuff here
#npm install -g bower ember-cli

cd /vagrant
npm install -no-bin-link

npm start
