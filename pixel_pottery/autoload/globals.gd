extends Node
 
enum pot_type {junk, cup, bowl, decorative}
 
const MAX_CLAY_PIXELS = 500
const MIN_PEDAL_DEGREE = 0
const MAX_PEDAL_DEGREE = 45
const MAX_WHEEL_SPEED = 3
#Dimensions of images used for classifcation (square)
const IMAGE_SIZE = 96
const IMAGE_OFFSET = Vector2(-IMAGE_SIZE*0.5, 0)


var clay_body = 0.8
var clay_saturation = 0.0
var clay_plasticity = 1
var clay_color = Color(1,1,1,1)

var data_collection = false
