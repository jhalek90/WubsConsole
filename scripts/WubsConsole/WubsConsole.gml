////////////////////////////////////
//								  //
//			WubsConsole           //
//		   wubsgames.com          //
//                                //
////////////////////////////////////

//macros for color codes.
//you can put these in any text, and the console will draw the correct color
//example: "&2this text is red" 
//example2: "&4Blue &8Pink &1White" 
#macro WC_COLORCODE "&"
#macro WC_COLOR_WHITE "1"
#macro WC_COLOR_RED "2"
#macro WC_COLOR_GREEN "3"
#macro WC_COLOR_BLUE "4"
#macro WC_COLOR_YELLOW "5"
#macro WC_COLOR_GRAY "6"
#macro WC_COLOR_PURPLE "7"
#macro WC_COLOR_PINK "8"

#macro WC_CURSOR "|"

function wubsConsoleInit(){
	wubsConsoleLog=ds_list_create();//some data structures to hold the log
	wubsConsoleCallHistory = ds_list_create(); // list of previously ran commands
	wubsConsoleCallHistoryIndex = -1;
	
	wubsConsoleEnabled=false;//is the console open?

	//size adjustments can be made here
	wubsConsoleWidth=600;
	wubsConsoleHeight=256;
	wubsConsoleMaxLines=16;
	
	//variables for flashing the cursor
	wubsConsoleCursorFlash=false;
	wubsConsoleCursorTimer=0;
	wubsConsoleCursorDelay=30;
}

function wubsConsoleIsEnabled(){
	return wubsConsoleEnabled;
}

function wubsConsoleEnable(){
	wubsConsoleEnabled=true;
}

function wubsConsoleDisable(){
	wubsConsoleEnabled=false;
}

function wubsConsoleStep(_key,_keyClose){
	
	if !wubsConsoleIsEnabled(){
		if keyboard_check_pressed(_key){
		 wubsConsoleEnable();
		 exit;
		}
	}else{
		
		wubsConsoleCursorTimer++;
		if wubsConsoleCursorTimer>=wubsConsoleCursorDelay{
			wubsConsoleCursorFlash=!wubsConsoleCursorFlash;
			wubsConsoleCursorTimer=0;
		}
		
		if keyboard_check_pressed(_keyClose){
		 wubsConsoleDisable();
		 exit;
		}
		
		if keyboard_check_pressed(vk_enter){
			
			wubsConsoleAddLog(keyboard_string);
			wubsConsoleAddCommand(keyboard_string);

			
			keyboard_string="";
		}
		
		var _history_move_direction = keyboard_check_pressed(vk_up) - keyboard_check_pressed(vk_down);
		if _history_move_direction != 0{
			
			if (_history_move_direction == -1 and wubsConsoleCallHistoryIndex == -1){
				// Move down when there is last element.
				keyboard_string="";
			}else{
				// Move in history.
				var _call_history_size = ds_list_size(wubsConsoleCallHistory);
				wubsConsoleCallHistoryIndex += _history_move_direction;
				wubsConsoleCallHistoryIndex = clamp(wubsConsoleCallHistoryIndex, -1, _call_history_size - 1);
				
				// Get previous command from the history.
				var _previous_command = wubsConsoleCallHistory[| (_call_history_size - 1 - wubsConsoleCallHistoryIndex)];
				keyboard_string = _previous_command;
			}
			
		}
	}
}

function wubsConsoleAddLog(_text){
	ds_list_add(wubsConsoleLog,_text);
}
	
function wubsConsoleAddCommand(_text){
	ds_list_add(wubsConsoleCallHistory,_text);
	// reset history index.
	wubsConsoleCallHistoryIndex = -1;

	wubsConsoleHandleCommand(_text);
}

