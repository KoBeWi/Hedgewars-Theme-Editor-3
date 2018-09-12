extends VBoxContainer

func _ready():
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	$Music/Play.connect("pressed", self, "play_music")
	$Music/Stop.connect("pressed", self, "stop_music")
	
	for music in Util.list_directory(music_dir()):
		$Music/List.add_item(music.get_basename())

func on_theme_loaded():
	$Header/Icon.texture = Util.load_texture(HWTheme.path() + "icon.png")
	$Header/Icon2x.texture = Util.load_texture(HWTheme.path() + "icon@2x.png")
	$Header/Name.text = HWTheme.theme_name

func play_music(): #TODO: cache music on change, pause
	var file = music_dir() + $Music/List.get_item_text($Music/List.selected) + ".ogg"
	
	var ogg_file = File.new()
	ogg_file.open(file, File.READ)
	
	var stream = AudioStreamOGGVorbis.new()
	stream.data = ogg_file.get_buffer(ogg_file.get_len())
	ogg_file.close()
	
	$Music/Player.stream = stream
	$Music/Player.play()

func stop_music():
	$Music/Player.stop()

func music_dir():
	return str(Util.hedgewars_path, "/Data/Music/")