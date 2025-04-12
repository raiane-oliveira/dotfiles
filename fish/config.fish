set -g fish_greeting
set -gx JAVA_HOME /usr/lib/jvm/java-1.21.0-openjdk-amd64

starship init fish | source

export PATH="$PATH:$HOME/.asdf/installs/nodejs/20.19.0/bin"

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# Homebrew
#eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# pnpm
set -gx PNPM_HOME "/home/raianeeo/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Binds
bind \cf accept-autosuggestion -M insert

# Alias
alias pn=pnpm
alias lazyd=lazydocker
alias lg=lazygit
alias cpc="xclip -sel c"
alias ls="eza --color=always --icons=always"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias nv="nvim"

# List the 10 most usage memory process
alias psm="ps aux --sort=-%mem | head"

# Open old files in nvim with fzf and entry directories with zoxide
alias nlof="~/scripts/fzf_listoldfiles.sh"
alias nzo="~/scripts/zoxide_openfiles_nvim.sh"

# Opens documentation through fzf (eg: git, fzf, etc.)
alias fman="complete -C | fzf | xargs man"

# Vi mode
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor

# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set fish_cursor_default block
# Set the insert mode cursor to a line
set fish_cursor_insert line
# Set the replace mode cursors to an underscore
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
# Set the external cursor to a line. The external cursor appears when a command is started.
# The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
set fish_cursor_external line
# The following variable can be used to configure cursor shape in
# visual mode, but due to fish_cursor_default, is redundant here
set fish_cursor_visual block

# Set up fzf key bindings
fzf --fish | source

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules"

# FZF Rose pine theme
# export FZF_DEFAULT_OPTS="--height 50% --layout=default --border \
# --color=fg:#908caa,bg:#191724,hl:#ebbcba
# --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
# --color=border:#403d52,header:#31748f,gutter:#191724
# --color=spinner:#f6c177,info:#9ccfd8
# --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# FZF Mellow theme
export FZF_DEFAULT_OPTS="--height 50% --layout=default --border \
--color=fg:#c9c7cd,bg:#161617,hl:#f5a191 \
--color=fg+:#c1c0d4,bg+:#1b1b1d,hl+:#ffae9f \
--color=border:#2a2a2d,header:#90b99f,gutter:#161617 \
--color=spinner:#ecaad6,info:#9dc6ac \
--color=pointer:#ea83a5,marker:#e29eca,prompt:#e6b99d"
export FZF_TMUX_OPTS=" -p90%,70% "

# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Change default bat theme
export BAT_THEME="Catppuccin Mocha"

zoxide init fish | source

if status is-interactive
    neofetch
end

if status is-interactive
    export MANPAGER="nvim +Man!"
end

# Cheat sh
function cheat.sh
    curl cheat.sh/$argv
end

complete -c cheat.sh -xa '(curl -s cheat.sh/:list)'
