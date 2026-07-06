extends RigidBody3D

@export var SENSITIVTY : float
@export var camera : Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation.y -= event.relative.x * SENSITIVTY
		camera.rotation.x -= event.relative.y * SENSITIVTY
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	var keyVector : Vector2 = Input.get_vector("forward","backward","left","right")
	var forceVector : Vector3 = camera.transform.basis * Vector3(keyVector.y,0,keyVector.x)
	
	apply_central_impulse(Vector3(forceVector.x,0,forceVector.z))
