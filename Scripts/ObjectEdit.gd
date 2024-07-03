extends Panel

const NO_DRAW = Vector2(-INF, -INF)
const Colors = {VISIBLE = Color.GREEN, BURIED = Color.RED, ANCHOR = Color.BLUE, OVERLAY = Color.YELLOW, SELECTED = Color.WHITE, INTERSECTING = Color.MAGENTA}

@onready var image := $ObjectImage as Sprite2D
@onready var overlays_container = $UI/Overlays/VBoxContainer/ScrollContainer/VBoxContainer
@onready var overlay_panel = $UI/Overlays

enum {VISIBLE, BURIED, ANCHORS, OVERLAYS}
var draw_mode: int

var object: HWTheme.ThemeObject
var original_object: HWTheme.ThemeObject
var zoom := 1.0: set = set_zoom
var drag: Vector2
var dirty: bool

var current_overlay: Texture2D
var current_overlay_name: String

func _ready():
	resized.connect(move_view)
	$UI/Zoom.resized.connect(set_zoom.bind(zoom))
	$UI/Help.hide()
	
	set_zoom(1)
	move_view()
	original_object = object.clone()
	
	var overlay_buttons := ButtonGroup.new()
	for image in HWTheme.image_list:
		var overlay_item := preload("res://Nodes/OverlayItem.tscn").instantiate() as Button
		overlay_item.set_image(HWTheme.get_theme_path().path_join(image + ".png"))
		overlay_item.button_group = overlay_buttons
		overlay_item.pressed.connect(select_overlay.bind(image))
		overlays_container.add_child(overlay_item)
	overlay_panel.hide()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if draw_mode == OVERLAYS:
					if current_overlay:
						dirty = true
						object.overlays.append(HWTheme.ThemeObject.Overlay.new(image.get_mouse_pos(), current_overlay_name))
				else:
					image.start_rectangle()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				self.zoom = min(zoom + 0.5, 20)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				self.zoom = max(zoom - 0.5, 1)
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				drag = image.position - get_viewport().get_mouse_position()
		else:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				drag = Vector2()
			elif event.button_index == MOUSE_BUTTON_LEFT and image.is_drawing():
				dirty = true
				match draw_mode:
					VISIBLE:
						object.visible.append(image.get_drawn_rectangle())
					BURIED:
						object.buried.append(image.get_drawn_rectangle())
					ANCHORS:
						object.anchors.append(image.get_drawn_rectangle(false))
				
				image.stop_rectangle()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if image.remove_rectangles():
					dirty = true
	elif event is InputEventMouseMotion:
		image.update_selected()
		image.queue_redraw()
		if drag:
			image.position = drag + get_viewport().get_mouse_position()

func set_zoom(new_zoom: float):
	zoom = new_zoom
	image.scale = Vector2(new_zoom, new_zoom)
	
	$UI/Zoom.value = new_zoom
	$UI/Zoom/Label.text = str("x", zoom)
	$UI/Zoom/Label.position.y = $UI/Zoom.size.y - zoom/20.0 * ($UI/Zoom.size.y - 16) - 16
	image.update_checker()
	image.queue_redraw()

func set_mode(mode: int):
	draw_mode = mode
	if mode == OVERLAYS:
		overlay_panel.show()
		for button in overlays_container.get_children():
			button.button_pressed = false
	else:
		overlay_panel.hide()
	image.queue_redraw()

func move_view():
	image.position = position + size / 2
	
func on_apply():
	HWTheme.apply_change()
	exit()

func on_help():
	$UI/Help.visible = not $UI/Help.visible

func on_revert():
	if dirty:
		$UI/ConfirmationDialog.popup_centered()
	else:
		do_revert()

func exit():
	queue_free()
	$"/root".add_child(Utils.temp_editor)
	get_tree().current_scene = Utils.temp_editor
	Utils.temp_editor = null

func do_revert():
	object.buried = original_object.buried
	object.visible = original_object.visible
	object.anchors = original_object.anchors
	object.overlays = original_object.overlays
	exit()

func select_overlay(image: String):
	current_overlay_name = image
	current_overlay = Utils.load_texture(HWTheme.get_theme_path().path_join(image + ".png"))
