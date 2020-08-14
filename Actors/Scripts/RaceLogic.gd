extends Spatial

signal FinishLineCrossed

onready var finish = $Finish



func _on_Finish_body_entered(body):
	if body == KinematicBody:
		print("finished?")
