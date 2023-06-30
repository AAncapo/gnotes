extends UIElement
class_name Note

signal checked(note, is_checked)
signal skip_forward(pip)
signal skip_back(pip)
signal dragging
signal dropped(_self)
signal size_updated

enum NoteType { Text, Checknote }
onready var textEdit = $HBoxContainer/TextEdit
var note_type = NoteType.Checknote
var is_checked = false
var drag_position = null
var empty = false


func _ready() -> void:
	if !object_id:
		object_id = Global.gen_id()
	update_size()


func detect_dragging():
	if !drag_position:
		var mouse_pos = get_global_mouse_position()
		if get_global_rect().has_point(mouse_pos):
			return true
		return false


func _initialize(_content,_checked):
	is_checked =_checked
	$HBoxContainer/TextEdit.text = _content
	$HBoxContainer/CheckBox.pressed = _checked
	$HBoxContainer/TextEdit.readonly = _checked


func set_type(_type):
	note_type = _type


func get_data() -> Dictionary:
	var content = textEdit.text
	var data_dict = {
		"filepath" : "res://Note.tscn",
		"content" : content,
		"is_checked" :  is_checked,
		"pip" : get_position_in_parent()
	}
	return data_dict


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			if textEdit.has_focus():
				get_tree().set_input_as_handled()
				if !is_empty():
					if textEdit.cursor_get_column() > 0:
						emit_signal("skip_forward", get_position_in_parent())
					else:
						emit_signal("skip_back",get_position_in_parent())
#this can't be handled by gui_input because by that point the cursor position will be 0

func _on_TextEdit_gui_input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_BACKSPACE:
				if get_parent().get_child_count() > 1 and get_position_in_parent() > 0 and is_empty():
					#tap BACKSPACE two times to make sure that the user doesn't want to keep writing in this Note and go back to the previous one
					if empty:
						var prev_note = get_parent().get_child(get_position_in_parent()-1)
						prev_note.focus_text()
						queue_free()
					else:
						empty = true
				elif get_parent().get_child_count() > 1 and get_position_in_parent() == 0 and is_empty():
					if empty:
						var next_note = get_parent().get_child(get_position_in_parent()+1)
						next_note.focus_text()
						queue_free()
					else:
						empty = true
	update_size()


func _on_CheckBox_pressed() -> void:
	is_checked = $HBoxContainer/CheckBox.pressed
	textEdit.readonly = is_checked
	emit_signal("checked",self,is_checked)


func _on_DragPoint_gui_input(event):
	if event is InputEventMouseButton:
		if !event.pressed and drag_position:
			drag_position = null
			emit_signal("dropped",self)
		if event.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		emit_signal("dragging")
		rect_global_position = get_global_mouse_position() - drag_position
		


func update_size():
	var wrap_count = textEdit.get_line_wrap_count(0) + 1
	var line_min_y = textEdit.rect_min_size.y
	rect_min_size.y = wrap_count * line_min_y
	emit_signal("size_updated")

func focus_text():
	textEdit.grab_focus()
	textEdit.cursor_set_column(textEdit.text.length())

func is_empty() -> bool:
	return textEdit.text.length() == 0
