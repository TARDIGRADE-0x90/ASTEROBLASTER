extends Node
class_name Poolable

signal released(obj)

@export var Active: bool = false

func _ready() -> void:
	pass
	#tree_exited.connect(destroy)

func show_poolable(process: bool = true, physics_process: bool = true, monitoring: bool = false, monitorable: bool = false) -> void:
	owner.show()
	
	if process: 
		owner.set_process(true)
	
	if physics_process: 
		owner.set_physics_process(true)
	
	if monitoring and owner.is_class("Area2D"): 
		owner.set_monitoring(true)
	
	if monitorable and owner.is_class("Area2D"): 
		owner.set_monitorable(true)

func hide_poolable(process: bool = true, physics_process: bool = true, monitoring: bool = false, monitorable: bool = false) -> void:
	owner.hide()
	
	if process: 
		owner.set_process(false)
	
	if physics_process: 
		owner.set_physics_process(false)
	
	if monitoring and owner.is_class("Area2D"): 
		owner.call_deferred("set_monitoring", false)
	
	if monitorable and owner.is_class("Area2D"): 
		owner.call_deferred("set_monitorable", false)

func destroy() -> void:
	owner.call_deferred("queue_free")
