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

# HACK: I don't really know why it's `-gt` instead of `-ge`
if [[ $(pgrep -f "${cmd}" | wc -l) -gt 2 ]]; then
  exit
fi

lib_path="${cmd_path}/lib"

declare -a config_paths=(
  "${XDG_CONFIG_HOME:-${HOME}/.config}/kitty/kitty-sessionx.yml"
  "${cmd_path}/kitty-sessionx.yml"
)

for file in "${config_paths[@]}"; do
  if [[ -f "${file}" ]]; then
    config_file="${file}"
    break
  fi
done

if [[ -n "${config_file:-}" ]]; then
  eval "$(yq -e --raw-output '
    "CONFIG_RELOAD=\"" + .reload.config + "\"
    PROJECTS_RELOAD=\"" + .reload.projects + "\"
    TABS_PROMPT=\"" + .prompt.tabs + "\"
    CONFIG_PROMPT=\"" + .prompt.config + "\"
    PROJECTS_PROMPT=\"" + .prompt.projects + "\"
    TABS_HEADER=\"" + .header.tabs + "\"
    CONFIG_HEADER=\"" + .header.config + "\"
    PROJECTS_HEADER=\"" + .header.projects + "\"
    TABS_KEYBIND=\"" + .keys.tabs + "\"
    CONFIG_KEYBIND=\"" + .keys.config + "\"
    PROJECTS_KEYBIND=\"" + .keys.projects + "\"
    RENAME_KEYBIND=\"" + .keys.rename + "\"
    CLOSE_KEYBIND=\"" + .keys.close + "\"
    PREVIEW_UP_KEYBIND=\"" + .keys.previewUp + "\"
    PREVIEW_DOWN_KEYBIND=\"" + .keys.previewDown + "\"
    DIR_PREVIEW=\"" + .preview.cmd + "\""
  ' "${config_file}" | sed 's/\$/\\$/g')"
fi

export DIR_PREVIEW=${DIR_PREVIEW:-ls --color=always -lh}

TABS_PROMPT="${TABS_PROMPT:- Kitty Tabs > }"
TABS_HEADER="${TABS_HEADER:-󰌑 : Switch to Selected Tab, Ctrl-X: Browse Config Directory, Ctrl-F: Browse Projects, Ctrl-R: Rename Tab, Alt-Backspace: Delete Tab}"
TABS_RELOAD='kitty @ ls | jq -r ".[] | .tabs[] | .title"'

CONFIG_PROMPT="${CONFIG_PROMPT:- Config Files > }"
CONFIG_HEADER="${CONFIG_HEADER:-󰌑 : Open New Tab in Selected Path, Ctrl-S: Browse Kitty Tabs, Ctrl-F: Browse Projects}"
CONFIG_RELOAD="${CONFIG_RELOAD:-fd . ~/.config/** --min-depth 1 --max-depth 1 --type d}"

PROJECTS_PROMPT="${PROJECTS_PROMPT:- Projects > }"
PROJECTS_HEADER="${PROJECTS_HEADER:-󰌑 : Open New Tab in Selected Path, Ctrl-S: Browse Kitty Tabs, Ctrl-X: Browse Config Directory}"
PROJECTS_RELOAD="${PROJECTS_RELOAD:-fd . ~/workspace/** --min-depth 1 --max-depth 1 --type d}"

TABS_KEYBIND="${TABS_KEYBIND:-ctrl-s}"
CONFIG_KEYBIND="${CONFIG_KEYBIND:-ctrl-x}"
PROJECTS_KEYBIND="${PROJECTS_KEYBIND:-ctrl-f}"
RENAME_KEYBIND="${RENAME_KEYBIND:-ctrl-r}"
CLOSE_KEYBIND="${CLOSE_KEYBIND:-alt-backspace}"
PREVIEW_UP_KEYBIND="${PREVIEW_UP_KEYBIND:-ctrl-u}"
PREVIEW_DOWN_KEYBIND="${PREVIEW_DOWN_KEYBIND:-ctrl-d}"

readarray -t active_sessions <<<"$(kitty @ ls | jq -r '.[] | .tabs[] | .title')"

printf '%s\n' "${active_sessions[@]}" |
  fzf --ansi \
    --prompt="${TABS_PROMPT}" \
    --header="${TABS_HEADER}" \
    --preview="${lib_path}/preview.sh {}" \
    --preview-label='Ctrl-U: Scroll Up, Ctrl-D: Scroll Down' \
    --bind "enter:execute(${lib_path}/selection-handler.sh {q} {})+abort" \
    --bind "${RENAME_KEYBIND}:execute(${lib_path}/rename-tab.sh {})+clear-query+reload(${TABS_RELOAD})" \
    --bind "${CLOSE_KEYBIND}:execute(${lib_path}/close-tab.sh {})+clear-query+reload(${TABS_RELOAD})" \
    --bind "${CONFIG_KEYBIND}:reload(${CONFIG_RELOAD})+change-prompt(${CONFIG_PROMPT})+change-header(${CONFIG_HEADER})" \
    --bind "${TABS_KEYBIND}:reload(${TABS_RELOAD})+change-prompt(${TABS_PROMPT})+change-header(${TABS_HEADER})" \
    --bind "${PROJECTS_KEYBIND}:reload(${PROJECTS_RELOAD})+change-prompt(${PROJECTS_PROMPT})+change-header(${PROJECTS_HEADER})" \
    --bind "${PREVIEW_UP_KEYBIND}:preview-down" \
    --bind "${PREVIEW_DOWN_KEYBIND}:preview-up" \
    --bind "f5:refresh-preview" \
    --layout=reverse \
    --padding=3%,1%
