extends Node
class_name Debris

const ZONE_BUFFER: int = 24

var points: Array[Vector2]
var origin: Vector2
var position: Vector2
var velocity: Vector2
var length: int
var width: float
var spin: int

func initialize(org: Vector2, pos: Vector2, vel: Vector2, l: int, w: float, s: int) -> void:
	origin = org
	position = pos
	velocity = vel
	length = l
	width = w
	spin = s
	assign_shape()

func assign_point(x_offset: float, y_offset: float) -> void:
	points.append(Vector2(position.x + x_offset, position.y + y_offset))

func assign_shape() -> void:
	var choice = randi_range(0, 4)
	match choice:
		0:
			make_line()
		1:
			make_leg()
		2:
			make_shell()
		3:
			make_plate()
		4:
			make_hull()
		_:
			print("should not be happening: Debris.gd , assign_shape()")

func make_line() -> void:
	assign_point(-length, 0)
	assign_point(length, 0)

func make_leg() -> void:
	assign_point(-length, 0)
	assign_point(length, 0)
	assign_point(length, 2 * -length)

func make_shell() -> void:
	assign_point(-length, -length)
	assign_point(length, length)
	assign_point(length, -length)
	assign_point(-length, length)

func make_plate() -> void:
	assign_point(-length, length)
	assign_point(length, 1.5 * length)
	assign_point(length, -length)
	assign_point(-length, length)

func make_hull() -> void:
	assign_point(-length, 0)
	assign_point(length, 0)
	assign_point(length, 1.5 * -length)
	assign_point(-length, 1.5 * -length)

func check_bound() -> bool:
	return position.x + origin.x > Global.zone_right + ZONE_BUFFER or position.x + origin.x < Global.zone_left - ZONE_BUFFER

