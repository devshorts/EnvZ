is_zsh=`ps $$ | grep zsh`
if [ "$?" = "0" ]; then
  local_path=`dirname $0:A`
else
  # make sure bash gets the env var location
  local_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

PATH=$PATH:$local_path/scripts

function edit-env-conf(){
    e $ENVIRONMENT_LOCATION/.config
}

function get_abs_filename() {
  perl -MCwd -le '
    for (@ARGV) {
      if ($p = Cwd::abs_path $_) {
        print $p;
      } else {
        warn "abs_path: $_: $!\n";
        $ret = 1;
      }
    }
    exit $ret' "$@"
}

function execute-remote(){

    if [ $# != 2 ]; then
        echo "Usage: execute-remote <host> <file>"
        return 1;
    fi
    machine=$1

    sourcefile=$2

    echo "Will execute root commands (in $sourcefile) on the remote ($machine)! Continue?"

    read

    COMMAND=`base64 -i $sourcefile`

    ssh -tt $machine "echo $COMMAND | base64 -d | sudo bash"
}

function update-env(){
    log-info "Updating main env"

    pushd $ENVIRONMENT_LOCATION

    git pull

    popd

    if [ -d $USER_MODULES ]; then
        pushd $USER_MODULES

        for dir in `ls -1LRd *`; do

            log-info
            log-info "Updating `basename $dir`"

            pushd $dir

            git pull

            popd
        done
    fi
}


# base 64 encode
alias B64enc='openssl enc -base64'

# base 64 decode
alias B64dec='openssl enc -base64 -d'

function newline-arr(){
    i=0
    var=()
    while read -r line
    do
        var[i++]=$line
    done

    return var
}

function brew-install(){
    prog=$1
    recipe=$2

    if [ -z $recipe ]; then
        recipe=$1
    fi

    hash $prog 2>/dev/null

    if [ $? != 0 ]; then
        log-info "Installing $prog"

        brew install $recipe

        return 1
    fi

    return 0
}

## ALIASES

# reload zsh completions
function reload-compinit(){
    autoload -Uz promptinit

    autoload -U compinit

    compinit -u

    promptinit

    for fn in $*; do
        unfunction $fn
        autoload -U $fn
    done
}

function reload(){
  is_zsh=`ps $$ | grep zsh`
  if [ "$?" = "0" ]; then
    source ~/.zshrc

    reload-compinit
  else
    source ~/.bashrc
  fi
}

# default editor
alias e="atom"

alias src="cd $SRC_DIR"

alias ls="exa -lahF"

alias cat="bat"
