#!/usr/bin/env bash
# Kitty "session" manager
#
# Author Luca Giugliardi
# Email: luca.giugliardi@gmail.com
#
# Kudos:
#		https://zachwashere.substack.com/p/ditching-tmux-for-kitty
#		https://github.com/taylorzr/kitty-meow
#		https://github.com/omerxx/tmux-sessionx/blob/main/scripts/sessionx.sh
#
# ----------------------------- Shell Options ----------------------------

set -o pipefail

# Add an index in front of every tab title to be used below (adding 1 to match kitty's displayed indexes in tab titles)
active_sessions=$(kitty @ ls | jq -r '.[0].tabs | map(.title) | to_entries | map("\(.key + 1) \(.value)") | .[]')

selection=$(printf '%s\n' "${active_sessions[@]}" |
	fzf --print-query \
		--prompt='Sessions > ' \
		--layout=reverse \
		--border \
		--border-label="Kitty Sessionx" \
		--border-label-pos=3 \
		--padding=3%,1% \
		--color='border:#7aa2f7,label:#7aa2f7,separator:#565f89,prompt:#bb9af7' \
		--color='fg:#a9b1d6,bg+:#292e42,fg+:#73daca,pointer:#9d7cd8,info:#9d7cd8')

readarray -t results <<<"${selection}"

query="${results[0]:-null}"
match="${results[1]%% *}"

if [[ "${query}" == "null" ]] && [[ -z "${match}" ]]; then
	exit
fi

if [[ "${active_sessions[*]}" =~ (${match}) ]] && [[ -n "${match}" ]]; then
	# Use tab indexes instead of titles because tabs with automatic titles are a moving target
	# (subtracting 1 to use the same index counting that kitty uses under the hood)
	kitty @ focus-tab --match index:"$((match - 1))"
elif [[ -d "${query}" ]] && [[ "${query}" != "null" ]]; then
	kitty @ launch --type=tab --tab-title="$(basename "${query}")" --cwd="${query}"
else
	z_target=$(zoxide query "${query}" || echo "${HOME}")
	kitty @ launch --type=tab --tab-title="${query}" --cwd="${z_target}"
fi