function wubsConsoleDraw(_x,_y){
	if !wubsConsoleIsEnabled(){exit}
	draw_set_font(fntWubsConsolas)
	draw_set_color(c_black)
	draw_set_alpha(0.8)
	draw_rectangle(_x,_y,_x+wubsConsoleWidth,_y+wubsConsoleHeight,false)
	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_rectangle(_x,_y,_x+wubsConsoleWidth,_y+wubsConsoleHeight,true)
	
	var _spacing=16;
	var _yOffset=-_spacing;
	var _fontOffset=18
	
	draw_set_color(c_ltgray)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	
	var _size=ds_list_size(wubsConsoleLog)
	
	for(var i=_size-1; i>max(-1,_size-wubsConsoleMaxLines); i--){
		var _t=wubsConsoleLog[| i];
		var _w=string_width(_t)
		
		if _w>wubsConsoleWidth{
			if wubsConsoleLog[| i+1] !=""{
				wubsConsoleAddLog("")
			}
		}
		
		//draw_text_ext(_x,_y+_yOffset+(wubsConsoleHeight-_fontOffset),_t,_spacing,wubsConsoleWidth);
		wubsConsoleDrawFormatted(_t,_x,_y+_yOffset+(wubsConsoleHeight-_fontOffset))
		_yOffset-=_spacing;
	}
		
	
	var _wubsConsoleDrawString=keyboard_string
	if (wubsConsoleCursorFlash==true){
		_wubsConsoleDrawString+=WC_CURSOR
	}
	draw_set_color(c_white)
	draw_text(_x,_y+(wubsConsoleHeight-_fontOffset),_wubsConsoleDrawString)
}
	
function wubsConsoleDrawFormatted(_str,_x,_y){
	
	draw_set_color(c_ltgray)
	var _len=string_length(_str)
	var _xx=_x
	var _yy=_y
	var _spacing=8
	for (var i=0; i<_len; i++){
		var _c=string_char_at(_str,i+1)
		if _c=WC_COLORCODE{
			_colorcode=string_char_at(_str,i+2)
			//pico 8 color pallet
			if _colorcode=WC_COLOR_RED{draw_set_color(make_color_rgb(255,0,7))}
			if _colorcode=WC_COLOR_WHITE{draw_set_color(make_color_rgb(255,241,232))}
			if _colorcode=WC_COLOR_GREEN{draw_set_color(make_color_rgb(0,135,81))}
			if _colorcode=WC_COLOR_BLUE{draw_set_color(make_color_rgb(41,173,255))}
			if _colorcode=WC_COLOR_YELLOW{draw_set_color(make_color_rgb(255,236,39))}
			if _colorcode=WC_COLOR_GRAY{draw_set_color(make_color_rgb(194,195,199))}
			if _colorcode=WC_COLOR_PURPLE{draw_set_color(make_color_rgb(131,118,156))}
			if _colorcode=WC_COLOR_PINK{draw_set_color(make_color_rgb(255,119,168))}
			i+=2;
			_c=string_char_at(_str,i+1)
		}
		draw_text(_xx,_yy,_c)//strings are 1 indexed....
		_xx+=_spacing
	}
}
	
