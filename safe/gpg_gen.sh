function Generate_GPG_KEY() {
    GPGNAME=$1
    GPGEMAIL=$2
    echo "Generating the gpg key"

    pushd "$HOME" > /dev/null || exit
    if [ -d .gnupg ]; then
        rm -rf .gnupg
        mkdir -m 0700 .gnupg
    fi
    cd .gnupg || exit
    # I removed this line since these are created if a list key is done.
    # touch .gnupg/{pub,sec}ring.gpg
    if [ -f "${GPGEMAIL}".gpg.key ]; then
        echo "The ${GPGEMAIL}.gpg.key is exit!"
        PUBLIC_KEY_URL=$(realpath "${GPGEMAIL}".gpg.key)
        PASSWD_URL=$(realpath passwd)
    elif [ ! -f "${GPGEMAIL}".gpg.key ]; then
        gpg --list-keys
        PASSPHRASE=$(openssl rand -base64 16)
        echo "$PASSPHRASE" > passwds
        PASSWD_URL=$(realpath passwd)

        cat > keydetails << EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $GPGNAME
    Name-Comment: $GPGNAME
    Name-Email: $GPGEMAIL
    Expire-Date: 0
    Passphrase: $PASSPHRASE
    %no-ask-passphrase
    %no-protection
    %pubring pubring.kbx
    %secring trustdb.gpg
    # Do a commit here, so that we can later print "done" :-)
    %commit
    %echo done
EOF

        gpg --verbose --batch --gen-key keydetails
        #echo "Generate the ASCII Format Public Key"
        gpg --output "${GPGEMAIL}".gpg.key --armor --export "$GPGEMAIL"
        PUBLIC_KEY_URL=$(realpath "${GPGEMAIL}".gpg.key)
        # Set trust to 5 for the key so we can encrypt without prompt.
        #echo -e "5\ny\n" |  gpg2 --command-fd 0 --expert --edit-key user@1.com trust;

        # Test that the key was created and the permission the trust was set.
        gpg --list-keys
        #        echo "The ASCII Format Public key is $PUBLIC_KEY_URL"
        echo "$PUBLIC_KEY_URL"
        #        echo "The Passphrase is: $PASSPHRASE , saved at $PASSWD_URL"
        echo "$PASSWD_URL"
        rm keydetails
    fi
    popd > /dev/null || exit

}
Generate_GPG_KEY $1 $2
