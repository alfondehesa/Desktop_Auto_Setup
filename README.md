# Desktop Auto Setup (AHK V2)

I got tired of starting my day **segregating apps by virtual desktops** (to have different streamlined workflows), only to finish the days with **a plethora of different apps in the wrong virtual desktops** and having to **re-organize them manually again**.

This project uses the **AutoHotkey V2 platform** to **record the placement and type of specific windows** in a specific Windows Virtual Desktop, and **restores the stored configuration** when a given hotkey is pressed.

It accomplishes this by first **recording executable paths and positions for every opened window** (besides specified windows to ignore).
It then **closes all windows**, and **calls every executable**, while **moving them** to the appropriate previously recorded location.

Furthermore, it **supports some attributes at opening**, like opening the file explorer at a specific path, or a Chrome browser at a specific address. The user can also add their own automatically mapped attributes if desired.

**CONTENTS:**

- [Desktop Auto Setup (AHK V2)](#desktop-auto-setup-ahk-v2)
  - [Installation](#installation)
    - [Download files](#download-files)
    - [Add main script to your startup folder](#add-main-script-to-your-startup-folder)
  - [Usage](#usage)
    - [Create and rename your virtual desktop](#create-and-rename-your-virtual-desktop)
    - [Record your virtual desktop configuration](#record-your-virtual-desktop-configuration)
      - [Options](#options)
    - [Trigger the script](#trigger-the-script)
    - [Get window information to set up custom ignore rules](#get-window-information-to-set-up-custom-ignore-rules)

## Installation

> [!IMPORTANT]
> Every script in the project is designed to use **AutoHotkey V2**. You do not have to install AutoHotkey V1 to run it. However, if you don't have it installed, you will **need to download AutoHotkey V2**. You can have multiple AutoHotkey versions in your computer, and AHK will automatically execute the scripts with the correct one.

### Download files

- **Download this repo's files** (or clone the repo) in any folder in your computer. You can have them stored in a folder inside your Document's folder, for example.
    > [!IMPORTANT]
    > Do not save files in a folder that needs admin permissions.

### Add main script to your startup folder

- You will need to **add a shortcut** to `set_up_desktop.ahk` to your **user or common startup folder**. For instructions on how to do so, [you can visit this Stack Overflow question](https://stackoverflow.com/questions/41723490/how-to-build-ahk-scripts-automatically-on-startup).

## Usage

### Create and rename your virtual desktop

- This script is **virtual desktop specific**.
- This means that whatever configuration you record will **only work in the virtual desktop that you record it in**.
- This was by design. That way, a user can have **multiple configurations**, each **designed to be used in their own virtual desktop**. For instance, you can have a virtual desktop called **programming**, that upon triggering the hotkey will be set up following your **programming config**, and another virtual desktop called **gaming**, that upon triggering the same hotkey will be set up following your **gaming config**.
- That also means that, since you are not actively selecting your configuration, you will **not be able to use your "programming" config set up in your "gaming" virtual desktop**.
- If your active virtual desktop does not have a recorded configuration, the script will **fail**.
- To start, **create your virtual desktop and rename it** to something recognizable, like "Programming" or "Administrative" or "Gaming" or "Browsing" or something along those lines. These are just some ideas.

### Record your virtual desktop configuration

- **Run** `RECORD_DESKTOP_CONFIGURATION.ahk` (you can double-click on it).
  - It will **open a message box prompting you to organize your windows**.
  - **Open all the programs** you want and **arrange them** in your desired locations.
  - Once you have everything where you want it, **click** `OK` in the **message box**.
  - By default, the script will give you a message box with information about each found window/process. **Dismiss these windows** by pressing `OK`.
  - It finally will give you a prompt showing you a **summary** of **every window/process that was found** and recorded.
  - You will find your **configuration file** was stored in the project directory, in the `Virtual Desktops` folder, under whatever name your virtual desktop was assigned. You can **modify the configuration file manually if desired** (it just contains a bunch of AHK instructions).

#### Options

- You can change some **parameters** for the `RECORD_DESKTOP_CONFIGURATION.ahk` script.
- To do so, **open the file with a text editor**.
- Under **SETTINGS**:
  - `title_ignore` is a list of string titles that if a window/process matches, will cause the script to ignore them at the time of making the configuration. By default, `""` and `"Program Manager"` are ignored, as these are system processes that do not necessarily correspond to a window. You can add more by adding to the list. Find out what title a specific window has by using `GET_WINDOW_INFORMATION.ahk` ([more info here](#get-window-information-to-set-up-custom-ignore-rules)) or by writing it down as the message is displayed while recording the desktop configuration with this script (you need to have `verbose` set to `1`, this is so by default).
  - `process_ignore` is the same as `title_ignore` but by process. By default, any empty processes `""` are also ignored. You can also add any string to this list. You can also find out the process corresponding to a specific window by using `GET_WINDOW_INFORMATION.ahk` ([more info here](#get-window-information-to-set-up-custom-ignore-rules)) or by writing it down as the message is displayed while recording the desktop configuration with this file (you need to have `verbose` set to `1`, this is so by default).
  - `alternate_map_path` is a list of titles or processes and corresponding, manually assigned execution paths. It is used to map a user specified execution path when a window with a specific process or name is detected.
    - This list needs to have an even number of entries. If you want to add to this list, you will add one entry for either the title or process that you want to map, and the next entry for the path that you want to map it to, in that order.
    - This is especially useful for Windows Store Apps that do not have an executable file available.
      - You can for example [do this](https://github.com/K3V1991/Create-Desktop-Shortcut-Windows-Store-Apps) to create a shortcut to an app. Then, you will specify the title to the app's window, and specify the path to your shortcut.
      - This repo includes an `App Shortcuts` empty folder inside the `Resources` folder where you can store shortcuts and map paths to that location, but you don't have to. You can always store the shortcut wherever you want so long as you map its location path.
    - This is an example of how `alternate_map_path` should look like:

    ```BASH
    alternate_path_map := [
    "EXAMPLE_TITLE_1",
    "EXAMPLE_EXECUTABLE_PATH_1",
    "EXAMPLE_PROCESS_NAME_2",
    "EXAMPLE_EXECUTABLE_PATH_2",
    "Calculator",
    "calc.exe",
    "Audacity",
    "C:\Program Files\Audacity\Audacity.exe",
    "WhatsApp",
    A_ScriptDir "\Resources\App Shortcuts\WhatsApp - Shortcut.lnk" ; This takes you to the App Shortcuts folder
    ]
    ```

    - `delay_amount` in milliseconds, is the amount of milliseconds the script waits for a window to open before attempting to move it. For software that takes a long time to open, such as a video game, you will want to make this value higher.
    - `verbose` is the level of verbose for the script. 1 Will print information for each window found and a summary of all windows/processes recorded. 0 Will only print the summary.
    - `attribute_mapping()` is a function defined at the bottom of the file that uses the UIA library to map certain attributes to some specified processes. For instance, by default, if a Windows explorer window is found, it will use UIA to record the path and pass it as an argument when starting the window. Similarly, if a chrome.exe instance if found, it will read the address bar and store the address to open chrome with it next time.

      - You can add an if statement to the function to add your own custom automatic attribute mapping. To do so, inside the project folder, in `\Resources\UIA-v2-main\Lib`, you will find `UIA.ahk`. Running this file will help you identify `ahk_id` numbers, `element names` and `element properties` for a specific element in a window.
      - If you hover your mouse over your desired element (like an address bar or a search bar, or even a button) it will show you information and different properties of that element.
      - Use the `UIA.ahk` window to figure out what property you are looking to extract (could be name, could be value, etc.).
      - You can get the UIA path to the element that you want (at the bottom left of the window).
      - Then, create a new if statement in the function, for whatever specific process you want (you can find out what process it is with `GET_WINDOW_INFORMATION.ahk` ([more info here](#get-window-information-to-set-up-custom-ignore-rules))).
      - Use the functions located in the previous `if` statements and the UIA path to extract the element you wanted.
      - Then, extract your desired property out of the element and return it.
      - That's it! Remember to save the script.

### Trigger the script

- By default, the **hotkey to trigger the script is `Ctrl + F1`**. You can **change this by editing** `set_up_desktop.ahk`.
- If this is the first time you run it, you will have to **load the script** (for subsequent times it will be initialized at Windows Startup since you added it to your startup folder). Simply **double-click on it**.
- If you have already recorded a configuration, try it out by **pressing your hotkey**!

> [!IMPORTANT]
> The script is also designed to give you a warning if you are trying to use it with a different amount of windows than what your usual setup has. This is a setting stored in `set_up_desktop.ahk`. The default is `1`, but change it to whatever amount of monitors the setup that you are recording in has.

### Get window information to set up custom ignore rules

- To **ignore specific windows** at the time of recording, or to **map different windows to a specific executable**, you will need to get some information about those windows. You can either identify these windows by their **process** (i.e. explorer.exe) or by their **name** (i.e. Spotify Premium). Sometimes, both will work, while other times one might be more descriptive than the other.
- You can do so by **enabling verbose at the time of recording** ([more info here](#options)).
- Alternatively, you can **run the `GET_WINDOW_INFORMATION.ahk` file**.
  - This script will prompt you to bring your desired window to focus, and it will return the name, process, path to the executable, and if any arguments are mapped, the arguments for it.
