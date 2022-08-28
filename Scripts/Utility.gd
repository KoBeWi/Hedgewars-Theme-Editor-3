extends Node

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
	var config = File.new()
	if config.open("user://config", File.READ) == OK:
		var lines = config.get_as_text().split("\n")
		preferred_language = lines[0]
		enable_autosave = lines[1] == "True"
		maximize_on_start = lines[2] == "True"
		include_music = lines[3] == "True"
		hedgewars_path = lines[4]
		hedgewars_user_path = lines[5]
		config.close()
	else:
		preferred_language = OS.get_locale()
	
	if !hedgewars_path:
		var path
		var test_directory = Directory.new()
		
		match OS.get_name():
			"Windows":
				for dir in Util.list_directory("C:/Program Files (x86)", false):
					if dir.begins_with("Hedgewars"):
						path = "C:/Program Files (x86)/" + dir
						break
				
				if !path: for dir in Util.list_directory("C:/Program Files", false):
					if dir.begins_with("Hedgewars"):
						path = "C:/Program Files/" + dir
						break
			
			"X11":
				if test_directory.dir_exists("/usr/share/hedgewars"): path = "/usr/share/hedgewars"
				else: path = "/usr/share/games/hedgewars"
			
			"OSX": #TODO: really?
				if test_directory.dir_exists("/usr/share/hedgewars"): path = "/usr/share/hedgewars"
				else: path = "/usr/share/games/hedgewars"
		
		hedgewars_path = path
	
	if hedgewars_user_path.empty():
		var path: String
		
		match OS.get_name():
			"Windows":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("Hedgewars")
			
			"X11":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir().plus_file("home")
			
			"OSX": #TODO: really?
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir().plus_file("home")
		
		hedgewars_user_path = path
	
	if package_path.empty():
		package_path = ProjectSettings.globalize_path("res://").plus_file("PackedThemes")

var texture_cache: Dictionary

func load_texture(file: String) -> Texture: ## TODO: reload if image changes
	if not file in texture_cache:
		if not File.new().file_exists(file):
			return null
		
		var image := Image.new()
		image.load(file)
		
		var texture := ImageTexture.new()
		texture.create_from_image(image, 0)
		texture_cache[file] = texture
	
	return texture_cache[file]

func list_directory(path: String, for_files := true):
	var list := []
	
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	var entry = dir.get_next()
	while not entry.empty():
		if for_files == dir.current_is_dir():
			entry = dir.get_next()
			continue
		
		list.append(entry)
		entry = dir.get_next()
	
	return list

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
	var config = File.new()
	config.open("user://config", File.WRITE)
	config.store_line(str(preferred_language))
	config.store_line(str(enable_autosave))
	config.store_line(str(maximize_on_start))
	config.store_line(str(include_music))
	config.store_line(hedgewars_path)
	config.store_line(hedgewars_user_path)
	config.close()

func refresh_themes():
	for i in main.get_node("ThemeAlign/ThemesList").get_child_count():
		main.get_node("ThemeAlign/ThemesList").get_child(0).free()
	
	for theme_dir in Util.list_directory(Util.get_themes_directory(), false): # TODO: handle invalid user path
		var v = theme_dir.split("_v")
		
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		main.get_node("ThemeAlign/ThemesList").add_child(button)
		button.set_meta("theme", theme_dir)
		button.theme_name.text = v[0]
		button.theme_icon.texture = Util.load_texture(Util.get_themes_directory().plus_file(theme_dir).plus_file("icon@2x.png"))
		if v.size() == 2:
			button.theme_version.text = str("v", int(v[1]))
		
		button.connect("pressed", main, "theme_selected", [button])
	
	main.select_theme_button()

func get_themes_directory() -> String:
	return hedgewars_user_path.plus_file("Data/Themes")

func get_game_music_directory() -> String:
	return hedgewars_path.plus_file("Data/Music")

func get_user_music_directory() -> String:
	return hedgewars_user_path.plus_file("Data/Music")

func get_theme_path(theme: String) -> String:
	return get_themes_directory().plus_file(theme)
