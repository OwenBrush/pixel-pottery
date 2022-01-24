extends Control

const JUNK_THRESHOLD = 0.3

var customers = []
var cell_vectors = []
var symmetry_score = 0
var final_score = 0

func _ready():
	hide()
	GameEvents.connect("session_end",self,"_on_session_end")
	GameEvents.connect("new_session",self,"_on_new_session")
	
func _on_new_session():
	customers.clear()
	cell_vectors.clear()
	symmetry_score = 0
	final_score = 0


func _on_session_end(cells:Dictionary)->void:
	show()
	cell_vectors = cells.keys()
	symmetry_score = Symmetry.score(cell_vectors)
	customers = $Customers.get_children()
	_score()
	
func _score()->void:
	if len(customers) == 0:
		_close_window()
		return
		
	var customer = customers.pop_front() as Customer
	var pot_type = Classification.identify_pot(cell_vectors, customer.model)
	var symmetry = Symmetry.score(cell_vectors)
	
	if symmetry <= customer.lower_symmetry_threshold-JUNK_THRESHOLD:
		pot_type = Globals.pot_type.junk
	
	
	var symmetry_met = _symmetry_met(customer, symmetry)
	var statements = _select_statements(customer,pot_type,symmetry_met)
	
	var text = statements[randi() % statements.size()]
	
	if not symmetry_met and not pot_type == Globals.pot_type.junk:
		text = _apply_qualifier(customer, text, symmetry)
		

	$ScoreCard/ReviewText.text = text
	$Portrait/CustomerName.text = customer.customer_name
	$Portrait/Background/Sprite.texture = customer.portrait
	if pot_type == Globals.pot_type.junk:
		$Portrait/Background/Sprite.frame = 2
	elif not symmetry_met:
		$Portrait/Background/Sprite.frame = 1
		final_score += 0.5
	else:
		$Portrait/Background/Sprite.frame = 0
		final_score += 1
		

func _select_statements(customer:Customer, pot_type:int, symmetry_met:float)->Array:
	match pot_type:
		Globals.pot_type.junk: return customer.junk_remarks
		Globals.pot_type.cup: 
								if symmetry_met: 	
									return customer.positive_cup_remarks
								else:
									return customer.negative_cup_remarks 
		Globals.pot_type.bowl: 
								if symmetry_met: 	
									return customer.positive_bowl_remarks
								else:
									return customer.negative_bowl_remarks 
		Globals.pot_type.decorative: 
								if symmetry_met: 	
									return customer.positive_decorative_remarks
								else:
									return customer.negative_decorative_remarks
	return []

func _apply_qualifier(customer:Customer, text:String, symmetry:float)->String:
	var qualifier = ''
	if symmetry > customer.upper_symmetry_threshold:
		var index = randi() % customer.too_much_symmetry.size()
		qualifier = customer.too_much_symmetry[index]
	elif symmetry < customer.lower_symmetry_threshold:
		var index = randi() % customer.too_much_symmetry.size()
		qualifier = customer.too_little_symmetry[index]
	return text+' '+qualifier
	
	
	

func _symmetry_met(c:Customer, sym:float)->bool:
	if sym >= c.lower_symmetry_threshold and sym <= c.upper_symmetry_threshold:
		return true
	else:
		return false
	
func _close_window():
	GameEvents.emit_final_score(final_score)
	hide()

	
	
#	classify_pot()
#	create_images_from_session_log()




func _on_Next_pressed():
	_score()
