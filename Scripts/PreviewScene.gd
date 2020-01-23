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

func steal_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$Arrow.position += event.relative
	
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("release_the_mouse")
