#region Color Hex Value Macros

// -------------------------- //
// --- SHADE COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_TRUE_WHITE				0xFFFFFF	// BGR 255, 255, 255
#macro	COLOR_WHITE						0xF8F8F8	// BGR 248, 248, 248
#macro	COLOR_VERY_LIGHT_GRAY			0xD8D8D8	// BGR 216, 216, 216
#macro	COLOR_LIGHT_GRAY				0xBCBCBC	// BGR 188, 188, 188
#macro	COLOR_GRAY						0x7F7F7F	// BGR 127, 127, 127
#macro	COLOR_DARK_GRAY					0x404040	// BGR  64,  64,  64
#macro	COLOR_VERY_DARK_GRAY			0x202020	// BGR  32,  32,  32
#macro	COLOR_BLACK						0x000000	// BGR   0,   0,   0

// -------------------------- //
// ---- RED COLOR CODES ----- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_RED			0xBCBCF8	// BGR 188, 188, 248
#macro	COLOR_LIGHT_RED					0x3050F8	// BGR  48,  80, 248
#macro	COLOR_RED						0x0010E0	// BGR   0,  16, 224
#macro	COLOR_DARK_RED					0x0010BC	// BGR   0,  16, 168
#macro	COLOR_VERY_DARK_RED				0x000058	// BGR   0,   0,  88

// -------------------------- //
// ---- LIME COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_LIME			0xBCF8E0	// BGR 224, 248, 188
#macro	COLOR_LIGHT_LIME				0x94F8BC	// BGR 148, 248, 188
#macro	COLOR_LIME						0x58F890	// BGR  88, 248, 144
#macro	COLOR_DARK_LIME					0x30F868	// BGR  48, 248, 104
#macro	COLOR_VERY_DARK_LIME			0x00E040	// BGR   0, 224,  64

// -------------------------- //
// --- GREEN COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_GREEN			0x7CF87C	// BGR 124, 248, 124
#macro	COLOR_LIGHT_GREEN				0x00F800	// BGR   0, 248,   0
#macro	COLOR_GREEN						0x00BC00	// BGR   0, 188,   0
#macro	COLOR_DARK_GREEN				0x008C00	// BGR   0, 140,   0
#macro	COLOR_VERY_DARK_GREEN			0x006400	// BGR   0, 100,   0

// -------------------------- //
// ---- CYAN COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_CYAN			0xF8F87C	// BGR 248, 248, 124
#macro	COLOR_LIGHT_CYAN				0xF8F830	// BGR 248, 248,  48
#macro	COLOR_CYAN						0xCCCC00	// BGR 204, 204,   0
#macro	COLOR_DARK_CYAN					0xA0A000	// BGR 160, 160,   0
#macro	COLOR_VERY_DARK_CYAN			0x7C7C00	// BGR 124, 124,   0

// -------------------------- //
// ---- BLUE COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_BLUE			0xF8A47C	// BGR 248, 164, 124
#macro	COLOR_LIGHT_BLUE				0xF87C58	// BGR 248, 124,  88
#macro	COLOR_BLUE						0xF84020	// BGR 248,  64,  32
#macro	COLOR_DARK_BLUE					0xBC2010	// BGR 188,  32,  16
#macro	COLOR_VERY_DARK_BLUE			0x7C0000	// BGR 124,   0,   0

// -------------------------- //
// --- YELLOW COLOR CODES --- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_YELLOW			0xA8F8F8	// BGR 168, 248, 248
#macro	COLOR_LIGHT_YELLOW				0x7CF8F8	// BGR 124, 248, 248
#macro	COLOR_YELLOW					0x00F8F8	// BGR   0, 248, 248
#macro	COLOR_DARK_YELLOW				0x00ACAC	// BGR   0, 172, 172
#macro	COLOR_VERY_DARK_YELLOW			0x005050	// BGR   0,  80,  80

