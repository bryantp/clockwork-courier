extends Node

@export var initial_state: NodePath
var current_state: PlayerState

func _ready() -> void:
	current_state = get_node(initial_state)
	current_state.enter()
	
func change_state(new_state: PlayerState):
	if new_state == current_state:
		return
	current_state.exit()
	current_state = new_state
	current_state.enter()

func _physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)
