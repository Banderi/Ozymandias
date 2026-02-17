extends ConfirmationDialog
class_name ConfirmationDialogEx
# ANTIMONY 'ConfirmationDialogEx' by Banderi --- v1.3

# these are the primary signal handlers that will determine what to do, and later fire the return container
func _on_confirmed(): # ConfirmationDialog
	_on_chosen(true)
func _on_dir_selected(stuff): # FileDialog
	_on_chosen(stuff)
func _on_file_selected(stuff): # FileDialog
	_on_chosen(stuff)
func _on_files_selected(stuff): # FileDialog
	_on_chosen(stuff)
func _on_popup_hide():
	# 'popup_hide' fires BEFORE 'confirmed'...
	# need to use "call_deferred" because of this.
	var selfRef = self
	if selfRef is FileDialog:
		call_deferred("_on_chosen", null)
	elif selfRef is ConfirmationDialog:
		call_deferred("_on_chosen", false)

# this is the final common returning signal. it encapsulates ALL the necessary states into one container.
signal chosen(choice)
func _on_chosen(choice):
	if !primed:
		return
	yield(Engine.get_main_loop(), "idle_frame")
	primed = false
	emit_signal("chosen", choice)
	# N.B.: any synchronous parent / callee *** M U S T *** free the async calls propagation and wait
	# for AT LEAST ONE IDLE FRAME before calling popup() again on the dialog.

# reset the "primed" state and fire Global.delicate (if implemented)
var primed = false
func _on_popup():
	primed = true

func _ready():
	# we use call_deferred to prevent UI inputs bleeding out from the hiding action
	var _r = connect("about_to_show", self, "_on_popup")
	_r = connect("popup_hide", self, "_on_popup_hide")
	
	var selfRef = self
	if (selfRef is FileDialog):
		_r = connect("dir_selected", self, "_on_dir_selected")
		_r = connect("file_selected", self, "_on_file_selected")
		_r = connect("files_selected", self, "_on_files_selected")
