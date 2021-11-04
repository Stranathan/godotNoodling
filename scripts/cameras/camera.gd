#(Ian)
#Camera position is inited in ready

extends Camera

# Export vars to play with
#-------------------------------------------------------------------------------
export var camHeight: float = 5.5
export var theta: float = (PI / 3) # the radial angle
export var phi: float = (PI / 4)   # the azimuthal angle
export var orthogonal: bool = false
export var orthoBoxWidth: float = 10
# onready vars that probably won't change
#-------------------------------------------------------------------------------
onready var thePlayer: KinematicBody = get_node("../player")
onready var camOffset: Vector3
#-- basis vars
onready var forward: Vector3 = transform.basis.z
onready var up: Vector3 = transform.basis.y
onready var right: Vector3 = transform.basis.x
#-- spherical polar vars
onready var radius: float # spherical coord arm
onready var rho: float    # polar arm
# Projection vectors for player movement
#--
onready var forwardProj: Vector3
onready var rightProj: Vector3

func _ready():
	if(orthogonal):
		set_orthogonal(orthoBoxWidth, 0.05, 100)
	else:
		set_perspective (70, 0.05, 100)
		
	init()
	
func _physics_process(delta):
	translation = thePlayer.translation + camOffset
	pass

# Init Functions
#-------------------------------------------------------------------------------
func init():
	initPos()
	getCamDir(thePlayer.translation, Vector3.UP)
	setBases()
	getProjectedBasis()
	
func initPos():
	radius = camHeight / cos(theta)
	rho = radius * sin(theta)
	var xCoord: float = -rho * cos(phi)
	var zCoord: float = rho * sin(phi)
	camOffset = Vector3(xCoord, camHeight, zCoord)
	translation = thePlayer.translation + camOffset
	
# Basis functions
#-------------------------------------------------------------------------------
func getCamDir(target: Vector3, anUpSeed: Vector3):
#	the relative pos vector should be from the center of the player to the pinhole cam
#	forward = -(target + Vector3(0, translation.y, 0) - translation).normalized()
	forward = -(target - translation).normalized()
	right = -forward.cross(Vector3.UP).normalized()
	up = forward.cross(right).normalized()
	
func setBases():
	transform.basis.x = right
	transform.basis.y = up
	transform.basis.z = forward

func getProjectedBasis():
	# project cam forward vector onto plane
	# world up is length one, so no division needed
	var camForwardProjOntoNormal = -transform.basis.z.dot(Vector3.UP) * -Vector3.UP
	# the desired projection onto plane + the projection onto the normal must add to
	# be the forward vector
	forwardProj = (transform.basis.z - camForwardProjOntoNormal).normalized()
	var camRightProjOntoNormal = transform.basis.x.dot(Vector3.UP) * -Vector3.UP
	rightProj = (transform.basis.x - camRightProjOntoNormal).normalized()
		
# Debug Utils
#-------------------------------------------------------------------------------
func printBases():
	print(right)
	print(up)
	print(forward)
	
func printBasis():
	print(transform.basis)
