#region Macros for Textbox Struct

// Macros that store the numerical values for each bit within the textbox's "flags" variable that are utilized
// by it to achieve some sort of state-based functionality outside of the standard step event state machine.
#macro	TBOX_INFLAG_ADVANCE				0x00000001
#macro	TBOX_INFLAG_TEXT_LOG			0x00000002
#macro	TBOX_INFLAG_LOG_UP				0x00000004
#macro	TBOX_INFLAG_LOG_DOWN			0x00000008
#macro	TBOX_FLAG_ACTIVE				0x00000010
#macro	TBOX_FLAG_WIPE_DATA				0x00000020
#macro	TBOX_FLAG_CLEAR_SURFACE			0x00000040
#macro	TBOX_FLAG_SHOW_NAME				0x00000080
#macro	TBOX_FLAG_LOG_ACTIVE			0x00000100
#macro	TBOX_FLAG_HAS_OPTIONS			0x00000200
#macro	TBOX_FLAG_OPTIONS_ACTIVE		0x00000400

// Macros that condense the checks required for specific states that the textbox must be in for it to process
// certain aspects of the data it is displaying the user, if it is allowed to do that currently to begin with.
#macro	TBOX_WAS_ADVANCE_PRESSED		((flags & TBOX_INFLAG_ADVANCE)		!= 0 && (prevInputFlags & TBOX_INFLAG_ADVANCE)		== 0)
#macro	TBOX_WAS_TEXT_LOG_PRESSED		((flags & TBOX_INFLAG_TEXT_LOG)		!= 0 && (prevInputFlags & TBOX_INFLAG_TEXT_LOG)		== 0)
#macro	TBOX_WAS_LOG_UP_PRESSED			((flags & TBOX_INFLAG_LOG_UP)		!= 0 && (prevInputFlags & TBOX_INFLAG_LOG_UP)		== 0)
#macro	TBOX_WAS_LOG_DOWN_PRESSED		((flags & TBOX_INFLAG_LOG_DOWN)		!= 0 && (prevInputFlags & TBOX_INFLAG_LOG_DOWN)		== 0)
#macro	TBOX_IS_ACTIVE					((flags & TBOX_FLAG_ACTIVE)			!= 0)
#macro	TBOX_CAN_WIPE_DATA				((flags & TBOX_FLAG_WIPE_DATA)		!= 0)
#macro	TBOX_SHOULD_CLEAR_SURFACE		((flags & TBOX_FLAG_CLEAR_SURFACE)	!= 0)
#macro	TBOX_SHOULD_SHOW_NAME			((flags & TBOX_FLAG_SHOW_NAME)		!= 0)
#macro	TBOX_IS_LOG_ACTIVE				((flags & TBOX_FLAG_LOG_ACTIVE)		!= 0)
#macro	TBOX_HAS_OPTIONS				((flags & TBOX_FLAG_HAS_OPTIONS)	!= 0)
#macro	TBOX_IS_OPTIONS_ACTIVE			((flags & TBOX_FLAG_OPTIONS_ACTIVE)	!= 0)

// The value the textbox is looking for within its "nextIndex" variable so it knows it can deactivate itself.
// This value is then reset to 0 after the deactivation is completed.
#macro	TBOX_INDEX_CLOSE			   -1

// Index values that point to an actor's name as a string within the game's data. Can be retrieved for use by
// calling the function get_actor_name.
#macro	TBOX_ACTOR_INVALID				0
#macro	TBOX_ACTOR_PLAYER				1

// Two macros that determine the size of the textbox's text surface along the x and y axis, respectively. The
// actual textbox's dimensions will be larger than this since this surface is only one part of the textbox.
#macro	TBOX_SURFACE_WIDTH				280
#macro	TBOX_SURFACE_HEIGHT				25

// Determines the total number of lines a textbox can display wihtin a single box. Any text that exceeds this
// amount after formatting will simply be discarded from what will be displayed.
#macro	TBOX_MAX_LINES_PER_BOX			3

// Macros for the characteristics of the textbox's background texture that the text surface will be drawn onto.
// They represent the width, height, and opacity/alpha value of said background, respectively.
#macro	TBOX_BG_X_OFFSET				0
#macro	TBOX_BG_Y_OFFSET				8
#macro	TBOX_BG_WIDTH					TBOX_SURFACE_WIDTH + 20
#macro	TBOX_BG_HEIGHT					42

// The pixel offsets from the current x/y position of the textbox that the text contents will be rendered at.
// The shadow for the text is offset one to the left and down to create a simple drop shadow effect on the text.
#macro	TBOX_TEXT_X_OFFSET				10
#macro	TBOX_TEXT_Y_OFFSET				16

// Constants for the x and y position of the textbox's advance arrow indicator which appears when the current 
// text to display has completely typed itself out onto the main textbox window.
#macro	TBOX_ARROW_X_OFFSET				TBOX_BG_X_OFFSET + TBOX_BG_WIDTH - 14
#macro	TBOX_ARROW_Y_OFFSET				TBOX_BG_Y_OFFSET + TBOX_BG_HEIGHT - 9

// Determines how many pixels the arrow's offset/timer will roughly move in 1/60th of a second.
#macro	TBOX_ARROW_MOVE_SPEED			0.07

// Determines the opacity levels for the text as well as its drop shadow.
#macro	TBOX_TEXT_ALPHA					1.0

// Determines how much additional time is applied to the "wait" timer during the textbox's text typing process
// whenever a given punctuation character has been hit.
#macro	TBOX_PUNCT_NONE					1.0
#macro	TBOX_PUNCT_COMMA_DELAY			0.175
#macro	TBOX_PUNCT_COLON_DELAY			0.125
#macro	TBOX_PUNCT_SEMICOLON_DELAY		0.15
#macro	TBOX_PUNCT_PERIOD_DELAY			0.1
#macro	TBOX_PUNCT_QUESTION_DELAY		0.09
#macro	TBOX_PUNCT_EXCLAIM_DELAY		0.075

// Determines the position on the GUI the textbox will begin the opening animation at.
#macro	TBOX_Y_START					VIEWPORT_HEIGHT + 30

// Determines the position on the GUI the textbox will rest at after its opening transition has completed.
#macro	TBOX_Y_TARGET					VIEWPORT_HEIGHT - 64

