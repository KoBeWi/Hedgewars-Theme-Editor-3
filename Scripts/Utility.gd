extends Node

var dir_watcher: DirectoryWatcher
var texture_cache: Dictionary

var preferred_language: String
var hedgewars_path: String
var hedgewars_user_path: String
var package_path: String

var enable_autosave = true
var maximize_on_start = true
var include_music = true

var temp_editor
var main

signal object_modified(operation, object)

func _ready():
	var config := FileAccess.open("user://config", FileAccess.READ)
	if config:
		var lines = config.get_as_text().split("\n")
		preferred_language = lines[0]
		enable_autosave = lines[1] == "true"
		maximize_on_start = lines[2] == "true"
		include_music = lines[3] == "true"
		hedgewars_path = lines[4]
		hedgewars_user_path = lines[5]
		config.close()
	else:
		preferred_language = OS.get_locale()
	
	if hedgewars_path.is_empty():
		var path: String
		
		match OS.get_name():
			"Windows":
				for dir in Utils.list_directory("C:/Program Files (x86)", false):
					if dir.begins_with("Hedgewars"):
						path = "C:/Program Files (x86)".path_join(dir)
						break
				
				if path.is_empty():
					for dir in Utils.list_directory("C:/Program Files", false):
						if dir.begins_with("Hedgewars"):
							path = "C:/Program Files".path_join(dir)
							break
			
			"Linux":
				if DirAccess.dir_exists_absolute("/usr/share/hedgewars"):
					path = "/usr/share/hedgewars"
				else:
					path = "/usr/share/games/hedgewars"
			
			"macOS": # TODO: really?
				if DirAccess.dir_exists_absolute("/usr/share/hedgewars"):
					path = "/usr/share/hedgewars"
				else:
					path = "/usr/share/games/hedgewars"
		
		hedgewars_path = path
	
	if hedgewars_user_path.is_empty():
		var path: String
		
		match OS.get_name():
			"Windows":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("Hedgewars")
			
			"X11":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir().path_join("home")
			
			"OSX": #TODO: really?
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir().path_join("home")
		
		hedgewars_user_path = path
	
	if package_path.is_empty():
		package_path = ProjectSettings.globalize_path("res://").path_join("PackedThemes")
	
	dir_watcher = DirectoryWatcher.new()
	add_child(dir_watcher)
	dir_watcher.add_scan_directory(Utils.get_themes_directory())
	dir_watcher.add_scan_directory(Utils.get_user_music_directory())

func load_texture(file: String, ignore_cache := false) -> Texture2D: ## TODO: reload if image changes
	if not file in texture_cache or ignore_cache:
		if not FileAccess.file_exists(file):
			return null
		
		var image := Image.load_from_file(file)
		var texture := ImageTexture.create_from_image(image)
		texture_cache[file] = texture
	
	return texture_cache[file]

func list_directory(path: String, for_files := true) -> PackedStringArray: # TODO: can be removed
	if for_files:
		return DirAccess.get_files_at(path)
	else:
		return DirAccess.get_directories_at(path)

func get_color(rgb):
	var result = []
	for i in 3: result.append(get_color_value(rgb[i]))
	return Color(result[0], result[1], result[2])

func get_rect_string(rect: Rect2) -> String:
	return str(rect.position.x, ", ", rect.position.y, ", ", rect.size.x, ", ", rect.size.y)

func get_color_value(val):
	if val.begins_with("$"): return val.substr(1, 2).hex_to_int() / 255.0
	else: return int(val) / 255.0

func select_music(list, item):
	list.selected = 0
	for i in list.get_item_count():
		if list.get_item_text(i) == item:
			list.selected = i
			return

func save_settings():
	var config = FileAccess.open("user://config", FileAccess.WRITE)
	config.store_line(preferred_language)
	config.store_line(str(enable_autosave))
	config.store_line(str(maximize_on_start))
	config.store_line(str(include_music))
	config.store_line(hedgewars_path)
	config.store_line(hedgewars_user_path)
	config.close()

func refresh_themes():
	for i in main.get_node("ThemeAlign/ThemesList").get_child_count():
		main.get_node("ThemeAlign/ThemesList").get_child(0).free()
	
	for theme_dir in Utils.list_directory(Utils.get_themes_directory(), false): # TODO: handle invalid user path
		var v = theme_dir.split("_v")
		
		var button = preload("res://Nodes/ThemeButton.tscn").instantiate()
		main.get_node("ThemeAlign/ThemesList").add_child(button)
		button.set_meta("theme", theme_dir)
		button.theme_name.text = v[0]
		button.theme_icon.texture = Utils.load_texture(Utils.get_themes_directory().path_join(theme_dir).path_join("icon@2x.png"))
		if v.size() == 2:
			button.theme_version.text = str("v", int(v[1]))
		
		button.pressed.connect(main.theme_selected.bind(button))
	
	main.select_theme_button()

func get_themes_directory() -> String:
	return hedgewars_user_path.path_join("Data/Themes")

func get_game_music_directory() -> String:
	return hedgewars_path.path_join("Data/Music")

func get_user_music_directory() -> String:
	return hedgewars_user_path.path_join("Data/Music")

func get_theme_path(theme: String) -> String:
	return get_themes_directory().path_join(theme)
