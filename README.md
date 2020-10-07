# Godot One Inventory

>[pt_BR][pt_br]

An inventory for use on the Godot engine (tested in version 3.2.x)

What this plugin does:

- stores items of various types.
- allows you to customize the item selection color and button images.

What I want to add:

- fully functional personalized background screen.
- rearrange items with drag and drop.
- enable separate equipment, for example: weapon, helmet, armor, boots, gloves.
- more customization options.
- and other little things that I should add here in the future.

## A brief description

The plugin has some scripts vars:

![script vars][script_vars]

**Background:** It is intended to be a personalized background screen. (not completed)

**Button Normal:** Appearance of buttons in normal state.

**Button Pressed:** Appearance of buttons when pressed.

**Active Color:** The color of the item's selection box when it is selected.

**Money Texture:** The image that will represent the money to be shown in the inventory.

**Usable Are Visible:** Will "usable" items be visible in the inventory? Default: false.

**Item Types:** By default this plugin accepts 3 types of items.
- **Consumable:** Consumable items, such as: potions, elixirs, etc.
- **Equipments:** Equipment: armor.
- **Usable:** Progression items, items that may or may not be used depending on the progress of the adventure (game).

>Attention: the `item types` must be consistent with what is in `attrib.type`.

To use this plugin, it is expected that the item to be inserted has the following structure:

    "gundar": {
        "icon": "res://sprites/button_fight_released.png",
        "name": "Heavy Armor of Gundar",
        "info": "Armor that defends against various types of damage.",
        "value": 9,
        "amount": 1,
        "attrib": {
            "type": 1,
            "affect": "equipset",
            "effect": "defense",
            "value": 12
        }
    }

This structure represents the following:

- **gundar:** This is the item key, it must be unique for each item.
- **icon:** An image that will visually represent the item.
- **name:** The name of the item as it will be shown to the player when he consults the item description.
- **info:** Item information.
- **value:** A value for the item when sold in NPC's stores.
- **amount:** Quantity available for this item.
- **attrib:** Attributes and effects of the item.
- **attrib.type:** Type of item, for example, equipment, consumable, in common use, etc.
- **attrib.affect:** What is affected by this item, equipment, energy, strength, etc.
- **attrib.effect:** The expected effect when using the item, increase, decrease, etc.
- **attrib.value:** The value of the effect, how much will affect attrib.effect.

Of all these, only the following are mandatory:

- **gundar:** The item key, which must be unique for each item.
- **icon:** An image for the item is important.
- **amount:** The item must contain a quantity > 0.
- **attrib.type:** The item must have a type, if it is equipment use the panel with the *script vars* and specify the types: *equipments*, *consumable*, *usable*. So that they are consistent with the items that will be inserted in the inventory. For example, I can have a **enum** that has these values, with that, I will define in *script vars* the respective values for each one, the plugin will do the rest.

## Installation

1. Copy the *addons* folder to the project root.
2. Enable the plugin in (Project Settings > Plugins).
3. Congratulations! You can now use the plugin.

## Using the plugin

1. Get the plugin instance:  
`onready var inventory = load("res://addons/godot-one-inventory/inventory.tscn").instance()`
2. Connect the necessary signals:  
`inventory.connect("used_consume_item", self, "_on_consumed_item")`  
`inventory.connect("used_usable_item", self, "_on_used_usable")`  
`inventory.connect("equipped_item", self, "_on_equipped_item")`
3. Attach it to your viewport (or scene):  
`add_child(inventory)`
4. Use the * set_visible * method to show the inventory. Put that call on some button that will show the inventory:  
`inventory.set_visible(true)`

## Screenshots

![screen one][sc_one]

![screen two][sc_two]

I hope this plugin can help you. If it was helpful, consider buy me a coffee, thanks! [ByMeACoffee][bmc]

Available under MIT license. [License][license]

[script_vars]: ./screenshots/script_vars.png "Script Vars"
[sc_one]: ./screenshots/one_sc.png "Screenshot One"
[sc_two]: ./screenshots/two_sc.png "Screenshot Two"

[bmc]: https://buymeacoff.ee/gianscardua "By Me A Coffee"
[license]: LICENSE "License"
[pt_br]: README_pt_br.md "pt_BR"
