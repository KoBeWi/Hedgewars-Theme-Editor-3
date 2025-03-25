extends Button

@onready var theme_name_label: Label = %Name
@onready var theme_icon: TextureRect = %Icon
@onready var theme_version: Label = %Version

func set_theme_dir(dir: String):
	var v := dir.split("_v")
	
	theme_name_label.text = v[0]
	theme_icon.texture = Utils.load_texture(Utils.get_themes_directory().path_join(dir).path_join("icon@2x.png"))
	if v.size() == 2:
		theme_version.text = str("v", v[1].to_int())

func get_theme_dir() -> String:
	if theme_version.text.is_empty():
		return theme_name_label.text
	else:
		return "_".join([theme_name_label.text, theme_version.text])
