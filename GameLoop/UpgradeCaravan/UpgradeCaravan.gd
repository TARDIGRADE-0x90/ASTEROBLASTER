extends Sprite2D
class_name UpgradeCaravan

signal passed

const ORIGIN := Vector2(0, 0)
const FLOAT_SPEED := Vector2(0, 3)

func _physics_process(delta):
	translate(FLOAT_SPEED)
	#if global.position
	if (global_position.y > Global.zone_bottom):
		passed.emit()
		clear()

func clear() -> void:
	queue_free()
