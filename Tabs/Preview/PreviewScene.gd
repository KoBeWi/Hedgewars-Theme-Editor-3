extends Node2D

const PREVIEW_SIZE = Vector2(4096, 2048)

signal release_the_mouse()

func _ready() -> void:
	if not HWTheme.theme_name:
		return
	
	$Arrow/Camera2D.limit_left = 0
	$Arrow/Camera2D.limit_right = PREVIEW_SIZE.x
	$Arrow/Camera2D.limit_top = 0
	$Arrow/Camera2D.limit_bottom = PREVIEW_SIZE.y
	$SkyCanvas/SkyColor.color = HWTheme.sky
	
	var sky_texture := Utils.load_texture(HWTheme.get_theme_path().path_join("Sky.png"))
	if sky_texture:
		#sky_texture.flags |= Texture2D.FLAG_REPEAT
		$Sky.texture = sky_texture
		$Sky.region_rect.size.x = PREVIEW_SIZE.x
		$Sky.region_rect.size.y = sky_texture.get_height()
		$Sky.position.y = PREVIEW_SIZE.y - sky_texture.get_height()
	
	var horizont_texture := Utils.load_texture(HWTheme.get_theme_path().path_join("horizont.png"))
	var horizont_textureL := Utils.load_texture(HWTheme.get_theme_path().path_join("horizontL.png"))
	var horizont_textureR := Utils.load_texture(HWTheme.get_theme_path().path_join("horizontR.png"))
	if horizont_texture:
		#horizont_texture.flags |= Texture2D.FLAG_REPEAT
		$Horizont/Middle.texture = horizont_texture
		if not horizont_textureL:
			$Horizont/Middle.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			$Horizont/Left.size_flags_horizontal |= Control.SIZE_FILL
			$Horizont/Right.size_flags_horizontal |= Control.SIZE_FILL
		elif not horizont_textureR:
			$Horizont/Left.texture = horizont_textureL
			$Horizont/Right.texture = horizont_textureL
		else:
			$Horizont/Left.texture = horizont_textureL
			$Horizont/Right.texture = horizont_textureR
		
		$Horizont.size.x = PREVIEW_SIZE.x
		$Horizont.size.y = horizont_texture.get_height()
		$Horizont.position.y = PREVIEW_SIZE.y - horizont_texture.get_height()
	
	var cloud_texture := Utils.load_texture(HWTheme.get_theme_path().path_join("Clouds.png"))
	if cloud_texture:
		$Clouds.texture = cloud_texture
		$Clouds.amount = HWTheme.clouds
		$Clouds.position.y = PREVIEW_SIZE.y / 2
		$Clouds.enable(PREVIEW_SIZE.x)
	
	var water_texture := Utils.load_texture(HWTheme.get_theme_path().path_join("BlueWater.png"))
	if not water_texture:
		water_texture = Utils.load_texture(Utils.hedgewars_path.path_join("Graphics/BlueWater.png"))
	#water_texture.flags |= Texture2D.FLAG_REPEAT
	
	$WaterGradient.material.set_shader_parameter("top_color", HWTheme.water_top)
	$WaterGradient.material.set_shader_parameter("water_bottom", HWTheme.water_bottom)
	$WaterGradient.size.x = PREVIEW_SIZE.x
	$WaterGradient.position.y = PREVIEW_SIZE.y - $WaterGradient.size.y
	
	$Water.texture = water_texture
	$Water.region_rect = Rect2(0, 0, PREVIEW_SIZE.x, 48)
	$Water.position.y = PREVIEW_SIZE.y - $WaterGradient.size.y - water_texture.get_height() * 0.5

func steal_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$Arrow.position += event.relative
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			release_the_mouse.emit()
