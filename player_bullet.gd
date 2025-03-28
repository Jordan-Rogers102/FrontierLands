extends Area3D
signal enemy_hit
var speed: float = 150.0
var damage: int = 20
# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	await get_tree().create_timer(3.0).timeout
	destroy()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform.origin -= transform.basis.z.normalized() * speed * delta
	
func _on_body_entered(body):
#	print("bullet hit")
#	print (body.name)
	if body.has_method("take_damage"):
#		print("ow")
		body.take_damage(damage)
		enemy_hit.emit()
		destroy()

func destroy():
	queue_free()