// Macros for the characteristics of the opening and closing animations; denoted as such by containing either
// "OANIM" for opening, and "CANIM" for closing, respectively
#macro	TBOX_OANIM_MOVE_SPEED			0.2
#macro	TBOX_OANIM_ALPHA_SPEED			0.05
#macro	TBOX_CANIM_ALPHA_SPEED			0.08

// The macro for the unique key used to store the control icon group for the textox input information.
#macro	TBOX_ICONUI_CTRL_GRP			"tbox_icons"

// Determines where the control group's anchor point is placed relative to the bottom-right of the GUI (These 
// values are subtracted against the GUI's width and height).
#macro	TBOX_CTRL_GRP_XOFFSET			5
#macro	TBOX_CTRL_GRP_YOFFSET			12

// Determines the value that the arrow's current offset needs to be exceed for it to be reset to zero (Or 
// near-zero if the value happens to not be exactly the same as this threshold value).
#macro	TBOX_ARROW_OFFSET_THRESHOLD		2.0

// Parameters for the textbox's character typing animation. They determine how often it is played, how loud
// it is, how pitch-shifted it is relative to its default pitch, and the random variance that is applied to
// the volume/gain and pitch of the current playback of the sound.
#macro	TBOX_SND_TYPE_PLAY_INTERVAL		3.8
#macro	TBOX_SND_TYPE_GAIN				0.05
#macro	TBOX_SND_TYPE_PITCH				1.0
#macro	TBOX_SND_TYPE_GAIN_RANGE		0.02
#macro	TBOX_SND_TYPE_PITCH_RANGE		0.04

#endregion Macros for Textbox Struct

