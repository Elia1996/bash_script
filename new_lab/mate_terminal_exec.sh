#!/bin/bash

ps -aux | grep ^lp19.10.*pts.*bash$ > file.txt
mate-terminal &
sleep 1
ps -aux | grep ^lp19.10.*pts.*bash$ > file2.txt
diff file.txt file2.txt
rm file.txt
rm file2.txt
