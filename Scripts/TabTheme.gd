extends Control

const COLORS = ["sky", "border", "water_top", "water_bottom", "sd_water_top", "sd_water_bottom", "sd_tint"]

var player_paused = null
var current_player

func _ready():
	get_parent().name = tr("Theme")
	HWTheme.theme_loaded.connect(on_theme_loaded)
	
	$Music/Play.pressed.connect(play_music.bind($Music/List))
	$SDMusic/Play.pressed.connect(play_music.bind($SDMusic/List))
	$FallbackMusic/Play.pressed.connect(play_music.bind($FallbackMusic/List))
	$FallbackSDMusic/Play.pressed.connect(play_music.bind($FallbackSDMusic/List))
	
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
	
	$Music/List.item_selected.connect(HWTheme.change_property_from_list.bind("music", $Music/List))
	$SDMusic/List.item_selected.connect(HWTheme.change_property_from_list.bind("sd_music", $SDMusic/List))
	$FallbackMusic/List.item_selected.connect(HWTheme.change_property_from_list.bind("fallback_music", $FallbackMusic/List))
	$FallbackSDMusic/List.item_selected.connect(HWTheme.change_property_from_list.bind("fallback_sd_music", $FallbackSDMusic/List))
	
	
	$Colors/UpperWater/ColorPickerButton.color_changed.connect(synchronize_water_alpha.bind($Colors/LowerWater/ColorPickerButton))
	$Colors/LowerWater/ColorPickerButton.color_changed.connect(synchronize_water_alpha.bind($Colors/UpperWater/ColorPickerButton))
	$Colors/SDUpperWater/ColorPickerButton.color_changed.connect(synchronize_water_alpha.bind($Colors/SDLowerWater/ColorPickerButton))
	$Colors/SDLowerWater/ColorPickerButton.color_changed.connect(synchronize_water_alpha.bind($Colors/SDUpperWater/ColorPickerButton))
	
	for i in $Colors.get_child_count():
		var picker = $Colors.get_child(i)
		picker.get_node("OnOff").toggled.connect(HWTheme.change_property.bind(str(COLORS[i], "_defined")))
		picker.get_node("ColorPickerButton").color_changed.connect(HWTheme.change_property.bind(COLORS[i]))
	
	
	$CloudsOnOff.toggled.connect(HWTheme.change_property.bind("clouds_defined"))
	$Clouds/Amount.value_changed.connect(HWTheme.change_property.bind("clouds"))
	$SDCloudsOnOff.toggled.connect(HWTheme.change_property.bind("sd_clouds_defined"))
	$SDClouds/Amount.value_changed.connect(HWTheme.change_property.bind("sd_clouds"))
	
	$FlakesOnOff.toggled.connect(HWTheme.change_property.bind("flakes_defined"))
	$Flakes/Amount/Value.value_changed.connect(HWTheme.change_property.bind("flakes_amount"))
	$Flakes/Frames/Value.value_changed.connect(HWTheme.change_property.bind("flakes_frames"))
	$Flakes/FrameDuration/Value.value_changed.connect(HWTheme.change_property.bind("flakes_duration"))
	$Flakes/RotationSpeed/Value.value_changed.connect(HWTheme.change_property.bind("flakes_rotation"))
	$Flakes/FallingSpeed/Value.value_changed.connect(HWTheme.change_property.bind("flakes_speed"))
	
	$SDFlakesOnOff.toggled.connect(HWTheme.change_property.bind("sd_flakes_defined"))
	$SDFlakes/Amount/Value.value_changed.connect(HWTheme.change_property.bind("sd_flakes_amount"))
	$SDFlakes/Frames/Value.value_changed.connect(HWTheme.change_property.bind("sd_flakes_frames"))
	$SDFlakes/FrameDuration/Value.value_changed.connect(HWTheme.change_property.bind("sd_flakes_duration"))
	$SDFlakes/RotationSpeed/Value.value_changed.connect(HWTheme.change_property.bind("sd_flakes_rotation"))
	$SDFlakes/FallingSpeed/Value.value_changed.connect(HWTheme.change_property.bind("sd_flakes_speed"))
	
	$WaterAnimationOnOff.toggled.connect(HWTheme.change_property.bind("water_animation_defined"))
	$WaterAnimation/Frames/Value.value_changed.connect(HWTheme.change_property.bind("water_animation_frames"))
	$WaterAnimation/FrameDuration/Value.value_changed.connect(HWTheme.change_property.bind("water_animation_duration"))
	$WaterAnimation/MovementSpeed/Value.value_changed.connect(HWTheme.change_property.bind("water_animation_speed"))
	$SDWaterAnimationOnOff.toggled.connect(HWTheme.change_property.bind("sd_water_animation_defined"))
	$SDWaterAnimation/Frames/Value.value_changed.connect(HWTheme.change_property.bind("sd_water_animation_frames"))
	$SDWaterAnimation/FrameDuration/Value.value_changed.connect(HWTheme.change_property.bind("sd_water_animation_duration"))
	$SDWaterAnimation/MovementSpeed/Value.value_changed.connect(HWTheme.change_property.bind("sd_water_animation_speed"))
	
	$"%RopeStepDefined".toggled.connect(HWTheme.change_property.bind("rope_step_defined"))
	$"%RopeStepValue".value_changed.connect(HWTheme.change_property.bind("rope_step"))
	
	$Hidden.toggled.connect(HWTheme.change_property.bind("hidden"))
	$FlattenFlakes.toggled.connect(HWTheme.change_property.bind("flatten_flakes"))
	$FlattenClouds.toggled.connect(HWTheme.change_property.bind("flatten_clouds"))
	$Snow.toggled.connect(HWTheme.change_property.bind("snow"))
	$Ice.toggled.connect(HWTheme.change_property.bind("ice"))

