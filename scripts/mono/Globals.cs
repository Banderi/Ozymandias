using Godot;
using System;

public class Globals : Node
{
	public override void _Ready()
	{
		GD.Print("*** MONO: Globals (Autoloads) loaded: " + this);
		fillGlobals();
	}
	
	// ******* autoloads here ******* //
	public static Node Debug;
	public static Node IO;
	public static Node Log;
	public static Node Stopwatch;
	public static Node Settings;
	public static Node Keybinds;
	
	public static Grids_mono GridsMono;
//	public static Node PKWare;
	public static PKWare_mono PKWareMono;
	public static SGImage_mono SGImageMono;
	public static Node Scribe;
	public static Scribe_mono ScribeMono;
	public static Node Assets;
	public static Node Sounds;
	public static Node Viewports;
	public static Graphics_mono GraphicsMono;
	public static MapRenderer_mono MapRendererMono;
	
	public static Node Game;
	public static Node Family;
	public static Node Campaign;
	public static Node Map;
	public static Node Figures;
//	public static Node FiguresMono;
	public static Node Routing;
	public static Node City;
	public static Node Buildings;
	public static Node Scenario;
	public static Node Empire;
	public static Node Messages;
	public static Node Gods;
	public static Node Random;
	public static Node Military;
	
	private void fillGlobals()
	{
		Log = GetNode("/root/Log");
		Debug = GetNode("/root/Debug");
		IO = GetNode("/root/IO");
		Log = GetNode("/root/Log");
		Stopwatch = GetNode("/root/Stopwatch");
		Settings = GetNode("/root/Settings");
		Keybinds = GetNode("/root/Keybinds");
		
		GridsMono = GetNode<Grids_mono>("/root/GridsMono");
//		PKWare = GetNode("/root/PKWare");
		PKWareMono = GetNode<PKWare_mono>("/root/PKWareMono");
		SGImageMono = GetNode<SGImage_mono>("/root/SGImageMono");
		Scribe = GetNode("/root/Scribe");
		ScribeMono = GetNode<Scribe_mono>("/root/ScribeMono");
		Assets = GetNode("/root/Assets");
		Sounds = GetNode("/root/Sounds");
		Viewports = GetNode("/root/Viewports");
		GraphicsMono = GetNode<Graphics_mono>("/root/GraphicsMono");
		MapRendererMono = GetNode<MapRenderer_mono>("/root/MapRendererMono");
		
		Game = GetNode("/root/Game");
		Family = GetNode("/root/Family");
		Campaign = GetNode("/root/Campaign");
		Map = GetNode("/root/Map");
		Figures = GetNode("/root/Figures");
//		FiguresMono = GetNode("/root/FiguresMono");
		Routing = GetNode("/root/Routing");
		City = GetNode("/root/City");
		Buildings = GetNode("/root/Buildings");
		Scenario = GetNode("/root/Scenario");
		Empire = GetNode("/root/Empire");
		Messages = GetNode("/root/Messages");
		Gods = GetNode("/root/Gods");
		Random = GetNode("/root/Random");
		Military = GetNode("/root/Military");
	}
}
