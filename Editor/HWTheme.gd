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

var objects: Dictionary[String, ThemeObject]
var sprays: Dictionary[String, int]
var image_list: PackedStringArray

var theme_output: PackedStringArray
var stored_output: PackedStringArray
var is_loading: bool

signal theme_loaded
signal output_updated

func load_defaults() -> void:
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
	water_top = Color("545C9D80")
	water_bottom = Color("343C7D80")
	
	sd_water_top_defined = false
	sd_water_bottom_defined = false
	sd_water_top = Color("9670A980")
	sd_water_bottom = Color("B972C980")
	
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

func load_theme(theme_dir: String) -> void:
	if is_theme_loaded():
		Utils.dir_watcher.remove_scan_directory(get_theme_path())
		Utils.texture_cache.clear()
	
	load_defaults()
	
	var v := theme_dir.split("_v")
	theme_name = v[0]
	if v.size() == 1:
		theme_version = 0
		saved_version = 0
	else:
		theme_version = v[1].to_int()
		saved_version = theme_version
	
	is_loading = true
	Utils.dir_watcher.add_scan_directory(get_theme_path())
	
	var lines = []
	var cfg_file := FileAccess.open(get_theme_path().path_join("theme.cfg"), FileAccess.READ)
	if cfg_file:
		lines = cfg_file.get_as_text().split("\n")
	
	var water_opacity := 0.5
	var sd_water_opacity := 0.5
	for line in lines:
		var split = line.split(" = ") # TODO: probably some regex for better handling, or at least "=" and trim
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
					object.buried.append(Rect2i(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
				
				rects = int(params[i])
				i += 1
				while rects > 0:
					object.visible.append(Rect2i(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
			"spray":
				sprays[params[0]] = int(params[1])
			"anchors":
				var object: ThemeObject = objects[params[0]]
				var rects := int(params[1])
				var i := 2
				
				while rects > 0:
					object.anchors.append(Rect2i(int(params[i]), int(params[i+1]), int(params[i+2]), int(params[i+3])))
					rects -= 1
					i += 4
			"overlays":
				var object: ThemeObject = objects[params[0]]
				var rects := int(params[1])
				var i := 2
				
				while rects > 0:
					object.overlays.append(ThemeObject.Overlay.new(Vector2i(int(params[i+0]), int(params[i+1])), params[i+2]))
					rects -= 1
					i += 3
	
	water_top.a = water_opacity
	water_bottom.a = water_opacity
	sd_water_top.a = sd_water_opacity
	sd_water_bottom.a = sd_water_opacity
	
	if not sd_clouds_defined:
		sd_clouds = clouds
	
	image_list.clear()
	for file in DirAccess.get_files_at(HWTheme.get_theme_path()):
		if file.get_extension() == "png":
			image_list.append(file.get_basename().get_file())
	
	cfg_file.close()
	theme_loaded.emit()
	
	refresh_oputput(false)
	stored_output = theme_output
	is_loading = false

func save_theme() -> void:
#	refresh_oputput(false)
	
	DirAccess.rename_absolute(get_theme_path().path_join("theme.cfg"), get_theme_path().path_join("theme.bak"))
	
	var cfg_file := FileAccess.open(get_theme_path().path_join("theme.cfg"), FileAccess.WRITE)
	if cfg_file: # TODO: show error if fails
		cfg_file.store_string("\n".join(theme_output))
		cfg_file.close()
		
		stored_output = theme_output
	
	if theme_version != saved_version:
		var new_name = basename()
		if theme_version > 0:
			new_name += str("_v", theme_version)
		
		DirAccess.rename_absolute(Utils.get_themes_directory().path_join(theme_name), Utils.get_themes_directory().path_join(new_name))
		theme_name = new_name
		
		saved_version = theme_version
		Utils.refresh_themes()
	
	output_updated.emit(theme_output != stored_output)

func get_theme_path() -> String:
	if theme_version == 0:
		return Utils.get_themes_directory().path_join(theme_name)
	else:
		return Utils.get_themes_directory().path_join("%s_v%d" % [theme_name, theme_version])

func refresh_oputput(emit_changed := true) -> void:
	theme_output = PackedStringArray()
	theme_output.append("#Created with Hedgewars Theme Editor 3")
	
	if sky_defined:
		theme_output.append("sky = %d, %d, %d" % get_color_format(sky))
	
	if border_defined:
		theme_output.append("border = %d, %d, %d" % get_color_format(border))
	
	if sd_tint_defined:
		theme_output.append("sd-tint = %d, %d, %d" % get_color_format(sd_tint))
	
	if water_top_defined:
		theme_output.append("water-top = %d, %d, %d" % get_color_format(water_top))
	
	if water_bottom_defined:
		theme_output.append("water-bottom = %d, %d, %d" % get_color_format(water_bottom))
	
	if water_top_defined or water_bottom_defined:
		theme_output.append("water-opacity = %d" % int(water_top.a * 255))
	
	if sd_water_top_defined:
		theme_output.append("sd-water-top = %d, %d, %d" % get_color_format(sd_water_top))
	
	if sd_water_bottom_defined:
		theme_output.append("sd-water-bottom = %d, %d, %d" % get_color_format(sd_water_bottom))
	
	if sd_water_top_defined or sd_water_bottom_defined:
		theme_output.append("sd-water-opacity = %d" % int(sd_water_top.a * 255))
	
	if not music.is_empty() and music != "/none/":
		theme_output.append("music = %s.ogg" % music)
	
	if not sd_music.is_empty() and sd_music != "/none/":
		theme_output.append("sd-music = %s.ogg" % sd_music)
	
	if not fallback_music.is_empty() and fallback_music != "/none/":
		theme_output.append("fallback-music = %s.ogg" % fallback_music)
	
	if not fallback_sd_music.is_empty() and fallback_sd_music != "/none/":
		theme_output.append("fallback-sd-music = %s.ogg" % fallback_sd_music)
	
	if flakes_defined:
		theme_output.append("flakes = %d, %d, %d, %d, %d" % [flakes_amount, flakes_frames, flakes_duration, flakes_rotation, flakes_speed])
	
	if sd_flakes_defined:
		theme_output.append("sd-flakes = %d, %d, %d, %d, %d" % [sd_flakes_amount, sd_flakes_frames, sd_flakes_duration, sd_flakes_rotation, sd_flakes_speed])
	
	if clouds_defined:
		theme_output.append("clouds = %d" % clouds)
	
	if sd_clouds_defined:
		theme_output.append("sd-clouds = %d" % sd_clouds)
	
	if water_animation_defined:
		theme_output.append("water-animation = %d, %d, %d" % [water_animation_frames, water_animation_duration, water_animation_speed])
	
	if sd_water_animation_defined:
		theme_output.append("sd-water-animation = %d, %d, %d" % [sd_water_animation_frames, sd_water_animation_duration, sd_water_animation_speed])
	
	for spray in sprays.keys():
		theme_output.append("spray = %s, %d" % [spray, sprays[spray]])
	
	for object_name in objects.keys():
		var object := objects[object_name]
		
		var line := PackedStringArray()
		line.append(object_name)
		line.append(str(object.number))
		
		if object.buried.size() != 1:
			line.append(str(object.buried.size()))
		
		for buried in object.buried:
			line.append(Utils.get_rect_string(buried))
		
		line.append(str(object.visible.size()))
		for visible in object.visible:
			line.append(Utils.get_rect_string(visible))
		
		theme_output.append("object = %s" % ", ".join(line))
		
		if not object.anchors.is_empty():
			line = PackedStringArray()
			line.append(object_name)
			line.append(str(object.anchors.size()))
			
			for anchor in object.anchors:
				line.append(Utils.get_rect_string(anchor))
			
			theme_output.append("anchors = %s" % ", ".join(line))
		
		if not object.overlays.is_empty():
			line = PackedStringArray()
			line.append(object_name)
			line.append(str(object.overlays.size()))
			
			for overlay in object.overlays:
				line.append(str(overlay.position.x))
				line.append(str(overlay.position.y))
				line.append(str(overlay.image))
			
			theme_output.append("overlays = %s" % ", ".join(line))
	
	if rope_step_defined:
		theme_output.append("rope-step = %d" % rope_step)
	
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
		output_updated.emit(theme_output != stored_output)

func get_color_format(color: Color) -> Array:
	return [int(color.r * 255), int(color.g * 255), int(color.b * 255)]

func change_property(value, property: StringName) -> void:
	if is_loading:
		return
	
	set(property, value)
	apply_change()
	
func change_property_from_list(item: int, property: StringName, list: OptionButton) -> void:
	change_property(list.get_item_text(item), property)

func apply_change() -> void:
	refresh_oputput()
	if Utils.enable_autosave:
		save_theme()

func set_version(version: int) -> void:
	theme_version = version
	
	if not is_loading and Utils.enable_autosave:
		save_theme()

func basename() -> String:
	return theme_name.split("_v")[0]

func is_theme_loaded() -> bool:
	return not theme_name.is_empty()

class ThemeObject:
	var name: String
	var number: int
	
	var buried: Array[Rect2i]
	var visible: Array[Rect2i]
	
	var anchors: Array[Rect2i]
	var overlays: Array[Overlay]
	var on_water: bool # TODO: unused
	
	func _init(p_name: String, p_number: int):
		name = p_name
		number = p_number
	
	func clone() -> ThemeObject:
		var cloned := ThemeObject.new(name, number)
		cloned.buried.assign(buried.duplicate())
		cloned.visible.assign(visible.duplicate())
		cloned.anchors.assign(anchors.duplicate())
		cloned.overlays.assign(overlays.duplicate())
		cloned.on_water = on_water
		return cloned
	
	func has_overlay(overlay: String) -> bool:
		return overlays.any(func(o: Overlay) -> bool: return o.image == overlay)
	
	class Overlay:
		var position: Vector2i
		var image: String
		
		func _init(p_position: Vector2, p_image: String):
			position = p_position
			image = p_image
		
		func get_texture() -> Texture2D:
			return Utils.load_texture(HWTheme.get_theme_path().path_join(image + ".png"))
		
		func get_rect() -> Rect2:
			return Rect2(position, get_texture().get_size())
