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
    printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#'
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
  work="$home/Documents/Workspace"
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
    echo "`prompt_rule`"
    if [[ ! ${ZSH_THEME_KIRCH_RIGHT:=false} ]]; then
        echo "`build_rprompt`"
    fi
    p_colour red
    echo -n "┌─"
    p_reset
    p_colour cyan
    echo -n " `prompt_context` "
    p_colour red
    echo -n "──"
    echo " %W %* ─ %j ─"
    p_reset
    RETVAL=$?
    p_colour red
    echo -n "└─"
    p_reset
    p_colour red
    echo -n "─ %h ─"
    p_reset
    echo -n "`prompt_status`"
    p_colour cyan
    echo -n ">"
    p_reset
}
## Right Prompt
build_rprompt() {
    echo -n "`prompt_location` "
    p_colour red
    echo -n "──"
    p_reset
    echo " `git_super_status` "
}

PROMPT='%{%f%b%k%}$(build_prompt) '

if [[ ${ZSH_THEME_KIRCH_RIGHT:=false} ]]; then
  RPROMPT='%{%f%b%k%}$(build_rprompt)'
fi

precmd(){
    echo
}

preexec(){
    # printf '\e]0;%s [%s@%s: %s]\a' "$2" "${prompt_user}" "${prompt_host}" "${prompt_char}"		
}

# original prompt from zshrc:

# PS1=$'\n\n'"%F{white}%d $(git_super_status)"$'\n'"%F{red}┌─[%F{cyan}%n@%m%F{red}]-[%F{cyan}%D{%x %X}%F{red}]-[%F{cyan}%j%F{red}]"$'\n'"%F{red}└─[%F{cyan}%!%F{red}]-$__vim%F{cyan}%(#.#.$)>%F{white}%{$reset_color%}"
# PS2="%F{red}└─%F{cyan}>%{$reset_color%}"

