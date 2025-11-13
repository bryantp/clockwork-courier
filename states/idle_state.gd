extends PlayerState

func enter():
	player.animation_player.stop()
	
func physics_update(delta:float):
	if not player.is_on_floor():
		pass
	elif abs(player.velocity.x) > 10:
		player.state_machine.change_state(player.state_machine.get_node("WalkState"))
	elif Input.is_action_just_pressed("ui_accept"):
		player.state_machine.change_state(player.state_machine.get_node("JumpState"))
