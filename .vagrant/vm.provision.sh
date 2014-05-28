#!/bin/bash
#
# Vagrant Provisionner
#
# @author   Akarun for KRKN <akarun@krkn.be>
# @since    August 2013
#
# =============================================================================
START_TIME=$SECONDS
PROJECT_NAME=$1
PROJECT_HOST=$2
PROJECT_FILE=$(echo "${PROJECT_NAME,,}" |  sed -e 's/ /_/g')

# =============================================================================
SEP="$(printf '%0.1s' "-"{1..80})\n"
function echo_success { echo -ne "\033[60G\033[0;39m[   \033[1;32mOK\033[0;39m    ]\n\r"; }
function echo_failure { echo -ne "\033[60G\033[0;39m[ \033[1;31mFAILED\033[0;39m  ]\n\r"; }
function echo_warning { echo -ne "\033[60G\033[0;39m[ \033[1;33mWARNING\033[0;39m ]\n\r"; }
function echo_exists  { echo -ne "\033[60G\033[0;39m[   \033[1;34mDONE\033[0;39m  ]\n\r"; }

function process_end {
    if [[ $1 > 0 ]]; then
        echo -en "${SEP}Error $1 : $2" ; echo_failure
    else
        ELAPSED_TIME=$(($SECONDS - $START_TIME))
        echo -en "${SEP}Deploy completed in $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
        echo_success
    fi

    exit 0
}


# =============================================================================

# Update and package list
echo -en "${SEP}\nSystem Update"

apt-key adv -q --keyserver keyserver.ubuntu.com --recv 7F0CEB10 >/dev/null 2>&1
echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' >> /etc/apt/sources.list.d/mongodb.list

apt-get -yq update >/dev/null 2>&1 && #apt-get -yq upgrade >/dev/null 2>&1 &&
echo_success || process_end 1 "Unable to update the system"

# Sharing fix
echo "SELINUX=disabled" >> /etc/selinux/config

# =============================================================================

# Tools
echo -en "Install Tools\n"

