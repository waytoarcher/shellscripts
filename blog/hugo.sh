# to install the latest version 0.53 of Hugo on Ubuntu:
# releases are here: https://github.com/gohugoio/hugo/releases
export VER="0.86.1"
action=${1:-pullblog}
cd /tmp/ || exit 1
[ -f hugo_${VER}_Linux-64bit.deb ] || wget https://github.com/gohugoio/hugo/releases/download/v"$VER"/hugo_"${VER}"_Linux-64bit.deb
sudo dpkg -i hugo_${VER}_Linux-64bit.deb

# check if right version is installed
hugo version
newsite(){
# make a new website (don't do that if you already have one)
# first go to the directory where a new folder for your website should be made
mkdir -p ~/Documents/blog/
cd ~/Documents/||exit 1
cd blog || exit 1
git init
git submodule add https://github.com/LukasJoswiak/etch.git themes/etch
# to use the example site, move the exampleSite contains to the root directory of your website
cp -r themes/etch/exampleSite/ .
# new site
hugo site new "blog"

# add a theme to a new or existing website
# 1. go choose a theme here: https://themes.gohugo.io/
# see on Github that the last commit is not too long ago (<12mths), so you know it's maintained
# also make sure the theme comes with an exampleSite
}
pullblog(){
cd ~/Documents/||exit 1
rm -rf hugo || exit 1
git clone git@github.com:sandylaw/hugo.git || exit 1
cd hugo || exit 1
git submodule update --init --recursive
}

# to edit, in general most content is in the content folder (in the root directory, not somewhere in themes)
# static files such as images can be put in static directory
# most contents is in Markdown .md and config files for most themes are in YAML or TOML

# preview the site
case "$action" in
    new)
        newsite
        ;;
    *)
        pullblog
        ;;
esac
