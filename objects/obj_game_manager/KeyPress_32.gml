/*with(TEXTBOX){
	// queue_new_text("This is a test to see if the textbox can still function when it is formatting or parsing text on-the-fly as required.");
	// queue_new_text("Instead of having to format everything at once whenever a new string is queued for display.");
	queue_new_text("This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test.\n(@0xF86040{to see if color formatting isn't bugged here}).");
	// queue_new_text("One more textbox because why not.");
	activate_textbox();
}*/


// item_inventory_remove(global.itemData[? ITEM_HANDGUN_AMMO].itemID, irandom_range(3, 32));

var _pX		= PLAYER.x;
var _pY		= PLAYER.y;
var _dir	= random(360);
add_debug_line(_pX, _pY, _pX + lengthdir_x(100, _dir), _pY + lengthdir_y(100, _dir), 120.0);