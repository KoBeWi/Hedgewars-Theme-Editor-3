extends VBoxContainer

func _ready():
	get_parent().name = tr("Objects")
	Util.size_listeners.append(self)
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
func on_theme_loaded():
	for panel in get_children(): panel.free()
	
	for object in HWTheme.objects.values():
		var panel  = preload("res://Nodes/ObjectPanel.tscn").instance()
		panel.object = object
		add_child(panel)

func edit_object(object):
	Util.temp_editor = get_tree().current_scene
	
	var object_edit = preload("res://ObjectEdit.tscn").instance()
	object_edit.object = object
	$"/root".add_child(object_edit)
	get_tree().current_scene = object_edit
	
	$"/root".remove_child(Util.temp_editor)