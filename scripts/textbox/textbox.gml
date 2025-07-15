#region Macros for Textbox Struct

// Macros that store the numerical values for each bit within the textbox's "flags" variable that are utilized
// by it to achieve some sort of state-based functionality outside of the standard step event state machine.
#macro	TBOX_INFLAG_ADVANCE				0x00000001
#macro	TBOX_INFLAG_TEXT_LOG			0x00000002
#macro	TBOX_FLAG_ACTIVE				0x00000004
#macro	TBOX_FLAG_WIPE_DATA				0x00000008
#macro	TBOX_FLAG_CLEAR_SURFACE			0x00000010
#macro	TBOX_FLAG_SHOW_NAME				0x00000020

// Macros that condense the checks required for specific states that the textbox must be in for it to process
// certain aspects of the data it is displaying the user, if it is allowed to do that currently to begin with.
#macro	TBOX_WAS_ADVANCE_PRESSED		((flags & TBOX_INFLAG_ADVANCE)		!= 0 && (prevInputFlags & TBOX_INFLAG_ADVANCE)	== 0)
#macro	TBOX_WAS_TEXT_LOG_PRESSED		((flags & TBOX_INFLAG_TEXT_LOG)		!= 0 && (prevInputFlags & TBOX_INFLAG_TEXT_LOG)	== 0)
#macro	TBOX_IS_ACTIVE					((flags & TBOX_FLAG_ACTIVE)			!= 0)
#macro	TBOX_CAN_WIPE_DATA				((flags & TBOX_FLAG_WIPE_DATA)		!= 0)
#macro	TBOX_SHOULD_CLEAR_SURFACE		((flags & TBOX_FLAG_CLEAR_SURFACE)	!= 0)
#macro	TBOX_SHOULD_SHOW_NAME			((flags & TBOX_FLAG_SHOW_NAME)		!= 0)

//
#macro	TBOX_CHAR_SPACE					" "
#macro	TBOX_CHAR_NEWLINE				"\n"
#macro	TBOX_CHAR_COLOR_CHANGE			"@"
#macro	TBOX_CHAR_REGION_START			"{"
#macro	TBOX_CHAR_REGION_END			"}"

// 
#macro	TBOX_COLOR_CODE_BLUE			"blue"
#macro	TBOX_COLOR_CODE_RED				"red"
#macro	TBOX_COLOR_CODE_GREEN			"green"
#macro	TBOX_COLOR_CODE_ORANGE			"orange"
#macro	TBOX_COLOR_CODE_PURPLE			"purple"

// Index values that point to an actor's name as a string within the game's data. Can be retrieved for use by
// calling the function get_actor_name.
#macro	TBOX_ACTOR_INVALID				0
#macro	TBOX_ACTOR_PLAYER				1

// Two macros that determine the size of the textbox's text surface along the x and y axis, respectively. The
// actual textbox's dimensions will be larger than this since this surface is only one part of the textbox.
#macro	TBOX_SURFACE_WIDTH				280
#macro	TBOX_SURFACE_HEIGHT				28

// Macros for the characteristics of the textbox's background texture that the text surface will be drawn onto.
// They represent the width, height, and opacity/alpha value of said background, respectively.
#macro	TBOX_BG_WIDTH					VIEWPORT_WIDTH - 20
#macro	TBOX_BG_HEIGHT					50
#macro	TBOX_BG_ALPHA					0.25

// The pixel offsets from the current x/y position of the textbox that the text contents will be rendered at.
// The shadow for the text is offset one to the left and down to create a simple drop shadow effect on the text.
#macro	TBOX_TEXT_X_OFFSET				10
#macro	TBOX_TEXT_Y_OFFSET				15
#macro	TBOX_TEXT_SHADOW_X_OFFSET		11
#macro	TBOX_TEXT_SHADOW_Y_OFFSET		16

// Determines the opacity of the text's shadow relative to the entire textbox's current opacity.
#macro	TBOX_TEXT_SHADOW_ALPHA			0.75

// Determines how many pixels away from the edges of the surface the text will be on the leftmost edge of it.
#macro	TBOX_SURFACE_X_PADDING			1
#macro	TBOX_SURFACE_Y_PADDING			2

