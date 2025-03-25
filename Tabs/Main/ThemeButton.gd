extends Button

var theme_dir: String

@onready var theme_name_label: Label = %Name
@onready var theme_icon: TextureRect = %Icon
@onready var theme_version: Label = %Version

func set_theme_dir(dir: String):
	theme_dir = dir
	var v := theme_dir.split("_v")
	
	
	theme_name_label.text = v[0]
	theme_icon.texture = Utils.load_texture(Utils.get_themes_directory().path_join(theme_dir).path_join("icon@2x.png"))
	if v.size() == 2:
		theme_version.text = str("v", v[1].to_int())
