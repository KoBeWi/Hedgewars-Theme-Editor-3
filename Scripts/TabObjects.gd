extends VBoxContainer

var spray_count = 0

func _ready():
	get_parent().name = tr("Objects")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	Util.connect("object_modified", self, "on_object_modified")
	
func on_theme_loaded():
	for panel in get_children(): panel.free()
	spray_count = 0
	
	for spray in HWTheme.sprays.keys():
		add_spray(spray)
	
	for object in HWTheme.objects.values():
		add_object(object)

func on_object_modified(operation, object):
	match operation:
		"spray+":
			add_spray(object)

func add_spray(spray):
	var panel = preload("res://Nodes/SprayPanel.tscn").instance()
	panel.spray = spray
	add_child_below_node(get_child(spray_count-1), panel)
	spray_count += 1

func add_object(object):
	var panel  = preload("res://Nodes/ObjectPanel.tscn").instance()
	panel.object = object
	add_child(panel)

func update_object_amount(amount, object):
	HWTheme.objects[object].number = amount
	HWTheme.apply_change()

func update_object_on_water(value, object):
	if !value:
		HWTheme.objects[object].buried.erase(Rect2())
	else:
		HWTheme.objects[object].buried.insert(0, Rect2())
	
	HWTheme.apply_change()

func update_spray_amount(amount, spray):
	HWTheme.sprays[spray] = amount
	HWTheme.apply_change()

func edit_object(object):
	Util.temp_editor = get_tree().current_scene
	
	var object_edit = preload("res://ObjectEdit.tscn").instance()
	object_edit.object = object
	$"/root".add_child(object_edit)
	get_tree().current_scene = object_edit
	
	$"/root".remove_child(Util.temp_editor)