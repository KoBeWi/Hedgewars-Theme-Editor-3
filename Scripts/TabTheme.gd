extends Control

const COLORS = ["sky", "border", "water_top", "water_bottom", "sd_water_top", "sd_water_bottom", "sd_tint"]

var player_paused = null
var current_player

func _ready():
	get_parent().name = tr("Theme")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$Music/Play.connect("pressed", self, "play_music", [$Music/List])
	$SDMusic/Play.connect("pressed", self, "play_music", [$SDMusic/List])
	$FallbackMusic/Play.connect("pressed", self, "play_music", [$FallbackMusic/List])
	$FallbackSDMusic/Play.connect("pressed", self, "play_music", [$FallbackSDMusic/List])
	
	$Music/List.add_item(tr("/none/")) 
	$SDMusic/List.add_item(tr("/none/"))
	$FallbackMusic/List.add_item(tr("/none/")) 
	$FallbackSDMusic/List.add_item(tr("/none/"))
	
	$Music/List.add_separator()
	$SDMusic/List.add_separator()
	$FallbackMusic/List.add_separator()
	$FallbackSDMusic/List.add_separator()
	
	for music in Utils.list_directory(Utils.get_game_music_directory()):
		if music.get_extension() == "ogg":
			$Music/List.add_item(music.get_basename())
			$SDMusic/List.add_item(music.get_basename())
			$FallbackMusic/List.add_item(music.get_basename())
			$FallbackSDMusic/List.add_item(music.get_basename())
	
	$Music/List.add_separator()
	$SDMusic/List.add_separator()
	
	for music in Utils.list_directory(Utils.get_user_music_directory()): # TODO:refresh on directory change
		if music.get_extension() == "ogg":
			$Music/List.add_item(music.get_basename())
			$SDMusic/List.add_item(music.get_basename())
	
	$Music/List.connect("item_selected", HWTheme, "change_property_from_list", ["music", $Music/List])
	$SDMusic/List.connect("item_selected", HWTheme, "change_property_from_list", ["sd_music", $SDMusic/List])
	$FallbackMusic/List.connect("item_selected", HWTheme, "change_property_from_list", ["fallback_music", $FallbackMusic/List])
	$FallbackSDMusic/List.connect("item_selected", HWTheme, "change_property_from_list", ["fallback_sd_music", $FallbackSDMusic/List])
	
	
	$Colors/UpperWater/ColorPickerButton.connect("color_changed", self, "synchronize_water_alpha", [$Colors/LowerWater/ColorPickerButton])
	$Colors/LowerWater/ColorPickerButton.connect("color_changed", self, "synchronize_water_alpha", [$Colors/UpperWater/ColorPickerButton])
	$Colors/SDUpperWater/ColorPickerButton.connect("color_changed", self, "synchronize_water_alpha", [$Colors/SDLowerWater/ColorPickerButton])
	$Colors/SDLowerWater/ColorPickerButton.connect("color_changed", self, "synchronize_water_alpha", [$Colors/SDUpperWater/ColorPickerButton])
	
	for i in $Colors.get_child_count():
		var picker = $Colors.get_child(i)
		picker.get_node("OnOff").connect("toggled", HWTheme, "change_property", [str(COLORS[i], "_defined")])
		picker.get_node("ColorPickerButton").connect("color_changed", HWTheme, "change_property", [COLORS[i]])
	
	
	$CloudsOnOff.connect("toggled", HWTheme, "change_property", ["clouds_defined"])
	$Clouds/Amount.connect("value_changed", HWTheme, "change_property", ["clouds"])
	$SDCloudsOnOff.connect("toggled", HWTheme, "change_property", ["sd_clouds_defined"])
	$SDClouds/Amount.connect("value_changed", HWTheme, "change_property", ["sd_clouds"])
	
	$FlakesOnOff.connect("toggled", HWTheme, "change_property", ["flakes_defined"])
	$Flakes/Amount/Value.connect("value_changed", HWTheme, "change_property", ["flakes_amount"])
	$Flakes/Frames/Value.connect("value_changed", HWTheme, "change_property", ["flakes_frames"])
	$Flakes/FrameDuration/Value.connect("value_changed", HWTheme, "change_property", ["flakes_duration"])
	$Flakes/RotationSpeed/Value.connect("value_changed", HWTheme, "change_property", ["flakes_rotation"])
	$Flakes/FallingSpeed/Value.connect("value_changed", HWTheme, "change_property", ["flakes_speed"])
	
	$SDFlakesOnOff.connect("toggled", HWTheme, "change_property", ["sd_flakes_defined"])
	$SDFlakes/Amount/Value.connect("value_changed", HWTheme, "change_property", ["sd_flakes_amount"])
	$SDFlakes/Frames/Value.connect("value_changed", HWTheme, "change_property", ["sd_flakes_frames"])
	$SDFlakes/FrameDuration/Value.connect("value_changed", HWTheme, "change_property", ["sd_flakes_duration"])
	$SDFlakes/RotationSpeed/Value.connect("value_changed", HWTheme, "change_property", ["sd_flakes_rotation"])
	$SDFlakes/FallingSpeed/Value.connect("value_changed", HWTheme, "change_property", ["sd_flakes_speed"])
	
	$WaterAnimationOnOff.connect("toggled", HWTheme, "change_property", ["water_animation_defined"])
	$WaterAnimation/Frames/Value.connect("value_changed", HWTheme, "change_property", ["water_animation_frames"])
	$WaterAnimation/FrameDuration/Value.connect("value_changed", HWTheme, "change_property", ["water_animation_duration"])
	$WaterAnimation/MovementSpeed/Value.connect("value_changed", HWTheme, "change_property", ["water_animation_speed"])
	$SDWaterAnimationOnOff.connect("toggled", HWTheme, "change_property", ["sd_water_animation_defined"])
	$SDWaterAnimation/Frames/Value.connect("value_changed", HWTheme, "change_property", ["sd_water_animation_frames"])
	$SDWaterAnimation/FrameDuration/Value.connect("value_changed", HWTheme, "change_property", ["sd_water_animation_duration"])
	$SDWaterAnimation/MovementSpeed/Value.connect("value_changed", HWTheme, "change_property", ["sd_water_animation_speed"])
	
	$"%RopeStepDefined".connect("toggled", HWTheme, "change_property", ["rope_step_defined"])
	$"%RopeStepValue".connect("value_changed", HWTheme, "change_property", ["rope_step"])
	
	$Hidden.connect("toggled", HWTheme, "change_property", ["hidden"])
	$FlattenFlakes.connect("toggled", HWTheme, "change_property", ["flatten_flakes"])
	$FlattenClouds.connect("toggled", HWTheme, "change_property", ["flatten_clouds"])
	$Snow.connect("toggled", HWTheme, "change_property", ["snow"])
	$Ice.connect("toggled", HWTheme, "change_property", ["ice"])

