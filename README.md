# HevLib
Library mod for ΔV: Rings of Saturn that provides several useful functions.

This library is run through a set of 'pointers', which are small snippets of code that act, like the namesake, as pointers towards each function's file and as a way to organize a larger number of features into an easy to access location.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M01L6LMF)

# Usage
> [!WARNING]
> Do note that this library is comprised of several ModMain.gd files. If you plan on writing mods which makes use of functions provided by this library, and some features do not work properly in the Godot editor, you will need to load all (at the time of writing) 4 of the library's ModMain files, which are as follows:
> ```
> "res://HevLib/ModMain.gd",
> "res://HevLib/scenes/keymapping/ModMain.gd",
> "res://HevLib/scenes/equipment/ModMain.gd",
> "res://HevLib/webtranslate/ModMain.gd",
> ```

[Information is kept on the (current WIP) wiki, please take a look here for further information.](https://github.com/rwqfsfasxc100/HevLib/wiki)

# Installation

1. Download the `HevLib.zip` file from the [latest release page](https://github.com/rwqfsfasxc100/HevLib/releases/latest).
2. Locate the game's directory (i.e. where the .exe/.x86_64 file is located). Create a folder named `mods` inside of this directory.
3. Copy the `HevLib.zip` file to the `mods` folder
4. Set the `--enable-mods` launch parameter for the Delta-V executable file
4a. **Steam**: Properties -> General -> Launch Options
4b. **GOG**: Manage Installation -> Configure -> Features -> Arguments (you will need to duplicate the default profile to edit these)
4c. **Command Line**: Delta-V.exe --enable-mods or ./Delta-V.exe --enable-mods
5. Launch game
