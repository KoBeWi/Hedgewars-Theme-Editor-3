extends Node

var preferred_language
var hedgewars_path
var hedgewars_user_path
var package_path

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
	
	if !hedgewars_user_path:
		var path
		var test_directory = Directory.new()
		
		match OS.get_name():
			"Windows":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Hedgewars"
			
			"X11":
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir() + "/home"
			
			"OSX": #TODO: really?
				path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).get_base_dir() + "/home"
		
		hedgewars_user_path = path
	
	if !package_path:
		var file = File.new()
		file.open("res://icon.png", file.READ)
		package_path = file.get_path_absolute().get_base_dir() + "/PackedThemes"

func load_texture(file) -> Texture:
	var check_exists = File.new()
	if not check_exists.file_exists(file):
		return null
	
	var image = Image.new()
	image.load(file)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	return texture

func list_directory(path, for_files = true):
	var list = []
	
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	var entry = dir.get_next()
	while entry != "":
		if for_files == dir.dir_exists(str(path, "/", entry)):
			entry = dir.get_next()
			continue
		
		list.append(entry)
		entry = dir.get_next()
	
	return list

func get_theme_path(theme):
	return str(hedgewars_user_path, "/Data/Themes/", theme, "/")

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
	
	for theme_dir in Util.list_directory(Util.hedgewars_user_path + "/Data/Themes", false):#TODO: handle invalid user path
		var v = theme_dir.split("_v")
		
		var button = preload("res://Nodes/ThemeButton.tscn").instance()
		main.get_node("ThemeAlign/ThemesList").add_child(button)
		button.set_meta("theme", theme_dir)
		button.theme_name.text = v[0]
		button.theme_icon.texture = Util.load_texture(str(Util.hedgewars_user_path, "/Data/Themes/", theme_dir, "/", "icon@2x.png"))
		if v.size() == 2:
			button.theme_version.text = str("v", int(v[1]))
		
		button.connect("pressed", main, "theme_selected", [button])
	
	main.select_theme_button()
