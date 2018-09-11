extends Node

func load_texture(file):
	var image = Image.new()
	image.load(file)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture