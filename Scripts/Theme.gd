extends Node

var theme_name

var music
var sd_music

var sky
var border
var sd_tint

var water_top
var water_bottom
var water_opacity

var sd_water_top
var sd_water_bottom
var sd_water_opacity

var clouds_defined
var clouds

var sd_clouds_defined
var sd_clouds

var flakes_defined
var flakes_amount
var flakes_frames
var flakes_duration
var flakes_rotation
var flakes_speed

var sd_flakes_defined
var sd_flakes_amount
var sd_flakes_frames
var sd_flakes_duration
var sd_flakes_rotation
var sd_flakes_speed

var water_animation_defined
var water_animation_frames
var water_animation_duration
var water_animation_speed

var sd_water_animation_defined
var sd_water_animation_frames
var sd_water_animation_duration
var sd_water_animation_speed

var flatten_clouds
var flatten_flakes
var snow
var ice

var objects
var sprays

signal theme_loaded

func load_defaults():
	sky = Color(0, 0, 0)
	border = Color("505050")
	sd_tint = Color("808080")
	
	water_top = Color("545C9D")
	water_bottom = Color("343C7D")
	water_opacity = 128
	
	sd_water_top = Color("9670A9")
	sd_water_bottom = Color("B972C9")
	sd_water_opacity = 128
	
	clouds_defined = false
	clouds = 9
	
	sd_clouds_defined = false
	sd_clouds = 9
	
	flakes_defined = false
	flakes_amount = 0
	flakes_frames = 0
	flakes_duration = 0
	flakes_rotation = 0
	flakes_speed = 0
	
	sd_flakes_defined = false
	sd_flakes_amount = 0
	sd_flakes_frames = 0
	sd_flakes_duration = 0
	sd_flakes_rotation = 0
	sd_flakes_speed = 0
	
	water_animation_defined = false
	water_animation_frames = 1
	water_animation_duration = 0
	water_animation_speed = 1
	
	sd_water_animation_defined = false
	sd_water_animation_frames = 1
	sd_water_animation_duration = 0
	sd_water_animation_speed = 1
	
	flatten_clouds = false
	flatten_flakes = false
	snow = false
	ice = false

	objects = {}
	sprays = {}

func load_theme(_theme_name):
	load_defaults()
	theme_name = _theme_name
	
	sd_clouds = null
	
	var cfg_file = File.new()
	cfg_file.open(path() + "theme.cfg", cfg_file.READ)
	var lines = cfg_file.get_as_text().split("\n")
	
	for line in lines:
		var split = line.split(" = ") #TODO: probably some regex for better handling
		var params = []
		if split.size() > 1: params = split[1].split(", ")
		
		match split[0]:
			"music": music = params[0].get_basename()
			"sd-music": sd_music = params[0].get_basename()
			"sky": sky = Util.get_color(params)
			"border": border = Util.get_color(params)
			"sd-tint": sd_tint = Util.get_color(params)
			"water-top": water_top = Util.get_color(params)
			"water-bottom": water_bottom = Util.get_color(params)
			"water-opacity": water_opacity = Util.get_color_value(params[0])
			"sd-water-top": sd_water_top = Util.get_color(params)
			"sd-water-bottom": sd_water_bottom = Util.get_color(params)
			"sd-water-opacity": sd_water_opacity = Util.get_color_value(params[0])
			"clouds":
				clouds = int(params[0])
				clouds_defined = true
			"sd-clouds":
				sd_clouds = int(params[0])
				sd_clouds_defined = true
			"flakes":
				flakes_amount = int(params[0])
				if params.size() > 1:
					flakes_frames = int(params[1])
					flakes_duration = int(params[2])
					flakes_rotation = int(params[3])
					flakes_speed = int(params[4])
					flakes_defined = true
			"sd-flakes":
				sd_flakes_amount = int(params[0])
				if params.size() > 1:
					sd_flakes_frames = int(params[1])
					sd_flakes_duration = int(params[2])
					sd_flakes_rotation = int(params[3])
					sd_flakes_speed = int(params[4])
					sd_flakes_defined = true
			"water-animation":
				water_animation_frames = int(params[0])
				water_animation_duration = int(params[1])
				water_animation_speed = float(params[2])
				water_animation_defined = true
			"sd-water-animation":
				sd_water_animation_frames = int(params[0])
				sd_water_animation_duration = int(params[1])
				sd_water_animation_speed = float(params[2])
				sd_water_animation_defined = true
			"flatten-clouds": flatten_clouds = true
			"flatten-flakes": flatten_flakes = true
			"snow": snow = true
			"ice": ice = true
			"object":
				var object = {buried = [], visible = []}
				object.max = int(params[1])
				
				var rects = 1
				var i = 2
				if params.size() % 2 == 0:
					rects = int(params[2])
					i = 3
				
				while rects > 0:
					object.buried.append(Rect2(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
				
				rects = int(params[i])
				i += 1
				while rects > 0:
					object.visible.append(Rect2(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
				
				objects[params[0]] = object
	
	water_top.a = water_opacity
	water_bottom.a = water_opacity
	sd_water_top.a = sd_water_opacity
	sd_water_bottom.a = sd_water_opacity
	
	if sd_clouds == null: sd_clouds = clouds
	
	OS.set_window_title(str(tr("Hedgewars Theme Editor 3"), " (", theme_name, ")"))
	emit_signal("theme_loaded")

func path():
	return str(Util.themes_path, "/", theme_name, "/")