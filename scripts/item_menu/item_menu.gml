#region Macros for Item Menu Struct

// Macros for the bits within the item menu that are utilized for various non-state functionality. Each are
// unique to this menu.
#macro	MENUITM_FLAG_MOVING_ITEM		0x00000001
#macro	MENUITM_FLAG_OPTIONS_OPEN		0x00000002
#macro	MENUITM_FLAG_CLOSE_ON_USE		0x00000004
#macro	MENUITM_FLAG_OPEN_TEXTBOX		0x00000008

// Macros for checking the state of the flags unique to the item menu.
#macro	MENUITM_IS_MOVING_ITEM			((flags & MENUITM_FLAG_MOVING_ITEM)		!= 0)
#macro	MENUITM_ARE_OPTIONS_OPEN		((flags & MENUITM_FLAG_OPTIONS_OPEN)	!= 0)
#macro	MENUITM_SHOULD_CLOSE_ON_USE		((flags & MENUITM_FLAG_CLOSE_ON_USE)	!= 0)
#macro	MENUITM_SHOULD_OPEN_TEXTBOX		((flags & MENUITM_FLAG_OPEN_TEXTBOX)	!= 0)

// Determines how many items will exist on a single row and column within the menu, respectively.
#macro	MENUITM_WIDTH					4
#macro	MENUITM_HEIGHT					5

// Since the positional offsets for the options and their spacing are constant in the item menu, they will 
// be set using macros instead of referencing their relevant variables within the menu, which should result
// in VERY slightly faster execution.
#macro	MENUITM_OPTIONS_X				20
#macro	MENUITM_OPTIONS_Y				4
#macro	MENUITM_OPTION_XSPACING			21
#macro	MENUITM_OPTION_YSPACING			21

// Determines the maximum line width for an item's description string as well as the maximum number of lines
// that can exist for display within the inventory's item section.
#macro	MENUITM_OPTION_INFO_MAX_WIDTH	180
#macro	MENUITM_OPTION_INFO_MAX_LINES	3

// Determines the color of the shadows found behind text rendered through this menu's draw_gui event.
#macro	MENUITM_TEXT_SHADOW_COLOR		COLOR_DARK_GRAY
#macro	MENUITM_TEXT_SHADOW_ALPHA		1.0

// Determines how fast the menu's currently highlighted item will move up along the y axis and the value that 
// it will need to hit before the offset rolls back over to 0.
#macro	MENUITM_HLITEM_ANIM_SPEED		0.075
#macro	MENUITM_HLITEM_OFFSET_LIMIT		2.0

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

// The dimensions of the surface that the selected item's option menu will be rendered onto, so it can have a
// sliding animation that doesn't render outside of the dimensions of the menu after animations have completed.
#macro	SUBMENU_ITM_SURFACE_WIDTH		40
#macro	SUBMENU_ITM_SURFACE_HEIGHT		40

// Determines the two x positions the item's option menu text will shift between during the opening and closing
// animations for this sub menu; allowing it to slide on and off of the surface it will be drawn onto.
#macro	SUBMENU_ITM_ANIM_X1			   -50
#macro	SUBMENU_ITM_ANIM_X2				0

// Determines how fast the selected item's option menu will fade into and out of visibility during its opening
// and closing animations. It also works as the value used to lerp the menu's options between the two x
// positions stated above.
#macro	SUBMENU_ITM_OANIM_ALPHA_SPEED	0.1
#macro	SUBMENU_ITM_CANIM_ALPHA_SPEED	0.1

#endregion Macros for Item Options Sub Menu

#region Item Menu Struct Definition

