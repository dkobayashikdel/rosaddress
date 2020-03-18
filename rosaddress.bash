#!/bin/bash
function _func_rosserver() {
    if [ -z "$ip_addr" ]; then
        echo "No Ethernet connection..."
    else
        echo "There are Ethernet connection"
        export ROS_MASTER_URI=http://${ip_addr}:11311
        export ROS_HOST_NAME=${ip_addr}
        export ROS_IP=${ip_addr}
        export PS1BACKUP=${PS1}
        export PS1="\[\033[41;1;33m\][ROS Server]\[\033[0m\] ${PS1BACKUP}"
    fi
    env | grep "ROS_MASTER_URI"
    env | grep "ROS_HOST_NAME"
    env | grep "ROS_IP"
}

function _func_rosclient() {
    if [ -z "$1" ]; then
        echo $1
        echo "Input the ROS server's IP address.'"
    else
        if [ -z "$ip_addr" ]; then
            echo "No Ethernet connection..."
        else
            echo "There are Ethernet connection"
            export ROS_MASTER_URI=http://$1:11311
            export GAZEBO_MASTER_URI=http://$2:11345
            export ROS_HOST_NAME=${ip_addr}
            export ROS_IP=${ip_addr}
            export PS1BACKUP=${PS1}
            export PS1="\[\033[41;1;33m\][ROS Client]\[\033[0m\] ${PS1BACKUP}"
        fi
        env | grep "ROS_MASTER_URI"
        env | grep "GAZEBO_MASTER_URI"
        env | grep "ROS_HOST_NAME"
        env | grep "ROS_IP"
    fi
}

function _func_roslocal() {
    export ROS_MASTER_URI=http://localhost:11311
    unset ROS_HOST_NAME
    unset ROS_IP
    export PS1BACKUP=${PS1}
    export PS1="\[\033[41;1;33m\][ROS Local]\[\033[0m\] ${PS1BACKUP}"
    env | grep "ROS_MASTER_URI"
    env | grep "GAZEBO_MASTER_URI"
    env | grep "ROS_HOST_NAME"
    env | grep "ROS_IP"
}

function _func_rosexit(){
    export ROS_MASTER_URI=http://localhost:11311
    unset ROS_HOST_NAME
    unset ROS_IP
    export PS1=${PS1BACKUP}
    unset PS1BACKUP
}

function _func_comp_rosaddress(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "server client local exit" -- $cur) )
    fi
}


function _func_rosaddress() {
    if [[ $1 = "local" ]]; then
        _func_roslocal
    elif [[ $1 = "server" ]]; then
        _func_rosserver $2
    elif [[ $1 = "client" ]]; then
        _func_rosclient $2 $3
    elif [[ $1 = "exit" ]]; then
        _func_rosexit
    fi
}

# _func_rosaddress $1 $2 $3

function _func_comp_rosaddress(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "server client local exit" -- $cur) )
    fi
    if [ "$prev" = "server" -o "$prev" = "client" ]; then
        COMPREPLY=( $(compgen -W "$(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}' | tr '\n' ' ')" -- $cur) )
    fi
}

alias rosaddress=_func_rosaddress
complete -o default -F _func_comp_rosaddress rosaddress
