sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

#First install out itps to apt-get
apt-get -y install ssh git python-pip nginx python-dev libpq-dev

SRC="git@github.com:rhigdon/UbuntuDjangoAutomationScript.git"
REPOSRC="git://github.com/kirpit/django-sample-app.git"

#check to see if we have our sandbox to play in
SANDBOX_DIR=/sandbox/
if [ ! -d $SANDBOX_DIR ]
then
    sudo mkdir /sandbox/
    sudo chmod 777 /sandbox/
fi

#check to see if we have a copy of the django repo.. of not go get it
LOCALREPO_VC_DIR=/sandbox/django-sample-app
if [ ! -d $LOCALREPO_VC_DIR ]
then
    git clone $REPOSRC $LOCALREPO_VC_DIR
fi

#check if python virtual environment exists.. otherwise create it
ENV_DIR=environment
if [ ! -d $ENV_DIR ]
then
    curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-12.0.7.tar.gz
    tar xvfz virtualenv-12.0.7.tar.gz
    python virtualenv-12.0.7/virtualenv.py environment
    rm virtualenv-12.0.7.tar.gz
    rm -rf virtualenv-12.0.7/
fi

source environment/bin/activate
pip install -r /sandbox/django-sample-app/requirements.txt

#Our sample app has a default template we need to replace
#this is something that could be done with puppet/chef
find /sandbox/django-sample-app/ -type f -exec sed -i 's/{{ project_name }}/projectname/g' {} +
find /sandbox/django-sample-app/ -type f -exec sed -i 's/django.db.backends.postgresql_psycopg2/django.db.backends.sqlite3/g' {} +
find /sandbox/django-sample-app/ -type f -exec sed -i 's/ALLOWED_HOSTS = (/ALLOWED_HOSTS =  ("*"/g' {} +

python /sandbox/django-sample-app/projectname/manage.py migrate
python /sandbox/django-sample-app/projectname/manage.py compress --force

#now configure proxy for nginx
sudo cp nginx.conf /etc/nginx/sites-enabled/default
sudo cp myssl.crt /etc/ssl/certs/myssl.crt
sudo cp myssl.key /etc/ssl/private/myssl.key

sudo cp uwsgi_params /sandbox/

pip install uwsgi
environment/bin/uwsgi --ini projectname.ini --socket :8002 > /dev/null 2>&1 &

#####Begin IP Tables Rules#######
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

sudo service nginx restart

sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# lets accept for 80 443
sudo iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 8000 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p tcp --sport 8000 -m state --state ESTABLISHED -j ACCEPT

# allow 22 ssh for these networks
sudo iptables -A INPUT -i eth0 -p tcp -s 10.0.1.7/10.0.1.255 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -s 192.168.0.0/24 -m tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 -m tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 172.0.0.0/8 -m tcp --dport 22 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# allow 3389 ssh for these networks
sudo iptables -A INPUT -p tcp -s 192.168.0.0/24 -m tcp --dport 3389 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 -m tcp --dport 3389 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 172.0.0.0/8 -m tcp --dport 3389 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -p tcp --sport 3389 -m state --state ESTABLISHED -j ACCEPT
#####End IP Tables Rules #####
