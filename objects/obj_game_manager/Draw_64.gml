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

var _minAlpha = gpu_get_alphatestref() / 255.0;

// 
_length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i]){
		if (alpha <= _minAlpha || !MENU_IS_VISIBLE)
			continue;
		draw_gui_event();
	}
}

// 
with(TEXTBOX){
	if (alpha <= _minAlpha || y >= VIEWPORT_HEIGHT)
		break;
	draw_gui_event();
}

draw_set_color(c_maroon);
draw_set_halign(fa_right);
draw_text(60, 5, string("{0}\n{1}\n{2}", floor(fps_real), global.deltaTime, global.flags));