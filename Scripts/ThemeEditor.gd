extends TabContainer

func _ready():
	OS.set_window_title(tr("Hedgewars Theme Editor 3"))
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, true)
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")

func on_theme_loaded():
	for i in range(1, get_child_count()-1):
		set_tab_disabled(i, false)