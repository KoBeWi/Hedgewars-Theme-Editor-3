extends Control

const DONT_PACK = ["theme.bak", "desktop.ini", "thumbs.db"]

var language_list: Array
var pack_mode: bool
var selected_theme: String

func _ready():
	get_parent().name = tr("Main")
	HWTheme.theme_loaded.connect(on_theme_loaded)
	Utils.main = self
	
	$Save/Button.pressed.connect(HWTheme.save_theme)
	$GamePath/Button.pressed.connect($Dialogs/GameDialog.popup_centered)
	$UserPath/Button.pressed.connect($Dialogs/UserDialog.popup_centered)
	$Dialogs/GameDialog.dir_selected.connect(set_game_path)
	$Dialogs/UserDialog.dir_selected.connect(set_user_path)
	$LanguageContainer/LanguageList.item_selected.connect(change_language)
	$PackContainer/PackThemes.pressed.connect(pack_start)
	$PackContainer/CreatePack.pressed.connect(pack_accept)
	$PackContainer/Cancel.pressed.connect(pack_cancel)
	$Save/Version.value_changed.connect(HWTheme.set_version)
	
	$GamePath/Label.text = Utils.hedgewars_path
	$UserPath/Label.text = Utils.hedgewars_user_path
	
	$Dialogs/GameDialog.current_dir = Utils.hedgewars_path
	$Dialogs/UserDialog.current_dir = Utils.hedgewars_user_path
	
	bind_setting($Save/EnableAutosave, "enable_autosave")
	bind_setting($MaximizeContainer/EnableMaximize, "maximize_on_start")
	bind_setting($PackContainer/IncludeMusic, "include_music")
	
	Utils.refresh_themes()
	
	language_list.append("en")
	for language in Utils.list_directory("res://Translation", true):
		if language.get_extension() == "po":
			language_list.append(language.get_basename())
	
	var selected_language = 0
	for i in language_list.size():
		if language_list[i] == Utils.preferred_language: selected_language = i
		TranslationServer.set_locale(language_list[i])
		$LanguageContainer/LanguageList.add_item(tr("English") + "​")
	
	TranslationServer.set_locale(Utils.preferred_language)
	$LanguageContainer/LanguageList.selected = selected_language

func theme_selected(button: Button):
	if not pack_mode:
		HWTheme.load_theme(button.get_meta("theme"), int(button.theme_version.text))
		selected_theme = button.theme_name.text
		select_theme_button()
		deselect_themes()

func select_theme_button():
	var style := preload("res://Resources/ThemeButtonSelected.stylebox")
	for button: Button in $ThemeAlign/ThemesList.get_children():
		if button.theme_name.text == selected_theme:
			button.add_theme_stylebox_override(&"normal", style)
			button.add_theme_stylebox_override(&"pressed", style)
			button.add_theme_stylebox_override(&"focus", style)
			button.add_theme_stylebox_override(&"hover", style)
		else:
			button.remove_theme_stylebox_override(&"normal")
			button.remove_theme_stylebox_override(&"pressed")
			button.remove_theme_stylebox_override(&"focus")
			button.remove_theme_stylebox_override(&"hover")

func deselect_themes():
	for button in $ThemeAlign/ThemesList.get_children():
		button.button_pressed = false

func pack_start():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i != 0)
	$SelectPack.visible = true
	pack_mode = true

func pack_accept():# TODO: pack music (optional)
	var selected = []
	for button in $ThemeAlign/ThemesList.get_children():
		if button.pressed:
			selected.append(button.get_meta("theme"))
	
	var pack_name = $PackContainer/PackName.text
	if pack_name == "": pack_name = "+".join(PackedStringArray(selected))
	
	var root := Utils.package_path.path_join(pack_name)
	
	DirAccess.make_dir_recursive_absolute(root.path_join("Data/Themes"))
	
	for theme_name in selected:
		var output_path := root.path_join("Data/Themes").path_join(theme_name)
		DirAccess.make_dir_recursive_absolute(output_path)
		for file in Utils.list_directory(Utils.get_theme_path(theme_name), true): if not file in DONT_PACK:
			DirAccess.copy_absolute(Utils.get_theme_path(theme_name).path_join(file), output_path.path_join(file))
	
	pack_cancel()#TODO: feedback if success

func pack_cancel():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i == 0)
	$SelectPack.visible = false
	pack_mode = false
	deselect_themes()

func on_theme_loaded():
	$SaveHeader.visible = true
	$Save.visible = true
	$Save/Version.value = HWTheme.theme_version

func set_game_path(path: String):
	Utils.hedgewars_path = path
	$GamePath/Label.text = Utils.hedgewars_path
	Utils.save_settings()

func set_user_path(path: String):
	Utils.hedgewars_user_path = path
	$UserPath/Label.text = Utils.hedgewars_user_path
	Utils.save_settings()

func change_language(item): # TODO: some warning? it probably discards changes
	Utils.preferred_language = language_list[item]
	Utils.save_settings()
	get_tree().reload_current_scene()

func bind_setting(button, setting):
	button.button_pressed = Utils.get(setting)
	button.toggled.connect(on_setting_changed.bind(setting))

func on_setting_changed(enabled, setting):
	Utils.set(setting, enabled)
	Utils.save_settings()

func open_theme_directory():
	OS.shell_open(HWTheme.get_theme_path())

func new_theme():
	var name_edit := $Dialogs/NewThemeDialog/LineEdit as LineEdit
	var theme_path := Utils.get_themes_directory().path_join(name_edit.text)
	
	var err := DirAccess.make_dir_absolute(theme_path)
	if err == OK:
		name_edit.clear()
		
		var file := FileAccess.open(theme_path + "/theme.cfg", FileAccess.WRITE)
		file.close()
		
		Utils.refresh_themes()
	else:
		var error := str(err)
		match err:
			ERR_CANT_CREATE:
				error = "can't create directory. Check the name and try again"
			ERR_ALREADY_EXISTS:
				error = "directory already exists"
		
		if err == ERR_ALREADY_EXISTS and name_edit.text == "":
			error = "name can't be empty"
		
		$Dialogs/ErrorDialog.dialog_text = str("\nError creating theme: ", error, ".")
		$Dialogs/ErrorDialog.popup_centered()

func on_new_theme_pressed():
	$Dialogs/NewThemeDialog.popup_centered()
