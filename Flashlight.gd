extends Area2D

export (bool) var on_floor = true
export (bool) var on = false
export (bool) var hovered = false
export (bool) var hovering_player_name = null


signal pick_up(player_name)


func _ready():
	$Light.enabled = on
	$PickExplainer.hide()


func _input(event):
	if event.is_action_pressed("pick_up") and hovered and is_network_master():
		emit_signal("pick_up", hovering_player_name)
		queue_free()


func switch():
	rpc("switch_light")


remotesync func switch_light():
	on = not on
	$Light.enabled = on


func _on_Flashlight_body_entered(body):
	if body.is_in_group("player") and on_floor and is_network_master():
		$PickExplainer.show(position)
		hovered = true
		hovering_player_name = body.name


func _on_Flashlight_body_exited(body):
	if body.is_in_group("player") and on_floor and is_network_master():
		$PickExplainer.hide()
		hovered = false
		hovering_player_name = null
