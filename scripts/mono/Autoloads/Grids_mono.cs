using Godot;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;
using System.Collections.Generic; // Dictionary
using System; // String

public class Grids_mono : Node
{
	// Antimony Mono Commons
	public override void _Ready() {
		GD.Print("*** MONO: GridsMono loaded: " + this);
	}
	protected void PrintError(string Message, int Err = 1) {
		Globals.Log.Call("error", this, Err, Message);
	}
	protected void PrintGeneric(string Message) {
		Globals.Log.Call("generic", this, Message);
	}

	// ----- grid / map size & helpers -----
	public int GRID_SIZE;
	public int MAP_WIDTH; // these are from the game's Scenario settings --- they are DOUBLE the rectangle size!!
	public int MAP_HEIGHT;
	public bool TileIsInsideMap(int x, int y) { // checks if tile is inside the rotated map rectangle (OG diamond, this is generalized)
		// for a general case in which the GRID has different side lengths...
		// int dx2 = 2 * x + 1 - GRID_X;
		// int dy2 = 2 * y + 1 - GRID_Y;
		// return Math.Abs(dx2 - dy2) <= MAP_WIDTH && Math.Abs(dx2 + dy2) <= MAP_HEIGHT;

		// for a same-size GRID...
		return Math.Abs(2 * (x - y)) <= MAP_WIDTH && Math.Abs(2 * (x + y + 1 - GRID_SIZE)) <= MAP_HEIGHT;
	}
	public bool TileIsInsideGreaterDiamond(int x, int y) { // checks inside the greater of the two map sizes (still OG diamond...)
		int half_largest = MAP_WIDTH / 2;
		if (MAP_HEIGHT > MAP_WIDTH)
			half_largest = MAP_HEIGHT / 2;
		return Math.Abs(x - y) <= half_largest && Math.Abs(x + y + 1 - GRID_SIZE) <= half_largest;
	}

	// TODO: make this work for other GameSets...?
	public Dictionary<String, GridInterface> grids = new Dictionary<String, GridInterface> {
			{ "images", new GridInterface() },
			{ "edge", new GridInterface() },
			{ "buildings", new GridInterface() },
			{ "terrain", new GridInterface() },
			{ "aqueduct", new GridInterface() },
			{ "figures", new GridInterface() },
			{ "bitfields", new GridInterface() },
			{ "sprites", new GridInterface() },
			{ "random", new GridInterface() },
			{ "desirability", new GridInterface() },
			
			{ "elevation", new GridInterface() },
			{ "building_dmg", new GridInterface() },
			{ "aqueduct_bak", new GridInterface() },
			{ "sprite_bak", new GridInterface() },
			
			{ "fertility", new GridInterface() },
			{ "vegetation_growth", new GridInterface() },
			{ "unk_grid03", new GridInterface() },
			{ "unk_grid04", new GridInterface() },
			{ "moisture", new GridInterface() }
	};
	
	public bool RedrawMap(Enums.Directions orientation) { // update entire map (via MapRendererMono) with image data

		Grid<uint> grid_images = (Grid<uint>)(grids["images"]).grid;
		Grid<sbyte> grid_edge = (Grid<sbyte>)(grids["edge"]).grid;
		Grid<short> grid_buildings = (Grid<short>)(grids["buildings"]).grid;

		for (int y = 0; y < GRID_SIZE; y++) {
			for (int x = 0; x < GRID_SIZE; x++) {

				// skip outside map
				if (!TileIsInsideGreaterDiamond(x, y))
					continue;
				
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
				
				// skip non-DRAW_TILE tiles (i.e. tiles with 2+ size graphics only render on leftmost center tile)
				if (((Enums.EdgeFlags)grid_edge[x, y] & Enums.EdgeFlags.DRAW_TILE) != Enums.EdgeFlags.DRAW_TILE) {
					Globals.MapRendererMono.SetTileImage(cell_x, cell_y, 0, -1);
					continue;
				}

				// get image offset (e.g. Pyramid section height)
				int image_y_offset = 0;
				Building b = GameInterfaces.GetBuilding(grid_buildings[x, y]);
				if (b != null)
					image_y_offset += b.data.pyramid_section_height * 90;
				
				// draw!
				Globals.MapRendererMono.SetTileImage(cell_x, cell_y, image_y_offset, grid_images[x, y]);
			}
		}
		return true;
	}
}
