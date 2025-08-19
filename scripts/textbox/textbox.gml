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
#macro	TBOX_SURFACE_HEIGHT				28

// Determines the total number of lines a textbox can display wihtin a single box. Any text that exceeds this
// amount after formatting will simply be discarded from what will be displayed.
#macro	TBOX_MAX_LINES_PER_BOX			3

// Macros for the characteristics of the textbox's background texture that the text surface will be drawn onto.
// They represent the width, height, and opacity/alpha value of said background, respectively.
#macro	TBOX_BG_X_OFFSET				0
#macro	TBOX_BG_Y_OFFSET				8
#macro	TBOX_BG_WIDTH					VIEWPORT_WIDTH - 20
#macro	TBOX_BG_HEIGHT					42

// The pixel offsets from the current x/y position of the textbox that the text contents will be rendered at.
// The shadow for the text is offset one to the left and down to create a simple drop shadow effect on the text.
#macro	TBOX_TEXT_X_OFFSET				10
#macro	TBOX_TEXT_Y_OFFSET				15

// Determines how many pixels away from the edges of the surface the text will be on the leftmost edge of it.
#macro	TBOX_SURFACE_X_PADDING			1
#macro	TBOX_SURFACE_Y_PADDING			2

// Constants for the x and y position of the textbox's advance arrow indicator which appears when the current 
// text to display has completely typed itself out onto the main textbox window.
#macro	TBOX_ARROW_X_OFFSET				TBOX_BG_X_OFFSET + TBOX_BG_WIDTH - 14
#macro	TBOX_ARROW_Y_OFFSET				TBOX_BG_Y_OFFSET + TBOX_BG_HEIGHT - 9

// Determines how many pixels the arrow's offset/timer will roughly move in 1/60th of a second.
#macro	TBOX_ARROW_MOVE_SPEED			0.07

// Determines the opacity levels for the text as well as its drop shadow.
#macro	TBOX_TEXT_ALPHA					1.0
#macro	TBOX_TEXT_SHADOW_ALPHA			0.8

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
	nextCharDelay	= TBOX_PUNCT_NONE;
	
	// Variables that allow the textbox to reference the current color data for the text that is being typed
	// onto the textbox; allowing each individual character to be a unique color compared to the default white.
	colorDataRef	= -1;
	totalColors		= 0;
	charColorIndex	= 0;
	
	// 
	advArrowOffset	= 0.0;

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
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	draw_gui_event = function(_delta){
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
			var _curChar		= "";
			var _curCharIndex	= curChar;
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
						// When the final character index is hit, the next element in the list (If one exists)
						// will be utilized on the next iteration of this character rendering logic. Otherwise,
						// the desired color is set if the current character's index is higher than whatever
						// the starting index for the color data is.
						if (_curCharIndex > endIndex){
							_curColor = COLOR_WHITE;
							other.charColorIndex++; 
						} else if (_curCharIndex >= startIndex){
							_curColor = colorCode; 
						}
					}
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
					charX	= TBOX_SURFACE_X_PADDING;
					charY  += string_height("M");
					// Get the previous character to see if it is punctuation and exit the loop if so.
					if (check_for_punctuation(_curText, _curCharIndex - 1))
						break;
					continue;
				}
				
				// Once the proper coordinates have been set as required, the character is drawn and the width
				// of the drawn character is added to properly offset the next character in the string.
				draw_text_shadow(charX, charY, _curChar, 
					_curColor, TBOX_TEXT_ALPHA, COLOR_DARK_GRAY, TBOX_TEXT_SHADOW_ALPHA);
				charX    += string_width(_curChar);
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
		
		// Display the background contents of the textbox, which includes the background that is always shown
		// behind the text being displayed, and an arrow that shows up once it is possible to advance to the
		// next chunk of text or close the texxtbox.
		draw_sprite_stretched_ext(spr_tbox_background, 0, _xPos + TBOX_BG_X_OFFSET, _yPos + TBOX_BG_Y_OFFSET, 
			TBOX_BG_WIDTH, TBOX_BG_HEIGHT, COLOR_TRUE_WHITE, alpha);
		if (curChar == textLength){
			// Display the advance indicator at the bottom-right of the textbox window relative to the value 
			// of the offset timer/value with the fraction component removed. 
			draw_sprite_ext(spr_tbox_advance_indicator, 0, 
				_xPos + TBOX_ARROW_X_OFFSET, 
				_yPos + TBOX_ARROW_Y_OFFSET + floor(advArrowOffset),
				1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha
			);
			
			// Increment the value until it reaches 2.0 or higher, and then reduce it by two to bring it back
			// to zero; allowing the arrow to bob up and down rhythmically on screen.
			advArrowOffset += TBOX_ARROW_MOVE_SPEED * _delta;
			if (advArrowOffset > 2.0)
				advArrowOffset -= 2.0;
		}
		
		// Simply draw the currently rendered text onto the screen with this single draw call.
		draw_surface_ext(textSurface, _xPos + TBOX_TEXT_X_OFFSET, _yPos + TBOX_TEXT_Y_OFFSET, 
			1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha);
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
		global.flags |= GAME_FLAG_TEXTBOX_OPEN;
		
		// Attempt to pause the player object. If a cutscene is currently occurring, this code does nothing
		// to the player object and whatever their state may currently be because of said cutscene.
		with(PLAYER) { pause_player(); }
		
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
		flags		   &= ~TBOX_FLAG_ACTIVE;
		global.flags   &= ~GAME_FLAG_TEXTBOX_OPEN;
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
		var _parsedData = string_parse_color_data(_text);
		ds_list_add(textData, {
			content		: string_split_lines(_parsedData.fullText, fnt_small, 
							TBOX_SURFACE_WIDTH - (TBOX_SURFACE_X_PADDING * 2), TBOX_MAX_LINES_PER_BOX),
			colorData	: _parsedData.colorData,
			actorIndex	: _actorIndex,
			nextIndex	: _nextIndex == -1 ? ds_list_size(textData) + 1 : _nextIndex,
		});
		delete _parsedData;
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
		if (_index == 0 || _index > textLength) { return false; }
		
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
	/// The textbox's main state. It allows the player to skip over the textbox's typing animation with an
	/// early press of the advance text input, and will also allow them to move onto the next textbox by
	/// pressing that same key so long as all the text for the current textbox is visible to them.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		process_textbox_input();
		
		// The text animation has completed, so nextChar no longer needs to have its value incremented, and
		// the user can now press the advance key to move onto the next textbox.
		if (nextChar == textLength){
			if (TBOX_WAS_ADVANCE_PRESSED){
				// Close the textbox if the next index is less than 0, equal to the current index, or outside
				// of the valid bounds of textbox data indices.
				if (nextIndex < 0 && nextIndex == textIndex || nextIndex >= ds_list_size(textData)){
					object_set_state(state_close_animation);
					textIndex = TBOX_INDEX_CLOSE;
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
		nextChar += nextCharDelay * _delta;
		if (TBOX_WAS_ADVANCE_PRESSED || nextChar > textLength){
			nextChar		= textLength;
			nextCharDelay	= TBOX_PUNCT_NONE;
		}
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
		alpha -= TBOX_ANIM_MOVE_SPEED * _delta;
		if (alpha <= 0.0) // Prevent the value from going negative.
			alpha = 0.0;
	}
}

#endregion Textbox Struct Definition