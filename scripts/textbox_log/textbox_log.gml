#region Macros for Textbox Log Struct

// 
#macro	TBOXLOG_FLAG_RENDER				0x00000001
#macro	TBOXLOG_FLAG_ACTIVE				0x00000002

// 
#macro	TBOXLOG_SHOULD_RENDER			((flags & TBOXLOG_FLAG_RENDER)		!= 0)
#macro	TBOXLOG_IS_ACTIVE				((flags & TBOXLOG_FLAG_ACTIVE)		!= 0)

// 
#macro	TBOXLOG_MAXIMUM_STORED			128
#macro	TBOXLOG_MAXIMUM_VISIBLE			3

// 
#macro	TBOXLOG_ICONUI_CTRL_GRP_MOVE	"tlog_icons_move"
#macro	TBOXLOG_ICONUI_CTRL_GRP_INPUT	"tlog_icons_input"

// 
#macro	TBOXLOG_CTRL_GRP_XOFFSET		5
#macro	TBOXLOG_CTRL_GRP_YOFFSET		12
#macro	TBOXLOG_CTRL_GRP_INPUT_PADDING	3
#macro	TBOXLOG_CTRL_GRP_MOVE_PADDING	2

// 
#macro	TBOXLOG_BG_XPADDING				4
#macro	TBOXLOG_BG_YPADDING				4

#endregion Macros for Textbox Log Struct

#region Textbox Log Struct Definition

