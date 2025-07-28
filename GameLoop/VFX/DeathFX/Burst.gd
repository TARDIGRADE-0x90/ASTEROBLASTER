extends Sparks
class_name Burst

const BURST_LIFETIME: float = 0.25
#const BURST_DECAY_BUFFER: float = 2.5
const C_RANGE: float = 0.3
const MIN_BURST: int = 6
const MAX_BURST: int = 10
const MIN_WIDTH: int = 6
const MAX_WIDTH: int = 14
const FORCE: int = 14

#var burst_color: Color = TEST_COLOR
#var colors: Array[Color]
var widths: Array[int]

"""
The next three methods are carbon copies of the parent methods, idk if this is worth changing later or not though
"""
func _ready() -> void:
	Lifetime.wait_time = BURST_LIFETIME
	Lifetime.timeout.connect(delete)
	Lifetime.set_one_shot(true)
	Lifetime.start()
	
	initialize_vectors()
	
	assert(origins.size() == directions.size(), ERR_VEC_ARR_SIZE)

func initialize_vectors() -> void:
	if origins.is_empty():
		count = randi_range(MIN_BURST, MAX_BURST) #initialize if empty
		for n in range(count):
			#var deviation: float = randf_range(0, C_RANGE)
			origins.append(origin)
			directions.append(Vector2(randi_range(-FORCE, FORCE), randi_range(-FORCE, FORCE)) )
			#colors.append(Color(color.r - deviation, color.g - deviation, color.b - deviation, 1.0))
			widths.append(randi_range(MIN_WIDTH, MAX_WIDTH))
	else:
		for n in range(origins.size()): #reposition origins if there are extant indices
			origins[n] = origin

func _draw() -> void:
	for n in range(directions.size()):
		draw_line(origins[n], Vector2(origins[n].x + directions[n].x, origins[n].y + directions[n].y), color, widths[n])

#func modify_color_alpha() -> void:
#	for n in range(colors.size()):
#		colors[n].a = sin(Lifetime.time_left * PI) * BURST_DECAY_BUFFER 

func delete() -> void:
	#origins.clear() #may or may not be issue later; consider if the elements in array are being cleared as well
	#directions.clear()
	#widths.clear()
	#colors.clear()
	
	if VFXPoolable.Active:
		VFXPoolable.released.emit(self)
	else:
		call_deferred("queue_free")
