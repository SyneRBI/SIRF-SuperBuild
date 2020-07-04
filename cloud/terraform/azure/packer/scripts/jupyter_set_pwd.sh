#!/bin/bash
newpasswd=$1;
export HISTIGNORE="expect*";
 
expect -c "
        spawn jupyter notebook password
        expect "?assword:"
        send \"$newpasswd\r\"
        expect "?assword:"
        send \"$newpasswd\r\"
        expect eof"
 
export HISTIGNORE="";
