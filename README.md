EnvZ
====

This is an opinionated shared environment that augments the zshell.  It'll set up a bunch of stuff that nobody wants to bother with.

Preqreqs: ZSH.  Install [YADR](https://github.com/skwp/dotfiles) to simplify this.

Things like

- Installing YADR (if already on zsh)
- Installing a default editor ([atom](https://atom.io/))
- Ensuring that your `hub` wrapper has git OAUTH credentials and that it auto points to github enterprise
- useful aliases 
- useful autocompletes

It also supports custom user modules

Clone the repo wherever you want and to install run:

```
brew install zsh > /dev/null 2>&1;
chsh -s $(which zsh); 
if [ ! -f "~/.zshrc" ];
    touch ~/.zshrc
fi
echo ". `pwd`/EnvZ/bootstrap" >> ~/.zshrc
```

Then restart your terminal.

If you already have zsh installed, then just add the following to the bottom of your .zshrc file
```
. <path>/EnvZ/bootstrap
```

The bootstrapper may prompt or install required items (such as python) and give you the option to install a default editor or other items

When updates are pushed just execute `reload-env`

## Source directory

A key part of the environment is knowing where you store your source code. When the environment first starts it may ask you to put in where you source code exists.  Environment variables will work as well as `~`. All stored settings are put into the `.config` file. If you mess up, blow the file out.

## Sensitive information

Add any non shareable keys to a file called `keys` in the modules folder. `modules/keys` will be sourced if it exists.  For example, to add your git 
oauth token do

```
export GIT_TOKEN=....
``` 

In the keys folder.  

## Custom plugins

To add a folder to your set of shell loads, go to your path and do 

```
add-user-env <folder>
```

This will add the folders script contents to be sourced on shell start. Only files that end with `.sh` will get sourced and only the first directory level (this lets you build your own custom folders that contain whatever you want that wont get sourced)

To remove a custom folder do

```
remove-user-env ...
```

You can add custom validation to your modules that will run after all other modules are run by creating a `validate.sh` file in your module.  This file WILL NOT get run during the initial load, and only run after the fact.

And it will give you autocomplete on your installed plugins
