#!/bin/sh
#This script continously checks for terminal commands, updates execution flags based on them.

read -p "MP3_shell> " mp3Com

case $mp3Com in
start)
    echo '1' > /tmp/start_flag
    ;;

stop)
    echo '1' > /tmp/pause_flag
    ;;

restart)
    echo '1' > /tmp/restart_flag
    ;;

next)
    echo '1' > /tmp/next_flag
    ;;

prev)
    echo '1' > /tmp/prev_flag
    ;;

shuf)
    echo '1' > /tmp/shuf_flag
    ;;

connect)
    bluetoothctl connect 1C:91:9D:91:BF:E6
    ;;

remove)
    bluetoothctl remove 1C:91:9D:91:BF:E6
    esac

exit 0
