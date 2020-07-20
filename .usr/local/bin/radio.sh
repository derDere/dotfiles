echo -en "\033]0;Radio\a"
(mplayer $* > /dev/null 2>&1) | vis
