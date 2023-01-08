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
ShellX initalised for oghny in Hostname
Session information:
  Started at 20 hr 10 min 34 sec
  Loaded in: 00 hr 00 min 01 sec
Libraries:
    [*] colors.sh           [*] io.sh               [*] stopwatch.sh        [*] user.sh             [*] debug.sh            [*] plugins.sh
    [*] command.sh          [*] path.sh             [*] sysinfo.sh          [*] cli.sh              [*] feature.sh          [*] session.sh
    [*] env.sh              [*] shell.sh            [*] time.sh             [*] config.sh           [*] log.sh              [*] update.sh
Plugins:
  Applied filter: @all
  Packages:
    [*] [@plugins] ~/.shellx/plugins
  Loaded:
    [*] @plugins/shellx_update.sh                                   [*] @plugins/wellcome.sh
```

Wellcome is the bundled plugin as of demo purposes and shellx_update is the one that enables AUTO_UPDATE feature.

## Default features

* Auto-Load of libraries: Load all libraries from ~/.shellx/lib folder, which makes to have in all your sessions specific functions, etc.
* Auto-Load of .{path,exports,aliases,functions,extra} files: just have your stuff bit more tidy up in files
* Bundled Plugins: loaded from ~/.shellx/plugins folder
* Auto include in PATH folder ~/.bin and ~/.local/bin to have your binaries also in control
* Extended Plugins: variable SHELLX_PLUGINS_EXTRA is an array of locations where (same as plugins folder) will be loaded. It helps you to allow to have your private plugins in another locations.

## Shellx CLI

Shellx once initialized, has his own CLI to make easier to interact with shellx functionalities, below you will find the same output as `shellx help`

```raw
MANAGE SESSION
-----------------------------------------------------------------------------
shellx reset                            Resets current shell session
                                        it does a /bin/zsh reset or exec /bin/zsh
shellx info                             Print Shell,OS and Host information
                                        current session info
                                        (start time, load time, plugins, etc)

MANAGE VERSION
-----------------------------------------------------------------------------
shellx version                          Prints current shellx version
shellx version info                     Prints a nice message with
                                        version and release notes
shellx update                           Updates (if newer) shellx version
                                        is available to latest release
shellx check                            Checks if a new version is available
                                        and print new changes
shellx update available                 Checks if a new version is available
                                        useful for scripting (returns 1 in
                                        case of no new version) so you can
                                        > shellx check && shellx update

TOOLS
-----------------------------------------------------------------------------
shellx debug enabled                    Enabled shellx debug output to stdout
shellx debug disabled                   Disable shellx debug output to stdout


MANAGE PLUGINS
-----------------------------------------------------------------------------
shellx plugins install <git-url>        Installs a plugins package from
                                        git repo url
shellx plugins installed                List installed plugin packages
shellx plugins uninstall <plugin_name>  Uninstall specified plugins package
shellx plugins reload                   Reloads plugins into current session
shellx plugins loaded                   List of loaded plugins in current
                                        current session
```

**Note**: All CLI commands `under the hood` calls to a shellx shell function in the form of `shellx::<namespace>::<function> <parameters>`. Below in this documentation you will find some internal library functions that can be used, and can be translated of invoked using this cli even if it's not documented in this help.
You just need to follow this convention, as example:

```shell
# Gets the full path for shellx-community-plugins package
$ shellx::plugins::path shellx-community-plugins
~/.shellx.plugins.d/shellx-community-plugins

