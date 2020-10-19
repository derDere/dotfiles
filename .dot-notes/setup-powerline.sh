# Powerline Setup via pip

curl https://bootstrap.pypa.io/get-pip.py -o $HOME/get-pip.py
python $HOME/get-pip.py --user
rm $HOME/get-pip.py
$HOME/.local/bin/pip install --user powerline-status