func on_theme_loaded():
	$Header/Icon.texture = Utils.load_texture(HWTheme.get_theme_path().plus_file("icon.png"))
	$Header/Icon2x.texture = Utils.load_texture(HWTheme.get_theme_path().plus_file("icon@2x.png"))
	$Header/Name.text = HWTheme.basename()
	
	Utils.select_music($Music/List, HWTheme.music)
	Utils.select_music($SDMusic/List, HWTheme.sd_music)
	Utils.select_music($FallbackMusic/List, HWTheme.fallback_music)
	Utils.select_music($FallbackSDMusic/List, HWTheme.fallback_sd_music)
	
	for i in $Colors.get_child_count():
		var picker = $Colors.get_child(i)
		picker.get_node("OnOff").pressed = HWTheme.get(str(COLORS[i], "_defined"))
		picker.get_node("ColorPickerButton").color = HWTheme.get(COLORS[i])
	
	$CloudsOnOff.pressed = HWTheme.clouds_defined
	$Clouds/Amount.editable = HWTheme.clouds_defined
	$Clouds/Amount.value = HWTheme.clouds
	$SDCloudsOnOff.pressed = HWTheme.sd_clouds_defined
	$SDClouds/Amount.editable = HWTheme.sd_clouds_defined
	$SDClouds/Amount.value = HWTheme.clouds
	
	$FlakesOnOff.pressed = HWTheme.flakes_defined
	$Flakes/Amount/Value.editable = HWTheme.flakes_defined
	$Flakes/Frames/Value.editable = HWTheme.flakes_defined
	$Flakes/FrameDuration/Value.editable = HWTheme.flakes_defined
	$Flakes/RotationSpeed/Value.editable = HWTheme.flakes_defined
	$Flakes/FallingSpeed/Value.editable = HWTheme.flakes_defined
	$Flakes/Amount/Value.value = HWTheme.flakes_amount
	$Flakes/Frames/Value.value = HWTheme.flakes_frames
	$Flakes/FrameDuration/Value.value = HWTheme.flakes_duration
	$Flakes/RotationSpeed/Value.value = HWTheme.flakes_rotation
	$Flakes/FallingSpeed/Value.value = HWTheme.flakes_speed
	
	$SDFlakesOnOff.pressed = HWTheme.sd_flakes_defined
	$SDFlakes/Amount/Value.editable = HWTheme.sd_flakes_defined
	$SDFlakes/Frames/Value.editable = HWTheme.sd_flakes_defined
	$SDFlakes/FrameDuration/Value.editable = HWTheme.sd_flakes_defined
	$SDFlakes/RotationSpeed/Value.editable = HWTheme.sd_flakes_defined
	$SDFlakes/FallingSpeed/Value.editable = HWTheme.sd_flakes_defined
	$SDFlakes/Amount/Value.value = HWTheme.sd_flakes_amount
	$SDFlakes/Frames/Value.value = HWTheme.sd_flakes_frames
	$SDFlakes/FrameDuration/Value.value = HWTheme.sd_flakes_duration
	$SDFlakes/RotationSpeed/Value.value = HWTheme.sd_flakes_rotation
	$SDFlakes/FallingSpeed/Value.value = HWTheme.sd_flakes_speed
	
	$WaterAnimationOnOff.pressed = HWTheme.water_animation_defined
	$WaterAnimation/Frames/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/FrameDuration/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/MovementSpeed/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/Frames/Value.value = HWTheme.water_animation_frames
	$WaterAnimation/FrameDuration/Value.value = HWTheme.water_animation_duration
	$WaterAnimation/MovementSpeed/Value.value = HWTheme.water_animation_speed
	
	$SDWaterAnimationOnOff.pressed = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/Frames/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/FrameDuration/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/MovementSpeed/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/Frames/Value.value = HWTheme.sd_water_animation_frames
	$SDWaterAnimation/FrameDuration/Value.value = HWTheme.sd_water_animation_duration
	$SDWaterAnimation/MovementSpeed/Value.value = HWTheme.sd_water_animation_speed
	
	$"%RopeStepDefined".pressed = HWTheme.rope_step_defined
	$"%RopeStepValue".editable = HWTheme.rope_step_defined
	$"%RopeStepValue".value = HWTheme.rope_step
	
	$Hidden.pressed = HWTheme.hidden
	$FlattenFlakes.pressed = HWTheme.flatten_flakes
	$FlattenClouds.pressed = HWTheme.flatten_clouds
	$Snow.pressed = HWTheme.snow
	$Ice.pressed = HWTheme.ice

func play_music(player): #TODO: cache music on change, also handle change when paused
	if player == current_player:
		if $MusicPlayer.playing:
			$MusicPlayer.playing = false
			player_paused = $MusicPlayer.get_playback_position()
			return
		elif player_paused:
			$MusicPlayer.play(player_paused)
			return
	current_player = player
	
	var ogg_file = File.new()
	var file := Utils.get_game_music_directory().plus_file(player.get_item_text(player.selected) + ".ogg")
	if not ogg_file.file_exists(file):
		file = Utils.get_user_music_directory().plus_file(player.get_item_text(player.selected) + ".ogg")
	if not ogg_file.file_exists(file):
		return
	
	ogg_file.open(file, File.READ)
	
	var stream = AudioStreamOGGVorbis.new()
	stream.data = ogg_file.get_buffer(ogg_file.get_len())
	ogg_file.close()
	
	$MusicPlayer.stream = stream
	$MusicPlayer.play()

func stop_music():
	$MusicPlayer.stop()
	player_paused = false

func synchronize_water_alpha(new_color, twin):
	twin.color.a = new_color.a
