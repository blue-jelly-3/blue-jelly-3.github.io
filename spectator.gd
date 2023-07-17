extends CharacterBody3D

@export var SPEED = 25
@export var TO_RESPAWN = true
@export var RESPAWN_TIME = 5.0
var MOUSE_SENSITIVITY = Global.MOUSE_SENSITIVITY
var rotation_helper
var name2ref
var players: Array
var currentIndex = -1
var freecam = true
var t = 0
var follow = false
var realPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_helper = $rotation_helper
	realPlayer = Global.realPlayer

func _input(event):
	# This section controls your player camera. Sensitivity can be changed.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		rotation_helper.rotation = camera_rot
	
	# Release/Grab Mouse for debugging. You can change or replace this.
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	if Input.CURSOR_MOVE and freecam:
		_input(InputEvent)
		
	if Input.is_action_pressed("ui_up"):
		velocity -= SPEED*rotation_helper.global_transform.basis.z
	if Input.is_action_pressed("ui_down"):
		velocity += SPEED*rotation_helper.global_transform.basis.z
	if Input.is_action_pressed("ui_right"):
		velocity += SPEED*rotation_helper.global_transform.basis.x
	if Input.is_action_pressed("ui_left"):
		velocity -= SPEED*rotation_helper.global_transform.basis.x
	if Input.is_action_pressed("ui_accept"):
		velocity.y += SPEED
	if Input.is_action_pressed("crouch"):
		velocity.y -= SPEED
	if Input.is_action_just_pressed("next_spectate"):
		_on_next_pressed()
	if Input.is_action_just_pressed("previous_spectate"):
		_on_previous_pressed()
	$"../TextureProgressBar".value = (float($"../respawnTimer".time_left)/float(RESPAWN_TIME))*100.0
	
	
	
	if freecam:
		move_and_slide()
	else:
		velocity=Vector3.ZERO
		name2ref = Global.name2ref
		players.clear()
		for name in name2ref:
			players.append(name2ref[name])
		var target = players[currentIndex]
		target = target.get_node("rotation_helper/Camera3D")
		#print(target)
		if not follow:
			global_transform = global_transform.interpolate_with(target.global_transform,t)
			t += delta
			if t>=1.0:
				t=0.1
				follow = true
		if follow:
			global_transform =target.global_transform


func _on_next_pressed():
	if currentIndex+1 != len(players):
		currentIndex+=1
		freecam=false
		follow = false
		t=0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$"../HBoxContainer/Label".text = name2ref.find_key(players[currentIndex])
		$"../HBoxContainer/previous".disabled=false
		
		if currentIndex == len(players)-1:
			$"../HBoxContainer/next".disabled=true
		

func activate():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	name2ref = Global.name2ref
	players.clear()
	for name in name2ref:
		players.append(name2ref[name])

	$"../HBoxContainer".visible=true
	$rotation_helper/Camera3D.current=true
	$"../respawnTimer".start(RESPAWN_TIME)
	$"../TextureProgressBar".visible=true


func _on_previous_pressed():
	if currentIndex > 1:
		currentIndex-=1
		freecam=false
		follow = false
		t=0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$"../HBoxContainer/Label".text = name2ref.find_key(players[currentIndex])
		$"../HBoxContainer/previous".disabled=false
		$"../HBoxContainer/next".disabled=false
	else:
		$"../HBoxContainer/previous".disabled=true
		freecam=true
		follow=false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$"../HBoxContainer/Label".text="FREECAM"


func _on_respawn_timer_timeout():
	$rotation_helper/Camera3D.current=false
	$"../TextureProgressBar".visible=false
	$"../HBoxContainer".visible=false
	realPlayer.revive()
