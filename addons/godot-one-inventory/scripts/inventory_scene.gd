extends Control

## Where save the inventory
const INVENTARIO =  "user://inventario.save"

## Define the callback signals. IMPORTANT!!
signal used_consume_item(item)
signal used_usable_item(item)
signal equipped_item(equip)

## Get instance of slot (slot of items)
var empty_slot = preload("res://addons/godot-one-inventory/item_slot.tscn").instance()

## Defining vars, getting nodes...
onready var title = $title/lb_title
onready var tabs = $separate/items/panel_items
onready var background_texture = $background
onready var consumables = $separate/items/panel_items/consumable/consumable
onready var equipments = $separate/items/panel_items/equipments/equipments
onready var use = $separate/items/item_desc/use
onready var drop = $separate/items/item_desc/drop
onready var head = $separate/equipments_side/head/head
onready var body = $separate/equipments_side/body/body
onready var hands = $separate/equipments_side/hands/hands
onready var legs = $separate/equipments_side/legs/legs
onready var weapon = $separate/equipments_side/weapon/weapon
onready var dropbox = $dropbox
onready var money_panel = $separate/equipments_side/money
onready var money_image = $separate/equipments_side/money/image
onready var money_text = $separate/equipments_side/money/text
onready var money_amount = $separate/equipments_side/money/amount
onready var equip_title = $separate/equipments_side/equip_title

## Vars available in the inspector (editor)
export(Texture) var background
export(Texture) var button_normal = load("res://addons/godot-one-inventory/sprites/buttonNormal.png")
export(Texture) var button_pressed = load("res://addons/godot-one-inventory/sprites/buttonPressed.png")
#export(Texture) var equipset
export(Color) var active_color = Color("#00994a")
export(Texture) var money_texture = load("res://addons/godot-one-inventory/sprites/moeda.png")
export(bool) var usable_are_visible = false
export(Dictionary) var item_types = {
	"consumable": 0,
	"equipments": 1,
	"usable": 2
}

## Control how many slots per tab (consumable and equips)
var consu_spaces = 18
var equip_spaces = 18

## Necessary for the walk through the slots
var previous = Panel.new()

## Initialize the items dictionary
var items = {
	"items": {},
	"refs": {},
	"equips": {},
	"money": 0
}

func _init():
	load_inventory()

func _ready():
	var parent_position = get_parent().position
	set_position(Vector2(-parent_position.x, -parent_position.y))
	title.text = tr("TITLE")
	tabs.set_tab_title(0, tr("TAB1"))
	tabs.set_tab_title(1, tr("TAB2"))
	money_text.set_text(tr("COINS"))
	equip_title.set_text(tr("TAB2"))
	background_texture.set_texture(background)
#	equip_set.texture_normal = equipset
	use.texture_normal = button_normal
	use.texture_pressed = button_pressed
	drop.texture_normal = button_normal
	drop.texture_pressed = button_pressed
	money_image.texture_normal = money_texture
	money_amount.set_text(str(get_money()))
	
	# load equipped item, and then, get some bonuses
	load_equip()
	
	# hide the desc item panel and fill tabs consumable and equips
	hide_item_desc()
	_fill_consumables()
	_fill_equipments()
	
	# fill the slots with the items that the player has
	_load_consume_items()
	_load_equip_items()
	set_visible(false)

##
## Fill consumable tab with empty slots
##
func _fill_consumables():
	for x in range(consu_spaces):
		var new_slot = empty_slot.duplicate()
		var panel_slot = new_slot.get_node("slot_item")
		consumables.add_child(new_slot)

##
## Fill the slots in consumable tab with the items that the player has
##
func _load_consume_items():
	for item in items.items:
		if items.items[item].attrib.type != item_types["equipments"]:
			var get_slot = _get_free_consume_slot()
			_fill_slot(get_slot, item)

##
## Fill equipments tab with empty slots
##
func _fill_equipments():
	for x in range(equip_spaces):
		var new_slot = empty_slot.duplicate()
		var panel_slot = new_slot.get_node("slot_item")
		equipments.add_child(new_slot)

##
## Fill the slots in equipaments tab with the items that the player has
##
func _load_equip_items():
	for item in items.items:
		if items.items[item].attrib.type == item_types["equipments"]:
			var get_slot = get_free_equip_slot()
			# if the equipped item is equal another one, skip then
			if items.equips.has(item):
				continue
			else:
				_fill_slot(get_slot, item)

