extends Node

var theme_name

var sky = Color(0, 0, 0)
var border = Color("505050")
var water_top = Color("545C9D")
var water_bottom = Color("343C7D")
var water_opacity = 128
var sd_water_top = Color("9670A9")
var sd_water_bottom = Color("B972C9")
var sd_water_opacity = 128

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
			"sky": sky = Util.get_color(params)
			"border": border = Util.get_color(params)
			"water-top": water_top = Util.get_color(params)
			"water-bottom": water_bottom = Util.get_color(params)
			"water-opacity": water_opacity = Util.get_color_value(params[0])
			"sd-water-top": sd_water_top = Util.get_color(params)
			"sd-water-bottom": sd_water_bottom = Util.get_color(params)
			"sd-water-opacity": sd_water_opacity = Util.get_color_value(params[0])
	
	water_top.a = water_opacity
	water_bottom.a = water_opacity
	sd_water_top.a = sd_water_opacity
	sd_water_bottom.a = sd_water_opacity
	
	emit_signal("theme_loaded")

func path():
	return str(Util.themes_path, "/", theme_name, "/")