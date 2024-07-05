extends SubViewportContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$SubViewport.gui_disable_input = false
			get_parent().preview_scene.steal_mouse()
