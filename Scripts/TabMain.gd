extends Control

const DONT_PACK = ["theme.bak", "desktop.ini", "thumbs.db"]

var language_list = []
var pack_mode = false

func _ready():
	get_parent().name = tr("Main")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	get_viewport().connect("size_changed", self, "update_columns")
	
	$Save/Button.connect("pressed", HWTheme, "save_theme")
	$GamePath/Button.connect("pressed", $FileDialog/GameDialog, "popup_centered")
	$UserPath/Button.connect("pressed", $FileDialog/UserDialog, "popup_centered")
	$FileDialog/GameDialog.connect("confirmed", self, "update_game_path")
	$FileDialog/UserDialog.connect("confirmed", self, "update_user_path")
	$LanguageContainer/LanguageList.connect("item_selected", self, "change_language")
	$PackContainer/PackThemes.connect("pressed", self, "pack_start")
	$PackContainer/CreatePack.connect("pressed", self, "pack_accept")
	$PackContainer/Cancel.connect("pressed", self, "pack_cancel")
	
	$GamePath/Label.text = Util.hedgewars_path
	$UserPath/Label.text = Util.hedgewars_user_path
	
	$FileDialog/GameDialog.current_dir = Util.hedgewars_path
	$FileDialog/UserDialog.current_dir = Util.hedgewars_user_path
	
	bind_setting($Save/EnableAutosave, "enable_autosave")
	bind_setting($MaximizeContainer/EnableMaximize, "maximize_on_start")
	bind_setting($PackContainer/IncludeMusic, "include_music")
	
	for theme_dir in Util.list_directory(Util.hedgewars_user_path + "/Data/Themes", false):#TODO: handle invalid user path
		var v = theme_dir.split("_v")
		
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		button.set_meta("theme", theme_dir)
		button.get_node("Name").text = v[0]
		if v.size() == 2:
			button.get_node("Version").text = str("v", int(v[1]))
		button.get_node("Icon").texture = Util.load_texture(str(Util.hedgewars_user_path, "/Data/Themes/", theme_dir, "/", "icon@2x.png"))
		button.connect("pressed", self, "theme_selected", [button])
		$ThemeAlign/ThemesList.add_child(button)
	
	language_list.append("en")
	for language in Util.list_directory("res://Translation", true):
		if language.get_extension() == "po": language_list.append(language.get_basename())
	
	var selected_language = 0
	for i in language_list.size():
		if language_list[i] == Util.preferred_language: selected_language = i
		TranslationServer.set_locale(language_list[i])
		$LanguageContainer/LanguageList.add_item(tr("English") + "​")
	
	TranslationServer.set_locale(Util.preferred_language)
	$LanguageContainer/LanguageList.selected = selected_language
	update_columns()

func theme_selected(button):
	if !pack_mode:
		HWTheme.load_theme(button.get_meta("theme"))
		deselect_themes()

func deselect_themes(): for button in $ThemeAlign/ThemesList.get_children(): button.pressed = false

func pack_start():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i != 0)
	$SelectPack.visible = true
	pack_mode = true

func pack_accept():#TODO: pack music (optional)
	var selected = []
	for button in $ThemeAlign/ThemesList.get_children():
		if button.pressed: selected.append(button.get_node("Name").text)
	
	var pack_name = $PackContainer/PackName.text
	if pack_name == "": pack_name = PoolStringArray(selected).join("+")
	
	var root = str(Util.package_path, "/", pack_name, "/")
	
	var output = Directory.new()
	output.make_dir_recursive(root + "Data/Themes")
	
	for theme_name in selected:
		var output_path = str(root, "Data/Themes/", theme_name)
		output.make_dir_recursive(output_path)
		for file in Util.list_directory(Util.get_theme_path(theme_name), true): if not file in DONT_PACK:
			output.copy(str(Util.get_theme_path(theme_name), "/", file), str(output_path, "/", file))
	
	pack_cancel()

func pack_cancel():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i == 0)
	$SelectPack.visible = false
	pack_mode = false
	deselect_themes()

func on_theme_loaded():
	$SaveHeader.visible = true
	$Save.visible = true

func update_game_path():
	Util.hedgewars_path = $FileDialog/GameDialog.current_dir
	$GamePath/Label.text = Util.hedgewars_path
	Util.save_settings()

func update_user_path():
	Util.hedgewars_user_path = $FileDialog/UserDialog.current_dir
	$UserPath/Label.text = Util.hedgewars_user_path
	Util.save_settings()

func update_columns():
	$ThemeAlign/ThemesList.columns = max(floor(get_viewport_rect().size.x / 128) - 1, 1)

func change_language(item):
	Util.preferred_language = language_list[item]
	Util.save_settings()
	Util.size_listeners.clear()
	get_tree().reload_current_scene()

func bind_setting(button, setting):
	button.pressed = Util.get(setting)
	button.connect("toggled", self, "on_setting_changed", [setting])

func on_setting_changed(enabled, setting):
	Util.set(setting, enabled)
	Util.save_settings()