extends Label

@onready var base_text = text

func format(args: Variant):
	text = base_text % args
