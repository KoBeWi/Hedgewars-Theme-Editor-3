extends VBoxContainer

@onready var object_container: VBoxContainer = %ObjectContainer
@onready var object_label: Label = %ObjectLabel
@onready var warning_label: Label = %WarningLabel
@onready var spray_container: VBoxContainer = %SprayContainer
@onready var spray_label: Label = %SprayLabel

func _ready():
	HWTheme.theme_loaded.connect(on_theme_loaded)
	Utils.object_modified.connect(on_object_modified)

func on_theme_loaded():
	for panel in object_container.get_children():
		panel.free()
	for panel in spray_container.get_children():
		panel.free()
	
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
			object = HWTheme.ThemeObject.new(object, 1)
			HWTheme.objects[object.name] = object
			var panel = add_object(object)
			object.buried.append(Rect2(Vector2(), panel.get_node("Container/Image").texture.get_size()))
		"object-":
			HWTheme.objects.erase(object)
			remove_object(object)
	
	HWTheme.apply_change()

func add_spray(spray):
	var panel = preload("uid://dgsrwg7c16473").instantiate() # SprayPanel.tscn
	panel.spray = spray
	spray_container.add_child(panel)
	panel.owner = self
	panel.initialize()
	return panel

func remove_spray(spray):
	pass
	#for i in spray_count:
		#if container.get_child(i).spray == spray:
			#container.get_child(i).queue_free()
			#spray_count -= 1
			#update_labels()
			#return

func add_object(object):
	var panel  = preload("uid://6jy66k3cxx4g").instantiate() # ObjectPanel.tscn
	panel.object = object
	object_container.add_child(panel)
	panel.owner = self
	panel.initialize()
	return panel

func remove_object(object):
	pass
	#for i in range(spray_count, container.get_child_count()):
		#if container.get_child(i).object.name == object:
			#container.get_child(i).queue_free()
			#object_count -= 1
			#update_labels()
			#return

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
	
	var object_edit = preload("uid://kju5d6s6yqbj").instantiate() # ObjectEdit.tscn
	object_edit.object = object
	$"/root".add_child(object_edit)
	get_tree().current_scene = object_edit
	
	$"/root".remove_child(Utils.temp_editor)

func update_labels():
	object_label.format(object_container.get_child_count())
	warning_label.visible = object_container.get_child_count() > 32
	spray_label.format(spray_container.get_child_count())
