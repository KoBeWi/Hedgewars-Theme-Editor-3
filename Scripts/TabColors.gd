extends Control

const colors = ["sky", "border", "water_top", "water_bottom", "sd_water_top", "sd_water_bottom", "sd_tint"]

func _ready():
	get_parent().name = tr("Colors")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$PickerContainer/UpperWater/ColorContainer/Color.connect("color_changed", self, "synchronize_water_alpha", [$PickerContainer/LowerWater/ColorContainer/Color])
	$PickerContainer/LowerWater/ColorContainer/Color.connect("color_changed", self, "synchronize_water_alpha", [$PickerContainer/UpperWater/ColorContainer/Color])
	$PickerContainer/SDUpperWater/ColorContainer/Color.connect("color_changed", self, "synchronize_water_alpha", [$PickerContainer/SDLowerWater/ColorContainer/Color])
	$PickerContainer/SDLowerWater/ColorContainer/Color.connect("color_changed", self, "synchronize_water_alpha", [$PickerContainer/SDUpperWater/ColorContainer/Color])
	
	for i in $PickerContainer.get_child_count():
		var picker = $PickerContainer.get_child(i)
		picker.get_node("Header/OnOff").connect("toggled", HWTheme, "change_property", [str(colors[i], "_defined")])
		picker.get_node("ColorContainer/Color").connect("color_changed", HWTheme, "change_property", [colors[i]])

func synchronize_water_alpha(new_color, twin):
	twin.color.a = new_color.a

func on_theme_loaded():
	for i in $PickerContainer.get_child_count():
		var picker = $PickerContainer.get_child(i)
		
		picker.get_node("Header/OnOff").pressed = HWTheme.get(str(colors[i], "_defined"))
		picker.get_node("ColorContainer/Color").color = HWTheme.get(colors[i])
