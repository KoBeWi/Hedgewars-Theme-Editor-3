extends Button

var image: String

func _ready():
	custom_minimum_size.y = size.x

func set_image(path: String):
	%Texture.texture = Utils.load_texture(path)
	image = path.get_basename().get_file()
	%Label.text = image
