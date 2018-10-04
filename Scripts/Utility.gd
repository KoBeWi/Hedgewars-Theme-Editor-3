extends Node

var preferred_language
var enable_autosave = true
var hedgewars_path
var hedgewars_user_path

var temp_editor
var size_listeners = []

func _ready():
	get_viewport().connect("size_changed", self, "update_size")
	
	var config = File.new()
	if config.open("user://config", File.READ) == OK:
		var lines = config.get_as_text().split("\n")
		preferred_language = lines[0]
		enable_autosave = lines[1] == "True"
		hedgewars_path = lines[2]
		hedgewars_user_path = lines[3]
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

func load_texture(file):
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

func get_color(rgb):
	var result = []
	for i in 3: result.append(get_color_value(rgb[i]))
	return Color(result[0], result[1], result[2])

func get_color_value(val):
	if val.begins_with("$"): return val.substr(1, 2).hex_to_int() / 255.0
	else: return int(val) / 255.0

func update_size():
	for container in size_listeners:
		container.rect_min_size.x = get_viewport().size.x-32

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
	config.store_line(hedgewars_path)
	config.store_line(hedgewars_user_path)
	config.close()