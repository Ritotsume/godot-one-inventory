extends CanvasLayer

## Define vars (getting nodes)
onready var title = $background/box/title_box/title
onready var drop = $background/box/drop
onready var cancel = $background/box/cancel
onready var cancel_text = $background/box/cancel/text
onready var drop_text = $background/box/drop/text
onready var amount_box = $background/box/amount_box
onready var amount_slider = $background/box/amount_slider
onready var slot_item = $background/box/slot
onready var item_name = $background/box/item_name
onready var box = $background

## Get owner node
onready var owner_node = get_owner()

## Define auxiliary vars
var item = null
var panel_ref = null

func _ready():
	title.set_text(tr("DROP"))
	drop_text.set_text(tr("DROP"))
	cancel_text.set_text(tr("CANCEL"))
	drop.texture_normal = owner_node.button_normal
	cancel.texture_normal = owner_node.button_normal
	box.visible = false

##
## Slider was changed, will change the 'amount_box' too
##
func _on_amount_slider_value_changed(value):
	amount_box.text = String(value)

##
## Amount box was changed, will change the 'amount_slider' too
##
func _on_amount_box_text_changed(new_text):
	new_text = int(new_text)
	if new_text <= 0:
		new_text = 1
	amount_slider.set("value", new_text)
	amount_box.set_text(String(new_text))
	amount_box.caret_position = String(new_text).length()

##
## If the cancel button was clicked, disconnect signals and close the box
##
func _on_cancel_button_up():
	owner_node.disconnect_signals(drop, "button_up", self, "on_item_droped")
	box.visible = false

##
## Define which item will be dropped
##
func set_item(panel: Panel):
	panel_ref = panel
	var key = panel.get_node("img_item/item").text
	item = owner_node.get_item(key)
	item_name.set_text(item.name)
	slot_item.get_node("slot_item/img_item").texture_normal = load(item.icon)
	amount_slider.set("max_value", item.amount)
	amount_slider.set("value", item.amount)
	drop.connect("button_up", self, "on_item_droped", [key])

##
## The item is dropped
##
func on_item_droped(itemKey):
	var qt_item = owner_node.dec_item(itemKey, int(amount_box.text))
	if qt_item <= 0:
		owner_node.clean_slot(panel_ref)
	else:
		panel_ref.get_node("amount").set_text(String(qt_item))
		panel_ref.update()
	owner_node.disconnect_signals(drop, "button_up", self, "on_item_droped")
	owner_node.fill_consume_with_empty_slot_skin()
	owner_node.fill_equip_with_empty_slot_skin()
	box.visible = false

##
## Change visibility of the drop panel
##
func set_visible(visibility):
	box.visible = visibility
