extends Enemy
class_name Chariot

@onready var label = $Label

func _physics_process(_delta):
	label.position = Vector2(-20, -40)
	label.text = str(current_health)
	descend()
