extends Node

onready var summonParticle: Spatial = $Summon

func _ready():
	for N in summonParticle.get_children():
		print(N)
		N.emitting = false
		
func _process(delta):
	if Input.is_action_pressed("runBtn"):
		for N in summonParticle.get_children():
			N.emitting = true
	