// Determines the position on the GUI the textbox will begin the opening animation at.
#macro	TBOX_Y_START					VIEWPORT_HEIGHT + 30

// Determines the position on the GUI the textbox will rest at after its opening transition has completed.
#macro	TBOX_Y_TARGET					VIEWPORT_HEIGHT - 60.0

// Determines the speed of the the elements involved in the textbox's open and closing animations. The first
// value is only utilized during opening, and the second is utilized by both.
#macro	TBOX_ANIM_MOVE_SPEED			0.2
#macro	TBOX_ANIM_ALPHA_SPEED			0.075

#endregion Macros for Textbox Struct

#region Textbox Struct Definition

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_textbox(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// The current position of the textbox on the game's GUI layer. Determines where everything is drawn as
	// this coordinate will determine the top-left position of the entire textbox when drawn to the screen.
	x				= floor((VIEWPORT_WIDTH - TBOX_SURFACE_WIDTH - 20) / 2);
	y				= TBOX_Y_START;
	
	// Determines the overall transparency level for every graphics element of the textbox.
	alpha			= 0.0;
	
	// State variables that function exactly like how they do when an entity utilizes them; processing a single
	// function that represents the current state of the object; allowing them to move to other states as required
	// during that initial state's output.
	curState		= 0;
	nextState		= 0;
	lastState		= 0;
	
	// The surface that the current textbox's text will be drawn to, and the buffer that will store a copy of
	// that data in memory in case the surface gets flushed from the GPU.
	textSurface		= -1;
	surfBuffer		= buffer_create(TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4, buffer_fixed, 4);
	
	// Variable relating to the text content data structure. They store the list itself, the current index
	// and next index as determined by the current index's data, and the length of the string found within the
	// current index's data.
	textData		= ds_list_create();
	textIndex		= 0;
	nextIndex		= 0;
	textLength		= 0;

	// Stores the string that represents the name of the actor that is speaking in the current textbox. Can
	// only be shown if the flag bit within the flags variable is set as well.
	actorName		= "";
	
	// Stores the toggled and not toggled input flags from the previous frame so the input can be checked to
	// see if it was pressed or not by the player.
	prevInputFlags	= 0;
	
	// Variables relating to which character(s) will be drawn and where they will be drawn on the textbox's
	// text surface when performing the "typing" animation.
	curChar			= 1;
	nextChar		= 1;
	charX			= 0;
	charY			= 0;
	
	// 
	colorDataRef	= -1;
	totalColors		= 0;
	charColorIndex	= 0;

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
	/// information taht has been queued up for the player to see.
	///	
	draw_gui_event = function(){
		// Ensures that the surface will be valid should it randomly be flushed from memory by the GPU. Then,
		// the previous surface's contents are copied from their buffer onto the newly formed surface.
		if (!surface_exists(textSurface)){
			textSurface = surface_create(TBOX_SURFACE_WIDTH, TBOX_SURFACE_HEIGHT);
			buffer_set_surface(surfBuffer, textSurface, 0);
		}
		
		// When toggled, this flag allows the surface to be completely wiped of any contents as required.
		// This will leave the surface completely empty so new content can populate it.
		if (TBOX_SHOULD_CLEAR_SURFACE){
			flags &= ~TBOX_FLAG_CLEAR_SURFACE;
			surface_set_target(textSurface);
			draw_clear_alpha(c_black, 0.0);
			surface_reset_target();
		}
		
		// Adding new characters to the text surface of the current textbox whenever the value of curChar (The
		// value that represents how many characters have been drawn) is less than _nextChar and the textbox
		// is currently considered active. Otherwise, this block of code is skipped.
		var _nextChar = floor(nextChar);
		if (TBOX_IS_ACTIVE && curChar < _nextChar){
			surface_set_target(textSurface);
				
			// Set the font outside of the loop since all text drawn shares the same one. Also set the alpha
			// value to 1.0 to ensure the text won't accidentally be drawn onto the surface with transparency.
			draw_set_font(fnt_small);
			draw_set_alpha(1.0);
			draw_set_color(c_white); // TEMPORARY until color information is added to textbox data.
			
			// Grab a reference to the current textbox's contents and then begin adding characters to the text
			// surface one at a time until the value of curChar matches that of _nextChar.
			var _curText	= textData[| textIndex];
			var _curChar	= "";
			var _colorData	= -1;
			var _curColor	= c_white;
			while(curChar < _nextChar){
				_curChar = string_char_at(_curText.content, curChar);
				
				// Newline character found; the x offset of the character is reset and the y value if offset
				// to create a new line of text on the surface instead of writing on top of the previous one.
				if (_curChar == "\n"){
					charX	= TBOX_SURFACE_X_PADDING;
					charY  += string_height("M");
					curChar++;
					continue;
				}
				
				// Check if any unique colors should be used for the text currently being added to the screen.
				// This entire chunk of code is ignored if the textbox doesn't have any additional color data
				// associated with it.
				if (colorDataRef != -1 && charColorIndex < totalColors){
					var _curCharIndex = curChar;
					with(colorDataRef[| charColorIndex]){
						// When the final character index is hit, the next element in the list (If one exists)
						// will be utilized on the next iteration of this character rendering logic. Otherwise,
						// the desired color is set if the current character's index is higher than whatever
						// the starting index for the color data is.
						if (_curCharIndex > endIndex)		  { other.charColorIndex++; }
						else if (_curCharIndex >= startIndex) { _curColor = colorCode; }
					}
				}
				curChar++; // Only increment this value AFTER the potential color data has been checked.
				
				// Once the proper coordinates have been set as required, the character is drawn and the width
				// of the drawn character is added to properly offset the next character in the string.
				draw_text_shadow(charX, charY, _curChar, _curColor);
				charX    += string_width(_curChar);
				_curColor = c_white; 
			}
			
			// Finally, the surface target is reset to that of the application surface, and the current contents 
			// of the text surface are captured and stored in their buffer should the GPU flush it.
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurface, 0);
		}

		// Get the non-decimal position of the textbox so there aren't any odd subpixel rendering done when the
		// goal is a pixel-perfect aesthetic. Then the textbox graphics are drawn in their required order.
		var _xPos = floor(x);
		var _yPos = floor(y);
		
		// TODO -- Replace this rectangle with an actual textbox graphic.
		draw_sprite_ext(spr_rectangle, 0, _xPos, _yPos, 
			TBOX_BG_WIDTH, TBOX_BG_HEIGHT, 0.0, c_white, alpha * TBOX_BG_ALPHA);
		
		// Simply draw the currently rendered text onto the screen with this single draw call.
		draw_surface_ext(textSurface, _xPos + TBOX_TEXT_X_OFFSET, _yPos + TBOX_TEXT_Y_OFFSET, 
			1.0, 1.0, 0.0, c_white, alpha);
	}
	
	/// @description 
	/// Captures the user's input for the current frame. Instead of storing the current input flags in their
	/// own dedicated variable, they're placed within the default "flags" variable since there is plenty of
	/// room for the two user inputs required for the textbox to function. The previous frame's inputs are
	/// still stored in the standard "prevInputFlags" variable.
	/// 
	process_textbox_input = function(){
		prevInputFlags	= flags & (TBOX_INFLAG_ADVANCE | TBOX_INFLAG_TEXT_LOG);
		flags		   &= ~(TBOX_INFLAG_ADVANCE | TBOX_INFLAG_TEXT_LOG);
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			flags |= (MENU_PAD_TBOX_ADVANCE		); // Offset based on position of the bit within the variable.
			flags |= (MENU_PAD_TBOX_LOG		<< 1);
			return;
		}
		
		flags |= (MENU_KEY_TBOX_ADVANCE		); // Offset based on position of the bit within the variable.
		flags |= (MENU_KEY_TBOX_LOG		<< 1);
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
			
		// Set the default flags that are toggled upon activation of the textbox. Then, if required, the flag
		// will be set to true that all data will be cleared on deactivation of the textbox.
		flags |= TBOX_FLAG_ACTIVE; // Surface clearing flag is set within "set_textbox_index".
		if (_clearDataOnDeactivation)
			flags |= TBOX_FLAG_WIPE_DATA;
		
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
		flags &= ~TBOX_FLAG_ACTIVE;
		if (!TBOX_CAN_WIPE_DATA) // Prevent deleting any text information if the flag isn't toggled.
			return;
		flags &= ~TBOX_CAN_WIPE_DATA;
		
		// Loop through and clear out the structs from within the textData data structures. All now undefined
		// references will also be cleared and the structure is set back to a size of 0.
		var _length = ds_list_size(textData);
		for (var i = 0; i < _length; i++){
			with(textData[| i]){ // Make sure color data structs are removed should any exist for the current textbox.
				if (ds_exists(colorData, ds_type_list)){
					var _cDataLength = ds_list_size(colorData);
					for (var ii = 0; ii < _cDataLength; ii++)
						delete colorData[| ii];
					ds_list_destroy(colorData);
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
		var _textData		= textData[| _index];
		var _prevActorIndex	= textData[| textIndex].actorIndex;
		var _newActorIndex	= _textData.actorIndex;
		if (_prevActorIndex != _newActorIndex)
			object_set_state(state_close_animation);
		
		flags		   |= TBOX_FLAG_CLEAR_SURFACE;
		textLength		= string_length(_textData.content) + 1;
		textIndex		= _index;
		nextIndex		= _textData.nextIndex;
		actorName		= get_actor_name(_newActorIndex);
		curChar			= 1;	// Reset these to their defaults so the typing animation can play again.
		nextChar		= 1;
		charX			= TBOX_SURFACE_X_PADDING;
		charY			= TBOX_SURFACE_Y_PADDING;
		colorDataRef	= _textData.colorData;	// Overwrite the previous ds_list reference with either -1 or the new textbox's color list.
		totalColors		= (colorDataRef == -1) ? 0 : ds_list_size(colorDataRef);
		charColorIndex	= 0;
		
		// Clear or set the flag that is responsible for allowing a textbox to display graphics related to an
		// actor's name alongside that name itself depending on what "actorName" is set to by the call to the
		// get_actor_name.
		if (actorName != "") { flags &= ~TBOX_FLAG_SHOW_NAME; }
		else				 { flags |=  TBOX_FLAG_SHOW_NAME; }
	}
	
	/// @description 
	///	Adds another element to the textData data structure for the textbox to utilize when set to view its
	/// contents. It will properly format the string so it doesn't overflow the textbox horizontally before
	/// the string is converted into a text content struct containing the string and data is references. It
	///	also discards any text that should exceed the 
	///	
	///	@param {String}	text		The text to format and enqueue for the textbox to display when ready.
	/// @param {Real}	actorIndex	(Optional) If set to a value greater than 0, the actor's name relative to the index will be shown.
	///	@param {Real}	nextIndex	(Optional) Determines which textbox out of the current data is after this one.
	queue_new_text = function(_text, _actorIndex = 0, _nextIndex = -1){
		draw_set_font(fnt_small); // Ensures proper font is used for size calculations.
		var _curWordWidth		= 0;
		var _curLineWidth		= 0;
		var _curChar			= "";
		var _curLine			= "";
		var _curWord			= "";
		var _fullText			= "";
		var _fullColorData		= ds_list_create();
		var _length				= string_length(_text);
		for (var i = 1; i <= _length; i++){
			_curChar = string_char_at(_text, i);

			// A space character or the length of the string has been reached. The current word will be added
			// to the current line if that line still has room on the textbox. Otherwise, it will be added to
			// the next line and that line will begin with that word alongside a spaceas its starting content.
			if (_curChar == TBOX_CHAR_SPACE || i == _length){
				// The text will overflow the textbox horizontally, so the current line is added to the 
				// formatted string and a new line will begin.
				if (_curLineWidth + _curWordWidth > TBOX_SURFACE_WIDTH - (TBOX_SURFACE_X_PADDING * 2)){
					// Make sure the text doesn't also overflow vertically if another line was going to be
					// added to what will be shown on the screen. If so, exit the loop early.
					if (string_height(_fullText + "\nM") > TBOX_SURFACE_HEIGHT - (TBOX_SURFACE_Y_PADDING * 2)){
						_fullText  += _curLine;
						_curLine	= "";
						break;
					}
					_fullText	   += _curLine + TBOX_CHAR_NEWLINE;
					_curLineWidth	= _curWordWidth + string_width(TBOX_CHAR_SPACE);
					_curLine		= _curWord + " ";
				} else{ // Line has more space; keep adding to it.
					_curLineWidth  += _curWordWidth + string_width(_curChar);
					_curLine	   += _curWord + _curChar;
				}
				_curWordWidth	= 0;
				_curWord		= "";
				continue;
			}
			
			// A newline character already exists within the string, so a new line will be started without
			// the current line having to exceed the horizontal limit of the textbox.
			if (_curChar == TBOX_CHAR_NEWLINE){
				// Make sure the text doesn't also overflow vertically if another line was going to be
				// added to what will be shown on the screen. If so, exit the loop early.
				if (string_height(_fullText + "\nM") > TBOX_SURFACE_HEIGHT - (TBOX_SURFACE_Y_PADDING * 2)){
					_fullText	   += _curLine + _curWord;
					_curLine		= "";
					break;
				}
				_fullText	   += _curLine + _curWord + TBOX_CHAR_NEWLINE;
				_curLineWidth	= 0;
				_curLine		= "";
				_curWordWidth	= 0;
				_curWord		= "";
				continue;
			}
			
			// A region end character ('}') has been hit while parsing the current string. So, the position
			// within the parsed string is captured so the color data will know when it has ended. Otherwise, 
			// all subsequent characters would remain a given color until another color within this ds_list 
			// would overwrite it with its own color; instead of going back to the standard text color.
			if (_curChar == TBOX_CHAR_REGION_END){
				with(_fullColorData[| ds_list_size(_fullColorData) - 1])
					endIndex = string_length(_fullText) + string_length(_curLine) + string_length(_curWord);
				continue;
			}
			
			// A color change character ('@') has been hit while parsing the current string. So, a new struct
			// is created that will house the data for the next chunk of text that will be colored a different
			// hue from the textbox's default.
			if (_curChar == TBOX_CHAR_COLOR_CHANGE){
				i++; // Increment i to skip over the color change character.
				
				// Set the start index of the colored text region to whatever the current length of all the
				// parsed text is equal to. The endIndex value is initialzed to 0, but will be set in the future.
				var _colorData = {
					colorCode	: 0,
					startIndex	: string_length(_fullText) + string_length(_curLine) + string_length(_curWord),
					endIndex	: 0,
				};
				
				// Now, loop until a region start character ('{') is found. When that character is hit, whatever
				// was parsed before it will be treated as the "color code". THis is passed into a function that
				// will return an RGB color value that the text can utilize as it's being rendered.
				var _strColor = "";
				while(i < _length){
					_curChar = string_char_at(_text, i);
					if (_curChar == TBOX_CHAR_REGION_START){
						ds_list_add(_fullColorData, _colorData);
						_colorData.colorCode = get_color_code_from_string(_strColor);
						break;
					}
					
					_strColor += _curChar;
					i++;
				}
				continue;
			}
			
			// Add the current character to the current word being parsed from the unformatted string. The 
			// width of said character is also captured and added to the current word's width. 
			_curWordWidth  += string_width(_curChar);
			_curWord	   += _curChar;
		}
		
		// Make sure the final line is added to the parsed string if it wasn't set within the loop on its
		// last iteration.
		if (_curLine != "")
			_fullText += _curLine;
		
		// Check to see if the actor index specified is valid by quickly calling the function for getting an
		// actor's name. If this function returnes its default value of an empty string, no name will be shown. 
		if (_actorIndex != TBOX_ACTOR_INVALID && get_actor_name(_actorIndex) == "")
			_actorIndex = TBOX_ACTOR_INVALID;
		
		// Should no additional color data be parsed from the provided text, the ds_list that was created to
		// hold any potential color information will be destroyed and the value passed into the textData struct
		// will simply be the default value of -1.
		if (ds_list_size(_fullColorData) == 0){
			ds_list_destroy(_fullColorData);
			_fullColorData = -1;
		}
		
		// Finally, create a new struct for the parsed text's contents and paired data.
		ds_list_add(textData, {
			content		: _fullText,
			colorData	: _fullColorData,
			actorIndex	: _actorIndex,
			nextIndex	: _nextIndex,
		});
	}
	
	/// @description 
	///	Grabs an RGB color code (Denoted as 0xBBGGRR in the actual hex values for each) that matches the string
	/// code that was parsed into this function's single argument parameter. If a matching value is found, it
	/// will be returned. Otherwise, the default value of a dark gray is returned as a soft error.
	///	
	/// @param {String}	string	The string of text that will be checked to get the matching color code from. 
	get_color_code_from_string = function(_string){
		switch(string_lower(_string)){
			default:						return c_dkgray;
			case TBOX_COLOR_CODE_BLUE:		return c_blue;
			case TBOX_COLOR_CODE_RED:		return c_red;
			case TBOX_COLOR_CODE_GREEN:		return c_green;
			case TBOX_COLOR_CODE_ORANGE:	return c_orange;
			case TBOX_COLOR_CODE_PURPLE:	return c_purple;
		}
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
	/// The textbox's main state. It allows the player to skip over the textbox's typing animation with an
	/// early press of the advance text input, and will also allow them to move onto the next textbox by
	/// pressing that same key so long as all the text for the current textbox is visible to them.
	///	
	///	@param {Real}	delta 
	state_default = function(_delta){
		process_textbox_input();
		
		// The text animation has completed, so nextChar no longer needs to have its value incremented, and
		// the user can now press the advance key to move onto the next textbox.
		if (nextChar == textLength){
			if (TBOX_WAS_ADVANCE_PRESSED){
				if (nextIndex == -1){ // The next index is invalid, the textbox will deactivate itself.
					object_set_state(state_close_animation);
					textIndex = -1;
					return;
				}
				set_textbox_index(nextIndex);
			}
			return;
		}
		
		// Increment the value of nextChar by the current delta multiplied against the speed of the text as
		// defined within the current struct being referenced within the textData data structure. Pressing
		// the advance key before this value has reached the desired text length will skip this process and
		// display all text on the screen instantly.
		nextChar += _delta;
		if (TBOX_WAS_ADVANCE_PRESSED || nextChar > textLength)
			nextChar = textLength;
	}
	
	/// @description 
	/// Executes the opening animation for the textbox, which fades it into visiblity on the GUI layer while
	/// also smoothly shifting the textbox upward from the bottom of the screen. Once the target y position
	/// is reached AND the alpha is set to 1.0, the opening animation will be considered complete.
	///	
	///	@param {Real}	delta 
	state_open_animation = function(_delta){
		// Give the player control over the textbox by shifting into its default state function. This state is
		// also responsible for "typing" the characters onto the textbox until they're all shown.
		if (alpha == 1.0 && y == TBOX_Y_TARGET){
			object_set_state(state_default);
			return;
		}
		
		// Fades the entire textbox into full visiblity.
		if (alpha < 1.0){
			alpha += TBOX_ANIM_ALPHA_SPEED * _delta;
			if (alpha > 1.0)
				alpha = 1.0;
		}
		
		// Move the y position from where it is initially set below the visible portion of the screen to the
		// desired position set by this opening animation.
		if (y != TBOX_Y_TARGET){
			y += (TBOX_Y_TARGET - y) * TBOX_ANIM_MOVE_SPEED * _delta;
			if (point_distance(0, y, 0, TBOX_Y_TARGET) <= max(1.0, _delta))
				y = TBOX_Y_TARGET;
		}
	}
	
	/// @description 
	/// Executes the closing animation for the textbox, which simply fades it out at a linear rate until it
	/// is completely invisible to the player. Then, it determines whether to deactivate the current textbox
	/// or re-opens it if an actor name change is why the textbox "closed".
	///	
	///	@param {Real}	delta 
	state_close_animation = function(_delta){
		// Repeat the opening animation or deactivate the textbox depending on the current value of nextIndex.
		if (alpha == 0.0){
			if (textIndex == -1){ // Closes the textbox.
				deactivate_textbox();
				return;
			}
			// Set the textbox to "reopen" itself for the new actor's dialogue.
			object_set_state(state_open_animation); 
			y = TBOX_Y_START;
			return;
		}
		
		// Fades the textbox until it is no longer visible on the screen.
		alpha -= TBOX_ANIM_MOVE_SPEED * _delta;
		if (alpha <= 0.0) // Prevent the value from going negative.
			alpha = 0.0;
	}
}

#endregion Textbox Struct Definition