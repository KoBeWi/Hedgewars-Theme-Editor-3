extends VBoxContainer

func _ready():
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	for music in Util.list_directory(str(Util.hedgewars_path, "/Data/Music")):
		$Music/List.add_item(music.get_basename())

func on_theme_loaded():
	$Header/Icon.texture = Util.load_texture(Util.theme_path() + "icon.png")
	$Header/Icon2x.texture = Util.load_texture(Util.theme_path() + "icon@2x.png")
	$Header/Name.text = HWTheme.theme_name