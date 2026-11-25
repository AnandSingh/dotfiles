#!/usr/bin/env bash
# Continuous Waybar status stream for Vocalinux: no polling process per frame.
set -u

state_file="${XDG_RUNTIME_DIR:-/run/user/$UID}/vocalinux-waybar-state"
recording_frames=('▁▂▄▆▄▂▁' '▂▄▆█▆▄▂' '▄▆█▆█▆▄' '▂▄▆█▆▄▂')
processing_frames=('▁▃▅▇▅▃▁' '▃▅▇▅▇▅▃' '▅▇▅▃▅▇▅' '▃▅▇▅▇▅▃')
starting_frames=('·  ' '·· ' '···' ' ··' '  ·')
last_state=''
frame=0

emit() {
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$1" "$2" "$3"
}

while :; do
    if ! systemctl --user --quiet is-active vocalinux.service; then
        state=error
    elif [[ -r "$state_file" ]]; then
        read -r state < "$state_file" || state=idle
    else
        state=idle
    fi

    case "$state" in
        listening)
            emit "${recording_frames[frame % ${#recording_frames[@]}]}" recording 'Listening — release F10 to transcribe'
            frame=$((frame + 1))
            sleep 0.12
            ;;
        starting)
            emit "${starting_frames[frame % ${#starting_frames[@]}]}" starting 'Opening microphone…'
            frame=$((frame + 1))
            sleep 0.18
            ;;
        processing)
            emit "${processing_frames[frame % ${#processing_frames[@]}]}" processing 'Transcribing on devserver-aks…'
            frame=$((frame + 1))
            sleep 0.14
            ;;
        error)
            if [[ "$last_state" != error ]]; then
                emit '!' error 'Vocalinux service is not running'
            fi
            frame=0
            sleep 1
            ;;
        *)
            if [[ "$last_state" != idle ]]; then
                emit '' idle 'Hold F10 to dictate'
            fi
            frame=0
            sleep 0.4
            ;;
    esac
    last_state=$state
done
