extends SceneTree
class_name CustomMainLoop
# ANTIMONY 'CustomMainLoop' by Banderi --- v1.0

func run_ps(args):
	var arr = []
	var r = OS.execute("powershell", args, true, arr, true, false)
	print(r, ": ", arr)
func detach_appid_icon():
	if !OS.is_debug_build() || !OS.has_feature("editor") || !("Godot" in OS.get_executable_path().split('/')[-1]):
		return
	run_ps([
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", "E:\\Godot\\change_appicon.ps1",
		"-TargetPid", str(OS.get_process_id()),
		"-AppId", "com.example.mygame.instance1"
	])
func dismiss_appid_icon():
	if !("Godot" in OS.get_executable_path().split('/')[-1]):
		return
	run_ps([
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", "E:\\Godot\\change_appicon.ps1",
		"-TargetPid", str(OS.get_process_id()),
		"-Clear"
	])

func _initialize() -> void:
#	var a =  get_editor_interface().get_editor_settings().get_setting("network/debug/remote_port")
	detach_appid_icon()
	print("Init Main Loop")

func _notification(notification):
	match notification:
		NOTIFICATION_CRASH:
			dismiss_appid_icon()
		NOTIFICATION_WM_QUIT_REQUEST: # this will be called on normal quit, as well as _finalize
			dismiss_appid_icon()
		NOTIFICATION_PREDELETE:
			dismiss_appid_icon()
