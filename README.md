# yt-cli
A Bash script for watching/listening to YouTube.
Search for a video, Choose the quality, And You are ready to go.

> Forked from [ThatOneCalculator/YouTube-CLI-Scripts](https://github.com/ThatOneCalculator/YouTube-CLI-Scripts).

## Requirements:
- bash
- [mpv](https://github.com/mpv-player/mpv)
- [youtube dl](https://github.com/ytdl-org/youtube-dl)
- [fzf](https://github.com/junegunn/fzf)
- (optional) [rofi](https://github.com/davatorium/rofi)
- (optional) [dmenu](https://dwm.suckless.org/)

## Help:
```
Usage: yt-cli [OPTION...] [COMMAND]...
Options:
  -u="url", --url="url"  Uses this url
  -d, --download         Download the video
  -r, --rofi	 	 Takes input and prompts using rofi
  -m, --dmenu	 	 Takes input and prompts using dmenu
Commands:
  -h, --help             Displays this help and exists
  -v, --version          Displays output version and exists
```
## Install

```bash
git clone https://github.com/BishrGhalil/yt-cli.git
cd yt-cli
sudo make
```

## Uninstall
```bash
sudo make uninstall
```
