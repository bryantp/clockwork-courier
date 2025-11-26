extends AnimatableBody2D

var _speed: float = 50

# negative is up, positive is down
var _direction := -1
	
func _physics_process(delta: float) -> void:
	position.y += _speed * _direction * delta
	
func set_speed(speed: int) -> void:
	_speed = speed
	
func reverse_direction() -> void:
	_direction = -_direction
