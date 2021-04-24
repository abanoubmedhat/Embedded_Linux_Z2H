#!/bin/sh
#This script is run in the background to continously check for new USB storage media, and mount them.

songsFile=/Songs/songList
removed_flag=0
mounted_flag=0

while :
do

    #Check for mounted media that has been removed. Unmount them and remove the folder
    for medium in `ls /media`; do
        if [ ! -e "/dev/$medium" ]; then
            umount /media/$medium 2> /dev/null
            rm -r /media/$medium
            find /Songs -name '*.mp3' > $songsFile
            find /media -name '*.mp3' >> $songsFile
            removed_flag=1
        fi
    done

    #inform the user that a media has been removed
    if [ $removed_flag -eq 1 ]; then
      songCount=`cat $songsFile | wc -l`
 #     espeak -ven+f5 -s200 "media removed, now you have $songCount songs" --stdout | paplay
      removed_flag=0
    fi


    #Check for unmounted devices. Create media folders and mount
    partitions=`ls /dev/sd*[[:digit:]]` 2> /dev/null
    for partition in $partitions; do
        if [ `df | grep -c $partition` -eq 0 ]; then
            mountpoint="/media/`basename $partition`"
            if [ ! -e "$mountpoint" ]; then
                mkdir $mountpoint
            fi
            mount $partition $mountpoint 2> /dev/null
            find "$mountpoint" -name '*.mp3' >> $songsFile
            mounted_flag=1
        fi
    done

    #inform the user that a media has been inserted
    if [ $mounted_flag -eq 1 ]; then
      songCount=`cat $songsFile | wc -l`                                                                        
      espeak -ven+f5 -s200 "media mounted, now you have $songCount songs" --stdout | paplay
      mounted_flag=0
    fi

done
