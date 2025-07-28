extends Node
class_name Application

var game_state: int = -1
var current_scene: Variant
var next_scene: Variant

func _ready() -> void:
	Global.game_state_changed.connect(change_game_state)
	Global.game_state_changed.emit(Global.GAME_STATES.START_SCREEN)

func load_scene(scene_path: String) -> void:
	flush_current_tree(self)
	
	next_scene = load(scene_path).instantiate()
	add_child(next_scene)
	
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	
	current_scene = next_scene

func change_game_state(new_state: int) -> void:
	get_tree().paused = true
	game_state = new_state
	match game_state:
		Global.GAME_STATES.GAME_LOOP: load_scene(FilePaths.MAIN_ZONE)
		Global.GAME_STATES.START_SCREEN: load_scene(FilePaths.START_SCREEN)
		_:
			print("Invalid gameplay state (SceneManager.gd, change_game_state())")
	get_tree().paused = false

func flush_current_tree(root: Variant) -> void:
	for game_scene in root.get_children():
		game_scene.queue_free()
