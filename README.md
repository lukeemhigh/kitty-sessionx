<table>
  <tr>
    <td><img src="assets/images/screenshot-2025173949409414-014814.png" alt="Screenshot 1" width="400"/></td>
    <td><img src="assets/images/screenshot-2025173949358414-013944.png" alt="Screenshot 2" width="400"/></td>
  </tr>
  <tr>
    <td><img src="assets/images/screenshot-2025173949406914-014749.png" alt="Screenshot 3" width="400"/></td>
    <td><img src="assets/images/screenshot-2025173949405014-014730.png" alt="Screenshot 4" width="400"/></td>
  </tr>
</table>
  
<p align="center"><strong style="color: #7aa2f7;">WIP: This project is still pretty much in alpha state.</strong></p>

`kitty-sessionx` is a session manager for [Kitty](https://sw.kovidgoyal.net/kitty/) that leverages `fzf` for managing terminal tabs. It enables you to switch between tabs, launch new ones, rename, and close existing tabs with custom key bindings—making tab management quick and efficient.

## Requirements

- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)
- [jq](https://github.com/stedolan/jq)

## Features

- **Tab Management:**
  - **Switch Tabs:** Quickly focus on a tab by selecting its title.
  - **Launch New Tabs:** Open new tabs in a specified directory. When a non-directory input is provided, `zoxide` is automatically used to find the best matching directory for launching a new session.
  - **Rename Tabs:** Easily update the title of active tabs.
  - **Close Tabs:** Remove tabs with a simple key binding.
- **Preview Support:**
  - Preview directories using file listings with `eza`.
  - Preview tab contents by retrieving the text output from `kitty`.

## Key Bindings

- **Enter:** Execute the selection, switching focus to the chosen tab or launching a new one based on the provided input.
- **Ctrl-R:** Rename the selected tab.
- **Alt-Backspace:** Close the selected tab.
- **Ctrl-X:** Reload to browse configuration directories from `~/.config`.
- **Ctrl-S:** Refresh the list of active `kitty` tabs.
- **Ctrl-F:** Browse project directories (from `~/git-repos`).
- **Ctrl-U / Ctrl-D:** Scroll the preview up or down respectively.

## Installation & Usage

1. Clone this repository:

   ```sh
   git clone https://github.com/lukeemhigh/kitty-sessionx.git ~/path/to/kitty-sessionx
   ```

2. In your kitty configuration file (`~/.config/kitty/kitty.conf`), bind a key combination to launch `kitty-sessionx`:

   ```
   map kitty_mod+<preferred key> launch --type=overlay ~/path/to/kitty-sessionx/kitty-sessionx.sh
   ```

3. Reload `kitty` or restart your terminal emulator to apply the changes.

## TODO

- [ ] Externally configurable inner workings
  - [ ] Make file listing command configurable
  - [ ] Make search paths for config and project configurable by defining custom commands
