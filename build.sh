#First install out itps to apt-get
apt-get -y install ssh git python-pip nginx

SRC="git@github.com:rhigdon/UbuntuDjangoAutomationScript.git"
REPOSRC="git://github.com/kirpit/django-sample-app.git"

#check to see if we have a copy of the django repo.. of not go get it
LOCALREPO_VC_DIR=.git
if [ ! -d $LOCALREPO_VC_DIR ]
then
    git clone $REPOSRC 
fi

#check if python virtual environment exists.. otherwise create it
ENV_DIR=environment
if [ ! -d $ENV_DIR ]
then
    curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-12.0.7.tar.gz
    tar xvfz virtualenv-12.0.7.tar.gz
    python virtualenv-12.0.7/virtualenv.py environment
    source environment/bin/activate
    pip install -r django-sample-app/requirements.txt
else
    #If we already have an environment.. activate it
    # and make sure pip is up to date with the latest requirments
    source environment/bin/activate
    pip install -r django-sample-app/requirements.txt
fi

#Our sample app has a default template we need to replace
#this is something that could be done with puppet/chef
find . -type f -exec sed -i 's/{{ project_name }}/projectname/g' {} +

#now configure proxy for nginx
#sudo cp nginx.conf //default
#sudo cp myssl.cert 
#sudo cp myssl.key 

#####Begin IP Tables Rules#######
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

#sudo iptables -P INPUT DROP
#sudo iptables -P OUTPUT DROP
#sudo iptables -P FORWARD DROP

# lets accept for 80 443
#sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#sudo iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
#sudo iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#sudo iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
#sudo iptables -A INPUT -p tcp -m tcp --dport 8000 -j ACCEPT
#sudo iptables -A OUTPUT -o eth0 -p tcp --sport 8000 -m state --state ESTABLISHED -j ACCEPT

# allow 22 ssh for these networks
#sudo iptables -A INPUT -i eth0 -p tcp -s 10.0.1.7/10.0.1.255 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
#sudo iptables -A INPUT -p tcp -s 192.168.0.0/24 -m tcp --dport 22 -j ACCEPT
#sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 -m tcp --dport 22 -j ACCEPT
#sudo iptables -A INPUT -p tcp -s 172.0.0.0/8 -m tcp --dport 22 -j ACCEPT
#sudo iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# allow 3389 ssh for these networks
#sudo iptables -A INPUT -p tcp -s 192.168.0.0/24 -m tcp --dport 3389 -j ACCEPT
#sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 -m tcp --dport 3389 -j ACCEPT
#sudo iptables -A INPUT -p tcp -s 172.0.0.0/8 -m tcp --dport 3389 -j ACCEPT
#sudo iptables -A OUTPUT -o eth0 -p tcp --sport 3389 -m state --state ESTABLISHED -j ACCEPT
#####End IP Tables Rules #####
