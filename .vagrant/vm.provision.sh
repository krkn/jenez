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
echo -en "${SEP}Updating"
#apt-get -yq update >/dev/null 2>&1 && 
#apt-get -yq upgrade >/dev/null 2>&1 &&
echo_success || process_end 1 "Unable to update the system"

# Sharing fix
echo "SELINUX=disabled" >> /etc/selinux/config

# Tools
echo -en "${SEP}Install Tools"

test $(which vim) || apt-get install -yq vim >/dev/null 2>&1 
test $(which nano) || apt-get install -yq nano >/dev/null 2>&1 
test $(which apg) || apt-get install -yq apg >/dev/null 2>&1 
test $(which zip) || apt-get install -yq zip unzip >/dev/null 2>&1 
test $(which git) || apt-get install -yq git >/dev/null 2>&1 
test $(which curl) || apt-get install -yq curl >/dev/null 2>&1 
test $(which bzip2) || apt-get install -yq bzip2 >/dev/null 2>&1 
echo_exists

# -----------------------------------------------------------------------------

# Prompt and aliases
echo -en "\nPrompt and aliases"

grep -q 'alias duh' /root/.bashrc || tee -a /root/.bashrc <<EOF
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
echo_exists


# -----------------------------------------------------------------------------

# Mongo DB
echo -en "\nInstall Tools"

if [[ -z $(which mongo) ]]; then
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 &&
    echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list &&
    apt-get -yq update >/dev/null 2>&1 && apt-get install -qy mongodb-org >/dev/null 2>&1
    
    if ( $? ); then 
        process_end 1 "Unable to install MongoDB"
    else
        mongo admin --eval "db.addUser( { user: \"admin\", pwd: \"admin\", roles: [ \"userAdmin\" ] } )" &&
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

    if ( $? ); then 
        process_end 1 "Unable to install Redis"
    else
        REDIS_PONG=$(redis-cli ping)

        if [[ $REDIS_PONG != "PONG" ]]; then 
            echo_warning; 
        else 
            echo_success; 
        fi
    fi
else
    echo_exists
fi

# -----------------------------------------------------------------------------

# Node
# echo -en "\nInstall Node"

# add-apt-repository ppa:chris-lea/node.js
# apt-get -yq update && apt-get install -qy nodejs

# if ( $? ); then 
#     process_end 1 "Unable to install Node"
# else
#     npm install -g n --unsafe-perm
#     n stable

#     echo_success
# fi

# NPM Pack
# echo -en "\nInstall NPM packages"

# npm install -g grunt-cli --unsafe-perm
# npm install -g nodemon --unsafe-perm
# npm install -g bower --unsafe-perm
# npm install -g browserify --unsafe-perm

# echo_exists

# -----------------------------------------------------------------------------

# NginX
# echo -en "\nInstall NginX"

# if [ -f /etc/nginx/nginx.conf ]; then
#     apt-get install -yq nginx-extra
#     sed -i 's/user www-data/user vagrant/' /etc/nginx/nginx.conf

#     service nginx restart
#     if ( $? ); then 
#         process_end 1 "Unable to install NginX"
#     else 
#         echo_success; 
#     fi
# else
#     echo_exists
# fi

# VHosts


# =============================================================================

# Avahi (in case of...)
# apt-get install -qy avahi-daemon
# update-rc.d avahi-daemon defaults

# sudo tee -a /etc/avahi/services/afpd.service <<EOF
# <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
# <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
# <service-group>
#     <name replace-wildcards="yes">%h</name>
#     <service>
#         <type>_afpovertcp._tcp</type>
#         <port>548</port>
#     </service>
# </service-group>
# EOF

# /etc/init.d/avahi-daemon restart

# =============================================================================

# Project
# echo -en "\nDeploy project sources"
# cd /vagrant
# rm -rf node_modules
# npm install --unsafe-perm

# =============================================================================

# End
process_end
