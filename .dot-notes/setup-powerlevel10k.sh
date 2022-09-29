#############
# Oh My ZSH
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i -E "s/(ZSH_THEME=\".+?\")/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g" ~/.zshrc


#############
# MANUAL
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
