extends Control

##
## Function that's permit drag some data (item in a slot)
##
func get_drag_data(position):
	var owner_node = get_owner().get_parent().get_owner()
	owner_node.fill_equip_with_empty_slot_skin()
	owner_node.hide_item_desc()
	var button = TextureButton.new()
	button.rect_size = Vector2(200,200)
	button.rect_position = button.rect_size / 2
	button.expand = true
	button.texture_normal = self.texture_normal
	set_drag_preview(button)
	return self

