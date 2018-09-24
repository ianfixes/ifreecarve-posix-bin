#!/bin/sh

# change screenshot location
mkdir -p ~/Desktop/screenshots_delete_anytime
defaults write com.apple.screencapture location ~/Desktop/screenshots_delete_anytime
killall SystemUIServer

# remove custom login background
sudo rm /Library/Caches/com.apple.desktop.admin*

# install brew


# install brew packages
brew install ag
brew install wget
brew install node
brew install imagemagick --with-librsvg
brew install emacs
brew install pv
brew install z
brew install tac
brew install cloc
brew install gcc
brew install gawk

# fix npm
# https://gist.github.com/DanHerbert/9520689
#rm -rf /usr/local/lib/node_modules
#brew uninstall node
#brew install node --without-npm
#echo prefix=~/.npm-packages >> ~/.npmrc
#curl -L https://www.npmjs.com/install.sh | sh

