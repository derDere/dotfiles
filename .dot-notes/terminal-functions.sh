
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


# check if we're running on linux sub system for windows
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    alias docker="docker.exe"
    alias node="node.exe"
fi


# Add Org Dir Env
export org=$HOME/Org


# Add this to your PATH if it’s not already declared
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.usr/local/bin"


# Create C++ Project
function create-project() {
	#printf "SRC = \$(wildcard *.cpp)\nAPP = \"$1\"\n\nAll: \$(APP)\n\t@echo Done\n\n\$(APP): \$(SRC)\n\tg++ -o \$(APP) \$(SRC)\n\ntest: \$(APP)\n\t./\$(APP) debug\n" > ./makefile
	#printf "#include <iostream>\n\n#define APP \"$1\"\n\nusing namespace std;\n\n/**\n * Project: $1\n * Creator: $USER\n * Creation Date: $(date)\n */\nint main(int argc, char* argv[]) {\n\tcout << \"Neues Project: \" << APP << endl;\n\treturn 0;\n}\n" > ./main.cpp
	#editor ./main.cpp
	$(if [ -n "$TMUX" ]; then; echo "tmux popup -E"; else; echo "sh -c"; fi;) "sh $HOME/.dot-notes/create-project.sh $1 $2 $3"
	LAST=$(cat "$HOME/.dot-notes/create-project-templates/.last")
	cd $LAST
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