function wubsConsoleHandleCommand(_command){
	
	//WubsConsole handles commands by seperating the user's input at spaces
	//the first blob of text is saved in "_thisCommand"
	//the rest of the text is saved in a ds list called _arguments
	//
	//Example "spawn" command
	/*
	//spawn 10 objCoin
	
	if (_thisCommand == "spawn"){
		var _amount = _arguments[| 0]//arg 0 is the number of things to spawn
		_obj = _arguments[| 1]//arg 1 is the object to spawn
		repeat(_amount){instance_create_depth(mouse_x,mouse_y,_obj)}//spawn a number of objects at the mouse
		wubsConsoleAddLog("&5Spawned &8"+string(_amount)+" &3"+string(_obj))//log to console
	}
	*/
	
	try{
	#region get command and arguments
		if _command == ""{
			exit;
		}
		_command+=" "//add a trailing space
		var _arguments=ds_list_create()
	
		var _remainingCommand=_command
	
		var _firstSpace=string_pos(" ",_remainingCommand);
		if _firstSpace>0{
			var _thisCommand=string_copy(_remainingCommand,0,_firstSpace-1);
			_remainingCommand=string_copy(_remainingCommand,_firstSpace+1,string_length(_remainingCommand)-1);
		
		
			do{
				_firstSpace=string_pos(" ",_remainingCommand);
				ds_list_add(_arguments,string_copy(_remainingCommand,0,_firstSpace-1));
				_remainingCommand=string_copy(_remainingCommand,_firstSpace+1,string_length(_remainingCommand)-1);
			}until(string_length(_remainingCommand)=0)
		
		
		}else{
			_thisCommand=_command;
		}
	
	#endregion

	#region command Help
		if (_thisCommand == "help") or (_thisCommand == "list"){
			wubsConsoleAddLog("&6Type commands into the console to execute code");
			wubsConsoleAddLog("");
			wubsConsoleAddLog("&1avalible commands:");
			wubsConsoleAddLog("    &1-&5help");
			wubsConsoleAddLog("    &1-&5quit");
			wubsConsoleAddLog("    &1-&5fullscreen");
			wubsConsoleAddLog("    &1-&5add &4[&1a&4] &4[&1b&4]");
			wubsConsoleAddLog("    &1-&5sub &4[&1a&4] &4[&1b&4]");
			wubsConsoleAddLog("    &1-&5mult &4[&1a&4] &4[&1b&4]");
			wubsConsoleAddLog("    &1-&5div &4[&1a&4] &4[&1b&4]");
			wubsConsoleAddLog("&6You can add new commands in &3wubsConsoleHandleCommand&6()&1;");
			wubsConsoleAddLog("");
			wubsConsoleAddLog("&1created by: &8Wubs");
			wubsConsoleAddLog("&7https://wubsgames.com");
			exit;
		}
	#endregion
	
	#region command Echo
		if (_thisCommand == "echo") or (_thisCommand == "say") or (_thisCommand == "repeat"){
			var _echo=""
			for (var _a=0; _a<ds_list_size(_arguments); _a++){
				_echo+=_arguments[| _a];
				_echo +=" "
			}
			wubsConsoleAddLog(_echo);
			exit;
		
		}
	#endregion
		
	#region command Clear
		if (_thisCommand="clear"){
			ds_list_clear(wubsConsoleLog)
			exit
		}
	#endregion
		
	#region command Exit
		if (_thisCommand="exit") or (_thisCommand="quit"){
			wubsConsoleDisable();
			exit
		}
	#endregion
	
	#region command Add
		if (_thisCommand="add") or (_thisCommand="sum"){
			var _a=real(_arguments[| 0])
			var _b=real(_arguments[| 1])
			wubsConsoleAddLog(string(_a+_b));
			exit
		}
	#endregion
	
	#region command sub
		if (_thisCommand="sub"){
			var _a=real(_arguments[| 0])
			var _b=real(_arguments[| 1])
			wubsConsoleAddLog(string(_a-_b));
			exit
		}
	#endregion
	
	#region command multiply
		if (_thisCommand="mult"){
			var _a=real(_arguments[| 0])
			var _b=real(_arguments[| 1])
			wubsConsoleAddLog(string(_a*_b));
			exit
		}
	#endregion
	
	#region command divide
		if (_thisCommand="div"){
			var _a=real(_arguments[| 0])
			var _b=real(_arguments[| 1])
			wubsConsoleAddLog(string(_a/_b));
			exit
		}
	#endregion
	
	#region command fps
		if (_thisCommand="fps"){
			wubsConsoleAddLog("fps: "+string(fps));
			wubsConsoleAddLog("fps real: "+string(fps_real));
			exit
		}
	#endregion
		
	#region command fullscreen
		if (_thisCommand="fullscreen"){
			window_set_fullscreen(!window_get_fullscreen())
			exit
		}
	#endregion
	
	#region default response
		ds_list_destroy(_arguments)
		wubsConsoleAddLog("&1Unknown command: '&2"+string(_command)+"&1' use '&3help&1' for a list of commands");
	#endregion
	}catch(e){
		show_debug_message(e);
	}
}
	

