#!/bin/bash
# search videos and playlists on youtube and play them in mpv, without an API 
# usage:
# yt					asks for input in stdin, prompts using fzf
# yt search query		takes input from the passed arg, prompts using fzf
# yt -r					takes input and prompts using rofi

promptcmd="fzf --with-nth=2..-1"
formats="0. audio only\n \
1. 144px\n \
2. 240px\n \
3. 360px\n \
4. 480px\n \
5. 720px\n \
6. 1080px\n \
exit"

if [ -z "$*" ]; then 
	echo -n "Search: "
	read -r query
else
	case "$1" in
		-r) query=$(rofi -dmenu -p "Search: ")
			promptcmd="rofi -dmenu -no-custom -p Video:";;
		*) query="$*";;
	esac
fi
if [ -z "$query" ]; then exit; fi 
# sanitise the query
query=$(sed \
	-e 's|+|%2B|g'\
	-e 's|#|%23|g'\
	-e 's|&|%26|g'\
	-e 's| |+|g'\
	<<< "$query")
# fetch the results with the $query 
response=$(curl -s "https://www.youtube.com/results?search_query=$query")
vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
pgrep='"playlistRenderer":{"playlistId":"\K.{34}?","title":{"simpleText":".+?[^\"](?=")'
# grep the video id and title
# replace " with “ so that entire title is displayed even if it has "
videoids=$(
	echo "$response" | \
	grep -oP "$vgrep" | \
	sed 's|\\\"|“|g' | \
	awk -F\" '{ print $1 "\t\t\t\t" $NF}'
)
# grep the playlist id and title
# replace " with “ so that entire title is displayed even if it has "
playlistids=$(
	echo "$response" | \
	grep -oP "$pgrep" | \
	sed 's|\\\"|“|g' | \
	awk -F\" '{ print $1 "\t(playlist) " $NF }'
)
# if there are playlists, append them to list
[ -n "$playlistids" ] && ids="$playlistids\n"
# if there are videos, append them to list
[ -n "$videoids" ] && ids="$ids$videoids"
# url prefix for videos and playlists
videolink="https://youtu.be/"
playlink="https://youtube.com/playlist?list="
# prompt the results to user infinitely until they exit (escape)
while true; do
	id=$(
		echo -e "$ids" | \
		$promptcmd | \
		cut -d'	' -f1
	)
	# Video quality
	video_quality=$(
	    echo -e "$formats" | \
	    fzf | \
	    awk '{ print $1 }' | \
	    sed 's/\.//g'
	)

	case $video_quality in
	    0)
		video_quality=251;;
	    1)
		video_quality=160+251;;
	    2)
		video_quality=133+251;;
	    3)
		video_quality=134+251;;
	    4)
		video_quality=135+251;;
	    5)
		video_quality=136+251;;
	    6)
		video_quality=137+251;;
	    exit)
		break
		exit 0;;
	esac

	flags="--ytdl-format=$video_quality"

	case $id in
		# 11 digit id = video
		???????????) clear; mpv "$videolink$id" "$flags";;
		# 34 digit id = playlist
		??????????????????????????????????) clear; mpv "$playlink$id" "$flags";;
		"") exit ;;
		*) echo "invalid id - $id" ;;
	esac
done
