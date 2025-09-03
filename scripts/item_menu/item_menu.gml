#region Macros for Item Menu Struct

// Macros for the bits within the item menu that are utilized for various non-state functionality. Each are
// unique to this menu.
#macro	MENUITM_FLAG_MOVING_ITEM		0x00000001
#macro	MENUITM_FLAG_OPTIONS_OPEN		0x00000002

// Macros for checking the state of the flags unique to the item menu.
#macro	MENUITM_IS_MOVING_ITEM			((flags & MENUITM_FLAG_MOVING_ITEM)		!= 0)
#macro	MENUITM_ARE_OPTIONS_OPEN		((flags & MENUITM_FLAG_OPTIONS_OPEN)	!= 0)

// Two calculations for the item menu's cursor arrow and an item's current quantity if that value is visible.
#macro	MENUINV_CURSOR_X_OFFSET		   -8
#macro	MENUITM_ITEM_QUANTITY_X_OFFSET	110

// Calculations for the position of the an item's info text when it is currently being highlighted by the
// player. Since they use "_xPos" and "_yPos" they must be used IN THE DRAW GUI EVENT ONLY!!!
#macro	MENUITM_OPTION_INFO_X			(_xPos + optionX - 48)
#macro	MENUITM_OPTION_INFO_Y			(_yPos + optionY + (MENUITM_VISIBLE_HEIGHT * optionSpacingY) + 5) 

// Determines the maximum line width for an item's description string as well as the maximum number of lines
// that can exist for display within the inventory's item section.
#macro	MENUITM_OPTION_INFO_MAX_WIDTH	160
#macro	MENUITM_OPTION_INFO_MAX_LINES	4

// Values for some constant characteristics about how the item inventory will be shown to the player. These
// are specifically for the maximum number of item slots visible to the player at once, the color of the text's
// drop shadow effect, and the opacity for that drop shadow.
#macro	MENUITM_VISIBLE_HEIGHT			10
#macro	MENUITM_TEXT_SHADOW_COLOR		COLOR_DARK_GRAY
#macro	MENUITM_TEXT_SHADOW_ALPHA		0.75

// Determines how fast the menu's cursor will move back and forth along the x axis.
#macro	MENUITM_CURSOR_ANIM_SPEED		0.07

// Determines where the "E" icon for signifying the item in a given slot is equipped to the player will be
// placed relative to the item's name's x position on the currently visible portion of the menu.
#macro	MENUITM_EQUIP_ICON_X_OFFSET		(MENUITM_ITEM_QUANTITY_X_OFFSET - maxQuantityWidth - 8)

// The two variations on how displayed item quantities within the inventory can be formatted. The first is the
// default method for anything with a stack limit greater than one, and the second is the amount of ammunition
// left in the weapon's current magazine (Melee weapons aside from the chainsaw are excluded since they don't 
// have to use ammo).
#macro	MENUINM_QUANTITY_STANDARD		"x{0}"
#macro	MENUINM_QUANTITY_WEAPON			"[{0}]"

// The default string that will be used for an empty item slot when displayed on the UI for the player. The
// empty slot's info text will also use this default string.
#macro	MENUITM_DEFAULT_STRING			"---"

// A group of all the possible options an item can have access to whenever a given item is selected by the
// player within the item inventory. These strings are then used to determine what should be done upon
// selection within the item's options sub menu.
#macro	MENUITM_OPTION_USE				"Use"
#macro	MENUITM_OPTION_EQUIP			"Equip"
#macro	MENUITM_OPTION_UNEQUIP			"Unequip"
#macro	MENUITM_OPTION_COMBINE			"Combine"
#macro	MENUITM_OPTION_MOVE				"Move"
#macro	MENUITM_OPTION_DROP				"Drop"

#endregion Macros for Item Menu Struct

#region Macros for Item Options Sub Menu

// Stores the offset position of a selected item's option sub menu along the x axis so it appears to the right 
// of said item relative to its vertical position on the visible portion of the menu.
#macro	SUBMENU_ITM_OFFSET_X			50

// The dimensions of the surface that the selected item's option menu will be rendered onto, so it can have a
// sliding animation that doesn't render outside of the dimensions of the menu after animations have completed.
#macro	SUBMENU_ITM_SURFACE_WIDTH		40
#macro	SUBMENU_ITM_SURFACE_HEIGHT		40

// Determines the two x positions the item's option menu text will shift between during the opening and closing
// animations for this sub menu; allowing it to slide on and off of the surface it will be drawn onto.
#macro	SUBMENU_ITM_ANIM_X1				50.0
#macro	SUBMENU_ITM_ANIM_X2				0.0

