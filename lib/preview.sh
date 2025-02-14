#!/usr/bin/env bash

fzf_match="${1}"

if [[ -d ${fzf_match} ]]; then
  eval "${DIR_PREVIEW} ${fzf_match}"
else
  window_id="$(kitty @ ls | jq -r ".[] | .tabs[] | select(.title == \"${fzf_match}\") | .windows[0] | .id")"

  kitty @ get-text --ansi --add-wrap-markers --add-cursor --match id:"${window_id}" | sed -e 's/133;A//g' -e 's/133;C//g'
fi
