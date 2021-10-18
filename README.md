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

## Usage:
```bash
yt-cli <search-query>
```
#### Options
```
yt-cli [<options>] [<argument> ...]
-h	--help		prints this help message
-u	--url <url>	streams from a url
-r 			prompts using rofi
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
