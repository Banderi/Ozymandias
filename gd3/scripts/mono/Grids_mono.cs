using Godot;
using System;
using System.IO;

public class Grids_mono : Node
{
	// Member variables here, example:
	public override void _Ready()
	{
		GD.Print("GridsMono loaded: " + this);
	}

	const int PH_MAP_WIDTH = 228;
	const int PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH; // 228 * 228 = 51984

	enum ScribeFormat {
		i8,
		i16,
		i32,
		u8,
		u16,
		u32,
		ascii,
		utf8,
		raw
	}

	public bool SetGrid(Godot.Collections.Array grid, byte[] data, int format)
	{
		grid.Clear();
		BinaryReader stream = new BinaryReader(new MemoryStream(data));
		for (int y = 0; y < PH_MAP_WIDTH; y++)
		{
			Godot.Collections.Array row = new Godot.Collections.Array();
			for (int x = 0; x < PH_MAP_WIDTH; x++)
			{
				Int64 value = 0;
				switch ((ScribeFormat)format)
				{
					case ScribeFormat.u8:
						value = stream.ReadByte();
						break;
					case ScribeFormat.i8:
						value = stream.ReadSByte();
						break;
					case ScribeFormat.u16:
						value = stream.ReadUInt16();
						break;
					case ScribeFormat.i16:
						value = stream.ReadInt16();
						break;
					case ScribeFormat.u32:
						value = stream.ReadUInt32();
						break;
					case ScribeFormat.i32:
						value = stream.ReadInt32();
						break;
					default:
						break;
				}
				row.Add(value);
			}
			grid.Add(row);
		}
		return true;
	}
	public bool SetMap(TileMap map, byte[] data, int format)
	{
		if (map == null)
			return false;
		BinaryReader stream = new BinaryReader(new MemoryStream(data));
		for (int y = 0; y < PH_MAP_WIDTH; y++)
		{
			for (int x = 0; x < PH_MAP_WIDTH; x++)
			{
				Int64 value = 0;
				switch ((ScribeFormat)format)
				{
					case ScribeFormat.u8:
						value = stream.ReadByte();
						break;
					case ScribeFormat.i8:
						value = stream.ReadSByte();
						break;
					case ScribeFormat.u16:
						value = stream.ReadUInt16();
						break;
					case ScribeFormat.i16:
						value = stream.ReadInt16();
						break;
					case ScribeFormat.u32:
						value = stream.ReadUInt32();
						break;
					case ScribeFormat.i32:
						value = stream.ReadInt32();
						break;
					default:
						break;
				}
				map.SetCell(x, y, (int)value);
			}
		}
		return true;
	}
}
