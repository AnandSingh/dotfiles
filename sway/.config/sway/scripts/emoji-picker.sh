#!/usr/bin/env bash
# Emoji picker via rofi. Selected emoji is copied to the clipboard (wl-copy).
# No external emoji tool needed — curated common set lives inline below.
# (wtype isn't installed, so we copy rather than auto-type. Paste with the
#  clipboard shortcut or $mod+Alt+v history picker.)

set -euo pipefail

emojis="\
😀 grinning face
😂 face with tears of joy
🙂 slightly smiling face
😉 winking face
😍 smiling face with heart-eyes
😎 smiling face with sunglasses
🤔 thinking face
😅 grinning face with sweat
😭 loudly crying face
😡 enraged face
🥳 partying face
😴 sleeping face
🤯 exploding head
🙃 upside-down face
😬 grimacing face
👍 thumbs up
👎 thumbs down
👏 clapping hands
🙏 folded hands
🤝 handshake
💪 flexed biceps
👀 eyes
🔥 fire
✨ sparkles
🎉 party popper
✅ check mark
❌ cross mark
⚠️ warning
💡 light bulb
🚀 rocket
🐛 bug
💯 hundred points
❤️ red heart
💔 broken heart
⭐ star
☕ coffee
🍕 pizza
🎯 direct hit
📌 pushpin
📝 memo
📈 chart increasing
📉 chart decreasing
🔒 locked
🔑 key
⏰ alarm clock
💬 speech balloon
👋 waving hand
🤷 shrug
🥲 smiling face with tear
🫠 melting face"

chosen=$(printf '%s' "$emojis" | rofi -dmenu -i -p "Emoji" \
    -theme-str 'window {width: 28%;}')

[ -n "${chosen:-}" ] || exit 0

emoji=$(printf '%s' "$chosen" | cut -d' ' -f1)
printf '%s' "$emoji" | wl-copy
notify-send "Copied $emoji" "Emoji on clipboard — paste with Ctrl+V" -t 1500
