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
		elif not horizont_textureR:
			$Horizont/Left.texture = horizont_textureL
			$Horizont/Left.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			$Horizont/Right.texture = horizont_textureL
			$Horizont/Right.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
		else:
			$Horizont/Left.texture = horizont_textureL
			$Horizont/Left.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			$Horizont/Right.texture = horizont_textureR
			$Horizont/Right.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
		
		$Horizont.rect_size.x = PREVIEW_SIZE.x
		$Horizont.rect_size.y = horizont_texture.get_height()
		$Horizont.rect_position.y = PREVIEW_SIZE.y - horizont_texture.get_height()
	
	var cloud_texture := Util.load_texture(HWTheme.path() + "Clouds.png")
	if cloud_texture:
		$Clouds.texture = cloud_texture
		$Clouds.amount = HWTheme.clouds
		$Clouds.position.y = PREVIEW_SIZE.y / 2
		$Clouds.enable(PREVIEW_SIZE.x)

func steal_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$Arrow.position += event.relative
	
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("release_the_mouse")
