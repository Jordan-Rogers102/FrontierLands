extends State

func enter(_prev_state: State) -> void:
	# Apply jump velocity
	player.velocity.y = player.JUMP_VELOCITY
	player.anim_player.play("jump")

func physics_update(delta: float) -> void:
	var input = Input.get_vector("left", "right", "up", "down")
	var direction = (player.transform.basis * Vector3(input.x, 0, input.y)).normalized()

	if direction:
		player.velocity.x = direction.x * player.speed
		player.velocity.z = direction.z * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.speed)

	# Apply gravity
	player.velocity.y -= player.gravity * delta

	player.move_and_slide()

	# Transition to another state once grounded
	if player.is_on_floor():
		if input.length() > 0:
			player.state_machine.change_state(player.move_state)
		else:
			player.state_machine.change_state(player.idle_state)