// -------------------------- //
// --- ORANGE COLOR CODES --- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_ORANGE			0xA8D0F8	// BGR 168, 208, 248
#macro	COLOR_LIGHT_ORANGE				0x44BCF8	// BGR  68, 188, 248
#macro	COLOR_ORANGE					0x10A0E4	// BGR  16, 160, 248
#macro	COLOR_DARK_ORANGE				0x0050BC	// BGR   0,  80, 188
#macro	COLOR_VERY_DARK_ORANGE			0x003088	// BGR   0,  48, 136

// -------------------------- //
// --- PURPLE COLOR CODES --- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_PURPLE			0xF8B8D8	// BGR 248, 184, 216
#macro	COLOR_LIGHT_PURPLE				0xF894B8	// BGR 248, 148, 184
#macro	COLOR_PURPLE					0xF87898	// BGR 248, 120, 152
#macro	COLOR_DARK_PURPLE				0xF84468	// BGR 248,  68, 104
#macro	COLOR_VERY_DARK_PURPLE			0xBC2844	// BGR 188,  40,  68

// -------------------------- //
// ---- PINK COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_PINK			0xE4CCF8	// BGR 228, 204, 248
#macro	COLOR_LIGHT_PINK				0xE47CF8	// BGR 228, 124, 248
#macro	COLOR_PINK						0xE400F8	// BGR 228,   0, 248
#macro	COLOR_DARK_PINK					0xA400BC	// BGR 164,   0, 188
#macro	COLOR_VERY_DARK_PINK			0x6E007C	// BGR 110,   0, 124

// -------------------------- //
// ---- BROWN COLOR CODES --- //
// -------------------------- //
#macro	COLOR_VERY_LIGHT_BROWN			0x0094CC	// BGR   0, 148, 204
#macro	COLOR_LIGHT_BROWN				0x006CA4	// BGR   0, 108, 164
#macro	COLOR_BROWN						0x00588A	// BGR   0,  88, 138
#macro	COLOR_DARK_BROWN				0x003058	// BGR   0,  48,  88
#macro	COLOR_VERY_DARK_BROWN			0x001830	// BGR   0,  24,  48

#endregion Color Hex Value Macros

#region Macros for "vk_*" Constants not Included by GameMaker

// Virtual keyboard constants for all keyboard keys that don't have built-in vk constants already.
#macro	vk_0							0x30	// Top-row number keys
#macro	vk_1							0x31
#macro	vk_2							0x32
#macro	vk_3							0x33
#macro	vk_4							0x34
#macro	vk_5							0x35
#macro	vk_6							0x36
#macro	vk_7							0x37
#macro	vk_8							0x38
#macro	vk_9							0x39
#macro	vk_a							0x41	// Alphabet keys
#macro	vk_b							0x42
#macro	vk_c							0x43
#macro	vk_d							0x44
#macro	vk_e							0x45
#macro	vk_f							0x46
#macro	vk_g							0x47
#macro	vk_h							0x48
#macro	vk_i							0x49
#macro	vk_j							0x4A
#macro	vk_k							0x4B
#macro	vk_l							0x4C
#macro	vk_m							0x4D
#macro	vk_n							0x4E
#macro	vk_o							0x4F
#macro	vk_p							0x50
#macro	vk_q							0x51
#macro	vk_r							0x52
#macro	vk_s							0x53
#macro	vk_t							0x54
#macro	vk_u							0x55
#macro	vk_v							0x56
#macro	vk_w							0x57
#macro	vk_x							0x58
#macro	vk_y							0x59
#macro	vk_z							0x5A
#macro	vk_capslock						0x14	// All remaining keys
#macro	vk_numberlock					0x90
#macro	vk_scrolllock					0x91
#macro	vk_semicolon					0xBA	// Also ":"
#macro	vk_equal						0xBB	// Also "+"
#macro	vk_comma						0xBC	// Also "<"
#macro	vk_underscore					0xBD	// Also "-"
#macro	vk_period						0xBE	// Also ">"
#macro	vk_forwardslash					0xBF	// Also "?"
#macro	vk_tilde						0xC0	// Also "`"
#macro	vk_openbracket					0xDA	// Also "{"
#macro	vk_backslash					0xDC	// Also "|"
#macro	vk_closebracket					0xDD	// Also "}"
#macro	vk_quotation					0xDE	// Also "'"

