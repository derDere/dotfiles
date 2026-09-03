#########################################################################


# DotFile Management
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"

function dotfiles-setup() {
  rm $HOME/.bashrc
  git clone --bare https://github.com/derDere/dotfiles.git $HOME/.dotfiles.git
  dotfiles checkout
  dotfiles config --local status.showUntrackedFiles no
}


# Aliases
alias em="emacs"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias mp5="mp-5"
alias cls="clear"
alias l="ls"
alias ccp="create-project"
alias py="python3"
alias rcd="rangercd"


# check if we're running on linux sub system for windows
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    alias docker="docker.exe"
    alias node="node.exe"
    export DISPLAY=:0
fi


# Add Org Dir Env
export org=$HOME/Org


# Add this to your PATH if it’s not already declared
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.usr/local/bin"


# Create New Project
function create-project() {
	$(if [ -n "$TMUX" ]; then; echo "tmux popup -E"; else; echo "sh -c"; fi;) "sh $HOME/.dot-notes/create-project.sh $1 $2 $3"
	if test -f "$HOME/.dot-notes/create-project-templates/.last"; then
		LAST=$(cat "$HOME/.dot-notes/create-project-templates/.last")
		rm -f "$HOME/.dot-notes/create-project-templates/.last"
		cd $LAST
	fi
}


# Handy functions
function measure-speed() {
  date +%D\ %T:%N
  $*
  date +%D\ %T:%N
}


# remove ls background colors
eval "$(dircolors -p | \
    sed 's/ 4[0-9];/ 01;/; s/;4[0-9];/;01;/g; s/;4[0-9] /;01 /' | \
    dircolors /dev/stdin)"


# cd using ranger
function rangercd() {
    TMP_FILE_OUT=$(mktemp)
    ranger --show-only-dirs --choosedir="$TMP_FILE_OUT"
    if [ "$?" -eq "0" ]; then
        TARGET_PATH=$(cat "$TMP_FILE_OUT")
        rm -f "$TMP_FILE_OUT"
        cd "$TARGET_PATH"
    else
        echo Error
    fi
}


# tux fortune
function fortune-tux() {
	fortune | cowsay -n -f tux | center.sh | lolcat
}


# load private data from unmanaged file
source "$HOME/.private-env/exports.sh"


#enable true color support
export COLORTERM=truecolor
export CLAUDE_CODE_TMUX_TRUECOLOR=1
