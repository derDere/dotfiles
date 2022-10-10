#!sh

rm -f "$HOME/.dot-notes/create-project-templates/.last"

projectname="$1"

if [ -z "$projectname" ]; then
	projectname=$(dialog --clear --backtitle "Creating new Project" --inputbox "Enter project name:" 10 40 --output-fd 1)
fi

if [ -z "$projectname" ]; then
  return
fi

languages() {
  ls "$HOME/.dot-notes/create-project-templates"
}

languagesMenuItems() {
  NUM=1
	languages | while read i; do
		echo "$NUM $i"
		NUM=$(($NUM+1))
	done
}

LANG="$2"
if [ -z "$LANG" ]; then
	echo ""
else
	LANG=$(languages | sed -n "$LANG p" 2> /dev/null)
fi

if [ -z "$LANG" ]; then
	LANG=$(dialog --clear --backtitle "Creating Project: $projectname" --title "Language" --menu "Select Language:" 15 40 4 $(languagesMenuItems) --output-fd 1)
	if [ -z "$LANG" ]; then
		echo ""
	else
		LANG=$(languages | sed -n "$LANG p")
	fi
fi

if [ -z "$LANG" ]; then
	return
fi

DIR=""
case "$LANG" in
	"C++") DIR="cpp"
	;;
	"JavaScript") DIR="node"
	;;
	"Python") DIR="python"
	;;
esac

if [ -z "$DIR" ]; then
	dialog --clear --msgbox "\n    ERROR\!\n\nNo directory specified for this language\!" 10 40
	return
fi

templates() {
	ls "$HOME/.dot-notes/create-project-templates/$1"
}

templatesMenuItems() {
	NUM=1
	templates $1 | while read i; do
		echo "$NUM $i"
		NUM=$(($NUM+1))
	done
}

TMPL="$3"
if [ -z "$TMPL" ]; then
	echo ""
else
	TMPL=$(templates $LANG | sed -n "$TMPL p" 2> /dev/null)
fi

if [ -z "$TMPL" ]; then
	TMPL=$(dialog --clear --backtitle "Create Project: $projectname" --title "Template" --menu "Select Template:" 15 40 4 $(templatesMenuItems $LANG) --output-fd 1)
	if [ -z "$TMPL" ]; then
		echo ""
	else
		TMPL=$(templates $LANG | sed -n "$TMPL p")
	fi
fi

if [ -z "$TMPL" ]; then
	return
fi

mkdir -p "$HOME/documents/$DIR"
mkdir -p "$HOME/documents/$DIR/$projectname"

(
	cd "$HOME/documents/$DIR/$projectname"
	sh "$HOME/.dot-notes/create-project-templates/$LANG/$TMPL" $projectname
)

echo "$HOME/documents/$DIR/$projectname" > "$HOME/.dot-notes/create-project-templates/.last"
