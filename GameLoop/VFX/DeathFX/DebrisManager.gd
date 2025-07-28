extends Node2D
class_name DebrisManager

"""
Later (but possibly very significant?) priority:
IMPROVE EFFICIENCY OF THIS FOR LARGER (n > 700) DEBRIS COUNTS
(I'm uncertain if this is a priority, huge debris numbers like that is unlikely to be used)
"""

@export var VFXPoolable: Poolable

@onready var Lifetime = $Lifetime

enum SHAPES {LINE, LEG, SHELL, PLATE, HULL}

const ERR_POSITION_DATA: String = "Error in DebrisManager.gd - XData does not match size of YData"

const DEFAULT_COLOR: Color = Color(0.9, 0.9, 0.9)
const SPIN_SLOW: int = 38
const SPIN_MED: int = 75
const SPIN_FAST: int = 56
const LIFETIME: float = 0.5
const MIN_VEL: float = 0.0
const MAX_VEL: float = 3.0
const MIN_LENGTH: int = 8
const MAX_LENGTH: int = 15
const MIN_WIDTH: int = 1
const MAX_WIDTH: int = 4
const THIN_RATE: float = 0.05

var spins: Array[int] = [SPIN_SLOW, SPIN_MED, SPIN_FAST]
var color: Color = DEFAULT_COLOR

"""
IF YOU GET RANDOM, SEEMINGLY INEXPLICABLE CRASHES - LOOK BACK HERE
so far so good - add pooling to individual Debris pieces later
and see if there's anything else to make efficient because this shits up the framerate like crazy
"""
var debris = load(FilePaths.DEBRIS)
var frags: Array[Debris]

func _ready() -> void:
	Lifetime.wait_time = LIFETIME
	Lifetime.timeout.connect(delete)
	Lifetime.set_one_shot(true)
	Lifetime.start()

func spawn_debris(amount: int):
	for n in range(amount):
		var frag: Debris = debris.new()
		frag.initialize(global_position, Vector2(0, 0), Vector2(randf_range(MIN_VEL, MAX_VEL) * [1, -1].pick_random(), randf_range(MIN_VEL, MAX_VEL) * [1, -1].pick_random()), randi_range(MIN_LENGTH, MAX_LENGTH), randi_range(MIN_WIDTH, MAX_WIDTH), spins.pick_random() * [1, -1].pick_random())
		frags.append(frag) #NOTE: The Zero Vector above is because this is a RELATIVE transformation

func rotate_points(Vect: Array[Vector2], XCenter: int, YCenter: int, angle: float) -> void:
	var temp: int

	for n in range(Vect.size()):
		temp = ((Vect[n].x - XCenter) * cos(angle)) - ((Vect[n].y - YCenter) * sin(angle)) + XCenter
		Vect[n].y = ((Vect[n].x - XCenter) * sin(angle)) + ((Vect[n].y - YCenter) * cos(angle)) + YCenter
		Vect[n].x = temp

func translate_points(vec: Vector2, XDir: float, YDir: float) -> Vector2:
	vec.x += XDir
	vec.y += YDir
	return vec

"""
Marked to raise performance later
"""
func modify_color_alpha() -> void:
	color.a = sin(Lifetime.time_left * PI)

func _draw() -> void:
	if not frags.is_empty():
		for frag in frags:
			draw_polyline(frag.points, color, frag.width)

"""
Marked to raise performance later
"""
func _physics_process(_delta: float) -> void:
	queue_redraw()
	modify_color_alpha() #all fragments share same piece color; placing it in for loop unnecessary
	
	if not frags.is_empty():
		for frag in frags:
			rotate_points(frag.points, frag.position.x, frag.position.y, frag.spin)
			frag.position = translate_points(frag.position, frag.velocity.x, frag.velocity.y)
			frag.width -= THIN_RATE
			
			if frag.check_bound():
				frags.erase(frag)
				frag.call_deferred("queue_free")

func delete() -> void:
	frags.clear() #may or may not be issue later; consider if the elements in array are being cleared as well
	
	if VFXPoolable.Active:
		VFXPoolable.released.emit(self)
	else:
		call_deferred("queue_free")
