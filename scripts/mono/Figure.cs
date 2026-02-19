using Godot;
using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices; // Marshal


// [StructLayout(LayoutKind.Sequential, Pack = 1)]
public class Figure : Reference //Godot.Object //Reference
{
	
	// public override void _Init()
	// {
	// 	GD.Print("*** FIGURE.CS SPAWNED: " + this);
	// }
	Figure()
	{
		// GD.Print("*** FIGURE.CS CREATED: " + this);
	}
	~Figure()
	{
		// GD.Print("*** FIGURE.CS DESTRUCTED: " + this);
	}
	// public New()
	// {
	// 	return new Figure();
	// }


    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public class FigureData
    {
		public byte alternative_location_index;
		public byte anim_frame;
		public byte is_enemy_image;
		public byte flotsam_visible;
		public short sprite_image_id; // this is off by 18 with respect to the normal SG global ids!
		public short unk_00; // cart_image_id was here in C3
		public short next_figure;
		public byte type;
		public byte resource_id;
		public byte use_cross_country;
		public byte is_friendly;
		public byte state;
		public byte faction_id;
		public byte action_state_before_attack;
		public sbyte direction;
		public sbyte previous_tile_direction;
		public sbyte attack_direction;
		public ushort tile_x;
		public ushort tile_y;
		public ushort previous_tile_x;
		public ushort previous_tile_y;
		public ushort missile_damage;
		public ushort damage;
		public int tile_grid;
		public ushort destination_tile_x;
		public ushort destination_tile_y;
		public int destination_tile_grid;
		public ushort source_tile_x;
		public ushort source_tile_y;
		public ushort formation_position_x_soldier;
		public ushort formation_position_y_soldier;
		public short __unused_24; // 0
		public short wait_ticks; // 0
		public byte action_state; // 9
		public byte progress_on_tile; // 11
		public short routing_path_id; // 12
		public short routing_path_current_tile; // 4
		public short routing_path_length; // 28
		public byte in_building_wait_ticks; // 0
		public byte outside_road_ticks; // 1
		public short max_roam_length;
		public short roam_length;
		public byte roam_wander_freely;
		public byte roam_random_counter;
		public sbyte roam_turn_direction;
		public sbyte roam_ticks_until_next_turn; // 0 ^^^^
		public short cc_coords_x;
		public short cc_coords_y;
		public short cc_destination_x;
		public short cc_destination_y;
		public short cc_delta_x;
		public short cc_delta_y;
		public short cc_delta_xy;
		public byte cc_direction;
		public byte speed_multiplier;
		public short home_building_id;
		public short immigrant_home_building_id;
		public short destination_building_id;
		public short formation_id; // formation: 10
		public byte index_in_formation; // 3
		public byte formation_at_rest;
		public byte migrant_num_people;
		public byte is_ghost;
		public byte min_max_seen;
		public byte __unused_57;
		public short leading_figure_id;
		public byte attack_image_offset;
		public byte wait_ticks_missile;
		public sbyte cart_offset_x;
		public sbyte cart_offset_y;
		public byte empire_city_id;
		public byte trader_amount_bought;
		public short name; // 6
		public byte terrain_usage;
		public byte is_boat;
		public ushort resource_amount_full; // 4772 >>>> 112 (resource amount! 2-bytes)
		public byte height_adjusted_ticks;
		public byte current_height;
		public byte target_height;
		public byte collecting_item_id;
		public byte trade_ship_failed_dock_attempts;
		public byte phrase_sequence_exact;
		public sbyte phrase_id;
		public byte phrase_sequence_city;
		public byte __unused_6f;
		public byte trader_id;
		public byte wait_ticks_next_target;
		public short target_figure_id;
		public short targeted_by_figure_id;
		public ushort created_sequence;
		public ushort target_figure_created_sequence;
	//    public byte figures_sametile_num;
		// Scribe.skip(1)
		public byte unk_01;
		public byte num_attackers;
		public short attacker_id1;
		public short attacker_id2;
		public short opponent_id;
		// below are added in Pharaoh
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 7)]
		public byte[] unk_02;
		public short unk_03_269; // 269
		public short unk_04; // 0
		public int market_lady_resource_image_offset; // 03 00 00 00
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 12)]
		public byte[] unk_05_ff; // FF FF FF FF FF ...
		public short market_lady_returning_home_id; // 26
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 14)]
		public byte[] unk_06_00; // 00 00 00 00 00 00 00 ...
		public short market_lady_bought_amount; // 200
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 115)]
		public byte[] unk_07;
		public sbyte unk_08_6; // 6
		public short unk_09_ffff; // -1
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 48)]
		public byte[] unk_10;
		public sbyte festival_remaining_dances;
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 27)]
		public byte[] unk_11;
		public short cart_image_id; // this is off by 18 with respect to the normal SG global ids!
		public short unk_12;
    }
	public FigureData data = new FigureData();
    
	public void Fill()
	{
		// BinaryReader r = (BinaryReader)Globals.ScribeMono.Call("GetReader");
		readFromStream(((Scribe_mono)Globals.ScribeMono).GetReader());
	}
	public void Dump()
	{
		// writeToStream((BinaryWriter)Globals.ScribeMono.Call("GetWriter"));
		writeToStream(((Scribe_mono)Globals.ScribeMono).GetWriter());
	}

	// public unsafe void readFigure<T>(T pData)
	public unsafe void readFromStream(BinaryReader reader)
	{
		// int size = Marshal.SizeOf<T>();
		// int size = Marshal.SizeOf(this.GetType());
		int size = Marshal.SizeOf<FigureData>();
		// byte[] stream = _handle.GetBuffer(size);
		byte[] buffer = reader.ReadBytes(size);
		fixed (byte* ptr = buffer)
		{
			// return Marshal.PtrToStructure<T>((IntPtr)ptr);
			// Marshal.PtrToStructure((IntPtr)ptr, this);
			Marshal.PtrToStructure((IntPtr)ptr, data);

		}
	}
	public unsafe void writeToStream(BinaryWriter writer)
    {
        // using (var file = new FileStream(path, FileMode.Create))
        // using (var writer = new BinaryWriter(file))
        // {
		// int size = Marshal.SizeOf(this.GetType());
		int size = Marshal.SizeOf<FigureData>();
		byte[] buffer = new byte[size];
		
		fixed (byte* ptr = buffer)
		{
			// Marshal.StructureToPtr(this, (IntPtr)ptr, false);
			Marshal.StructureToPtr(data, (IntPtr)ptr, false);
		}
		
		writer.Write(buffer);
        // }
    }

    // public void enscribe_figures()
    // {
        
    // }

	public object getData(String fieldName)
	{
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return null;
		return field.GetValue(data);
		// var dict = new Godot.Collections.Dictionary();
		
		// foreach (var field in data.GetType().GetFields())
		// {
		// 	if (field.Name == fieldName)
		// 		return field.GetValue(data);
		// 	// var value = field.GetValue(_obj);
			
		// 	// if (value is int[] intArray)
		// 	// {
		// 	// 	var godotArray = new Godot.Collections.Array();
		// 	// 	foreach (var item in intArray)
		// 	// 		godotArray.Add(item);
		// 	// 	dict[field.Name] = godotArray;
		// 	// }
		// 	// else if (value is float[] floatArray)
		// 	// {
		// 	// 	var godotArray = new Godot.Collections.Array();
		// 	// 	foreach (var item in floatArray)
		// 	// 		godotArray.Add(item);
		// 	// 	dict[field.Name] = godotArray;
		// 	// }
		// 	// else
		// 	// {
		// 	// 	dict[field.Name] = value;
		// 	// }
		// }
		// return null;
		// // return dict;
	}
	
	public bool setData(String fieldName, object value)
	{
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return false;
		try {
			field.SetValue(data, Convert.ChangeType(value, field.FieldType));
		} catch (Exception e) {
			// Globals.Log.Call("error", this, e.HResult, "could not set data field");
			GD.PrintErr(e.ToString());
			GD.PushError(e.ToString());
			return false;
		}
		return true;
		// foreach (var field in data.GetType().GetFields())
		// {
		// 	if (field.Name == fieldName) {
		// 		try {
		// 			field.SetValue(data, Convert.ChangeType(value, field.FieldType));
		// 		} catch (Exception e) {
		// 			// Globals.Log.Call("error", this, e.HResult, "could not set data field");
		// 			GD.PrintErr(e.ToString());
		// 			GD.PushError(e.ToString());
		// 			return false;
		// 		}
		// 		return true;
		// 	}
		// 	// var fieldName = key.ToString();
		// 	// var field = _obj.GetType().GetField(fieldName);
			
		// 	// if (field != null)
		// 	// {
		// 	// 	var value = dict[key];
				
		// 	// 	if (value is Godot.Collections.Array godotArray && field.FieldType.IsArray)
		// 	// 	{
		// 	// 		if (field.FieldType == typeof(int[]))
		// 	// 		{
		// 	// 			var intArray = new int[godotArray.Count];
		// 	// 			for (int i = 0; i < godotArray.Count; i++)
		// 	// 				intArray[i] = Convert.ToInt32(godotArray[i]);
		// 	// 			field.SetValue(_obj, intArray);
		// 	// 		}
		// 	// 		else if (field.FieldType == typeof(float[]))
		// 	// 		{
		// 	// 			var floatArray = new float[godotArray.Count];
		// 	// 			for (int i = 0; i < godotArray.Count; i++)
		// 	// 				floatArray[i] = Convert.ToSingle(godotArray[i]);
		// 	// 			field.SetValue(_obj, floatArray);
		// 	// 		}
		// 	// 	}
		// 	// 	else
		// 	// 		field.SetValue(_obj, Convert.ChangeType(value, field.FieldType));
		// 	// }
		// }
		// return false;
	}
}
