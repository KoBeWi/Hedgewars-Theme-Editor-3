extends Node

var dir_watcher: DirectoryWatcher
var texture_cache: Dictionary

var preferred_language: String
var hedgewars_path: String
var hedgewars_user_path: String
var package_path: String

var enable_autosave := true
var maximize_on_start := true
var include_music := true

var temp_editor
var main

signal object_modified(operation, object)

func _ready():
	load_settings()
	
	if hedgewars_path.is_empty():
		var path: String
		
		match OS.get_name():
			"Windows":
				for dir in DirAccess.get_directories_at("C:/Program Files (x86)"):
					if dir.begins_with("Hedgewars"):
						path = "C:/Program Files (x86)".path_join(dir)
						break
				
				if path.is_empty():
					for dir in DirAccess.get_directories_at("C:/Program Files"):
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

func load_settings():
	var config := FileAccess.get_file_as_string("user://config.txt")
	if not config.is_empty():
		var config_data: Dictionary = str_to_var(config)
		preferred_language = config_data.get("preferred_language", OS.get_locale())
		enable_autosave = config_data.get("enable_autosave", true)
		maximize_on_start = config_data.get("maximize_on_start", true)
		include_music = config_data.get("include_music", true)
		hedgewars_path = config_data.get("hedgewars_path", "")
		hedgewars_user_path = config_data.get("hedgewars_user_path", "")
	else:
		var legacy_config := FileAccess.open("user://config", FileAccess.READ)
		if legacy_config:
			var lines := legacy_config.get_as_text().split("\n")
			preferred_language = lines[0]
			enable_autosave = lines[1].to_lower() == "true"
			maximize_on_start = lines[2].to_lower() == "true"
			include_music = lines[3].to_lower() == "true"
			hedgewars_path = lines[4]
			hedgewars_user_path = lines[5]
			save_settings()
		else:
			preferred_language = OS.get_locale()

func save_settings():
	var config_data: Dictionary
	config_data["preferred_language"] = preferred_language
	config_data["enable_autosave"] = enable_autosave
	config_data["maximize_on_start"] = maximize_on_start
	config_data["include_music"] = include_music
	config_data["hedgewars_path"] = hedgewars_path
	config_data["hedgewars_user_path"] = hedgewars_user_path
	
	var config := FileAccess.open("user://config.txt", FileAccess.WRITE)
	config.store_string(var_to_str(config_data))

func refresh_themes():
	for i in main.get_node("ThemeAlign/ThemesList").get_child_count():
		main.get_node("ThemeAlign/ThemesList").get_child(0).free()
	
	for theme_dir in DirAccess.get_directories_at(Utils.get_themes_directory()): # TODO: handle invalid user path
		var button = preload("uid://bec35mck45vma").instantiate()
		main.themes_list.add_child(button)
		button.set_theme_dir(theme_dir)
		
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
