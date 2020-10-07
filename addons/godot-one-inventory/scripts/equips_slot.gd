extends Control

## Get's the owner node (inventory)
onready var owner_node = get_owner()

func _ready():
	owner_node.slot_empty(self.get_parent())

##
## Get's the previous item (key that's define the item)
## return key of item or null if is empty
##
func _get_previous_item():
	if self.get_node("item").text.empty():
		return null
	else:
		return self.get_node("item").text

##
## Test if the drop is possible
## The drop is possible if the affect (attrib.affect) is 'equipset'
##
func can_drop_data(position, data):
	if get_owner().items.items[data.get_node("item").text].attrib.affect == self.get_name():
		return true

##
## Drop the item into 'equipset'
##
func drop_data(position, data):
	var key = data.get_node("item").text
	var item = owner_node.get_item(key)
	var button = owner_node.get_node("separate/items/item_desc/use")
	
	# If an item already equiped, unequip then
	if self.texture_normal != null:
		unequip_item(self, button)
		
	self.texture_normal = data.texture_normal
	self.get_node("item").set_text(key)
	self.connect("button_up", self, "on_head_button_up", [key])
	owner_node.set_equip(key, item)
	# cleaning slot of used item
	data.texture_normal = null
	data.get_node("item").text = ""
	data.get_parent().get_node("amount").text = ""
	owner_node.disconnect_signals(data, "button_up", owner_node, "_item_selected")
	data.set_script(null)
	owner_node.hide_item_desc()
	owner_node.fill_equip_with_empty_slot_skin()
	owner_node.slot_empty(data.get_parent())
	owner_node.emit_signal("equipped_item", item)

##
## The equipped item was selected, that permits unequip then
##
func on_head_button_up(item):
	var button = owner_node.get_node("separate/items/item_desc/use")
	var dropButton = owner_node.get_node("separate/items/item_desc/drop")
	owner_node.disconnect_signals(button, "button_up", owner_node, "_equip_item")
	owner_node.disconnect_signals(button, "button_up", owner_node, "_use_item")
	owner_node.disconnect_signals(dropButton, "button_up", owner_node, "_equip_drop")
	owner_node.disconnect_signals(dropButton, "button_up", owner_node, "_use_drop")
	owner_node.fill_equip_with_empty_slot_skin()
	owner_node.fill_consume_with_empty_slot_skin()
	owner_node.show_item_desc(item)
	owner_node.slot_filled(self.get_parent())
	button.get_node("Label").set_text(tr("BT_UNEQUIP"))
	button.connect("button_up", self, "unequip_item", [self, button])
#	dropButton.connect("button_up", owner_node, "_equip_drop", [self.get_parent()])

##
## Unequip equipset
##
func unequip_item(button, owner_button):
	var dropButton = owner_node.get_node("separate/items/item_desc/drop")
	var previous_item = _get_previous_item()
	var slot = get_owner().get_free_equip_slot()
	slot.get_node("slot_item/img_item").set_script(load("res://addons/godot-one-inventory/scripts/equip_item_slot.gd"))
	slot.get_node("slot_item/img_item").texture_normal = button.texture_normal
	slot.get_node("slot_item/img_item").connect("button_up", get_owner(), "_item_selected", [slot.get_node("slot_item"), previous_item])
	slot.get_node("slot_item/img_item/item").text = previous_item
	slot.get_node("slot_item/amount").text = str(1)
	slot.get_node("slot_item/amount").self_modulate = Color(1,1,1,0)
	button.texture_normal = null
	button.get_node("item").set_text("")
	# disconnecting signals...
	owner_node.disconnect_signals(button, "button_up", self, "on_head_button_up")
	owner_node.disconnect_signals(owner_button, "button_up", self, "unequip_item")
	owner_node.disconnect_signals(button, "button_up", owner_node, "_equip_item")
	owner_node.disconnect_signals(button, "button_up", owner_node, "_use_item")
	owner_node.disconnect_signals(dropButton, "button_up", dropButton, "_equip_drop")
	owner_node.disconnect_signals(dropButton, "button_up", dropButton, "_use_drop")
#	# necessary cleaning...
	owner_node.hide_item_desc()
	owner_node.slot_empty(button.get_parent())
	owner_node.unequip_item()
