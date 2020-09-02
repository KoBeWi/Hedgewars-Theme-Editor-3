extends TabContainer

var last_dirty = false
var theme_version_changed = false

func _ready():
	TranslationServer.set_locale(Util.preferred_language)
	OS.set_window_title(tr("Hedgewars Theme Editor 3"))
	OS.window_maximized = Util.maximize_on_start
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, true)
	
	HWTheme.connect("theme_loaded", self, "on_theme_loaded")
	HWTheme.connect("output_updated", self, "on_output_updated")

func on_theme_loaded():
	OS.set_window_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.basename(), ")"))
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, false)

func on_output_updated(dirty):
	if last_dirty != dirty:
		last_dirty = dirty
		OS.set_window_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.basename(), ")", "*" if dirty else ""))
