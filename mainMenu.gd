extends Control

var single_map = preload("res://Playground.tscn")
var optionsMap = preload("res://options.tscn")
var multiWaiting = preload("res://multiWaiting.tscn")
var listener = -1
var listening=false
# Called when the node enters the scene tree for the first time.
func _ready():
	discord_sdk.state = "in main menu"
	$Label.text = Global.version

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_single_pressed():
	get_tree().change_scene_to_packed(single_map)


func _on_options_pressed():
	$name.visible=false
	$VBoxContainer.visible=false
	$options.visible=true


func _on_multi_pressed():
	get_tree().change_scene_to_packed(multiWaiting)


func _on_button_pressed():
	$options/HBoxContainer2/FileDialog.set_filters(PackedStringArray(["*.png ; PNG Images"]))
	$options/HBoxContainer2/FileDialog.show()


func _on_file_dialog_file_selected(path):
	print("confirmed")
	
	print("res://assets/kenney_crosshair-pack/PNG/" + $options/HBoxContainer2/FileDialog.current_path)
	var fullpath = "res://assets/kenney_crosshair-pack/PNG/" + $options/HBoxContainer2/FileDialog.current_path
	var tex = load(fullpath)
	#print(typeof($options/HBoxContainer2/FileDialog.current_path))
	Global.crosshair=tex
	$options/HBoxContainer2/TextureRect.texture = Global.crosshair


func _on_color_picker_button_color_changed(color):
	Global.crosshair_color = color
	$options/HBoxContainer2/TextureRect.modulate = color


func _on_file_dialog_song_file_selected(path):
	print(path)
	Global.customMusic = AudioStreamMP3.new()
	var file = FileAccess.open(path,FileAccess.READ)
	Global.customMusic.data = file.get_buffer(file.get_length())

func _on_button_song_pressed():
	$options/HBoxContainer4/FileDialogSong.popup()


func _on_button_car_pressed():
	$"options/car interact/Button car interact".text = "-press any key-"
	InputMap.action_erase_events("car interact")
	listener = "car interact"
	listening=true
	
	
func _unhandled_key_input(event):
	if listening:
		print(event)
		InputMap.action_add_event(listener,event)
		get_node("options/"+listener+"/Button "+listener).text = event.as_text()
		listening=false


func _on_exit_pressed():
	if $options.visible:
		$options.visible=false
		$VBoxContainer.visible =true


func _on_button_flashlight_pressed():
	var action = "flashlight"
	$"options/flashlight/Button flashlight".text = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_next_spectate_pressed():
	var action = "next_spectate"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_previous_spectate_pressed():
	var action = "previous_spectate"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_grapple_pressed():
	var action = "grapple"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_crouch_pressed():
	var action = "crouch"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_h_slider_2_value_changed(value):
	var volume = value
	var As = AudioServer
	As.set_bus_volume_db(0,value)
	print(As.get_bus_volume_db(As.get_bus_index("Master")))


func _on_gun_slider_value_changed(value):
	var As = AudioServer
	As.set_bus_volume_db(1,value)
	print(As.get_bus_volume_db(As.get_bus_index("GunShots")))
