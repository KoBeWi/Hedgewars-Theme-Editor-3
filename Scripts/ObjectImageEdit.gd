extends Sprite

onready var edit := get_parent()

var drawing: Vector2
var selected_rects: Array
var was_selected: Array

func _ready():
	texture = Util.load_texture(str(HWTheme.path(), edit.object.name, ".png"))
	$Checker.region_rect.size = texture.get_size()
	drawing = edit.NO_DRAW

func _process(delta):
	if drawing != edit.NO_DRAW or not selected_rects.empty() or was_selected:
		update()

func _draw():
	draw_set_transform(origin(), 0, Vector2(1, 1))
	
	var intersecting := []
	for rect in edit.object.buried:
		var intersect = false
		for rect2 in edit.object.visible:
			if rect.intersects(rect2):
				intersect = true
				intersecting.append(rect2)
		
		var color = Color.yellow if rect in selected_rects else Color.magenta if intersect else Color.red
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color))
	
	for rect in edit.object.visible:
		var color = Color.yellow if rect in selected_rects else Color.magenta if rect in intersecting else Color.green
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color))
	
	if drawing != edit.NO_DRAW:
		var color := Color.green
		if edit.draw_mode == edit.BURIED:
			color = Color.red
		
		draw_rect(get_drawn_rectangle(), color, false)
		draw_rect(get_drawn_rectangle(), fill_color(color), true)
	
	draw_set_transform(Vector2(), 0, Vector2(1, 1))
	if not selected_rects.empty():
		was_selected = selected_rects.duplicate()
	else:
		was_selected = []
	selected_rects.clear()

func origin() -> Vector2:
	return -texture.get_size() / 2

func get_mouse_pos() -> Vector2:
	return (get_local_mouse_position() - origin()).floor()

func fill_color(color: Color):
	color.a = 0.25
	return color

func get_drawn_rectangle() -> Rect2:
	var mouse := get_mouse_pos()
	
	var start := Vector2(drawing.x if drawing.x < mouse.x else mouse.x, drawing.y if drawing.y < mouse.y else mouse.y)
	start.x = clamp(start.x, 0, texture.get_width() - 1)
	start.y = clamp(start.y, 0, texture.get_height() - 1)
	
	var end := Vector2(drawing.x if drawing.x > mouse.x else mouse.x, drawing.y if drawing.y > mouse.y else mouse.y)
	end.x = clamp(end.x, start.x + 1, texture.get_width())
	end.y = clamp(end.y, start.y + 1, texture.get_height())
	
	return Rect2(start, end - start)

func start_rectangle():
	drawing = get_mouse_pos()
	drawing.x = max(drawing.x, 0)
	drawing.y = max(drawing.y, 0)

func stop_rectangle():
	drawing = edit.NO_DRAW
	update()

func update_checker():
	$Checker.global_scale = Vector2(1, 1)
	$Checker.region_rect.size = texture.get_size() * scale

func remove_rectangles():
	if was_selected: for rect in was_selected:
		edit.object.visible.erase(rect)
		edit.object.buried.erase(rect)
