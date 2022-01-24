extends Node

const SAVE_INDEX = 'save_index.txt'
const SAVE_DIRECTORY = '../pixel_pottery_modelling/train_2/'

func create_images_from_session_log(session_log):
	var size = Globals.IMAGE_SIZE
	for frame in session_log:
		var img = Image.new()
		img.create(size, size , false , 5)
		img.lock()
		for x in size:
			for y in size:
				var v =  not Vector2(x,-y)+Globals.IMAGE_OFFSET in frame
				img.set_pixel(x , y , Color(v,v,v,1))			
		img.unlock()
		img.flip_y()
		var index = get_save_index()
		index +=1
		img.save_png(SAVE_DIRECTORY+str(index)+'.png')
		set_save_index(index)
	print('Samples captured: '+ str(len(session_log)))
	print('Total Samples to date: '+str(get_save_index()))
	
func get_save_index():
	var file = File.new()
	if not file.file_exists(SAVE_DIRECTORY+SAVE_INDEX):
		return 0
	else:
		file.open(SAVE_DIRECTORY+SAVE_INDEX, File.READ)
		var index = file.get_line()
		file.close()
		return int(index)
		
func set_save_index(x):
	var file = File.new()
	file.open(SAVE_DIRECTORY+SAVE_INDEX, File.WRITE)
	file.store_string(str(x))
	file.close()