func on_theme_loaded():
	$Header/Icon.texture = Utils.load_texture(HWTheme.get_theme_path().path_join("icon.png"))
	$Header/Icon2x.texture = Utils.load_texture(HWTheme.get_theme_path().path_join("icon@2x.png"))
	$Header/Name.text = HWTheme.basename()
	
	Utils.select_music($Music/List, HWTheme.music)
	Utils.select_music($SDMusic/List, HWTheme.sd_music)
	Utils.select_music($FallbackMusic/List, HWTheme.fallback_music)
	Utils.select_music($FallbackSDMusic/List, HWTheme.fallback_sd_music)
	
	for i in $Colors.get_child_count():
		var picker = $Colors.get_child(i)
		picker.get_node("OnOff").button_pressed = HWTheme.get(str(COLORS[i], "_defined"))
		picker.get_node("ColorPickerButton").color = HWTheme.get(COLORS[i])
	
	$CloudsOnOff.button_pressed = HWTheme.clouds_defined
	$Clouds/Amount.editable = HWTheme.clouds_defined
	$Clouds/Amount.value = HWTheme.clouds
	$SDCloudsOnOff.button_pressed = HWTheme.sd_clouds_defined
	$SDClouds/Amount.editable = HWTheme.sd_clouds_defined
	$SDClouds/Amount.value = HWTheme.clouds
	
	$FlakesOnOff.button_pressed = HWTheme.flakes_defined
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
	
	$SDFlakesOnOff.button_pressed = HWTheme.sd_flakes_defined
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
	
	$WaterAnimationOnOff.button_pressed = HWTheme.water_animation_defined
	$WaterAnimation/Frames/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/FrameDuration/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/MovementSpeed/Value.editable = HWTheme.water_animation_defined
	$WaterAnimation/Frames/Value.value = HWTheme.water_animation_frames
	$WaterAnimation/FrameDuration/Value.value = HWTheme.water_animation_duration
	$WaterAnimation/MovementSpeed/Value.value = HWTheme.water_animation_speed
	
	$SDWaterAnimationOnOff.button_pressed = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/Frames/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/FrameDuration/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/MovementSpeed/Value.editable = HWTheme.sd_water_animation_defined
	$SDWaterAnimation/Frames/Value.value = HWTheme.sd_water_animation_frames
	$SDWaterAnimation/FrameDuration/Value.value = HWTheme.sd_water_animation_duration
	$SDWaterAnimation/MovementSpeed/Value.value = HWTheme.sd_water_animation_speed
	
	$"%RopeStepDefined".button_pressed = HWTheme.rope_step_defined
	$"%RopeStepValue".editable = HWTheme.rope_step_defined
	$"%RopeStepValue".value = HWTheme.rope_step
	
	$Hidden.button_pressed = HWTheme.hidden
	$FlattenFlakes.button_pressed = HWTheme.flatten_flakes
	$FlattenClouds.button_pressed = HWTheme.flatten_clouds
	$Snow.button_pressed = HWTheme.snow
	$Ice.button_pressed = HWTheme.ice

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
	
	# TODO: set path in metadata
	var file := Utils.get_game_music_directory().path_join(player.get_item_text(player.selected) + ".ogg")
	if not FileAccess.file_exists(file):
		file = Utils.get_user_music_directory().path_join(player.get_item_text(player.selected) + ".ogg")
	if not FileAccess.file_exists(file):
		return
	
	$MusicPlayer.stream = AudioStreamOggVorbis.load_from_file(file)
	$MusicPlayer.play()

func stop_music():
	$MusicPlayer.stop()
	player_paused = false

func synchronize_water_alpha(new_color, twin):
	twin.color.a = new_color.a
