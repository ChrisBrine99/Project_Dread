#macro	TEXTBOX_WIDTH					280
#macro	TEXTBOX_HEIGHT					30

#macro	TEXTBOX_X_PADDING				2
#macro	TEXTBOX_Y_PADDING				4

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_textbox(_index) : str_base(_index) constructor {
	x			= 0.0;
	y			= 0.0;
	
	textSurface = -1;
	surfBuffer	= buffer_create(TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4, buffer_fixed, 4);
	
	textQueue	= ds_queue_create();
	textLength	= 0;
	
	curChar		= 1;
	nextChar	= 1;
	
	destroy_event = function(){
		if (surface_exists(textSurface))
			surface_free(textSurface);
		buffer_delete(surfBuffer);
		
		var _data = 0;
		while(ds_queue_size(textQueue) > 0){
			_data = ds_queue_head(textQueue);
			delete _data;
			ds_queue_dequeue(textQueue);
		}
		ds_queue_destroy(textQueue);
	}
	
	///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
		if (ds_queue_size(textQueue) == 0)
			return;
		
		if (nextChar == textLength){
			return;
		}
		
		nextChar += _delta;
		//if (keyboard_check_pressed(
	}
	
	///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
	draw_gui_event = function(_delta){
		if (ds_queue_size(textQueue) == 0)
			return;
			
		if (!surface_exists(textSurface)){
			textSurface = surface_create(TEXTBOX_WIDTH, TEXTBOX_HEIGHT);
			buffer_set_surface(surfBuffer, textSurface, 0);
		}
		
		// 
		if (typeTimer == 0.0 && curChar < floor(nextChar)){
			surface_set_target(textSurface);
			
			
			
			surface_reset_target();
			buffer_get_surface(surfBuffer, textSurface, 0);
		}

		draw_surface(textSurface, floor(x), floor(y));
	}
	
	/// @description 
	///	
	///	
	///	@param {String}	text		The text to format and enqueue for the textbox to display when ready.
	/// @param {Real}	typeSpeed	Determines how fast the text will type onto the screen relative to the global text speed setting.
	/// @param {Real}	punctSpeed	Determines how long any punctuation (',', '.', '?', '!', and '...') will pause the typing of textbox characters for relative to the global text speed.
	queue_new_text = function(_text, _typeSpeed, _punctSpeed){
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
					_curLineWidth	= _curWordWidth;
					_curLine		= _curWord;
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
		if (_curLine != "") { _fullText += _curLine; }
		ds_queue_enqueue(textQueue, {
			text		: _fullText,
			typeSpeed	: _typeSpeed,
			punctSpeed	: _punctSpeed
		});
	}
}