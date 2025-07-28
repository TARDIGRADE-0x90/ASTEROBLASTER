extends Area2D
#NOTE: Collision Mask is set to 2
const Y_SPEED: float = 2.25

var x_speed: float = 0
var y_speed: float = 0

func _ready() -> void:
	y_speed = Y_SPEED
	area_entered.connect(grant_scrap)

func _physics_process(delta) -> void:
	translate(Vector2(x_speed, y_speed))
	if (global_position.y < Global.zone_top or global_position.y > Global.zone_bottom):
		queue_free()

func grant_scrap(area: Area2D) -> void:
	if area.owner == Global.player:
		Global.player.scrap_collected.emit()
		queue_free()
