#!/usr/bin/env bash

fzf_match="${1}"

if [[ -d ${fzf_match} ]]; then
  :
else
  matched_tab_id="$(kitty @ ls | jq -r ".[] | .tabs[] | select(.title == \"${fzf_match}\") | .id")"

  read -rp "New tab title > " new_tab_title
  kitty @ set-tab-title --match id:"${matched_tab_id}" "${new_tab_title}"
fi
