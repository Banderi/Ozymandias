using Godot;
using System;
using System.IO;
using System.Linq;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;


// public interface IGrid
// {
// 	int Width { get; }
//     int Height { get; }
//     bool SetGridFromBytes(byte[] bytes);
//     // double GetAsDouble(int x, int y);
// }
public class Grid<T> : IGrid where T : unmanaged
{
	const int PH_MAP_WIDTH = 228;
	// const int PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH; // 228 * 228 = 51984
	// const int MAP_CENTER = PH_MAP_WIDTH / 2;

	// public enum Enums.ScribeFormat {
	// 	i8,
	// 	i16,
	// 	i32,
	// 	u8,
	// 	u16,
	// 	u32,
	// 	ascii,
	// 	utf8,
	// 	raw
	// }

	// private dynamic[][] _raw_data;
	// public dynamic[] this[int x] => _raw_data[x];

	private T[] _raw_data;
	// public readonly int Width;
	// public readonly int Height;
    public int Width { get; }
    public int Height { get; }
    public Grid(int _width, int _height) {
		Width = _width;
		Height = _height;
		_raw_data = new T[Width * Height];
	}
	public T this[int x, int y] {
		get { return _raw_data[y * Width + x]; }
		set { _raw_data[y * Width + x] = value; }
	}
	public object GetValue(int x, int y) {
		if (x < 0 || x >= Width || y < 0 || y >= Height)
			return null;
		return (object)(this[x, y]);
	}
	// public void SetValue(int x, int y, T value) {
	// 	this[x, y] = value;
	// }
	public bool SetValue(int x, int y, object value) {
		if (x < 0 || x >= Width || y < 0 || y >= Height)
			return false;
		this[x, y] = (T)value;
		return true;
	}

	// serialization & deserialization
	public bool Fill(byte[] bytes) {
		// grid.Clear();
		// grid.Resize(grid_size);
		// BinaryReader stream = new BinaryReader(new MemoryStream(data));
		int byteCount = bytes.Length;
		if (Buffer.ByteLength(_raw_data) != byteCount)
			return false;
		Buffer.BlockCopy(bytes, 0, _raw_data, 0, byteCount);
		return true;
	}
	public byte[] Dump() { // TODO
		// byte[] stream = new byte[0];
		return null;
	}
}
