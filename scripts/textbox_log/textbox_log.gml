#region Macros for Textbox Log Struct

// 
#macro	TBOXLOG_FLAG_RENDER				0x00000001
#macro	TBOXLOG_FLAG_ACTIVE				0x00000002

// 
#macro	TBOXLOG_SHOULD_RENDER			(flags & TBOXLOG_FLAG_RENDER)
#macro	TBOXLOG_IS_ACTIVE				(flags & TBOXLOG_FLAG_ACTIVE)

// 
#macro	TBOXLOG_MAXIMUM_STORED			100
#macro	TBOXLOG_MAXIMUM_VISIBLE			4

#endregion Macros for Textbox Log Struct

#region Textbox Log Struct Definition

/// @param {Function}	index	The value of "str_textbox_log" as determined by GameMaker during runtime.
function str_textbox_log(_index) : str_base(_index) constructor {
	flags				= STR_FLAG_PERSISTENT;
	
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
		// 
		draw_sprite_ext(spr_rectangle, 0, _viewX, _viewY, VIEWPORT_WIDTH, VIEWPORT_HEIGHT, 
			0.0, COLOR_BLACK, 0.75 * alpha);
		
		// 
		var _length = array_length(textSurfaces);
		for (var i = 0; i < _length; i++){
			if (!surface_exists(textSurfaces[i])){
				textSurfaces[i] = surface_create(TBOX_SURFACE_WIDTH, TBOX_SURFACE_HEIGHT);
				buffer_set_surface(surfBuffer, textSurfaces[i], TBOX_SURFACE_WIDTH * TBOX_SURFACE_HEIGHT * 4 * i);
			}
			
			draw_surface_ext(textSurfaces[i], _viewX + textX + TBOX_TEXT_X_OFFSET, _viewY + 120 - (i * 30), 
				1.0, 1.0, 0.0, COLOR_TRUE_WHITE, alpha);
		}
		
		// 
		if (!TBOXLOG_SHOULD_RENDER)
			return;
		flags &= ~TBOXLOG_FLAG_RENDER;
		
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
		for (var i = 0; i < _length; i++){
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
		flags |= TBOXLOG_FLAG_RENDER;
		
		// Update the offset of the textbox log so that it always starts off showing the newest element that
		// have been added to it (Or 0 if there are less than four elements total at the moment).
		var _size = ds_list_size(textData);
		curOffset = _size - 1;
		
		// Remove the oldest element from the list if the log has hit its limit of text it can hold onto.
		if (_size > TBOXLOG_MAXIMUM_STORED){
			ds_list_delete(textData, 0);
			curOffset--;
		}
	}
}

#endregion Textbox Log Struct Definition