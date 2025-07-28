extends Enemy
class_name Wing

const LEFT_MARGIN_LENIENCE : int = 32
const RIGHT_MARGIN_LENIENCE : int = 32

@onready var label = $Label

func on_ready_initialization() -> void:
	shot_timer = EnemyProjectileManager.ShotTimer
	shot_timer.timeout.connect(fire.bind(shot_timer, ENEMY_SHOT, ENEMY_SHOT_DATA))
	shot_timer.set_wait_time(randf_range(SHOT_WAIT_MIN, SHOT_WAIT_MAX))
	shot_timer.start()
	velocity.x *= [1, -1].pick_random()

func _physics_process(_delta):
	label.position = Vector2(-20, -40)
	label.text = str(current_health)
	descend()
	
	if (velocity.x < 0 and global_position.x <= Global.zone_left - LEFT_MARGIN_LENIENCE) or (velocity.x > 0 and global_position.x >= Global.zone_right + RIGHT_MARGIN_LENIENCE):
		velocity.x *= -1

func on_death() -> void:
	shot_timer.stop()