##
## Fill the slot with the item info.
##
func _fill_slot(slot: Control, itemKey: String):
	if slot != null:
		var panel = slot.get_node("slot_item")
		var button = slot.get_node("slot_item/img_item")
		var amount = slot.get_node("slot_item/amount")
		var item = get_item(itemKey)
		button.texture_normal = load(item.icon)
		button.get_node("item").set_text(str(itemKey))
		amount.set_text(str(item.amount))
		if item.attrib.type == item_types["equipments"]:
			amount.visible = false
			slot \
			.get_node("slot_item/img_item") \
			.set_script(load("res://addons/godot-one-inventory/scripts/equip_item_slot.gd"))
		button.connect("button_up", self, "_item_selected", [panel, itemKey])
	else:
		print("inventory is full")

##
## Get a empty slot in consumable tab
##
func _get_free_consume_slot():
	for x in get_node("separate/items/panel_items/consumable/consumable").get_children():
		if x.get_node("slot_item/img_item").texture_normal == null:
			return x
	return null

##
## Get a empty slot in equipments tab
##
func get_free_equip_slot():
	for x in get_node("separate/items/panel_items/equipments/equipments").get_children():
		if x.get_node("slot_item/img_item").texture_normal == null:
			return x
	return null

##
## Style the slot selected, and show the item description
##
func _item_selected(panel: Panel, itemStr: String):
	var stylesGreen = StyleBoxFlat.new()
	var stylesGray = StyleBoxFlat.new()
	var item = get_item(itemStr)
	
	# disconnecting previous signals...
	disconnect_signals(use, "button_up", self, "_use_item")
	disconnect_signals(use, "button_up", self, "_equip_item")
	disconnect_signals(drop, "button_up", self, "_use_drop")
	disconnect_signals(drop, "button_up", self, "_equip_drop")
	disconnect_signals(use, "button_up", head, "unequip_item")
	disconnect_signals(use, "button_up", body, "unequip_item")
	disconnect_signals(use, "button_up", hands, "unequip_item")
	disconnect_signals(use, "button_up", legs, "unequip_item")
	disconnect_signals(use, "button_up", weapon, "unequip_item")
	
	# show the item description
	show_item_desc(itemStr)
	
	slot_empty(head.get_parent())
	slot_empty(body.get_parent())
	slot_empty(hands.get_parent())
	slot_empty(legs.get_parent())
	slot_empty(weapon.get_parent())
	
	panel.add_stylebox_override("panel", stylesGreen)
	previous.add_stylebox_override("panel", stylesGray)
	
	if previous != panel:
		slot_empty(previous)
		slot_filled(panel)
		previous = panel
	else:
		slot_filled(previous)
		slot_filled(panel)
	
	# connecting signals...
	if item.attrib.type != item_types["equipments"]:
		use.connect("button_up", self, "_use_item", [panel])
		drop.connect("button_up", self, "_use_drop", [panel])
	elif item.attrib.type == item_types["equipments"]:
		use.connect("button_up", self, "_equip_item", [panel])
		drop.connect("button_up", self, "_equip_drop", [panel])

##
## An item is used, emit signal for used item.
##
func _use_item(panel: Panel):
	var item = get_item(panel.get_node("img_item/item").text)
	var amount = dec_item(panel.get_node("img_item/item").text)
	if amount > 0:
		panel.get_node("amount").set_text(String(amount))
		panel.update()
	else:
		clean_slot(panel)
		fill_consume_with_empty_slot_skin()
	# emitting the correct signal...
	if item.attrib.type == item_types['consumable']:
		emit_signal("used_consume_item", item)
	else:
		emit_signal("used_usable_item", item)

