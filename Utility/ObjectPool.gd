extends Node
class_name ObjectPool

var pool: Array
var pool_index: int = 0

func flush() -> void:
	pool.clear()

"""
func generate(new_obj: Variant) -> void:
	pool.append(new_obj)

func acquire() -> Variant: #GRAB WHAT IS IN THE POOL
	var new_obj: Variant
	
	#if pool_index >= pool.size():
	#	generate(new_obj)
	#else:
	#	new_obj = pool[pool_index]
	#	pool_index += 1
	
	new_obj.set_process(true)
	new_obj.set_physics_process(true)
	new_obj.show()
	
	return null

func release(new_obj: Variant) -> void: #ADD IT BACK TO POOL
	pool.append(new_obj)
	new_obj.hide()
	new_obj.set_process(false)
	new_obj.set_physics_process(false)
"""


"""
#example of fire method to refer to

func fire_bullet(count):
	$ShootDelay.start(fire_rate)
	#	bullet_array[index].set_process(true)
	#	var pos = global_position.direction_to(get_global_mouse_position()).rotated(count * step - angle / 2 + step / 2) * distance
	new projectile = draw_from_pool() #must initialize with add_to_pool
	
	bullet_array[index].global_position = global_position + pos
	bullet_array[index].rotation = pos.angle()
	bullet_array[index].show()
	index += 1
	if index == array_size:
		index = 0

#>re: object pooling:	perhaps define a variable that keeps track of the smallest free index 
						in an object pool to reduce traversing the entire pool
"""
