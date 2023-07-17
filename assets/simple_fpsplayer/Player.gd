extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30

@export var SPEED = 5.0
@export var SPRINT_MULT = 2.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.06
@export var GRAPPLE_MULT = 2.0
@export var MULTIPLAYER = false
@export var HP = 100
var MAXHP = HP
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var wire
var camera
var rotation_helper
var dir = Vector3.ZERO
var flashlight
var ray
var car
var audio
var grappleTimer
var cooldownDisp
var socket = Global.socket
var suckCord: Vector3
var grappling = false
var wireCord
var CONNECTED = false
var puppet
var dead= false
var shooting
var inCar = false
var grapplingData = [false,Transform3D(),0.001]
var hitSound
@onready var weapon = $"rotation_helper/ak-47"
var weaponDmg = 1
var hpBar
var hpLabel
var transgenders = {}
var players = []
var deadPlayers = []
var carTransgender
var refWires = {}
var name2ref = {}
var spectator 


var n =0 


func _ready():
	puppet = load("res://multiplayerPuppet.tscn")
	if MULTIPLAYER:
		carTransgender = $"../car".global_transform
		print("car trans is " + str(carTransgender))
		Global.realPlayer = self
		discord_sdk.state = "playing multiPlayer with " + str(n) + " other people!"
	else:
		discord_sdk.state = "playing singlePlayer"
	discord_sdk.refresh()
	cooldownDisp = $grappleCoolDown
	camera = $rotation_helper/Camera3D
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Camera3D/flashlight_player
	audio = $AudioStreamPlayer3D
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray = $rotation_helper/Camera3D/shootingRay
	wire = $rotation_helper/Camera3D/shootingRay/wire
	grappleTimer = $grappleTimer
	car = $"../car"
	hitSound = $hitSound
	weaponDmg = weapon.dmg
	hpBar = $hpBar
	hpLabel = $hpBar/hpVal
	spectator = $"../baseTrans"
	print("puppet is " + str(puppet))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_tree().get_root().get_node(".").print_tree_pretty()
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
	
	# Flashlight toggle. Defaults to F on Keyboard.
	if event is InputEventKey:
		if Input.is_action_pressed("flashlight"):
			if flashlight.is_visible_in_tree() and not event.echo:
				flashlight.hide()
			elif not event.echo:
				flashlight.show()
	if Input.is_action_pressed("fire") and $reloadTimer.is_stopped():
		audio.pitch_scale = randf_range(1,2.0)
		audio.play()
		$reloadTimer.start()
		$AudioStreamPlayer3D/OmniLight3D.visible=true
		$flashTimer.start()
		if (ray.get_collider() != null):
			if (ray.get_collider().name == "puppetMesh"):
				print("hit" + name2ref.find_key(ray.get_collider().get_parent()))
				var hitted = name2ref.find_key(ray.get_collider().get_parent())
				Global.send_hit_other_player_sig(hitted,weaponDmg)
				if hitted not in deadPlayers:
					puppet_hit(hitted,weaponDmg)
				
			print(ray.get_collider())
			shooting=true
	if Input.is_action_just_pressed("grapple"):
		var col = ray.get_collider()
		if col is CSGBox3D and grappleTimer.is_stopped() and not grappling:
			suckCord = ray.get_collision_point()
			var vect = suckCord - global_transform.origin
			var Length = vect.length()
			wire.height = Length
			#place at midpoint between ray origin and collision
			wire.transform.basis = Basis(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,-1,0))
			wire.global_transform.origin = (suckCord + global_transform.origin)/2.0
			
			wire.visible=true
			wireCord = wire.global_transform
			print(wireCord)
			grappling = true
			grapplingData[1] = wireCord
			grapplingData[2] = Length
			
