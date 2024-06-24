extends Label

onready var base_text = text

func format(args):
	text = base_text % args
