using Godot;

public class GameInterfaces {
	
    public static Figure getFigure(short figure_id) {
        if (figure_id <= 0)
            return null;
		return (Figure) ((Godot.Collections.Array)Globals.Figures.Get("figures"))[figure_id];
	}
    public static Building getBuilding(short building_id) {
		if (building_id <= 0)
			return null;
		return (Building) ((Godot.Collections.Array)Globals.Buildings.Get("buildings"))[building_id];
	}
}