extends GL_Node


func _ready():
	super._ready()
	_set_title("Invert")
	_create_row("Value",0.0,0.0,false,0.0,1.0)
	_update_visuals()

func _process(delta):
	super._process(delta)
	apply_pick_values()
			
	rows["Value"]["output"] = 1.0 - rows["Value"]["input"]
	_send_input("Value")
