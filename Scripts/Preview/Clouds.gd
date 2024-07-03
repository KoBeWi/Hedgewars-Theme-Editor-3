extends Node2D

class Cloud:
	var image: int
	var pos: Vector2

var texture: Texture2D
var amount: int
var clouds: Array

var draw_area_width: float

func _ready() -> void:
	set_process(false)

func enable(width: float):
	set_process(true)
	draw_area_width = width + 256
	
	var texture_count := texture.get_height() / 128
	for i in amount:
		var cloud := Cloud.new()
		cloud.image = randi() % texture_count
		cloud.pos = Vector2(randf_range(-256, draw_area_width), randf_range(-64, 64))
		clouds.append(cloud)

func _process(delta: float) -> void:
	update()

func _draw() -> void:
	for cloud in clouds:
		cloud.pos.x = wrapf(cloud.pos.x + 10, -256, draw_area_width)
		draw_texture_rect_region(texture, Rect2(cloud.pos, Vector2(256, 128)), Rect2(0, cloud.image * 128, 256, 128))
