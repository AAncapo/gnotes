extends UIElement
class_name Board

signal deleted(id)

onready var container = $"%PanelContainer"
onready var add_element_bttn = $PanelContainer/VBoxContainer/ScrollContainer/PanelContainer/AddElementButton
var panel_tscn = preload("res://elements/NotePanel.tscn")
var title = "New Board"


func _ready():
	if !object_id:
		object_id = Global.gen_id()


func add_panel(_panel=null) -> NotePanel:
	var panel_new
	if !_panel:
		panel_new = panel_tscn.instance()
	else:
		panel_new = _panel
	container.add_child(panel_new)
	container.move_child(add_element_bttn, container.get_child_count()-1)
	return panel_new


func focus_text():
	$"%BoardTitle".grab_focus()


func _initialize(_title:String, _panels:Dictionary):
	$"%BoardTitle".text = _title
	title = _title
	self.name = _title
	load_panels(_panels)


func load_panels(panels_dict:Dictionary):
	print("loading panels..")
	for x in range(panels_dict.size()):
		for key in panels_dict.keys():
			if panels_dict[key]['pip'] == x:
				var new_panel = panel_tscn.instance()
				var pos = Vector2(panels_dict[key]['pos_x'],panels_dict[key]['pos_y'])
				new_panel._initialize(panels_dict[key]['panel_name'], panels_dict[key]['notes'], pos)
				add_panel(new_panel)
#				print(panels_dict[key]['notes'])
				print("panel ",key," LOADED")


func get_data() -> Dictionary:
	var panels_dict = {}
	var panels = container.get_children()
	for i in panels:
		if i is UIElement:
			panels_dict[i.object_id] = i.get_data()
	
	var data = {
		"filepath" : "res://elements/Board.tscn",
		"title" : $"%BoardTitle".text,
		"parent" : get_parent().get_path(),
		"panels" : panels_dict,
	}
	return data


func _on_LineEdit_text_changed(_new_text):
	title = $"%BoardTitle".text
	name = title

func _on_LineEdit_text_entered(_new_text):
	if !container.get_children():
		var new_panel = add_panel()
		new_panel.focus_text()

func _on_DELETE_pressed():
	$ConfirmationDialog.popup()

func _on_AddElementButton_pressed():
	add_panel()


func _on_ConfirmationDialog_confirmed():
	emit_signal("deleted", object_id)
	queue_free()
