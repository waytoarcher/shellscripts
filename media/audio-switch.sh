#!/bin/sh

# based on a script from a now deleted askubuntu answer on this question http://askubuntu.com/questions/71863/how-to-change-pulseaudio-sink-with-pacmd-set-default-sink-during-playback
# the script linked in the answer is still available at https://github.com/mpapis/home_dotfiles/blob/master/bin/mypa though

# dependencies: pulseaudio pacmd awk xargs grep volumeicon
# optional dependencies: zenity (for gui switch)

# this script assumes you are using volumeicon as a tray icon and will restart it on switch
# if you do not use volumeicon you should remove the 2 lines in switch_sink()

function list_sinks() {
    pacmd list-sinks | grep -E 'index:|name:'
}

function switch_sink_default() {
    echo switching default
    pacmd set-default-sink $1 || echo failed
}

function switch_sink_applications() {
    echo switching applications
    pacmd list-sink-inputs \
                         | awk '/index:/{print $2}' \
                             | xargs -r -I{} pacmd move-sink-input {} $1 \
                                              || echo failed
}

function switch_sink() {
    switch_sink_default    "$@"
    switch_sink_applications "$@"
    # workaround because volumeicon does not detect a switch of audio output
    killall volumeicon 2> /dev/null
    (volumeicon &)
}

# Use a zenity gui to switch audio outputs
function switch_gui() {
    # get current output id, all output ids and the sink names
    current_id=$(pacmd list-sinks | egrep '\* index:' | egrep -o '[0-9]+$')
    ids=($(pacmd list-sinks | egrep 'index:' | egrep -o '[0-9]+$' | tr '\n' ' '))
    names=($(pacmd list-sinks | egrep 'name:' | egrep -o '\..*>$' | tr -d '>' | tr '\n' ' '))

    zen_pars="--list --radiolist --column '' --column 'ID' --column 'Sink_name'"

    # construct the zenity command
    for i in "${!ids[@]}"; do
        if [ ${ids[$i]} = $current_id ]; then
            zen_pars="$zen_pars TRUE"
        else
            zen_pars="$zen_pars FALSE"
        fi
        zen_pars="$zen_pars ${ids[$i]} ${names[$i]}"
    done

    # change the audio sink with the switch_sink function
    new_sink_id=$(zenity $zen_pars || echo "")
    if [ -n $new_sink_id ]; then
        switch_sink $new_sink_id
    fi
}

function help_me() {
    echo "Usage: $0 [gui|list|<sink name to switch to>]"
}

case "${1:-}" in
    "" | list) list_sinks    ;;
    [0-9]*) switch_sink "$@" ;;
    gui)    switch_gui       ;;
    *)      help_me          ;;
esac
