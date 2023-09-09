#Requires AutoHotkey v2.0

#Include %A_ScriptDir%\Resources\get_desktop_name.ahk
#Include %A_ScriptDir%\Resources\UIA-v2-main\Lib\UIA.ahk
#Include %A_ScriptDir%\Resources\Iteration_functions.ahk

; SET OF WINDOW MANAGEMENT FUNCTIONS

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
