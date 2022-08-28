extends Node

var theme_name: String
var theme_version: int
var saved_version: int

var music: String
var sd_music: String
var fallback_music: String
var fallback_sd_music: String

var sky_defined: bool
var border_defined: bool
var sd_tint_defined: bool
var sky: Color
var border: Color
var sd_tint: Color

var water_top_defined: bool
var water_bottom_defined: bool
var water_top: Color
var water_bottom: Color

var sd_water_top_defined: bool
var sd_water_bottom_defined: bool
var sd_water_top: Color
var sd_water_bottom: Color

var clouds_defined: bool
var clouds: int

var sd_clouds_defined: bool
var sd_clouds: int

var flakes_defined: bool
var flakes_amount: int
var flakes_frames: int
var flakes_duration: int
var flakes_rotation: int
var flakes_speed: int

var sd_flakes_defined: bool
var sd_flakes_amount: int
var sd_flakes_frames: int
var sd_flakes_duration: int
var sd_flakes_rotation: int
var sd_flakes_speed: int

var water_animation_defined: bool
var water_animation_frames: int
var water_animation_duration: int
var water_animation_speed: int

var sd_water_animation_defined: bool
var sd_water_animation_frames: int
var sd_water_animation_duration: int
var sd_water_animation_speed: int

var rope_step_defined: bool
var rope_step: int

var hidden: bool
var flatten_clouds: bool
var flatten_flakes: bool
var snow: bool
var ice: bool

var objects: Dictionary
var sprays: Dictionary
var image_list: Array

var theme_output: PoolStringArray
var stored_output: PoolStringArray
var is_loading: bool

signal theme_loaded
signal output_updated

func load_defaults():
	music = ""
	sd_music = ""
	fallback_music = ""
	fallback_sd_music = ""
	
	sky_defined = false
	border_defined = false
	sd_tint_defined = false
	sky = Color(0, 0, 0)
	border = Color("505050")
	sd_tint = Color("808080")
	
	water_top_defined = false
	water_bottom_defined = false
	water_top = Color("80545C9D")
	water_bottom = Color("80343C7D")
	
	sd_water_top_defined = false
	sd_water_bottom_defined = false
	sd_water_top = Color("809670A9")
	sd_water_bottom = Color("80B972C9")
	
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
	
	rope_step_defined = false
	rope_step = 4
	
	hidden = false
	flatten_clouds = false
	flatten_flakes = false
	snow = false
	ice = false

	objects = {}
	sprays = {}

