extends Area2D


export (PackedScene) var Bullet
export (float) var fire_rate = 0.5
export (bool) var on_floor = true

var bullet_speed = 2000
var can_fire = true

var hovered = false
var hovering_player_name = null

signal pick_up(player_name)


func _ready():
	$PickExplainer.hide()


func _input(event):
	if event.is_action_pressed("pick_up") and hovered and is_network_master():
		emit_signal("pick_up", hovering_player_name)
		queue_free()


func _process(_delta):
	if Input.is_action_pressed("fire") and can_fire and not on_floor and is_network_master():
		rpc("shoot", get_tree().get_network_unique_id(), $BulletPoint.global_position, rotation_degrees, global_rotation)
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_fire = true


remotesync func shoot(player_id, bullet_position, bullet_rotation_degrees, player_global_rotation):
	$Gunshot.play()
	var bulletInstance = Bullet.instance()
	bulletInstance.player_id = player_id
	bulletInstance.position = bullet_position
	bulletInstance.rotation_degrees = bullet_rotation_degrees
	bulletInstance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(player_global_rotation))
	get_tree().root.add_child(bulletInstance)


func _on_Gun_body_entered(body):
	if body.is_in_group("player") and on_floor and is_network_master():
		$PickExplainer.show(position)
		hovered = true
		hovering_player_name = body.name


func _on_Gun_body_exited(body):
	if body.is_in_group("player") and on_floor and is_network_master():
		$PickExplainer.hide()
		hovered = false
		hovering_player_name = null
