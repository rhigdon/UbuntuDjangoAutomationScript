# UbuntuDjangoAutomationScript #
Script to bootstrap a django application into 14.04.3

Overview
  1. Installs packages with sudo apt-get
  2. create a /sandbox/ directory to run the app from (uwsgi doesnt seem to like relative paths?)
  3. create a virtual environment for python and downloads python packages
  4. configure the django application
  5. configure nginx for proxy with uwsgi
  6. update iptables

##Usage
    sudo apt-get install git
    git clone https://github.com/rhigdon/UbuntuDjangoAutomationScript.git
    cd UbuntuAutomationScript
    ./build.sh

##Stopping the WSGI Process
By default the build script will start up the WSGI process.. If you need to make changes and restart you can kill the process like this:

	uwsgi --stop /tmp/project-master.pid

at this point you can just continue to use the build script to start the process again

##TODO
1. Migrate from sqlite3 to Postgres
2. pull down this repo if it doesnt exist (bootstrap script?)
