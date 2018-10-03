extends Node

var theme_name

var music
var sd_music

var sky_defined
var border_defined
var sd_tint_defined
var sky
var border
var sd_tint

var water_top_defined
var water_bottom_defined
var water_top
var water_bottom
var water_opacity

var sd_water_top_defined
var sd_water_bottom_defined
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

var theme_output
var stored_output
var is_loading = false

signal theme_loaded
signal output_updated

func load_defaults():
	sky_defined = false
	border_defined = false
	sd_tint_defined = false
	sky = Color(0, 0, 0)
	border = Color("505050")
	sd_tint = Color("808080")
	
	water_top_defined = false
	water_bottom_defined = false
	water_top = Color("545C9D")
	water_bottom = Color("343C7D")
	water_opacity = 128
	
	sd_water_top_defined = false
	sd_water_bottom_defined = false
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
	water_animation_speed = 100
	
	sd_water_animation_defined = false
	sd_water_animation_frames = 1
	sd_water_animation_duration = 0
	sd_water_animation_speed = 100
	
	flatten_clouds = false
	flatten_flakes = false
	snow = false
	ice = false

	objects = {}
	sprays = {}

func load_theme(_theme_name):
	load_defaults()
	theme_name = _theme_name
	is_loading = true
	
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
			"sky":
				sky = Util.get_color(params)
				sky_defined = true
			"border":
				border = Util.get_color(params)
				border_defined = true
			"sd-tint":
				sd_tint = Util.get_color(params)
				sd_tint_defined = true
			"water-top":
				water_top = Util.get_color(params)
				water_top_defined = true
			"water-bottom":
				water_bottom = Util.get_color(params)
				water_bottom_defined = true
			"water-opacity": water_opacity = Util.get_color_value(params[0])
			"sd-water-top":
				sd_water_top = Util.get_color(params)
				sd_water_top_defined = true
			"sd-water-bottom":
				sd_water_bottom = Util.get_color(params)
				sd_water_bottom_defined = true
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
				water_animation_speed = float(params[2]) * 100
				water_animation_defined = true
			"sd-water-animation":
				sd_water_animation_frames = int(params[0])
				sd_water_animation_duration = int(params[1])
				sd_water_animation_speed = float(params[2]) * 100
				sd_water_animation_defined = true
			"flatten-clouds": flatten_clouds = true
			"flatten-flakes": flatten_flakes = true
			"snow": snow = true
			"ice": ice = true
			"object":
				var object = {name = params[0], number = int(params[1]), buried = [], visible = [], on_water = false}
				
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
			"spray": sprays[params[0]] = int(params[1])
	
	water_top.a = water_opacity
	water_bottom.a = water_opacity
	sd_water_top.a = sd_water_opacity
	sd_water_bottom.a = sd_water_opacity
	
	if sd_clouds == null: sd_clouds = clouds
	
	cfg_file.close()
	emit_signal("theme_loaded")
	
	refresh_oputput(false)
	is_loading = false

func save_theme():
	refresh_oputput(false)
	
	Directory.new().rename(path() + "theme.cfg", path() + "theme.bak")
	
	var cfg_file = File.new()
	cfg_file.open(path() + "theme.cfg", cfg_file.WRITE)
	cfg_file.store_string(theme_output.join("\n"))
	cfg_file.close()
	
	stored_output = theme_output

func path():
	return str(Util.hedgewars_user_path, "/Data/Themes/", theme_name, "/")

