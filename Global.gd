extends Node

var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

func _ready() -> void:
	randomize()

func gen_id(id_len = 8):
	var new_id = "@"
	for _i in range(id_len):
		new_id += chars[randi()%chars.length()-1]
	return new_id

func change_parent(_node:Node,_new_parent:Node):
	var prev_parent = _node.get_parent()
	prev_parent.remove_child(_node)
	_new_parent.add_child(_node)

