extends Control

func _ready():
	get_parent().name = tr("Customization")
	Util.size_listeners.append(self)
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$ItemLists/Sprays.rect_min_size.x = rect_size.x / 3
	$ItemLists/Other.rect_min_size.x = rect_size.x / 3
	$ItemLists/Objects.rect_min_size.x = rect_size.x / 3

func on_theme_loaded():
	for o in HWTheme.objects:
		$ItemLists/Objects.add_item(o)