##
## An item is equipped, emit signal for the equipped item
##
func _equip_item(panel: Panel):
#	var slot = get_node("separate/equipments_side/equipset")
	var itemKey = panel.get_node("img_item/item").text
	var item = get_item(itemKey)
	var slot = _get_slot(item.attrib.affect)
	
	# if the affect attribute is equals "equipset", equip then
	if item.attrib.affect == slot.get_name():
		# if an item is already equipped, unequip then
		if slot.get_child(0).texture_normal != null:
			slot.get_child(0).unequip_item(slot.get_child(0), use)
		
		slot.get_child(0).texture_normal = panel.get_node("img_item").texture_normal
		slot.get_child(0).get_node("item").set_text(itemKey)
		slot.get_child(0).connect("button_up", slot.get_child(0), "on_head_button_up", [itemKey])
		# save the equipped item...
		set_equip(itemKey, item)
		# necessary cleaning...
		panel.get_node("img_item").texture_normal = null
		panel.get_node("img_item/item").text = ""
		panel.get_node("amount").text = ""
		disconnect_signals(panel.get_node("img_item"), "button_up", self, "_item_selected")
		panel.get_node("img_item").set_script(null)
		# disconnecting signals...
		disconnect_signals(use, "button_up", self, "_use_item")
		disconnect_signals(drop, "button_up", self, "_use_drop")
		disconnect_signals(use, "button_up", self, "_equip_item")
		disconnect_signals(drop, "button_up", self, "_equip_drop")
		# hide desc, clean slot and emit signal
		hide_item_desc()
		slot_empty(panel)
		emit_signal("equipped_item", item)

##
## The drop button was clicked, show drop box (consumable tab)
##
func _use_drop(panel: Panel):
	dropbox.set_item(panel)
	dropbox.set_visible(true)

##
## The drop button was clicked, show drop box (equipments tab)
##
func _equip_drop(panel: Panel):
	dropbox.set_item(panel)
	dropbox.set_visible(true)

##
## Tab was changed, clear selections in previous tab
##
func _on_panel_items_tab_changed(tab):
	if tab == 0:
		fill_equip_with_empty_slot_skin()
	elif tab == 1:
		fill_consume_with_empty_slot_skin()
	# disconnecting previous signals...
	disconnect_signals(use, "button_up", self, "_use_item")
	disconnect_signals(drop, "button_up", self, "_use_drop")
	disconnect_signals(use, "button_up", self, "_equip_item")
	disconnect_signals(drop, "button_up", self, "_equip_drop")
	slot_empty(head.get_parent())
	slot_empty(body.get_parent())
	slot_empty(hands.get_parent())
	slot_empty(legs.get_parent())
	slot_empty(weapon.get_parent())

##
## The button close was clicked, close inventory
##
func _on_bt_close_button_up():
	set_visible(false)

##
## Update slots with a new insertion of item.
##
func _update_consume_slot_with_new_item(itemKey: String):
	var panel = null
	for itemSlot in consumables.get_children():
		# if item is already visible in a slot, update the slot with new amount
		if itemSlot.get_node("slot_item/img_item/item").text == itemKey:
			panel = itemSlot.get_node("slot_item")
			var item = get_item(itemKey)
			panel.get_node("amount").set_text(String(item.amount))
			panel.update()
			return 1
	var slot = _get_free_consume_slot()
	_fill_slot(slot, itemKey)
	return 0

##
## Update equip slots with a new equipment insertion
##
func _update_equip_slot_with_new_item(itemKey: String):
	var slot = get_free_equip_slot()
	_fill_slot(slot, itemKey)

##
## Function that get slot for equip an item
##
func _get_slot(affect: String):
	var slot
	match affect:
		"head":
			slot = get_node("separate/equipments_side/head")
		"body":
			slot = get_node("separate/equipments_side/body")
		"legs":
			slot = get_node("separate/equipments_side/legs")
		"hands":
			slot = get_node("separate/equipments_side/hands")
		"weapon":
			slot = get_node("separate/equipments_side/weapon")
		_:
			return false
	return slot

##
## Save inventory
##
func save_inventory():
	var file = File.new()
	file.open_encrypted_with_pass(INVENTARIO, File.WRITE, OS.get_unique_id()) ## tentar trocar o unique id...
	file.store_var(items)
	file.close()

##
## Load inventory
##
func load_inventory():
	var file = File.new()
	if not file.file_exists(INVENTARIO):
		return
	file.open_encrypted_with_pass(INVENTARIO, File.READ, OS.get_unique_id())
	items = file.get_var()
	file.close()

##
## Get all items
##
func get_items():
	return items.items