func _physics_process(delta):
	var moving = false
	grapplingData[0] = grappling
	cooldownDisp.value = (grappleTimer.get_time_left() / 2.0) * 100
	
	# Add the gravity. Pulls value from project settings.
	if not is_on_floor() and not grappling:
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and grappling:
		grappling = false
		wire.visible = false
		wire.transform.basis = Basis(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,-1,0))
		velocity.y = JUMP_VELOCITY
		$grappleCoolDown/Grapple.visible=true
		grappleTimer.start()
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	# This just controls acceleration. Don't touch it.
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with a custom keymap depending on your control scheme. These strings default to the arrow keys layout.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	if Input.is_key_pressed(KEY_SHIFT):
		direction = direction * SPRINT_MULT
	else:
		pass
		

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if grappling:
		wire.global_transform = wireCord
		var suckDir = suckCord - global_transform.origin
		#suckDir = suckDir
		velocity = suckDir * GRAPPLE_MULT
		#velocity.y = suckDir.y 
		
		if suckDir.length() < 2:
			grappling = false
			wire.visible = false
			wire.transform.basis = Basis(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,-1,0))
			$grappleCoolDown/Grapple.visible=true
			grappleTimer.start()
	move_and_slide()
	
	#MULTIPLAYER
	if MULTIPLAYER:
		socket.poll()
		handleMultiplayer()
		if not dead:
			send_data_marked(global_transform)
		if CONNECTED:
			for mover in transgenders:
				if mover not in deadPlayers:
					var ref = name2ref[mover]
					ref.global_transform.origin = lerp(ref.global_transform.origin,transgenders[mover].origin,0.5)
					ref.global_transform.basis = transgenders[mover].basis
			for muWire in refWires:
				muWire.global_transform = refWires[muWire]
			car.global_transform.origin = lerp(car.global_transform.origin,carTransgender.origin,0.5)
			car.global_transform.basis = carTransgender.basis
	#togglers
	if shooting:
		shooting = not shooting
		
	
func _on_flash_timer_timeout():
	$AudioStreamPlayer3D/OmniLight3D.visible=false

func _on_grapple_timer_timeout():
	$grappleCoolDown/Grapple.visible = false

func send_data_marked(data):
	#print("sending data as " + Global.username)
	socket.send(var_to_bytes([Global.username,data,shooting,grapplingData,inCar]))

func handlePacket(pak):
	CONNECTED=true
	var data=pak.decode_var(0,true)
	if data is Array:
		var mover = data[0]
		#print("got data as " + Global.username + " , data is " + str(data))
		if mover != Global.username:
			#movement stuff
			if mover not in players:
				add_puppet(mover)
				n += 1
				discord_sdk.state = "playing multiPlayer with " + str(n+1) + " player[s]!"
				discord_sdk.refresh()
				players.append(mover)
			if data[4] == false:
				#print(mover + " moved, recieveing as " + Global.username)
				transgenders[mover] = data[1]
			if data[4]:
				carTransgender = data[1]
			#shooting stuff
			if data[2]:
				name2ref[mover].shootingAnim()
			
			if data[3][0] == true:
				var grapStuff = data[3]
				var refWire = name2ref[mover].wire
				refWire.height = grapStuff[2]
				refWire.global_transform = grapStuff[1]
				refWire.visible = true
				refWires[refWire]= grapStuff[1]
			elif mover in name2ref:
				var refWire = name2ref[mover].wire
				refWire.visible = false
	if data is Dictionary:
		if data["name"] != Global.username:
			if data["delete"]:
				delete_player(data["name"])
			if data["readd"]:
				readd_player(data["name"])
			if data["hit"]:
				#if we are hit
				print("someone got hit")
				var damage = data["hitData"][1]
				if data["hitData"][0]==Global.username and not dead:
					print("we got hit")
					hitSound.play(0.3)
					HP -= damage
					updateHpBar()
				elif not dead and data["hitData"][0] not in deadPlayers:
					puppet_hit(data["hitData"][0],damage)
				

func add_puppet(name):
	var inst = puppet.instantiate()
	inst.set_name(name)
	get_parent().add_child(inst)
	name2ref[name] = inst
	inst.nameLabel.text = name
	
func handleMultiplayer():
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			#print("Packet: ", socket.get_packet())
			handlePacket(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		CONNECTED=false

func delete_player(username):
	print("deleting " + username + " , as " + Global.username)
	var ref = name2ref[username]
	ref.queue_free()
	transgenders.erase(username)
	name2ref.erase(username)
	refWires.clear()
	deadPlayers.append(username)
	
func readd_player(username):
	print("readding " + username)
	if username in deadPlayers:
		deadPlayers.erase(username)
	add_puppet(username)

func updateHpBar():
	var precent = (float(HP)/float(MAXHP))*100.0
	hpBar.value = precent
	hpLabel.text = str(HP)
	if (HP < 0):
		dead = true
		Global.send_delete_player_sig()
		Global.name2ref = name2ref
		spectator.activate()
		visible=false
		#queue_free()

func puppet_hit(other,damage):
	var refOther = name2ref[other]
	print(refOther)
	refOther.hitSound.play(0.3)
	refOther.HP -= damage
	refOther.hpBar.set_value(float(refOther.HP)/float(refOther.MAXHP))

func revive():
	visible=true
	#respawn point 
	global_transform.origin = Vector3(0,3.0,0)
	dead=false
	Global.send_revive_signal()
	HP = 100
