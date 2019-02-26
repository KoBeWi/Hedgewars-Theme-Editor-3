extends Control

func _ready():
	get_parent().name = tr("Customization")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$ItemLists/LeftMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Sprays/List])
	$ItemLists/LeftMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Sprays/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Objects/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Objects/List])
	
#	add_customization("Icon")
#	add_customization("Land texture")

func on_theme_loaded():
	$ItemLists/Sprays/List.clear()
	$ItemLists/Objects/List.clear()
	
	for s in HWTheme.sprays:
		$ItemLists/Sprays/List.add_item(s)
	
	for o in HWTheme.objects:
		$ItemLists/Objects/List.add_item(o)

func move_item(from, to):
	if from.get_item_count() == 0 or from.get_selected_items().size() == 0: return
	
	var item = from.get_selected_items()[0]
	to.add_item(from.get_item_text(item))
	from.remove_item(item)

func add_customization(cname):
	var custom = preload("res://Nodes/CustomizationPanel.tscn").instance()
	add_child(custom)