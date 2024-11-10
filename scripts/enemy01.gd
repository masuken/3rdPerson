#enemy01
extends CharacterBody3D

@onready 

# キャラクターの速度
var speed = 20.0
var dir = Vector3.ZERO
var vel = Vector3.ZERO
const gravity = 30  #50
# キャラクターのジャンプ力
var jump_power = 15  #15

var blast_x
var blast_z

var dis = Vector3.ZERO

var slide_vel = Vector3.ZERO


var is_jumping = false
var is_falling = false
var is_moving = false
var is_having = false
var is_being_blown_away = false


@export var friction = 0.3
@export var friction_slide = 0.02#0.03
@export var angular_accelerration = 10
@export var body_Container: Node3D
@export var _player: Node3D

#@onready var springArm = $SpringArm3D
@onready var _model = get_node("./") #$enemy_packed/Armature
@onready var _myTree = $enemy_packed/AnimationTree2
@onready var _playback = _myTree.get("parameters/playback")

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var _BH: BeehaveTree = $BeehaveTree



func _process(delta):
#func _physics_process(delta: float) -> void:
	# キャラクターの移動
	move_and_slide()
	#重力の影響を受ける
	velocity.y -= gravity * delta
	
	#approach_player2()
	
	
	update_animation()
	
func approach_player(playerPos):
	#print(playerPos)
	pass
	"""
	if is_on_floor() and is_being_blown_away == false:
		face_to_player()
		var direction = Vector3()
		nav.target_position = playerPos#
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction
		#velocity = velocity.lerp(direction * speed)
		
		_playback.travel("walk")	
	"""
	
func approach_player2():
	#print("approach_player2")
	if is_on_floor() and is_being_blown_away == false:
		face_to_player()
		var direction = Vector3()
		nav.target_position = _player.global_position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction
		#velocity = velocity.lerp(direction * speed)
		
		_playback.travel("walk")
		
		

func punch_player():
	_playback.travel("punch")
	pass	

func update_animation():
	
	#吹き飛ばされている 
	if !is_on_floor() and is_being_blown_away == true:
		
		slide_vel.x = -blast_x * 4#8
		slide_vel.z = -blast_z * 4#8
		velocity.x = slide_vel.x
		velocity.z = slide_vel.z
		

	#吹き飛ばされて着地
	if is_on_floor() and is_being_blown_away == true:

		#滑ってる
		#_myTree.set("parameters/blown_away/ba_Transition/transition_request", "state_1")
		_playback.travel("blown_away_3")
		slide_vel.x = lerp(slide_vel.x, 0.0, friction_slide)
		slide_vel.z = lerp(slide_vel.z, 0.0, friction_slide)
		velocity.x = slide_vel.x
		velocity.z = slide_vel.z
		
		#止まった
		if slide_vel.x < 0.025 and slide_vel.x > -0.025 and slide_vel.z < 0.025 and slide_vel.z > -0.025:
			is_being_blown_away = false
			_myTree.set("parameters/conditions/flag_getup", true)
			
			#print("止まった") 
			#_myTree.set_inputs(0)
			body_collition_off()
			
			velocity.x = 0
			velocity.z = 0


func face_to_player():
	dis.x = _player.position.x - _model.position.x
	dis.z = _player.position.z - _model.position.z
	_model.rotation.y = lerp_angle(_model.rotation.y,  atan2(dis.x, dis.z), 0.02 * angular_accelerration)

func face_to_player_immediately():
	dis.x = _player.position.x - _model.position.x
	dis.z = _player.position.z - _model.position.z
	_model.rotation.y = atan2(dis.x, dis.z)
	

func body_collition_on():
	#print("エネミーこりおん")
	body_Container.set_collision_layer_value(4, true)
	pass
	
func body_collition_off():
	#print("エネミーこりオフ")
	body_Container.set_collision_layer_value(4, false)
	pass
	
func add_blast():
	
	is_being_blown_away = true
	velocity.y = 7
	body_collition_on()
	#face_to_player()
	face_to_player_immediately()
	blast_x = sin(_model.rotation.y)
	blast_z = cos(_model.rotation.y)

	#print("ブラスト") 
	
	
func reset_flag():
	_BH.enabled = true
	_myTree.set("parameters/conditions/flag_getup", false)



func _on_body_cotainer_area_entered(area):
	#print("敵にhit")
	_BH.enabled = false
	_playback.travel("blown_away_2")
	#_playback.travel("damage_front")
	pass # Replace with function body.
