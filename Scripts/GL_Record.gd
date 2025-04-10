extends GL_Node
var timer:float
const sampleRate = 0.1
var recording:Dictionary
var oldTime:float = 0.000030042452 #sorta random number
var time:float = 0

func _ready():
	super._ready()
	_set_title("Record")
	special_condition = "Record Node"
	_create_row("Recording",false,null,true,false,0)
	_create_row("Current Time",0.0,0.0,false,0,0)
	_update_visuals()
	pass 

func _process(delta):
	super._process(delta)
	for key in rows:
		rows[key]["output"] = rows[key]["input"]
	apply_pick_values()
	time = float(rows["Current Time"]["output"])
	if recording:
		if timer <= 0:
			timer = sampleRate
			_traverse()
			_record()
		timer -= delta
	oldTime = time
	for key in rows:
		_send_input(key)

func _traverse():
	if time == oldTime:
		return
	for key in recording:
		if recording[key]["start"] == -1 || recording[key]["end"] == -1:
			continue
		if recording[key]["current"] == -1:
			recording[key]["current"] = recording[key]["start"]
		var current = recording[key]["list"][recording[key]["current"]]
		if time < oldTime: #rewind
			continue #fix pls
		else: #forward
			current = recursive_traverse_forward(key,current)
			recording[key]["current"] = current["id"]
			if current["time"] <= time:
				rows[key]["output"] = current["value"]
			
func recursive_traverse_forward(key:String,current:Dictionary) -> Dictionary:
	if current["time"] > time:
		if current["back"] != -1:
			return recursive_traverse_forward(key,recording[key]["list"][current["back"]])
	if current["time"] <= time:
		if current["forward"] != -1 && recording[key]["list"][current["forward"]]["time"] <= time:
			return recursive_traverse_forward(key,recording[key]["list"][current["forward"]])
	return current	
	
func _record():
	#{"id":12345,back":-1,"forward":-1,"time":1.01,"value":null}
	pass

func _create_row(name:String,input,output,picker:bool,pickDefault,pickFloatMaximum:float):
	super._create_row(name,input,output,picker,pickDefault,pickFloatMaximum)
	for key in rows:
		if !recording.has(key):
			recording[key] = {"start":-1,"end":-1,"current":-1,"list":{}}
