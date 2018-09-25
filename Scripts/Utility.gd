extends Node

var themes_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Hedgewars/Data/Themes"
var hedgewars_path = "C:/Program Files (x86)/Hedgewars 0.9.24.1"
var hedgewars_user_path = "C:/Users/Tomek/Documents/Hedgewars"

var size_listeners = []

func _ready():
	get_viewport().connect("size_changed", self, "update_size")

func load_texture(file):
	var image = Image.new()
	image.load(file)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func list_directory(path, for_files = true):
	var list = []
	
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	var entry = dir.get_next()
	while entry != "":
		if for_files == dir.dir_exists(str(Util.themes_path, "/", entry)):
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
		container.rect_min_size.x = get_viewport().size.x

func select_music(list, item):
	list.selected = 0
	for i in list.get_item_count():
		if list.get_item_text(i) == item:
			list.selected = i
			return