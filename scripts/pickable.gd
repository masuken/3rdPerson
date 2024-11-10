#pickable.gd
extends RigidBody3D

@onready var original_parent = get_parent()
@onready var original_collision_layer = collision_layer
@onready var original_collision_mask = collision_mask

var is_verticalized = false
var picked_up_parent = null

func _ready():
	set_gravity_scale(3.0)

func _process(delta):
	#if freeze == true:
	#	pass
	if is_verticalized == true:
		verticalize_item()
		

func verticalize_item():
	var rx = global_rotation.x
	var rz = global_rotation.z
	rotation.x -= rx
	rotation.z -= rz


#func verticalize_item_on():
#	flag_verticalize_item = true
	
#func verticalize_item_off():
#	flag_verticalize_item = false
	

func pick_up(set_point):
	#print("ピックアップ")

	freeze = true
	collision_layer = 0
	collision_mask = 0

	picked_up_parent = set_point

	original_parent.remove_child(self)
	picked_up_parent.add_child(self)

	position = Vector3.ZERO
	rotation = Vector3.ZERO


func let_go():
	
	var t = global_transform
	
	#reparent it
	picked_up_parent.remove_child(self)
	original_parent.add_child(self)
	picked_up_parent = null
	
	global_transform = t
	
	rotation = Vector3.ZERO
	
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	freeze = false


func throw_object(impulse):
	#print("投げた")
	
	var t = global_transform
	#reparent it
	picked_up_parent.remove_child(self)
	original_parent.add_child(self)
	picked_up_parent = null
	
	global_transform = t
	
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	freeze = false
	
	
	apply_central_impulse(impulse)
	
