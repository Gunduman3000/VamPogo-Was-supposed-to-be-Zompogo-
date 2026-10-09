extends Node2D
var p_state := false
@export var speed: float = 120.0
@export var player: Node2D
func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * speed * delta
	if p_state == true:
		player.corruption.value -= 3
		
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		p_state = true
		


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		p_state = false
