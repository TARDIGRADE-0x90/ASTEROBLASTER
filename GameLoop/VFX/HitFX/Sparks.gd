extends Node2D
class_name Sparks

const ERR_VEC_ARR_SIZE: String = "Array of origins does not match size of array of directions (Sparks.gd)"

const NULL_INT: int = -1
const NULL_VEC = Vector2(0, 0)
const TEST_COLOR = Color(0.9, 0.9, 0.9)
const DEFAULT_WIDTH: float = 1.0
const LIFETIME: float = 0.125
const FLY_FACTOR: float = 0.4
const ALPHA_DECAY_BUFFER: float = 1.75
const MIN_SPARKS: int = 3
const MAX_SPARKS: int = 5
const X_MIN: int = -20
const X_MAX: int = 20
const Y_MIN: int = 8
const Y_MAX: int = 20
const UP: int = -1
const DOWN: int = 1

@export var VFXPoolable: Poolable
@onready var Lifetime = $Lifetime

var facing: int = DOWN

var color: Color = TEST_COLOR
var origin = Vector2(300, 300)
var width: int = DEFAULT_WIDTH

var origins: Array[Vector2]
var directions: Array[Vector2]
var count: int = 0

func initialize(start: Vector2, c: Color = TEST_COLOR, y_face: int = DOWN) -> void:
	origin = start
	color = c
	facing = y_face
	initialize_vectors()
	
	if Lifetime: #restart due to pooling
		Lifetime.start()

func _ready() -> void:
	Lifetime.wait_time = LIFETIME
	Lifetime.timeout.connect(delete)
	Lifetime.set_one_shot(true)
	Lifetime.start()
	
	initialize_vectors()
	
	assert(origins.size() == directions.size(), ERR_VEC_ARR_SIZE)

func initialize_vectors() -> void:
	if origins.is_empty(): #initialize facing and origin if array has no indices
		count = randi_range(MIN_SPARKS, MAX_SPARKS)
		for n in range(count):
			origins.append(origin) #this assigns default origins that get reassigned later
			directions.append(Vector2(randi_range(X_MIN, X_MAX), randi_range(Y_MIN * facing, Y_MAX * facing)))
	else: 
		for n in range(origins.size()): #reposition the origins if there are existing indices
			origins[n] = origin

"""
Marked to raise performance later
"""
func translate_spark(vec: Vector2, vec2: Vector2) -> Vector2:
	vec.x += vec2.x * FLY_FACTOR
	vec.y += vec2.y * FLY_FACTOR
	return vec

func _draw() -> void:
	for n in range(directions.size()):
		draw_line(origins[n], Vector2(origins[n].x + directions[n].x, origins[n].y + directions[n].y), color, width)

func modify_color_alpha() -> void:
	color.a = sin(Lifetime.time_left * PI) * ALPHA_DECAY_BUFFER

func _physics_process(_delta: float) -> void:
	queue_redraw()
	modify_color_alpha()
	
	for n in range(origins.size()):
		origins[n] = translate_spark(origins[n], directions[n])

func delete() -> void:
	#wipe_entries(origins, NULL_VEC)
	#wipe_entries(directions, NULL_VEC)
	#origins.clear() #may or may not be issue later; consider if the elements in array are being cleared as well
	#directions.clear()
	
	if VFXPoolable.Active:
		VFXPoolable.released.emit(self)
	else:
		call_deferred("queue_free")
