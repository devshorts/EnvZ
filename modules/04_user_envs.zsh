#!/usr/bin/env zsh

function add-user-env(){

    usage="Add a user custom environment: link-user-env <directory containing your shells scripts>"

    if [ $# -eq 0 ]; then
        echo $usage
        return 1
    fi;

    userEnvDirectory=$1

    fileName=$(basename "$userEnvDirectory")

    user_modules=$USER_MODULES

    if [ ! -d $user_modules ]; then
        mkdir $user_modules
    fi;

    fullpath=`get_abs_filename $userEnvDirectory`

    ln -s $fullpath $user_modules/$fileName

    reload
}

function remove-user-env(){
    usage="Remove a user custom environment: remove-user-env <env to remove>"

    if [ $# -eq 0 ]; then
        echo $usage
        return 1
    fi;

    fullpath=$USER_MODULES/$1

    rm $fullpath

    reload
}
