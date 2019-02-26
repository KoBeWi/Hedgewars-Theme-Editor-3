extends Control

func _ready():
	get_parent().name = tr("Customization")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$ItemLists/LeftMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Sprays/List])
	$ItemLists/LeftMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Sprays/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Objects/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Objects/List])

func on_theme_loaded():
	$ItemLists/Sprays/List.clear()
	$ItemLists/Objects/List.clear()
	
	for s in HWTheme.sprays:
		$ItemLists/Sprays/List.add_item(s)
	
	for o in HWTheme.objects:
		$ItemLists/Objects/List.add_item(o)
	
	var customization
	
	customization = add_customization("Icon")
	customization.add_info("Themes without icons don't appear on in-game theme list")
	customization.add_image("icon.png")
	customization.add_image_info("Size: 33x32")
	customization.add_image("icon@2x.png")
	customization.add_image_info("Size: 65x64")
	
	customization = add_customization("Land texture")
	customization.add_info("Texture drawn as map's terrain")
	customization.add_info("This image is required")
	customization.add_image("LandTex.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Land back texture")
	customization.add_info("Visible when terrain is destroyed")
	customization.add_image("LandBackTex.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Border")
	customization.add_info("Painted arround terrain")
	customization.add_info("This image is required")
	customization.add_image("Border.png")
	customization.add_image_info("Size: 128x32")
	customization.add_image_info("Two halves, top and bottom 16 pix each")

func move_item(from, to):
	if from.get_item_count() == 0 or from.get_selected_items().size() == 0: return
	
	var item = from.get_selected_items()[0]
	to.add_item(from.get_item_text(item))
	from.remove_item(item)

func add_customization(cname):
	var custom = preload("res://Nodes/CustomizationPanel.tscn").instance()
	add_child(custom)
	custom.get_node("Container/GroupName").text = cname
	return custom