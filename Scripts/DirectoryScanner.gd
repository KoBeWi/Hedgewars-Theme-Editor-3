extends Node

var scan_list: Array
var current_directory: int
var current_file: int
var file_util: File

signal files_created(files)
signal files_modified(files)
signal files_deleted(files)

func _ready() -> void:
	file_util = File.new()
	refresh_paths()

func refresh_paths():
	scan_list.clear()
	current_directory = 0
	
	add_scan_directory(Util.hedgewars_user_path.plus_file("Data/Themes"))
#	add_scan_directory(Util.hedgewars_user_path.plus_file("Data/Music"))

func add_scan_directory(directory: String):
	var scan_data := DirectoryScanData.new(directory)
	scan_list.append(scan_data)

func _process(delta: float) -> void:
	if not scan_list[current_directory].step(1):
		current_directory = (current_directory + 1) % scan_list.size()
		scan_list[current_directory].restart()

class DirectoryScanData:
	var directory: Directory
	
	var file_times: Dictionary
	var current_file_list: Array
	var last_file_list: Array
	
	func _init(d: String) -> void:
		directory = Directory.new()
		directory.open(d)
		
		directory.list_dir_begin(true)
		var file := directory.get_next()
		while file:
			file_times[file] = get_time(file)
			file = directory.get_next()
		last_file_list = file_times.keys()
		
		restart()
	
	func restart():
		directory.list_dir_begin(true)
	
	func step(count: int) -> bool:
		var finished: bool
		var new_files: Array
		var modified_files: Array
		
		for i in count:
			var file := directory.get_next()
			current_file_list.append(file)
			
			if file:
				var time := file_times.get(file, -1) as int
				if time == -1:
					new_files.append(file)
					file_times[file] = get_time(file)
				else:
					var new_time := get_time(file)
					if new_time > time:
						file_times[file] = new_time
						modified_files.append(file)
			else:
				finished = true
				break
		
		if finished:
			var deleted_files: Array
			
			for file in last_file_list:
				if not file in current_file_list:
					deleted_files.append(file)
			
			last_file_list = current_file_list
			current_file_list = []
			
			if deleted_files:
				for file in deleted_files:
					file_times.erase(file)
				
				notify_files("files_deleted", deleted_files)
		
		if new_files:
			notify_files("files_created", new_files)
		if modified_files:
			notify_files("files_modified", modified_files)
		
		return not finished
	
	func get_time(file: String) -> int:
		return DirectoryScanner.file_util.get_modified_time(directory.get_current_dir() + "/" + file)
	
	func notify_files(notify_type: String, files: Array):
		print(notify_type)
		var full_files: Array
		
		for file in files:
			full_files.append(directory.get_current_dir().plus_file(file))
		
		DirectoryScanner.emit_signal(notify_type, full_files)