#endregion Macros for "vk_*" Constants not Included by GameMaker

#region General Macros

// The value that equates to one second of real-time in the game's units. An example would be an entity with
// a speed value of 1.0 would move roughly 60 pixels per second.
#macro	GAME_TARGET_FPS					60.0

// The maximum possible delta that the game can have; equivalent to roughly 10 frames per second. Anything
// lower than that will have the game slow down to prevent any glitches or bugs because of a massive delta
// value.
#macro	GAME_MAX_DELTA					6.0

// A catchall for some ID that is considered invalid (Ex. item IDs, data structure IDs, etc.).
#macro	ID_INVALID					   -16

// Another catchall like above, but for references to objects/structs that are considered invalid.
#macro	REF_INVALID					   -32

// Macros for characters that are used throughout the games code for various purposes; from parsing data for 
// items when they're loaded into the game, to punctuation pauses during the textbox's "typing" animation, and
// so on.
#macro	CHAR_SPACE						" "
#macro	CHAR_COMMA						","
#macro	CHAR_COLON						":"
#macro	CHAR_SEMICOLON					";"
#macro	CHAR_PERIOD						"."
#macro	CHAR_QUESTION					"?"
#macro	CHAR_EXCLAIM					"!"
#macro	CHAR_NEWLINE					"\n"
#macro	CHAR_COLOR_CHANGE				"@"
#macro	CHAR_REGION_START				"{"
#macro	CHAR_REGION_END					"}"

// Macros for how color data should be formatted within a string of text. It must be 0xBBGGRR otherwise the
// value is ignored and defaulted to the macro COLOR_DARK_GRAY.
#macro	HEX_CODE_PREFIX					"0x"
#macro	COLOR_CODE_LENGTH				8		// Number of characters including the "0x" prefix

// Macros for the dimensions of the tile graphics used by the game.
#macro	TILE_WIDTH						16
#macro	TILE_HEIGHT						16

// Macros that explain what each tile index in the floor materials tileset refers to within the player's step
// sound effect logic, so it will know the proper sound to play relative to the material they are moving on.
#macro	TILE_INDEX_FLOOR_TILE			1
#macro	TILE_INDEX_FLOOR_WATER			2
#macro	TILE_INDEX_FLOOR_WOOD			3
#macro	TILE_INDEX_FLOOR_GRASS			4

#endregion General Macros

#region Drawing Functions

/// @description 
///	A expanded version of the built-in draw_text function that will apply a drop shadow to any text rendered.
/// This drop shadow is placed one pixel to the right and one pixel down from the text's actual coordinates.
///	
///	@param {Real}			x			Position along the x axis that the text will be aligned to when rendered.
/// @param {Real}			y			Position along the y axis that the text will be aligned to when rendered.
/// @param {Real}			text		The string of characters that will rendered onto the screen.
/// @param {Constant.Color}	color		(Optional) Color to use when rendering the text. The default color is white.
/// @param {Real}			alpha		(Optional) Opacity of the text (Ranging from 0.0 to 1.0). The default opacity is 1.0 or completely opaque.
/// @param {Constant.Color}	shadowColor	(Optional) Color to use for the text's drop shadow. The default color used is black.
/// @param {Real}			shadowAlpha	(Optional) Opacity of the text's drop shadow (Ranging from 0.0 to 1.0). The default opacity is set to 0.75 or ~75% opaque.
function draw_text_shadow(_x, _y, _text, _color = c_white, _alpha = 1.0, _shadowColor = c_black, _shadowAlpha = 0.75){
	if (string_length(_text) == 0)
		return; // Don't bother attempting to draw an empty string of text.
	
	draw_set_alpha(_alpha * _shadowAlpha);	// The three lines responsible for drawing the drop shadow.
	draw_set_color(_shadowColor);
	draw_text(_x + 1, _y + 1, _text);
	
	draw_set_alpha(_alpha);	 // The three lines responsible for drawing the main string of text.
	draw_set_color(_color);
	draw_text(_x, _y, _text);
}

