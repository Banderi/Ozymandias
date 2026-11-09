using Godot;
using System;
using System.IO;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;

public class Grids_mono : Node
{
	// Member variables here, example:
	public override void _Ready() {
		GD.Print("*** MONO: GridsMono loaded: " + this);
	}

	// Log.error(...)
	protected void PrintError(string Message, int Err = 1) {
		Globals.Log.Call("error", this, 1, Message);
	}
	protected void PrintGeneric(string Message) {
		Globals.Log.Call("generic", this, Message);
	}

	public int GRID_SIZE;
	public int MAP_WIDTH; // these are from the game's Scenario settings --- they are DOUBLE the rectangle size!!
	public int MAP_HEIGHT;
	
	public bool TileIsInsideMap(int x, int y) {
		// Tile-center offset from the grid center, doubled to stay integer.
		// int dx2 = 2 * x + 1 - GRID_X;
		// int dy2 = 2 * y + 1 - GRID_Y;
		int dx2 = 2 * x + 1 - GRID_SIZE;
		int dy2 = 2 * y + 1 - GRID_SIZE;

		// Top-left/bottom-right sides run along (1,-1), so the extent across
		// them is measured by dx - dy. Top-right/bottom-left sides run along
		// (1,1), so their extent is measured by dx + dy.
		// |dx - dy| <= cellsX  <=>  |dx2 - dy2| <= 2*cellsX   (likewise for Y)
		return Math.Abs(dx2 - dy2) <= 2 * MAP_WIDTH / 2
			&& Math.Abs(dx2 + dy2) <= 2 * MAP_HEIGHT / 2;
	}
	
	// update entire TileMap with grid data
	public bool RedrawMap(TileMap map, GodotDictionary grids, Enums.Directions orientation) {

		Grid<uint> grid_images = (Grid<uint>)((GridInterface)grids["images"]).grid;
		Grid<sbyte> grid_edge = (Grid<sbyte>)((GridInterface)grids["edge"]).grid;

		for (int y = 0; y < GRID_SIZE; y++)
		{
			for (int x = 0; x < GRID_SIZE; x++)
			{
				int cell_x = x;
				int cell_y = y;
				switch (orientation) {
					case Enums.Directions.CITY_90_DEG:
						cell_x = y; cell_y = GRID_SIZE - x - 1;
						break;
					case Enums.Directions.CITY_180_DEG:
						cell_x = GRID_SIZE - x - 1; cell_y = GRID_SIZE - y - 1;
						break;
					case Enums.Directions.CITY_270:
						cell_x = GRID_SIZE - y - 1; cell_y = x;
						break;
				}

				if (!TileIsInsideMap(x, y)) {
					continue;
				}
				int image = (int)grid_images[x, y];
				int edge = (int)grid_edge[x, y];
				map.SetCell(cell_x, cell_y, image);
				
				if (((Enums.EdgeFlags)edge & Enums.EdgeFlags.DRAW_TILE) == Enums.EdgeFlags.DRAW_TILE)
					map.SetCell(cell_x, cell_y, image);
				else
					map.SetCell(cell_x, cell_y, -1);
			}
		}
		return true;
	}
}
