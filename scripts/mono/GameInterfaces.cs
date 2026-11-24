using Godot;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;

public class GameInterfaces {

    public static Figure GetFigure(int figure_id) {
        if (figure_id <= 0)
            return null;
		return (Figure) ((GodotArray)Globals.Figures.Get("figures"))[figure_id];
	}
    public static Building GetBuilding(int building_id) {
		if (building_id <= 0)
			return null;
		return (Building) ((GodotArray)Globals.Buildings.Get("buildings"))[building_id];
	}
	public static int Grid_TerrainAt(int x, int y) {
		return (int)Globals.GridsMono.grids["terrain"].Get(x, y);
	}
	public static int Map_GetGridStartingOffset() {
		return 0;
	} 
}