extends CSGBox3D

var realPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	realPlayer = get_parent().get_parent().get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if realPlayer != null:
		look_at(realPlayer.global_transform.origin)

func set_value(precent):
	size.x = 1.5 * precent
