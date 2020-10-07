extends Sprite

onready var edit := get_parent()

var drawing: Vector2

var selected_rects: Array
var intersecting_rects: Array

func _ready():
	texture = Util.load_texture(str(HWTheme.path(), edit.object.name, ".png"))
	$Checker.region_rect.size = texture.get_size()
	drawing = edit.NO_DRAW

func _draw():
	draw_set_transform(get_origin(), 0, Vector2(1, 1))
	update_intersecting()
	
	for rect in edit.object.buried:
		var color := get_rect_color(rect, edit.Colors.BURIED)
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color))
	
	for rect in edit.object.visible:
		var color := get_rect_color(rect, edit.Colors.VISIBLE)
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color))
	
	for rect in edit.object.anchors:
		var color := get_rect_color(rect, edit.Colors.ANCHOR)
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color))
	
	if is_drawing():
		var color: Color = edit.Colors.VISIBLE
		if edit.draw_mode == edit.BURIED:
			color = edit.Colors.BURIED
		elif edit.draw_mode == edit.ANCHORS:
			color = edit.Colors.ANCHOR
		
		var rect := get_drawn_rectangle(edit.draw_mode != edit.ANCHORS)
		draw_rect(rect, color, false)
		draw_rect(rect, fill_color(color), true)
	
	draw_set_transform(Vector2(), 0, Vector2(1, 1))

func update_selected():
	var old_selected := selected_rects
	selected_rects = []
	
	if is_drawing():
		update()
		return
	
	for rect in edit.object.buried:
		if rect.has_point(get_mouse_pos()):
			selected_rects.append(rect)
	
	for rect in edit.object.visible:
		if rect.has_point(get_mouse_pos()):
			selected_rects.append(rect)
	
	for rect in edit.object.anchors:
		if rect.has_point(get_mouse_pos()):
			selected_rects.append(rect)
	
	if old_selected != selected_rects:
		update()

func update_intersecting():
	intersecting_rects.clear()
	
	for rect in edit.object.visible:
		var intersecting: bool
		
		for rect2 in edit.object.buried:
			if rect.intersects(rect2):
				intersecting = true
				intersecting_rects.append(rect2)
		
		for rect2 in edit.object.anchors:
			if rect.intersects(rect2):
				intersecting = true
				intersecting_rects.append(rect2)
		
		if intersecting:
			intersecting_rects.append(rect)

func get_origin() -> Vector2:
	return -texture.get_size() / 2

func get_mouse_pos() -> Vector2:
	return (get_local_mouse_position() - get_origin()).floor()

func get_rect_color(rect: Rect2, default: Color) -> Color:
	if rect in selected_rects:
		return Color.white
	elif rect in intersecting_rects:
		return Color.magenta
	else:
		return default

func fill_color(color: Color):
	color.a = 0.25
	return color

func get_drawn_rectangle(clamped := true) -> Rect2:
	var mouse := get_mouse_pos()
	
	var start := Vector2(drawing.x if drawing.x < mouse.x else mouse.x, drawing.y if drawing.y < mouse.y else mouse.y)
	var end := Vector2(drawing.x if drawing.x > mouse.x else mouse.x, drawing.y if drawing.y > mouse.y else mouse.y)
	
	if clamped:
		start.x = clamp(start.x, 0, texture.get_width() - 1)
		start.y = clamp(start.y, 0, texture.get_height() - 1)
		end.x = clamp(end.x, start.x + 1, texture.get_width())
		end.y = clamp(end.y, start.y + 1, texture.get_height())
	
	return Rect2(start, end - start)

func start_rectangle():
	drawing = get_mouse_pos()
	update_selected()

func is_drawing() -> bool:
	return drawing != edit.NO_DRAW

func stop_rectangle():
	drawing = edit.NO_DRAW
	update()

func update_checker():
	$Checker.global_scale = Vector2(1, 1)
	$Checker.region_rect.size = texture.get_size() * scale

func remove_rectangles():
	for rect in selected_rects:
		edit.object.visible.erase(rect)
		edit.object.buried.erase(rect)
		edit.object.anchors.erase(rect)
