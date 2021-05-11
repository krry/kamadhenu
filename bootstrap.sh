#!/usr/bin/env bash

# Toolset
hr_msg ()  {
    echo ''
    printf -v _hr "%*s" "$(tput cols)" ""
    echo -en "${_hr// /${2--}}"
    echo -e "\r\033[$((($(tput cols)-${#1}-2)/2))C ${1-hi} "
}

message () {
    echo ''
    printf "\r  [ \033[00;34m(:\033[0m ] %s\n" "$1"
}

success () {
    echo ''
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

warning () {
    echo ''
    printf "\r  [ \033[00;33mUH\033[0m ] %s\n" "$1"
    WARNED=true
}

failure () {
    echo ''
    printf "\r\033[2K  [\033[0;31mNO\033[0m] %s\n" "$1"
    exit
}

# Checking for Homebrew
if type brew > /dev/null 2>&1; then
    message "Homebrew found. Commencing installation..."
    message "Cloning the Kamadhenu repository..."
else
    echo ''
    printf "Sorry, you'll need Homebrew for Kamadhenu to install itself."
    printf "See the REAMDE.md for manual installation instructions."
    exit 2
fi

# CONSTANTS
BREWFIX="$(brew --prefix)"
COW_DIR=${BREWFIX}/share/cows/
FIGLET_DIR=${BREWFIX}/share/figlet/fonts
FORTUNE_DIR=${BREWFIX}/share/games/fortunes

# Cloning
git clone --quiet https://github.com/krry/Kamadhenu.git
git_clone_status=$?

if (($git_clone_status < 2)); then
    success "Repository cloned into $PWD"
    cd "./Kamadhenu" && cd_status=$?
    if ((cd_status < 2)); then
        message "Building Kamadhenu's temple..."
        cp -f ./Kamadhenu /usr/local/bin/
        message "Updating brew and unbundling brewfile..."
    else
        failure "Oops, flubbed the dismount. Couldn't find the cloned files."
        failure "Find 'Kamadhenu' in $PWD and type 'brew bundle' to continue."
        exit 1
    fi
else
    failure "Cloning the git repository has gone awry."
    exit 1
fi

# Brewing
brew update && brew bundle
brew_status=$?
if (($brew_status < 2)); then
    success "Brewed and ready."
else
    warning "There was an issue with the brew."
fi

# Symlinking
if [ -L ${BREWFIX}/bin/Kamadhenu ] > /dev/null 2>&1 ; then
    rm ${BREWFIX}/bin/Kamadhenu;
fi
message "Symlinking Kamadhenu into $BREWFIX/bin"

ln -s "$PWD/Kamadhenu" "$BREWFIX/bin/"
symlink_status=$?
if (($symlink_status < 2)); then
    success "Kamadhenu symlinked"
else
    warning "Failed to symlink. You'll want to see to that."
fi

# Copying Data
hr_msg "Herding cowsays" "(oo) "
cp -n "${PWD}/cows/"*.cow "$COW_DIR"
cow_status=$?
if (($cow_status < 2)); then
    success "Cowsays herded into $COW_DIR"
else
    warning "Couldn't copy cows into $COW_DIR"
fi

hr_msg "Wrangling figlets" "<..> "

cp -n "${PWD}/figlet/fonts/"*.flf "$FIGLET_DIR"
figlet_status=$?

if (($figlet_status < 2)); then
    success "Figlets wrangled into $FIGLET_DIR"
else
    warning "Couldn't copy FIGlet fonts into $FIGLET_DIR"
fi

hr_msg "Stuffing fortune cookies" "\$\$ "

cp -n "${PWD}/fortunes/"* "$FORTUNE_DIR"
fortune_status=$?

if (($fortune_status < 2)); then
    success "Fortunes stuffed into $FORTUNE_DIR"
else
    warning "Couldn't copy Fortunes into $FORTUNE_DIR"
fi

if [ $WARNED ]; then
    warning "Check the warnings above to fix the flubs."
else
    success "Installation complete."
    echo ''
    hr_msg "GREAT SUCCESS!" "$"
    sleep 2
    echo ''
    echo ''
    printf "You may now call upon Kamadhenu, like so..." | cowsay -f fox | lolcat
    echo ''
    echo ''
    sleep 3
    echo ''
    echo ''
    figlet -f computer "Kamadhenu" | lolcat -a
    echo ''
    echo ''
    sleep 3
    Kamadhenu
fi
