extends KinematicBody

# Export vars to play with
#-------------------------------------------------------------------------------
export var baseSpeed: float = 2.0
export var maxWalkSpeed: float  = 4.0
export var maxRunSpeed: float = 7.0

# onready vars that probably won't change
#-------------------------------------------------------------------------------
onready var theCamera: Camera = get_node("../Camera")
#-- Camera projection vectors for movement -- might be a problem with instantiation order
onready var forwardDir: Vector3 
onready var rightDir: Vector3
#-- Kinematics
onready var inputVector: Vector2
onready var dir: Vector3 = Vector3.ZERO
onready var vel: Vector3 = Vector3.ZERO
onready var speed: float
#-- Mesh Orientation
onready var mesh: Spatial = $meshPivot
onready var forward: Vector3 = mesh.transform.basis.z
onready var up: Vector3 = mesh.transform.basis.y
onready var right: Vector3 = mesh.transform.basis.x
#-- State
onready var state: String = "idle"
onready var isRunning: bool = false
#-- Animation
onready var animTree: AnimationTree = $meshPivot/mixamoBase/AnimationTree
#-- Misc
onready var gravity: Vector3 = -9.8 * Vector3.UP
#--
onready var summonParticle: Spatial = $Summon
onready var summonCoolDown: float = 0.0

func _ready():
	speed = baseSpeed
	if theCamera.get("forwardProj") != null:
		forwardDir = theCamera.get("forwardProj")
		rightDir = theCamera.get("rightProj")
	else:
		print("Cam hasn't been made yet or something")
	
	# initiliaze particles
	for N in summonParticle.get_children():
		N.emitting = false
	
func _physics_process(delta):
	checkState(delta)
	getInput()
	setMoveState(delta)
	setAnimation()
	move(delta)

func getInput():
	if Input.is_action_pressed("runBtn"):
		isRunning = true
#	elif Input.is_action_just_pressed("summonBtn"):
#		summon()
	else:
		isRunning = false
	
	inputVector.x = (Input.get_action_strength("leftRight") - Input.get_action_strength("leftLeft"))
	inputVector.y = (Input.get_action_strength("leftUp") - Input.get_action_strength("leftDown"))

func gravityCheck():
	if is_on_floor():
		gravity = (Vector3.ZERO)
	else:
		gravity = (-9.8 * Vector3.UP)
		
func move(delta):
	gravityCheck()
	if inputVector != Vector2.ZERO:
		dir = (inputVector.x * rightDir + inputVector.y * -forwardDir).normalized()
		vel = dir * speed + gravity
		vel = move_and_slide(vel, Vector3.UP, false, 4, PI / 2.5, true)
	else:
		vel = Vector3.ZERO
		
	getMeshDir()
	
func setMoveState(delta):
	if isRunning:
		state = "running"
		speed = lerp(speed, maxRunSpeed, delta)
	elif !isRunning and Vector2(vel.x, vel.z).length() > 0.5:
		state = "walking"
		speed = lerp(speed, maxWalkSpeed, 5.0 * delta)
	else:
		state = "idle"
		speed = baseSpeed
		
func setAnimation():
	match state:
		"idle":
			animTree.set("parameters/idleToWalk/blend_amount", 0.0)
			animTree.set("parameters/walkToRun/blend_amount", 0.0)
		"walking":
			animTree.set("parameters/idleToWalk/blend_amount", 1.0)
			animTree.set("parameters/walkToRun/blend_amount", 0.0)
		"running":
			animTree.set("parameters/idleToWalk/blend_amount", 0.0)
			animTree.set("parameters/walkToRun/blend_amount", 1.0)

func getMeshDir():
#	forward = dir
#	right = dir.cross(up)
#	mesh.transform.basis.x = right
#	mesh.transform.basis.z = forward
	mesh.look_at(translation - dir, Vector3.UP)
	pass
	
func summon():
	#summonParticle.translation = translation + mesh.transform.basis.z + 0.5 * mesh.transform.basis.y
	if summonCoolDown == 0.0:
		print("we're in here now")
		summonCoolDown = 2.1
		for N in summonParticle.get_children():
				N.emitting = true
	else:
		pass

# should be saving stuff in a container of some kind, ok for now
# also, should be using a Timer object probably
func checkState(delta):
	if summonCoolDown != 0.0:
		summonCoolDown -= delta
