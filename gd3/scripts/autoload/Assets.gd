extends Node

# TODO: put these in user setting
const INSTALL_PATH = "D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra" 
const DATA_PATH = INSTALL_PATH + "/Data"
const SAVES_PATH = INSTALL_PATH + "/Save"

func load_texture(pak = "Pharaoh_Unloaded", data = "0_fired_00001.png"):
	var path = "res://assets/Pharaoh/" + pak + "/" + data
	
	
	var r = load(path)
	if r == null:
		var image = Image.new()
		image.load(path)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		r = texture
	
	return r

