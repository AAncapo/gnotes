extends UIElement
class_name NotePanel

signal size_updated
signal deleted
onready var panelTitle = $PanelContainer/VBoxContainer/HeaderControl/HBoxContainer/Title
onready var notesContainer = $PanelContainer/VBoxContainer/Notes
onready var checkedContainer = $PanelContainer/VBoxContainer/CheckedNotes

var note = preload("res://elements/Note.tscn")
var note_ghost = preload("res://elements/NoteGhost.tscn")
var ghost_instanced = false
var drag_position = null
var panel_title


func _ready() -> void:
	if !object_id:
		object_id = Global.gen_id()
	update_size()


func add_note(note_new = null) -> Note:
	if !note_new:
		note_new = note.instance()
	if !note_new.is_checked:
		$PanelContainer/VBoxContainer/Notes.add_child(note_new)
	else:
		$PanelContainer/VBoxContainer/CheckedNotes.add_child(note_new)
	note_new.connect("checked", self, "on_Note_checked")
	note_new.connect("skip_forward", self, "on_Note_skip_forward")
	note_new.connect("skip_back", self, "on_Note_skip_back")
	note_new.connect("size_updated", self, "update_size")
	note_new.connect("dragging", self, "on_note_dragging")
	note_new.connect("dropped", self, "on_note_dropped")
	update_size()
	return note_new

var ghost
func on_note_dragging():
	#this func is only needed for defining behaiour while a note is dragged
	if !ghost_instanced:
		ghost = note_ghost.instance()
		notesContainer.add_child(ghost)
		ghost_instanced = true
		ghost.hide()
	for n in notesContainer.get_children():
		if !n.is_in_group("ghost"):
			if n.detect_dragging():
				notesContainer.move_child(ghost,n.get_position_in_parent()+1)
				ghost.show()


func on_note_dropped(_note):
	for n in notesContainer.get_children():
		if n.is_in_group("ghost"):
			ghost_instanced = false
			n.queue_free()
		else:
			if n.detect_dragging():
				notesContainer.move_child(_note,n.get_position_in_parent())


func get_data() -> Dictionary:
	panel_title = panelTitle.text
	var all_notes = notesContainer.get_children() + checkedContainer.get_children()
	var notes_dict = {}
	for n in all_notes:
		notes_dict[n.object_id] = n.get_data()
	var data = {
		"filepath" : "res://NotePanel.tscn",
		"panel_name" : panelTitle.text,
		"parent": get_parent().get_path(),
		"pos_x" : rect_position.x,
		"pos_y" : rect_position.y,
		"notes" : notes_dict,
		"pip" : get_position_in_parent()
	}
	return data


func _initialize(_title:String, _notes:Dictionary, _position:Vector2):
	$PanelContainer/VBoxContainer/HeaderControl/HBoxContainer/Title.text = _title
	rect_position = _position
	load_notes(_notes)


func load_notes(notes_dict:Dictionary):
	#pip = (note)position_in_parent
	for x in range(notes_dict.size()):
		for key in notes_dict.keys():
			if notes_dict[key]['pip'] == x:
				var new_note = note.instance()
				new_note._initialize(notes_dict[key]['content'],notes_dict[key]['is_checked'])
				add_note(new_note)


func on_Note_checked(_note, is_checked):
	var parent:Node = _note.get_parent()
	parent.remove_child(_note)
	if is_checked:
		checkedContainer.add_child(_note)
	else:
		notesContainer.add_child(_note)


func on_Note_skip_forward(note_pip):
	for n in notesContainer.get_children():
		if n.get_position_in_parent() == note_pip + 1:
			var next_note = n
			if next_note.is_empty():
				next_note.focus_text()
				return
			else:
				var added_note = add_note()
				added_note.focus_text()
				notesContainer.move_child(added_note,note_pip+1)
				return
	var added_note = add_note()
	added_note.focus_text()


func on_Note_skip_back(note_pip):
	var added_note = add_note()
	added_note.focus_text()
	notesContainer.move_child(added_note, note_pip)


func _on_NotePanel_gui_input(_event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.pressed:
#			drag_position = get_global_mouse_position() - rect_global_position
#		else:
#			drag_position = null
#	if event is InputEventMouseMotion and drag_position:
#		rect_global_position = get_global_mouse_position() - drag_position
	pass

func _on_DeleteButton_pressed():
	emit_signal("deleted")
	queue_free()

func _on_AddTextNote_pressed():
	var new_note = add_note()
	new_note.note_type = Note.NoteType.Text

func _on_NewNoteButton_pressed():
	var new_note = add_note()
	new_note.note_type = Note.NoteType.Checknote

func _on_Title_text_entered(_new_text):
	if notesContainer.get_children():
		return
	else:
		var note_new = add_note()
		note_new.focus_text()


func focus_text():
	panelTitle.grab_focus()

func update_size():
	rect_min_size.y = $PanelContainer.rect_size.y + 25
	emit_signal("size_updated")
