extends Control

onready var boards = $Header/HBoxContainer/Boards/TabContainer
onready var shortcuts = $Header/HBoxContainer/Menu/ButtonsContainer/Group2/Shortcuts
var board_tscn = preload("res://elements/Board.tscn")
var bttn_tscn = preload("res://elements/ShortcutButton.tscn")


func update_shortcuts():
	for i in shortcuts.get_children():
		i.queue_free()
	
	for board in boards.get_children():
		var bttn_new = bttn_tscn.instance()
		shortcuts.add_child(bttn_new)
		bttn_new.text = board.title
		bttn_new.object_id = board.object_id
		bttn_new.connect("is_pressed", self, "on_shortcut_pressed")


func show_board(board_id):
	for board in boards.get_children():
		if board.object_id == board_id:
			boards.current_tab = board.get_position_in_parent()
			board.grab_focus()


func _on_CreateBoard_pressed():
	var board_new = board_tscn.instance()
	boards.add_child(board_new)
	board_new.connect("deleted", self,"on_board_deleted")
	board_new.focus_text()
	show_board(board_new.object_id)
	update_shortcuts()


func on_board_deleted(board_id):
	for i in shortcuts.get_children():
		if i.object_id == board_id:
			queue_free()
	if boards.get_children():
		show_board(boards.get_child(0).object_id)

func on_shortcut_pressed(id):
	show_board(id)
