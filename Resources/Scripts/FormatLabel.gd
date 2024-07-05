extends Label

@onready var base_text = text

func format(args: Variant):
	text = tr(base_text) % args
