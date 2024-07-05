extends BoxContainer

@export var text: String
@export var edit_alpha: bool

@onready var on_off: CheckBox = $OnOff

func _ready():
	on_off.text = text
	$ColorPickerButton.edit_alpha = edit_alpha

func on_color_changed(color):
	on_off.button_pressed = true
