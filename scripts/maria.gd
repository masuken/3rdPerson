#maria_jj08
extends CharacterBody3D

# キャラクターの速度
var speed = 5.0 #10.0
var dir = Vector3.ZERO
var vel = Vector3.ZERO

const gravity = 50  #50
# キャラクターのジャンプ力
var jump_power = 15  #15

var blast_x
var blast_z

var dis = Vector3.ZERO


var slide_vel = Vector3.ZERO


var is_moving = false
var is_falling = false
var is_reaching_item = false
var is_being_blown_away = false
var combo_number = 0


var reached_item = null
var target_pickup_item = null

@export var friction = 0.3
@export var friction_slide = 0.02#0.03
@export var angular_accelerration = 10
@export var backContainer: Node3D

@export var visionArea:Area3D
@export var visionRayCast:RayCast3D


@onready var springArm = $SpringArm3D
@onready var _model = $maria_packed/Armature
@onready var _myTree = $maria_packed/AnimationTree7
@onready var _playback = _myTree.get("parameters/playback")


var state_name = "hands_free"



func _process(delta):
#func _physics_process(delta: float) -> void:
	# キャラクターの移動
	move_and_slide()

	#重力の影響を受ける
	velocity.y -= gravity * delta  

	input_control(delta)
	check_touching_item()
	update_animation()


func _on_vision_timer_timeout() -> void:
	
	"""
	if visionRayCast.is_colliding():
			var collider = visionRayCast.get_collider()
			print(collider.name)
			if collider.is_in_group("enemy"):
				visionRayCast.debug_shape_custom_color = Color(0,255,0) #緑
			else:
				visionRayCast.debug_shape_custom_color = Color(0,0,255) #青
	"""
	
	if visionRayCast.is_colliding():
		var collider = visionRayCast.get_collider()
		if !collider.is_in_group("enemy"):
			visionRayCast.debug_shape_custom_color = Color(0,0,255) #青
	else:
		visionRayCast.debug_shape_custom_color = Color(0,0,255) #青
			

	var overlaps = visionArea.get_overlapping_bodies()
	if overlaps.size() > 0:	
		for overlap in overlaps:
			
			if overlap.is_in_group("enemy"):
				#visionRayCast.debug_shape_custom_color = Color(0,255,0) #緑
				#var enemyPosition = overlap.global_transform.origin
				var enemyPosition = overlap.global_position
				var targetPosition = Vector3(enemyPosition.x, 1, enemyPosition.z)
				visionRayCast.look_at(targetPosition, Vector3.UP)
				visionRayCast.rotate_object_local(Vector3.UP, PI)
				visionRayCast.force_raycast_update()
			
				if visionRayCast.is_colliding():
					var collider = visionRayCast.get_collider()
					#print(collider.name)
					if collider.is_in_group("enemy"):
						visionRayCast.debug_shape_custom_color = Color(0,255,0) #緑
					else:
						visionRayCast.debug_shape_custom_color = Color(0,0,255) #青
				
	
					
func check_touching_item():
	
	var item_bodies = $bodyCotainer.get_overlapping_bodies()
	#print("チェック")
	if item_bodies:
		print("タッチ")
		
		
		for item_body in item_bodies:
			#print(item_body)
			
			if item_body.has_method("getWeapon"):
				item_body.getWeapon(backContainer)
				return
				
			if item_body.has_method("pick_up"):
				is_reaching_item = true
				
				#print(reached_item)
				
				
				if reached_item: 
					print("もうターゲットしてるのでリターン")
					return
				
				if state_name == "carry_luggage":
					print("もう持ってるのでリターン")
					return
	
				reached_item = item_body
				target_pickup_item = item_body
	else:
		reached_item = null
		is_reaching_item = false
		
		
func input_control(delta):
	
	
	
	dir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	dir = dir.rotated(Vector3.UP, springArm.rotation.y).normalized()
	
	movement_lock()
	
	
	if dir.x == 0:
		vel.x = lerp(vel.x, 0.0, friction)
	if dir.z == 0:
		vel.z = lerp(vel.z, 0.0, friction)
	
	if dir.x != 0:
		vel.x = dir.x * speed
	if dir.z != 0:
		vel.z = dir.z * speed
	
	velocity.x = vel.x
	velocity.z = vel.z



	if dir.x !=0 or dir.z != 0:
		_model.rotation.y = lerp_angle(_model.rotation.y, atan2(dir.x, dir.z), delta * angular_accelerration)
		is_moving = true
	else:
		is_moving = false
	
	
	# ジャンプの処理
	if is_on_floor() && Input.is_action_just_pressed("ui_accept"):
		
		if state_name == "hands_sword":
			_playback.travel("jump_attack")
		else:
			_playback.travel("jump")
	
	if Input.is_action_just_pressed("b"):
		_playback.start("blown_away_2")
	
	# 武装
	if Input.is_action_just_pressed("ui_text_indent"):
		if state_name == "hands_sword":
			_playback.travel("hands_free")
			state_name = "hands_free"
		else:
			_playback.travel("hands_sword")
			state_name = "hands_sword"
		
	
	# ものを持つ、または置く
	if Input.is_action_just_pressed("p"):
		check_pickup_or_unload()
		
	# 攻撃
	if Input.is_action_just_pressed("x"):
		
		if state_name == "hands_free":
			#"""
			var current_node = _playback.get_current_node()
			current_node = _playback.get_current_node()
			
			if current_node == "hands_free":
				_playback.travel("atk1")
				combo_number = 0
			if current_node == "atk1":
				_playback.travel("atk2")
				combo_number += 1
				#print(combo_number)
			if current_node == "atk2" or combo_number > 1:
				_playback.travel("atk3")	
			
				combo_number = 0
			#"""
			#_playback.travel("atk3")

		elif state_name == "hands_sword":
			var current_node = _playback.get_current_node()
			current_node = _playback.get_current_node()
			
			if current_node == "hands_sword":
				_playback.travel("s_atk1")
				#combo_number = 0
			if current_node == "s_atk1":
				_playback.travel("s_atk2")
				#combo_number += 1
				
				#combo_number = 0
			
			#_playback.travel("s_atk")
				
		elif state_name == "carry_luggage":
			 #荷物を持ってたら投げる
			_playback.travel("throw")
		
			state_name = "hands_free"
		