/// @description 
///	An extension of the above defined "draw_text_with_shadow" function. It allows the drawn text to be blended
/// with up to four unique colors. On top of that, it also allows the drop shadow to be positioned as required
/// by the shadowX and shadowY fucntion parameters.
///	
/// @param {Real}			x			Position along the x axis that the text will be aligned to when rendered.
/// @param {Real}			y			Position along the y axis that the text will be aligned to when rendered.
/// @param {String}			text		The string of characters that will rendered onto the screen.
/// @param {Constant.Color}	color1		(Optional) One of the four colors (The top-left corner) that is used for the rendered text.
/// @param {Constant.Color}	color2		(Optional) One of the four colors (The top-right corner) that is used for the rendered text.
/// @param {Constant.Color}	color3		(Optional) One of the four colors (The bottom-right corner) that is used for the rendered text.
/// @param {Constant.Color}	color4		(Optional) One of the four colors (The bottom-left corner) that is used for the rendered text.
/// @param {Real}			alpha		(Optional) Opacity of the text (Ranging from 0.0 to 1.0). The default opacity is 1.0 or completely opaque.
///	@param {Constant.Color}	shadowColor	(Optional) Color to use for the text's drop shadow. The default color used is black.
/// @param {Real}			shadowAlpha	(Optional) Opacity of the text's drop shadow (Ranging from 0.0 to 1.0). The default opacity is set to 0.75 or ~75% opaque.
/// @param {Real}			shadowX		(Optional) Relative horizontal offset for the text's drop shadow. The default offset is one pixel to the right.
/// @param {Real}			shadowY		(Optional) Relative vertical offset for the text's drop shadow. The default offset is one pixel down.
function draw_text_shadow_ext(_x, _y, _text, _color1 = c_white, _color2 = c_white, _color3 = c_white, _color4 = c_white, _alpha = 1.0, _shadowColor = c_black, _shadowAlpha = 0.75, _shadowX = 1, _shadowY = 1){
	if (string_length(_text) == 0)
		return; // Don't bother attempting to draw an empty string of text.
	
	draw_set_alpha(_alpha * _shadowAlpha);	// Three lines are responsible for drawing the drop shadow.
	draw_set_color(_shadowColor);
	draw_text(_x + _shadowX, _y + _shadowY, _text);
	
	// Then, the text is drawn on top of the shadow text that was drawn previously.
	draw_text_color(_x, _y, _text, _color1, _color2, _color3, _color4, _alpha);
}

/// @description 
///	An extension of the standard draw_circle/draw_ellipse functions that allows the alpha channel to be set
/// as well as two colors that can create a gradient across the final output. Arguments are also made to be
/// more intuitive compared to draw_ellipse and draw_ellipse_color with their confusing x1, y1, x2, and y2
///	values for the parameters that determine how the resulting ellipse will appear.
///	
///	@param {Real}			x			Centerpoint of the circle/ellipse on the horizontal axis.
/// @param {Real}			y			Centerpoint of the circle/ellipse on the vertical axis.
///	@param {Real}			xRadius		Radius of the circle/ellipse when parallel to the x axis.
/// @param {Real}			yRadius		Radius of the circle/ellipse when parallel to the y axis.
/// @param {Constant.Color}	innerColor	Color at the centerpoint of the circle/ellipse.
/// @param {Constant.Color}	outerColor	Color at the circumference of the circle/ellipse.
/// @param {Real}			alpha		Overall opacity of the circle/ellipse.
function draw_circle_ext(_x, _y, _xRadius, _yRadius, _innerColor, _outerColor, _alpha){
	draw_set_alpha(_alpha);
	draw_ellipse_color(
		_x - _xRadius, _y - _yRadius,
		_x + _xRadius, _y + _yRadius,
		_innerColor, _outerColor,
		false
	);
}

