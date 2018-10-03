extends Panel

var object
var zoom = 1 setget set_zoom
var drag

func _ready():
	$ObjectImage.texture = Util.load_texture(str(HWTheme.path(), object.name, ".png"))
	
	connect("resized", self, "move_view")
	$UI/Zoom.connect("value_changed", self, "set_zoom")
	$UI/Zoom.connect("resized", self, "set_zoom", [zoom])
	
	set_zoom(1)
	move_view()

func _process(delta):
	if drag: $ObjectImage.position = drag + get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				self.zoom = min(zoom + 0.5, 20)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				self.zoom = max(zoom - 0.5, 0)
			elif event.button_index == BUTTON_MIDDLE:
				drag = $ObjectImage.position - get_viewport().get_mouse_position()
		elif event.button_index == BUTTON_MIDDLE:
			drag = null
		elif event.button_index == BUTTON_LEFT:
			object.visible.append($ObjectImage.get_drawn_rectangle())
			$ObjectImage.stop_rectangle()
		elif event.button_index == BUTTON_RIGHT:
			object.buried.append($ObjectImage.get_drawn_rectangle())
			$ObjectImage.stop_rectangle()
		
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		queue_free()
		$"/root".add_child(Util.temp_editor)
		get_tree().current_scene = Util.temp_editor
		Util.temp_editor = null

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				$ObjectImage.start_rectangle(false)
			elif event.button_index == BUTTON_RIGHT:
				$ObjectImage.start_rectangle(true)

func set_zoom(new_zoom):
	zoom = new_zoom
	$ObjectImage.scale = Vector2(new_zoom, new_zoom)
	
	$UI/Zoom.value = new_zoom
	$UI/Zoom/Label.text = str("x", zoom)
	$UI/Zoom/Label.rect_position.y = $UI/Zoom.rect_size.y - zoom/20.0 * ($UI/Zoom.rect_size.y-16) - 20

func move_view():
	$ObjectImage.position = rect_position + rect_size/2