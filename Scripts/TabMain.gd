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
		button.connect("pressed", self, "theme_selected", [theme_dir])
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

func theme_selected(theme):
	if pack_mode:
		pass
	else:
		HWTheme.load_theme(theme)
		deselect_themes()

func deselect_themes(): for button in $ThemeAlign/ThemesList.get_children(): button.pressed = false

func pack_start():
	$PackContainer/PackThemes.visible = false
	$PackContainer/CreatePack.visible = true
	$PackContainer/PackName.visible = true
	$PackContainer/PackName.text = ""
	$SelectPack.visible = true
	pack_mode = true

func pack_accept():
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
	
	$PackContainer/PackThemes.visible = true
	$PackContainer/CreatePack.visible = false
	$PackContainer/PackName.visible = false
	$SelectPack.visible = false
	pack_mode = false
	deselect_themes()

func on_theme_loaded():
	$SaveHeader.visible = true
	$Save.visible = true

func update_game_path():
	Util.hedgewars_path = $FileDialog/GameDialog.current_dir
	$GamePath/Label.text = Util.hedgewars_path

func update_user_path():
	Util.hedgewars_user_path = $FileDialog/UserDialog.current_dir
	$UserPath/Label.text = Util.hedgewars_user_path

func update_columns():
	$ThemeAlign/ThemesList.columns = max(floor(get_viewport_rect().size.x / 128) - 1, 1)

func change_language(item):
	Util.preferred_language = language_list[item]
	Util.save_settings()
	Util.size_listeners.clear()
	get_tree().reload_current_scene()

func on_autosave_changed(enabled):
	Util.enable_autosave = enabled
	Util.save_settings()