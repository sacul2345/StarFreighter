extends RigidBody3D

@export var SENSITIVTY : float
@export var ACCELERATION : float
@export var MAX_SPEED : float
@export var AIR_ACCEL : float
@export var FRICTION : float
@export var JUMP_POWER : float

@export var camera : Camera3D
@export var groundCast : ShapeCast3D
@export var standCollide : CollisionShape3D
@export var crouchCollide : CollisionShape3D

@export var debugMarker : MeshInstance3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation.y -= event.relative.x * SENSITIVTY
		camera.rotation.x -= event.relative.y * SENSITIVTY
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float):
	if onGround():
		applyFriction(delta)
		
	var inputVector = Input.get_vector("left","right","backward","forward")
	#if inputVector == Vector2.ZERO:
		#return
	
	var forward = -camera.global_basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = camera.global_basis.x
	right.y = 0
	right = right.normalized()
	
	var wish_dir = (forward * inputVector.y + right * inputVector.x).normalized()
	
	if Input.is_action_just_pressed("jump") && onGround():
		linear_velocity.y = JUMP_POWER
		
	if Input.is_action_pressed("crouch"):
		standCollide.disabled = true
		crouchCollide.disabled = false
		groundCast.target_position.y = -1
	else:
		standCollide.disabled = false
		crouchCollide.disabled = true
		groundCast.target_position.y = -2
		
	if wish_dir != Vector3.ZERO:
		if onGround():
			accelerate(wish_dir, MAX_SPEED, ACCELERATION, delta)
		else:
			accelerate(wish_dir, MAX_SPEED, AIR_ACCEL, delta)
			
	debugMarker.global_position = groundCast.get_collision_point(0)

func accelerate(wishDir: Vector3, wishSpeed: float, accel: float, delta: float):
	
	var currentSpeed = Vector3(linear_velocity.x,0,linear_velocity.z).dot(wishDir)
	var addSpeed = wishSpeed - currentSpeed
	
	if addSpeed <= 0:
		return
	
	var accelSpeed = accel * delta * wishSpeed
	accelSpeed = min(accelSpeed, addSpeed)
	
	linear_velocity.x += accelSpeed * wishDir.x
	linear_velocity.z += accelSpeed * wishDir.z


func applyFriction(delta):
	var horizontalVelocity = Vector3(linear_velocity.x,0,linear_velocity.z)
	
	var speed = horizontalVelocity.length()
	if speed < 0:
		return
	
	var damp = speed * FRICTION * delta
	speed = max(speed-damp, 0.0)
	
	horizontalVelocity = horizontalVelocity.normalized() * speed
	
	linear_velocity.x = horizontalVelocity.x
	linear_velocity.z = horizontalVelocity.z

func onGround() -> bool:
	var surfaceNormal : Vector3
	var slopeAngle : float
	
	if groundCast.is_colliding():
		surfaceNormal = groundCast.get_collision_normal(0)
		slopeAngle = rad_to_deg(surfaceNormal.angle_to(Vector3.UP))
		if slopeAngle < 30 && groundCast.is_colliding():
			return true
		else:
			return false
	return false
