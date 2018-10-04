extends TabContainer

var last_dirty = false

func _ready():
	TranslationServer.set_locale(Util.preferred_language)
	OS.set_window_title(tr("Hedgewars Theme Editor 3"))
	OS.window_maximized = true #TODO: optional
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, true)
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	HWTheme.connect("output_updated", self, "on_output_updated")

func on_theme_loaded():
	OS.set_window_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.theme_name, ")"))
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, false)

func on_output_updated(dirty):
	if last_dirty != dirty:
		last_dirty = dirty
		OS.set_window_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.theme_name, ")", "*" if dirty else ""))