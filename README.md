# shellx: the (almost) shell-independent plugin manager

ZSH/BASH or any other shell has their own plugin managers and configuration managers which, for me:

* Contains plugins that has to be available in other shells managers to work the same
* Or, if you don't use plugin managers like in bash, you have to setup your environment (like installing pyenv or nvm or any other), and then modify your bashrc to init all the required stuff, which ends up with a big bashrc which depends from your "pre-configured" environment. I mean, if you copy  this one to another machine, it won't work till you install all the pre-requirements.

A minimal example could be, installing pyenv, it will require to enables it on the session that you want to use, in a minimal scenario, include these lines in .bashrc and .zshrc.

Initially i was using a generic shell file and just including a source of that file which do all of this, and was working fine, but i found that:

* file lines count increased a lot
* make file resilience like, don't init pyenv if is not installed into the system, was also making the stuff complex
* cross-OS like linux/osx had also some additional complexity

So, i have ended, which probably could be called a generic script/plugin loader. It doesn't do anything special at all but allows me:

* Having "plugins" that allows me to do things like installing a package, cloning a repository, export variables, run commands. And cross-shell compatible.
* Having an unified way of configuring my shells, it uses one of many approaches to standardize home folder with a set of predefined files and folders. it defines a ~/bin folder between others that is auto-included in PATH, so it helps me to use always same approach on all my systems.
* Having different plugins in different folders, which allows me as example to load certain folders in certains environments to load variables or any other special configurations. It also allows me to clone other users plugins easily.
* It provides a minimal set of libraries and binaries bundled inside which offers a set of functions/aliases/etc. based on SH/BASH (compatible with other shells) to use in plugins contexts to do certain stuff easily.

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
* Bundled Plugins: loaded from ~/.shellx/plugins folder
* Auto include in PATH folder ~/.bin and ~/.local/bin to have your binaries also in control
* Extended Plugins: variable SHELLX_PLUGINS_EXTRA is an array of locations where (same as plugins folder) will be loaded. It helps you to allow to have your private plugins in another locations.

## Community plugins

[Community Plugins repo](https://github.com/0ghny/shellx-community-plugins)

## Plugin framework

Plugins may use all internal variables and functions bundled in ShellX (in fact, they are declared in session so, you can access to them from your shell anytime)

### Variables

| NAME                    | DESCRIPTION                                   |
| ----------------------- | --------------------------------------------- |
| __shellx_plugins_loaded | array with list of loaded plugins by name     |
| __shellx_homedir        | home directory for shellx installation        |
| __shellx_bindir         | shellx installation bin directory             |
| __shellx_libdir         | shellx installation lib directory             |
| __shellx_plugins_d      | shellx extended plugins directory             |
| __shellx_pluginsdir     | shellx installation bundled plugins directory |

### Extend with plugins

In short, just add .sh or .bash files into ~/.shellx/plugins folder and they will be loaded once your shell is restarted.
You can see some examples in folder `plugin-examples`.

Some ideas for plugins:

* Download a binary if not present in your system
* Create some aliases for some tools if they are installed
* Initialize some stuff like nvm, or any other if present tool
