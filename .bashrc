# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

function ccppp() {
  printf "SRC = \$(wildcard *.cpp)\nAPP = \"$1\"\n\nAll: \$(APP)\n      #Making\n\n\$(APP): \$(SRC)\n   g++ -o \$(APP) \$(SRC)\n\ntest: \$(APP)\n       ./\$(APP) debug\n" > ./makefile
  printf "#include <iostream>\n\n#define APP \"$1\"\n\nusing namespace std;\n\n/**\n * Project: $1\n * Creator: $USER\n * Creation Date: $(date)\n */\nint main(int argc, char* argv[]) {\n cout << \"Neues Project: \" << APP << endl;\n return 0;\n}\n" > ./main.cpp
  emacs ./main.cpp
}

function measure-speed() {
  date +%D\ %T:%N
  $*
  date +%D\ %T:%N
}

#    30: Black
#    31: Red
#    32: Green
#    33: Yellow
#    34: Blue
#    35: Purple
#    36: Cyan
#    37: White
#------------------------------------
#    0: Normal text
#    1: Bold or light, depending on terminal
#    4: Underline text
#------------------------------------
#    40: Black background
#    41: Red background
#    42: Green background
#    43: Yellow background
#    44: Blue background
#    45: Purple background
#    46: Cyan background
#    47: White background

#if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
#echo > /dev/null
#PS1='
#\[\e[42m\]\[\e[30m\]${debian_chroot:+($debian_chroot)} \u \[\e[32m\]\[\e[47m\] \[\e[37m\]\[\e[30m\]\h \[\e[37m\]\[\e[44m\] \w \[\e[0m\]\[\e[34m\]\[\e[0m\] '
#else
#PS1='\[\e[1;32m\]\[\e[40m\]${debian_chroot:+($debian_chroot)}\u\[\e[32m\]\[\e[40m\]@\[\e[1;34m\]\w\[\e[40m\]\[\e[37m\]$\[\e[0m\]\[\e[30m\]\[\e[0m\]'
#fi


# Add Org Dir Env
export org=$HOME/Org


# Add this to your PATH if it’s not already declared
export PATH=$PATH:$HOME/.local/bin

# Powerline configuration
if [ -f $HOME/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh ]; then
    $HOME/.local/bin/powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    source $HOME/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
fi


# remove ls background colors
eval "$(dircolors -p | \
    sed 's/ 4[0-9];/ 01;/; s/;4[0-9];/;01;/g; s/;4[0-9] /;01 /' | \
    dircolors /dev/stdin)"


# DotFile Management
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"

function dotfiles-setup() {
  rm $HOME/.bashrc
  git clone --bare https://github.com/derDere/dotfiles.git $HOME/.dotfiles.git
  dotfiles checkout
  dotfiles config --local status.showUntrackedFiles no
}

# Aliases
alias em=emacs
alias ll = "ls -l"
alias la = "ls -a"
alias lla = "ls -la"
alias mp5=mp-5

