extends CharacterBody3D

@export var movement_speed: float = 16.0
var player
var car
func _ready():
	player = $"../Player"
	car = $"../car"

func _process(delta):
	#velocity = player.global_transform.origin - global_transform.origin
	#velocity = velocity.normalized() * movement_speed

	move_and_slide()
