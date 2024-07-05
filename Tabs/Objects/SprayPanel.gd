extends Control

var spray: String

func initialize():
	%Image.texture = Utils.load_texture(HWTheme.get_theme_path().path_join(spray + ".png"))
	
	%Amount.value = HWTheme.sprays[spray]
	%Amount.value_changed.connect(owner.update_spray_amount.bind(spray))
