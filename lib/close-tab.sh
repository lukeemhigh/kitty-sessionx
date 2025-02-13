#!/usr/bin/env bash

fzf_match="${1}"

if [[ -d ${fzf_match} ]]; then
  :
else
  matched_tab_id="$(kitty @ ls | jq -r ".[] | .tabs[] | select(.title == \"${fzf_match}\") | .id")"

  kitty @ close-tab --match id:"${matched_tab_id}"
fi
