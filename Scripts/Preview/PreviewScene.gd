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
	
	var sky_texture := Util.load_texture(HWTheme.path() + "Sky.png")
	if sky_texture:
		sky_texture.flags |= Texture.FLAG_REPEAT
		$Sky.texture = sky_texture
		$Sky.region_rect.size.x = PREVIEW_SIZE.x
		$Sky.region_rect.size.y = sky_texture.get_height()
		$Sky.position.y = PREVIEW_SIZE.y - sky_texture.get_height()
	
	var horizont_texture := Util.load_texture(HWTheme.path() + "horizont.png")
	var horizont_textureL := Util.load_texture(HWTheme.path() + "horizontL.png")
	var horizont_textureR := Util.load_texture(HWTheme.path() + "horizontR.png")
	if horizont_texture:
		horizont_texture.flags |= Texture.FLAG_REPEAT
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
		
		$Horizont.rect_size.x = PREVIEW_SIZE.x
		$Horizont.rect_size.y = horizont_texture.get_height()
		$Horizont.rect_position.y = PREVIEW_SIZE.y - horizont_texture.get_height()
	
	var cloud_texture := Util.load_texture(HWTheme.path() + "Clouds.png")
	if cloud_texture:
		$Clouds.texture = cloud_texture
		$Clouds.amount = HWTheme.clouds
		$Clouds.position.y = PREVIEW_SIZE.y / 2
		$Clouds.enable(PREVIEW_SIZE.x)
	
	var water_texture := Util.load_texture(HWTheme.path() + "BlueWater.png")
	if not water_texture:
		water_texture = Util.load_texture(Util.hedgewars_path + "Graphics/BlueWater.png")
	water_texture.flags |= Texture.FLAG_REPEAT
	
	$WaterGradient.material.set_shader_param("top_color", HWTheme.water_top)
	$WaterGradient.material.set_shader_param("water_bottom", HWTheme.water_bottom)
	$WaterGradient.rect_size.x = PREVIEW_SIZE.x
	$WaterGradient.rect_position.y = PREVIEW_SIZE.y - $WaterGradient.rect_size.y
	
	$Water.texture = water_texture
	$Water.region_rect = Rect2(0, 0, PREVIEW_SIZE.x, 48)
	$Water.position.y = PREVIEW_SIZE.y - $WaterGradient.rect_size.y - water_texture.get_height() * 0.5

func steal_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$Arrow.position += event.relative
	
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("release_the_mouse")
