extends Control

var images := -1

func _ready():
	$Container/GeneralInfo.text = ""
	Utils.dir_watcher.files_created.connect(files_changed)
	Utils.dir_watcher.files_modified.connect(files_changed)
	Utils.dir_watcher.files_deleted.connect(files_changed)

func add_info(info: String):
	$Container/GeneralInfo.text += tr(info) + "\n"

func add_image(iname: String):
	images += 1
	
	if images > 0:
		$Container.add_child(get_image(0).duplicate())
	
	get_image(images).set_meta("image_name", iname)
	get_image(images).get_node("ImageHeader/ImageName").text = iname
	get_image(images).get_node("ImageInfo").text = ""
	
	update_image(images)
	
	get_image(images).get_node("Template/TemplateButton").pressed.connect(get_parent().fetch_template.bind(iname, self, images))
	get_parent().add_customizable_image(iname)

func add_image_info(info: String, format := []):
	var new_line = ("" if get_image(images).get_node("ImageInfo").text.length() == 0 else "\n")
	
	if format:
		info = tr(info) % format
	else:
		info = tr(info)
	
	get_image(images).get_node("ImageInfo").text += new_line + info

func get_image(i) -> Control:
	return $Container.get_child(i + 2) as Control

func update_image(idx: int):
	var image_container := get_image(idx)
	var tex := Utils.load_texture(HWTheme.get_theme_path().path_join(image_container.get_meta("image_name")), true)
	
	if tex:
		image_container.get_node("Image").texture = tex
		image_container.get_node("Template").hide()
	else:
		image_container.get_node("Image").texture = preload("uid://f5amv6ot7myy") # NoImage.png
		image_container.get_node("Template").show()

func files_changed(file_list: Array):
	for file in file_list:
		var file_name: String = file.get_file()
		for idx in images + 1:
			if get_image(idx).get_meta("image_name") == file_name:
				update_image(idx)
				break
