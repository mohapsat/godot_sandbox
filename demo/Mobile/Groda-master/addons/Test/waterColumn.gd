#extends Node

var TargetHeight = 0.0
var Height = 0.0
var Speed = 0.0

func Update(dampening,tension):
	var x = TargetHeight-Height
	Speed += tension * x - Speed * dampening
	Height += Speed
	
func test():
	print("hello")