##
## Add an item to items dictionary
##
func add_item(key: String, item: Dictionary):
	if item.attrib.type == item_types["equipments"]:
		var new_key = key
		if items.items.has(key):
			new_key = key + String(OS.get_system_time_msecs())
		items.items[new_key] = {
			"name": item.name,
			"icon": item.icon,
			"info": item.info,
			"amount": 1,
			"attrib": item.attrib
		}
		_update_equip_slot_with_new_item(key)
	else:
		if items.items.has(key):
			items.items[key].amount += 1
		else:
			items.items[key] = {
				"name": item.name,
				"icon": item.icon,
				"info": item.info,
				"amount": 1,
				"attrib": item.attrib
			}
		_update_consume_slot_with_new_item(key)
	save_inventory() ### para testes, depois deverá ser mudado...

##
## Add an ref item to items ref dictionary
## the param "item" is the key of the item
## # This item don't appears in the inventory
##
func add_ref_item(item: String):
	if items.refs.has(item):
		items.refs[item] += 1
	else:
		items.refs[item] = 1
	save_inventory() ### para testes, depois deverá ser mudado...

##
## Decrement an item
## If the amount param is provided the item is decremented in that amount,
## otherwise, it will decremented by one
##
func dec_item(key: String, amount = null):
	if items.items.has(key):
		if items.items[key].amount > 0:
			if amount != null:
				items.items[key].amount -= amount
			else:
				items.items[key].amount -= 1
			if items.items[key].amount <= 0:
				items.items.erase(key)
				save_inventory() ### para testes, depois deverá ser mudado...
				return 0
			save_inventory() ### para testes, depois deverá ser mudado...
			return items.items[key].amount
	else:
		return 0

##
## This method is common used to use items outside of inventory, in example, a key 
## to open a door.
##
func use_item_outside_inventory(itemKey: String):
	var item = get_item(itemKey)
	var amount = dec_item(itemKey)
	for slot in consumables.get_children():
		var panel = slot.get_node("slot_item")
		if panel.get_node("img_item/item").text == itemKey:
			if amount > 0:
				panel.get_node("amount").set_text(String(amount))
				panel.update()
			else:
				clean_slot(panel)
				fill_consume_with_empty_slot_skin()
	# emitting the correct signal...
	if item.attrib.type == item_types['consumable']:
		emit_signal("used_consume_item", item)
	else:
		emit_signal("used_usable_item", item)

##
## Use or decrement an item (ref)
##
func use_ref_item(key: String):
	if items.refs.has(key):
		if items.refs[key] > 0:
			items.refs[key] -= 1
			if items.refs[key] == 0:
				items.refs.erase(key)
		save_inventory() ### para testes, depois deverá ser mudado...

##
## Get an item for a given key and return then, otherwise, return a empty dict
##
func get_item(key: String) -> Dictionary:
	if items.items.has(key):
		return items.items[key]
	else:
		return {}

##
## Add money to the amount of money of the player
##
func save_money(amount: int):
	if items.has("money"):
		items.money += amount
	else:
		items["money"] = amount
	money_amount.set_text(String(get_money()))
	money_panel.update()
	save_inventory() ### para testes, depois deverá ser mudado...

##
## Get the amount of money of the player
##
func get_money() -> int:
	if items.has("money"):
		return items.money
	else:
		return 0

##
## Delete ALL items in the inventory, and all refs items and money.
## CAUTION ON USE THIS!
##
func delete_all_items():
	items.clear()
	items["items"] = {}
	items["refs"] = {}
	items["equips"] = {}
	items["money"] = 0

##
## Make payments
##
func pay(amount: int) -> int:
	if items.has("money") and items.money < amount:
		return 0
	else:
		items.money -= amount
		money_amount.set_text(String(get_money()))
		money_panel.update()
		save_inventory() ### para testes, depois deverá ser mudado...
		return 1

##
## Set equipment
##
func set_equip(key: String, equip: Dictionary):
	items.equips[key] = equip
	save_inventory() ### para testes, depois deverá ser mudado...

##
## Get the equipped item
##
func get_equipped_items() -> Dictionary:
	return items.equips

##
## Fill the equipset slot with the equipped item, emit signal to use their bonuses
##
func load_equip():
	var slot # = get_node("separate/equipments_side/equipset")
	var items_equip = get_equipped_items()
#	print("ITENS::: ", items_equip)
	if items_equip.size() > 0:
		for key in items_equip:
