// with(CAMERA) { camera_apply_shake(random_range(1.5, 7.0), random_range(15.0, 150.0)); }

/*with(TEXTBOX){
	queue_new_text("This is a test to see if the textbox can still function when it is formatting or parsing text on-the-fly as required.");
	queue_new_text("Instead of having to format everything at once whenever a new string is queued for display.");
	queue_new_text("This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test.\n(@0xF86040{to see if color formatting isn't bugged here}).");
	add_options(
		queue_new_text("One more textbox because why not."),[
			"TEST OPTION 1", 
			"TEST OPTION 2",
			"TEST OPTION 3",
		], [
			[ // TEST OPTION 1
				set_next_index, TBOX_INDEX_CLOSE
			],
			[ // TEST OPTION 2
				set_next_index, 0
			],
			[ // TEXT OPTION 3
				set_event_flag, 2, true,
				set_event_flag, 3, true
			]
		]
	);
	queue_new_text("This is a test to see if the nextIndex value can be updated on-the-fly depending on player choice.");
	activate_textbox();
}*/

// item_inventory_remove(global.itemData[? ITEM_HANDGUN_AMMO].itemID, irandom_range(3, 32));

/*var _pX		= PLAYER.x;
var _pY		= PLAYER.y;
var _dir	= random(360);
add_debug_line(_pX, _pY, _pX + lengthdir_x(100, _dir), _pY + lengthdir_y(100, _dir), 120.0);*/