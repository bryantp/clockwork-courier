extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("self_cleanup"):
		return
	
	# We shouldn't need handle anything other than platforms or other non-player chars
	print("Deleting object")
	body.queue_free()
