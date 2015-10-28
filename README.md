# UbuntuDjangoAutomationScript #
Script to bootstrap a django application into 14.04.3

Overview
  1. Installs packages with apt-get
  2. creates a virtual environment for python and downloads python packages
  3. configure the django application
  4. configure nginx for proxy with uwsgi
  5. update iptables

##Usage
    ./build.sh

##packages
  1. git
  2. python
  3. nginx
  4. django
  5. ssh

##Stopping the WSGI Process
By default the build script will start up the WSGI process.. If you need to make changes and restart you can kill the process like this:

	uwsgi --stop /tmp/project-master.pid

at this point you can just continue to use the build script to start the process again