# The same using shellx cli
shellx plugins path shellx-community-plugins
~/.shellx.plugins.d/shellx-community-plugins
```

## Configuration Options

ShellX can be customized in behaviour using a configuration file which can be located in different places (in order or priority):

- Environment variable `SHELLX_CONFIG`
- ~/.shellxrc
- ~/.config/shellx/config

This file is loaded at bootstrapping time, so it's useful to avoid having to export variables before starting shellx in your shell session.

Current configuration options are:

| KEY              | DESCRIPTION                                                                              |
| ---------------- | ---------------------------------------------------------------------------------------- |
| SHELLX_CONFIG    | If you wanna specify an specific location for your shellx configuration file             |
| SHELLX_PLUGINS_D | By default it's `HOME/.shellx.plugins.d` but in case you wanna set another special location for searching for external plugins directory, you can use this variable |
| SHELLX_NO_BANNER | If declared with any value, summary banner that contains session information, plugins loaded, etc. won't be displayed |
| SHELLX_DEBUG     | If declared with any value, debug mode is enabled, lot's of output in your console       |
| SHELLX_PLUGINS   | By default value is `@all` which means all plugins, it controls the plugin loading feature, you can read more about it in this documentation in `Selective plugin loading` section |
| SHELLX_HOME      | If you wanna move shellx to another location, you can set that location in this variable, by default it will use the place where the `shellx.sh` script is. |

### Reload configuration from the CLI

Now you can reload configuration from file in your current environment session just running

```shell
$ shellx config reload
$ shellx config print
SHELLX_NO_BANNER=yes
SHELLX_PATH_BACKUP=....
SHELLX_DEBUG=           # <- it means disabled
```

## Bundled session variables

When shellx is bootstrapped, there's some variables that can be used inside the session that belongs to shellx, it's quite important that you don't modify them if you don't want unexpected behaviours, but sometimes could be useful to use them in your scripts

| NAME                    | DESCRIPTION                                   |
| ----------------------- | --------------------------------------------- |
| __shellx_plugins_loaded | array with list of loaded plugins by name     |
| __shellx_homedir        | home directory for shellx installation        |
| __shellx_bindir         | shellx installation bin directory             |
| __shellx_libdir         | shellx installation lib directory             |
| __shellx_plugins_d      | shellx extended plugins directory             |
| __shellx_pluginsdir     | shellx installation bundled plugins directory |

## Bundled library of functions

Shellx includes and load a library of functions that can be used inside any plugin but also from your shell session

| LIB       | FUNC NAME               | DESCRIPTION                                                                              |
| --------- | ----------------------- | ---------------------------------------------------------------------------------------- |
| command   | command::get_type       | returns the type (as string) of a command by name, like "command,alias,function,builtin" |
| command   | command::exists         | returns true if specified command exists as command,alias or function                    |
| env       | env::export             | export a variable with a value                                                           |
| env       | env::is_defined         | checks if a variable is already defined, returns true or false                           |
| io        | io::exists              | returns true if the path (file or directory) exists, false if not                        |
| path      | path::add               | adds a new path to the PATH variable (if not already added)                              |
| path      | path::exists            | checks if a path is already in PATH variable                                             |
| path      | path::export            | alias of path::add with a different implementation                                       |
| path      | path::backup            | backups current PATH content into a variable (default PATH_BAK)                          |
| shell     | shell::function_exists  | checks if a function is already defined, returns true or false                           |
| shell     | shell::alias_exists     | checks if an alias is already defined, returns true or false                             |
| stopwatch | stopwatch::capture      | returns the current date to use in stopwatch::elapsed operation                          |
| stopwatch | stopwatch::elapsed      | elapsed time between startdate and enddate                                               |
| sysinfo   | env::arch               | returns os architecture (386, amd64, arm, unknown)                                       |
| sysinfo   | env::platform           | returns os platform (linux, darwin, unknown)                                             |
| sysinfo   | env::uptime             | human readable and cross-os uptime                                                       |
| time      | time::to_human_readable | from elapsed to human readable                                                           |
| user      | user::current           | returns the name of the current user                                                     |

## Community plugins

[Community Plugins repo](https://github.com/0ghny/shellx-community-plugins)

to installs them, or any other repository with plugins:

```shell
git clone https://github.com/0ghny/shellx-community-plugins ~/.shellx.plugins.d/shellx-community-plugins
# then, just restart your shell (e.g: exec zsh)
```

## Plugins Management

Shellx offer different functions that allows you to install/uninstall plugins created using `ShellX Plugin Framework guidelines` (read in sections below).
Remember that by default all plugin commands operates with `SHELLX_PLUGINS_D` variable, which is the directory that contains plugins installed.

| CLI                      | LIB              | FUNC NAME                  | DESCRIPTION                                                                            |
| ------------------------ | ---------------- | -------------------------- | -------------------------------------------------------------------------------------- |
| shellx plugins install   | shellx/plugins   | shellx::plugins::install   | with a git repository as parameter installs the plugin and reload plugins              |
| shellx plugins uninstall | shellx/plugins   | shellx::plugins::uninstall | with a plugin name as parameter uninstall the plugin from your shellx installation     |
| shellx plugins installed | shellx/plugins   | shellx::plugins::installed | prints current installed plugins and their location                                    |
|                          | shellx/plugins   | shellx::plugins::is_installed | with plugin name as parameter returns true or false if plugins is installed         |
| shellx plugins loaded    | shellx/plugins   | shellx::plugins::loaded    | prints current loaded plugins into shellx                                              |
| shellx plugins reload    | shellx/plugins   | shellx::plugins::reload    | reload all plugins                                                                     |
| shellx plugins update    | shellx/plugins   | shellx::plugins::update    | update specified plugin by name, or all plugins installed                              |

### Get current installed plugins

```shell
$ shellx plugins installed
Plugisn Installed:
  [*] plugins (~/.shellx/plugins)
  [*] shellx-community-plugins (~/.shellx.plugins.d/shellx-community-plugins)
  [*] shellx-plugins-arch (~/.shellx.plugins.d/shellx-plugins-arch)
