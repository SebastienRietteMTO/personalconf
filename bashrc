# This file contains general (not host specific) configuration
#
# Lines of documentation must starts exactly with '# DOC ' with the space at the end
# including for empty lines.

#############################
#### ALIAS AND FUNCTIONS ####
#############################

# DOC 
# DOC \e[34m#### Alias and functions ####\e[0m
# DOC
# DOC   * \033[1m ll \033[0m: ls -l
# DOC   * \033[1m ccd \033[0m: cd directory (creating it if necessary)
# DOC   * \033[1m a \033[0m: calculator (eg: 'a 2+3' prints '5')
# DOC   * \033[1m o \033[0m: open the file with the default program
# DOC   * \033[1m sdu \033[0m: print size of arguments, ordered
# DOC   * \033[1m vipy \033[0m: open with 'vi -p' all *.py files found in the current directory
# DOC   * \033[1m Myhelp \033[0m: this help message
alias ll='ls -l'
function ccd { [ ! -e $1 ] && mkdir $1; cd $1; }
function a { python3 -c "from math import *; print($*)"; }
function o { for fichier in "$@"; do echo $fichier; xdg-open "$fichier"; sleep 1; done }
function sdu { du -sh $* | sort -h; }
vipy () { vi -p $(find . -name \*.py) $@; } 
function Myhelp { echo -e "$(grep '^# DOC ' $HOME/.bashrc_common | cut -c 7-)"; }

##############################
#### ENVIRONMENT VARAIBLES ###
##############################

#Pour crontab -e
export EDITOR=vim

############################
#### PYTHON VIRTUAL ENV ####
############################

# DOC 
# DOC \e[34m#### Python virtual env ####\e[0m
# DOC The 'pye' function is declared (with autocompletion):
# DOC 
# DOC   * \033[1m pye NAME \033[0m: create (if not already done) the virtual env NAME and activate it
# DOC   * \033[1m pye \033[0m: list virtual environments
# DOC   * \033[1m pye exit \033[0m: exit the current virtual environment
base_env=${HOME}/virtualenvs
pye() {
  arg=$1
  if [ "$arg" == "" ]; then
    deact=""
    [ "$VIRTUAL_ENV" != "" ] && deact="exit"
    (cd $base_env; echo ${deact} $(\ls))
  elif [ "$arg" == "exit" ]; then
    deactivate
  elif [ -e ${base_env}/${arg} ]; then
    . ${base_env}/${arg}/bin/activate
  else
    (cd ${base_env}; python3 -m venv ${arg})
    . ${base_env}/${arg}/bin/activate
  fi
}
_script() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "$(pye)" -- ${cur}) )
  return 0
}
complete -o nospace -F _script pye

############################
#### BASH CONFIGURATION ####
############################

#Pour traiter correctement les variables d'environnement avec l'auto-completion
shopt -s direxpand
