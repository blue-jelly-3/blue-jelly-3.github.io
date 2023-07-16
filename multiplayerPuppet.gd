extends CharacterBody3D
var wire

var audio
var nameLabel
func _ready():
	wire = $rotation_helper/Camera3D/shootingRay/wire
	audio = $AudioStreamPlayer3D
	nameLabel = $nameLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shootingAnim():
	audio.pitch_scale = randf_range(1,2.0)
	audio.play()
	$AudioStreamPlayer3D/OmniLight3D.visible=true
	$flashTimer.start()


func _on_flash_timer_timeout():
	$AudioStreamPlayer3D/OmniLight3D.visible=false
