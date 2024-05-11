extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var coyoteJump: float = 0.0
var preJump: float = 0.0

var chargeJump: float = 0.0

var trail: CPUParticles2D

var resetPos: Vector2

func _ready():
	trail = get_node("Trail")
	resetPos = position

func _physics_process(delta):

	if Input.is_action_just_pressed("Reset"):
		position = resetPos
		velocity = Vector2(0, 0)

	if Input.is_action_just_pressed("Jump"):
		chargeJump = 0.0
	if Input.is_action_pressed("Jump"):
		chargeJump += delta
		chargeJump = clamp(chargeJump, 0.0, 0.5)

	if !is_on_floor():
		velocity.y += gravity * delta
		coyoteJump -= delta
		if Input.is_action_just_released("Jump"):
			preJump = 0.1
		preJump -= delta
	else:
		coyoteJump = 0.1

	# Handle jump.
	if (Input.is_action_just_released("Jump") || preJump > 0) && (is_on_floor() || coyoteJump > 0):
		preJump = 0.0
		velocity.y = JUMP_VELOCITY * (chargeJump + 0.5)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	trail.look_at(position + velocity.normalized())

	trail.angle_min = rad_to_deg(-trail.rotation)
	trail.angle_max = rad_to_deg(-trail.rotation)

	trail.scale_curve_y.set_point_value(0, 0.8 + clamp(0.2 - (0.2 * velocity.length()), 0.0, 0.2))
	trail.scale_curve_x.set_point_value(0, 1.0 + clamp(0.2 * velocity.length(), 0.0, 0.2))
