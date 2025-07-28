extends Enemy
class_name Supply

@onready var label = $Label

func _physics_process(_delta):
	label.position = Vector2(-20, -40)
	label.text = str(current_health)
	descend()

func handle_death_sfx() -> void:
	EnemySoundHandler.parse_sound(SFXLibrary.SOUNDS.EXPLOSION1)

func on_death() -> void:
	var scrap = load(FilePaths.SCRAP).instantiate()
	zone.call_deferred("add_child", scrap)
	scrap.global_position = global_position