func refresh_oputput(emit_changed = true):
	theme_output = PoolStringArray()
	
	theme_output.append("#Created with Hedgewars Theme Editor 3")
	
	if sky_defined: theme_output.append(str("sky = ", int(sky.r * 255), ", ", int(sky.g * 255), ", ", int(sky.b * 255)))
	if border_defined: theme_output.append(str("border = ", int(border.r * 255), ", ", int(border.g * 255), ", ", int(border.b * 255)))
	if sd_tint_defined: theme_output.append(str("sd-tint = ", int(sd_tint.r * 255), ", ", int(sd_tint.g * 255), ", ", int(sd_tint.b * 255), ", ", int(sd_tint.a * 255)))
	
	if water_top_defined: theme_output.append(str("water-top = ", int(water_top.r * 255), ", ", int(water_top.g * 255), ", ", int(water_top.b * 255)))
	if water_bottom_defined: theme_output.append(str("water-bottom = ", int(water_bottom.r * 255), ", ", int(water_bottom.g * 255), ", ", int(water_bottom.b * 255)))
	if water_top_defined or water_bottom_defined: theme_output.append(str("water-opacity = ", int(water_top.a * 255)))
	
	if sd_water_top_defined: theme_output.append(str("sd-water-top = ", int(sd_water_top.r * 255), ", ", int(sd_water_top.g * 255), ", ", int(sd_water_top.b * 255)))
	if sd_water_bottom_defined: theme_output.append(str("sd-water-bottom = ", int(sd_water_bottom.r * 255), ", ", int(sd_water_bottom.g * 255), ", ", int(sd_water_bottom.b * 255)))
	if sd_water_top_defined or sd_water_bottom_defined: theme_output.append(str("sd-water-opacity = ", int(sd_water_top.a * 255)))
	
	if music != tr("/none/"): theme_output.append(str("music = ", music, ".ogg"))
	if sd_music != tr("/none/"): theme_output.append(str("sd-music = ", sd_music, ".ogg"))
	
	if flakes_defined: theme_output.append(str("flakes = ", flakes_amount, ", ", flakes_frames, ", ", flakes_duration, ", ", flakes_rotation, ", ", flakes_speed))
	if sd_flakes_defined: theme_output.append(str("sd-flakes = ", sd_flakes_amount, ", ", sd_flakes_frames, ", ", sd_flakes_duration, ", ", sd_flakes_rotation, ", ", sd_flakes_speed))
	
	if clouds_defined: theme_output.append(str("clouds = ", clouds))
	if sd_clouds_defined: theme_output.append(str("sd-clouds = ", sd_clouds))
	
	if water_animation_defined: theme_output.append(str("water-animation = ", water_animation_frames, ", ", water_animation_duration, ", ", water_animation_speed * 0.01)) #TODO: make sure floats have 2 decimal digits
	if sd_water_animation_defined: theme_output.append(str("sd-water-animation = ", sd_water_animation_frames, ", ", sd_water_animation_duration, ", ", sd_water_animation_speed * 0.01))
	
	for spray in sprays.keys(): theme_output.append(str("spray = ", spray, ", ", sprays[spray]))
	
	for object in objects.keys():
		var line = PoolStringArray()
		line.append(str(object, ", ", objects[object].number, ", "))
		
		if objects[object].buried.size() > 1: line.append(str(objects[object].buried.size(), ", "))
		for buried in objects[object].buried:
			line.append(str(buried.position.x, ", ", buried.position.y, ", ", buried.size.x, ", ", buried.size.y, ", "))
		
		line.append(str(objects[object].visible.size()))
		for visible in objects[object].visible:
			line.append(str(", ", visible.position.x, ", ", visible.position.y, ", ", visible.size.x, ", ", visible.size.y))
		
		theme_output.append("object = " + line.join(""))
	
	if flatten_flakes: theme_output.append("flatten-flakes = true")
	if flatten_clouds: theme_output.append("flatten-clouds = true")
	if snow: theme_output.append("snow = true")
	if ice: theme_output.append("ice = true")
	
	if emit_changed: emit_signal("output_updated", theme_output != stored_output)

func change_property(value, property):
	if is_loading: return
	
	set(property, value)
	apply_change()
	
func change_property_from_list(item, property, list):
	change_property(list.get_item_text(item), property)

func apply_change():
	if Util.enable_autosave: save_theme()
	else: refresh_oputput()