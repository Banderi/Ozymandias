using Godot;

public class ReferenceEx : Reference {

	// Log.error(...)
	protected void PrintError(string Message, int Err = 1) {
		Globals.Log.Call("error", this, 1, Message);
	}
	protected void PrintGeneric(string Message) {
		Globals.Log.Call("generic", this, Message);
	}
}