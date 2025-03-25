extends Control

var object: HWTheme.ThemeObject

func initialize():
	%Image.texture = Utils.load_texture(HWTheme.get_theme_path().path_join(object.name + ".png"))
	
	%Amount.value = object.number
	%OnWater.button_pressed = (not object.buried.is_empty() and object.buried[0] == Rect2i())
	
	%EditObject.pressed.connect(owner.edit_object.bind(object))
	%Amount.value_changed.connect(owner.update_object_amount.bind(object.name))
	%OnWater.toggled.connect(owner.update_object_on_water.bind(object.name))
