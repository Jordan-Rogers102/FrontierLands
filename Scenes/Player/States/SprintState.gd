extends State

var stamina_bar = null  # We'll assign this from the player

const ACCELERATION = 20.0
const DECELERATION = 30.0
const SPRINT_SPEED = 9.0
const WALK_SPEED = 5.0
const MAX_STAMINA = 100.0  # Max stamina
const STAMINA_CONSUMPTION_RATE = 20.0  # How much stamina is consumed per second of sprinting
const STAMINA_REGEN_RATE = 10.0  # How much stamina regenerates per second when not sprinting

var last_input_vector := Vector2.ZERO
var current_stamina := MAX_STAMINA

func enter(_prev_state: State) -> void:
	# This is called when the state is entered.
	# Use the player reference to get to the StaminaBar.
	if player.has_node("Camera3D/StaminaBar"):
		stamina_bar = player.get_node("Camera3D/StaminaBar")
		# print("Stamina bar node found from player: ", stamina_bar)
	#else:
		# print("Failed to find StaminaBar under player!")
	
	# Start sprinting when entering sprint state
	player.speed = SPRINT_SPEED
	player.anim_player.play("move")

func physics_update(delta: float) -> void:
	# Check if the sprint key is still held down
	var is_sprinting = Input.is_action_pressed("player_run")
	# print("Is sprinting: ", is_sprinting)

	# Set the player's speed based on whether they're sprinting or walking
	if is_sprinting:
		if current_stamina > 0:
			player.speed = SPRINT_SPEED
			current_stamina -= STAMINA_CONSUMPTION_RATE * delta  # Consume stamina while sprinting
			player.anim_player.play("move")
			# print("Sprinting. Current stamina: ", current_stamina)
		else:
			player.speed = WALK_SPEED  # Stop sprinting if out of stamina
			player.anim_player.play("move")
			# print("Out of stamina, switching to walking. Current stamina: ", current_stamina)
	else:
		player.speed = WALK_SPEED  # Walking speed when not sprinting
		# Regenerate stamina when not sprinting
		current_stamina += STAMINA_REGEN_RATE * delta
		if current_stamina > MAX_STAMINA:
			current_stamina = MAX_STAMINA  # Cap stamina at maximum
			# print("Stamina fully regenerated. Current stamina: ", current_stamina)

	# Enforce walking if stamina is 0
	if current_stamina <= 0:
		player.speed = WALK_SPEED
		# print("Stamina is 0. Switching to walking.")

	# Update the stamina bar if it exists
	if stamina_bar:
		stamina_bar.value = current_stamina
		# print("Stamina bar value updated: ", stamina_bar.value)
	#else:
		# print("Stamina bar node is not found or not assigned!")

	# Movement logic...
	var input_vector = Input.get_vector("left", "right", "up", "down")
	var is_moving = input_vector.length() > 0
	var direction = Vector3.ZERO

	if is_moving:
		direction = (player.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	# Detect input direction reversal
	var flipped_x = sign(input_vector.x) != sign(last_input_vector.x) and input_vector.x != 0
	var flipped_y = sign(input_vector.y) != sign(last_input_vector.y) and input_vector.y != 0
	var input_flipped = flipped_x or flipped_y

	var target_velocity = Vector3.ZERO

	if is_moving:
		target_velocity.x = direction.x * player.speed
		target_velocity.z = direction.z * player.speed

		if input_flipped:
			player.velocity.x = target_velocity.x
			player.velocity.z = target_velocity.z
			# print("Input flipped — snapping velocity")
		else:
			player.velocity.x = move_toward(player.velocity.x, target_velocity.x, ACCELERATION * delta)
			player.velocity.z = move_toward(player.velocity.z, target_velocity.z, ACCELERATION * delta)
			# print("Accelerating. Target velocity: ", target_velocity)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, DECELERATION * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, DECELERATION * delta)
		# print("Decelerating... Current velocity: ", player.velocity)

	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	player.move_and_slide()
	last_input_vector = input_vector

	# State transitions...
	if not is_sprinting:
		if player.velocity.length() < 0.1:
			player.state_machine.change_state(player.idle_state)
	elif not is_moving and player.is_on_floor():
		if player.velocity.length() < 0.1:
			player.state_machine.change_state(player.idle_state)
	elif Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.state_machine.change_state(player.jump_state)
