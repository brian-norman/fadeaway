extends KinematicBody2D


export (int) var speed = 200
export (int) var bullet_speed = 2000

var velocity = Vector2()

var bullet = preload("res://Bullet.tscn")


func _process(delta):
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("fire"):
		var bulletInstance = bullet.instance()
		bulletInstance.position = global_position
		bulletInstance.rotation_degrees = rotation_degrees
		bulletInstance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().root.add_child(bulletInstance)


func _physics_process(_delta):
	var direction = Vector2()
	if Input.is_action_pressed("move_left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		direction += Vector2(1, 0)
	if Input.is_action_pressed("move_up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		direction += Vector2(0, 1)

	move_and_slide(direction * speed)