#endregion Drawing Functions

#region Audio Playback Functions

/// @description 
///	An extension of GameMaker's audio playback function that applies the game's current master volume and 
/// sound effect volume to determine how loud the playback will be relative to the optionally set volume value.
///	Also allows previous instances of the sound to be stopped prior to playing said sound asset if required.
///	
///	@param {Asset.GMSound}	sound			Index of the audio asset that will be played.
/// @param {Real}			soundType		(Optional) Determines which volume setting group the sound belongs to.
/// @param {Real}			volume			(Optional) Determines the volume of the sound BEFORE adjustments are made by the game's volume setting values.
/// @param {Real}			pitch			(Optional) Pitch of the sound effect relative to its default pitch (This is equivalent to a pitch of 1.0).
/// @param {Real}			priority		(Optional) Sets the channel priority for the sound (Default is 0).
/// @param {Bool}			stopPrevious	(Optional) When true, previous instances of the sound's
/// @param {Bool}			loops			(Optional) When true, the sound will loop indefinitely.
/// @param {Real}			offset			(Optional) The offset (in seconds) to start sound playback from.
function sound_effect_play(_sound, _soundType = STNG_AUDIO_GAME_SOUNDS, _volume = 1.0, _pitch = 1.0, _priority = 0, _stopPrevious = false, _loops = false, _offset = 0.0){
	if (_stopPrevious && audio_is_playing(_sound))
		audio_stop_sound(_sound); // Stop previous playbacks of the sound if the flag is toggled.
		
	// Adjust the volume of the sound absed on the current master and current volume for the sound's type.
	// Then, play the desired sound effect and return its ID.
	with(global.settings) { _volume *= audio[STNG_AUDIO_MASTER] * audio[_soundType]; }
	return audio_play_sound(_sound, _priority, _loops, _volume, _offset, _pitch);
}

/// @description 
///	A further extension of GameMaker's audio playback function that applies the game's current master 
/// volume and sound effect volume values the player currently has them set to (They range from 0.0 to 1.0)
/// while also allowing each playback of said sound to have randomly chosen adjustments to its playback
/// volume and pitch.
///	
///	@param {Asset.GMSound}	sound			Index of the audio asset that will be played.
/// @param {Real}			soundType		(Optional) Determines which volume setting group the sound belongs to.
/// @param {Real}			volume			(Optional) Volume for the sound effect without any changes done by volume settings/gain variance.
/// @param {Real}			pitch			(Optional) Pitch of the sound effect before the random variance is applied to it.
/// @param {Real}			priority		(Optional) Sets the channel priority for the sound (Default is 0).
/// @param {Bool}			stopPrevious	(Optional) When true, previous instances of the sound's playback will be stopped.
/// @param {Bool}			loops			(Optional) When true, the sound will loop indefinitely.
/// @param {Real}			gainVariance	(Optional) Random amount to adjust the sound's volume; ranging from the base volume plus or minus this value.
/// @param {Real}			pitchVariance	(Optional) Random amount to shift the sound's pitch; ranging from the base pitch plus or minus this value.
/// @param {Real}			offset			(Optional) The offset (in seconds) to start sound playback from.
function sound_effect_play_ext(_sound, _soundType = STNG_AUDIO_GAME_SOUNDS, _volume = 1.0, _pitch = 1.0, _priority = 0, _stopPrevious = false, _loops = false, _gainVariance = 0.1, _pitchVariance = 0.05, _offset = 0.0){
	return sound_effect_play(
		_sound,
		_soundType,
		_volume * (1.0 + random_range(-_gainVariance,	_gainVariance)),
		_pitch	* (1.0 + random_range(-_pitchVariance,	_pitchVariance)),
		_priority, 
		_stopPrevious,
		_loops,
		_offset
	);
}

