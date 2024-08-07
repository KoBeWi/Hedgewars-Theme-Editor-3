extends Sprite2D

@onready var edit := get_parent()

var drawing: Vector2

var selected_rects: Array
var intersecting_rects: Array

func _ready():
	texture = Utils.load_texture(HWTheme.get_theme_path().path_join(edit.object.name + ".png"))
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
	
	for overlay in edit.object.overlays:
		draw_texture(overlay.get_texture(), overlay.position)
		var rect = overlay.get_rect()
		var color := get_rect_color(rect, edit.Colors.OVERLAY)
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
	
	var start: Vector2 = global_transform.affine_inverse() * Vector2()
	var size := Vector2(999999999, 999999999)
	var center1 := get_mouse_pos().floor()
	var center2 := center1 + Vector2.ONE
	var cross_color := Color(1, 1, 1, 0.2)
	
	draw_rect(Rect2(start.x, center1.y, size.x, center2.y - center1.y), cross_color)
	draw_rect(Rect2(center1.x, start.y, center2.x - center1.x, size.y), cross_color)
	
	if edit.draw_mode == edit.OVERLAYS:
		if edit.current_overlay:
			draw_texture(edit.current_overlay, get_mouse_pos())
		else:
			draw_string(edit.get_theme_font(&"font", &"Label"), get_mouse_pos(), tr("Select overlay image"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, edit.get_theme_color(&"font_color", &"Label"))
	
	draw_set_transform(Vector2(), 0, Vector2(1, 1))

func update_selected():
	var old_selected := selected_rects
	selected_rects = []
	
	if is_drawing():
		queue_redraw()
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
	
	for overlay in edit.object.overlays:
		var rect = overlay.get_rect()
		if rect.has_point(get_mouse_pos()):
			selected_rects.append(rect)
	
	if old_selected != selected_rects:
		queue_redraw()

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
		return Color.WHITE
	elif rect in intersecting_rects:
		return Color.MAGENTA
	else:
		return default

func fill_color(color: Color):
	color.a = 0.25
	return color

func get_drawn_rectangle(clamped := true) -> Rect2:
	var mouse := get_mouse_pos()
	
	var start := Vector2(drawing.x if drawing.x < mouse.x else mouse.x, drawing.y if drawing.y < mouse.y else mouse.y)
	var end := Vector2(drawing.x if drawing.x > mouse.x else mouse.x, drawing.y if drawing.y > mouse.y else mouse.y) + Vector2.ONE
	
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
	queue_redraw()

func update_checker():
	$Checker.global_scale = Vector2(1, 1)
	$Checker.region_rect.size = texture.get_size() * scale

func remove_rectangles() -> bool:
	for rect in selected_rects:
		edit.object.visible.erase(rect)
		edit.object.buried.erase(rect)
		edit.object.anchors.erase(rect)
	
	var to_erase: Array
	for overlay in edit.object.overlays:
		if overlay.get_rect() in selected_rects:
			to_erase.append(overlay)
	
	for overlay in to_erase:
		edit.object.overlays.erase(overlay)
	
	return not selected_rects.is_empty()
