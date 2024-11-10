#CombatController.gd
extends Node3D

 
@export var handContainer: Node3D
@export var backContainer: Node3D
#@export var itemContainer: Area3D
@onready var itemContainer: Area3D = get_node("../../ItemStatic3D/itemContainer")
@export var hand_R_Area: Area3D
@export var foot_R_Area: Area3D
@export var foot_L_Area: Area3D


@onready var _playback = $AnimationTree7.get("parameters/playback")


var isArmed = false
 


func switchParent():
	if isArmed == false:
		armedWeapon()
	elif isArmed == true:
		unarmedWeapon()


func armedWeapon():
	#print("武装")
	var parent = itemContainer.get_parent()
	parent.remove_child(itemContainer)
	handContainer.add_child(itemContainer)
	isArmed = true

func unarmedWeapon():
	#print("解除")
	var parent = itemContainer.get_parent()
	parent.remove_child(itemContainer)
	backContainer.add_child(itemContainer)
	isArmed = false
	
	

func sword_collition_on():
	
	itemContainer.set_collision_layer_value(4, true)
	
func sword_collition_off():
	
	itemContainer.set_collision_layer_value(4, false)
	
	
func foot_R_collition_on():
	foot_R_Area.set_collision_layer_value(4, true)
	pass
	
func foot_R_collition_off():
	foot_R_Area.set_collision_layer_value(4, false)
	pass

func foot_L_collition_on():
	foot_L_Area.set_collision_layer_value(4, true)
	pass
	
func foot_L_collition_off():
	foot_L_Area.set_collision_layer_value(4, false)
	pass


func hand_R_collition_on():
	hand_R_Area.set_collision_layer_value(4, true)
	pass
	
func hand_R_collition_off():
	hand_R_Area.set_collision_layer_value(4, false)
	pass
