#!/usr/bin/env zsh

export GIT_BASE_URL="https://github.com"

function create-branch(){
    git checkout -b "$@"
    git push -u origin "$@"
}

function resolve-all-mine(){
    grep -lr '<<<<<<< HEAD' . | xargs git checkout --ours
}

function resolve-all-theirs(){
    git merge -Xtheirs
}

function set-github-enterprise-config(){
    git config --global --unset hub.host

    git config --global --add hub.host github.secureserver.net
}

function init-hub(){
    set-github-enterprise-config

    # generate a garbage event
    hub pull-request -m "test" -b "xxxx"

    log-warn "OK"
}

function resync(){
    git fetch
    git merge origin/master
}

function git-api(){
    curl "$GIT_BASE_URL/api/v3/$@?access_token=$GIT_TOKEN"
}

function rollback-release(){
    tag=$1

    if [ $# -eq 0 ]
    then
        echo "Need git tag to rollback"

        return 1
    fi

    echo "Deleting tag $tag from local"

    git tag -d $tag

    echo "Deleting tag $tag from remote"

    git push origin :refs/tags/$tag

    echo "Executing rollback"

    mvn release:rollback

    cm "Rolling back release"
}

function latest-pr(){
    components=(`get-git-components`)

    owner=$components[1]

    repo=$components[2]

    latest_pr_id=`git-api repos/$owner/$repo/pulls | \
                        jq ".[] | select (.state==\"open\") | \
                        .number" | \
                        sort -n -r | \
                        head -1`

    o "$GIT_BASE_URL/$owner/$repo/pull/$latest_pr_id"
}

function get-git-remote(){
    remotes=()

    git remote -v |  while read f
    do
        remotes=($remotes $f)
    done;

    echo $remotes[1]
}

function pre-release(){
    mvn release:prepare;

    git add --all .

    cm "Release prepare";
}

function prune-merged-branches(){
    currentbranch=`git-branch-current`

    git branch --merged | egrep -v "master|develop|$currentbranch" | sed 's/origin\///' | xargs git branch -d
}

function release(){
    push

    url=`hub pull-request -m "Release prepare"`

    echo $url

    o $url
}

function pr(){

    which hub

    local branch message

    usage="create a pull request: pr -b|--branch <branch> -m <message>"

    if [ $# -eq 0 ]; then
        echo $usage
        return 1
    fi;

    while [ "$1" != "" ]; do
        PARAM="$1"

        VALUE="$2"

        case $PARAM in
            -h | --help)
                echo $usage
                return 1
                ;;
            -b | --branch)
                branch=$VALUE
                ;;
            -m | --message)
                message=$VALUE
                ;;
            *)
                echo "ERROR: unknown parameter \"$PARAM\""
                echo $usage
                return 1
                ;;
        esac
        shift
        shift
    done

    query="hub pull-request -m \"$message\" -b $branch"

    echo "Create pull request: $query?"

    read

    url=`eval $query`

    echo $url

    o $url
}

function get-git-components(){
    name=`get-git-remote | \
                sed 's/origin.*git@github\.secureserver\.net://g' | \
                sed 's/.git (fetch)//g'`

    components=("${(s|/|)name}")

    owner=$components[1]

    repo=$components[2]

    echo $owner $repo
}

function get-giturl(){
    components=(`get-git-components`)

    owner=$components[1]

    repo=$components[2]

    branch=`git-branch-current`

    echo "$GIT_BASE_URL/$owner/$repo/tree/$branch"
}

function open-pull-requests(){
    components=(`get-git-components`)

    owner=$components[1]

    repo=$components[2]

    branch=`git-branch-current`

    o "$GIT_BASE_URL/$owner/$repo/pulls"
}

function open-github(){
    o `get-giturl`
}

alias gh="open-github"

alias lpr="latest-pr"

alias cm="git commit -m"

alias push="git push"