```

### Installing a plugin

Next example installs `shellx-plugins-arch` which contains plugins for arch linux

```shell
$ shellx plugins install https://github.com/0ghny/shellx-plugins-arch
[PLUGIN] Cloning plugin into shellx plugins directory... OK
[PLUGIN] Reloading plugins...
```

### Uninstalling a plugin

Next example uninstall `shellx-plugins-arch` plugin

```shell
$ shellx plugins uninstall shellx-plugins-arch
[PLUGIN] shellx-plugins-arch uninstalling... OK
```

### Updating Plugins (or a single Plugin)

```shell
$ shellx plugins update [PLUGIN_NAME]
  where PLUGIN_NAME is an optional parameter with one of the plugin names.

  If provided, it should be an existing installed plugin name, to retrieve list of plugins installed you can execute
    shellx plugins installed
  and pick a proper name.

  If not provided it will try to update ALL plugins.

  The update method is using git pull under plugin directory, it will check also if directory contains a .git directory.
```

To update our `shellx-plugins-arch` plugin

```shell
$ shellx plugins update shellx-plugins-arch
[+] Updating shellx-plugins-arch... OK
```

### Selective plugins loading

The core of shellx is to be able to add or remove functionality by plugins. Some or the allready existing community plugins are ready to skip their functionality if as example the tool is not present into the system. If `dotnet` is not installed, doesn't makes sense to export the OPTOUT variables to disable telemetry.

But, even doing this, as much plugins you have, in some way, slower the bootstrap process will be.

To avoid this, shellx offer a selective plugin feature, that, as default is `load all plugins`. But, remember that all `bundled` plugins will be always loaded.

This configuration is done using the previously defined `SHELLX_PLUGINS` configuration property, which is an array that contains the plugins to be loaded. **BUT**, since a plugin can be named the same in different locations, we have offer different ways of specify `what to load`.

- Load all: In this case `SHELLX_PLUGINS` should be valued `( @all )`. **This is the default value**
- Load a location completely: Specify the name of the folder inside `shellx plugins d` directory with symbol '@' as prefix. In case of wanna load all community plugins installed, normally it will `( @shellx-community-plugins )`.
- Load specific plugin from a location: location/plugin-name, like `@shellx-community-plugins/asdf` or `@shellx-community-plugins/pyenv`
- Load all plugins that are named the same: just specify the name `asdf` or `pyenv` will load all plugins named asdf or pyenv in all locations.

Some examples:

```shell
# Loads all plugins, in this case variable can be defined in this way, or not be defined
SHELLX_PLUGINS=( @all )

# Load all community plugins only (+ bundled)
SHELLX_PLUGINS=( @shellx-community-plugins )

# Load asdf from community plugins + custom cloned plugins repo in a folder called shellx-my-plugins
SHELLX_PLUGINS=( @shellx-community-plugins/asdf @shellx-my-plugins )

# Load just plugins with names asdf,pyenv,minikube, in ALL locations
SHELLX_PLUGINS=( asdf pyenv minikube )
```

## Plugin framework Guidelines

Plugins may use all internal variables and functions bundled in ShellX (in fact, they are declared in session so, you can access to them from your shell anytime).

### Specific plugin configuration

When you're developing or using a plugin you may want to define certain "variables" that can affect to the plugin behaviour, like, as example, determine if you want to download a binary for a tool or not in case that doesn't exists on the system.

This is done using Feature Flags inside your plugin, basically you can use any variable named that you want, and the user can include that configuration in `ShellX configuration file` or exporting them into the shell before bootstrapping shellx, BUT, we recommend to follow (as we do) a naming pattern for those variables. Following our previous example, imagine a plugin that will install minikube in case it's not present into the system, you may create a variable called `SHELLX_PLUGIN_MINIKUBE_INSTALL_IF_NOT_PRESENT` or `SHELLX_PLUGIN_MINIKUBE_INSTALL` so basically `SHELLX_PLUGIN_MINIKUBE_` will be the prefix for your plugin variables. We do this to avoid conflicts with other tools or other plugins (even if this is almost impossible to ensure 100%), some people don't like LONG variable names, but, sometimes could be necessary.

### Extend with plugins

You can see some examples in folder `plugin-examples` or take a look or use [Community Plugins repo](https://github.com/0ghny/shellx-community-plugins).

Create your own repository with your plugins and clone them inside `SHELLX_PLUGINS_D` directory (usually ~/.shellx.plugins.d/folder_name).

Some ideas for plugins:

* Download a binary if not present in your system
* Create some aliases for some tools if they are installed
* Initialize some stuff like nvm, or any other if present tool

## Debugging ShellX

Shellx offers some internal logging mechanishm that may help to understand what's happening behind a command or operation.
Debug can be enabled in two ways:

- adding variable SHELLX_DEBUG to `shellxrc` file with any value (remove to disable)
- through CLI as `shellx debug enable` or `shellx debug disable`, this is specially useful since allows you to enable/disable for specific command executions during a session
- defining SHELLX_DEBUG variable before running a command `SHELLX_DEBUG=yes shellx plugins reload`
- defining SHELLX_DEBUG variable before running a function `SHELLX_DEBUG=yes shellx::plugins::reload`

if you have it declared in `shellxrc` file you will see lot of outputs everytime you start a shell, that's why it's not recommented.

**If you want to debug the shellx initialization process** it's better to do:

```shell
$ shellx debug enable
$ shellx reset
....
... lot of output
....

... once you finish debugging
$ shellx debug disable
```
