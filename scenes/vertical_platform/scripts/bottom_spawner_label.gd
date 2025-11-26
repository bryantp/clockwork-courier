@tool
extends Label

func _ready() -> void:
	if not Engine.is_editor_hint():
		#hide()
		pass
