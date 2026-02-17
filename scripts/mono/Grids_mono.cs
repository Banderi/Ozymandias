using Godot;
using System;
using System.IO;

public class Grids_mono : Node
{
	// Member variables here, example:
	public override void _Ready()
	{
		GD.Print("*** MONO: GridsMono loaded: " + this);
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

	public bool SetGridFromBytes(Godot.Collections.Array grid, byte[] data, int grid_size, int format)
	{
		grid.Clear();
		grid.Resize(grid_size);
		BinaryReader stream = new BinaryReader(new MemoryStream(data));

		// This BARELY improves the code speeds by any amount -- but I'll leave it here.
		switch ((ScribeFormat)format){
			case ScribeFormat.u8:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadByte();
					grid[y] = row;
				}
				break;
			case ScribeFormat.i8:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadSByte();
					grid[y] = row;
				}
				break;
			case ScribeFormat.u16:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadUInt16();
					grid[y] = row;
				}
				break;
			case ScribeFormat.i16:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadInt16();
					grid[y] = row;
				}
				break;
			case ScribeFormat.u32:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadUInt32();
					grid[y] = row;
				}
				break;
			case ScribeFormat.i32:
				for (int y = 0; y < PH_MAP_WIDTH; y++)
				{
					Godot.Collections.Array row = new Godot.Collections.Array();
					row.Resize(grid_size);
					for (int x = 0; x < PH_MAP_WIDTH; x++)
						row[x] = stream.ReadInt32();
					grid[y] = row;
				}
				break;
			default:
				return false;
		}

		// for (int y = 0; y < PH_MAP_WIDTH; y++)
		// {
		// 	Godot.Collections.Array row = new Godot.Collections.Array();
		// 	row.Resize(grid_size);
		// 	for (int x = 0; x < PH_MAP_WIDTH; x++)
		// 	{
		// 		Int64 value = 0;
		// 		switch ((ScribeFormat)format)
		// 		{
		// 			case ScribeFormat.u8:
		// 				value = stream.ReadByte();
		// 				break;
		// 			case ScribeFormat.i8:
		// 				value = stream.ReadSByte();
		// 				break;
		// 			case ScribeFormat.u16:
		// 				value = stream.ReadUInt16();
		// 				break;
		// 			case ScribeFormat.i16:
		// 				value = stream.ReadInt16();
		// 				break;
		// 			case ScribeFormat.u32:
		// 				value = stream.ReadUInt32();
		// 				break;
		// 			case ScribeFormat.i32:
		// 				value = stream.ReadInt32();
		// 				break;
		// 			default:
		// 				break;
		// 		}
		// 		row[x] = value;
		// 	}
		// 	grid[y] = row;
		// }
		return true;
	}
	public byte[] GetBytesFromGrid(Godot.Collections.Array grid, int grid_size, int format)
	{
		// byte[] stream = new byte[0]; // TODO
		return null;
	}
	public bool RedrawMap(TileMap map, Godot.Collections.Dictionary grids)
	{
		// Godot.Collections.Array grid_images = (Godot.Collections.Array)grids["images"];
		for (int y = 0; y < PH_MAP_WIDTH; y++)
		{
			// Godot.Collections.Array row = (Godot.Collections.Array)grid_images[y];
			for (int x = 0; x < PH_MAP_WIDTH; x++)
			{
				// int image = (int)row[x];
				int image = (int)( (Godot.Collections.Array)( (Godot.Collections.Array)grids["images"] )[y] )[x];
				int edge = (int)( (Godot.Collections.Array)( (Godot.Collections.Array)grids["edge"] )[y] )[x];
				// int bitfields = (int)( (Godot.Collections.Array)( (Godot.Collections.Array)grids["bitfields"] )[y] )[x];
				if ((edge & 64) == 64)
					map.SetCell(x, y, image);
			}
		}
		return true;
	}
}