/// @param {Function}	index	The value of "str_item_menu" as determined by GameMaker during runtime.
function str_item_menu(_index) : str_base_menu(_index) constructor {
	// Create two arrays that will store data about the item inventory's contents so the relevant parts can
	// be used and/or displayed on the UI for the player to see while accessing their items.
	var _itemInvSize	= array_length(global.curItems);
	invItemRefs			= array_create(_itemInvSize, INV_EMPTY_SLOT);
	itemDataToRender	= array_create(_itemInvSize, INV_EMPTY_SLOT);
	
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
	itemOptionsAlpha	= 0.0;
	
	// Value that loops between zero and 2.0 to create a verticalbobbing motion for an item that is currently 
	// being highlighted by the menu's cursor.
	curOptionOffset		= 0.0;
	
	/// @description 
	///	The item menus struct's create event. It initializes required parameters; sets up the auxillary return
	/// input bindings, and loads the contents of the item inventory in as menu options + descriptions.
	///	
	create_event = function(){
		// Get a referfence to this struct so its submenu can reference it in its "prevMenu" variable.
		selfRef				= instance_find_struct(structID);
		
		// Set up the "auxilliary" return inputs to the input that opens up this menu during gameplay, so 
		// it can also close the menu should the player choose to use it instead of the standard input.
		var _inputs			= global.settings.inputs;
		keyAuxReturn		= _inputs[STNG_INPUT_ITEM_MENU];
		padAuxReturn		= _inputs[STNG_INPUT_ITEM_MENU + 1];
		
		// Set up the item menu to it has the same number of options as there are slots available in the
		// player's item inventory. Using that number, the base and option parameters are both initialized.
		initialize_params(0, 14, true, true, MENUITM_WIDTH, MENUITM_WIDTH, MENUITM_HEIGHT);
		initialize_option_params(MENUITM_OPTIONS_X, MENUITM_OPTIONS_Y, 
			MENUITM_OPTION_XSPACING, MENUITM_OPTION_YSPACING, fa_left, fa_top, true);
		
		// Loop through the item inventory array so the menu can construct itself to accurately represent what
		// is currently contained within that data.
		var _invItem		= INV_EMPTY_SLOT;
		var _itemName		= MENUITM_DEFAULT_STRING;
		var _itemInfo		= MENUITM_DEFAULT_STRING;
		var _length			= array_length(global.curItems);
		for (var i = 0; i < _length; i++){
			_invItem = global.curItems[i];
			if (_invItem == INV_EMPTY_SLOT){ // Occupy the slot with an empty option.
				add_option(MENUITM_DEFAULT_STRING, MENUITM_DEFAULT_STRING);
				continue;
			}
			
			// 
			create_internal_item_data(i);
			with(_invItem){
				_itemName = itemName;
				with(global.itemIDs[itemID])
					_itemInfo = itemInfo;
			}
			add_option(_itemName, _itemInfo);
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
		
		// Clean up any elements that are currently occupied by extra item data structs.
		var _length = array_length(itemDataToRender);
		for (var i = 0; i < _length; i++){
			if (itemDataToRender[i] != INV_EMPTY_SLOT)
				delete itemDataToRender[i];
		}
	}
	
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos	The menu's current x position added with the viewport's current x position.
	/// @param {Real}	yPos	The menu's current y position added with the viewport's current y position.
	/// @param {Real}	wView	The viewport's current width.
	/// @param {Real}	hView	The viewport's current height.
	draw_gui_event = function(_xPos, _yPos, _wView, _hView){
		// Set the font used by all text within this menu, set the proper alignment for the quantity text that 
		// can appear alongside an item's icon, and set the opacity of all draw commands that don't take in an 
		// alpha level to the current opacity of the menu.
		draw_set_font(fnt_small);
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_alpha(alpha);
		
		// Increase the y offset of the currently highlighted item by its speed relative to the current delta
		// time until it hits or exceeds its limit value; where it will wrap back around to 0.
		curOptionOffset += MENUITM_HLITEM_ANIM_SPEED * global.deltaTime;
		if (curOptionOffset >= MENUITM_HLITEM_OFFSET_LIMIT)
			curOptionOffset -= MENUITM_HLITEM_OFFSET_LIMIT;
		
		// Loop through all available inventory slots to display them within the UI of the item menu. Occupied
		// slots will contain some information about the item itself as well as a sprite that represents the
		// item.
		var _item			= INV_EMPTY_SLOT;
		var _alpha			= alpha;
		var _optionX		= _xPos + optionX;
		var _optionY		= _yPos + optionY;
		var _curOptOffset	= 0;
		var _option			= 0;
		var _slotCol		= COLOR_TRUE_WHITE;
		var _length			= ds_list_size(options);
		for (var yy = 0; yy < height; yy++){
			for (var xx = 0; xx < width; xx++){
				// Determine the option's index based on the current x/y position of the slot that will be 
				// drawn. Should this value exceed the inventory's current size, it will break out of this
				// loop and the outer loop by setting yy to the menu's height.
				_option = (yy * width) + xx;
				if (_option >= _length){
					yy = height;
					break;
				}
				
				// Determine blending characteristics of the item slot/icon as well as the icon's positional
				// offset based on whether the slot in question is visible (the "else" block), highlighted
				// (_option == curOption), the primary selection (_option == selOption), of the stored
				// selection (_option == auxSelOption), respectively.
				if (_option == auxSelOption){ 
					_slotCol		= COLOR_RED;
					_curOptOffset	= (_option == curOption) ? floor(curOptionOffset) : 1;
				} else if (_option == selOption){
					_slotCol		= COLOR_GREEN;
					_curOptOffset	= 1;
				} else if (_option == curOption){ 
					_slotCol		= COLOR_YELLOW;
					_curOptOffset	= floor(curOptionOffset);
				} else{
					_slotCol		= COLOR_TRUE_WHITE;
					_curOptOffset	= 0;
				}
				
				// Determine whether to use the default version of the slot sprite or its highlighted
				// counterpart depending on what the _slotCol variable was set to in the if/else block 
				// above.
				var _imageIndex = (_slotCol != COLOR_TRUE_WHITE);
				draw_sprite_ext(spr_item_menu_slot, _imageIndex, _optionX, 
					_optionY, 1.0, 1.0, 0.0, _slotCol, alpha);
				
				// The current item in the slot will have its icon drawn and quantity, if that is also 
				// required.
				_item = global.curItems[_option];
				if (_item != INV_EMPTY_SLOT){
					with(_item){ // Determine which shading to use for the item's icon.
						if (_slotCol == COLOR_TRUE_WHITE)	{ _slotCol = COLOR_GRAY; }
						else if (_slotCol == COLOR_YELLOW)	{ _slotCol = COLOR_TRUE_WHITE; }
						
						draw_sprite_ext(spr_item_menu_item_icons, itemID, _optionX, 
							_optionY - _curOptOffset, 1.0, 1.0, 0.0, _slotCol, _alpha);
					}
					
					// Displays the current quantity and the symbol signifying the item is equipped if 
					// that flag is currently set within the render data struct.
					with(itemDataToRender[_option]){
						draw_text_shadow(_optionX + 18, _optionY + 19, quantityStr, 
							quantityCol, _alpha, COLOR_DARK_GRAY, _alpha);
						if (isEquipped){
							draw_sprite_ext(spr_item_menu_equip_icon, 0, _optionX + 11, _optionY - 1, 
								1.0, 1.0, 0.0, COLOR_TRUE_WHITE, _alpha);
						}
					}
				}
				_optionX += optionSpacingX;
			}
			_optionX	= _xPos + optionX;
			_optionY   += optionSpacingY;
		}
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		// Draw the currently highlighted item's name and description below the region of the item menu that
		// contains the player's item inventory and its current contents.
		_optionX	= _xPos + optionX;
		_optionY	= _yPos + optionY;
		_item		= invItemRefs[curOption];
		if (_item != INV_EMPTY_SLOT){
			with(_item){
				draw_text_shadow(_optionX + 5, _optionY + 106, itemName, 
					COLOR_WHITE, _alpha, COLOR_DARK_GRAY, _alpha);
				draw_text_shadow(_optionX, _optionY + 118, itemInfo,
					COLOR_LIGHT_GRAY, _alpha, COLOR_DARK_GRAY, _alpha);
			}
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
		draw_clear_alpha(COLOR_BLACK, 0);
		with(itemOptionsMenu)
			draw_gui_event(4, 2, COLOR_DARK_GRAY);
		surface_reset_target();
		
		// Remaining elements to draw all rely on these offsets, so calculate them once here.
		_xPos += itemOptionsMenuX;
		_yPos += itemOptionsMenuY;
		
		#region Drawing Background for Item Options Menu
		
			draw_sprite_stretched_ext(
				spr_item_menu_slot, 
				1,		// Uses highlighted version of the sprite
				_xPos - 2, _yPos - 2, 
				SUBMENU_ITM_SURFACE_WIDTH + 4, itemOptionsMenuHeight,
				COLOR_LIGHT_BLUE, itemOptionsAlpha
			);
		
		#endregion Drawing Background for Item Options Menu
				
		// Finally, draw the current capture of the selected item's option menu text onto the screen.
		draw_set_alpha(itemOptionsAlpha);
		draw_surface(itemOptionsSurf, _xPos, _yPos);
	}
	
	/// @description 
	///	Allows a single line of code calling this function to encapsulate all that is required to reset the
	/// item menu back to its default parameters before assigning its current state back to state_default.
	///	
	reset_to_default_state = function(){
		// Re-enable the change page and two additional cursor movement inputs within the menu movement 
		// control group so they are shown again.
		var _movementCtrlGroup = movementCtrlGroup;
		with(CONTROL_UI_MANAGER){
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_LEFT,	true);
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_RIGHT,	true);
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_LEFT,		true);
			update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_RIGHT,		true);
			update_control_group_icon_descriptor(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_DOWN,		"Cursor");
		}
		
		// After re-enabling the necessary input information, the inventory has flags set that re-enable its
		// ability to close through the return input being pressed, its ability to switch from one section to
		// another, and the item menu is reset to its default state.
		with(prevMenu) { flags = flags | MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE & ~MENUINV_FLAG_HIDE_CONTROLS; }
		object_set_state(state_default);
		flags			= flags & ~(MENUITM_FLAG_MOVING_ITEM | MENUITM_FLAG_OPEN_TEXTBOX);
		auxSelOption	= -1;
		selOption		= -1;
	}
	
	/// @description 
	/// When called, this function will call the "item_inventory_add" function; passing in all of its parameters
	/// into that function. On top of that, the renderable data for the item menu are updated as required
	/// if some amount of all of the item was actually added into the item inventory.
	///	
	///	@param {String}	item		String representing the name/key of the item.
	///	@param {Real}	amount		How many of said item will be added to the inventory.
	/// @param {Real}	durability	(Optional; Higher Difficulties Only) The item's current condition.
	///	@param {Real}	ammoIndex	(Optional; Weapon-Type Items Only) The ammunition found within the item relative to its list of valid ammo types.
	add_item_to_inventory = function(_item, _amount, _durability = 0, _ammoIndex = 0){
		var _remainder = item_inventory_add(_item, _amount, _durability, _ammoIndex);
		if (_remainder == _amount) // Item wasn't added to the inventory; exit before the loop.
			return;
		
		// Since we don't know what slot the item was added into the inventory, all available slots are checked
		// and when there is a difference in the slot's state (has item vs no item) and the current renderable
		// information, call the function to create that info for the item menu.
		var _length = array_length(global.curItems);
		for (var i = 0; i < _length; i++){
			if (global.curItems[i] == INV_EMPTY_SLOT || (invItemRefs[i] != INV_EMPTY_SLOT 
					&& itemDataToRender[i] != INV_EMPTY_SLOT))
				continue;
			create_internal_item_data(i);
		}
	}
	
	/// @description 
	///	Creates a new struct within the "itemDataToRender" struct that stores the string versions of any
	/// values that need to be rendered onto the item menu's inventory grid.
	/// 
	/// @param {Real}	slot	The item that will have its properties passed along to the menu for rendering.
	create_internal_item_data = function(_slot){
		var _itemID			= ID_INVALID;
		var _quantity		= 0;
		var _quantityCol	= COLOR_WHITE;
		var _showStack		= false;
		with(global.curItems[_slot]){
			_itemID		= itemID;
			_quantity	= min(999, quantity);
			if (_quantity == 0) // If the quantity happens to be zero; set the number to dark red.
				_quantityCol = COLOR_DARK_RED;
		}
		
		var _itemRef = global.itemIDs[_itemID];
		with(_itemRef){
			_showStack	= ((typeID == ITEM_TYPE_WEAPON && !WEAPON_IS_MELEE) || stackLimit > 1);
			if (_quantity == stackLimit) // When the quantity is full turn the quantity's color to light green.
				_quantityCol = COLOR_LIGHT_GREEN;
		}
		
		// Determine if the slot should display an "equipped" icon by seeing if the item occupying it is
		// equipped in any of the player's five equipment slots.
		var _isEquipped = false;
		with(PLAYER.equipment){
			_isEquipped = (weapon == _slot || armor == _slot || light == _slot 
					|| firstAmulet == _slot || secondAmulet == _slot);
		}
		
		array_set(invItemRefs, _slot, _itemRef);
		array_set(itemDataToRender, _slot, {
			quantityStr	: _showStack ? string(_quantity) : "",
			quantityCol	: _quantityCol,
			isEquipped	: _isEquipped,
		});
	}
	
	/// @description 
	///	Removes whatever item is found within the provided slot index in the player's item inventory. 
	/// Optionally, an amount can be provided in case the entire stack doesn't need to be removed. Omitting
	/// this value will remove the entire stack found in that slot.
	///	
	/// @param {Real}	slot		The slot in the inventory that will have some amount of its contents removed.
	/// @param {Real}	amount		(Optional) How many of that item will be removed from the slot in question.
	remove_item_from_slot = function(_slot, _amount = -1){
		var _slotEmpty	= false;
		var _itemID		= ID_INVALID;
		with(global.curItems[_slot]){
			_slotEmpty	= (_amount <= -1 || quantity - _amount <= 0);
			_itemID		= itemID;
		}
		
		if (_slotEmpty) { item_inventory_remove_slot(_slot); }
		else			{ item_inventory_remove(_itemID, _amount); }
		
		refresh_internal_item_data(_slot, global.itemIDs[_itemID]);
	}
	
	/// @description 
	/// Takes whatever was previously stored for renderable information within the provided slot index and
	/// either replaces it with new information to reflect the item that is now within the slot or removes
	/// the information if no item occupies the slot.
	///	
	/// @param {Real}				slot		The slot in the inventory that will have its render data refreshed.
	/// @param {Struct._structRef}	itemRef		The struct containing the item's non-inventory struct information that will be stored for later use.
	refresh_internal_item_data = function(_slot, _itemRef){
		// By default, a quantity of zero (Excluding weapons as they can have a quantity of zero and still
		// exist in the inventory) will signify the slot in question no longer contains an item, and the
		// renderable data should be removed.
		var _quantity	= 0;
		var _invItemRef = global.curItems[_slot];
		if (_invItemRef != INV_EMPTY_SLOT)
			_quantity = _invItemRef.quantity;
		
		// If the quantity is greater than zero OR the item in question is a weapon, the branch below is
		// taken and the contents of the renderable data are refreshed to reflect any potential changes.
		if (_quantity > 0 || (!is_undefined(_itemRef) && _itemRef.typeID == ITEM_TYPE_WEAPON)){
			if (itemDataToRender[_slot] != INV_EMPTY_SLOT)
				delete itemDataToRender[_slot]; // Delete this previous struct as the function call below creates a new one.
			create_internal_item_data(_slot);
			
			var _itemName = MENUITM_DEFAULT_STRING;
			var _itemInfo = MENUITM_DEFAULT_STRING;
			with(_itemRef){ // Get the name and info text for the item that is having its data refreshed.
				_itemName = itemName;
				_itemInfo = itemInfo;
			}
			with(options[| _slot]){ // Copy what was stored into the required parameters within the menu's option struct.
				oName = _itemName;
				oInfo = _itemInfo;
			}
			return;
		}
		
		// Check if there is an item occupying the current slot and whether or not that item is equipped.
		// If both these checks are true, the item in question is unequipped from the player before the
		// renderable data for the item is removed.
		var _dataRef = itemDataToRender[_slot];
		if (_dataRef != INV_EMPTY_SLOT && _dataRef.isEquipped){
			selOption = _slot;
			state_unequip_item(0.0);
		}
		itemDataToRender[_slot] = INV_EMPTY_SLOT;
		delete _dataRef;
		
		// Remove the reference to the item as it is no longer within the item inventory. Then,
		// remove the item's data from the menu option with the same slot index.
		invItemRefs[_slot] = INV_EMPTY_SLOT;
		with(options[| _slot]){ // Set the option struct to its default values.
			oName = MENUITM_DEFAULT_STRING;
			oInfo = MENUITM_DEFAULT_STRING;
		}
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
		if (MINPUT_IS_SELECT_RELEASED && curOption != auxSelOption){
			// Don't jump into any of this selection code logic if the current slot is empty AND the 
			// inventory isn't currently set to move an item to another slot. If slot movement is occurring, 
			// the check is bypassed to be stopped further below.
			var _isMovingItem = MENUITM_IS_MOVING_ITEM;
			if (!_isMovingItem && invItemRefs[curOption] == INV_EMPTY_SLOT)
				return;
			with(prevMenu){ flags = flags & ~(MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE); }
			
			// Disable the page and cursor left/right input information since the inventory is no longer 
			// able to switch between each of the three sections contained within it.
			var _movementCtrlGroup = movementCtrlGroup;
			with(CONTROL_UI_MANAGER){
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_LEFT,	false);
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_RIGHT,	false);
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_LEFT,		false);
				update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_PAGE_RIGHT,		false);
				update_control_group_icon_descriptor(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_DOWN,		"Navigate");
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
					
					// An item that would normally have the "Equip" option as the first in the list of 
					// available options will have it changed to "Unequip" if the weapon happens to be 
					// equipped to the player.
					if (itemDataToRender[selOption].isEquipped)
						_options[0] = MENUITM_OPTION_UNEQUIP;
						
					break;
				case ITEM_TYPE_CONSUMABLE:
					_options = [
						MENUITM_OPTION_USE, 
						MENUITM_OPTION_COMBINE, 
						MENUITM_OPTION_MOVE, 
						MENUITM_OPTION_DROP
					];
					break;
				case ITEM_TYPE_KEY_ITEM:
					_options = [ // These are the only two options available to every key item.
						MENUITM_OPTION_COMBINE,
						MENUITM_OPTION_MOVE,
					];
					
					// Add the "Use" and "Drop" options for key items here by checking if the flags for adding
					// said options are set within the item's flag variable.
					with(invItemRefs[selOption]){
						if (KEYITM_CAN_BE_USED)		{ array_insert(_options, 0, MENUITM_OPTION_USE); }
						if (KEYITM_CAN_BE_DROPPED)	{ array_push(_options, MENUITM_OPTION_DROP); }
					}
					
					break;
			}
			
			// If the struct already exists, replace the previous options and clear the bit that is normally
			// set when the sub menu is closing. Finally, copy the vertical spacing between options like was
			// done in below so the height of the menu's background can be calculated.
			var _ySpacing = 0;
			with(itemOptionsMenu){
				replace_options(_options, 1, 1, array_length(_options));
				flags		= flags & ~MENUSUB_FLAG_CLOSING;
				_ySpacing	= optionSpacingY;
			}
			
			// Create the sub menu for the select item's available options. Then, set the alpha to fully opaque
			// since the item menu renders this sub menu onto a separate surface, and copy over the vertical
			// spacing between options so the height of the menu's background can be calculated.
			if (itemOptionsMenu == noone){
				itemOptionsMenu	= create_sub_menu(str_sub_menu, selfRef, 0, 0, _options, 1, 1, array_length(_options));
				with(itemOptionsMenu){
					alpha		= 1.0;
					_ySpacing	= optionSpacingY;
				}
			}
			
			// Finally, swap over the opening state for the item options menu. On top of that, set the flag
			// that lets this menu know that sub menu is open, and position it to show up beside the selected
			// item's name. The cursor animation offset/timer is also reset to zero.
			object_set_state(state_open_item_options);
			flags = flags | MENUITM_FLAG_OPTIONS_OPEN;
			
			// Calculate the offset for the item's options menu and its height for the background UI.
			itemOptionsMenuX = MENUITM_OPTIONS_X + ((curOption % width)		 * MENUITM_OPTION_XSPACING) + MENUITM_OPTION_XSPACING;
			itemOptionsMenuY = MENUITM_OPTIONS_Y + (floor(curOption / width) * MENUITM_OPTION_YSPACING);
			itemOptionsMenuHeight = (array_length(_options) * _ySpacing) + 8;
			return;
		}
		
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
		var _isOpened			= false;
		var _itemOptionsAlpha	= itemOptionsAlpha;
		with(itemOptionsMenu){
			optionX				= lerp(SUBMENU_ITM_ANIM_X1, SUBMENU_ITM_ANIM_X2, _itemOptionsAlpha); 
			_itemOptionsAlpha  += SUBMENU_ITM_OANIM_ALPHA_SPEED * _delta;
			if (_itemOptionsAlpha >= 1.0){ // Animation has completed; set values to their targets.
				object_set_state(state_default);
				flags				= flags | MENU_FLAG_ACTIVE;
				optionX				= SUBMENU_ITM_ANIM_X2;
				_itemOptionsAlpha	= 1.0;
				_isOpened			= true;
			}
		}
		itemOptionsAlpha = _itemOptionsAlpha;
		
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
		var _isClosed			= false;
		var _itemOptionsAlpha	= itemOptionsAlpha;
		with(itemOptionsMenu){
			optionX				= lerp(SUBMENU_ITM_ANIM_X1, SUBMENU_ITM_ANIM_X2, _itemOptionsAlpha); 
			_itemOptionsAlpha  -= SUBMENU_ITM_CANIM_ALPHA_SPEED * _delta;
			if (_itemOptionsAlpha <= 0.0){ // Animation has completed; reset flags and set values to their targets.
				flags				= flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_CURSOR_AUTOSCROLL);
				optionX				= SUBMENU_ITM_ANIM_X1;
				_itemOptionsAlpha	= 0.0;
				_isClosed			= true;
			}
		}
		itemOptionsAlpha = _itemOptionsAlpha;
		
		// Don't proceed further into the funcition if the closing animation hasn't yet concluded.
		if (!_isClosed)
			return;
		flags = flags & ~MENUITM_FLAG_OPTIONS_OPEN; // Clear flag since this submenu is now closed.
		
		// When flagged to close the item inventory menu in its whole on an item's use, this branch of the code
		// is taken. It will also check if the textbox needs to opened after the menu has finished its closing
		// animation.
		if (MENUITM_SHOULD_CLOSE_ON_USE){
			var _openTextbox = MENUITM_SHOULD_OPEN_TEXTBOX;
			with(prevMenu){ 
				object_set_state(state_close_animation);
				if (_openTextbox) { flags = flags | MENUINV_FLAG_OPEN_TEXTBOX; }
			}
			return;
		}
		
		// When flagged to open the textbox (But not also flagged to close the item inventory menu), the menu
		// will switch to a special state which it will remain in until the textbox that it was signaled to
		// open is closed.
		if (MENUITM_SHOULD_OPEN_TEXTBOX){
			with(prevMenu)	{ flags = flags | MENUINV_FLAG_HIDE_CONTROLS; }
			with(TEXTBOX)	{ activate_textbox(0, TBOX_FLAG_HIDE_CONTROLS); }
			object_set_state(state_textbox_open);
			return;
		}
		
		// If no special flags have been set through the use of an item, the function will simply reset the
		// item inventory menu back to its default state, and will reset required values back to 0 if the value
		// in "auxSelOption" is set to anything other than its default of -1.
		object_set_state(state_default);
		if (auxSelOption == -1) 
			reset_to_default_state();
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
			var _oName = "";
			with(itemOptionsMenu)
				_oName = options[| selOption].oName;
			
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
					
					// Update the Control UI for the Item Menu so it displays the left and right cursor 
					// movement inputs alongside the up/down inputs that were displayed for the selected
					// item's option menu.
					var _movementCtrlGroup = movementCtrlGroup;
					with(CONTROL_UI_MANAGER){
						update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_LEFT,	true);
						update_control_group_icon_active_state(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_RIGHT,	true);
						update_control_group_icon_descriptor(_movementCtrlGroup, MENUINV_CTRL_GRP_CURSOR_DOWN,		"Cursor");
					}
					break;
				case MENUITM_OPTION_DROP:		// Removes slot from the inventory; creates a world item on the floor representing the slot's contents.
					var _dataRef = itemDataToRender[selOption];
					if (_dataRef != INV_EMPTY_SLOT){ 
						if (_dataRef.isEquipped) // Unequip the item if it happens to be equipped.
							state_unequip_item(_delta);
						itemDataToRender[selOption] = INV_EMPTY_SLOT;
						delete _dataRef;
					}
					
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
			with(itemOptionsMenu) { object_set_state(STATE_NONE); }
		}
	}
	
	/// @description
	///	A single-frame state that attempts to use the select item and apply its effects to the player, game
	/// world, area, etc.. The item's option window begins its closing animation after this.
	///
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_use_item = function(_delta){
		var _selOption	= selOption;
		var _useFlags	= 0;
		var _itemID		= ID_INVALID;
		with(invItemRefs[selOption]){
			if (useFunction != NO_FUNCTION && script_exists(useFunction))
				_useFlags = script_execute(useFunction, _selOption);
			_itemID	= itemID;
		}
		object_set_state(state_close_item_options);

		// No additional logic needs to be performed for the item being used; exit the function early.
		if (_useFlags == 0)
			return;
			
		// Set the flag within the item inventory if the item being used requires the item inventory menu to
		// be closed when it is used by the player in-game.
		if ((_useFlags & USEITM_FLAG_CLOSE_MENU) != 0)
			flags = flags | MENUITM_FLAG_CLOSE_ON_USE;
			
		// Set the flag within the item menu that tells it to toggle the flag within the inventory menu struct 
		// (Which handles opening and closing this menu) that activates the textbox with whatever contents
		// exists in the text queue.
		if ((_useFlags & USEITM_FLAG_OPEN_TEXTBOX) != 0)
			flags = flags | MENUITM_FLAG_OPEN_TEXTBOX;
		
		// The final check for item consumption flags: removing the itme that was used from the current item
		// inventory. Deletes the necessary data from the menu's data if the item no longer exists in the slot.
		if ((_useFlags & USEITM_FLAG_CONSUMED) != 0){
			item_inventory_remove(_itemID, 1);
			if (global.curItems[selOption] == INV_EMPTY_SLOT){
				invItemRefs[selOption]		= INV_EMPTY_SLOT;
				itemDataToRender[selOption] = INV_EMPTY_SLOT;
				delete itemDataToRender[selOption];
			}
		}
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
		
		// If there was a previously equipped item in the slot where this new item is equipped, its flag will
		// be set to false before flipping the equipped flag for the new item to true.
		if (_slotToCheck != INV_EMPTY_SLOT)
			itemDataToRender[_slotToCheck].isEquipped = false;
		itemDataToRender[selOption].isEquipped = true;
		
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
		var _itemData = invItemRefs[selOption];
		with(PLAYER){
			// Determine which unequip function to call relative to the item's "equipment type".
			switch(_itemData.equipType){
				case ITEM_EQUIP_TYPE_FLASHLIGHT:	unequip_flashlight();		break;
				case ITEM_EQUIP_TYPE_MAINWEAPON:	unequip_main_weapon();		break;
			}
		}
		
		// Ensure the inventory knows the item in question is unequipped by flipping the flag to false.
		itemDataToRender[selOption].isEquipped = false;
		
		// Finally, switch to the state that will close the selected item's option menu/window so normal
		// functionality can return to the item menu.
		object_set_state(state_close_item_options);
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_combine_item = function(_delta){
		var _firstSlot	= auxSelOption;
		var _secondSlot = selOption;
		var _firstItem	= invItemRefs[auxSelOption];
		var _secondItem = invItemRefs[selOption];
		if (_firstItem == REF_INVALID || _secondItem == REF_INVALID){ //  Prevent combination from occurring if either item is invalid.
			reset_to_default_state();
			return;
		}
		
		// Swap the references if the second item happens to have an item ID value that is lower than the 
		// first item, as the crafting data is sorted by the first item's ID for organization purposes.
		if (_firstItem.itemID > _secondItem.itemID){
			var _temp	= _firstItem;
			_firstItem	= _secondItem;
			_secondItem = _temp;
			_firstSlot	= selOption;
			_secondSlot	= auxSelOption;
		}
		reset_to_default_state();
		
		// Get the ID and names for both items involved in the combination process.
		var _firstItemID	= ID_INVALID;
		var _firstItemName	= "";
		with(_firstItem){
			_firstItemID	= itemID; 
			_firstItemName	= itemName;
		}
		var _secondItemID	= ID_INVALID;
		var _secondItemName	= "";
		with(_secondItem){ 
			_secondItemID	= itemID;
			_secondItemName	= itemName;
		}
		
		// Create additional local values that will be utilized for general combination as well as upgrading
		// a piece of equipment (Which is the whole branch directly below these variable initializations).
		var _comboSuccess	= false;
		var _resultItemID	= ID_INVALID;
		var _validCombos	= global.itemData[? KEY_VALID_COMBOS];
		var _length			= ds_list_size(_validCombos);
		
		// Since the upgrade parts should never have an ID value lower than any weapon in the game, the
		// second item's name is always checked to see if it is the upgrade parts. If so, the first item
		// (Which should be a weapon) will be upgraded.
		if (_secondItemName == ITEM_UPGRADE_PARTS){
			for (var i = 0; i < _length; i++){ // TODO -- Potentially change to binary search since data is organized.
				with(_validCombos[| i]){
					if (firstItem != _firstItemID || secondItem != _secondItemID)
						continue;
					_resultItemID = resultItem;
					_comboSuccess = (_resultItemID >= 0 && _resultItemID < array_length(global.itemIDs));
					break;
				}
			}
			
			// If the combo succeeded, the item being upgraded is removed along with a single upgrade part. 
			// Then, the upgraded version of the item is added to the player's item inventory. The quantity
			// and ammo index values for the item before it was upgraded are passed along to the new item;
			// the durability will always be its maximum possible value after an upgrade.
			if (_comboSuccess){
				var _quantity	= 0;
				var _ammoIndex	= 0;
				with(global.curItems[_firstSlot]){ // Get the item's current quantity and ammo index as they carry over during the upgrade.
					_quantity	= quantity;
					_ammoIndex	= ammoIndex;
				}
				remove_item_from_slot(_firstSlot);
				remove_item_from_slot(_secondSlot, 1);
				
				var _name		= "";
				var _durability	= 0;
				with(global.itemIDs[_resultItemID]){ // Get the resulting items name and its maximum possible durability value (If said value exists for the item).
					_name		= itemName;
					_durability	= variable_struct_exists(global.itemIDs[_resultItemID], "durability") ? durability : 0;
				}
				add_item_to_inventory(_name, _quantity, _durability, _ammoIndex);
			}
			return;
		}
		
		// 
		var _firstCost		= 0;
		var _secondCost		= 0;
		var _resultQuantity	= 0;
		var _resultMin		= 0;
		var _resultMax		= 0;
		
		// 
		for (var i = 0; i < _length; i++){
			with(_validCombos[| i]){
				if (firstItem != _firstItemID || secondItem != _secondItemID)
					continue;
				_firstCost		= firstCost;
				_secondCost		= secondCost;
				_resultItemID	= resultItem;
				_resultMin		= minAmount;
				_resultMax		= maxAmount;
				_comboSuccess	= (_resultItemID >= 0 && _resultItemID < array_length(global.itemIDs));
				break;
			}
		}
		
		// 
		if (_comboSuccess){
			if ( global.curItems[_firstSlot].quantity < _firstCost || global.curItems[_secondSlot].quantity < _secondCost){
				with(TEXTBOX){ // Flavor text letting the player know they can make something out of the combo, but they need more of either item.
					queue_new_text("I don't have enough to make anything out of these items...");
					activate_textbox(0, TBOX_FLAG_HIDE_CONTROLS);
				}
				object_set_state(state_textbox_open);
				return;
			}
			remove_item_from_slot(_firstSlot, _firstCost);
			remove_item_from_slot(_secondSlot, _secondCost);
			
			// 
			var _name		= global.itemIDs[_resultItemID].itemName;
			var _quantity	= irandom_range(_resultMin, _resultMax);
			add_item_to_inventory(_name, _quantity);
			return;
		}
		
		with(TEXTBOX){ // Flavor text letting the player know they can't make anything out of the combination. 
			queue_new_text("Seems like nothing happens when I try to combine these two together...");
			activate_textbox(0, TBOX_FLAG_HIDE_CONTROLS);
		}
		object_set_state(state_textbox_open);
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
			
			// Perform a check that will see if any of the current equipment slot values need to be updated to
			// match the fact that an item (Or two) were moved from their previous slots. If so, they will
			// be updated through this function call.
			if (itemDataToRender[auxSelOption] != INV_EMPTY_SLOT || itemDataToRender[curOption] != INV_EMPTY_SLOT){
				var _auxSelOption	= auxSelOption;
				var _curOption		= curOption;
				with(PLAYER) { update_equip_slot(_auxSelOption, _curOption); }
			}
			
			// Update the references to the structs that hold data about how to render an item information on
			// the slot its icon occupies in the item inventory.
			var _prevAuxSelOptionData		= itemDataToRender[auxSelOption];
			itemDataToRender[auxSelOption]	= itemDataToRender[curOption];
			itemDataToRender[curOption]		= _prevAuxSelOptionData;
				
			// Update the references to item structs within the item inventory so the slots they occupy matches
			// where they are now located after the slot swap occurs.
			var _tempInvItemRef				= invItemRefs[auxSelOption];
			invItemRefs[auxSelOption]		= invItemRefs[curOption];
			invItemRefs[curOption]			= _tempInvItemRef;
			
			// Like above, the option contents need to be swapped to match the fact that two items changed
			// places within the item inventory.
			var _tempOptionRef				= options[| auxSelOption];
			options[| auxSelOption]			= options[| curOption];
			options[| curOption]			= _tempOptionRef;
		}
		
		reset_to_default_state();
	}
	
	/// @description 
	///	A simple state that waits until the textbox is closed before returning control back over to the
	/// item inventory menu. Useful whenever an item needs to open the textbox, but doesn't need to close the
	/// menu out beforehand.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_textbox_open = function(_delta){
		if (!GAME_IS_TEXTBOX_OPEN){
			reset_to_default_state();
			prevInputFlags	= 0;
			inputFlags		= 0;
		}
	}
}

#endregion Item Menu Struct Definition