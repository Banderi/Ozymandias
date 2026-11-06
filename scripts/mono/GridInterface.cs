using Godot;
public class GridInterface : Reference { // this is pure torture
	
	public IGrid grid; // non-generic interface to type specific Grid<T> class

	// setgets
	public object Get(int x, int y) {
		return grid.GetValue(x, y);
	}
	public object Get(int cantor) {
		return grid.GetValue(cantor % grid.Width, cantor / grid.Height);
	}
	public bool Set(int x, int y, object value) {
		return grid.SetValue(x, y, value);
	}
	public bool Set(int cantor, object value) {
		return grid.SetValue(cantor % grid.Width, cantor / grid.Height, value);
	}
}