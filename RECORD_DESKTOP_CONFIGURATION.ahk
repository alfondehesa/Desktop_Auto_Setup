#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Resources\get_desktop_name.ahk
#Include %A_ScriptDir%\Resources\UIA-v2-main\Lib\UIA.ahk

; This file prints out a configuration of every open window in your current virtual desktop. It spits it out in desktop_configuration.txt. You will then need to copy the contents to "set_up_desktop.ahk" at the specified seciton in the file. Then, any time you run set_up_desktop.ahk in this specific virtual desktop, your windows will open to where they were when they were recorded by this script.

; SETTINGS:

; Title names to ignore (use GET_WINDOW_INFORMATION.ahk tool to get title names, otherwise inspect desktop_configuration.txt after running this script to make sure you don't want to ignore any more titles)
title_ignore := [
    "",
    "Program Manager",
    "NVIDIA GeForce Overlay"
]

; Process names to ignore (use GET_WINDOW_INFORMATION.ahk tool to get process names, otherwise inspect desktop_configuration.txt after running this script to make sure you don't want to ignore any more processes)
process_ignore := [
    ""
]

; Manually map the path of a match. Replaces the executable path of a match in the name or process field.
; Add one line for the app's name/process (you can find it with GET_WINDOW_INFORMATION.ahk), and add the next line for the corresponding executable path (i.e. "Name1", "Path1", "Process2", "Path2").
; This is especially useful for window store apps that are notoriously difficult to open through an executable. You can specify the path to a shortcut, etc.
alternate_path_map := [
    "calculator",
    "calc.exe",
    "Windows PowerShell",
    "powershell",
    "Command Prompt",
    "cmd",
    "WhatsApp",
    A_ScriptDir "\Resources\App Shortcuts\WhatsApp - Shortcut.lnk",
    "Spotify.exe",
    "spotify.exe",
    "Settings",
    "ms-settings:"
]

; Delay amount (in milliseconds). Depending on your specific computer, setup, or apps that you want to open, you may adjust it higher/lower.
delay_amount := 1000

; Verbose level.
; 0 For basic prompts.
; 1 to inspect information about every added process.
; Useful for when wanting to add custom executable path mapping.
verbose := 1

; BEGGINING OF CODE:

; Initialize printout (what will end up in the file), give user time to configure windows
printout := init()

; Initialize a record of "Added" processes
process_record := Format("
(
    Added processes for desktop "{}":`n
)", VirtualDesktops.GetCurrentVirtualDesktopName())

; Find IDS of every open window in virtual desktop
ids := WinGetList(,,,)

; For each ID (each window)
For id in ids
{
    try {

        ; Find information on the current window (title and process name)
        local_title := WinGetTitle("ahk_id " id)
        local_process := WinGetProcessName("ahk_id " id)
        local_process_path := WinGetProcessPath("ahk_id " id)

        ; Only run if the title and process name is not contained in the title ignore and process ignore sections
        if (not contains_value(process_ignore, local_process)) and (not contains_value(title_ignore, local_title))
            {
                ; Record the position of the current window
                X_POS := ""
                Y_POS := ""
                WIDTH := ""
                HEIGH := ""
                WinGetPos(&X_POS, &Y_POS, &WIDTH, &HEIGH, "ahk_id " id)
                
                ; Record specific attributes if necessary (a chrome link or an explorer path)
                attribute := attribute_mapping(local_process)
                
                ; Substitute the process path for an alternative path if defined in the alternative path map:
                local_process_path := remap_path(local_process_path,local_title,local_process,alternate_path_map)

                ; Add the following lines to the printout, specific to the current process (iterative)
                composed_comands := Format("
                (
                    `n
                    ; Open {}
                    tmp_id:="ahk_id " WinExist("a")
                    Run "{} {}"
                    WinWaitNotActive(tmp_id,,20,,)
                    Sleep({})
                    tmp_id:="ahk_id " WinExist("a")
                    if WinGetMinMax(tmp_id) != 0 {
                        WinRestore(tmp_id)
                        sleep(1000)
                    }
                    WinMove({},{},{},{},tmp_id)
                )", local_process, local_process_path, attribute, delay_amount, X_POS, Y_POS, WIDTH, HEIGH, delay_amount)
                printout := printout composed_comands

                ; Communicate added process if verbose is on.
                if verbose >= 1 {

                    MsgBox("Added process!" "`n`nDetected process title: `n`n`t" local_title "`n`n`n`n`nDetected process executable: `n`n`t" local_process "`n`n`n`n`nDetected address: `n`n`t" attribute "`n`n`n`n`nDetected process path: `n`n`t" local_process_path, "PROCESS FOUND!")
                    
                }

                ; Append the current added process to the record.
                local_record := Format("
                (
                    `n`t - {}
                )", local_process)
                process_record := process_record local_record

            }
    }
}

; Save the prinout as "desktop_configuration.txt"
FileAppend(printout, A_ScriptDir "\Virtual Desktops\" VirtualDesktops.GetCurrentVirtualDesktopName() ".ahk")

; Print a message with the recorded apps
MsgBox(process_record, "Summary")

; FUNCTION DEFINITION

; Finds current desktop and uses it to initialize the printout (with the current desktop as a condtion). Also gives user time to adjust windows
init() {

    desktop := VirtualDesktops.GetCurrentVirtualDesktopName() ; Finds current desktop name
    MsgBox "Adjust windows to your desired position and click OK." ; Gives user time to adjust windows
    Sleep 1000 ; Gives time for the ahk window to close and not be detected
    
    ; Attempts to delete previous printout, if any
    try {
        FileDelete( A_ScriptDir "\Virtual Desktops\" VirtualDesktops.GetCurrentVirtualDesktopName() ".ahk")
    }

    ; Initializes a printout with the current desktop as a condition
    printout := Format("
    (   
        ; {}
        
        #Requires AutoHotkey v2.0
    )", desktop, desktop)
    
    return printout

}

; Returns True if second argument "Needle" is found in first argument array "Haystack". Returns False otherwise
contains_value(haystack, needle) {

	if !(IsObject(haystack)) ; || (haystack.Length() = 0)
		return False

	for index, value in haystack
		if (StrLower(value) = StrLower(needle))
			return True

	return False
}

; You might want some apps to be launched with attributes, such as a chrome window to a specified link or an explorer link in a specific directory. Add to this function to map a specific attribute to a specific proccess:
attribute_mapping(local_process){

    attribute := ""

    ; Specific attribute maping of chrome --> Specified address
    if StrLower(local_process) = StrLower("chrome.exe") {
        chrome_instance := UIA.ElementFromHandle("ahk_id " id)
        attribute := chrome_instance.ElementFromPath("YYY/YLY4").value " --new-window"
    }

    ; Specific attribute maping of explorer --> Specified Directory
    if StrLower(local_process) = StrLower("explorer.exe") {
        explorer_instance := UIA.ElementFromHandle("ahk_id " id)
        attribute := LTrim(explorer_instance.ElementFromPath("YYrCYL").name, "Address: ")
    }

    return attribute
}

; If the current process name or executable matches anything in the dictionary, return the next entry in the dictionary.
remap_path(current_path,local_title,local_process,dictionary) {

    if !(IsObject(dictionary)) ; || (haystack.Length() = 0)
        return current_path

    for index, value in dictionary
        if ((StrLower(value) = StrLower(local_title)) OR (StrLower(value) = StrLower(local_process))) AND (StrLower(local_process) != "explorer.exe")
            return dictionary[index+1]

    return current_path

}
