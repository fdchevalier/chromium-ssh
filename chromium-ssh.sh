#!/bin/bash
# Title: chromium-ssh.sh
# Version: 0.3
# Author: Frédéric CHEVALIER <f15.chevalier@gmail.com>
# Created in: 2015-03-07
# Modified in: 2020-04-27
# Licence : GPL v3



#======#
# Aims #
#======#

aim="Set a SSH tunnel for chromium."



#==========#
# Versions #
#==========#

# v0.3 - 2020-04-27: askpass box when run from GUI / version printed / code cleaning
# v0.2 - 2016-09-08: ssh id option added
# v0.1 - 2015-03-07: http proxy added to work with some chromium version
# v0.0 - 2015-03-07: creation

version=$(grep -i -m 1 "version" "$0" | cut -d ":" -f 2 | sed "s/^ *//g")



#===========#
# Functions #
#===========#

# Usage message
function usage {
    echo -e "
    \e[32m ${0##*/} \e[00m -u|--usr username -s|--svr server -i|--id identity_file -p|--port integer -l|--log path -h|--help

Aim=$aim

Version: $version

Options:
    -u, --usr       user name required to connect the ssh server [default: $USER]
    -s, --svr       address of the ssh server to set the ssh tunnel up
    -i, --id        identity file used for ssh connection (optional)
    -p, --port      local port for ssh tunnel [default: 8080]
    -l, --log       path to the log file [default: /tmp/${0##*/}.log]
    -h, --help      this message
"
}


# For info, warning, and error functions, look at http://stackoverflow.com/a/911213 to see what descriptor to test (0 if it has to be run in graphic mode, 1 if it has to be run in a terminal)

# Info message
function info {
    if [[ -t 0 ]]
    then
        echo -e "\e[32mInfo:\e[00m $1"
    else
        notify-send $myicon -h string:x-canonical-append:allowed "${0##*/} - Info: $1"
    fi
}


# Warning message
function warning {
    if [[ -t 0 ]]
    then
        echo -e "\e[33mWarning:\e[00m $1"
    else
        notify-send $myicon -h string:x-canonical-append:allowed "${0##*/}" "Warning: $1"
    fi
}


# Error message
## usage: error message [exit_code]
## exit code optional
function error {
    if [[ -t 0 ]]
    then
        echo -e "\e[31mError:\e[00m $1"
    else
        notify-send $myicon -h string:x-canonical-append:allowed "${0##*/}" "Error: $1"
    fi

    [[ -n $2 ]] && exit $2
}


# Dependency test
function test_dep {
    [[ ! $(which $1 2> /dev/null) ]] && error "Package $1 is needed. Exiting..." 1
}



#==============#
# Dependencies #
#==============#

test_dep notify-send
test_dep chromium-browser



#===========#
# Variables #
#===========#

# Load variables
while [[ $# -gt 0 ]]
do
    case $1 in
        -u|--usr    ) myuser="$2"   ; shift 2 ;;
        -s|--svr    ) myserver="$2" ; shift 2 ;;
        -i|--id     ) myid="-i $2"  ; shift 2 ;;
        -p|--port   ) myport="$2"   ; shift 2 ;;
        -l|--log    ) mylog="$2"    ; shift 2 ;;
        -h|--help   ) usage ; exit 0 ;;
        *           ) error "Invalid option: $1" 1 ;;
    esac
done


# Icon for notification
if [[ -f "$HOME/.icons/chromium-ssh.png" ]]
then
    myicon="-i $HOME/.icons/chromium-ssh.png"
else
    myicon="-i chromium-browser"
fi


# Check for mendatory options
[[ -z "$myuser" ]] && myuser=$USER
[[ -z "$myserver" ]] && error "Server address missing for ssh connection. Exiting..." 1
myssh_add="$myuser@$myserver"


# Check for existing identity file
[[ -n "$myid" && ! -f $(echo "$myid" | cut -d " " -f 2-) ]] && error "Identity file does not exist. Exiting..." 1


# Set default values if nothing specify
[[ -z "$port" ]] && myport=8080
[[ -z "$log" ]]  && mylog="/tmp/${0##*/}.log"

# Password/phrase in GUI context
if [[  -t 0 ]]
then
    myssh="ssh $myid"
else
    test_dep ssh-askpass
    export SSH_ASKPASS=$(which ssh-askpass)
    myssh="setsid ssh $myid"
fi



#============#
# Processing #
#============#


#-----------------------#
# Set up the SSH tunnel #
#-----------------------#
## source: http://stackoverflow.com/a/15198031

# Info message
date > "$mylog"
mymsg="SSH tunnel initialization..."
info "$mymsg"
echo -e "\n$mymsg\n" >> "$mylog"

# SSH tunnel
$myssh -M -S my-ctrl-socket -C2fnNT -D $myport "$myssh_add" &>> "$mylog"

[[ $? != 0 ]] && error "SSH tunnel cannot be set up. See $mylog." 1

# Check socket
$myssh -S my-ctrl-socket -O check "$myssh_add" &>> "$mylog"

# Environment variables
HTTP_PROXY="http://localhost:$myport"
HTTPS_PROXY="https://localhost:$myport"
SOCKS_SERVER="localhost:$myport"
SOCKS_VERSION=5


#-----------------#
# Start Chromium  #
#-----------------#

# Info message
mymsg="Chromium starting..."
info "$mymsg"
echo -e "\n\n$mymsg\n" >> "$mylog"

# Start Chromium
## source: http://www.chromium.org/developers/design-documents/network-stack/socks-proxy
chromium-browser --proxy-server="socks://localhost:$myport" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" &>> "$mylog"

[[ $? != 0 ]] && error "Chromium closed unexpectedly. See $mylog." 1


#-----------------#
# Close SSH tunel #
#-----------------#

# Info message
mymsg="SSH tunel closing..."
info "$mymsg"
echo -e "\n\n$mymsg\n" >> "$mylog"

# Close SSH unnel
$myssh -S my-ctrl-socket -O exit "$myssh_add" &>> "$mylog"


exit 0
