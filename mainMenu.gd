extends Control

var single_map = preload("res://Playground.tscn")
var optionsMap = preload("res://options.tscn")
var multiWaiting = preload("res://multiWaiting.tscn")
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
	get_tree().change_scene_to_packed(optionsMap)


func _on_multi_pressed():
	get_tree().change_scene_to_packed(multiWaiting)
