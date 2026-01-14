#region Macros for Textbox Log Struct

// Bits that are utilized within the textbox log's "flags" variable to enable different aspect of the struct
// and disable them as required.
#macro	TBOXLOG_INFLAG_UP				0x00000001
#macro	TBOXLOG_INFLAG_DOWN				0x00000002
#macro	TBOXLOG_INFLAG_CLOSE			0x00000004
#macro	TBOXLOG_FLAG_RENDER				0x00000008
#macro	TBOXLOG_FLAG_ACTIVE				0x00000010
#macro	TBOXLOG_FLAG_CLOSING			0x00000020

// Macros that condense the code needed to check if each flag bit used by the textbox log's into a neat value
// that can be auto-completed by GameMaker to simply the typing required.
#macro	TBOXLOG_MOVE_UP_HELD			((flags & TBOXLOG_INFLAG_UP)		!= 0 && (prevInputFlags & TBOXLOG_INFLAG_UP)	!= 0)
#macro	TBOXLOG_MOVE_DOWN_HELD			((flags & TBOXLOG_INFLAG_DOWN)		!= 0 && (prevInputFlags & TBOXLOG_INFLAG_DOWN)	!= 0)
#macro	TBOXLOG_WAS_CLOSE_RELEASED		((flags & TBOXLOG_INFLAG_CLOSE)		== 0 && (prevInputFlags & TBOXLOG_INFLAG_CLOSE)	!= 0)
#macro	TBOXLOG_SHOULD_RENDER			((flags & TBOXLOG_FLAG_RENDER)		!= 0)
#macro	TBOXLOG_IS_ACTIVE				((flags & TBOXLOG_FLAG_ACTIVE)		!= 0)
#macro	TBOXLOG_IS_CLOSING				((flags & TBOXLOG_FLAG_CLOSING)		!= 0)

// Values that determine how many pieces of text the log can hold at any given time and how many of those
// pieces of data will be shown to the player at a single time when they view the log.
#macro	TBOXLOG_MAXIMUM_STORED			128
#macro	TBOXLOG_MAXIMUM_VISIBLE			3

// Values for the keys that store the textbox log's control groups within the control UI manager struct.
#macro	TBOXLOG_ICONUI_CTRL_GRP_MOVE	"tlog_icons_move"
#macro	TBOXLOG_ICONUI_CTRL_GRP_INPUT	"tlog_icons_input"

// Some offset and positional values for the two control groups that are used by the textbox log. The offset
// values are used for both groups even though they are on opposite sides of the screen.
#macro	TBOXLOG_CTRL_GRP_XOFFSET		5
#macro	TBOXLOG_CTRL_GRP_YOFFSET		12
#macro	TBOXLOG_CTRL_GRP_INPUT_PADDING	3
#macro	TBOXLOG_CTRL_GRP_MOVE_PADDING	2

// Values that determine the distance between the text surfaces edges on all sides to the edges of the
// background that is rendered behind each surface.
#macro	TBOXLOG_BG_XPADDING				4
#macro	TBOXLOG_BG_YPADDING				4

#endregion Macros for Textbox Log Struct

#region Textbox Log Struct Definition

