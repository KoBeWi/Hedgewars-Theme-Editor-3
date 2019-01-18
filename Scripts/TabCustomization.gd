extends Control

func _ready():
	get_parent().name = tr("Customization")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")

func on_theme_loaded():
	$ItemLists/Sprays.clear()
	$ItemLists/Objects.clear()
	
	for s in HWTheme.sprays:
		$ItemLists/Sprays.add_item(s)
	
	for o in HWTheme.objects:
		$ItemLists/Objects.add_item(o)