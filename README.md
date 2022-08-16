# shellx

> Simple shell session bootstrap to init stuff to avoid having .bashrc or .zshrc full of code, this library helps to have everyting tidy up.


## Why ?

ZSH/BASH or any other shell has their own plugin managers and configuration managers which, for me, ends up changing my rc files or other configurations.
A minimal example could be, installing pyenv, it will require to enables it on the session that you want to use, in a minimal scenario, include these lines in .bashrc and .zshrc.

Initially i was using a generic shell file and just including a source of that file which do all of this, and was working fine, but i found that:

* file lines count increased a lot
* make file resilience like, don't init pyenv if is not installed into the system, was also making the stuff complex
* cross-OS like linux/osx had also some additional complexity

So, i have ended, which probably could be called a generic script loader. It doesn't do anything special at all but allows me:

* Having an unified way of configuring my shells, it uses one of many approaches to standardize home folder with a set of predefined files and folders. it defines a ~/bin folder between others that is auto-included in PATH, so it helps me to use always same approach on all my systems.
* Having different plugins in different folders, which allows me as example to load certain folders in certains environments to load variables or any other special configurations.
* It provides a minimal language based on SH/BASH (compatible with other shells) to use in plugins contexts to do certain stuff.

## Use it

Clone this repo to your disk

```shell
git clone https://github.com/0ghny/shellx ~/.shellx
```

Once cloned, modify your .zshrc or .bashrc or any *rc from a compatible shell to start shellx bootstrap with your shell. Below, an example to use it with ZSHell (add lines to end of your .zshrc file)

```shell
[[ -f ~/.shellx/shellx.sh ]] && source ~/.shellx/shellx.sh
```

Once you starts a new shell (or `exec zsh` to start a new one) you can check ShellX is in action with the shellx init output

```shell
 Plugins loaded: wellcome.sh shellx_update.sh
 Loaded in: 00 hr 00 min 00 sec
Happy Hacking
```

Wellcome is the bundled plugin as of demo purposes.

## Default features

* Auto-Load of libraries: Load all libraries from ~/.shellx/lib folder, which makes to have in all your sessions specific functions, etc.
* Auto-Load of .{path,exports,aliases,functions,extra} files: just have your stuff bit more tidy up in files
* Default Plugins: loaded from ~/.shellx/plugins folder
* Auto include in PATH folder ~/.bin and ~/.local/bin to have your binaries also in control
* Extended Plugins: variable SHELLX_PLUGINS_EXTRA is an array of locations where (same as plugins folder) will be loaded. It helps you to allow to have your private plugins in another locations.

## Plugin framework


### Extend with plugins

In short, just add .sh or .bash files into ~/.shellx/plugins folder and they will be loaded once your shell is restarted.
You can see some examples in folder `plugin-examples`.

Some ideas for plugins:

* Download a binary if not present in your system
* Create some aliases for some tools if they are installed
* Initialize some stuff like nvm, or any other if present tool