func load_theme(_theme_name, version):
	if theme_name:
		Utils.dir_watcher.remove_scan_directory(get_theme_path())
		Utils.texture_cache.clear()
	
	load_defaults()
	theme_name = _theme_name
	theme_version = version
	saved_version = version
	is_loading = true
	Utils.dir_watcher.add_scan_directory(get_theme_path())
	
	var lines = []
	var cfg_file = File.new()
	if cfg_file.open(get_theme_path().plus_file("theme.cfg"), cfg_file.READ) == OK:
		lines = cfg_file.get_as_text().split("\n")
	
	var water_opacity := 0.5
	var sd_water_opacity := 0.5
	for line in lines:
		var split = line.split(" = ") # TODO: probably some regex for better handling
		var params = []
		if split.size() > 1: params = split[1].split(", ")
		
		match split[0]: # TODO: would be cool to add some metadata for editor
			"music":
				music = params[0].get_basename()
			"sd-music":
				sd_music = params[0].get_basename()
			"fallback-music":
				fallback_music = params[0].get_basename()
			"fallback-sd-music":
				fallback_sd_music = params[0].get_basename()
			"sky":
				sky = Utils.get_color(params)
				sky_defined = true
			"border":
				border = Utils.get_color(params)
				border_defined = true
			"sd-tint":
				sd_tint = Utils.get_color(params)
				sd_tint_defined = true
			"water-top":
				water_top = Utils.get_color(params)
				water_top_defined = true
			"water-bottom":
				water_bottom = Utils.get_color(params)
				water_bottom_defined = true
			"water-opacity": water_opacity = Utils.get_color_value(params[0])
			"sd-water-top":
				sd_water_top = Utils.get_color(params)
				sd_water_top_defined = true
			"sd-water-bottom":
				sd_water_bottom = Utils.get_color(params)
				sd_water_bottom_defined = true
			"sd-water-opacity":
				sd_water_opacity = Utils.get_color_value(params[0])
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
			"rope-step":
				rope_step = int(params[0])
				rope_step_defined = true
			"hidden":
				hidden = true
			"flatten-clouds":
				flatten_clouds = true
			"flatten-flakes":
				flatten_flakes = true
			"snow":
				snow = true
			"ice":
				ice = true
			"object":
				var object := ThemeObject.new(params[0], int(params[1]))
				objects[object.name] = object
				
				if params.size() == 3:
					continue
				
				var rects := 1
				var i := 2
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
			"spray":
				sprays[params[0]] = int(params[1])
			"anchors":
				var object: ThemeObject = objects[params[0]]
				var rects := int(params[1])
				var i := 2
				
				while rects > 0:
					object.anchors.append(Rect2(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
			"overlays":
				var object: ThemeObject = objects[params[0]]
				var rects := int(params[1])
				var i := 2
				
				while rects > 0:
					object.overlays.append(ThemeObject.Overlay.new(Vector2(int(params[i+0]), int(params[i+1])), params[i+2]))
					rects -= 1
					i += 3
	
	water_top.a = water_opacity
	water_bottom.a = water_opacity
	sd_water_top.a = sd_water_opacity
	sd_water_bottom.a = sd_water_opacity
	
	if not sd_clouds_defined:
		sd_clouds = clouds
	
	image_list.clear()
	for file in Utils.list_directory(HWTheme.get_theme_path(), true):
		if file.get_extension() == "png":
			image_list.append(file.get_basename().get_file())
	
	cfg_file.close()
	emit_signal("theme_loaded")
	
	refresh_oputput(false)
	stored_output = theme_output
	is_loading = false

func save_theme():
#	refresh_oputput(false)
	
	Directory.new().rename(get_theme_path().plus_file("theme.cfg"), get_theme_path().plus_file("theme.bak"))
	
	var cfg_file = File.new()
	if cfg_file.open(get_theme_path().plus_file("theme.cfg"), cfg_file.WRITE) == OK: # TODO: show error if fails
		cfg_file.store_string(theme_output.join("\n"))
		cfg_file.close()
		
		stored_output = theme_output
	
	if theme_version != saved_version:
		var new_name = basename()
		if theme_version > 0:
			new_name += str("_v", theme_version)
		
		var renamer = Directory.new()
		renamer.rename(Utils.get_themes_directory().plus_file(theme_name), Utils.get_themes_directory().plus_file(new_name))
		theme_name = new_name
		
		saved_version = theme_version
		Utils.refresh_themes()
	
	emit_signal("output_updated", theme_output != stored_output)

func get_theme_path() -> String:
	return Utils.get_themes_directory().plus_file(theme_name)

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
	
	if music and music != tr("/none/"): theme_output.append(str("music = ", music, ".ogg"))
	if sd_music and sd_music != tr("/none/"): theme_output.append(str("sd-music = ", sd_music, ".ogg"))
	if fallback_music and fallback_music != tr("/none/"): theme_output.append(str("fallback-music = ", fallback_music, ".ogg"))
	if fallback_sd_music and fallback_sd_music != tr("/none/"): theme_output.append(str("fallback-sd-music = ", fallback_sd_music, ".ogg"))
	
	if flakes_defined: theme_output.append(str("flakes = ", flakes_amount, ", ", flakes_frames, ", ", flakes_duration, ", ", flakes_rotation, ", ", flakes_speed))
	if sd_flakes_defined: theme_output.append(str("sd-flakes = ", sd_flakes_amount, ", ", sd_flakes_frames, ", ", sd_flakes_duration, ", ", sd_flakes_rotation, ", ", sd_flakes_speed))
	
	if clouds_defined: theme_output.append(str("clouds = ", clouds))
	if sd_clouds_defined: theme_output.append(str("sd-clouds = ", sd_clouds))
	
	if water_animation_defined: theme_output.append(str("water-animation = ", water_animation_frames, ", ", water_animation_duration, ", ", water_animation_speed * 0.01))
	if sd_water_animation_defined: theme_output.append(str("sd-water-animation = ", sd_water_animation_frames, ", ", sd_water_animation_duration, ", ", sd_water_animation_speed * 0.01))
	
	for spray in sprays.keys(): theme_output.append(str("spray = ", spray, ", ", sprays[spray]))
	
	for object in objects.keys():
		var line := PoolStringArray()
		line.append(str(object, ", ", objects[object].number, ", "))
		
		if objects[object].buried.size() != 1:
			line.append(str(objects[object].buried.size(), ", "))
		for buried in objects[object].buried:
			line.append(Utils.get_rect_string(buried) +  ", ")
		
		line.append(str(objects[object].visible.size()))
		for visible in objects[object].visible:
			line.append(", " + Utils.get_rect_string(visible))
		
		theme_output.append("object = " + line.join(""))
		
		var anchors: Array = objects[object].anchors
		if not anchors.empty():
			line = PoolStringArray()
			line.append(str(object, ", ", anchors.size()))
			
			for anchor in anchors:
				line.append(", " + Utils.get_rect_string(anchor))
			
			theme_output.append("anchors = " + line.join(""))
		
		var overlays: Array = objects[object].overlays
		if not overlays.empty():
			line = PoolStringArray()
			line.append(str(object, ", ", overlays.size()))
			
			for overlay in overlays:
				line.append(str(", ", overlay.position.x, ", ", overlay.position.y, ", ", overlay.image))
			
			theme_output.append("overlays = " + line.join(""))
	
	if rope_step_defined:
		theme_output.append(str("rope-step = ", rope_step))
	
	if hidden:
		theme_output.append("hidden = true")
	
	if flatten_flakes:
		theme_output.append("flatten-flakes = true")
	
	if flatten_clouds:
		theme_output.append("flatten-clouds = true")
	
	if snow:
		theme_output.append("snow = true")
	
	if ice:
		theme_output.append("ice = true")
	
	if emit_changed:
		emit_signal("output_updated", theme_output != stored_output)

func change_property(value, property: String):
	if is_loading:
		return
	
	set(property, value)
	apply_change()
	
func change_property_from_list(item: int, property: String, list: OptionButton):
	change_property(list.get_item_text(item), property)

func apply_change():
	refresh_oputput()
	if Utils.enable_autosave:
		save_theme()

func set_version(version):
	theme_version = version
	
	if not is_loading and Utils.enable_autosave:
		save_theme()

func basename() -> String:
	return theme_name.split("_v")[0]

class ThemeObject:
	var name: String
	var number: int
	var buried: Array
	var visible: Array
	var anchors: Array
	var overlays: Array
	var on_water: bool
	
	func _init(p_name: String, p_number: int):
		name = p_name
		number = p_number
	
	func clone() -> ThemeObject:
		var cloned := ThemeObject.new(name, number)
		cloned.buried = buried.duplicate()
		cloned.visible = visible.duplicate()
		cloned.anchors = anchors.duplicate()
		cloned.overlays = overlays.duplicate()
		cloned.on_water = on_water
		return cloned
	
	func has_overlay(overlay: String) -> bool:
		for o in overlays:
			if o.image == overlay:
				return true
		return false
	
	class Overlay:
		var position: Vector2
		var image: String
		
		func _init(p_position: Vector2, p_image: String):
			position = p_position
			image = p_image
		
		func get_texture() -> Texture:
			return Utils.load_texture(HWTheme.get_theme_path().plus_file(image + ".png"))
		
		func get_rect() -> Rect2:
			return Rect2(position, get_texture().get_size())
