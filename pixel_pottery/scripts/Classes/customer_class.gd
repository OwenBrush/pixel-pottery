extends Node

class_name Customer

export(String) var model = 'res://classifiers/model_0.json'
export(String) var customer_name
export(Texture) var portrait

export(float, 0, 1) var lower_symmetry_threshold
export(float, 0, 1) var upper_symmetry_threshold

export(Array, String) var junk_remarks = [
		"I don't even know what I'm supposed to be looking at...",
		"I think you need some more practice.",
		"Not for me...",
		"Oh, that's not really my taste.",
		"Could you make something more... functional?"
		]


export(Array, String) var positive_cup_remarks = [
		"This would make a great cup.",
		"I'd drink my coffee out of this.",
		"My new favorite cup!",
		"This cup is just perfect, I love it!",
		"This would be perfect for my cup collection"
		]
		
		
export(Array, String) var positive_bowl_remarks = [
		"I like this bowl a lot.",
		"I'd eat my cereal out of this.",
		"The bowl of my dreams!",
		"What a lovely bowl you've made.",
		"Nice bowl!"
		]
		
		
export(Array, String) var positive_decorative_remarks = [
		"This is a great decorative piece.",
		"This would make a lovely mantelpiece.",
		"This would be a good vessel to display something in.",
		"I'd use this as a centerpiece for family dinners.",
		"I think this pot is just lovely."
		]
		
		
export(Array, String) var negative_cup_remarks = [
		"I want to like this cup... but",
		"I've given this cup alot of thought, but",
		"I'm not sure I'd use this cup often.",
		"Could you make me a different cup?",
		"This cup wouldn't match my dinnerware."
		]
		
		
export(Array, String) var negative_bowl_remarks = [
		"I don't know if I'd eat out of this bowl.",
		"I can see you put alot of work into this bowl, but",
		"This bowl isn't quite right for me.",
		"I can see it's a well made bowl, but",
		"I'll pass on this bowl."
		]
		
		
export(Array, String) var negative_decorative_remarks = [
		"It doesn't match my decor, I wouldn't know where to display it.",
		"I'm not sure where I would put this piece.",
		"It's almost the centerpiece I'm looking for.",
		"I want a centerpiece for my table, but is this right?.",
		"I know someone will love this as a decorative piece, but for me?"
		]

export(Array, String) var too_much_symmetry = [
		"It's just too perfect.",
		"I can't even tell that it's hand made.",
		"I like things a little more wobbly.",
		"I'm afraid to touch it, it's so perfect.",
		"I'm looking for something with a more organic feel to it."
		]

export(Array, String) var too_little_symmetry = [
		"It's a little too wonky.",
		"I'm looking for something more symmetrical.",
		"It just doesn't have the precision I'm looking for.",
		"It's more rustic than I'd like.",
		"It's just too wobbly for me."
		]

		
# This is a great cup,
# What a lovely pot to look at
# My new cereal bowl!

# I don't think this is the cup for me
#   

# I dont know what I am looking at...
