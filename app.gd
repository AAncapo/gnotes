extends Control

func _ready() -> void:
	load_data()


func save_data():
	var save_file = File.new()
	save_file.open("res://save/save_file.save",File.WRITE)
	var saveload_nodes = get_tree().get_nodes_in_group("saveload")
	for node in saveload_nodes:
		if node.has_method("get_data"):
			var node_data = node.get_data()
			save_file.store_line(to_json(node_data))
	print("saved")
	save_file.close()
	$Home.update_shortcuts()


func load_data():
	var file = File.new()
	if !file.file_exists("res://save/save_file.save"):
		print("don't have a save to load")
		return
	#Delete all 'saveload' nodes to avoid cloning
	var saveload_nodes = get_tree().get_nodes_in_group("saveload")
	for i in saveload_nodes:
		i.queue_free()
	
	file.open("res://save/save_file.save",File.READ)
	while file.get_position() < file.get_len():
		var node_data = parse_json(file.get_line())
		
		var new_object = load(node_data["filepath"]).instance()
		get_node(node_data['parent']).add_child(new_object)
		new_object._initialize(node_data['title'], node_data['panels'])
	file.close()
	$Home.update_shortcuts()


func _input(event):
	if event.is_action_pressed("save"):
		save_data()


func _on_ClearData_pressed():
	var dir = Directory.new()
	if dir.dir_exists("res://save/save_file.save"):
		dir.remove("res://save/save_file.save")
