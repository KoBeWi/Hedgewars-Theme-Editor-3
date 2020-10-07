extends Panel

const NO_DRAW = Vector2(-1, -1)

onready var image := $ObjectImage as Sprite

enum {VISIBLE, BURIED, ANCHORS, OVERLAYS}
var draw_mode: int

var object: Dictionary
var original_object: Dictionary
var zoom := 1.0 setget set_zoom
var drag: Vector2

func _ready():
	connect("resized", self, "move_view")
	$UI/Zoom.connect("resized", self, "set_zoom", [zoom])
	
	set_zoom(1)
	move_view()
	original_object = object.duplicate(true)
	
func _process(delta: float):#TODO: some label with cursor pixel position
	if drag:
		image.position = drag + get_viewport().get_mouse_position()
	
	for rect in object.buried:
		if rect.has_point(image.get_mouse_pos()):
			image.selected_rects.append(rect)
	
	for rect in object.visible:
		if rect.has_point(image.get_mouse_pos()):
			image.selected_rects.append(rect)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				image.start_rectangle()
			elif event.button_index == BUTTON_WHEEL_UP:
				self.zoom = min(zoom + 0.5, 20)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				self.zoom = max(zoom - 0.5, 0)
			elif event.button_index == BUTTON_MIDDLE:
				drag = image.position - get_viewport().get_mouse_position()
		else:
			if event.button_index == BUTTON_MIDDLE:
				drag = Vector2()
			elif event.button_index == BUTTON_LEFT and image.drawing != NO_DRAW:
				if draw_mode == VISIBLE:
					object.visible.append(image.get_drawn_rectangle())
				elif draw_mode == BURIED:
					object.buried.append(image.get_drawn_rectangle())
				
				image.stop_rectangle()
			elif event.button_index == BUTTON_RIGHT:
				image.remove_rectangles()

func set_zoom(new_zoom: float):
	zoom = new_zoom
	image.scale = Vector2(new_zoom, new_zoom)
	
	$UI/Zoom.value = new_zoom
	$UI/Zoom/Label.text = str("x", zoom)
	$UI/Zoom/Label.rect_position.y = $UI/Zoom.rect_size.y - zoom/20.0 * ($UI/Zoom.rect_size.y-16) - 16
	$ObjectImage.update_checker()

func set_mode(mode: int):
	draw_mode = mode

func move_view():
	image.position = rect_position + rect_size/2
	
func on_apply():
	HWTheme.apply_change()
	exit()

func on_help():
	$UI/Container/Help.visible = !$UI/Container/Help.visible

func on_revert():
	object.buried = original_object.buried
	object.visible = original_object.visible
	exit()

func exit():
	queue_free()
	$"/root".add_child(Util.temp_editor)
	get_tree().current_scene = Util.temp_editor
	Util.temp_editor = null
