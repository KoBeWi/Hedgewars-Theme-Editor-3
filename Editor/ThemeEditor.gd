extends TabContainer

var last_dirty = false
var theme_version_changed = false

func _ready():
	TranslationServer.set_locale(Utils.preferred_language)
	get_window().mode = Window.MODE_MAXIMIZED if (Utils.maximize_on_start) else Window.MODE_WINDOWED
	
	for i in range(1, get_child_count()):
		set_tab_disabled(i, true)
	
	HWTheme.theme_loaded.connect(on_theme_loaded)
	HWTheme.output_updated.connect(on_output_updated)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		update_title()

func update_title():
	if HWTheme.theme_name.is_empty():
		get_window().title = "Hedgewars Theme Editor 3"
	else:
		get_window().set_title(str(tr("Hedgewars Theme Editor 3"), " (", HWTheme.basename(), ")", "*" if last_dirty else ""))

func on_theme_loaded():
	update_title()
	for i in range(1, get_child_count()):
		set_tab_disabled(i, false)

func on_output_updated(dirty):
	if last_dirty != dirty:
		last_dirty = dirty
		update_title()
