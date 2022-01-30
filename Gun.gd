extends StaticBody2D


export (PackedScene) var Bullet
export (float) var fire_rate = 0.5

var bullet_speed = 1000
var can_fire = true


func _process(_delta):
	if Input.is_action_pressed("fire") and can_fire:
		$GunshotSound.play()
		var bulletInstance = Bullet.instance()
		bulletInstance.position = $BulletPoint.global_position
		bulletInstance.rotation_degrees = rotation_degrees
		bulletInstance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(global_rotation))
		get_tree().root.add_child(bulletInstance)
		
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_fire = true
