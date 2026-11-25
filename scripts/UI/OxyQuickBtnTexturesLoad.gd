tool
extends TextureButton

export var tex_path: String = "res://assets/Pharaoh/Pharaoh_General/interface/"
export var tex_id: int = 0 setget set_textures
func set_textures(t):
	tex_id = t
	texture_normal = load(tex_path + "%05d.png" % [t])
	texture_hover = load(tex_path + "%05d.png" % [t + 1])
	texture_pressed = load(tex_path + "%05d.png" % [t + 2])
	texture_disabled = load(tex_path + "%05d.png" % [t + 3])
	rect_size = Vector2()
