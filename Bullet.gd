extends RigidBody2D

var player_id

func _on_Bullet_body_entered(body):
	if body.is_in_group("enemy"):
		body.die(player_id)
	queue_free()


func _on_Timer_timeout():
	queue_free()

