extends Control
@onready var restart: Button = $restart
@onready var quit: Button = $quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart.pressed.connect(_on_restart_pressed)
	quit.pressed.connect(_on_quit_pressed)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
