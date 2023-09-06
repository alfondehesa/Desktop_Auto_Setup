#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Resources\get_desktop_name.ahk

; This file closes all windows and opens a predefined amount of windows in predefined locations.

; SETTINGS:

; How many monitors were your configurations set up for.
monitor_count := 1

; BEGGINING OF CODE:

; Change this to your preferred hotkey to trigger
^F1::
{
	; Find name of virtual desktop
	current_desktop := StrLower(VirtualDesktops.GetCurrentVirtualDesktopName())
	
	; Print a warning if the number of monitors does not match the settings
	if not MonitorGetCount() = monitor_count {
		MsgBox(Format("This script was made to work with {} monitors. It might now work correctly for {}.`nChange the monitor count in set_up_desktop.ahk and re-adjust preset desktop configurations with RECORD_DESKTOP_CONFIGURATION.ahk, or correct your number of monitors.`nPress OK to continue.",monitor_count,MonitorGetCount()),"WARNING")
	}

	; Close all current windows
	close_windows() ; Close all windows in current virtual desktop

	try {
		RunWait( A_ScriptDir "\Virtual Desktops\" current_desktop ".ahk")
	}

	; Display completion message
	MsgBox("Your virtual desktop has been set up!","Done!","T1")
}

; Define function to close windows
close_windows() {

	; Get IDs of all open windows
	ids := WinGetList(,,"Program Manager",)

	; Iterate over open windows
	For id in ids
	{
		; Attempt to close
		try {

			; Get the title of the window
			this_title := WinGetTitle("ahk_id " id)

			; If the title is not empty
			if not this_title = ""
				{
					; Close the window
					winclose this_title
				}
		}
	}
	Return
}
