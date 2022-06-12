#!/bin/bash
sudo apt install -y golang
mkdir -p "$HOME"/go/bin
export PATH="$PATH:$HOME/go/bin"
curl https://glide.sh/get | sh
echo "PATH"
echo "$GOPATH"
echo "$PATH"
sleep 5
mkdir -p "$GOPATH"/src/github.com/danielgtaylor
cd "$GOPATH"/src/github.com/danielgtaylor || exit
git clone https://github.com/danielgtaylor/tech-talk.git
cd tech-talk || exit
"$GOPATH"/bin/glide install
