#!/usr/bin/env bash

query="${1:-None}"
fzf_match="${2}"

if [[ -d ${fzf_match} ]]; then
  if [[ -n "${EDITOR}" ]] && which "${EDITOR}" >/dev/null 2>&1; then
    kitty @ launch --type=tab --tab-title="$(basename "${fzf_match}")" --cwd="${fzf_match}" "${SHELL}" -c "${EDITOR} . && exec ${SHELL}"
  else
    kitty @ launch --type=tab --tab-title="$(basename "${fzf_match}")" --cwd="${fzf_match}"
  fi
else
  matched_tab_id=$(kitty @ ls | jq -r ".[] | .tabs[] | select(.title == \"${fzf_match}\") | .id")

  if [[ "${query}" == "None" ]] && [[ -z "${matched_tab_id}" ]]; then
    exit
  fi

  if [[ -n "${matched_tab_id}" ]]; then
    # Use kitty's internal tab id instead of titles because they can be changed by applications
    kitty @ focus-tab --match id:"${matched_tab_id}"
  elif [[ -d "${query}" ]] && [[ "${query}" != "None" ]]; then
    kitty @ launch --type=tab --tab-title="$(basename "${query}")" --cwd="${query}"
  elif [[ ! -d "${query}" ]] && [[ "${query}" != "None" ]]; then
    z_target=$(zoxide query "${query}" || echo "${HOME}")
    kitty @ launch --type=tab --tab-title="${query}" --cwd="${z_target}"
  fi
fi
