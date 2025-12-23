# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $ZSH_THEME
ZSH_THEME="robbyrussell"

# Plugins
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git eza zsh-autosuggestions grc sudo colorize tmux)

# Colorize style
zsh_colorize_style="colorful"

source $ZSH/oh-my-zsh.sh

# User configuration

# --- Aliases ---
# Bat (cat replacement)
# Note: The script ensures 'cat' aliases to the correct binary (bat or batcat)
# But since this file is copied, we rely on the user or the script to handle binary naming issues.
# To be safe and dynamic, we can use a conditional alias strategy or just assume 'batcat' on Kali/Debian.
# Or better, we can alias based on what's available. 
# However, Zsh rc runs at shell startup. We can check for command existence here.

if command -v batcat &> /dev/null; then
    alias cat='batcat'
elif command -v bat &> /dev/null; then
    alias cat='bat'
fi

# Note: Use \cat to use the standard cat command if needed for copying lines.

# Nmap (colorized)
alias nmap='grc nmap'

# Eza (ls replacement)
alias ls='eza --color=always --group-directories-first'
alias la='eza -la --color=always --group-directories-first'

# --- TMUX Autostart ---
# Automatically start tmux if not already inside one, and not in a script
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

# --- Custom Prompt ---
setopt PROMPT_SUBST

# tun0 IP configuration
vpn_ip_prompt() {
    local ip=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
    [[ -n "$ip" ]] && echo "[$ip]"
}

# Final Prompt Construction
PROMPT='┌──(%n@%m)-[%~]$(vpn_ip_prompt)
└─# '
