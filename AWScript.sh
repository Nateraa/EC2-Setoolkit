#!/bin/bash

function _spinner() {

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            let column=$(tput cols)-${#2}-8
            echo -ne ${2}
            printf "%${column}s"
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)

            kill $3 > /dev/null 2>&1

            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

# SCRIPT DE INSTALACIÓN

echo "    ___        ______                _       _   "
echo "   / \ \      / / ___| ___  ___ _ __(_)_ __ | |_ "
echo "  / _ \ \ /\ / /\___ \/ __|/ __| '__| | '_ \| __|"
echo " / ___ \ V  V /  ___) \__ \ (__| |  | | |_) | |_ "
echo "/_/   \_\_/\_/  |____/|___/\___|_|  |_| .__/ \__|"
echo "                                      |_|        "
echo "   By Puenteuropa"
echo ""
start_spinner '--| [STEP 1] - Updating System |--'
apt update -y &>/dev/null
stop_spinner $?

start_spinner '--| [STEP 2] - Updating |--'
apt install git python pip -y &>/dev/null
stop_spinner $?

start_spinner '--| [STEP 3] - Downloading Setoolkit |--'
git clone https://github.com/trustedsec/social-engineer-toolkit &>/dev/null
cd social-engineer-toolkit/ &>/dev/null
stop_spinner $?

start_spinner '--| [STEP 4] - Installing necessary dependencies (1/3) |--'
pip3 install -r requirements.txt &>/dev/null
stop_spinner $?

start_spinner '--| [STEP 5] - Installing necessary dependencies (2/3) |--'
python3 setup.py &>/dev/null
stop_spinner $?

start_spinner '--| [STEP 6] - Installing necessary dependencies (3/3) |--'
pip3 install -r requirements.txt &>/dev/null
stop_spinner $?

setoolkit
