extends Button
class_name ShortcutButton

var object_id
signal is_pressed(id)

func _on_ShortcutButton_pressed():
	emit_signal("is_pressed", object_id)
