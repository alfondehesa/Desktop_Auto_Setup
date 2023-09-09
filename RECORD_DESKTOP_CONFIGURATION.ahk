#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Resources\get_desktop_name.ahk
#Include %A_ScriptDir%\Resources\UIA-v2-main\Lib\UIA.ahk
#Include %A_ScriptDir%\SETTINGS.ahk
#Include %A_ScriptDir%\Resources\Window_control.ahk

; This file prints out a configuration of every open window in your current virtual desktop. It spits it out in desktop_configuration.txt. You will then need to copy the contents to "set_up_desktop.ahk" at the specified seciton in the file. Then, any time you run set_up_desktop.ahk in this specific virtual desktop, your windows will open to where they were when they were recorded by this script.

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
                MAXIMIZED_STATUS := WinGetMinMax("ahk_id " id)
                
                ; Record specific attributes if necessary (a chrome link or an explorer path)
                attribute := attribute_mapping(local_process)
                
                ; Substitute the process path for an alternative path if defined in the alternative path map:
                local_process_path := remap_path(local_process_path,local_title,local_process,alternate_path_map)

                ; Add the following lines to the printout, specific to the current process (iterative)
                composed_comands := Format("
                (
                    `n

                    ; OPEN {}

                    ; Declare script variables
                    local_process_path := "{}"
                    attribute := "{}"
                    window_x_target := {}
                    window_y_target := {}
                    window_width_target := {}
                    window_height_target := {}
                    sleep_amount_at_window_start := {}
                    sleep_amount_move := {}
                    MAXIMIZED_STATUS_TARGET := {}

                    ; Record current window
                    tmp_id:="ahk_id " WinExist("a")

                    ; Run new window and wait for it to pop up
                    Run local_process_path " " attribute
                    WinWaitNotActive(tmp_id,,20,,)

                    ; Give it some time to boot up, and record its new id
                    Sleep(sleep_amount_at_window_start)
                    tmp_id:="ahk_id " WinExist("a")
                    
                    ; If it came out either maximized or minimized, restore it
                    if WinGetMinMax(tmp_id) != 0 {
                        WinRestore(tmp_id)
                        sleep(sleep_amount_move)
                    }
                    
                    ; To make sure we can fit it right, make the window as small as possible
                    make_window_as_small_as_possible(tmp_id)
                    sleep(sleep_amount_move)

                    ; Record the window's new smallest width and height
                    WinGetPos(&tmp_x, &tmp_y, &tmp_width, &tmp_height, tmp_id)

                    ; Find which monitor is at the target location and retrieve its center location
                    get_monitor_index_and_center_at_final_window_location(window_x_target, window_y_target, window_width_target, window_height_target, &index_result, &x_center_result, &y_center_result)

                    ; Transform the center coordinates to move coordinates that result on the current window being in the center
                    transform_move_coordinates_to_center_of_window(tmp_width, tmp_height, x_center_result, y_center_result, &corrected_target_x, &corrected_target_y)

                    ; Move window to the center of monitor
                    WinMove(corrected_target_x, corrected_target_y, 0, 0, tmp_id)
                    Sleep(sleep_amount_move)
                    
                    ; If window was maximized, maximize it
                    if MAXIMIZED_STATUS_TARGET = 1 {
                        WinMaximize(tmp_id)
                        Sleep(50)
                    }
                    
                    ; If window was neither maximized nor minimized, move to the correct location
                    if MAXIMIZED_STATUS_TARGET = 0 {
                        WinMove(window_x_target,window_y_target,window_width_target,window_height_target)
                        Sleep(50)
                    }
                    
                    ; If window was minimized, maximize to make big, and minimize
                    if MAXIMIZED_STATUS_TARGET = -1 {
                        WinMaximize(tmp_id)
                        Sleep(200)
                        WinMinimize(tmp_id)
                        Sleep(50)
                    }


                )", StrUpper(local_process), local_process_path, attribute, X_POS, Y_POS, WIDTH, HEIGH, delay_amount_for_window_start, delay_amount_for_move, MAXIMIZED_STATUS)
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

                Sleep(50)
            }
    }
}

printout_end := Format("
(
    `n`n`n`n
    ; FUNCTIONS

    ; CENTERS

    get_center_of_window(window_x_position, window_y_position, window_width, window_height, &x_center:="", &y_center:="") {
        ; Takes the window's XY position, width and height, and returns the window's XY center coordinates.
        x_center := window_x_position + (window_width/2)
        y_center := window_y_position + (window_height/2)

    }

    get_center_of_window_from_id(window_id, &x_center:="", &y_center:="") {
        ; Returns an X and Y coordinate for the center of a window when passed the window's id.
        
        WinGetPos(&window_x_position, &window_y_position, &window_width, &window_height, window_id)
        get_center_of_window(window_x_position, window_y_position, window_width, window_height, &x_center, &y_center)

    }

    get_center_of_monitor(left, right, top, bottom, &x_center:="", &y_center:="") {
        ; Returns center coordinates of a monitor provided left, right, top and bottom bounding coordinates.

        x_center := left + (0.5*(right-left))
        y_center := top + (0.5*(bottom-top))

    }

    get_center_of_monitor_from_monitor_index(monitor_index, &x_center:="", &y_center:="") {
        ; Returns a monitor's center coordinates when passing the monitor's index.

        get_all_monitor_indexes_and_bounding_coordinates(&recorded_dimensions_by_monitor)

        get_center_of_monitor(recorded_dimensions_by_monitor["Left" monitor_index], recorded_dimensions_by_monitor["Right" monitor_index], recorded_dimensions_by_monitor["Top" monitor_index], recorded_dimensions_by_monitor["Bottom" monitor_index], &x_center, &y_center)

    }


    ; MONITOR INDEXES

    get_all_monitor_indexes_and_bounding_coordinates(&recorded_dimensions_by_monitor := 0, &amount_of_monitors := 0) {
        ; Returns an object with properties
        ; .monitor_amount (which describes the user's total amount of monitors)
        ; .monitor_bounding_coordinates, which is a Map object. This map stores values for the bounding corner locations of a specific monitor. You can reference any of these locations "Left" "Right" "Top" "Bottom" by using this string and following with the monitor's number as an index. For example, object.monitor_bounding_coordinates["Left1"] will give you the X coordinate of the first monitor's left bounding edge.

        recorded_dimensions_by_monitor := Map()

        amount_of_monitors := MonitorGetCount()

        for i in range(amount_of_monitors) {

            current_monitor_number := i+1

            MonitorGetWorkArea(current_monitor_number,&Left,&Top,&Right,&Bottom)

            recorded_dimensions_by_monitor["Left" current_monitor_number] := Left
            recorded_dimensions_by_monitor["Right" current_monitor_number] := Right
            recorded_dimensions_by_monitor["Top" current_monitor_number] := Top
            recorded_dimensions_by_monitor["Bottom" current_monitor_number] := Bottom
            
        }
    }

    check_monitor_index_at_window(window_id, monitor_index := 0) {
        ; Returns the monitor index that the center of the window is located at.
        ; Alternatively, if a monitor index is passed, returns True if window is found at that location.
        
        
        get_all_monitor_indexes_and_bounding_coordinates(&monitor_bounding_coordinate_map,&monitor_amount)
        
        get_center_of_window_from_id(window_id, &x_center, &y_center)
        
        for monitor in range(monitor_amount) {
            monitor_id := monitor+1
            
            if monitor_bounding_coordinate_map["Left" monitor_id] < x_center && x_center < monitor_bounding_coordinate_map["Right" monitor_id] && monitor_bounding_coordinate_map["Top" monitor_id] < y_center && y_center < monitor_bounding_coordinate_map["Bottom" monitor_id] {
                window_center_monitor_index := monitor_id
            }
            
        }
        
        if monitor_index != 0 and window_center_monitor_index = monitor_index {
            return true
        }
        
        if monitor_index != 0 and window_center_monitor_index != monitor_index {
            return false
        }
        
        return window_center_monitor_index
        
    }

    get_monitor_index_and_center_at_final_window_location(window_x_target, window_y_target, window_width_target, window_height_target, &window_center_monitor_index :=0, &x_center_result := "", &y_center_result := "") {
        ; Returns the monitor index detected at the center of a window's final desired location.
        ; Also outputs the center of that monitor.
        
        get_center_of_window(window_x_target, window_y_target, window_width_target, window_height_target, &x_center, &y_center)

        get_all_monitor_indexes_and_bounding_coordinates(&monitor_bounding_coordinate_map, &monitor_amount)

        for monitor in range(monitor_amount) {
            monitor_id := monitor+1
            
            if monitor_bounding_coordinate_map["Left" monitor_id] < x_center && x_center < monitor_bounding_coordinate_map["Right" monitor_id] && monitor_bounding_coordinate_map["Top" monitor_id] < y_center && y_center < monitor_bounding_coordinate_map["Bottom" monitor_id] {
                window_center_monitor_index := monitor_id
            }
            
        }

        get_center_of_monitor_from_monitor_index(window_center_monitor_index, &x_center_result, &y_center_result)

    }


    ; WINDOW MANAGEMENT

    make_window_as_small_as_possible(window_id) {
        ; Makes the window as small as possible.

        WinMove(,,0,0,window_id)

    }

    transform_move_coordinates_to_center_of_window(window_width, window_height, target_x, target_y, &corrected_target_x, &corrected_target_y){
        ; Takes coordinates on the screen and outputs window coordinates that, when passed to a move command, result in centering the window on the first set of coordinates.
        corrected_target_x := target_x - (0.5 * window_width)
        corrected_target_y := target_y - (0.5 * window_width)

    }

    move_window_center_to_center_of_monitor(target_monitor_index, window_id){
        ; Moves a window to the center of a monitor.

        WinGetPos(,,&window_width, &window_height)

        get_center_of_monitor_from_monitor_index(target_monitor_index, &x_target, &y_target)

        transform_move_coordinates_to_center_of_window(window_width, window_height, x_target, y_target, &corrected_x_target, &corrected_y_target)

        WinMove(corrected_x_target, corrected_y_target, window_width, window_height, window_id)

    }

    range(a, b:=unset, c:=unset) {
        IsSet(b) ? '' : (b := a, a := 0)
        IsSet(c) ? '' : (a < b ? c := 1 : c := -1)
     
        pos := a < b && c > 0
        neg := a > b && c < 0
        if !(pos || neg)
           throw Error("Invalid range.")
     
        return (&n) => (
           n := a, a += c,
           (pos && n < b) OR (neg && n > b) )
    }
     

)")

printout := printout printout_end


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

        ; While the window still exists (there is at least one mroe tab)
        while WinExist("ahk_id " id) !=0 {

            ; Focus on the chrome window
            WinActivate(id)

            ; Read the address bar
            chrome_instance := UIA.ElementFromHandle("ahk_id " id)
            tab_address := chrome_instance.ElementFromPath("YYY/YLY4").value
            
            ; Close the tab
            Send("^w")

            ; Register the tab's adress
            attribute := attribute " " tab_address

            Sleep (300)

        }

        attribute := attribute " --new-window"
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