echo -en "\t- Vim"
test $(which vim) && echo_exists || ( apt-get install -yq vim >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\t- Apg"
test $(which apg) && echo_exists || ( apt-get install -yq apg >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\t- Zip"
test $(which zip) && echo_exists || ( apt-get install -yq zip unzip >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\t- Git"
test $(which git) && echo_exists || ( apt-get install -yq git >/dev/null 2>&1 && echo_success || echo_failure )

# -----------------------------------------------------------------------------

# Prompt and aliases
echo -en "Prompt and aliases"

grep -q 'alias duh' /root/.bashrc || tee -a /root/.bashrc >/dev/null <<EOF
# Prompt
export PS1="\n\[\033[1;34m\][\u@\h \#|\W]\[\033[0m\]\n\[$(tput bold)\]↪ "
# Use colors
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l='clear; ls -la'
alias duh='du -hs'
alias tree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"
alias wget="wget -c"

cd /vagrant
EOF

cp -f /root/.bashrc /home/vagrant/ && chown vagrant: /home/vagrant/.bashrc
echo_success

# VIM Config.
echo -en "Vim config"

sed -e "/^\"syntax/s/^\"//" -i /etc/vim/vimrc        # Activer la coloration syntaxique
sed -e "/showcmd/s/^\"//" -i /etc/vim/vimrc
sed -e "/showmatch/s/^\"//" -i /etc/vim/vimrc        # Show matching brackets.
sed -e "/ignorecase/s/^\"//" -i /etc/vim/vimrc       # Recherche sans tenir compte de la casse
sed -e "/smartcase/s/^\"//" -i /etc/vim/vimrc        # Do smart case matching

tee -a /etc/vim/vimrc >/dev/null <<EOF
set tabstop=4
set viminfo=\'20,\"50
set history=50
set ruler
EOF
echo_success

# =============================================================================

# Avahi (in case of...)
echo -en "Install Avahi Deamon\t"

apt-get install -y avahi-daemon >/dev/null 2>&1 &&
update-rc.d avahi-daemon defaults >/dev/null 2>&1 &&

tee -a /etc/avahi/services/afpd.service >/dev/null <<EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
    <name replace-wildcards="yes">%h</name>
    <service>
        <type>_afpovertcp._tcp</type>
        <port>548</port>
    </service>
</service-group>
EOF

/etc/init.d/avahi-daemon restart >/dev/null 2>&1 &&
echo_success || echo_failure

# -----------------------------------------------------------------------------

# Mongo DB
echo -en "Install MongoDB\t"

if [[ -z $(which mongo) ]]; then
    apt-get install -qq mongodb-org >/dev/null 2>&1

    if [[ -z $(which mongo) ]]; then
        echo_failure
    else
        #/etc/init.d/mongod start  &&
        mongo admin --eval "db.createUser( { user: \"admin\", pwd: \"admin\", roles: [ \"userAdmin\" ] } )" >/dev/null &&
        echo_success || echo_warning
    fi
else
    echo_exists
fi

# -----------------------------------------------------------------------------

# Redis
echo -en "Install Redis\t"

if [[ -z $(which redis-cli) ]]; then
    apt-get install -qq redis-server >/dev/null 2>&1

    if [[ -z $(which redis-cli) ]]; then
        process_end 1 "Unable to install Redis"
    else
        [[ $(redis-cli ping) != "PONG" ]] && echo_warning || echo_success
    fi
else
    echo_exists
fi

# -----------------------------------------------------------------------------

# Node
echo -en "Install NodeJS\t"

if [[ -z $(which node) ]]; then
    apt-get -yqq install python-software-properties >/dev/null 2>&1 &&
    add-apt-repository -y ppa:chris-lea/node.js >/dev/null 2>&1 &&
    sed -e "s/wheezy/lucid/g" -i /etc/apt/sources.list.d/chris-lea-node_js-wheezy.list &&
    apt-get -y update >/dev/null 2>&1 &&
    apt-get install -yqq nodejs >/dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        process_end 1 "Unable to install Node"
    else
        npm install -g n --unsafe-perm >/dev/null 2>&1 &&
        n stable >/dev/null 2>&1 &&
        echo_success || echo_failure

        # NPM Pack
        echo -en "Install NPM packages\n"

        echo -en "\t- grunt-cli\t"
        npm install -g grunt-cli --unsafe-perm >/dev/null 2>&1 && echo_success || echo_failure

        echo -en "\t- nodemon\t"
        npm install -g nodemon --unsafe-perm >/dev/null 2>&1 && echo_success || echo_failure

        echo -en "\t- bower\t"
        npm install -g bower --unsafe-perm >/dev/null 2>&1 && echo_success || echo_failure

        echo -en "\t- browserify\t"
        npm install -g browserify --unsafe-perm >/dev/null 2>&1 && echo_success || echo_failure
    fi
else
    echo_done
fi

# -----------------------------------------------------------------------------

# NginX
echo -en "Install NginX\t"

if [[ ! -f /etc/nginx/nginx.conf ]]; then
    apt-get install -y nginx-extras >/dev/null 2>&1
    sed -i '/user/s/www-data/vagrant/' /etc/nginx/nginx.conf
    sed -i '/sendfile/s/on/off/' /etc/nginx/nginx.conf
    sed -i -e "/default_type/a\ \n\tclient_max_body_size 400M;" /etc/nginx/nginx.conf

    /etc/init.d/nginx configtest >/dev/null 2>&1 && /etc/init.d/nginx restart >/dev/null 2>&1 &&
    echo_success || process_end 1 "Unable to install of configure NginX"

    # NginX VHost
    echo -en "\tVHost installation"
    pushd /etc/nginx/sites-available/ >/dev/null &&
    mv default default.backup &&

    echo -en "server {
        listen 80;
        server_name localhost ${PROJECT_HOST};
        root /vagrant/;

        charset utf-8;

        gzip                on;
        gzip_http_version   1.1;
        gzip_proxied        expired no-cache no-store private auth;
        gzip_disable        \"MSIE [1-6]\\.\";
        gzip_types          text/plain text/css application/json application/x-javascript text/xml application/xml application/rss+xml text/javascript image/svg+xml application/vnd.ms-fontobject application/x-font-ttf font/opentype;
        gzip_vary           on;
        gzip_min_length     1000;
        gzip_buffers        16 8k;

        location / {
            proxy_pass http://127.0.0.1:53000;
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Host \$http_host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-NginX-Proxy  true;
        }

        location ~* ^.+\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|html|htm|svg|ttf|woff)$ {
            root /vagrant/static;
            add_header X-Powered-By nginx;
        }
    }" > default

    /etc/init.d/nginx configtest >/dev/null 2>&1 && /etc/init.d/nginx restart >/dev/null 2>&1 &&
    echo_success || echo_failure

    popd >/dev/null
else
    echo_exists
fi

# =============================================================================

# Project
echo -en "Deploy project sources"
pushd /vagrant >/dev/null &&
rm -rf node_modules &&
npm install --unsafe-perm >/dev/null 2>&1 &&
echo_success || echo_failure

if [ -n $PROJECT_NAME ]; then
    [ -f package.json ] && sed -e "s/PROJECT_NAME/${PROJECT_NAME}/" -i package.json

    if [ -f jenez.sublime-project ]; then
        sed -e "s/PROJECT_NAME/${PROJECT_NAME}/" -i jenez.sublime-project
        mv jenez.sublime-project "${PROJECT_FILE}.sublime-project"
    fi

    find ./src -type f -name "*.coffee" -print0 | xargs -0 sed -i "s/PROJECT_NAME/${PROJECT_NAME}/"
    find ./static -type f -name "*.styl" -print0 | xargs -0 sed -i "s/PROJECT_NAME/${PROJECT_NAME}/"
fi

# =============================================================================

# End
process_end
