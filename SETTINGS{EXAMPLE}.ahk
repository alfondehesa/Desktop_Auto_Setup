#Requires AutoHotkey v2.0

; REMOVE {EXAMPLE} FROM TITLE!

; SETTINGS (Execution):

; How many monitors were your configurations set up for.
monitor_count := 1

; SETTINGS (Recording):

; Title names to ignore (use GET_WINDOW_INFORMATION.ahk tool to get title names, otherwise inspect desktop_configuration.txt after running this script to make sure you don't want to ignore any more titles)
title_ignore := [
    "",
    "Program Manager"
]

; Process names to ignore (use GET_WINDOW_INFORMATION.ahk tool to get process names, otherwise inspect desktop_configuration.txt after running this script to make sure you don't want to ignore any more processes)
process_ignore := [
    ""
]

; Manually map the path of a match. Replaces the executable path of a match in the name or process field.
; Add one line for the app's name/process (you can find it with GET_WINDOW_INFORMATION.ahk), and add the next line for the corresponding executable path (i.e. "Name1", "Path1", "Process2", "Path2").
; This is especially useful for window store apps that are notoriously difficult to open through an executable. You can specify the path to a shortcut, etc.
alternate_path_map := Map(
    "calculator",
    "calc.exe",
    "Windows PowerShell",
    "powershell",
    "Command Prompt",
    "cmd"
)

; Delay amount (in milliseconds) to wait for a window to open. Depending on your specific computer, setup, or apps that you want to open, you may adjust it higher/lower.
delay_amount_for_window_start := 1000

; Delay amount (in milliseconds) while moving the window. This can likely be smaller than the above.
delay_amount_for_move := 200

; Verbose level.
; 0 For basic prompts.
; 1 to inspect information about every added process.
; Useful for when wanting to add custom executable path mapping.
verbose := 1
