extends VBoxContainer

onready var preview_scene := $ViewportContainer/Viewport/PreviewScene as Node2D

func _ready() -> void:
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")

func on_theme_loaded():
	reload_scene()

func reload_scene():
	preview_scene.queue_free()
	preview_scene = preload("res://Nodes/PreviewScene.tscn").instance()
	$ViewportContainer/Viewport.add_child(preview_scene)
	preview_scene.connect("release_the_mouse", self, "release_mouse")

func refresh_preview() -> void:
	reload_scene()

func release_mouse():
	$ViewportContainer/Viewport.gui_disable_input = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
