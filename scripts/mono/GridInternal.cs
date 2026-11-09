using Godot;
using System;
using System.IO;
using System.Linq;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;

public class Grid<T> : IGrid where T : unmanaged {
	private T[] _raw_data;
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
	public bool SetValue(int x, int y, object value) {
		if (x < 0 || x >= Width || y < 0 || y >= Height)
			return false;
		this[x, y] = (T)value;
		return true;
	}

	// serialization & deserialization
	public bool Fill(byte[] bytes) {
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
