extends Node

var theme_name

var sky = Color(0, 0, 0)
var border = Color("505050")
var water_top = Color("80545C9D")
var water_bottom = Color("80343C7D")

signal theme_loaded

func load_theme(_theme_name):
	theme_name = _theme_name
	
	sky = Color(0, 0, 0)
	
	var cfg_file = File.new()
	cfg_file.open(path() + "theme.cfg", cfg_file.READ)
	var lines = cfg_file.get_as_text().split("\n")
	
	for line in lines:
		var split = line.split(" = ") #TODO: probably some regex for better handling
		var params = []
		if split.size() > 1: params = split[1].split(", ")
		
		match split[0]:
			"sky": sky = Color(int(params[0]), int(params[1]), int(params[2]))
	
	emit_signal("theme_loaded")

func path():
	return str(Util.themes_path, "/", theme_name, "/")