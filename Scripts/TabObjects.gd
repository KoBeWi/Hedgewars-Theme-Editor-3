extends VBoxContainer

onready var container: VBoxContainer = $Container
onready var object_label: Label = $ObjectLabel
onready var spray_label: Label = $SprayLabel
onready var warning_label: Label = $WarningLabel

var spray_count := 0
var object_count := 0

func _ready():
	get_parent().name = tr("Objects")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	Utils.connect("object_modified", self, "on_object_modified")

func on_theme_loaded():
	for panel in container.get_children():
		panel.free()
	spray_count = 0
	object_count = 0
	
	for spray in HWTheme.sprays.keys():
		add_spray(spray)
	
	for object in HWTheme.objects.values():
		add_object(object)
	
	update_labels()

func on_object_modified(operation, object):
	match operation:
		"spray+":
			HWTheme.sprays[object] = 1
			add_spray(object)
		"spray-":
			HWTheme.sprays.erase(object)
			remove_spray(object)
		"object+":
			object = {name = object, number = 1, buried = [], visible = [], on_water = false}
			HWTheme.objects[object.name] = object
			var panel = add_object(object)
			object.buried.append(Rect2(Vector2(), panel.get_node("Container/Image").texture.get_size()))
		"object-":
			HWTheme.objects.erase(object)
			remove_object(object)
	
	HWTheme.apply_change()

func add_spray(spray):
	var panel = preload("res://Nodes/SprayPanel.tscn").instance()
	panel.spray = spray
	if spray_count > 0:
		container.add_child_below_node(container.get_child(spray_count-1), panel) # TODO this can just use 2 containers
	else:
		container.add_child(panel)
		container.move_child(panel, 0)
	spray_count += 1
	update_labels()
	return panel

func remove_spray(spray):
	for i in spray_count:
		if container.get_child(i).spray == spray:
			container.get_child(i).queue_free()
			spray_count -= 1
			update_labels()
			return

func add_object(object):
	var panel  = preload("res://Nodes/ObjectPanel.tscn").instance()
	panel.object = object
	container.add_child(panel)
	object_count += 1
	update_labels()
	return panel

func remove_object(object):
	for i in range(spray_count, container.get_child_count()):
		if container.get_child(i).object.name == object:
			container.get_child(i).queue_free()
			object_count -= 1
			update_labels()
			return

func update_object_amount(amount, object):
	HWTheme.objects[object].number = amount
	HWTheme.apply_change()

func update_object_on_water(value, object):
	if not value:
		HWTheme.objects[object].buried.erase(Rect2())
	else:
		HWTheme.objects[object].buried.insert(0, Rect2())
	
	HWTheme.apply_change()

func update_spray_amount(amount, spray):
	HWTheme.sprays[spray] = amount
	HWTheme.apply_change()

func edit_object(object):
	Utils.temp_editor = get_tree().current_scene
	
	var object_edit = preload("res://ObjectEdit.tscn").instance()
	object_edit.object = object
	$"/root".add_child(object_edit)
	get_tree().current_scene = object_edit
	
	$"/root".remove_child(Utils.temp_editor)

func update_labels():
	object_label.format(object_count)
	spray_label.format(spray_count)
	warning_label.visible = object_count > 32
