#region Color Hex Value Macros

// -------------------------- //
// --- SHADE COLOR CODES ---- //
// -------------------------- //
#macro	COLOR_TRUE_WHITE				0xFFFFFF	// BGR 255, 255, 255
#macro	COLOR_WHITE						0xF8F8F8	// BGR 248, 248, 248
#macro	COLOR_VERY_LIGHT_GRAY			0xD8D8D8	// BGR 216, 216, 216
#macro	COLOR_LIGHT_GRAY				0xBFBFBF	// BGR 188, 188, 188
#macro	COLOR_GRAY						0x7F7F7F	// BGR 124, 124, 124
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

// The value that equates to one second of real-time in the game's units. An exmaple would be an entity with
// a speed value of 1.0 would move roughly 60 pixels per second.
#macro	GAME_TARGET_FPS					60.0

// A catchall for some ID that is considered invalid (Ex. item IDs, data structure IDs, etc.).
#macro	ID_INVALID					   -1

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

#endregion General Macros

#region Text Rendering Functions

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
function draw_text_with_shadow_ext(_x, _y, _text, _color1 = c_white, _color2 = c_white, _color3 = c_white, _color4 = c_white, _alpha = 1.0, _shadowColor = c_black, _shadowAlpha = 0.75, _shadowX = 1, _shadowY = 1){
	if (string_length(_text) == 0)
		return; // Don't bother attempting to draw an empty string of text.
	
	draw_set_alpha(_alpha * _shadowAlpha);	// Three lines are responsible for drawing the drop shadow.
	draw_set_color(_shadowColor);
	draw_text(_x + _shadowX, _y + _shadowY, _text);
	
	// Then, the text is drawn on top of the shadow text that was drawn previously.
	draw_text_color(_x, _y, _text, _color1, _color2, _color3, _color4, _alpha);
}

#endregion Text Rendering Functions

#region String Manipulation Functions

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