/// @param {Function}	index	The value of "str_textbox_log" as determined by GameMaker during runtime.
function str_textbox_log(_index) : str_base(_index) constructor {
	flags				= STR_FLAG_PERSISTENT;
	
	// 
	prevInputFlags		= 0;
	moveTimer			= 0.0;
	
	// Determines the overall transparency level for every graphics element of the textbox log.
	alpha				= 0.0;
	
	// Since the y value of the textboxes isn't important, the y value isn't stored in a variable. However, the
	// x value is calculated within the textbox itself during its create event, and this value will be copied
	// into this variable so the x position of the textbox's text and the log's text are consistent.
	textX				= 0.0;
	
	// Stores structs that contain the logged text information that the log will be able to show to the player.
	// It will be formatted exactly the same as how it is formatted in the textbox.
	textData			= ds_list_create();
	
	// Three surfaces and their accompanying buffers. They will store the visible textbox logs so that they
	// will not need to be constantly rendered every frame, and can be recovered should the GPU flush the
	// surfaces for some reason.
	textSurfaces		= array_create(TBOXLOG_MAXIMUM_VISIBLE, -1);
	surfBuffer			= buffer_create(TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * TBOXLOG_MAXIMUM_VISIBLE * 4, 
							buffer_fixed, 4);
	
	// Two values relating to the log itself. The first stores the current offset into the log that the topmost
	// lost within the currently visible region is, and the second simply stores total number of elements within
	// the log.
	curOffset			= 0;
	logSize				= 0;
	
	// Two variables that store the references to the control group UI elements that will be controlled and
	// drawn by the textbox log. These are created at the start of the game alongside this struct.
	movementCtrlGroup	= REF_INVALID;
	inputCtrlGroup		= REF_INVALID;
	
	/// @description 
	///	The textbox log struct's create event. It will simply initialize the control icon groups that will be 
	/// drawn whenever the textbox log is actively being rendered onto the screen.
	///	
	create_event = function(){
		if (room != rm_init)
			return; // Prevents a call to this function from executing outside of the game's initialization.
		
		// Create two local variables to store the references to the control group information that the log
		// will utilize to inform the player on how to interact with it. These are then stored in the log's
		// own variables for each respective control group for use later in the code.
		var _movementCtrlGroup	= REF_INVALID;
		var _inputCtrlGroup		= REF_INVALID;
		with(CONTROL_UI_MANAGER){
			// Create the control group that will display the inputs for moving up and down through the available
			// logged textboxes. These inputs are the same as the menu's up and down inputs, so changing those
			// will cause these to change as well.
			_movementCtrlGroup = create_control_group(TBOXLOG_ICONUI_CTRL_GRP_MOVE,
				TBOXLOG_CTRL_GRP_XOFFSET, VIEWPORT_HEIGHT - TBOXLOG_CTRL_GRP_YOFFSET,
					TBOXLOG_CTRL_GRP_INPUT_PADDING, ICONUI_DRAW_RIGHT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_UP);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_DOWN, "Navigate");
			
			// Create a second control group that stores information for the input that will close the log.
			// This button is the exact same button that was used to activate the textbox log.
			_inputCtrlGroup = create_control_group(TBOXLOG_ICONUI_CTRL_GRP_INPUT, 
				VIEWPORT_WIDTH - TBOXLOG_CTRL_GRP_XOFFSET, VIEWPORT_HEIGHT - TBOXLOG_CTRL_GRP_YOFFSET, 
					TBOXLOG_CTRL_GRP_MOVE_PADDING, ICONUI_DRAW_LEFT);
			add_control_group_icon(_inputCtrlGroup, ICONUI_TBOX_LOG, "Close");
		}
		movementCtrlGroup	= _movementCtrlGroup;
		inputCtrlGroup		= _inputCtrlGroup;
	}
	
	/// @description 
	///	The textbox log struct's destroy event. It will clean up anything that isn't automatically cleaned up 
	/// by GameMaker when this struct is destroyed/out of scope.
	///
	destroy_event = function(){
		// Free all the surfaces that store the currently visible log data, and destroy the buffer that stores
		// a backup of each of those surfaces should they be flushed by the GPU.
		var _length = array_length(textSurfaces);
		for (var i = 0; i < _length; i++){
			if (surface_exists(textSurfaces[i]))
				surface_free(textSurfaces[i]);
		}
		buffer_delete(surfBuffer);
		
		// Loop through and remove all structs within this list before destroying the list itself.
		_length = ds_list_size(textData);
		for (var i = 0; i < _length; i++){
			with(textData[| i]){ // Make sure color data structs are removed before deleting the outer struct.
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
		ds_list_destroy(textData);
	}
	
	/// @description 
	///	Despite being called "step_event", this function is not called on every frame within the obj_game_manager
	/// step event. Instead, it is called within the functions of objects or structs that are monitoring 
	/// this struct's closing flag to see when they should return function to themselves/play any animations
	///	they perform when the log is closed.
	///
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
		process_input();
		
		// Pressing the return input will reset the necessary variables and set the flag that signals to
		// other objects that the log can now be closed without issue.
		if (TBOXLOG_WAS_CLOSE_RELEASED){
			flags			= flags & ~(TBOXLOG_INFLAG_UP | TBOXLOG_INFLAG_DOWN) | TBOXLOG_FLAG_CLOSING;
			prevInputFlags	= 0;
			moveTimer		= 0.0;
			return;
		}
		
		// Determine the movement direction for the textbox log by subtracting the flag bit values for the
		// textbox log up/down inputs. This results in either a -1, 0, or +1 to be calculated; resulting in
		// movement up (-1), down (+1), or nothing (0).
		var _moveDirection = TBOXLOG_MOVE_DOWN_HELD - TBOXLOG_MOVE_UP_HELD;
		if (_moveDirection == 0 || logSize <= TBOXLOG_MAXIMUM_VISIBLE){
			moveTimer = 0.0;
			return;
		}
			
		// A simplified version of the menu input autoscrolling that simply resets to a constant values as
		// the user holds one of the two movement inputs down to navigate around the current log contents.
		moveTimer -= _delta;
		if (moveTimer > 0.0)
			return;
		moveTimer += 15.0;
		
		// Determine whether to move the user up the log to older messages, or down the log to newer ones
		// relative to the direction of input they are currently pressing/holding. Each direction will wrap
		// to the top or bottom once they hit those points.
		if (_moveDirection == MENU_MOVEMENT_UP && curOffset >= TBOXLOG_MAXIMUM_VISIBLE - 1){ 
			curOffset--;
			if (curOffset == TBOXLOG_MAXIMUM_VISIBLE - 2)
				curOffset = logSize - 1;
		} else if (_moveDirection == MENU_MOVEMENT_DOWN && curOffset < logSize){
			curOffset++;
			if (curOffset == logSize)
				curOffset = TBOXLOG_MAXIMUM_VISIBLE - 1;
		}
		
		// After updating the position within the textbox log, set the flag that is responsible for rendering
		// the newly visible contents.
		flags = flags | TBOXLOG_FLAG_RENDER;
	}
	
	/// @description 
	///	Called to render the textbox log and its currently visible contents whenever the textbox log struct is 
	/// currently showing the information it contains.
	///	
	///	@param {Real}	xView		Position of the viewport within the current room along its x axis.
	/// @parma {Real}	yView		Position of the viewport within the current room along its y axis.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_gui_event = function(_xView, _yView, _delta){
		#region Drawing Main Background for Textbox Log
		
			draw_sprite_ext( // Single rectangle to cover entire screen.
				spr_rectangle,
				0,		// Unused
				_xView, _yView, 
				VIEWPORT_WIDTH, VIEWPORT_HEIGHT, 
				0.0,	// Unused
				COLOR_BLACK, 0.75 * alpha
			);
				
		#endregion Drawing Main Background for Textbox Log
		
		// Come local values that are used by the scrollbar and its background element. The X value is basically
		// shared between the two (The background for the bar is one pixel to the left), but the Y values will
		// differ once enough entries exist in the log. So, two Y variables are created; one for the position
		// of both the scrollbar and the background (Background is one pixel down), and the other for the offset
		// of the bar relative to that topmost position. Finally, the height is set and also adjusted when there
		// are enough elements within the log to require scrollbar movement.
		var _xScrollbar		= _xView + VIEWPORT_WIDTH - 9;
		var _yScrollbarTop	= _yView + 15;
		var _yScrollbarBot	= 0;
		var _hScrollbar		= 145;
		
		// Once the log has grown large enough, the scrollbar will need to be sized and positioned accordingly.
		// So, the maximum possible value that "curOffset" can be (This is two below the actual log size) will
		// be the denominator in the calculations for size (_hScrollbar) and position (_yScrollbarBot).
		if (logSize > TBOXLOG_MAXIMUM_VISIBLE){
			var _curOffsetMax	= (logSize - TBOXLOG_MAXIMUM_VISIBLE) + 1; // Without the + 1 the values will all be off by one element's amount.
			_yScrollbarBot		= (145 * ((curOffset - (TBOXLOG_MAXIMUM_VISIBLE - 1)) / _curOffsetMax));
			_hScrollbar			= 145 / _curOffsetMax; // Shrink the scrollbar as more elements are added to the log.
		}
		
		#region Drawing Scrollbar on Left Edge of Textbox Log
		
			draw_sprite_ext( // Background for Scrollbar
				spr_rectangle,
				0,		// Unused
				_xScrollbar + 1, _yScrollbarTop + 1, 
				2, 143,
				0.0,	// Unused
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // The Scrollbar itself
				spr_rectangle,
				0,		// Unused
				_xScrollbar, _yScrollbarTop + _yScrollbarBot,
				4, _hScrollbar,
				0.0,	// Unused
				COLOR_WHITE, alpha
			);
		
		#endregion Drawing Scrollbar on Left Edge of Textbox Log

		// Loop through the available surfaces and drawn them to the screen. Alongside the surfaces, the
		// background for each will be drawn in real time out of simple rectangles. The X values need to only
		// be calculated once, and the Y variables will be set on each iteration of the loop.
		var _xOffset	= _xView + textX + TBOX_TEXT_XOFFSET;
		var _xBack		= _xOffset - TBOXLOG_BG_XPADDING;
		var _yOffset	= 0;
		var _yBack		= 0;
		for (var i = 0; i < TBOXLOG_MAXIMUM_VISIBLE; i++){
			if (!surface_exists(textSurfaces[i])){
				textSurfaces[i] = surface_create(TBOX_SURFACE_WIDTH, TBOX_SURFACE_HEIGHT);
				buffer_set_surface(surfBuffer, textSurfaces[i], TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4 * i);
			}
		
			// If there are less elements in the log than can be drawn at once; ignore drawing the background
			// elements and surfaces as they would be displaying no text.
			if (i >= logSize)
				continue;
		
			// Set the values for the y positions of the surface that will draw the text that is logged, and
			// the background behind that text, respectively.
			_yOffset	= _yView + 25 + ((TBOXLOG_MAXIMUM_VISIBLE - 1 - i) * 50);
			_yBack		= _yOffset - TBOXLOG_BG_YPADDING;
		
		#region Drawing Background for Visible Log Text
		
				draw_sprite_ext( // Left edge of outline
					spr_rectangle, 
					0,		// Unused
					_xBack - 1, _yBack,
					1, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Right edge of outline
					spr_rectangle, 
					0,		// Unused
					_xBack + TBOX_SURFACE_WIDTH + 8, _yBack, 
					1, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Top edge of outline
					spr_rectangle, 
					0,		// Unused
					_xBack - 1, _yBack - 1, 
					TBOX_SURFACE_WIDTH + 10, 1, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Bottom edge of the outline
					spr_rectangle,
					0,		// Unused
					_xBack - 1, _yBack + TBOX_SURFACE_HEIGHT + 8, 
					TBOX_SURFACE_WIDTH + 10, 1, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Rectangle streteched to fill the outlined area
					spr_rectangle, 
					0,		// Unused
					_xBack, _yBack, 
					TBOX_SURFACE_WIDTH + 8, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_VERY_DARK_BLUE, 0.6 * alpha
				);
				
		#endregion Drawing Background for Visible Log Text
		
			// After constructing the background, display the message contents of this respective log on top
			// of that background by drawing the surface twice; once for the text itself, and another for its
			// drop shadow below.
			draw_surface_ext(textSurfaces[i], _xOffset + 1, _yOffset + 1, 1.0, 1.0, 0.0, 
				COLOR_DARK_GRAY, alpha * TBOX_TEXT_SHADOW_ALPHA);
			draw_surface_ext(textSurfaces[i], _xOffset, _yOffset, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha);
		}
		
		// Render the control group information to the screen.
		var _logSize			= logSize;
		var _movementCtrlGroup	= movementCtrlGroup;
		var _inputCtrlGroup		= inputCtrlGroup;
		with(CONTROL_UI_MANAGER){
			if (_logSize > TBOXLOG_MAXIMUM_VISIBLE) // Only show movement inputs when the history can be scrolled up or down.
				draw_control_group(_movementCtrlGroup, _xView, _yView, 1.0, COLOR_WHITE, COLOR_DARK_GRAY, 1.0); 
			draw_control_group(_inputCtrlGroup, _xView, _yView, 1.0, COLOR_WHITE, COLOR_DARK_GRAY, 1.0); 
		}
		
		// Exit the event here if the log doesn't need to re-render the visible text, as all the code from
		// this point on is related to rendering new data to each of the visible surfaces the log utilizes.
		if (!TBOXLOG_SHOULD_RENDER)
			return;
		flags = flags & ~TBOXLOG_FLAG_RENDER;
		
		// Set up the required font, and alignment in case they were changed during another UI rendering event
		// and not properly reset. Also set the alpha to complete opacity since the surface will have its alpha
		// altered if needed; not the text contained on it.
		draw_set_font(fnt_small);
		draw_set_alpha(1.0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		// Loop through each of the surfaces; rendering the text to them in a very similar way to how the text
		// in the textbox struct is rendered onto its surface for storing the current textbox's contents. The
		// main difference here is the process here is instantaneous instead of playing out a typing animation
		// to display the text.
		var _xCurChar		= 0;
		var _yCurChar		= 0;
		var _curChar		= "";
		var _curCharColor	= COLOR_WHITE;
		var _textLength		= 0;
		var _textHeight		= string_height("M"); // All use same font, so height will not change between them.
		var _isMultiColor	= true;
		var _charIndex		= 1;
		var _colorIndex		= 0;
		for (var i = 0; i < TBOXLOG_MAXIMUM_VISIBLE; i++){
			// Set the correct surface within the array and instantly clear whatever it previously contained.
			surface_set_target(textSurfaces[i]);
			draw_clear_alpha(COLOR_BLACK, 0.0);
			
			with(textData[| curOffset - i]){
				_textLength		= string_length(content);
				_isMultiColor	= (colorData != -1);

				// Loop through all characters within the text that is logged; drawing each character to the
				// screen one-by-one to allow for multi-colored text.
				while(_charIndex <= _textLength){
					_curChar = string_char_at(content, _charIndex);
					
					// When the text content contains multiple colors, it will applied to the relevant region
					// of text as needed until all of the text has been rendered to the surface.
					if (_isMultiColor){
						with(colorData[| _colorIndex]){
							if (_charIndex >= endIndex){ // The final index is hit; reset to color white and move to the next potential color.
								_curCharColor = COLOR_WHITE;
								_colorIndex++; 
							} else if (_charIndex >= startIndex){ // Apply the desired color for the region of text.
								_curCharColor = colorCode;
							}
						}
					}
					_charIndex++;
					
					// A newline character will ignore the automatic newline process done for the textbox and
					// the log, and will simply move onto the next line instantly.
					if (_curChar == CHAR_NEWLINE){
						_xCurChar	= 0;
						_yCurChar  += _textHeight;
						continue;
					}
					
					// Once the proper coordinates have been set as required, the character is drawn and the 
					// width of said character is added to properly offset the next character in the string.
					draw_text_shadow(_xCurChar, _yCurChar, _curChar, _curCharColor, TBOX_TEXT_ALPHA, COLOR_GRAY);
					_xCurChar += string_width(_curChar);
				}
			}
			
			// Copy the contents of the surface to its respective buffer.
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurfaces[i], TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4 * i);
			
			// Reset all values used in the loop for rendering the characters, and either exit the event if
			// this is the final surface to render to or loop over the process again for the next surface.
			_xCurChar		= 0;
			_yCurChar		= 0;
			_charIndex		= 1;
			_colorIndex		= 0;
		}
	}
	
	/// @description 
	///	Copies the data found in the provided struct's data (The text content, actor index, and color data) 
	/// into a new struct that will then continue to store that data until it is removed from memory by the
	/// textbox log exneeding its 100 element limit.
	///
	/// @param {Struct}		textRef		A reference to the text contents that will be added to the log.
	queue_new_text = function(_textRef){
		// Copy over the color date from the text struct that will be stored in the log. This requires creating
		// a new list and copying the data from the text struct into this new list. Otherwise, the reference
		// is only stored and when the original struct is deleted, that list goes with it; making the reference
		// useless.
		var _sourceColorData	= _textRef.colorData;
		var _colorData			= -1;
		if (ds_exists(_sourceColorData, ds_type_list)){
			_colorData = ds_list_create();
			ds_list_copy(_colorData, _textRef.colorData);
		}
		
		// Add a struct to the textbox log's data that is similarly structured to the text struct that is
		// brought over from the textbox. Then. toggle the flag that triggers a render of this data to one of
		// the surfaces so it will be visible when the log is opened by the player.
		ds_list_add(textData, {
			content		: _textRef.content,
			colorData	: _colorData,
			actorIndex	: 0,
		});
		flags = flags | TBOXLOG_FLAG_RENDER;
		
		// Update the offset of the textbox log so that it always starts off showing the newest element that
		// have been added to it (Or 0 if there are less than four elements total at the moment).
		var _size	= ds_list_size(textData);
		curOffset	= _size - 1;
		logSize		= _size;
		
		// Remove the oldest element from the list if the log has hit its limit of text it can hold onto.
		if (_size > TBOXLOG_MAXIMUM_STORED){
			ds_list_delete(textData, 0);
			curOffset--;
			logSize--;
		}
	}
	
	/// @description 
	/// Checks the state of the inputs that are utilized by the textbox log. The previous frame's inputs are
	/// stored in a "prevInputFlags" variable as standard across objects that utilize inputs, but the current
	/// frame's inputs are stored in the "flags" variable since there is plenty of room within it.
	/// 
	process_input = function(){
		prevInputFlags	= flags &  (TBOXLOG_INFLAG_UP | TBOXLOG_INFLAG_DOWN | TBOXLOG_INFLAG_CLOSE);
		flags			= flags & ~(TBOXLOG_INFLAG_UP | TBOXLOG_INFLAG_DOWN | TBOXLOG_INFLAG_CLOSE);
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			flags = flags | (MENU_PAD_UP				); // Offset based on position of the bit within the variable.
			flags = flags | (MENU_PAD_DOWN			<< 1);
			flags = flags | (MENU_PAD_RETURN		<< 2);
			return;
		}
		
		flags = flags | (MENU_KEY_UP				); // Offset based on position of the bit within the variable.
		flags = flags | (MENU_KEY_DOWN			<< 1);
		flags = flags | (MENU_KEY_RETURN		<< 2);
	}
}

#endregion Textbox Log Struct Definition