extends Node

var theme_name

signal theme_loaded

func load_theme(_theme_name):
	theme_name = _theme_name
	emit_signal("theme_loaded")