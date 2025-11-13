extends PlayerState

func enter():
	player.animation_player.play("JumpAnimation")
	
func physics_update(delta:float):
	if player.is_on_floor():
		player.state_machine.change_state(player.state_machine.get_node("IdleState"))
