extends Node

var themes_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Hedgewars/Data/Themes"
var hedgewars_path = "C:/Program Files (x86)/Hedgewars 0.9.24.1"

func load_texture(file):
	var image = Image.new()
	image.load(file)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func theme_path():
	return str(themes_path, "/", HWTheme.theme_name, "/")

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