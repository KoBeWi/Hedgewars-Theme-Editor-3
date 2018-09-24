extends Control

const colors = ["sky", "border", "water_top", "water_bottom", "sd_water_top", "sd_water_bottom"]

func _ready():
	name = tr(name)
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	$Container/UpperWater/Color.connect("color_changed", self, "synchronize_water_alpha")
	$Container/LowerWater/Color.connect("color_changed", self, "synchronize_water_alpha")

func synchronize_water_alpha(new_color):
	$Container/UpperWater/Color.color.a = new_color.a
	$Container/LowerWater/Color.color.a = new_color.a

func on_theme_loaded():
	for i in $Container.get_child_count():
		var picker = $Container.get_child(i)
		
		picker.get_node("Color").color = HWTheme.get(colors[i])