// Determines how fast the selected item's option menu will fade into and out of visibility during its opening
// and closing animations. It also works as the value used to lerp the menu's options between the two x
// positions stated above.
#macro	SUBMENU_ITM_OANIM_ALPHA_SPEED	0.1
#macro	SUBMENU_ITM_CANIM_ALPHA_SPEED	0.1

#endregion Macros for Item Options Sub Menu

#region Item Menu Struct Definition

/// @param {Function}	index	The value of "str_item_menu" as determined by GameMaker during runtime.
function str_item_menu(_index) : str_base_menu(_index) constructor {
	// An array that stores references to item structs for items currently contained within the item inventory 
	// so they can be quickly accessed instead of iterating through the item data map or ID list whenever they
	// are required for various processes handled by the item menu.
	invItemRefs			= array_create(array_length(global.curItems), INV_EMPTY_SLOT);
	
	// Stores the slots that have equipped items currently occupying them. This allows the item inventory to
	// know what is equipped or not without having to constantly reference the player's "equipment" struct.
	equippedSlots		= ds_list_create();
	
	// Two variables that store references to menus. The first will hold the sub menu instance that is
	// responsible for displaying and processing logic for the list of options available to the player for 
	// the item they selected, and the second is simply a reference to this struct during runtime so it can
	// be passed to that sub menu and stored in its prevMenu variable.
	itemOptionsMenu		= noone;
	selfRef				= noone;
	
	// Store references to the control group information that is created/gotten and drawn by the inventory
	// menu instance. This allows the item menu to adjust what is shown in each group as required by its state.
	movementCtrlGroup	= REF_INVALID;
	interactCtrlGroup	= REF_INVALID;
	
	// Variables specific to the item options menu and how it is rendered within the item menu iteself. They
	// are the surface that the sub menu is drawn onto (Its default rendering method is disabled to allow 
	// this), and the position of the sub menu relative to the overall menu's position.
	itemOptionsSurf		= -1;
	itemOptionsMenuX	= 0;
	itemOptionsMenuY	= 0;
	
	// A value used to allow the menu's cursor to move back and forth by one pixel along the x axis.
	cursorAnimTimer		= 0.0;
	
	// Calculate the maximum width for the largest string that can display an item's quantity. This value is
	// then used to offset the "E" icon that is placed next to items that are currently equipped.
	draw_set_font(fnt_small);
	maxQuantityWidth	= string_width("[000]");
	
	/// @description 
	///	The item menus struct's create event. It initializes required parameters; sets up the auxillary return
	/// input bindings, and loads the contents of the item inventory in as menu options + descriptions.
	///	
	create_event = function(){
		// Get a referfence to this struct so its submenu can reference it in its "prevMenu" variable.
		selfRef			= instance_find_struct(structID);
		
		// Set up the "auxilliary" return inputs to the input that opens up this menu during gameplay, so 
		// it can also close the menu should the player choose to use it instead of the standard input.
		var _inputs		= global.settings.inputs;
		keyAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU];
		padAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU + 1];
		
		// Set up the item menu to it has the same number of options as there are slots available in the
		// player's item inventory. Using that number, the base and option parameters are both initialized.
		var _invSize	= array_length(invItemRefs);
		initialize_params(x, y, true, true, 1, 1, min(_invSize, MENUITM_VISIBLE_HEIGHT), 0, 2);
		initialize_option_params(display_get_gui_width() - 120, 20, 50, 10, fa_left, fa_top, true);
		
		// Looping through the player's items so they can be added as options to this menu. From here, the
		// player will be able to select a highlighted item to interact with in in various ways relative to
		// the item's type and potential subtype.
		var _itemName	= "";
		var _itemInfo	= "";
		var _itemID		= ID_INVALID;
		var _invItem	= INV_EMPTY_SLOT;
		for (var i = 0; i < _invSize; i++){
			_invItem = item_inventory_slot_get_data(i);
			if (_invItem == INV_EMPTY_SLOT){ // Occupy the slot with an empty option.
				add_option(MENUITM_DEFAULT_STRING, MENUITM_DEFAULT_STRING);
				continue;
			}
			
			// Jump into the current item struct's scope to grab the relevant data for the item menu's option
			// element and reference array can utilize in their initializations.
			with(_invItem){
				_itemName	= itemName;
				_itemInfo	= itemInfo;
				_itemID		= itemID;
			}
			add_option(_itemName, _itemInfo);
			invItemRefs[i] = global.itemIDs[_itemID];
		}
		
		// The item inventory doesn't know where each equipped item resides on the player when it is first
		// created, so a quick check to see if there are valid slot values within each equip slot is done and
		// if they are valid they are added to the euqippedSlots list.
		var _equippedSlots = equippedSlots;
		with(PLAYER.equipment){
			if (weapon		 != INV_EMPTY_SLOT)	{ ds_list_add(_equippedSlots, weapon); }
			if (armor		 != INV_EMPTY_SLOT)	{ ds_list_add(_equippedSlots, armor); }
			if (light		 != INV_EMPTY_SLOT)	{ ds_list_add(_equippedSlots, light); }
			if (firstAmulet  != INV_EMPTY_SLOT)	{ ds_list_add(_equippedSlots, firstAmulet); }
			if (secondAmulet != INV_EMPTY_SLOT) { ds_list_add(_equippedSlots, secondAmulet); }
		}
	}
	
	/// Store the pointer to the base menu's destroy event so it can be called within the item menu's version
	/// of the event alongside the other logic it needs when cleaning itself up.
	__destroy_event = destroy_event;
	/// @description 
	///	Called whenever the item menu is closed by the player. It handles cleaning up memory that was allocated 
	/// from the str_base_menu struct while also destroying the sub menu it manages if it exists during this
	/// lifetime of the item menu struct.
	///
	destroy_event = function(){
		__destroy_event(); // Call parent destroy event to manage everything that was inherited.
		
		// Should either the surface for the selected item's option menu or that menu struct exist when the
		// item inventory is being destroyed they will be tidied up here.
		if (itemOptionsMenu != noone)		 { instance_destroy_menu_struct(itemOptionsMenu); }
		if (surface_exists(itemOptionsSurf)) { surface_free(itemOptionsSurf); }
		
		// Remove the ds_list that kept track of the slots where player's currently equipped items were contained.
		ds_list_clear(equippedSlots);
		ds_list_destroy(equippedSlots);
	}
	
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos	The menu's current x position added with the viewport's current x position.
	/// @param {Real}	viewY	The menu's current y position added with the viewport's current x position.
	draw_gui_event = function(_xPos, _yPos){
		// Create local values for the location of the currently highlighted item on the visible portion of
		// the item inventory menu, which are then used to position various elements that rely on the current
		// option's index to be drawn.
		var _curOptionX = _xPos + optionX + MENUINV_CURSOR_X_OFFSET;
		var _curOptionY = _yPos + optionY + ((curOption - visibleAreaY) * optionSpacingY);
		
		// Displays a translucent rectangle behind the currently highlight item. If that item happens to be
		// selected and its option menu is on display, the color will be green instead of yellow.
		var _bkgColor = (selOption == curOption) ? COLOR_LIGHT_GREEN : COLOR_LIGHT_YELLOW;
		if (auxSelOption == curOption) {_bkgColor = COLOR_LIGHT_RED; } // Turn it red for an auxilliary selection.
		draw_sprite_ext(spr_rectangle, 0, _curOptionX - 2, _curOptionY - 1, 122, optionSpacingY, 0.0, 
			_bkgColor, alpha * 0.2);
			
		// Above the backing rectangle for the highlighted item, a cursor using the greater-than symbol will
		// be drawn; shifting left and right based on the current value of cursorAnimTimer.
		draw_text_shadow(_curOptionX + floor(cursorAnimTimer), _curOptionY, ">", 
			COLOR_WHITE, alpha, MENUITM_TEXT_SHADOW_COLOR, MENUITM_TEXT_SHADOW_ALPHA);
		
		// Display the currently visible region of this menu with the default function provided by the 
		// inherited base menu struct.
		draw_visible_options(fnt_small, _xPos, _yPos, MENUITM_TEXT_SHADOW_COLOR, MENUITM_TEXT_SHADOW_ALPHA);
		
		// After the visible menu options have been draw, a cursor and the current quantities will be drawns
		// to the right of each item name as required.
		draw_set_halign(fa_right);
		var _index		 = -1;
		var _isWeapon	 = false;
		var _item		 = INV_EMPTY_SLOT;
		var _quantity	 = 0;
		var _sQuantity	 = "";
		var _sColor		 = COLOR_WHITE;
		var _curX		 = _xPos + optionX;
		var _curY		 = _yPos + optionY;
		for (var i = visibleAreaY; i < visibleAreaY + visibleAreaH; i++){
			// Get the value currently stored in the player's item inventory array to see if the slot is empty
			// or not. If it isn't empty, its quantity and item type will determine how the quantity will be
			// drawn and if it will even be drawn to begin with.
			_item = global.curItems[i];
			if (_item != INV_EMPTY_SLOT){
				_quantity = min(999, _item.quantity); // Limit to showing 999 at most.
				with(invItemRefs[i]){
					// So long as the item is a weapon that uses ammo (All ranged weapons + the chainsaw), the
					// quantity is formatted as [{quantity}]. Otherwise, it will be shown as x{quantity} so
					// long as the max stack is high than one.
					if (typeID == ITEM_TYPE_WEAPON && !WEAPON_IS_MELEE){
						_sQuantity = string(MENUINM_QUANTITY_WEAPON, _quantity);
					} else if (stackLimit > 1 && !_isWeapon){
						_sQuantity = string(MENUINM_QUANTITY_STANDARD, _quantity);
					} else{ // Clear the string to signify the quantity doesn't need to be shown for the item.
						_sQuantity = "";
					}
					
					// After the string is formatted, the color for the text will be determined. The default
					// is white, but a quantity of 0 (Weapons that use ammunition are the only items this
					// applies to) will turn the quantity text red, and a full stack in a slot will be green.
					if (_quantity == stackLimit)	{ _sColor = COLOR_LIGHT_GREEN; }
					else if (_quantity == 0)		{ _sColor = COLOR_RED; }
					else							{ _sColor = COLOR_WHITE; }
				}
				
				// Display the quantity as it was formatted above.
				draw_text_shadow(_curX + MENUITM_ITEM_QUANTITY_X_OFFSET, _curY, _sQuantity, 
					_sColor, alpha, MENUITM_TEXT_SHADOW_COLOR, MENUITM_TEXT_SHADOW_ALPHA);
			}
			
			// Display an "E" symbol next to each visible item that is currently equipped to one of the five
			// slots they have available for equipment.
			_index = ds_list_find_index(equippedSlots, i);
			if (_index != -1){
				draw_set_alpha(alpha);
				draw_sprite(spr_iteminv_equip_icon, 0, _curX + MENUITM_EQUIP_ICON_X_OFFSET, _curY);
			}
			
			// Shift the y position down for the next potential item quantity to draw at.
			_curY += optionSpacingY;
		}
		draw_set_halign(fa_left);
		
		// Draw the highlighted/selected item's description below the current visible region of options in 
		// the item inventory. For now, it simply displays it with no animations or fancy flairs.
		if (curOption >= 0 && curOption < ds_list_size(options)){
			var _curOption = options[| curOption];
			draw_text_shadow(MENUITM_OPTION_INFO_X, MENUITM_OPTION_INFO_Y, _curOption.oInfo, 
				COLOR_LIGHT_GRAY, alpha, MENUITM_TEXT_SHADOW_COLOR, MENUITM_TEXT_SHADOW_ALPHA);
		}
		
		// Don't bother with any of the surface rendering/swapping logic below if the sub menu containing the
		// selected item's options isn't currently opened for the player to select from.
		if (!MENUITM_ARE_OPTIONS_OPEN)
			return;
		
		// Make sure the surface for the selected item's option menu if it doesn't exist due to a GPU flush.
		if (!surface_exists(itemOptionsSurf))
			itemOptionsSurf = surface_create(SUBMENU_ITM_SURFACE_WIDTH, SUBMENU_ITM_SURFACE_HEIGHT);
			
		// Switch to rendering onto the surface for the selected item's option menu. Clear the surface to
		// the color (0, 0, 0, 0) so the previous frame's rendering doesn't show up again creating a smear.
		// Then, jump into scope of the menu in question and draw its options to the screen.
		surface_set_target(itemOptionsSurf);
		draw_clear_alpha(COLOR_BLACK, 0.0);
		var _x = x;
		var _y = y;
		with(itemOptionsMenu){
			// Only display the options if they will be visible on the surface to begin with (As they slide
			// to the left during the opening animation and to the right in the closing animation).
			if (optionX < SUBMENU_ITM_SURFACE_WIDTH)
				draw_gui_event(_x, _y);
		}
		surface_reset_target();
		
		// Finally, draw the current capture of the selected item's option menu onto the screen.
		draw_set_alpha(alpha);
		draw_surface(itemOptionsSurf, _xPos + itemOptionsMenuX, _yPos + itemOptionsMenuY);
	}
	
	/// @description 
	///	Allows a single line of code calling this function to encapsulate all that is required to reset the
	/// item menu back to its default state as it involves more steps than just setting its state back to
	/// state_default.
	///	
	reset_to_default_state = function(){
		// Re-enable the "Change Page" inputs within the menu movement control group so they are shown again.
		var _movementCtrlGroup = movementCtrlGroup;
		with(CONTROL_UI_MANAGER){
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_LEFT,  true);
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_RIGHT, true);
		}
		
		// After re-enabling the necessary input information, the inventory has flags set that re-enable its
		// ability to close through the return input being pressed, its ability to switch from one section to
		// another, and the item menu is reset to its default state.
		with(prevMenu) { flags = flags | MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE; }
		object_set_state(state_default);
		flags			= flags & ~MENUITM_FLAG_MOVING_ITEM;
		auxSelOption	= -1;
		selOption		= -1;
	}

	/// @description 
	///	The item menu's default state. It will handle selecting a slot within the menu, closing the menu by
	/// releasing the "auxilliary" return input (The master inventory menu manages the standard return input),
	///	and moving the cursor if no option was selected and the menu shouldn't close at the moment.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// First, process player input for the current frame, and then check if they released the return key.
		// If so, the item menu will signal to the inventory that it is time to play its closing animation.
		process_player_input();
		if (MINPUT_IS_AUX_RETURN_RELEASED){
			// Don't allow the first detection of the release input close the inventory if the value found in
			// auxSelOption isn't default value. If so, reset back to the item menu's default state.
			if (auxSelOption != -1){
				reset_to_default_state();
				return; // Don't let the inventory close itself.
			}
			
			with(prevMenu) { object_set_state(state_close_animation); }
			return; // The menu shouldn't process any other logic.
		}
		
		// Like above for the auxillary return input, the item menu is reset back to its default state but
		// when the normal return input for menus is pressed instead of that auxillary input. That input flag
		// is then cleared so the inventory menu doesn't accidentally detect it and close the menu during the
		// next frame since it is processed before this menu is.
		if (auxSelOption != -1 && MINPUT_IS_RETURN_RELEASED){
			reset_to_default_state();
			prevInputFlags = prevInputFlags & ~MINPUT_FLAG_RETURN;
			return; // The menu shouldn't process any other logic.
		}
		
		// The select input was released, so an item will be selected for the player to interact with its
		// list of available options.
		if (MINPUT_IS_SELECT_RELEASED){
			// Don't jump into any of this selection code logic if the current slot is empty AND the inventory
			// isn't currently set to move an item to another slot. If slot movement is occurring, the check
			// is bypassed to be stopped further below.
			var _isMovingItem = MENUITM_IS_MOVING_ITEM;
			if (!_isMovingItem && invItemRefs[curOption] == INV_EMPTY_SLOT)
				return;
			with(prevMenu){ flags = flags & ~(MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE); }
			
			// Disable the page left/right input information since the inventory is no longer able to switch
			// between each of the three sections contained within it.
			var _movementCtrlGroup = movementCtrlGroup;
			with(CONTROL_UI_MANAGER){ 
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_LEFT,  false);
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_RIGHT, false);
			}
			selOption = curOption;
			
			// Check if the inventory is moving an item. If so, this branch is taken and the inventory will
			// move to its state for handling an item movement, and this state exits early.
			if (_isMovingItem){
				object_set_state(state_move_item);
				return;
			}
			
			// If there is a value found in the auxSelOption variable and the moving item flag wasn't set, it
			// is assumed the item is being combined with another instead, so that state is activated.
			if (auxSelOption != -1){
				object_set_state(state_combine_item);
				return;
			}
			
			// Determine the options that the item inventory's sub menu--the item options menu--will have
			// based on its given type ID. This will determine what can and cannot be done to the item.
			var _options	= -1;
			var _itemType	= invItemRefs[selOption].typeID;
			switch(_itemType){
				default: // Undefined item types default to the combine/move/drop option combo.
				case ITEM_TYPE_AMMO:
				case ITEM_TYPE_COMBINABLE:
					_options = [
						MENUITM_OPTION_COMBINE,
						MENUITM_OPTION_MOVE,
						MENUITM_OPTION_DROP
					];
					break;
				case ITEM_TYPE_EQUIPABLE:
				case ITEM_TYPE_WEAPON:
					_options = [
						MENUITM_OPTION_EQUIP, 
						MENUITM_OPTION_COMBINE, 
						MENUITM_OPTION_MOVE, 
						MENUITM_OPTION_DROP
					];
					break;
				case ITEM_TYPE_CONSUMABLE:
				case ITEM_TYPE_KEY_ITEM:
					_options = [
						MENUITM_OPTION_USE,
						MENUITM_OPTION_COMBINE,
						MENUITM_OPTION_MOVE,
						MENUITM_OPTION_DROP
					];
					break;
			}
			
			// An item that would normally have the "Equip" option as the first in the list of available options
			// will have it changed to "Unequip" if the weapon happens to be equipped to the player.
			if (_options[0] == MENUITM_OPTION_EQUIP && ds_list_find_index(equippedSlots, selOption) != -1)
				_options[0] = MENUITM_OPTION_UNEQUIP;
			
			// Create a local variable that will store whether or not the sub menu struct was created this time
			// through or not. If the menu was created, this bool is set to true and some code below is skipped.
			var _menuCreated = false;
			if (itemOptionsMenu == noone){
				itemOptionsMenu	= create_sub_menu(selfRef, 0, 0, _options, 1, 1, array_length(_options));
				_menuCreated	= true;
			}
				
			// Jump into scope of the item inventory's sub menu so it can be activated along with replacing
			// the previous options if the menu already existed previous (This occurs when two or more items
			// have been selected by the user during the lifetime of this menu).
			var _optionSpacingY = 0;
			with(itemOptionsMenu){
				flags = flags | MENU_FLAG_ACTIVE;
				
				if (!_menuCreated){
					replace_options(_options, 1, 1, array_length(_options));
					flags = flags & ~MENUSUB_FLAG_CLOSING; // Also flip this bit so the menu doesn't instantly close.
				}
				
				_optionSpacingY = optionSpacingY;
			}
			
			// 
			var _yOffset = min((curOption - visibleAreaY) * optionSpacingY, 
							   (visibleAreaH - array_length(_options)) * _optionSpacingY);
			
			// Finally, swap over the opening state for the item options menu. On top of that, set the flag
			// that lets this menu know that sub menu is open, and position it to show up beside the selected
			// item's name. The cursor animation offset/timer is also reset to zero.
			object_set_state(state_open_item_options);
			flags			 = flags | MENUITM_FLAG_OPTIONS_OPEN;
			itemOptionsMenuX = optionX - SUBMENU_ITM_OFFSET_X;
			itemOptionsMenuY = optionY + _yOffset;
			cursorAnimTimer	 = 0.0;
			return;
		}
		
		// Update the cursor's animation timer (This is also used to display the animation's current offset)
		// so it shifts back and forth at a regular interval.
		cursorAnimTimer += MENUITM_CURSOR_ANIM_SPEED * _delta;
		if (cursorAnimTimer >= 2.0)
			cursorAnimTimer -= 2.0;
		
		// After checking for the relevant non-cursor movements have been checked, the cursor will check if its
		// position should be updated based on its "auto-shift" timer is that is active, or if a direction was
		// pressed in all other instances.
		update_cursor_position(_delta);
	}
	
	/// @description 
	///	Handles the opening animation for the selected item's option window. Once the animation has finished,
	/// the submenu will begin to check for input and then process whichever option is selected.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_item_options = function(_delta){
		// Jump into the submenu's scope and update the parameters involved in the animation. Once all values
		// have reached their targets, flip the flag _isOpened to true to signify the animation is done and
		// the item menu's state should change.
		var _isOpened = false;
		with(itemOptionsMenu){
			optionX  = lerp(SUBMENU_ITM_ANIM_X1, SUBMENU_ITM_ANIM_X2, alpha); 
			alpha	+= SUBMENU_ITM_OANIM_ALPHA_SPEED * _delta;
			if (alpha >= 1.0){ // Animation has completed; set values to their targets.
				object_set_state(state_default);
				alpha		= 1.0;
				optionX		= 0.0;
				_isOpened	= true;
			}
		}
		
		// Once the opening animation is finished, set the state of this menu to handle submenu logic.
		if (_isOpened) { object_set_state(state_navigating_item_options); }
	}
	
	/// @description 
	///	Handles the closing animation for the selected item's option window. Once the animation has finished,
	/// standard input functionality returns to the item inventory menu itself as it resets to its default
	/// state once again.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_item_options = function(_delta){
		// Jump into the select item's option menu submenu to update the parameters that are used in the
		// closing animation. Once the conditions of the animation are met, the local _isClosed flag is
		// set to true to signify the item menu can reset itself.
		var _isClosed = false;
		with(itemOptionsMenu){
			optionX  = lerp(SUBMENU_ITM_ANIM_X1, SUBMENU_ITM_ANIM_X2, alpha); 
			alpha -= SUBMENU_ITM_CANIM_ALPHA_SPEED * _delta;
			if (alpha <= 0.0){ // Animation has completed; reset flags and set values to their targets.
				flags		= flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_CURSOR_AUTOSCROLL);
				alpha		= 0.0;
				optionX		= 50.0;
				_isClosed	= true;
			}
		}
		
		// When flagged to close, the menu calls its reset function if there isn't an auxillary option
		// selected by the item menu. Otherwise, it simply just updates its state so further functionality
		// can occur with that auxillary item.
		if (_isClosed){
			if (auxSelOption == -1) { reset_to_default_state(); }
			else					{ object_set_state(state_default); }
			flags = flags & ~MENUITM_FLAG_OPTIONS_OPEN; // CLear flag since this submenu is now closed.
		}
	}
	
	
	/// @description 
	///	The state the item menu is set to whenever its sub menu has been activated. It processes what should
	/// happen depending on what option within the sub menu is selected, or closing that sub menu if needed.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_navigating_item_options = function(_delta){
		// Grab the current value of selOption within the sub menu, and then check if it is currently closing
		// or not. Both values are used below like a menu's select/return inputs are processed to determine
		// what needs to be done within the menu to meet the required criteria for either input.
		var _selOption	= -1;
		var _isClosing	= false;
		with(itemOptionsMenu){
			_selOption = selOption;
			_isClosing = MENUSUB_IS_CLOSING;
		}
		
		// An option in the sub menu was selected, so the selcted option is used to determine what needs to
		// happen within the item menu since it has ties to the player's item inventory and the sub menu is a
		// generic menu that doesn't handle its own selected option(s) automatically.
		if (_selOption != -1){
			var _oName		= "";
			with(itemOptionsMenu){ _oName = options[| selOption].oName; }
			
			// Determine what should be done based on the name of the option that was selected by the player.
			switch(_oName){
				case MENUITM_OPTION_USE:		// Shift to the state that determines how to use the item.
					object_set_state(state_use_item);
					return;
				case MENUITM_OPTION_EQUIP:		// Shift to the state that handles equipping the item.
					object_set_state(state_equip_item);
					return;
				case MENUITM_OPTION_UNEQUIP:	// Shift to the state that handles unequipping the item.
					object_set_state(state_unequip_item);
					return;
				case MENUITM_OPTION_MOVE:		// The item is being moved, so toggle the flag that says that action is occurring in addition to the "Combine" option's line below.
					flags = flags | MENUITM_FLAG_MOVING_ITEM;
				case MENUITM_OPTION_COMBINE:	// The item is being combined; store its slot index, and return to normal inventory function so another can be selected.
					auxSelOption = selOption;
					break;
				case MENUITM_OPTION_DROP:		// Removes slot from the inventory; creates a world item on the floor representing the slot's contents.
					// Check if the item that was dropped was equipped to one of the player's equipment slots. 
					// If so, state that normally handles unequipping an item will be immediately called, and 
					// then the remaining logic for removing an item is handled to avoid issue.
					var _index = ds_list_find_index(equippedSlots, selOption);
					if (_index != -1) { state_unequip_item(_delta); }
					
					// After the item is unequipped, it will be removed from the inventory and have an instance 
					// of obj_world_item containing the characteristics of what was in this slot.
					item_inventory_slot_create_item(PLAYER.x - 8, PLAYER.y - 8, selOption);
					
					// Remove the reference to the item as it is no longer within the item inventory. Then,
					// remove the item's data from the menu option with the same slot index.
					invItemRefs[selOption] = INV_EMPTY_SLOT;
					with(options[| selOption]){ // Set the option struct to its default values.
						oName = MENUITM_DEFAULT_STRING;
						oInfo = MENUITM_DEFAULT_STRING;
					}
					break;
			}
			
			// Manually set this boolean to true so the state knows to close the selected item's option menu.
			_isClosing = true;
		}
		
		// The sub menu is closing, so the item inventory should return to its default state. The sub menu is
		// also deactivated since it isn't required during said state.
		if (_isClosing){
			object_set_state(state_close_item_options);
			with(itemOptionsMenu) { object_set_state(0); }
		}
	}
	
	/// @description
	///	
	///
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_use_item = function(_delta){
		show_debug_message("The item in slot {0} was used.", selOption);
		object_set_state(state_close_item_options);
	}
	
	/// @description 
	///	A single-frame state that attempts to equip the selected item to the player in one of their six slots
	/// for various types of equipment. The item's option window begins its closing animation after this.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_equip_item = function(_delta){
		var _selOption		= selOption;
		var _itemData		= invItemRefs[_selOption];
		var _itemStructRef	= global.itemIDs[_itemData.itemID];
		var _slotToCheck	= INV_EMPTY_SLOT;
		with(PLAYER){
			// Determine what equipment slot to check for in the "equippedSlots" list and function to call
			// based on what "equipment type" the item is a part of.
			switch(_itemData.equipType){	
				case ITEM_EQUIP_TYPE_FLASHLIGHT:	// Equipping a light source to the player.
					_slotToCheck = equipment.light;
					equip_flashlight(_itemStructRef, _selOption);
					break;
				case ITEM_EQUIP_TYPE_MAINWEAPON:	// Equipping a ranged/melee weapon to the player.
					_slotToCheck = equipment.weapon;
					equip_main_weapon(_itemStructRef, _selOption);
					break;
			}
		}
		
		// After equipping the item, check if it already exists within the "equippedSlots" array that handles
		// displaying an "E" symbol next to all equipped items. If it does, update the value to match the
		// new slot value. Otherwise, no previous item of that same type was equipped so a new element is
		// added to the list.
		var _index = ds_list_find_index(equippedSlots, _slotToCheck);
		if (_index != -1)	{ ds_list_set(equippedSlots, _index, _selOption); }
		else				{ ds_list_add(equippedSlots, _selOption); }
		
		// Finally, switch to the state that will close the selected item's option menu/window so normal
		// functionality can return to the item menu.
		object_set_state(state_close_item_options);
	}
	
	/// @description 
	///	A single-frame state that attempts to unequip the item in the slot stored in the "selOption" variable.
	/// This will call the appropriate function for the type of item being unequipped, and then the item's
	/// option menu window will begin its closing animation immediately after.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_unequip_item = function(_delta){
		var _selOption	 = selOption;
		var _itemData	 = invItemRefs[_selOption];
		with(PLAYER){
			// Determine which unequip function to call relative to the item's "equipment type".
			switch(_itemData.equipType){
				case ITEM_EQUIP_TYPE_FLASHLIGHT:	unequip_flashlight();		break;
				case ITEM_EQUIP_TYPE_MAINWEAPON:	unequip_main_weapon();		break;
			}
		}
		
		// If the item's slot is found in the list tracking equipped slots for the item inventory to display
		// the "E" symbol next to equipped items, it will be removed from that list to stop the "E" symbol
		// from displaying on that item inventory slot.
		var _index = ds_list_find_index(equippedSlots, _selOption);
		if (_index != -1) { ds_list_delete(equippedSlots, _index); }
		
		// Finally, switch to the state that will close the selected item's option menu/window so normal
		// functionality can return to the item menu.
		object_set_state(state_close_item_options);
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_combine_item = function(_delta){
		show_debug_message("The item in slot {0} was combined the item in slot {1}.", auxSelOption, selOption);
		reset_to_default_state();
	}
	
	/// @description 
	///	Moves the item found in the slot index stored in the auxSelOption variable into the slot occupied by
	/// the item found in the slot index stored in the curOption variable. Resets to the item menu's default
	/// state immediately upon processing this state.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_move_item = function(_delta){
		if (auxSelOption != curOption){ // Only bother swapping data if two unique slots were chosen.
			item_inventory_slot_swap(auxSelOption, curOption);
			
			// Check if any slots that contain equipped items need to be updated to match the fact that items
			// were moved in the item inventory. If so, update them with the new values.
			var _firstSlotIndex		= ds_list_find_index(equippedSlots, auxSelOption);
			var _secondSlotIndex	= ds_list_find_index(equippedSlots, curOption);
			if (_firstSlotIndex == -1 && _secondSlotIndex != -1)		{ equippedSlots[| _secondSlotIndex] = auxSelOption; }
			else if (_firstSlotIndex != -1 && _secondSlotIndex == -1)	{ equippedSlots[| _firstSlotIndex]	= curOption; }
			
			// Perform a check that will see if any of the current equipment slot values need to be updated to
			// match the fact that an item (Or two) were moved from their previous slots. If so, they will
			// be updated through this function call.
			if (_firstSlotIndex != -1 || _secondSlotIndex != -1){
				var _auxSelOption	= auxSelOption;
				var _curOption		= curOption;
				with(PLAYER) { update_equip_slot(_auxSelOption, _curOption); }
			}
				
			// Update the references to item structs within the item inventory so the slots they occupy matches
			// where they are now located after the slot swap occurs.
			var _tempInvItemRef			= invItemRefs[auxSelOption];
			invItemRefs[auxSelOption]	= invItemRefs[curOption];
			invItemRefs[curOption]		= _tempInvItemRef;
			
			// Like above, the option contents need to be swapped to match the fact that two items changed
			// places within the item inventory.
			var _tempOptionRef		= options[| auxSelOption];
			options[| auxSelOption] = options[| curOption];
			options[| curOption]	= _tempOptionRef;
		}
		reset_to_default_state();
	}
}

#endregion Item Menu Struct Definition