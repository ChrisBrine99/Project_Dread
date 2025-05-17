// 
#macro	TEXTBOX_WIDTH					280
#macro	TEXTBOX_HEIGHT					30

// 
#macro	TEXTBOX_X_PADDING				2
#macro	TEXTBOX_Y_PADDING				4

// 
#macro	TBOX_INFLAG_ADVANCE				0x00000001
#macro	TBOX_INFLAG_TEXT_LOG			0x00000002
#macro	TBOX_FLAG_ACTIVE				0x00000004
#macro	TBOX_FLAG_CLEAR_SURFACE			0x00000008

// 
#macro	TBOX_WAS_ADVANCE_PRESSED		((flags & TBOX_INFLAG_ADVANCE)	&& !(prevInputFlags & TBOX_INFLAG_ADVANCE))
#macro	TBOX_WAS_TEXT_LOG_PRESSED		((flags & TBOX_INFLAG_TEXT_LOG)	&& !(prevInputFlags & TBOX_INFLAG_TEXT_LOG))
#macro	TBOX_IS_ACTIVE					(flags & TBOX_FLAG_ACTIVE)
#macro	TBOX_SHOULD_CLEAR_SURFACE		(flags & TBOX_FLAG_CLEAR_SURFACE)

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_textbox(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// 
	x				= 0.0;
	y				= 120.0;
	
	// 
	textSurface		= -1;
	surfBuffer		= buffer_create(TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4, buffer_fixed, 4);
	
	// 
	textData		= ds_list_create();
	textIndex		= 0;
	nextIndex		= 0;
	textLength		= 0;
	
	// 
	prevInputFlags	= 0;
	
	// 
	curChar			= 1;
	nextChar		= 1;
	charX			= 0;
	charY			= 0;
	
	destroy_event = function(){
		if (surface_exists(textSurface))
			surface_free(textSurface);
		buffer_delete(surfBuffer);
		
		deactivate_textbox();
		ds_list_destroy(textData);
	}
	
	///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
		// 
		if (!TBOX_IS_ACTIVE)
			return;
		process_textbox_input();
		
		// 
		if (nextChar == textLength){
			if (TBOX_WAS_ADVANCE_PRESSED){
				if (nextIndex == -1){
					deactivate_textbox();
					return;
				}
				flags |= TBOX_FLAG_CLEAR_SURFACE;
				
				var _textData	= textData[| nextIndex];
				textLength		= string_length(_textData.data) + 1;
				textIndex		= nextIndex;
				nextIndex		= _textData.nextIndex;
				curChar			= 1;
				nextChar		= 1;
				charX			= 0;
				charY			= 0;
			}
			return;
		}
		
		// 
		nextChar += _delta;
		if (TBOX_WAS_ADVANCE_PRESSED || nextChar > textLength)
			nextChar = textLength;
	}
	
	draw_gui_event = function(){
		// 
		if (!surface_exists(textSurface)){
			textSurface = surface_create(TEXTBOX_WIDTH, TEXTBOX_HEIGHT);
			buffer_set_surface(surfBuffer, textSurface, 0);
		}
		
		// 
		if (TBOX_SHOULD_CLEAR_SURFACE){
			flags &= ~TBOX_FLAG_CLEAR_SURFACE;
			surface_set_target(textSurface);
			draw_clear_alpha(c_black, 0.0);
			surface_reset_target();
		}
		
		// 
		var _nextChar = floor(nextChar);
		if (TBOX_IS_ACTIVE && curChar < _nextChar){
			surface_set_target(textSurface);
				
			// 
			draw_set_font(fnt_small);
			draw_set_color(c_white);
			
			// 
			var _curText = textData[| textIndex];
			var _curChar = "";
			while(curChar < _nextChar){
				_curChar = string_char_at(_curText.data, curChar);
				curChar += 1;
				
				// 
				if (_curChar == "\n"){
					charX	= 0;
					charY  += string_height("M");
					continue;
				}
				
				draw_text(charX, charY,	_curChar);
				charX   += string_width(_curChar);
			}
			
			// 
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurface, 0);
		}

		// 
		var _xPos = floor(x);
		var _yPos = floor(y);
		draw_surface_ext(textSurface, _xPos, _yPos, 1.0, 1.0, 0.0, c_white, 1.0);
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
	///	
	///	
	///	@param {Real}	startingIndex	Determines which text out of the list is used as the first in the textbox.	
	activate_textbox = function(_startingIndex){
		var _size = ds_list_size(textData);
		if (TBOX_IS_ACTIVE || _size == 0 || _size <= _startingIndex)
			return;
		flags |= TBOX_FLAG_ACTIVE | TBOX_FLAG_CLEAR_SURFACE;
		
		// 
		var _textData	= textData[| _startingIndex];
		textLength		= string_length(_textData.data) + 1;
		textIndex		= _startingIndex;
		nextIndex		= _textData.nextIndex;
		curChar			= 1;
		nextChar		= 1;
		charX			= 0;
		charY			= 0;
	}
	
	/// @description
	///	
	///	
	deactivate_textbox = function(){
		flags &= ~TBOX_FLAG_ACTIVE;
		
		var _length = ds_list_size(textData);
		for (var i = 0; i < _length; i++)
			delete textData[| i];
		ds_list_clear(textData);
	}
	
	/// @description 
	///	
	///	
	///	@param {String}	text		The text to format and enqueue for the textbox to display when ready.
	///	@param {Real}	nextIndex	(Optional) Determines which textbox out of the current data is after this one.
	queue_new_text = function(_text, _nextIndex = -1){
		var _size = ds_list_size(textData);
		if (_nextIndex < -1 || _nextIndex >= _size)
			return;
		
		draw_set_font(fnt_small); // Ensures proper font is used for size calculations.
		var _curWordWidth	= 0;
		var _curLineWidth	= 0;
		var _curChar		= "";
		var _curLine		= "";
		var _curWord		= "";
		var _fullText		= "";
		var _length			= string_length(_text);
		for (var i = 1; i <= _length; i++){
			_curChar = string_char_at(_text, i);
			
			// 
			if (_curChar == " " || i == _length){
				// 
				if (_curLineWidth + _curWordWidth > TEXTBOX_WIDTH + TEXTBOX_X_PADDING){
					_fullText	   += _curLine + "\n";
					_curLineWidth	= _curWordWidth + string_width(" ");
					_curLine		= _curWord + " ";
				} else{ // Line has more space; keep adding to it.
					_curLineWidth  += _curWordWidth + string_width(_curChar);
					_curLine	   += _curWord + _curChar;
				}
				_curWordWidth	= 0;
				_curWord		= "";
				continue;
			}
			
			// 
			if (_curChar == "\n"){
				_fullText	   += _curLine + _curWord + "\n";
				_curLineWidth	= 0;
				_curLine		= "";
				_curWordWidth	= 0;
				_curWord		= "";
				continue;
			}
			
			_curWordWidth  += string_width(_curChar);
			_curWord	   += _curChar;
		}
		
		// 
		if (_curLine != "") 
			_fullText += _curLine;
		
		// 
		ds_list_add(textData, {
			data		: _fullText,
			nextIndex	: _nextIndex,
		});
	}
}