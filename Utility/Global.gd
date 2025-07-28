extends Node

signal pause
signal unpause
signal upgrade_menu_open(upgrade_menu: Menu)
signal game_state_changed(new_state: int)
signal stop_music
signal start_music

enum GAME_STATES {START_SCREEN, GAME_LOOP}
enum VFX_LEVELS {MINIMUM, MEDIUM, MAXIMUM}

var player: Player = null
var player_position: Vector2
var zone: Zone = null
var paused: bool = false
var game_time: int = 0

var zone_left: int
var zone_right: int
var zone_top: int
var zone_bottom: int

var music_active: bool = true
var sfx_active: bool = true
var vfx_level: int = VFX_LEVELS.MAXIMUM

func _init() -> void:
	set_process_mode(PROCESS_MODE_ALWAYS)
	pause.connect(pause_game)
	unpause.connect(unpause_game)

func pause_game() -> void:
	get_tree().paused = true
	paused = true

func unpause_game() -> void:
	get_tree().paused = false
	paused = false

#Makes node a child of a specific node
func add_child_to_specific_node(child : Variant, node : Variant) -> void:
	node.add_child(child)
	child.set_owner(node)

#Makes node a child of the root scene
func add_child_to_owner(child : Variant) -> void: 
	zone.add_child(child)
	child.set_owner(zone)

func add_child_to_node_deferred(child : Variant, node : Variant) -> void:
	node.call_deferred("add_child", child)
	child.set_owner(node)

func add_child_to_owner_deferred(child : Variant) -> void:
	zone.call_deferred("add_child", child)
	child.set_owner(zone)
