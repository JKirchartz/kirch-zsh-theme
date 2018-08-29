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
  work="$home/Documents/Workspace"
  projects="$home/projects"

  where="${where/$home/α }"
  where="${where/$work/Δ }"
  where="${where/$projects/π }"

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
    echo -n "${$PWD/$HOME/~}"
    p_colour red
    echo -n "──"
    p_reset
    echo -n " `git_super_status` "
    echo
    p_colour red
    echo -n "┌─"
    p_reset
    p_colour cyan
    echo -n " `prompt_context` "
    p_colour red
    echo -n "──"
    echo -n "%@ ─ %j ─"
    p_reset
    RETVAL=$?
    printf "\n"
    p_colour red
    echo -n "└─"
    p_reset
    p_colour red
    echo -n "─ %h ─"
    p_reset
    echo -n " `prompt_status` "
    p_colour cyan
    echo -n ">"
    p_reset
}

PROMPT='%{%f%b%k%}$(build_prompt) '

PROMPT='%{%f%b%k%}$(build_prompt) '

precmd(){
    echo
    printf '\e[0;31m%*s\n\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#'
    printf '\e]0;%s@%s: %s\a' "${prompt_user}" "${prompt_host}" "${prompt_char}"
}

preexec(){
    printf '\e]0;%s [%s@%s: %s]\a' "$2" "${prompt_user}" "${prompt_host}" "${prompt_char}"		
}





# original prompt from zshrc:

# PS1=$'\n\n'"%F{white}%d $(git_super_status)"$'\n'"%F{red}┌─[%F{cyan}%n@%m%F{red}]-[%F{cyan}%D{%x %X}%F{red}]-[%F{cyan}%j%F{red}]"$'\n'"%F{red}└─[%F{cyan}%!%F{red}]-$__vim%F{cyan}%(#.#.$)>%F{white}%{$reset_color%}"
# PS2="%F{red}└─%F{cyan}>%{$reset_color%}"