#endregion

#region String Manipulation Functions

/// @description 
///	Takes an input string and converts it to a string that can fit into the region defined by the "maxWidth"
/// and "maxLines" parameters. If the input string happens to exceed the total number of lines allowed, the
/// remainder of the string is discarded from the formatted string that the function returns.
///	
///	@param {String}			string		Value that will be formatted to fit the defined region.
/// @param {Asset.GMFont}	font		Resource to use for the various width/height calculations for the string.
/// @param {Real}			maxWidth	Maximum width of a line in pixels for the formatted string.
/// @param {Real}			maxLines	Total number of lines allowed in the formatted string.
function string_split_lines(_string, _font, _maxWidth, _maxLines = 1){
	// Set the font to the parameter and then check if the input string even needs to be formatted in the 
	// first place. If not, it means the string is already within the desired format and is simply returned.
	draw_set_font(_font);
	if (string_width(_string) <= _maxWidth || _string = "") // Also exit ealy if an empty string was passed in.
		return _string;
	
	// Loop through the string that was passed into the function until it is considered formatted by the 
	// parameters specified upon the function call.
	var _spaceWidth	= string_width(CHAR_SPACE);
	var _totalLines = 1;
	var _lineWidth	= 0;
	var _curChar	= "";
	var _curLine	= "";
	var _curWord	= "";
	var _newString	= "";
	var _numChars	= string_length(_string);
	for (var i = 1; i <= _numChars; i++){ // Starts from one since GML's font functions are indexed starting at one.
		_curChar = string_char_at(_string, i);
		
		// A space character has been found OR the current character is the final character in the unformatted
		// version of the string, a check occurs to see if the word parsed can fit on the current line or a
		// new line needs to be added for it. If that new line exceeds the max number of lines allowed, it is
		// ignored and whatever is formatted already is returned.
		if (_curChar == CHAR_SPACE || i == _numChars){
			var _wordWidth = string_width(_curWord);
			if (_lineWidth + _wordWidth + _spaceWidth > _maxWidth){
				if (_totalLines == _maxLines)
					break;
					
				// Remove the unnecessary space at the end of the line (If one happens to be there). 
				if (string_ends_with(_curLine, CHAR_SPACE))
					_curLine = string_delete(_curLine, string_length(_curLine), 1);
				
				// After handling the potential extra space at the end of the line, add it to the formatted 
				// with a newline character where the space used to be (If there was one). Then, set up a new
				// line of text to be parsed.
				_newString	   += _curLine + CHAR_NEWLINE;
				_totalLines	   += 1;
				_lineWidth		= _wordWidth + _spaceWidth;
				_curLine		= _curWord + _curChar;
				_curWord		= "";
				continue;
			}
			
			// No newline character required, add the string to the end of the line alongside the current word.
			// Update the width of the line to match these newly added characters.
			_lineWidth += _wordWidth + _spaceWidth;
			_curLine   += _curWord + _curChar;
			_curWord	= "";
			continue;
		}
		
		// A newline character has been found within the string already, so it will add that line to the new
		// string and a new line will begin. If adding this line would exceed the max number of lines, the
		// line is ignored and the loop exits early.
		if (_curChar == CHAR_NEWLINE){
			if (_totalLines == _maxLines)
					break;
			_newString	   += _curLine + _curWord + CHAR_NEWLINE;
			_totalLines    += 1;
			_lineWidth		= 0;
			_curLine		= "";
			_curWord		= "";
			continue;
		}

		_curWord += _curChar;
	}
	
	// Finally, return the string that has been formatted with newline characters and clipped such that only
	// the set number of lines exist within that string. If the final line wasn't placed into the string in
	// the loop, it will be concatenated with the rest of the string. Otherwise, it is already in the string
	// so just "_newString" is returned by itself.
	if (_curLine != "")
		return _newString + _curLine;
	return _newString;
}

