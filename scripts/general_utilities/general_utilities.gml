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