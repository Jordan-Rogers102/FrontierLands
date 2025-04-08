extends State

func enter(_prev_state: State) -> void:
	player.anim_player.play("move")

func physics_update(delta: float) -> void:
	var input = Input.get_vector("left", "right", "up", "down")
	if input == Vector2.ZERO:
		player.state_machine.change_state(player.idle_state)
		return

	var dir = (player.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	player.velocity.x = dir.x * player.speed
	player.velocity.z = dir.z * player.speed

	# Gravity
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.state_machine.change_state(player.jump_state)

	player.move_and_slide()
