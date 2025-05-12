draw_set_font(fnt_small);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(5, 5, string("FPS\nDelta\nFlags"));

var _invItem	= -1;
var _itemData	= -1;
var _length		= array_length(global.inventory);
for (var i = 0; i < _length; i++){
	_invItem = global.inventory[i];
	if (_invItem == INV_EMPTY_SLOT)
		continue;
		
	_itemData = global.itemData[? _invItem.index];
	if (is_undefined(_itemData))
		continue;
		
	draw_text(5, 50 + (i * 8),		string("slot {0}: {1}", i + 1, _itemData.itemName));
	draw_text(130, 50 + (i * 8),	string("x{0}", _invItem.quantity));
}

draw_set_color(c_maroon);
draw_set_halign(fa_right);
draw_text(60, 5, string("{0}\n{1}\n{2}", floor(fps_real), global.deltaTime, global.flags));