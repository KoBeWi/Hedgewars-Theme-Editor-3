extends Panel

onready var image = $ObjectImage

var object
var original_object
var zoom = 1 setget set_zoom
var drag
var moved = false

func _ready():
	connect("resized", self, "move_view")
	$UI/Zoom.connect("value_changed", self, "set_zoom")
	$UI/Zoom.connect("resized", self, "set_zoom", [zoom])
	$UI/Container/Buttons/Apply.connect("pressed", self, "on_apply")
	$UI/Container/Buttons/Help.connect("pressed", self, "on_help")
	$UI/Container/Buttons/Revert.connect("pressed", self, "on_revert")
	
	set_zoom(1)
	move_view()
	original_object = object.duplicate(true)
	
	$UI/Container/Help.call_deferred("set_visible", false)

func _process(delta):
	if drag: image.position = drag + get_viewport().get_mouse_position()
	
	for rect in object.buried: if rect.has_point(image.mouse()): image.selected_rects.append(rect)
	for rect in object.visible: if rect.has_point(image.mouse()): image.selected_rects.append(rect)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				self.zoom = min(zoom + 0.5, 20)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				self.zoom = max(zoom - 0.5, 0)
			elif event.button_index == BUTTON_MIDDLE:
				drag = image.position - get_viewport().get_mouse_position()
				moved = false
		elif event.button_index == BUTTON_MIDDLE:
			drag = null
			if !moved: image.remove_rectangles()
		elif event.button_index == BUTTON_LEFT and image.drawing != null:
			object.visible.append(image.get_drawn_rectangle())
			image.stop_rectangle()
		elif event.button_index == BUTTON_RIGHT and image.drawing != null:
			object.buried.append(image.get_drawn_rectangle())
			image.stop_rectangle()
	
	if event is InputEventMouseMotion: moved = true

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				image.start_rectangle(false)
			elif event.button_index == BUTTON_RIGHT:
				image.start_rectangle(true)

func set_zoom(new_zoom):
	zoom = new_zoom
	image.scale = Vector2(new_zoom, new_zoom)
	
	$UI/Zoom.value = new_zoom
	$UI/Zoom/Label.text = str("x", zoom)
	$UI/Zoom/Label.rect_position.y = $UI/Zoom.rect_size.y - zoom/20.0 * ($UI/Zoom.rect_size.y-16) - 20
	$ObjectImage.update_checker()

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