#			print("ITEM>> ", key)
			slot = _get_slot(items_equip[key].attrib.affect)
#			var key = item.keys()[0]
			slot.get_child(0).texture_normal = load(items_equip[key].icon)
			slot.get_child(0).get_node("item").set_text(key)
			slot.get_child(0).connect("button_up", slot.get_child(0), "on_head_button_up", [key])
			emit_signal("equipped_item", items_equip[key])

##
## Unequip the item in equipset
##
func unequip_item(item: String):
#	print("UNEQUIP>>> ", item)
	items.equips.erase(item)
#	print("EQUIPEDS>>> ", items.equips)
#	items.equips.clear()
	save_inventory() ### para testes, depois deverá ser mudado...

##
## Styles the panel with a grey color and some aspect, i.e. border radius.
##
func slot_empty(panel: Panel):
	var stylesGray = StyleBoxFlat.new()
	panel.add_stylebox_override("panel", stylesGray)
	stylesGray.set_border_width_all(12)
	stylesGray.set_corner_radius_all(12)
	stylesGray.set_border_color(Color("#202020"))
	stylesGray.set_border_blend(true)
	stylesGray.set_bg_color(Color("#151515"))
	panel.update()

##
## Styles the panel with a active color and some aspect, i.e. border radius.
## this slot is selected...
##
func slot_filled(panel):
	var stylesGreen = StyleBoxFlat.new()
	panel.add_stylebox_override("panel", stylesGreen)
	stylesGreen.set_border_width_all(12)
	stylesGreen.set_corner_radius_all(12)
	stylesGreen.set_border_color(Color(active_color))
	stylesGreen.set_border_blend(true)
	stylesGreen.set_bg_color(Color("#151515"))
	panel.update()

##
## Clear the slot, removes the image, texts, signals and their scripts
##
func clean_slot(panel):
	panel.get_node("img_item").texture_normal = null
	panel.get_node("img_item/item").text = ""
	panel.get_node("amount").text = ""
	disconnect_signals(panel.get_node("img_item"), "button_up", self, "_item_selected")
	panel.get_node("img_item").set_script(null)
	panel.update()

##
## Hide the item description, button, texts, etc..
##
func hide_item_desc():
	var desc_elements = $separate/items/item_desc.get_children()
	for el in desc_elements:
		el.visible = false

##
## Show the item description
##
func show_item_desc(itemStr):
	var item = get_item(itemStr)
	if item.attrib.type != item_types["equipments"]:
		$separate/items/item_desc/use/Label.text = tr("BT_USE")
	elif item.attrib.type == item_types["equipments"]:
		$separate/items/item_desc/use/Label.text = tr("BT_EQUIP")
	$separate/items/item_desc/name.set_text(str(item.name))
	$separate/items/item_desc/desc.set_text(str(item.info))
	var desc_elements = $separate/items/item_desc.get_children()
	for el in desc_elements:
		el.visible = true
	# if attrib type is equals to "usable" hide "use" button
	# -- maybe must change the "usable" for something more dynamic...
	if item.attrib.type == item_types["usable"]:
		use.set_visible(usable_are_visible)

##
## Fill slots with a unselected skin (equipments tab)
##
func fill_equip_with_empty_slot_skin():
	for item in equipments.get_children():
		slot_empty(item.get_node("slot_item"))
		hide_item_desc()

##
## Fill slots with a unselected skin (consumable tab)
##
func fill_consume_with_empty_slot_skin():
	for item in consumables.get_children():
		slot_empty(item.get_node("slot_item"))
		hide_item_desc()

##
## Disconnect signals.
## nod: Node that retain a signal
## sig: Signal that will disconnected
## tar: Target where a function is connected to the signal
## met: Method that references a signal
##
func disconnect_signals(nod, sig, tar, met) -> bool:
	if nod.is_connected(sig, tar, met):
		nod.disconnect(sig, tar, met)
#		print("### START ###")
#		print("Disconnect node: ", nod.get_name(), "\nFrom: ", tar.get_name(), "\nMethod: ", met)
#		print("### END ###")
		return true
	else:
		return false

##
## Set visibility of the inventory
##
func set_visible(visibility: bool):
	fill_consume_with_empty_slot_skin()
	fill_equip_with_empty_slot_skin()
	tabs.current_tab = 0
	self.visible = visibility