func movement_lock():
	var current_node = _playback.get_current_node()
	
	if current_node == "atk1" or current_node == "atk2" or current_node == "atk3":
		dir.x = 0
		dir.z = 0
	elif current_node == "s_atk1" or current_node == "s_atk2":
		dir.x = 0
		dir.z = 0
	elif current_node == "sword_armed" or current_node == "sword_unarmed":
		dir.x = 0 
		dir.z = 0
	elif current_node == "blown_away_2" or current_node == "blown_away_3" or current_node == "standUp":
		dir.x = 0
		dir.z = 0
	elif current_node == "pickup" or current_node == "pickup2" or current_node == "pickup3" or current_node == "pickup4":
		dir.x = 0 
		dir.z = 0

func update_animation():
	
	#print(state_name)
	if is_moving == true:
		_myTree.set("parameters/" + state_name + "/walk_Transition/transition_request", "state_1")
	else:
		_myTree.set("parameters/" + state_name + "/walk_Transition/transition_request", "state_0")
	
	if is_being_blown_away == false:
	
		if !is_on_floor() and velocity.y < 0:
			print("落下中")
			is_falling = true
			_playback.travel("falling")
		
		#ジャンプ着地
		if is_on_floor() and is_falling == true:
			print("着地へトラベル")
			is_falling = false
			_playback.travel("landing")
	else:
		
		#爆風で吹き飛ばされている 
		if !is_on_floor():
			slide_vel.x = -blast_x * 10
			slide_vel.z = -blast_z * 10
			velocity.x = slide_vel.x
			velocity.z = slide_vel.z
		
		#吹き飛ばされて着地
		if is_on_floor():
			#滑ってる
			_playback.travel("blown_away_3")
			slide_vel.x = lerp(slide_vel.x, 0.0, friction_slide)
			slide_vel.z = lerp(slide_vel.z, 0.0, friction_slide)
			velocity.x = slide_vel.x
			velocity.z = slide_vel.z
			body_collition_off()
			
			#止まった
			if slide_vel.x < 0.025 and slide_vel.x > -0.025 and slide_vel.z < 0.025 and slide_vel.z > -0.025:
				is_being_blown_away = false
				_playback.travel("standUp")
				



func add_velocity_y():
	#ジャンプ発動
	print("ジャンプ発動")
	velocity.y = jump_power

func add_blast():
	is_being_blown_away = true
	velocity.y = 15
	blast_x = sin(_model.rotation.y)
	blast_z = cos(_model.rotation.y)
	body_collition_on()


func check_pickup_or_unload():
	
	if state_name == "carry_luggage":
		unload_travel()
	
	elif is_reaching_item == true:
		target_pickup_item.freeze = true
		pickup_travel()
		
		
func pickup_travel():
	face_the_item()
	_playback.travel("carry_luggage")
	state_name = "carry_luggage"
	

func unload_travel():
	_playback.travel("hands_free")
	state_name = "hands_free"
	
	
func pickup():
	target_pickup_item.pick_up($maria_packed/Armature/GeneralSkeleton/handAttachment/armContainer)
	verticalize_item_on()
	reached_item = null
	
func unload():
	target_pickup_item.let_go()
	verticalize_item_off()
	


func verticalize_item_on():
	target_pickup_item.is_verticalized = true
	
func verticalize_item_off():
	print("end")
	target_pickup_item.is_verticalized = false


func throw_objet():
	var dir = Vector3()
	dir.x = sin(_model.rotation.y)
	dir.z = cos(_model.rotation.y)
	dir.x = dir.x * 10#8
	dir.z = dir.z * 10#8
	dir.y = 4.0#3.0
	target_pickup_item.throw_object(dir)
	reached_item = null

func face_the_item():
	#_model.rotation.y = lerp_angle(_model.rotation.y, atan2(dir.x, dir.z), delta * angular_accelerration)
	dis.x = target_pickup_item.position.x - self.position.x
	dis.z = target_pickup_item.position.z - self.position.z
	
	_model.rotation.y = atan2(dis.x, dis.z)



func reset_state():
	#元いたステートに戻る
	if state_name == "hands_free":
		_playback.travel("hands_free")
		
	if state_name == "hands_sword":
		_playback.travel("hands_sword")
	
	#持っていた荷物は落とす
	if state_name == "carry_luggage":
		_playback.travel("hands_free")
		state_name = "hands_free"
	
	
func body_collition_on():
	#body_Container.set_collision_layer_value(4, true)
	$bodyCotainer.set_collision_layer_value(4, true)
	pass
	
func body_collition_off():
	$bodyCotainer.set_collision_layer_value(4, false)
	pass


