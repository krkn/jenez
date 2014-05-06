#!/bin/bash
#
# Vagrant Provisionner
#
# @author   Akarun for KRKN <akarun@krkn.be>
# @since    August 2013
#
# =============================================================================
START_TIME=$SECONDS

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

# Update
echo -en "${SEP}System Update"
apt-get -yq update >/dev/null 2>&1 && 
#apt-get -yq upgrade >/dev/null 2>&1 &&
echo_success || process_end 1 "Unable to update the system"

# Sharing fix
echo "SELINUX=disabled" >> /etc/selinux/config

# Tools
echo -en "${SEP}Install Tools\n"

# ... Does'nt work
# echo -en "Apt"
# apt-get install -yq software-properties-common >/dev/null 2>&1 && echo_success || echo_warning

echo -en "\tVim"
test $(which vim) && echo_exists || ( apt-get install -yq vim >/dev/null 2>&1 && echo_success || echo_failure )

# echo -en "\tNano"
# test $(which nano) && echo_exists || ( apt-get install -yq nano >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\tApg"
test $(which apg) && echo_exists || ( apt-get install -yq apg >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\tZip"
test $(which zip) && echo_exists || ( apt-get install -yq zip unzip >/dev/null 2>&1 && echo_success || echo_failure )

echo -en "\tGit" 
test $(which git) && echo_exists || ( apt-get install -yq git >/dev/null 2>&1 && echo_success || echo_failure )

# echo -en "\tCurl"
# test $(which curl) && echo_exists || ( apt-get install -yq curl >/dev/null 2>&1 && echo_success || echo_failure )

# echo -en "\tBZip2"
# test $(which bzip2) && echo_exists || ( apt-get install -yq bzip2 >/dev/null 2>&1 && echo_success || echo_failure )

# -----------------------------------------------------------------------------

# Prompt and aliases
echo -en "\nPrompt and aliases"

grep -q 'alias duh' /root/.bashrc || tee -a /root/.bashrc >/dev/null <<EOF
# Prompt
export PS1="\n\[\033[1;34m\][\u@\h \#|\W]\n\[$(tput bold)\]↪\[\033[0m\] "
# Use colors
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l='clear; ls -la'
alias duh='du -hs'
alias tree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"
alias wget="wget -c"
EOF

cp -f /root/.bashrc /home/vagrant/ && chown vagrant: /home/vagrant/.bashrc
echo_exists

# VIM Config.
echo -en "\nVim config"

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

# -----------------------------------------------------------------------------

# Avahi (in case of...)
echo -en "\nInstall Avahi Deamon"

apt-get install -qy avahi-daemon >/dev/null 2>&1 &&
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

/etc/init.d/avahi-daemon restart > /dev/null 2>&1 && echo_success || echo_failure

# -----------------------------------------------------------------------------

# Mongo DB
echo -en "\nInstall MongoDB"

if [[ -z $(which mongo) ]]; then
    apt-key adv -q --keyserver keyserver.ubuntu.com --recv 7F0CEB10 >/dev/null 2>&1 &&
    echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee -a /etc/apt/sources.list.d/mongodb.list >/dev/null &&
    apt-get -yq update >/dev/null 2>&1 && 
    apt-get install -qy mongodb-org >/dev/null 2>&1
    
    if [[ -z $(which mongo) ]]; then 
        echo_failure
    else
        /etc/init.d/mongod start && 
        mongo admin --eval "db.createUser( { user: \"admin\", pwd: \"admin\", roles: [ \"userAdmin\" ] } )" &&
        echo_success || echo_warning
    fi
else
    echo_exists
fi

# -----------------------------------------------------------------------------

# Redis
echo -en "\nInstall Redis"

if [[ -z $(which redis-cli) ]]; then
    apt-get install -qy redis-server >/dev/null 2>&1

    if [[ -z $(which redis-cli) ]]; then
        process_end 1 "Unable to install Redis"
    else
        [[ $(redis-cli ping) != "PONG" ]] && echo_warning || echo_success
    fi
else
    echo_exists
fi

process_end

# -----------------------------------------------------------------------------

# Node
echo -en "\nInstall Node"

add-apt-repository ppa:chris-lea/node.js >/dev/null &&
apt-get -yq update >/dev/null && apt-get install -qy nodejs >/dev/null

if ( $? ); then 
    process_end 1 "Unable to install Node"
else
    npm install -g n --unsafe-perm
    n stable && echo_success || echo_failure
fi

# NPM Pack
echo -en "\nInstall NPM packages"

npm install -g grunt-cli --unsafe-perm
npm install -g nodemon --unsafe-perm
npm install -g bower --unsafe-perm
npm install -g browserify --unsafe-perm
echo_exists

# -----------------------------------------------------------------------------

# NginX
echo -en "\nInstall NginX"

if [[ -f /etc/nginx/nginx.conf ]]; then
    apt-get install -yq nginx-extra
    sed -i 's/user www-data/user vagrant/' /etc/nginx/nginx.conf

    service nginx restart
    if ( $? ); then 
        process_end 1 "Unable to install NginX"
    else 
        echo_success; 
    fi

    # NginX Config
    echo -en "\tConfiguration"
    #sed -e "/^\"syntax/s/^\"//" -i /etc/nginx/
    echo_success
else
    echo_exists
fi

# NginX VHost
echo -en "\tVHost installation"
if [[ -f /etc/nginx/site-availables/default ]]; then
    if [[ -f ./vhost.skel]]; then 
        mv /etc/nginx/site-availables/default /etc/nginx/site-availables/default.bakup
        cp vhost.skel /etc/nginx/site-availables/default

        #TODO: change vHost parameters

        /etc/init.d/nginx configtest && /etc/init.d/nginx restart &&
        echo_success || echo_failure
    else
        echo_warning ; echo -en "\t\tNo vhost template..."
    fi
else
    echo_exists
fi

# =============================================================================

# Project
echo -en "\nDeploy project sources"
cd /vagrant
rm -rf node_modules
npm install --unsafe-perm

# =============================================================================

# End
process_end
