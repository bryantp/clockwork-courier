extends PlayerState

func enter():
	player.animation_player.play("WalkAnimation")
	
func physics_update(delta:float):
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0:
		player.state_machine.change_state(player.state_machine.get_node("IdleState"))
	else:
		player.velocity.x = dir * 500
		player.model_root.rotation.y = deg_to_rad(90 if dir > 0 else -90)
	
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.state_machine.change_state(player.state_machine.get_node("JumpState"))
	elif not player.is_on_floor():
		player.state_machine.change_state(player.state_machine.get_node("IdleState"))