#region Textbox Struct Definition

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_textbox(_index) : str_base(_index) constructor {
	flags				= STR_FLAG_PERSISTENT;
	
	// The current position of the textbox on the game's GUI layer. Determines where everything is drawn as
	// this coordinate will determine the top-left position of the entire textbox when drawn to the screen.
	x					= 0;
	y					= 0;
	
	// Determines the overall transparency level for every graphics element of the textbox.
	alpha				= 0.0;
	
	// State variables that function exactly like how they do when an entity utilizes them; processing a single
	// function that represents the current state of the object; allowing them to move to other states as required
	// during that initial state's output.
	curState			= 0;
	nextState			= 0;
	lastState			= 0;
	
	// The surface that the current textbox's text will be drawn to, and the buffer that will store a copy of
	// that data in memory in case the surface gets flushed from the GPU.
	textSurface			= -1;
	surfBuffer			= buffer_create(TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4, buffer_fixed, 4);
	
	// Variable relating to the text content data structure. They store the list itself, the current index
	// and next index as determined by the current index's data, and the length of the string found within the
	// current index's data.
	textData			= ds_list_create();
	textIndex			= TBOX_INDEX_CLOSE;
	nextIndex			= TBOX_INDEX_CLOSE;
	textLength			= 0;

	// Stores the string that represents the name of the actor that is speaking in the current textbox. Can
	// only be shown if the flag bit within the flags variable is set as well.
	actorName			= "";
	
	// Stores the toggled and not toggled input flags from the previous frame so the input can be checked to
	// see if it was pressed or not by the player.
	prevInputFlags		= 0;
	
	// Variables relating to which character(s) will be drawn and where they will be drawn on the textbox's
	// text surface when performing the "typing" animation.
	curChar				= 1;
	nextChar			= 1;
	charX				= 0;
	charY				= 0;
	nextCharDelay		= TBOX_PUNCT_NONE;
	
	// Counts down until the value goes below zero. When that happens, the counter is reset and the sound is
	// played alongside the textbox's typing animation.
	sndCharTypeTimer	= 0.0;
	
	// Variables that allow the textbox to reference the current color data for the text that is being typed
	// onto the textbox; allowing each individual character to be a unique color compared to the default white.
	colorDataRef		= -1;
	totalColors			= 0;
	charColorIndex		= 0;
	
	// Acts as both the positional offset and the timer that resets that interval back to zero when it hits
	// the limit value of two; allowing the arrow to bob up and down by one pixel as a simple aniamtion.
	advArrowOffset		= 0.0;

	// Stores a reference to the control icon group that displays input information for the textbox.
	tboxCtrlGroup		= REF_INVALID;

	// 
	optionMenu			= noone;
	optionDataRef		= REF_INVALID;

	/// @description 
	///	The textbox struct's create event. It will simply initialize the control icon group that will be drawn
	/// whenever the textbox is actively being rendered onto the screen.
	///	
	create_event = function(){
		if (room != rm_init)
			return; // Prevents a call to this function from executing outside of the game's initialization.

		// Determine the starting position of the textbox. The x position will remain constant, but the y 
		// value will change during the opening animation; going from the position set below to the value 
		// found in the constant "TBOX_Y_TARGET".
		x = floor((VIEWPORT_WIDTH - TBOX_BG_WIDTH) / 2) - 20; // Offset by 20 to account for the space between the background and the GUI's size.  
		y = VIEWPORT_HEIGHT + 30; // The same value as "TBOX_Y_START" but utilizing the fact the height was stored locally previously.
		
		// Copy the x value of the text so the visible logs are in the same relative area horizontally on the
		// game's screen. The value never changes hence why it is copied after initially being set.
		var _x = x;
		with(TEXTBOX_LOG) { textX = _x; }
		
		// Finally, setup the control group that will be utilized by the Textbox and calculate the positions
		// of the icons and their descriptors so they're displayed at the proper offset. Then, set the
		// textbox's reference to its control group so it can be referenced for drawing the group when needed.
		var _tboxCtrlGroup = REF_INVALID;
		with(CONTROL_UI_MANAGER){
			_tboxCtrlGroup = create_control_group(TBOX_ICONUI_CTRL_GRP, VIEWPORT_WIDTH - TBOX_CTRL_GRP_XOFFSET, 
				VIEWPORT_HEIGHT - TBOX_CTRL_GRP_YOFFSET, 3, ICONUI_DRAW_LEFT);
			add_control_group_icon(_tboxCtrlGroup, ICONUI_TBOX_ADVANCE, "Next");
			add_control_group_icon(_tboxCtrlGroup, ICONUI_TBOX_LOG, "Log");
		}
		tboxCtrlGroup = _tboxCtrlGroup;
	}

	/// @description 
	///	The textbox struct's destroy event. It will clean up anything that isn't automatically cleaned up by
	/// GameMaker when this struct is destroyed/out of scope.
	///	
	destroy_event = function(){
		if (surface_exists(textSurface)) 
			surface_free(textSurface);
		buffer_delete(surfBuffer);
		
		deactivate_textbox();
		ds_list_destroy(textData);
	}
	
	/// @description 
	///	Called to render the textbox and its current contents whenever the textbox struct is currently showing
	/// information that has been queued up for the player to see.
	///	
	///	@param {Real}	viewX		X position of the viewport within the current room.
	/// @parma {Real}	viewY		Y position of the viewport within the current room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_gui_event = function(_viewX, _viewY, _delta){
		// Ensures that the surface will be valid should it randomly be flushed from memory by the GPU. Then,
		// the previous surface's contents are copied from their buffer onto the newly formed surface.
		if (!surface_exists(textSurface)){
			textSurface = surface_create(TBOX_SURFACE_WIDTH, TBOX_SURFACE_HEIGHT);
			buffer_set_surface(surfBuffer, textSurface, 0);
		}
		
		// When toggled, this flag allows the surface to be completely wiped of any contents as required.
		// This will leave the surface completely empty so new content can populate it.
		if (TBOX_SHOULD_CLEAR_SURFACE){
			flags = flags & ~TBOX_FLAG_CLEAR_SURFACE;
			surface_set_target(textSurface);
			draw_clear_alpha(COLOR_BLACK, 0.0);
			surface_reset_target();
		}
		
		// Adding new characters to the text surface of the current textbox whenever the value of curChar (The
		// value that represents how many characters have been drawn) is less than _nextChar and the textbox
		// is currently considered active. Otherwise, this block of code is skipped.
		var _nextCharIndex = floor(nextChar);
		if (TBOX_IS_ACTIVE && curChar < _nextCharIndex){
			surface_set_target(textSurface);
			
			// Reset the punctuation delay so the next group of characters isn't also added to the surface with
			// the delay of the last found punctuation character.
			nextCharDelay = TBOX_PUNCT_NONE;
			
			// Set the font outside of the loop since all text drawn shares the same one. Also set the alpha
			// value to 1.0 to ensure the text won't accidentally be drawn onto the surface with transparency.
			// Finally, set the alignment to the top-left which is the default in case it has been changed.
			draw_set_font(fnt_small);
			draw_set_alpha(1.0);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			
			// Grab a reference to the current textbox's contents and then begin adding characters to the text
			// surface one at a time until the value of curChar matches that of _nextChar.
			var _curText		= textData[| textIndex].content;
			var _curCharIndex	= curChar;
			var _charColorIndex	= charColorIndex;
			var _curChar		= "";
			var _colorData		= -1;
			var _curColor		= COLOR_WHITE;
			while(curChar < _nextCharIndex){
				_curChar		= string_char_at(_curText, curChar);
				_curCharIndex	= curChar; // Store for later use.
				
				// Check if any unique colors should be used for the text currently being added to the screen.
				// This entire chunk of code is ignored if the textbox doesn't have any additional color data
				// associated with it.
				if (colorDataRef != -1 && charColorIndex < totalColors){
					with(colorDataRef[| charColorIndex]){
						if (_curCharIndex >= endIndex){ // The final index is hit; reset to color white and move to the next potential color.
							_curColor = COLOR_WHITE;
							_charColorIndex++; 
						} else if (_curCharIndex >= startIndex){ // Apply the desired color for the region of text.
							_curColor = colorCode;
						}
					}
					charColorIndex = _charColorIndex;
				}
				curChar++; // Only increment after the color code index has been checked.
				
				// Space character found; offset the x character by how wide the space character is within the
				// font being used, and then move onto the next character if punctuation isn't found.
				if (_curChar == CHAR_SPACE){
					charX += string_width(CHAR_SPACE);
					// Get the previous character to see if it is punctuation and exit the loop if so.
					if (check_for_punctuation(_curText, _curCharIndex - 1))
						break;
					continue;
				}
				
				// Newline character found; the x offset of the character is reset and the y value if offset
				// to create a new line of text on the surface instead of writing on top of the previous one.
				// The loop exits early if valid punctuation was found before this character.
				if (_curChar == CHAR_NEWLINE){
					charX	= 0;
					charY  += string_height("M");
					// Get the previous character to see if it is punctuation and exit the loop if so.
					if (check_for_punctuation(_curText, _curCharIndex - 1))
						break;
					continue;
				}
				
				// Once the proper coordinates have been set as required, the character is drawn and the width
				// of the drawn character is added to properly offset the next character in the string.
				draw_text_shadow(charX, charY, _curChar, _curColor, TBOX_TEXT_ALPHA, COLOR_GRAY);
				charX += string_width(_curChar);
			}
			
			// Finally, the surface target is reset to that of the application surface, and the current contents 
			// of the text surface are captured and stored in their buffer should the GPU flush it.
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurface, 0);
		}
		
		// Display the background contents of the textbox, which includes the background that is always shown
		// behind the text being displayed, and an arrow that shows up once it is possible to advance to the
		// next chunk of text or close the texxtbox.
		draw_sprite_stretched_ext(spr_tbox_background, 0, 
			x + _viewX + TBOX_BG_X_OFFSET, 
			y + _viewY + TBOX_BG_Y_OFFSET, 
			TBOX_BG_WIDTH, TBOX_BG_HEIGHT, COLOR_TRUE_WHITE, alpha
		);

		// Simply draw the currently rendered text onto the screen with this single draw call.
		draw_surface_ext(textSurface, x + _viewX + TBOX_TEXT_X_OFFSET, y + _viewY + TBOX_TEXT_Y_OFFSET, 
			1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha);
		
		// Elements that will not be rendered until the textbox has finished typing out all the required
		// characters for the textbox onto the screen.
		if (curChar == textLength){
			if (!TBOX_HAS_OPTIONS){
				// Display the advance indicator at the bottom-right of the textbox window relative to the 
				// value of the offset timer/value with the fraction component removed. 
				draw_sprite_ext(spr_tbox_advance_indicator, 0, 
					x + _viewX + TBOX_ARROW_X_OFFSET, 
					y + _viewY + TBOX_ARROW_Y_OFFSET + floor(advArrowOffset),
					1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha
				);
			
				// Increment the value until it reaches 2.0 or higher, and then reduce it by two to bring it 
				// back to zero; allowing the arrow to bob up and down rhythmically on screen.
				advArrowOffset += TBOX_ARROW_MOVE_SPEED * _delta;
				if (advArrowOffset > TBOX_ARROW_OFFSET_THRESHOLD)
					advArrowOffset -= TBOX_ARROW_OFFSET_THRESHOLD;
			} else{
				// When the textbox has options associated with it, the menu responsible for those options 
				// will be drawn instead of the advancement indicator.
				with(optionMenu)
					draw_gui_event(x + _viewX, y + _viewY, COLOR_DARK_GRAY);
			}
		}
		
		#region Rendering Control UI to Screen
		
			// Draw a black background with a nice alpha gradient applied to it. This will be found behind the 
			// control information for the textbox, but in front of all elements; causing the textbox to slide in
			// from behind this element during its opening animation.
			var _alpha = alpha;
			with(global.colorFadeShader){
				activate_shader(COLOR_BLACK);
				draw_circle_ext(
					_viewX + (VIEWPORT_WIDTH / 2), _viewY + VIEWPORT_HEIGHT, 
					300.0, 30.0, 
					COLOR_WHITE, COLOR_BLACK, 
					_alpha
				);
				shader_reset();
			}
		
			// Don't display the control UI information for the textbox if the player is currently viewing the 
			// textbox's history log.
			if (TBOX_IS_LOG_ACTIVE)
				return;
		
			// After rendering the textbox and all its required elements, the control icon group for the textbox 
			// will be drawn at their calculated positions. The color of the text (Both it and the drop shadow)
			// are set to match the default color for text within the textbox.
			var _tboxCtrlGroup = tboxCtrlGroup;
			with(CONTROL_UI_MANAGER)
				draw_control_group(_tboxCtrlGroup, _viewX, _viewY, _alpha, 
					COLOR_WHITE, COLOR_DARK_GRAY, _alpha); 
		
		#endregion Rendering Control UI to Screen
	}
	
	/// @description 
	/// Captures the user's input for the current frame. Instead of storing the current input flags in their
	/// own dedicated variable, they're placed within the default "flags" variable since there is plenty of
	/// room for the four user inputs required for the textbox and its log to function. The previous frame's 
	/// inputs are still stored in the standard "prevInputFlags" variable.
	/// 
	process_input = function(){
		prevInputFlags	= flags &  (TBOX_INFLAG_ADVANCE | TBOX_INFLAG_TEXT_LOG | TBOX_INFLAG_LOG_UP | TBOX_INFLAG_LOG_DOWN);
		flags		    = flags & ~(TBOX_INFLAG_ADVANCE | TBOX_INFLAG_TEXT_LOG | TBOX_INFLAG_LOG_UP | TBOX_INFLAG_LOG_DOWN);
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			flags = flags | (MENU_PAD_TBOX_ADVANCE		); // Offset based on position of the bit within the variable.
			flags = flags | (MENU_PAD_TBOX_LOG		<< 1);
			flags = flags | (MENU_PAD_UP			<< 2);
			flags = flags | (MENU_PAD_DOWN			<< 3);
			return;
		}
		
		flags = flags | (MENU_KEY_TBOX_ADVANCE		); // Offset based on position of the bit within the variable.
		flags = flags | (MENU_KEY_TBOX_LOG		<< 1);
		flags = flags | (MENU_KEY_UP			<< 2);
		flags = flags | (MENU_KEY_DOWN			<< 3);
	}
	
	/// @description 
	///	Activates the textbox so long as two major factors have been met: the textbox isn't currently toggled
	/// to "active" wihtin its flags variable and the starting index is within the valid range of 0 to what the
	/// size of the data structure (AKA the total number of text elements to show to the user).
	///	
	///	@param {Real}	startingIndex				(Optional) Determines which text out of the list is used as the first in the textbox. The default value is zero.
	/// @param {Bool}	clearDataOnDeactivation		(Optional) Determines if the contents within textData are deleted after the textbox closes down. The default flag is true.
	activate_textbox = function(_startingIndex = 0, _clearDataOnDeactivation = true){
		var _size = ds_list_size(textData);
		if (TBOX_IS_ACTIVE || _size == 0 || _size <= _startingIndex)
			return;
		global.flags = global.flags | GAME_FLAG_TEXTBOX_OPEN;
		
		// Attempt to pause the player object. If a cutscene is currently occurring, this code does nothing
		// to the player object and whatever their state may currently be because of said cutscene.
		with(PLAYER) { pause_player(); }
		
		// Set the default flags that are toggled upon activation of the textbox. Then, if required, the flag
		// will be set to true that all data will be cleared on deactivation of the textbox.
		flags = flags | TBOX_FLAG_ACTIVE; // Surface clearing flag is set within "set_textbox_index".
		if (_clearDataOnDeactivation)
			flags = flags | TBOX_FLAG_WIPE_DATA;
		
		// Finally, start the opening animation, assign the textbox's index to what was passed into this first
		// function's argument parameter, and set the y position of the textbox to what is needed for the 
		// opening animation to look correct.
		object_set_state(state_open_animation);
		set_textbox_index(_startingIndex);
	}
	
	/// @description
	///	Deactivates the textbox by clearing its "active" flag. Optionally, it will remove any data found within
	/// "textData" should the flag to allow that process to occur be set. Otherwise, the data will remain until
	/// setting that flag upon the next time this funciton's called.
	///	
	deactivate_textbox = function(){
		object_set_state(STATE_NONE);
		flags		    = flags & ~TBOX_FLAG_ACTIVE;
		global.flags    = global.flags & ~GAME_FLAG_TEXTBOX_OPEN;
		
		// 
		instance_destroy_menu_struct(optionMenu);
		optionMenu		= noone;
		optionDataRef	= REF_INVALID;
		
		if (!TBOX_CAN_WIPE_DATA) // Prevent deleting any text information if the flag isn't toggled.
			return;
		flags = flags & ~TBOX_FLAG_WIPE_DATA;
		
		// Loop through and clear out the structs from within the textData data structures. All now undefined
		// references will also be cleared and the structure is set back to a size of 0.
		var _length = ds_list_size(textData);
		for (var i = 0; i < _length; i++){
			with(textData[| i]){ // Make sure color data structs are removed should any exist for the current textbox.
				if (ds_exists(colorData, ds_type_list)){
					var _dataLength = ds_list_size(colorData);
					for (var ii = 0; ii < _dataLength; ii++)
						delete colorData[| ii];
					ds_list_destroy(colorData);
				}
				
				if (ds_exists(optionData, ds_type_list)){
					var _dataLength = ds_list_size(optionData);
					for (var ii = 0; ii < _dataLength; ii++)
						delete optionData[| ii];
					ds_list_destroy(optionData);
				}
			}
			delete textData[| i];
		}
		ds_list_clear(textData);
	}
	
	/// @description 
	///	Sets the textbox to begin displaying another data's contents to the player. It toggles the flag to
	/// automatically clear the previous data, captures the data for the next textbox index and any data needed
	/// by the textbox itself, as well as resets variables that are used for drawing characters onto the text
	/// surface of the textbox.
	///	
	/// @param {Real}	index	The index within the textbox data to use for the displayed textbox.
	set_textbox_index = function(_index){
		// Format and parse the text before anything below is executed. If the function fails for whatever
		// reason, it will return "noone" which will then close the textbox.
		var _textData = process_text_to_show(_index);
		if (_textData == noone){
			object_set_state(state_close_animation);
			textIndex = TBOX_INDEX_CLOSE;
			return;
		}
		
		// Copy over all the data required from the text data contained at the index provided for this function
		// within the textbox's current queue of text data.
		var _textLength		= 0;
		var _newActorIndex	= TBOX_ACTOR_INVALID;
		var _nextIndex		= TBOX_INDEX_CLOSE;
		var _colorData		= -1;
		var _optionData		= -1;
		with(_textData){
			_textLength		= string_length(content) + 1;
			_newActorIndex	= actorIndex;
			_nextIndex		= nextIndex;
			_colorData		= colorData;
			_optionData		= optionData;
		}
		
		// 
		if (textIndex != TBOX_INDEX_CLOSE){
			// 
			var _prevTextData = textData[| textIndex];
			with(TEXTBOX_LOG) { queue_new_text(_prevTextData); }
			
			// 
			var _prevActorIndex	= textData[| textIndex].actorIndex;
			if (_prevActorIndex != _newActorIndex)
				object_set_state(state_close_animation);
		}
			
		flags		    = (flags | TBOX_FLAG_CLEAR_SURFACE) & ~(TBOX_FLAG_SHOW_NAME | TBOX_FLAG_HAS_OPTIONS);
		textLength		= _textLength;
		textIndex		= _index;
		nextIndex		= _nextIndex;
		actorName		= get_actor_name(_newActorIndex);
		curChar			= 1;	// Reset these to their defaults so the typing animation can play again.
		nextChar		= 1;
		sndScrollTimer	= 0.0;
		charX			= 0;
		charY			= 0;
		colorDataRef	= _colorData;	// Overwrite the previous ds_list reference with either -1 or the new textbox's color list.
		totalColors		= (colorDataRef == -1) ? 0 : ds_list_size(colorDataRef);
		charColorIndex	= 0;
		optionDataRef	= _optionData;
		
		// Set additional flag bits if any of these checks return true.
		if (actorName != "")	 { flags = flags | TBOX_FLAG_SHOW_NAME; }
		if (optionDataRef != -1) { flags = flags | TBOX_FLAG_HAS_OPTIONS; }
	}
	
	/// @description 
	///	Adds another element to the textData data structure for the textbox to utilize when set to view its
	/// contents.
	///	
	///	@param {String}	text		The text to format and enqueue for the textbox to display when ready.
	/// @param {Real}	actorIndex	(Optional) If set to a value greater than 0, the actor's name relative to the index will be shown.
	///	@param {Real}	nextIndex	(Optional) Determines which textbox out of the current data is after this one.
	queue_new_text = function(_text, _actorIndex = 0, _nextIndex = -1){
		if (_text == "") // Don't attempt to add empty text to the queue.
			return noone;
			
		var _textData = {
			// Main variables for what will be shown and how it will be shown on that textbox when this data 
			// is utilized.
			content		: _text,
			colorData	: -1,
			actorIndex	: _actorIndex,
			
			// Determines the next textbox to display from the queue of data if there are no options contained
			// within the "optionData" variable below. Otherwise, those will trigger a choice to be made by the
			// user.
			nextIndex	: _nextIndex == -1 ? ds_list_size(textData) + 1 : _nextIndex,
			
			// Main variables for decision data that can be optionally added to a textbox. By default, it will
			// be set to -1 to not bloat non-decision textboxes, and will store a ds_list of option data should
			// decisions be utilized by the textbox.
			optionData	: -1,
			
			// When true, the textbox will know it no longer needs to try and parsed the text, as it has already
			// been parsed when it was first viewed by the player.
			isParsed	: false,
		};
		
		ds_list_add(textData, _textData);
		return _textData;
	}
	
	/// @description 
	///	Adds a set of options to the provided struct of data containing a textbox's information that is
	/// currently found in the textbox struct's queue. If an list of options already exists for the provided
	/// data, the newly provided arrays will be ignored to prevent overwriting the old data and the function
	/// will return without processing anything.
	///	
	/// @param {Struct._structRef}	textData		The text data from the textbox that these options will be tied to.
	/// @param {Array<String>}		options			Array of strings that represent the available options to the player.
	///	@param {Array<Array<Any>>}	selectParams	An array of arrays that contain functions alongside their parameters that should be executed when an option is selected.
	add_options = function(_textData, _options, _selectParams){
		if (!is_array(_options)) // Don't attempt to add invalidly formatted options.
			return;
		
		with(_textData){
			if (ds_exists(optionData, ds_type_list)) // Don't overwrite already existing options.
				return;
			optionData = ds_list_create();
			
			// Loop through all options and add them to the textbox's option data list as structs containing
			// the option's name which is shown to the player, and the parameters required for that option if
			// they are selected by the player.
			var _length = array_length(_options);
			for (var i = 0; i < _length; i++){
				ds_list_add(optionData, {
					oName			: _options[i],
					selectParams	: _selectParams[i],
				});
			}
		}
	}
	
	/// @description 
	///	The function that is responsible for actually parsing the data and formatting itself to meet the
	/// requirements of the textbox. This means only one chunk of text is parsed per textbox shown instead
	/// of every texxtbox being parsed and formatted immediately when the textbox is activated.
	///	
	/// @param {Real}	index	The text data to process since it will be shown soon or immediately.
	process_text_to_show = function(_index){
		// Don't bother considering an index that exists outside the bounds of the current amount of text data.
		if (_index < 0 || _index >= ds_list_size(textData))
			return noone;
		
		// Jump into the struct containing the data we want, and parse out any color information alongside the
		// text that is then formatted to contain itself within the bounds of the textbox's available space.
		var _textData = textData[| _index];
		with(_textData){
			if (isParsed) // No need to parse text that is already parsed and formatted; exit the function.
				return _textData;
			isParsed = true;
			
			var _parsedData = string_parse_color_data(content);
			content			= string_split_lines(_parsedData.fullText, fnt_small, 
								TBOX_SURFACE_WIDTH, TBOX_MAX_LINES_PER_BOX);
			colorData		= _parsedData.colorData;
			delete _parsedData;
		}
		return _textData;
	}
	
	/// @description
	///	Simply returns a string representing the textbox's current speaker/actor. If the value isn't found,
	/// an empty string will be returned to signify no name should be show for the currently visible textbox.
	///	
	///	@param {Real}	actorIndex	A numerical value that links to a character's name or an empty string.
	get_actor_name = function(_actorIndex){
		switch(_actorIndex){
			default:
			case TBOX_ACTOR_INVALID:		return "";
			case TBOX_ACTOR_PLAYER:			return "Claire";
		}
	}
	
	/// @description 
	/// Checks to see if the current character is a valid piece of punctuation or not. If it is, a unique delay
	/// is applied relative to the punctuation character it happens to be, and it not the standard delay will
	/// be applied between this and the next character appearing within the textbox.
	///
	///	@param {String}		curText		The text that is referenced during the punctuation check.
	/// @param {Real}		index		Position within the string to check for a punctuation character.
	check_for_punctuation = function(_curText, _index){
		// Ignore this function is the first character in the text is a space or newline character.
		if (_index == 0 || _index > textLength) 
			return false;
		
		// Get the previous character and see if it is considered punctuation.
		var _char = string_char_at(_curText, _index);
		if (is_punctuation(_char)){ // Apply delay to next character if punctuation was found.
			nextCharDelay = determine_punctuation_delay(_char);
			return true;
		}
		
		// No punctuation was found; reset the punctuation delay factor.
		nextCharDelay = TBOX_PUNCT_NONE;
		return false;
	}
	
	/// @description 
	/// Determines if the character passed into this function's parameter is punctuation or not. This will cause
	/// a unique delay to the time it will take for the next character to be added to the current text surface.
	///	If the character isn't what the function considers punctuation, the delay is nullified as a value of 1.0.	
	///
	/// @param {String}		char	The character to check for if it is punctuation.
	determine_punctuation_delay = function(_char){
		if (_char == CHAR_COMMA)		{ return TBOX_PUNCT_COMMA_DELAY; }
		if (_char == CHAR_COLON)		{ return TBOX_PUNCT_COLON_DELAY; }
		if (_char == CHAR_SEMICOLON)	{ return TBOX_PUNCT_SEMICOLON_DELAY; }
		if (_char == CHAR_PERIOD)		{ return TBOX_PUNCT_PERIOD_DELAY; }
		if (_char == CHAR_QUESTION)		{ return TBOX_PUNCT_QUESTION_DELAY; }
		if (_char == CHAR_EXCLAIM)		{ return TBOX_PUNCT_EXCLAIM_DELAY; }
		
		// No punctuation has been found; return the default factor of 1.0 (No change to text speed).
		return TBOX_PUNCT_NONE;
	}
	
	/// @description 
	/// 
	/// 
	close_current_textbox = function(){	
		// Close the textbox if the next index is less than 0, equal to the current index, or outside
		// of the valid bounds of textbox data indices.
		if (nextIndex < 0 && nextIndex == textIndex || nextIndex >= ds_list_size(textData)){
			object_set_state(state_close_animation);
			textIndex = TBOX_INDEX_CLOSE;
			return;
		}
		set_textbox_index(nextIndex);
	}
	
	/// @description 
	/// The textbox's main state. It allows the player to skip over the textbox's typing animation with an
	/// early press of the advance text input, and will also allow them to move onto the next textbox by
	/// pressing that same key so long as all the text for the current textbox is visible to them.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		process_input();
		
		// When the text log input is pressed, the process for opening that log is set to execute from the
		// next frame onward. The flag that tells the textbox if the log is open or not is set to prevent
		// certain parts of the textbox from rendering while it is open.
		if (TBOX_WAS_TEXT_LOG_PRESSED){
			object_set_state(state_open_log_animation);
			flags = flags | TBOX_FLAG_LOG_ACTIVE;
			return;
		}
		
		// 
		if (nextChar < textLength){
			// Calculate the "amount" of change during the previous frame and this one. This will then be used 
			// to increment the character typing sound's timer and the character typing animation "timer" that 
			// goes alongside said sound.
			var _amount = nextCharDelay * _delta;
			sndCharTypeTimer -= _amount;
			if (sndCharTypeTimer <= 0.0){ // Play the sound and reset its playback timer.
				sndCharTypeTimer += TBOX_SND_TYPE_PLAY_INTERVAL;
				sound_effect_play_ext(snd_textbox_type, STNG_AUDIO_MENU_SOUNDS, TBOX_SND_TYPE_GAIN, 1.0, 0, true, false,
					TBOX_SND_TYPE_GAIN_RANGE, TBOX_SND_TYPE_PITCH_RANGE);
			}
			
			// Increment the nextChar variable by the amount calculated above. If that amount exceeds the length
			// of the text being shown (Or the player pressed the advance input during the process), the text
			// will be completely visible and will no longer need this value to count up.
			nextChar += _amount;
			if (TBOX_WAS_ADVANCE_PRESSED || nextChar > textLength){
				nextChar		= textLength;
				nextCharDelay	= TBOX_PUNCT_NONE;
			}
			return;
		}

		// 
		if (TBOX_HAS_OPTIONS){
			object_set_state(state_open_options_animation);
			flags = flags | TBOX_FLAG_OPTIONS_ACTIVE;
			
			// 
			draw_set_font(fnt_small); // Set for accurate string width calculation.
			var _length		= ds_list_size(optionDataRef);
			var _options	= array_create(_length, "");
			var _oWidth		= 0;
			var _maxWidth	= 0;
			for (var i = 0; i < _length; i++){
				_options[i] = optionDataRef[| i].oName;
				_oWidth		= string_width(_options[i]);
				if (_oWidth > _maxWidth || _maxWidth == 0)
					_maxWidth = _oWidth;
			}
			
			// 
			var _yy = y;
			with(optionMenu){
				replace_options(_options, 1, 1, _length);
				flags			= (flags | MENU_FLAG_ACTIVE) & ~MENUSUB_FLAG_CLOSING;
				contentWidth	= _maxWidth;
				contentHeight	= optionSpacingY * _length;
				x				= TBOXMENU_XSTART;
				y				= _yy - contentHeight;
			}
			
			// 
			if (optionMenu == noone){
				optionMenu = create_sub_menu(str_textbox_options_menu, noone, TBOXMENU_XSTART, y, _options, 1, 1, _length);
				with(optionMenu){
					flags			= flags & ~MENUSUB_FLAG_CAN_CLOSE;
					contentWidth	= _maxWidth;
					contentHeight	= optionSpacingY * _length;
					y			   -= contentHeight; 
				}
			}
			return;
		}
		
		// Under normal circumstances, the advance input will be what moves the textbox to the next piece
		// of data within its queue to display to the player. This can only occur once all the text for the
		// current textbox has been shown to them.
		if (TBOX_WAS_ADVANCE_PRESSED)
			close_current_textbox();
	}
	
	/// @description 
	/// Executes the opening animation for the textbox, which fades it into visiblity on the GUI layer while
	/// also smoothly shifting the textbox upward from the bottom of the screen. Once the target y position
	/// is reached AND the alpha is set to 1.0, the opening animation will be considered complete.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_animation = function(_delta){
		// Give the player control over the textbox by shifting into its default state function. This state 
		// is also responsible for "typing" the characters onto the textbox until they're all shown.
		if (alpha == 1.0 && y <= TBOX_Y_TARGET){
			object_set_state(state_default);
			y = TBOX_Y_TARGET;
			return;
		}
		
		// Fades the entire textbox into full visiblity.
		if (alpha < 1.0){
			alpha += TBOX_OANIM_ALPHA_SPEED * _delta;
			if (alpha > 1.0)
				alpha = 1.0;
		}
		
		// Move the y position from where it is initially set below the visible portion of the screen to the
		// desired position set by this opening animation. Snap it to the target position is the distance
		// between the current value and target is small enough.
		if (y != TBOX_Y_TARGET){
			y += (TBOX_Y_TARGET - y) * TBOX_OANIM_MOVE_SPEED * _delta;
			if (point_distance(0, y, 0, TBOX_Y_TARGET) <= ceil(_delta))
				y = TBOX_Y_TARGET;
		}
	}
	
	/// @description 
	/// Executes the closing animation for the textbox, which simply fades it out at a linear rate until it
	/// is completely invisible to the player. Then, it determines whether to deactivate the current textbox
	/// or re-opens it if an actor name change is why the textbox "closed".
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_animation = function(_delta){
		// Repeat the opening animation or deactivate the textbox depending on the current value of nextIndex.
		if (alpha == 0.0){
			y = TBOX_Y_START; // Reset the y position so the textbox opens properly next time.
			if (textIndex < 0 || textIndex >= ds_list_size(textData)){ // Closes the textbox.
				deactivate_textbox();
				textIndex = 0;
				return;
			}
			// Set the textbox to "reopen" itself for the new actor's dialogue.
			object_set_state(state_open_animation);
			return;
		}
		
		// Fades the textbox until it is no longer visible on the screen.
		alpha -= TBOX_CANIM_ALPHA_SPEED * _delta;
		if (alpha <= 0.0) // Prevent the value from going negative.
			alpha = 0.0;
	}
	
	/// @description 
	/// Handles input processing logic for the textbox log. These inputs include shifting up and down through
	/// the log's contents, and the input that causes the log to close.
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_view_log = function(_delta){
		process_input();
		
		// With the highest priority, pressing the textbox log's activation input will cause the log to being
		// its closing process; with this state exiting before any other input can be processed.
		if (TBOX_WAS_TEXT_LOG_PRESSED){
			object_set_state(state_close_log_animation);
			return;
		}
		
		// Determine the movement direction for the textbox log by subtracting the flag bit values for the
		// textbox log up/down inputs. This results in either a -1, 0, or +1 to be calculated; resulting in
		// movement up (-1), down (+1), or nothing (0).
		var _moveDirection = TBOX_WAS_LOG_DOWN_PRESSED - TBOX_WAS_LOG_UP_PRESSED;
		if (_moveDirection == 0)
			return;
		
		with(TEXTBOX_LOG){
			// If there aren't enough pieces of logged text, there is no input required since the entire log
			// can be shown at once, so the logic below is skipped.
			if (logSize <= TBOXLOG_MAXIMUM_VISIBLE)
				return;
			
			// Shifting the textbox log up and down relative to the input calculated in the code above this.
			// When any movement is detected, a re-render is triggered for the log's surfaces, but a re-render
			// isn't triggered if the value for "curOffset" isn't changed by the detected movement.
			var _curOffset = curOffset;
			if (_moveDirection == MENU_MOVEMENT_UP && curOffset >= TBOXLOG_MAXIMUM_VISIBLE - 1){ 
				curOffset--;
				if (curOffset == TBOXLOG_MAXIMUM_VISIBLE - 2)
					curOffset = logSize - 1;
			} else if (_moveDirection == MENU_MOVEMENT_DOWN && curOffset < logSize){
				curOffset++;
				if (curOffset == logSize)
					curOffset = TBOXLOG_MAXIMUM_VISIBLE - 1;
			}
			
			if (_curOffset != curOffset)
				flags = flags | TBOXLOG_FLAG_RENDER;
		}
	}
	
	/// @description 
	/// State that handles the simple fading animation that is used when opening the textbox log. Once the log
	/// has an alpha value of 1.0, the log will be completely closed, and the textbox itself will recind control
	/// so that the textbox log can begin taking input from the user (Which is actually done through the textbox's
	/// "state_view_log" state). 
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_log_animation = function(_delta){
		var _animFinished = false;
		with(TEXTBOX_LOG){
			alpha += _delta * 0.1;
			if (alpha >= 1.0){
				flags			= flags | TBOXLOG_FLAG_ACTIVE;
				alpha			= 1.0;
				_animFinished	= true;
			}
		}
		
		if (_animFinished)
			object_set_state(state_view_log);
	}
	
	/// @descripiton 
	///	State that handles the simple fading animation that is used when closing the textbox log. Once the log
	/// has an alpha value of 0.0, the log will be completely closed, and the textbox itself will reset to its
	/// default state to enable interaction with it once again.
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_log_animation = function(_delta){
		var _animFinished = false;
		with(TEXTBOX_LOG){
			alpha -= _delta * 0.1;
			if (alpha <= 0.0){
				flags			= flags & ~TBOXLOG_FLAG_ACTIVE;
				alpha			= 0.0;
				_animFinished	= true;
			}
		}
		
		if (_animFinished){
			if (!TBOX_IS_OPTIONS_ACTIVE){ // Option menu not open; return to normal textbox function.
				object_set_state(state_default); 
			} else{ // Otherwise, reactivate the option menu and return to the state for processing that.
				object_set_state(state_option_menu);
				with(optionMenu) { flags = flags | MENU_FLAG_ACTIVE; }
			}
			flags = flags & ~TBOX_FLAG_LOG_ACTIVE;
		}
	}
	
	/// @description 
	/// 
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_option_menu = function(_delta){
		process_input();
		
		// When the text log input is pressed, the process for opening that log is set to execute from the
		// next frame onward. The flag that tells the textbox if the log is open or not is set to prevent
		// certain parts of the textbox from rendering while it is open.
		if (TBOX_WAS_TEXT_LOG_PRESSED){
			object_set_state(state_open_log_animation);
			flags = flags | TBOX_FLAG_LOG_ACTIVE;
			
			// Make sure to deactivate the option menu so the cursor cannot be interacted with while the log
			// is open.
			with(optionMenu) { flags = flags & ~MENU_FLAG_ACTIVE; }
			return;
		}
		
		// 
		var _selOption = MENU_OPTION_INVALID;
		with(optionMenu){
			if (selOption == curOption){
				_selOption	= selOption;
				selOption	= MENU_OPTION_INVALID;
			}
		}
		
		// 
		if (_selOption == MENU_OPTION_INVALID)
			return;
		
		// 
		var _selectParams = optionDataRef[| _selOption].selectParams;
		if (array_length(_selectParams) == 0){
			object_set_state(state_close_options_animation);
			return;
		}
		
		var _function	= array_create(1, _selectParams[0]);
		var _length		= array_length(_selectParams);
		var _index		= 1;
		do{
			if (is_method(_selectParams[_index])){
				if (array_length(_function) > 1) { script_execute_ext(_function[0], _function, 1); }
				else							 { script_execute(_function[0]); }
				_function = array_create(0);
			}
			array_push(_function, _selectParams[_index]);
			_index++;
		} until(_index == _length);
		
		// 
		if (array_length(_function) > 1) { script_execute_ext(_function[0], _function, 1); } 
		else							 { script_execute(_function[0]); }
		
		// 
		object_set_state(state_close_options_animation);
	}
	
	/// @description
	///	State that handles the fade in/left sliding animation that occurs when opening the textbox's option
	/// menu. Once the menu is full opaque and the x position is where it needs to be, the function will
	/// activate the options menu and change the textbox to its state for monitoring the state of the menu.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_options_animation = function(_delta){
		var _animFinished = false;
		with(optionMenu){
			// Update the values that are involved in the animation.
			var _targetX = VIEWPORT_WIDTH - TBOXMENU_BG_PADDING_LEFT - contentWidth;
			x		    += (_targetX - x) * _delta * 0.2;
			alpha		+= _delta * 0.075;
			
			// Check if all values have hit their respective targets. If so, activate the menu so the player
			// can navigate its contents and select an option. Otherwise, continue the animation.
			if (alpha >= 1.0 && x - _targetX <= _delta){
				object_set_state(state_default);
				flags			= flags | MENU_FLAG_ACTIVE;
				x				= _targetX;
				alpha			= 1.0;
				_animFinished	= true;
			}
		}
		
		if (_animFinished){
			object_set_state(state_option_menu);
			// TODO -- Update Visible Control Information to Include Menu Up/Down Inputs.
		}
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_options_animation = function(_delta){
		var _animFinished = false;
		with(optionMenu){
			// Update the values that are involved in the animation.
			x		    += (TBOXMENU_XSTART - x) * _delta * 0.1;
			alpha		-= _delta * 0.075;
			
			// 
			if (alpha <= 0.0 && x > VIEWPORT_HEIGHT){
				flags			= flags & ~MENU_FLAG_ACTIVE;
				x				= TBOXMENU_XSTART;
				alpha			= 0.0;
				_animFinished	= true;
			}
		}
		
		if (_animFinished){
			object_set_state(state_default);
			close_current_textbox(); // Treat the finished animation the same as pressing the advance input.
			flags = flags & ~TBOX_FLAG_OPTIONS_ACTIVE;
			// TODO -- Update Visible Control Information to Remove Menu Up/Down Inputs.
		}
	}
	
	/// @description 
	/// 
	/// 
	/// @param {Real}	index	The index for the textbox that will be opened next.
	set_next_index = function(_index){
		nextIndex = _index;
		// show_debug_message("nextIndex has been set to {0}.", nextIndex);
	}
	
	/// @description 
	///	
	///	
	///	@param {Real}	flagID		The position of the bit (Starting from 0 as the first) to get the value of.
	/// @param {Bool}	flagState	The desired value to set the event's bit to (True = 1, False = 0).
	set_event_flag = function(_flagID, _flagState){
		event_set_flag(_flagID, _flagState);
	}
}

#endregion Textbox Struct Definition