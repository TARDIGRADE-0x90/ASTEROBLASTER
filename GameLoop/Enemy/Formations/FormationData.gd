extends Node
class_name FormationData

enum TIER_ONE_PATTERNS {RIGHT_SWEEP, LEFT_SWEEP, LEFT_WING, RIGHT_WING}
#var formation_width: int = 2 #this is simply equal to the max value in a pattern

var tier_one_formations: Dictionary = {
	TIER_ONE_PATTERNS.RIGHT_SWEEP: [0, 1, 2, 3, 4],
	TIER_ONE_PATTERNS.LEFT_SWEEP: [4, 3, 2, 1, 0],
	TIER_ONE_PATTERNS.LEFT_WING: [2, 1, 0, 1, 2],
	TIER_ONE_PATTERNS.RIGHT_WING: [0, 1, 2, 1, 0]
}

func choose_tier_one_formation() -> Array[int]:
	var pattern: Array[int]
	pattern.assign(tier_one_formations.values().pick_random())
	return pattern

"""
alt solution proposal: make it a 2d array, with 2nd array an index for simultaneous spawn tracking
e.g
[0, 0] [4, 0] [1, 1] [3, 1] [2, 2]

the first array being which slot they pick, the second array being a track of which row they're at


Example:
	
	spawn cells
	0 1 2 3 4 5 6 7 8 9
	
	Let the pattern be:
	x x x O x x x x x x
	x x x x O x x x x x
	x x x x x O x x x x
	x x x x x x O x x x
	x x x x x x x O x x
	
	Anchor: (0 + 3); anchor index for formations roots at 0, and is summed with a random integer offset
	
	Within EnemyManager shall the offsets be assigned, for they must take into account the bounds of the
	spawn cell array; FormationData shall provide the width of formations for the EnemyManger to read
	
	Thus will formations generate in randomized positions
	
	Plan: let this be a series of integer arrays that EnemyManger reads I guess idk
	The offset applies to each index when a formation spawns enemies
	
	Each formation shall have a width that is read when considering boundary checks
	
	possible indices thus: 0 thru spawn_cells.size() - width
	
	It is possible that Formations may have to be their own object that is randomly chosen 
	
	in that example, you'd have an int array of [0, 1, 2, 3, 4]
	
	
	SIMULTANEOUS INDICES SOLUTION:
		Should a formation have enemies that spawn at the same time at different indices, e.g,
		
		O	X	X	X	O
		X	O	X	O	X
		X	X	O	X	X
		
		then you must spawn n number of enemies for that formation timer callback, n being the
		amount of enemies spawning in simultaneously; 
		this shall be handled by a While loop n times
		
		formation_pattern[0] = 0
		formation_pattern[1] = 4
		formation_pattern[2] = 1
		formation_pattern[3] = 3
		formation_pattern[4] = 2
		
		Note that the while loop can be called on each formation timer callback; this while loop will
		be in effect even if it's just 1 at a time (n = 1)
		
		for i in range(n)
			spawn formation_pattern[i]
		
		(if the array is uneven, which is checked by size % n != 0, then switch to single-reading of remaining indices)
		(or just find some better checking and handling later idk)
		(these patterns are going to be ugly ass hard code, i just want the interpretation of them to be clean and not hard-coded)
		
		do 0 and 1
		do 2 and 3
		do 4
		
"""
