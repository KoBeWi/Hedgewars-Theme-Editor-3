extends Control

const DONT_PACK = ["theme.bak", "desktop.ini", "thumbs.db"]

@onready var game_path_label: Label = %GamePathLabel
@onready var user_path_label: Label = %UserPathLabel
@onready var language_list: OptionButton = %LanguageList

@onready var save_container: Container = %SaveContainer
@onready var theme_version: SpinBox = %ThemeVersion
@onready var themes_list: Container = %ThemesList

var pack_mode: bool
var selected_theme: String

func _ready():
	HWTheme.theme_loaded.connect(on_theme_loaded)
	Utils.main = self
	
	%Version.text += ProjectSettings.get_setting("application/config/version")
	%SaveButton.pressed.connect(HWTheme.save_theme)
	theme_version.value_changed.connect(HWTheme.set_version)
	
	game_path_label.text = Utils.hedgewars_path
	user_path_label.text = Utils.hedgewars_user_path
	
	%GameDialog.current_dir = Utils.hedgewars_path
	%UserDialog.current_dir = Utils.hedgewars_user_path
	
	bind_setting(%EnableAutosave, "enable_autosave")
	bind_setting(%EnableMaximize, "maximize_on_start")
	bind_setting(%IncludeMusic, "include_music")
	
	Utils.refresh_themes()
	
	language_list.add_item("English")
	language_list.set_item_metadata(-1, "en")
	
	for language in Utils.list_directory("res://Translation", true):
		if language.get_extension() != "po":
			continue
		
		var translation: Translation = load("res://Translation".path_join(language))
		language_list.add_item(translation.get_message(&"TRANSLATED_LANGUAGE_NAME"))
		language_list.set_item_metadata(-1, language.get_basename())
	
	var selected_language = 0
	for i in language_list.item_count:
		if Utils.preferred_language.contains(language_list.get_item_metadata(i)):
			selected_language = i
	
	TranslationServer.set_locale(Utils.preferred_language)
	language_list.selected = selected_language

func theme_selected(button: Button):
	if not pack_mode:
		HWTheme.load_theme(button.get_theme_dir())
		selected_theme = button.theme_name_label.text
		select_theme_button()
		deselect_themes()

func select_theme_button():
	for button: Button in themes_list.get_children():
		if button.theme_name_label.text == selected_theme:
			button.theme_type_variation = &"ThemeButtonSelected"
		else:
			button.theme_type_variation = &""

func deselect_themes():
	for button in themes_list.get_children():
		button.button_pressed = false

func pack_start():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i != 0)
	$SelectPack.visible = true
	pack_mode = true

func pack_accept():# TODO: pack music (optional)
	var selected: Array[String]
	selected.assign(themes_list.get_children().filter(
		func(button: Button) -> bool: return button.button_pressed).map(
			func(button) -> String: return button.get_theme_dir()))
	
	var pack_name: String = $PackContainer/PackName.text
	if pack_name.is_empty():
		pack_name = "+".join(PackedStringArray(selected))
	
	DirAccess.make_dir_absolute(Utils.package_path)
	
	var hwp := ZIPPacker.new()
	hwp.open(Utils.package_path.path_join(pack_name) + ".hwp")
	
	for theme_name in selected:
		var theme_base := "Data/Themes".path_join(theme_name)
		for file in Utils.list_directory(Utils.get_theme_path(theme_name), true):
			if file in DONT_PACK:
				continue
			
			hwp.start_file(theme_base.path_join(file))
			hwp.write_file(FileAccess.get_file_as_bytes(Utils.get_theme_path(theme_name).path_join(file)))
			hwp.close_file()
	
	pack_cancel()#TODO: feedback if success

func pack_cancel():
	for i in $PackContainer.get_child_count():
		$PackContainer.get_child(i).visible = (i == 0)
	$SelectPack.visible = false
	pack_mode = false
	deselect_themes()

func on_theme_loaded():
	save_container.show()
	theme_version.value = HWTheme.theme_version

func set_game_path(path: String):
	Utils.hedgewars_path = path
	game_path_label.text = Utils.hedgewars_path
	Utils.save_settings()

func set_user_path(path: String):
	Utils.hedgewars_user_path = path
	user_path_label.text = Utils.hedgewars_user_path
	Utils.save_settings()

func change_language(item):
	Utils.preferred_language = language_list.get_item_metadata(item)
	TranslationServer.set_locale(Utils.preferred_language)
	Utils.save_settings()

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
