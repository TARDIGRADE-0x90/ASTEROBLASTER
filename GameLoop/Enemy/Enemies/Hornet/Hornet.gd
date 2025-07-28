extends Enemy
class_name Hornet

@onready var label = $Label

func on_ready_initialization() -> void:
	shot_timer = EnemyProjectileManager.ShotTimer
	shot_timer.timeout.connect(fire.bind(shot_timer, ENEMY_SHOT, ENEMY_SHOT_DATA))
	shot_timer.set_wait_time(randf_range(SHOT_WAIT_MIN, SHOT_WAIT_MAX))
	shot_timer.start()

func _physics_process(_delta):
	label.position = Vector2(-20, -40)
	label.text = str(current_health)
	descend()

func on_death() -> void:
	shot_timer.stop()
