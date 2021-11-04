extends Spatial

# throwaway script to make spell spin -- should be possible
# inside particle material options

# Export vars to play with
#-------------------------------------------------------------------------------
export var rotationSpeed: float = 2.0

func _physics_process(delta):
	transform.basis = transform.basis.rotated(Vector3(0, 1, 0), rotationSpeed * delta)
	
	pass
