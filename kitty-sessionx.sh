#!/usr/bin/env bash
# Kitty "session" manager
#
# Author Luca Giugliardi
# Email: lukeemhigh+dev@protonmail.com
#
# Kudos:
#		https://zachwashere.substack.com/p/ditching-tmux-for-kitty
#		https://github.com/taylorzr/kitty-meow
#		https://github.com/omerxx/tmux-sessionx/blob/main/scripts/sessionx.sh
#
# ----------------------------- Shell Options ----------------------------

set -o pipefail

cmd="$(readlink -f "${0}")"
cmd_path="$(dirname "${cmd}")"
lib_path="${cmd_path}/lib"

TABS_PROMPT=' Kitty Tabs > '
TABS_HEADER='󰌑 : Switch to Selected Tab, Ctrl-X: Browse Config Directory, Ctrl-F: Browse Projects, Ctrl-R: Rename Tab, Alt-Backspace: Delete Tab'
TABS_RELOAD='kitty @ ls | jq -r ".[] | .tabs[] | .title"'

CONFIG_PROMPT=' Config Files > '
CONFIG_HEADER='󰌑 : Open New Tab in Selected Path, Ctrl-S: Browse Kitty Tabs, Ctrl-F: Browse Projects'
CONFIG_RELOAD='fd . ~/.config --min-depth 1 --max-depth 1 --type d --type l'

PROJECTS_PROMPT=' Projects > '
PROJECTS_HEADER='󰌑 : Open New Tab in Selected Path, Ctrl-S: Browse Kitty Tabs, Ctrl-X: Browse Config Directory'
PROJECTS_RELOAD='fd . ~/git-repos/** --min-depth 1 --max-depth 1 --type d'

readarray -t active_sessions <<<"$(kitty @ ls | jq -r '.[] | .tabs[] | .title')"

printf '%s\n' "${active_sessions[@]}" |
  fzf --ansi \
    --prompt="${TABS_PROMPT}" \
    --header="${TABS_HEADER}" \
    --preview="${lib_path}/preview.sh {}" \
    --preview-label='Ctrl-U: Scroll Up, Ctrl-D: Scroll Down' \
    --bind "enter:execute(${lib_path}/selection-handler.sh {q} {})+abort" \
    --bind "ctrl-r:execute(${lib_path}/rename-tab.sh {})+clear-query+reload(${TABS_RELOAD})" \
    --bind "alt-backspace:execute(${lib_path}/close-tab.sh {})+clear-query+reload(${TABS_RELOAD})" \
    --bind "ctrl-x:reload(${CONFIG_RELOAD})+change-prompt(${CONFIG_PROMPT})+change-header(${CONFIG_HEADER})" \
    --bind "ctrl-s:reload(${TABS_RELOAD})+change-prompt(${TABS_PROMPT})+change-header(${TABS_HEADER})" \
    --bind "ctrl-f:reload(${PROJECTS_RELOAD})+change-prompt(${PROJECTS_PROMPT})+change-header(${PROJECTS_HEADER})" \
    --bind "ctrl-d:preview-down" \
    --bind "ctrl-u:preview-up" \
    --layout=reverse \
    --padding=3%,1%
