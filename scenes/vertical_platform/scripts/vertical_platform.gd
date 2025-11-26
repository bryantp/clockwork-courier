extends Node2D

@export var spawn_rate_secs = 2
@export var speed = 50

@onready var platform = %VerticalMovingPlatform.duplicate()
@onready var platform_start_pos = platform.position

# For this to be reversable, we will need 2 spawn points. One for each direction
@onready var top_spawner = %TopSpawner
@onready var bottom_spawner =%BottomSpawner

var platforms = {}
var reversed = false
var init_distance_between_platforms = 100

func _ready() -> void:
	#_create_platform_spawn_timer()

	platforms[platform.get_instance_id()] = platform

	var distance_between_platforms = spawn_rate_secs * speed
	var span = bottom_spawner.position.y - top_spawner.position.y  # positive distance

	for local_y in range(0, -span, -distance_between_platforms):
		var new_platform = platform.duplicate()
		"""
		The position of "new_platform" is relative to where it's placed, which
		in this case is the bottom_spawner. So, 0 is the position of the spawner
		and the Y value is relative to the spawner.
		"""
		new_platform.position = Vector2(0, local_y)
		new_platform.set_speed(0)
		bottom_spawner.add_child(new_platform)
		platforms[new_platform.get_instance_id()] = new_platform

func _create_platform_spawn_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = spawn_rate_secs
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	
	timer.timeout.connect(_on_spawn_platform)

func _on_spawn_platform() -> void:
	var new_platform = platform.duplicate()
	new_platform.position = platform_start_pos
	new_platform.set_speed(speed)
	platforms.set(new_platform.get_instance_id(), new_platform)
	if reversed:
		top_spawner.add_child(new_platform)
	else:
		bottom_spawner.add_child(new_platform)

func _on_top_spawner_area_body_entered(body: Node2D) -> void:
	if reversed:
		return
	body.queue_free()
	platforms.erase(body.get_instance_id())

func _on_bottom_spawner_area_body_entered(body: Node2D) -> void:
	if not reversed:
		return
	body.queue_free()
	platforms.erase(body.get_instance_id())

func _on_player_time_reversed(reversal_time: int) -> void:
	print("Time Reversed for %s seconds" % reversal_time)
	var timer := Timer.new()
	timer.wait_time = reversal_time
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	
	timer.timeout.connect(_reset_time_reverse)
	
	reversed = true
	for platform in platforms.values():
		platform.reverse_direction()
		
func _reset_time_reverse() -> void:
	reversed = false
	for platform in platforms.values():
		platform.reverse_direction()
