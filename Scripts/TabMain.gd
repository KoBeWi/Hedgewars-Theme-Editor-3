extends VBoxContainer

var themes_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Hedgewars/Data/Themes"

func _ready():
	var dir = Directory.new()
	dir.open(themes_path)
	dir.list_dir_begin(true)
	
	var theme_dir = dir.get_next()
	while theme_dir != "":
		if !dir.dir_exists(themes_path + "/" + theme_dir):
			theme_dir = dir.get_next()
			continue
		
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		button.get_node("Name").text = theme_dir
		button.get_node("Icon").texture = Util.load_texture(themes_path + "/" + theme_dir + "/" + "icon@2x.png")
		$ThemesList.add_child(button)
		
		theme_dir = dir.get_next()