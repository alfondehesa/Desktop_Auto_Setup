#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Resources\get_desktop_name.ahk
#Include %A_ScriptDir%\Resources\UIA-v2-main\Lib\UIA.ahk

; This file finds information about windows to help the user customize the desktop set-up ahk file.

; Display Instructions
MsgBox("Press OK, and immediately focus on the desired window (bring it to foreground and click on it).`nYou will have 5 seconds from dismissal of this message.","Instructions")

; Wait for user to switch windows
Sleep(5000)

; Find the ID of the focused window
id := "ahk_id " String(WinExist("A"))

; Get information about the open window
current_desktop := VirtualDesktops.GetCurrentVirtualDesktopName()
local_title := WinGetTitle(id)
local_process := WinGetProcessName(id)
local_process_path := WinGetProcessPath(id)

; Find special attributes (website address or explorer path) if any
attribute := attribute_mapping(local_process)

; Display properties
MsgBox("Added process!" "`n`n Current Desktop Name: `n`n`t" current_desktop "`n`n`n`n`n Window ID:`n`n`t" id "`n`n`n`n`nDetected process title: `n`n`t" local_title "`n`n`n`n`nDetected process executable: `n`n`t" local_process "`n`n`n`n`nDetected address: `n`n`t" attribute "`n`n`n`n`nDetected process path: `n`n`t" local_process_path, "PROCESS FOUND!")

; This function returns specific attributes if the process matches a specified one (i.e. for chrome.exe it returns the address bar, for explorer.exe it returns the path)
attribute_mapping(local_process){

    attribute := ""

    ; Specific attribute maping of chrome --> Specified address
    if StrLower(local_process) = StrLower("chrome.exe") {
        chrome_instance := UIA.ElementFromHandle(id)
        attribute := chrome_instance.ElementFromPath("YYY/YLY4").value " --new-window"
    }

    ; Specific attribute maping of explorer --> Specified Directory
    if StrLower(local_process) = StrLower("explorer.exe") {
        explorer_instance := UIA.ElementFromHandle(id)
        attribute := LTrim(explorer_instance.ElementFromPath("YYrCYL").name, "Address: ")
    }

    return attribute
}
