extends State

const ACCELERATION = 20.0
const DECELERATION = 30.0

var last_input_vector := Vector2.ZERO

func enter(_prev_state: State) -> void:
	player.speed = 5.0
	player.anim_player.play("move")

func physics_update(delta: float) -> void:
	var input_vector = Input.get_vector("left", "right", "up", "down")
	var is_moving = input_vector.length() > 0
	var direction = Vector3.ZERO

	if is_moving:
		direction = (player.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	#print("---")
	#print("Input vector: ", input_vector)
	#print("Is moving: ", is_moving)
	#print("Velocity BEFORE update: ", player.velocity)

	# Detect input direction reversal
	var flipped_x = sign(input_vector.x) != sign(last_input_vector.x) and input_vector.x != 0
	var flipped_y = sign(input_vector.y) != sign(last_input_vector.y) and input_vector.y != 0
	var input_flipped = flipped_x or flipped_y

	var target_velocity = Vector3.ZERO

	if is_moving:
		target_velocity.x = direction.x * player.speed
		target_velocity.z = direction.z * player.speed

		if input_flipped:
			# Snap immediately to new direction to avoid sliding
			player.velocity.x = target_velocity.x
			player.velocity.z = target_velocity.z
			#print("Input flipped — snapping velocity")
		else:
			# Accelerate smoothly toward target
			player.velocity.x = move_toward(player.velocity.x, target_velocity.x, ACCELERATION * delta)
			player.velocity.z = move_toward(player.velocity.z, target_velocity.z, ACCELERATION * delta)

		#print("Target velocity: ", target_velocity)
	else:
		# Decelerate to zero
		player.velocity.x = move_toward(player.velocity.x, 0, DECELERATION * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, DECELERATION * delta)
		#print("Decelerating...")

	# Gravity
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	#print("Velocity AFTER update: ", player.velocity)
	player.move_and_slide()

	# Update last input
	last_input_vector = input_vector

	# Transitions
	if Input.is_action_pressed("player_run") and is_moving:
		player.state_machine.change_state(player.sprint_state)
	elif not is_moving and player.is_on_floor():
		if player.velocity.length() < 0.1:
			player.state_machine.change_state(player.idle_state)
	elif Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.state_machine.change_state(player.jump_state)
