extends Control

const colors = ["sky", "border", "water_top", "water_bottom", "sd_water_top", "sd_water_bottom"]

func _ready():
	get_parent().name = tr(get_parent().name)
	
#	Util.size_listeners.append(self)
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	$UpperWater/Color.connect("color_changed", self, "synchronize_water_alpha")
	$LowerWater/Color.connect("color_changed", self, "synchronize_water_alpha")

func synchronize_water_alpha(new_color):
	$UpperWater/Color.color.a = new_color.a
	$LowerWater/Color.color.a = new_color.a

func on_theme_loaded():
	for i in get_child_count():
		var picker = get_child(i)
		
		picker.get_node("Color").color = HWTheme.get(colors[i])