extends VBoxContainer

func _ready():
	name = tr("Main")
	
	for theme_dir in Util.list_directory(Util.themes_path, false):
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		button.get_node("Name").text = theme_dir
		button.get_node("Icon").texture = Util.load_texture(str(Util.themes_path, "/", theme_dir, "/", "icon@2x.png"))
		button.connect("pressed", HWTheme, "load_theme", [theme_dir])
		$ThemesList.add_child(button)