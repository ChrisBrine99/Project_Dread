#region Macros for Textbox Option Menu Struct

// The position that this menu will be at when its opening animation starts playing and when its closing
// animation has been completed. The target position is dynamically determined based on the width of the text
// shown on the menu, so it cannot be set as a macro.
#macro	TBOXMENU_XSTART					VIEWPORT_WIDTH + 50

// Values that determine the distance between the content's four edges (Left, right, top, and bottom) and the
// edges of the background containing said content.
#macro	TBOXMENU_BG_PADDING_LEFT		15
#macro	TBOXMENU_BG_PADDING_RIGHT		5
#macro	TBOXMENU_BG_PADDING_TOP			5
#macro	TBOXMENU_BG_PADDING_BOTTOM		5

// Determines how far left the menu's cursor will be drawn relative to the leftmost position of its options.
#macro	TBOXMENU_CURSOR_XOFFSET			8

#endregion Macros for Textbox Option Menu Struct

#region Textbox Option Menu Struct Definition

/// @param {Function}	index	The value of "str_map_menu" as determined by GameMaker during runtime.
function str_textbox_options_menu(_index) : str_sub_menu(_index) constructor {
	// Two values unique to the textbox options menu that will store the maximum possible extents of the options
	// for the menu. Padding is then applied on top of these values to create a background.
	contentWidth	= 0;
	contentHeight	= 0;
	
	/// @description
	///	Called during every frame that the menu exists for. It is responsible for rendering this menu's contents
	/// to the game's screen.
	///	
	///	@param {Real}	xPos		The menu's current x position, rounded down.
	/// @param {Real}	yPos		The menu's current y position, rounded down.
	///	@param {Real}	shadowColor	Determines the color used for the option text's drop shadow.
	/// @param {Real}	shadowAlpha	Determines the opacity of the option text's drop shadow.
	draw_gui_event = function(_xPos, _yPos, _shadowColor = COLOR_BLACK, _shadowAlpha = 1.0){
		// Draw the background for the menu in the same style as the textbox itself by borrowing its background.
		// It should always be offset more on the left than on the right to make room for the cursor.
		draw_sprite_stretched_ext(
			spr_tbox_background, 
			0,			// Unused
			_xPos - TBOXMENU_BG_PADDING_LEFT,
			_yPos - TBOXMENU_BG_PADDING_TOP,
			contentWidth + TBOXMENU_BG_PADDING_LEFT + TBOXMENU_BG_PADDING_RIGHT, 
			contentHeight + TBOXMENU_BG_PADDING_TOP + TBOXMENU_BG_PADDING_BOTTOM, 
			COLOR_TRUE_WHITE, 
			alpha
		);

		#region Drawing Cursor Next To Highlighted Option
		
			var _yy = curOption * optionSpacingY;
			draw_sprite_ext( // "Shadow" for the cursor (1 pixel right and down from cursor's actual position).
				spr_menu_cursor, 
				0,			 // Unused
				_xPos + 1 - TBOXMENU_CURSOR_XOFFSET, _yPos + 1 + _yy, 
				1.0, 1.0,	 // Unused
				0.0,		 // Unused
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // The Cursor Itself
				spr_menu_cursor, 
				0,			 // Unused
				_xPos - TBOXMENU_CURSOR_XOFFSET, _yPos + _yy, 
				1.0, 1.0,	 // Unused
				0.0,		 // Unused
				COLOR_TRUE_WHITE, alpha
			);
			
		#endregion Drawing Cursor Next To Highlighted Option
		
		// Finally, use the default function for displaying a menu's visible region of options (In this case
		// all options will be visible).
		draw_visible_options(font, _xPos, _yPos, _shadowColor, _shadowAlpha);
	}
}

#endregion Textbox Option Menu Struct Definition