/// @description 
///	Attempts to parse color data from a given string. It will take the color data, store it into a dedicated
/// ds_list, and then return that list alongside the string that has had the color data/formatting parsed out
/// of it. Note that this means the value returned is a struct, so keep that in mind since it must be deleted
/// once it is no longer required.
///	
///	@param {String}			string		Text that will have color data parsed from it.
function string_parse_color_data(_string){
	// First, check if there is valid color data that can be parsed out of the string. If there isn't any, the
	// string is simply returned unprocessed, and the value for "colorData" is the default of -1.
	var _charIndex = string_pos(CHAR_COLOR_CHANGE, _string);
	if (_string == "" || _charIndex == 0 || string_count(CHAR_COLOR_CHANGE, _string) == 0)
		return { colorData : -1, fullText : _string };
	
	// Loop through the string to pick out text that is formatted as such:
	//	@0xFFFFFF{colored text goes here}
	// The characters @, {, and } are removed from the string and the remaining hex code is formatted into a
	// number and stored in a list containing all the text colors and the region they will affect when drawn.
	var _strLength	= string_length(_string);
	var _colorList  = ds_list_create();
	while(true){ // This is the dumbest way I could've made a loop but it works...
		_charIndex = string_pos_ext(CHAR_COLOR_CHANGE, _string, _charIndex);
		if (_charIndex == 0 || _charIndex == _strLength)
			break; // Exit if there is no more color data to parse or the index value is the end of the string.
		
		// Attempt to grad the hex value within the text. The length of this code is checked in case it exists
		// malformed at the very end of the string (Ex. @0xFF and nothing else or something like that) and said
		// length is checked to see if its a valid length for a color hex code (0xBBGGRR) or not along with
		// checks to see if the code is malformed.
		var _colorCode			= string_copy(_string, _charIndex + 1, COLOR_CODE_LENGTH);
		var _colorCodeLength	= string_length(_colorCode);
		if (_colorCodeLength != COLOR_CODE_LENGTH || !string_starts_with(_colorCode, HEX_CODE_PREFIX) ||
				string_char_at(_string, _charIndex + _colorCodeLength + 1) != CHAR_REGION_START)
			_colorCode = COLOR_DARK_GRAY; // Applies a default color is the color code data is malformed.
		
		// Delete the hex code and the trio of characters--@, {, and }--that have to exist alongside the string
		// so there is a known region for the different colored text. If the } character doesn't exist, it is
		// assumed the rest of the string will be colored relative to the code that was parsed.
		_string	= string_delete(_string, _charIndex, _colorCodeLength + 2);
		var _endRegionIndex	= string_pos_ext(CHAR_REGION_END, _string, _charIndex);
		if (_endRegionIndex == 0) 
			_endRegionIndex = _strLength;
		_string = string_delete(_string, _endRegionIndex, 1);
		
		// Finally, add the parsed data into a struck that will hold the information of the color to use, the
		// first character to use it on, and the final character to use it on.
		ds_list_add(_colorList, {
			colorCode	: real(_colorCode),
			startIndex	: _charIndex,
			endIndex	: _endRegionIndex,
		});
	}
	
	// The list and formatted string are returned in a simple struct that can then be utilized to create multi-
	// colored text in various areas of the game's GUI.
	return { colorData : _colorList, fullText : _string };
}

/// @description 
/// A very simple and dirty function that checks to see if the provided character is one of six valid punctuation 
/// characters: ',', ':', ';', '.', '?', or '!'.
///	
/// @param {String}		char	The character to check.
function is_punctuation(_char){
	return (_char == CHAR_COMMA || _char == CHAR_COLON || _char == CHAR_SEMICOLON || 
			_char == CHAR_PERIOD || _char == CHAR_QUESTION || _char == CHAR_EXCLAIM);
}

#endregion String Manupulation Functions
