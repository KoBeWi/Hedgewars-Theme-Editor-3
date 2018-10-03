extends Control

func _ready():
	name = tr("Main")
	Util.size_listeners.append(self)
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$Save/Button.connect("pressed", HWTheme, "save_theme")
	$GamePath/Button.connect("pressed", $FileDialog/GameDialog, "popup_centered")
	$UserPath/Button.connect("pressed", $FileDialog/UserDialog, "popup_centered")
	$FileDialog/GameDialog.connect("confirmed", self, "update_game_path")
	$FileDialog/UserDialog.connect("confirmed", self, "update_user_path")
	
	$GamePath/Label.text = Util.hedgewars_path
	$UserPath/Label.text = Util.hedgewars_user_path
	
	$FileDialog/GameDialog.current_dir = Util.hedgewars_path
	$FileDialog/UserDialog.current_dir = Util.hedgewars_user_path
	
	$Save/EnableAutosave.pressed = Util.enable_autosave
	$Save/EnableAutosave.connect("toggled", self, "on_autosave_changed")
	
	for theme_dir in Util.list_directory(Util.hedgewars_user_path + "/Data/Themes", false):
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		button.get_node("Name").text = theme_dir
		button.get_node("Icon").texture = Util.load_texture(str(Util.hedgewars_user_path, "/Data/Themes/", theme_dir, "/", "icon@2x.png"))
		button.connect("pressed", HWTheme, "load_theme", [theme_dir])
		$ThemesList.add_child(button)

func on_theme_loaded():
	$SaveHeader.visible = true
	$Save.visible = true

func update_game_path():
	Util.hedgewars_path = $FileDialog/GameDialog.current_dir
	$GamePath/Label.text = Util.hedgewars_path

func update_user_path():
	Util.hedgewars_user_path = $FileDialog/UserDialog.current_dir
	$UserPath/Label.text = Util.hedgewars_user_path

func on_autosave_changed(enabled):
	Util.enable_autosave = enabled
	Util.save_settings()