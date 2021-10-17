#!/bin/bash
# search videos and playlists on youtube and play them in mpv, without an API 
# usage:
# yt					asks for input in stdin, prompts using fzf
# yt -u	<video-url>			stream from a url
# yt search query			takes input from the passed arg, prompts using fzf
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

help_msg="Usage: yt-cli [option]\n \
    -h	--help\tprints this help message\n \
    -u	--url <url>\tstreams from a url\n \
    -r \t\tprompts using rofi\n \
"
# prompt to choose the video quality
video_format(){

	tmp_choice=$(
	    echo -e "$formats" | \
	    $promptcmd | \
	    awk '{ print $1 }' | \
	    sed 's/\.//g'
	)

	case $tmp_choice in
	    0)
		ytdl_id="251";;
	    1)
		ytdl_id="160+251";;
	    2)
		ytdl_id="133+251";;
	    3)
		ytdl_id="134+251";;
	    4)
		ytdl_id="135+251";;
	    5)
		ytdl_id="136+251";;
	    6)
		ytdl_id="137+251";;
	    exit)
		exit 0;;
	esac
}

if [ -z "$*" ]; then 
	echo -n "Search: "
	read -r query
else
	case "$1" in
		-h|--help)
		    echo -e $help_msg
		    exit;;
		-r)
		    query=$(rofi -dmenu -p "Search: ")
		    promptcmd="rofi -dmenu -no-custom -p Video:";;
		-u|--url)
		    if [[ $# < 2 ]]
		    then
			echo "Please enter a valid url"
			echo -e $help_msg
			exit -1
		    fi
		    URL=$2
		    video_format
		    flags="--ytdl-format=$ytdl_id"
		    mpv "$flags" "$URL"
		    exit;;
		*)
		    query="$*";;
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
	video_format
	flags="--ytdl-format=$ytdl_id"

	case $id in
		# 11 digit id = video
		???????????) clear; mpv "$videolink$id" "$flags";;
		# 34 digit id = playlist
		??????????????????????????????????) clear; mpv "$playlink$id" "$flags";;
		"") exit ;;
		*) echo "invalid id - $id" ;;
	esac
done
