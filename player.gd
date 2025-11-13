extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -400.0

@onready var state_machine = $"../StateMachine"
@onready var model_root = $SubViewportContainer/SubViewport/Node3D/robot
@onready var animation_player = model_root.get_node("AnimationPlayer")
@onready var camera = %Camera2D
@onready var default_camera_zoom = camera.zoom

var has_jumped_once = false

func _ready():
	for state in state_machine.get_children():
		state.player = self

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
	
func _create_zoom_tween(target: Vector2) -> void:
	if camera.zoom.is_equal_approx(target):
		return #Skip redundant tweens
	create_tween().tween_property(camera, "zoom", target, 0.3)