/// @param {Function}	index	The value of "str_textbox_log" as determined by GameMaker during runtime.
function str_textbox_log(_index) : str_base(_index) constructor {
	flags				= STR_FLAG_PERSISTENT;
	
	// 
	prevInputFlags		= 0;
	
	// Determines the overall transparency level for every graphics element of the textbox log.
	alpha				= 0.0;
	
	// Since the y value of the textboxes isn't important, the y value isn't stored in a variable. However, the
	// x value is calculated within the textbox itself during its create event, and this value will be copied
	// into this variable so the x position of the textbox's text and the log's text are consistent.
	textX				= 0.0;
	
	// 
	textData			= ds_list_create();
	
	// 
	textSurfaces		= array_create(TBOXLOG_MAXIMUM_VISIBLE, -1);
	surfBuffer			= buffer_create(TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * TBOXLOG_MAXIMUM_VISIBLE * 4, 
							buffer_fixed, 4);
	
	// 
	curOffset			= 0;
	logSize				= 0;
	
	// 
	movementCtrlGroup	= REF_INVALID;
	inputCtrlGroup		= REF_INVALID;
	
	/// @description 
	///	
	///	
	create_event = function(){
		if (room != rm_init)
			return; // Prevents a call to this function from executing outside of the game's initialization.
		
		// 
		var _movementCtrlGroup	= REF_INVALID;
		var _inputCtrlGroup		= REF_INVALID;
		with(CONTROL_UI_MANAGER){
			// 
			_movementCtrlGroup = create_control_group(TBOXLOG_ICONUI_CTRL_GRP_MOVE,
				TBOXLOG_CTRL_GRP_XOFFSET, VIEWPORT_HEIGHT - TBOXLOG_CTRL_GRP_YOFFSET,
					TBOXLOG_CTRL_GRP_INPUT_PADDING, ICONUI_DRAW_RIGHT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_UP);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_DOWN, "Navigate");
			
			// 
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
	///	Called to render the textbox log and its currently visible contents whenever the textbox log struct is 
	/// currently showing the information it contains.
	///	
	///	@param {Real}	viewX		X position of the viewport within the current room.
	/// @parma {Real}	viewY		Y position of the viewport within the current room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_gui_event = function(_viewX, _viewY, _delta){
		#region Drawing Main Background for Textbox Log
		
			draw_sprite_ext( // Single rectangle to cover entire screen.
				spr_rectangle,
				0,		// Unused
				_viewX, _viewY, 
				VIEWPORT_WIDTH, VIEWPORT_HEIGHT, 
				0.0,	// Unused
				COLOR_BLACK, 0.75 * alpha
			);
				
		#endregion Drawing Main Background for Textbox Log
		
		// Don't bother rendering anything other than the main background if the log is empty.
		if (logSize == 0)
			return;
		
		// Come local values that are used by the scrollbar and its background element. The X value is basically
		// shared between the two (The background for the bar is one pixel to the left), but the Y values will
		// differ once enough entries exist in the log. So, two Y variables are created; one for the position
		// of both the scrollbar and the background (Background is one pixel down), and the other for the offset
		// of the bar relative to that topmost position. Finally, the height is set and also adjusted when there
		// are enough elements within the log to require scrollbar movement.
		var _scrollbarX		= _viewX + VIEWPORT_WIDTH - 9;
		var _scrollbarY1	= _viewY + 15;
		var _scrollbarY2	= 0;
		var _scrollbarH		= 145;
		
		// Once the log has grown large enough, the scrollbar will need to be sized and positioned accordingly.
		// So, the maximum possible value that "curOffset" can be (This is two below the actual log size) will
		// be the denominator in the calculations for size (_scrollbarH) and position (_scrollbarY2).
		if (logSize > TBOXLOG_MAXIMUM_VISIBLE){
			var _curOffsetMax	= (logSize - TBOXLOG_MAXIMUM_VISIBLE) + 1; // Without the + 1 the values will all be off by one element's amount.
			_scrollbarY2		= (145 * ((curOffset - (TBOXLOG_MAXIMUM_VISIBLE - 1)) / _curOffsetMax));
			_scrollbarH			= 145 / _curOffsetMax; // Shrink the scrollbar as more elements are added to the log.
		}
		
		#region Drawing Scrollbar on Left Edge of Textbox Log
		
			draw_sprite_ext( // Background for Scrollbar
				spr_rectangle,
				0,		// Unused
				_scrollbarX + 1, _scrollbarY1 + 1, 
				2, 143,
				0.0,	// Unused
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // The Scrollbar itself
				spr_rectangle,
				0,		// Unused
				_scrollbarX, _scrollbarY1 + _scrollbarY2,
				4, _scrollbarH,
				0.0,	// Unused
				COLOR_WHITE, alpha
			);
		
		#endregion Drawing Scrollbar on Left Edge of Textbox Log

		// 
		var _bgX		= 0;
		var _bgY		= 0;
		var _xOffset	= 0;
		var _yOffset	= 0;
		for (var i = 0; i < TBOXLOG_MAXIMUM_VISIBLE; i++){
			if (!surface_exists(textSurfaces[i])){
				textSurfaces[i] = surface_create(TBOX_SURFACE_WIDTH, TBOX_SURFACE_HEIGHT);
				buffer_set_surface(surfBuffer, textSurfaces[i], TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4 * i);
			}
		
			// If there are less elements in the log than can be drawn at once; ignore drawing the background
			// elements and surfaces as they would be displaying no text.
			if (i >= logSize)
				continue;
		
			// 
			_xOffset	= _viewX + textX + TBOX_TEXT_X_OFFSET;
			_yOffset	= _viewY + 25 + ((TBOXLOG_MAXIMUM_VISIBLE - 1 - i) * 50);
			_bgX		= _xOffset - TBOXLOG_BG_XPADDING;
			_bgY		= _yOffset - TBOXLOG_BG_YPADDING;
		
		#region Drawing Background for Visible Log Text
		
				draw_sprite_ext( // Left edge of outline
					spr_rectangle, 
					0,		// Unused
					_bgX - 1, _bgY,
					1, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Right edge of outline
					spr_rectangle, 
					0,		// Unused
					_bgX + TBOX_SURFACE_WIDTH + 8, _bgY, 
					1, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Top edge of outline
					spr_rectangle, 
					0,		// Unused
					_bgX - 1, _bgY - 1, 
					TBOX_SURFACE_WIDTH + 10, 1, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Bottom edge of the outline
					spr_rectangle,
					0,		// Unused
					_bgX - 1, _bgY + TBOX_SURFACE_HEIGHT + 8, 
					TBOX_SURFACE_WIDTH + 10, 1, 
					0.0,	// Unused
					COLOR_DARK_GRAY, alpha
				);
				draw_sprite_ext( // Rectangle streteched to fill the outlined area
					spr_rectangle, 
					0,		// Unused
					_bgX, _bgY, 
					TBOX_SURFACE_WIDTH + 8, TBOX_SURFACE_HEIGHT + 8, 
					0.0,	// Unused
					COLOR_VERY_DARK_BLUE, 0.6 * alpha
				);
				
		#endregion Drawing Background for Visible Log Text
		
			// After constructing the background, display the message contents of this respective log on top
			// of that background.
			draw_surface_ext(textSurfaces[i], _xOffset, _yOffset, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha);
		}
		
		// 
		var _logSize			= logSize;
		var _movementCtrlGroup	= movementCtrlGroup;
		var _inputCtrlGroup		= inputCtrlGroup;
		with(CONTROL_UI_MANAGER){
			if (_logSize > TBOXLOG_MAXIMUM_VISIBLE) // Only show movement inputs when the history can be scrolled up or down.
				draw_control_group(_movementCtrlGroup, _viewX, _viewY, 1.0, COLOR_WHITE, COLOR_DARK_GRAY, 1.0); 
			draw_control_group(_inputCtrlGroup, _viewX, _viewY, 1.0, COLOR_WHITE, COLOR_DARK_GRAY, 1.0); 
		}
		
		// 
		if (!TBOXLOG_SHOULD_RENDER)
			return;
		flags = flags & ~TBOXLOG_FLAG_RENDER;
		
		// 
		draw_set_font(fnt_small);
		draw_set_alpha(1.0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		// 
		var _charX			= 0;
		var _charY			= 0;
		var _textLength		= 0;
		var _curChar		= "";
		var _curColor		= COLOR_WHITE;
		var _curColorIndex	= 0;
		var _numColors		= 0;
		var _curCharIndex	= 1;
		var _isMultiColor	= true;
		for (var i = 0; i < TBOXLOG_MAXIMUM_VISIBLE; i++){
			// 
			surface_set_target(textSurfaces[i]);
			draw_clear_alpha(COLOR_BLACK, 0.0);
			
			with(textData[| curOffset - i]){
				_textLength		= string_length(content);
				_isMultiColor	= (colorData != -1);
				_numColors		= _isMultiColor ? ds_list_size(colorData) : 0;
				
				// 
				while(_curCharIndex <= _textLength){
					_curChar = string_char_at(content, _curCharIndex);
					
					// 
					if (_isMultiColor){
						with(colorData[| _curColorIndex]){
							if (_curCharIndex >= endIndex){ // The final index is hit; reset to color white and move to the next potential color.
								_curColor = COLOR_WHITE;
								_curColorIndex++; 
							} else if (_curCharIndex >= startIndex){ // Apply the desired color for the region of text.
								_curColor = colorCode;
							}
						}
					}
					_curCharIndex++;
					
					// 
					if (_curChar == CHAR_NEWLINE){
						_charX	= 0;
						_charY  += string_height("M");
						continue;
					}
					
					// Once the proper coordinates have been set as required, the character is drawn and the 
					// width of said character is added to properly offset the next character in the string.
					draw_text_shadow(_charX, _charY, _curChar, _curColor, TBOX_TEXT_ALPHA, COLOR_GRAY);
					_charX += string_width(_curChar);
				}
			}
			
			// 
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurfaces[i], TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4 * i);
			
			// 
			_charX			= 0;
			_charY			= 0;
			_curCharIndex	= 1;
			_curColorIndex	= 0;
		}
	}
	
	/// @description 
	///	Copies the data found in the provided struct's data (The text content, actor index, and color data) 
	/// into a new struct that will then continue to store that data until it is removed from memory by the
	/// textbox log exneeding its 100 element limit.
	///
	/// @param {Struct}		textRef		A reference to the text contents that will be added to the log.
	queue_new_text = function(_textRef){
		// 
		var _sourceColorData	= _textRef.colorData;
		var _colorData			= -1;
		if (ds_exists(_sourceColorData, ds_type_list)){
			_colorData = ds_list_create();
			ds_list_copy(_colorData, _textRef.colorData);
		}
		
		// 
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
}

#endregion Textbox Log Struct Definition