extends CharacterBody2D
const SPEED = 500.0
const JUMP_VELOCITY = -400.0

@onready var state_machine = $"../StateMachine"
@onready var model_root = $SubViewportContainer/SubViewport/Node3D/robot
@onready var animation_player = model_root.get_node("AnimationPlayer")
@onready var camera = %Camera2D
@onready var default_camera_zoom = camera.zoom
@onready var player_energy_bar := %PlayerEnergyBar
@onready var tile_map = %ForegroundTileMapLayer

signal time_reversed(reversal_time: int)

var has_jumped_once = false
var current_energy_level = 100
var energy_tick_amount = 5

func _ready():
	for state in state_machine.get_children():
		state.player = self
	player_energy_bar.set_value(100)

func _physics_process(delta: float) -> void:	
	state_machine._physics_update(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if has_jumped_once:
			_create_zoom_tween(Vector2(2.5, 2.5))
	else:
		if has_jumped_once:
			_create_zoom_tween(default_camera_zoom)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		has_jumped_once = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	var collisions := get_slide_collision_count()
	if collisions > 0:
		_detect_and_handle_special_tiles(collisions)
	
func _detect_and_handle_special_tiles(collision_count: int) -> void:
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is TileMapLayer:
			var local_pos = tile_map.to_local(collision.get_position())
			var tile_pos = tile_map.local_to_map(local_pos)
			var tile_data = tile_map.get_cell_tile_data(tile_pos)
			if not tile_data:
				return
			var energy_level = tile_data.get_custom_data("energy")
			if energy_level != 0:
				tile_map.erase_cell(tile_pos)
				_update_energy_level(current_energy_level + energy_level)
				return
			
			var time_rewind_secs = tile_data.get_custom_data("time_rewind_secs")
			if time_rewind_secs > 0:
				tile_map.erase_cell(tile_pos)
				time_reversed.emit(time_rewind_secs)
	
func _create_zoom_tween(target: Vector2) -> void:
	if camera.zoom.is_equal_approx(target):
		return #Skip redundant tweens
	create_tween().tween_property(camera, "zoom", target, 0.3)

func _on_energy_timer_timeout() -> void:
	_update_energy_level(current_energy_level - energy_tick_amount)
	
func _update_energy_level(energy_level: int) -> void:
	current_energy_level = energy_level
	player_energy_bar.set_value(current_energy_level)
