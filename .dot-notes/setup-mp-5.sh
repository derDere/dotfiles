START_PWD=$(pwd)
mkdir $HOME/Downloads
cd $HOME/Downloads
wget https://triptico.com/download/mp-5.tar.gz
tar -xf mp-5.tar.gz
cd $HOME/Downloads/mp-5.46/
sudo apt-get install -y make gcc libncursesw5-dev
./config.sh
make
sudo make install
cd $START_PWD
