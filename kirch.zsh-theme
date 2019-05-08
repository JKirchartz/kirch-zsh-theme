# kirch zsh theme

ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[cyan]%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[cyan]%}%{✚%G%}"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'


### Prompt colour helpers
p_colour() {
  local colour=$1 || 'cyan'

  echo -n "%{%F{$colour}%}"
}

p_reset() {
  echo -n %{%f%}
}

### Prompt components

prompt_rule() {
  # if lolcat is available, make the rule prettier
  if (( $+commands[lolcat] )); then
    printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#' | lolcat
  else
    printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#'
  fi
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
    local user=`whoami`
    if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        echo -n "%n@%m"
    else
        echo -n "λ"
    fi
}

prompt_location() {
  where=$PWD
  home=$HOME
  work="$home/work"
  projects="$home/projects"

  where="${where/$work/Δ}"
  where="${where/$projects/π}"
  where="${where/$home/~}"

  echo -n "$where"
}
# Status:
# - was there an error
# - are there background jobs?
# - am I root
prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘%{%f%}"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{magenta}%}⚙%{%f%}"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡%{%f%}" || symbols+="%{%F{cyan}%} \$${%f%}"
    [[ -n "${VIMRUNTIME}" ]] && symbols+="(%F{white}V%F{red})"

    [[ -n "$symbols" ]] && echo -n "$symbols"
}

## Main prompt
build_prompt() {
    prompt_rule
    echo -n "`prompt_location` "
    p_colour red
    echo -n "──"
    p_reset
    echo -n " `git_super_status` "
    p_colour red
    echo -n "\n┌─ "
    p_reset
    p_colour cyan
    echo -n "`prompt_context`"
    p_colour red
    echo -n " ── "
    p_colour cyan
    echo -n "%W %*"
    p_colour red
    echo -n " ─ "
    p_reset
    p_colour cyan
    echo -n "%j"
    p_colour red
    echo
    RETVAL=$?
    echo -n "└── "
    p_colour cyan
    echo -n "%h"
    p_colour red
    echo -n " ─"
    p_colour cyan
    echo -n "`prompt_status`"
    echo -n ">"
    p_reset
}

PROMPT='%{%f%b%k%}$(build_prompt) '

precmd(){
    echo
}

preexec(){
    # printf '\e]0;%s [%s@%s: %s]\a' "$2" "${prompt_user}" "${prompt_host}" "${prompt_char}"		
}

# original prompt from zshrc:

# PS1=$'\n\n'"%F{white}%d $(git_super_status)"$'\n'"%F{red}┌─[%F{cyan}%n@%m%F{red}]-[%F{cyan}%D{%x %X}%F{red}]-[%F{cyan}%j%F{red}]"$'\n'"%F{red}└─[%F{cyan}%!%F{red}]-$__vim%F{cyan}%(#.#.$)>%F{white}%{$reset_color%}"
# PS2="%F{red}└─%F{cyan}>%{$reset_color%}"

