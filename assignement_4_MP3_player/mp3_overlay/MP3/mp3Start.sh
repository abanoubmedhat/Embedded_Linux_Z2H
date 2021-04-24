#!/bin/sh

#Flags to be used for execution of certain actions :D
songsFile=/Songs/songList
songNum=`cat /tmp/songNum`
mp3_state=`cat /tmp/mp3_state`
start_flag=`cat /tmp/start_flag`
stop_on_next_click=`cat /tmp/stop_on_next_click` 
next_flag=`cat /tmp/next_flag`
prev_flag=`cat /tmp/prev_flag`
restart_flag=`cat /tmp/restart_flag`
pause_flag=`cat /tmp/pause_flag`
shuf_flag=`cat /tmp/shuf_flag`
prevButtonPressed=`cat /tmp/prevButtonPressed`
prevTimeCount=`cat /tmp/prevTimeCount`

#Reading Buttons, changing flag values based on button press
if [ $(cat /sys/class/gpio/gpio2/value) -eq 0 ]; then
    if [ $stop_on_next_click -eq 1 ]; then
        pause_flag=1
        stop_on_next_click=0 
    elif [ $start_flag -eq 0 ]; then
        start_flag=1
        stop_on_next_click=1
    fi
elif [ $(cat /sys/class/gpio/gpio3/value) -eq 0 ]; then
    next_flag=1
elif [ $(cat /sys/class/gpio/gpio4/value) -eq 0 ]; then
    if [ $prevButtonPressed -eq 0 ]; then
        prevButtonPressed=1
    elif [ $prevTimeCount -lt 8 ]; then
        prevButtonPressed=0
        prevTimeCount=0
        prev_flag=1
    fi
    while [ $(cat /sys/class/gpio/gpio4/value) -eq 0 ]; do
        :
    done
elif [ $(cat /sys/class/gpio/gpio17/value) -eq 0 ]; then
    shuf_flag=1
fi

if [ $prevButtonPressed -eq 1 ]; then                
    prevTimeCount=$((prevTimeCount+1))
    if [ $prevTimeCount -ge 8 ]; then
        prevButtonPressed=0                              
        prevTimeCount=0                                
        restart_flag=1 
    fi  
fi

#Performing Actions based on current raised flag
songName=`cat $songsFile | sed -n "$songNum"p`

if [ $start_flag -eq 1 ]; then
    start_flag=0
    processFound=`pidof play | wc -w`
    if [ $processFound -eq 1 ]; then
        killall -CONT play 
    else
        play -q $songName & 
    fi
    mp3_state="NOW PLAYING:   `basename $songName`" 
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1`
    echo '1' > /tmp/clear_flag

elif [ $pause_flag -eq 1 ]; then
    pause_flag=0
    killall -STOP play
    mp3_state="MP3 Paused!"
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1` 
    echo '1' > /tmp/clear_flag

elif [ $restart_flag -eq 1 ]; then
    restart_flag=0
    killall play
    play -q $songName & 
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1`
    echo '1' > /tmp/clear_flag

elif [ $next_flag -eq 1 ]; then
    next_flag=0
    if [ $songNum -lt `cat $songsFile | wc -l` ]; then   
        songNum=$((songNum+1))                             
    else                                                 
        songNum=1                                          
    fi             
    songName=`cat $songsFile | sed -n "$songNum"p` 
    killall play 2> /dev/null
    mp3_state="NOW PLAYING:   `basename $songName`"  
    play -q $songName & 
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1`
    echo '1' > /tmp/clear_flag

elif [ $prev_flag -eq 1 ]; then
    prev_flag=0
    if [ $songNum -gt 1 ]; then    
	if [ $songNum -le `cat $songsFile | wc -l`]; then                
        	songNum=$((songNum-1))
	else
		songNum=`cat $songsFile | wc -l`   
	fi                       
    else                                            
        songNum=`cat $songsFile | wc -l`               
    fi      
    songName=`cat $songsFile | sed -n "$songNum"p` 
    killall play 2> /dev/null
    mp3_state="NOW PLAYING:   `basename $songName`" 
    play -q $songName &
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1`
    echo '1' > /tmp/clear_flag

elif [ $shuf_flag -eq 1 ]; then
    shuf_flag=0
    songCount=`cat $songsFile | wc -l`
    songNum=$((1+RANDOM%songCount))
    songName=`cat $songsFile | sed -n "$songNum"p` 
    killall play 2> /dev/null
    mp3_state="NOW PLAYING:   `basename $songName`" 
    play -q $songName &
    kill -9 `ps x | grep readInputs | awk '{print $1}' | head -1`
    echo '1' > /tmp/clear_flag
fi

#Update flag status
echo $start_flag > /tmp/start_flag                        
echo $stop_on_next_click > /tmp/stop_on_next_click        
echo $next_flag > /tmp/next_flag                          
echo $prev_flag > /tmp/prev_flag        
echo $restart_flag > /tmp/restart_flag
echo $pause_flag > /tmp/pause_flag
echo $shuf_flag > /tmp/shuf_flag
echo $prevButtonPressed > /tmp/prevButtonPressed          
echo $prevTimeCount > /tmp/prevTimeCount
echo $songNum > /tmp/songNum
echo $mp3_state > /tmp/mp3_state

exit 0
