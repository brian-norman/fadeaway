extends Area2D

export (bool) var on_floor = true
export (bool) var on = false

func _ready():
	$Light.enabled = on
	$PickExplainer.hide()


func switch():
	print('switching')
	on = not on
	$Light.enabled = on


func _on_Flashlight_body_entered(body):
	if body.is_in_group("player") and on_floor:
		$PickExplainer.show(position)


func _on_Flashlight_body_exited(body):
	if body.is_in_group("player") and on_floor:
		$PickExplainer.hide()
