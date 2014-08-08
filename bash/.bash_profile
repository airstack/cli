export EDITOR='subl -w'

[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

source ~/.profile
source ~/.git-completion.bash

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt

export PATH=~/bin:$PATH:/usr/local/share/npm/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin

# docker
export DOCKER_HOST=tcp://$(/usr/local/bin/boot2docker ip 2>/dev/null):2375

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export NVM_DIR="/Users/joe/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
