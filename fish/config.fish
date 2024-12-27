set -g fish_greeting

starship init fish | source

export PATH="$HOME/.local/bin:$PATH"

source ~/.asdf/asdf.fish

# if status is-interactive
#     # Commands to run in interactive sessions can go here
#     eval "(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# end

# Homebrew
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# pnpm
set -gx PNPM_HOME "/home/raiane/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Alias
alias pn=pnpm
alias lazyd=lazydocker
alias lazyg=lazygit
alias cpc="xclip -sel c"
alias ls="eza --color=always --icons=always"

# List the 10 most usage memory process
alias psm="ps aux --sort=-%mem | head"

# Open files in nvim with fzf and entry directories with zoxide
alias nlof="~/scripts/fzf_listoldfiles.sh"
alias nzo="~/scripts/zoxide_openfiles_nvim.sh"

# Opens documentation through fzf (eg: git, fzf, etc.)
alias fman="complete -C | fzf | xargs man"

# Set up fzf key bindings
fzf --fish | source

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#ea83a5"
export FZF_TMUX_OPTS=" -p90%,70% "

# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Change default bat theme
export BAT_THEME="Catppuccin Mocha"

zoxide init fish | source
thefuck --alias | source
