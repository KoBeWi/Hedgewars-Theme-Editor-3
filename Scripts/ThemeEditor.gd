extends TabContainer

var last_dirty = false
var theme_version_changed = false

func _ready():
	TranslationServer.set_locale(Utils.preferred_language)
	get_window().title = tr("Hedgewars Theme Editor 3")
	get_window().mode = Window.MODE_MAXIMIZED if (Utils.maximize_on_start) else Window.MODE_WINDOWED
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, true)
	
	HWTheme.theme_loaded.connect(on_theme_loaded)
	HWTheme.output_updated.connect(on_output_updated)

func on_theme_loaded():
	# TODO: unify this into update_title()
	get_window().set_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.basename(), ")"))
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, false)

func on_output_updated(dirty):
	if last_dirty != dirty:
		last_dirty = dirty
		get_window().set_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.basename(), ")", "*" if dirty else ""))
