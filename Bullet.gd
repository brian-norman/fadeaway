extends RigidBody2D


func _on_Bullet_body_entered(body):
	if body.is_in_group("enemy"):
		body.die()
	queue_free()
