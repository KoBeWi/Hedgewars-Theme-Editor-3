extends VBoxContainer

var player_paused = null
var playing_sd

func _ready():
	name = tr(name)
	
	$CloudsHeader/OnOff.hint_tooltip = tr("When off, related key will not appear in theme.cfg")
	$SDCloudsHeader/OnOff.hint_tooltip = tr("When off, related key will not appear in theme.cfg")
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	$Music/Play.connect("pressed", self, "play_music", [false])
	$Music/Stop.connect("pressed", self, "stop_music")
	$SDMusic/Play.connect("pressed", self, "play_music", [true])
	$SDMusic/Stop.connect("pressed", self, "stop_music")
	
	for music in Util.list_directory(music_dir()):
		$Music/List.add_item(music.get_basename())
		$SDMusic/List.add_item(music.get_basename())

func on_theme_loaded():
	$Header/Icon.texture = Util.load_texture(HWTheme.path() + "icon.png")
	$Header/Icon2x.texture = Util.load_texture(HWTheme.path() + "icon@2x.png")
	$Header/Name.text = HWTheme.theme_name
	
	$CloudsHeader/OnOff.pressed = HWTheme.clouds_defined
	$Clouds/Amount.value = HWTheme.clouds
	$SDCloudsHeader/OnOff.pressed = HWTheme.sd_clouds_defined
	$SDClouds/Amount.value = HWTheme.clouds

func play_music(sd): #TODO: cache music on change, also handle pause on change
	if sd == playing_sd:
		if $MusicPlayer.playing:
			$MusicPlayer.playing = false
			player_paused = $MusicPlayer.get_playback_position()
			return
		elif player_paused:
			$MusicPlayer.play(player_paused)
			return
	
	playing_sd = sd
	var file = music_dir() + ($SDMusic/List.get_item_text($SDMusic/List.selected) if sd else $Music/List.get_item_text($Music/List.selected)) + ".ogg"
	
	var ogg_file = File.new()
	ogg_file.open(file, File.READ)
	
	var stream = AudioStreamOGGVorbis.new()
	stream.data = ogg_file.get_buffer(ogg_file.get_len())
	ogg_file.close()
	
	$MusicPlayer.stream = stream
	$MusicPlayer.play()

func stop_music():
	$MusicPlayer.stop()
	player_paused = false

func music_dir():
	return str(Util.hedgewars_path, "/Data/Music/")