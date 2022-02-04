extends CanvasLayer


func show(position):
	$Panel.show()
	$Panel.rect_position = Vector2(position.x + 50, position.y + 50)


func hide():
	$Panel.hide()
