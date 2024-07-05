extends VBoxContainer

@onready var preview_scene := $ViewportContainer/Viewport/PreviewScene as Node2D

func _ready() -> void:
	HWTheme.theme_loaded.connect(on_theme_loaded)

func on_theme_loaded():
	reload_scene()

func reload_scene():
	preview_scene.queue_free()
	preview_scene = preload("uid://b5yto2mbqnxbs").instantiate() # PreviewScene.tscn
	$ViewportContainer/Viewport.add_child(preview_scene)
	preview_scene.release_the_mouse.connect(release_mouse)

func refresh_preview() -> void:
	reload_scene()

func release_mouse():
	$ViewportContainer/Viewport.gui_disable_input = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
