extends Control

var customizable_list = {}

func _ready():
	get_parent().name = tr("Customization")
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	
	$ItemLists/LeftMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Sprays/List])
	$ItemLists/LeftMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Sprays/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveLeft.connect("pressed", self, "move_item", [$ItemLists/Objects/List, $ItemLists/Other/List])
	$ItemLists/RightMove/MoveRight.connect("pressed", self, "move_item", [$ItemLists/Other/List, $ItemLists/Objects/List])

func on_theme_loaded():#TODO: sounds, error detection, jump to error
	$ItemLists/Sprays/List.clear()
	$ItemLists/Other/List.clear()
	$ItemLists/Objects/List.clear()
	
	for i in get_child_count() - 1:
		get_child(1).free()
	
	for s in HWTheme.sprays:
		$ItemLists/Sprays/List.add_item(s)
	
	for o in HWTheme.objects:
		$ItemLists/Objects/List.add_item(o)
	
	var customization
	
	customization = add_customization("Icon")
	customization.add_info("Themes without icon don't appear on in-game theme list")
	customization.add_image("icon.png")
	customization.add_image_info("Size: %s", ["33x32"])
	customization.add_image("icon@2x.png")
	customization.add_image_info("Size: %s", ["65x64"])
	
	customization = add_customization("Land texture")
	customization.add_info("Texture drawn as map's terrain")
	customization.add_info("This image is required")
	customization.add_image("LandTex.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Land back texture")
	customization.add_info("Visible when terrain is destroyed")
	customization.add_image("LandBackTex.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Border")
	customization.add_info("Painted arround terrain")
	customization.add_info("This image is required")
	customization.add_image("Border.png")
	customization.add_image_info("Size: %s", ["128x32"])
	customization.add_image_info("Two halves, top and bottom %s pix each", ["16"])
	
	customization = add_customization("Girder")
	customization.add_info("Land bridges")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("Girder.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Chunk")
	customization.add_info("Particles that fall when land is destroyed")
	customization.add_info("If not provided, no particles will appear")
	customization.add_image("Chunk.png")
	customization.add_image_info("Size: %s", ["64x64"])
	customization.add_image_info("Each particle is %s square", ["32x32"])
	
	customization = add_customization("Dust")
	customization.add_info("Particles that fall when something hits ground or mudball flies etc.")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("Dust.png")
	customization.add_image_info("Size: %s", ["22x176"])
	customization.add_image_info("Each particle is %s square", ["22x22"])
	
	customization = add_customization("Water")
	customization.add_info("Texture of water waves")
	customization.add_info("If not provided, a default image is used")
	customization.add_info("SD version is used during Sudden Death")
	customization.add_image("BlueWater.png")
	customization.add_image_info("Any size")
	customization.add_image_info("%s is preferred", ["128x48"])
	customization.add_image("SDWater.png")
	customization.add_image_info("Any size")
	customization.add_image_info("%s is preferred", ["128x48"])
	
	customization = add_customization("Splash and droplets")
	customization.add_info("Used when something hits water")
	customization.add_info("If not provided, a default image is used")
	customization.add_info("SD version is used during Sudden Death")
	customization.add_image("Splash.png")
	customization.add_image_info("Size: %s frames %s pix each", ["20", "80x50"])
	customization.add_image_info("Lined vertically in two columns")
	customization.add_image("Droplet.png")
	customization.add_image_info("Size: %s images %s pix each", ["4", "16x16"])
	customization.add_image_info("Lined vertically")
	customization.add_image("SDSplash.png")
	customization.add_image_info("Size: %s frames %s pix each", ["20", "80x50"])
	customization.add_image_info("Lined vertically in two columns")
	customization.add_image("SDDroplet.png")
	customization.add_image_info("Size: %s images %s pix each", ["4", "16x16"])
	customization.add_image_info("Lined vertically")
	
	customization = add_customization("Clouds")
	customization.add_info("Texture for clouds that appear on top of the map")
	customization.add_info("If not provided, a default image is used")
	customization.add_info("SD version is used during Sudden Death")
	customization.add_image("Clouds.png")
	customization.add_image_info("Size: %s for each cloud", ["256x128"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("Any number")
	customization.add_image("SDClouds.png")
	customization.add_image_info("Size: %s for each cloud", ["256x128"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("Any number")
	
	customization = add_customization("Flakes")
	customization.add_info("Texture for flakes that float in background")
	customization.add_info("SD version is used during Sudden Death")
	customization.add_image("Flake.png")
	customization.add_image_info("Size: %s for each flake", ["64x64"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("Game will crash if flakes are enabled and this image is missing")
	customization.add_image("SDFlake.png")
	customization.add_image_info("Size: %s for each flake", ["64x64"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("If not provided, a default image is used")
	
	customization = add_customization("Mirrored clouds/flakes")
	customization.add_info("Will replace their equivalents when wind is blowing left")
	customization.add_info("If not provided, flakes/clouds will always appear in one direction")
	customization.add_image("CloudsL.png")
	customization.add_image_info("Size: %s for each cloud", ["256x128"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("Any number")
	customization.add_image("SDCloudsL.png")
	customization.add_image_info("Size: %s for each cloud", ["256x128"])
	customization.add_image_info("Lined vertically")
	customization.add_image_info("Any number")
	customization.add_image("FlakeL.png")
	customization.add_image_info("Size: %s for each flake", ["64x64"])
	customization.add_image_info("Lined vertically")
	customization.add_image("SDFlakeL.png")
	customization.add_image_info("Size: %s for each flake", ["64x64"])
	customization.add_image_info("Lined vertically")
	
	customization = add_customization("Snow")
	customization.add_info("Texture for snow that accumulates on map when snow is enabled")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("Snow.png")
	customization.add_image_info("Must be at least 2 pixels wide to appear")
	customization.add_image_info("Height lower than 2 pixels will crash the game")
	
	customization = add_customization("Sky")
	customization.add_info("Map's background texture")
	customization.add_info("If not provided, no sky will appear")
	customization.add_image("Sky.png")
	customization.add_image_info("Any size")
	customization.add_image_info("Standard height is 512")
	
	customization = add_customization("Left/right sky")
	customization.add_info("If SkyL exists, Sky will be centered and SkyL will be looped on both sides")
	customization.add_info("If both SkyL and SkyR exist, Sky will be centered, SkyL will be looped on left side and SkyR on right side")
	customization.add_image("SkyL.png")
	customization.add_image_info("Any size")
	customization.add_image_info("Height preferrably the same as %s", ["Sky.png"])
	customization.add_image("SkyR.png")
	customization.add_image_info("Any size")
	customization.add_image_info("Height preferrably the same as %s", ["Sky.png"])
	
	customization = add_customization("Horizont")
	customization.add_info("Background layer between sky and terrain")
	customization.add_info("If not provided, no horizont will appear")
	customization.add_image("horizont.png")
	customization.add_image_info("Any size")
	
	customization = add_customization("Left/right horizont")
	customization.add_info("Same as SkyL/SkyR, but for horizont")
	customization.add_image("horizontL.png")
	customization.add_image_info("Any size")
	customization.add_image_info("Height preferrably the same as %s", ["horizont.png"])
	customization.add_image("horizontR.png")
	customization.add_image_info("Any size")
	customization.add_image_info("Height preferrably the same as %s", ["horizont.png"])
	
	customization = add_customization("Girder tool")
	customization.add_info("Used as a replacement for girder tool")
	customization.add_info("Any shape is allowed and will have proper collisions")
	customization.add_info("Use template if you want proper layout")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("amGirder.png")
	customization.add_image_info("%s grid of images", ["3x3"])
	customization.add_image_info("Each image is %s pix", ["160x160"])
	
	customization = add_customization("Rubber tool")
	customization.add_info("Used as a replacement for rubber tool")
	customization.add_info("Any shape is allowed and will have proper collisions")
	customization.add_info("Use template if you want proper layout")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("amRubber.png")
	customization.add_image_info("%s grid of images", ["2x2"])
	customization.add_image_info("Each image is %s pix", ["160x160"])
	
	customization = add_customization("Mudball weapon")
	customization.add_info("Used as a replacement for mudball weapon")
	customization.add_info("If not provided, a default image is used")
	customization.add_image("Snowball.png")
	customization.add_image_info("Size: %s", ["16x16"])
	customization.add_image("amSnowball.png")
	customization.add_image_info("Size: %s", ["128x128"])
	
	for file in HWTheme.image_list:
		if not file in customizable_list and not file in HWTheme.sprays and not file in HWTheme.objects:
			$ItemLists/Other/List.add_item(file)

func move_item(from, to):
	if from.get_item_count() == 0 or from.get_selected_items().size() == 0: return
	
	$ItemLists/LeftMove/MoveLeft.disabled = true
	$ItemLists/LeftMove/MoveRight.disabled = true
	$ItemLists/RightMove/MoveLeft.disabled = true
	$ItemLists/RightMove/MoveRight.disabled = true
	
	var item = from.get_selected_items()[0]
	var item_name = from.get_item_text(item)
	to.add_item(from.get_item_text(item))
	from.remove_item(item)
	
	if from == $ItemLists/Other/List and to == $ItemLists/Sprays/List:
		Util.emit_signal("object_modified", "spray+", item_name)
	elif from == $ItemLists/Sprays/List and to == $ItemLists/Other/List:
		Util.emit_signal("object_modified", "spray-", item_name)
	elif from == $ItemLists/Other/List and to == $ItemLists/Objects/List:
		Util.emit_signal("object_modified", "object+", item_name)
	elif from == $ItemLists/Objects/List and to == $ItemLists/Other/List:
		Util.emit_signal("object_modified", "object-", item_name)

func on_sprays_click(item):
	$ItemLists/Objects/List.unselect_all()
	$ItemLists/Other/List.unselect_all()
	$ItemLists/LeftMove/MoveLeft.disabled = true
	$ItemLists/LeftMove/MoveRight.disabled = false
	$ItemLists/RightMove/MoveLeft.disabled = true
	$ItemLists/RightMove/MoveRight.disabled = true

func on_other_click(item):
	$ItemLists/Sprays/List.unselect_all()
	$ItemLists/Objects/List.unselect_all()
	$ItemLists/LeftMove/MoveLeft.disabled = false
	$ItemLists/LeftMove/MoveRight.disabled = true
	$ItemLists/RightMove/MoveLeft.disabled = true
	$ItemLists/RightMove/MoveRight.disabled = false

func on_objects_click(item):
	$ItemLists/Sprays/List.unselect_all()
	$ItemLists/Other/List.unselect_all()
	$ItemLists/LeftMove/MoveLeft.disabled = true
	$ItemLists/LeftMove/MoveRight.disabled = true
	$ItemLists/RightMove/MoveLeft.disabled = false
	$ItemLists/RightMove/MoveRight.disabled = true

func add_customization(cname):
	var custom = preload("res://Nodes/CustomizationPanel.tscn").instance()
	add_child(custom)
	custom.get_node("Container/GroupName").text = tr(cname)
	return custom

func add_customizable_image(iname):
	customizable_list[iname] = true

func fetch_template(iname, customization, index):
	var dir = Directory.new()
	dir.copy(get_template_path(iname), HWTheme.get_theme_path() + iname)
	customization.update_image(index, iname)

func get_template_path(iname):
	match iname:
		"icon.png": return Util.hedgewars_path + "/Data/Themes/Nature/icon.png"
		"icon@2x.png": return Util.hedgewars_path + "/Data/Themes/Nature/icon@2x.png"
		"LandTex.png": return Util.hedgewars_path + "/Data/Themes/Nature/LandTex.png"
		"LandBackTex.png": return Util.hedgewars_path + "/Data/Themes/Nature/LandBackTex.png"
		"Border.png": return Util.hedgewars_path + "/Data/Themes/Jungle/Border.png"
		"Girder.png": return Util.hedgewars_path + "/Data/Graphics/Girder.png"
		"Chunk.png": return Util.hedgewars_path + "/Data/Themes/EarthRise/Chunk.png"
		"Dust.png": return Util.hedgewars_path + "/Data/Graphics/Dust.png"
		"BlueWater.png": return Util.hedgewars_path + "/Data/Graphics/BlueWater.png"
		"SDWater.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDWater.png"
		"Splash.png": return Util.hedgewars_path + "/Data/Graphics/Splash.png"
		"Droplet.png": return Util.hedgewars_path + "/Data/Graphics/Droplet.png"
		"SDSplash.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDSplash.png"
		"SDDroplet.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDDroplet.png"
		"Clouds.png": return Util.hedgewars_path + "/Data/Graphics/Clouds.png"
		"CloudsL.png": return Util.hedgewars_path + "/Data/Graphics/Clouds.png"#TODO: a proper template
		"SDClouds.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDClouds.png"
		"SDCloudsL.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDClouds.png"#TODO: a proper template
		"Flake.png": return Util.hedgewars_path + "/Data/Themes/Snow/Flake.png"
		"FlakeL.png": return Util.hedgewars_path + "/Data/Themes/Snow/Flake.png"#TODO: a proper template
		"SDFlake.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDFlake.png"
		"SDFlakeL.png": return Util.hedgewars_path + "/Data/Graphics/SuddenDeath/SDFlake.png"#TODO: a proper template
		"Snow.png": return Util.hedgewars_path + "/Data/Graphics/Snow.png"
		"Sky.png": return Util.hedgewars_path + "/Data/Themes/Castle/Sky.png"
		"SkyL.png": return Util.hedgewars_path + "/Data/Themes/Castle/SkyL.png"
		"SkyR.png": return Util.hedgewars_path + "/Data/Themes/Castle/SkyR.png"
		"horizont.png": return Util.hedgewars_path + "/Data/Themes/Bath/horizont.png"
		"horizontL.png": return Util.hedgewars_path + "/Data/Themes/Bath/horizontL.png"
		"horizontR.png": return Util.hedgewars_path + "/Data/Themes/Bath/horizontR.png"
		"amGirder.png": return Util.hedgewars_path + "/Data/Graphics/amGirder.png"
		"amRubber.png": return Util.hedgewars_path + "/Data/Graphics/amRubber.png"
		"Snowball.png": return Util.hedgewars_path + "/Data/Graphics/Snowball.png"
		"amSnowball.png": return Util.hedgewars_path + "/Data/Graphics/Hedgehog/amSnowball.png"
