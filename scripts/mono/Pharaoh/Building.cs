using Godot;
using System;
using System.IO; // BinaryReader / BinaryWriter
using System.Reflection; // FieldInfo
using System.Runtime.InteropServices; // Marshal

public class Building : ReferenceEx
{
	[StructLayout(LayoutKind.Explicit)] public unsafe struct BuildingData {
		[FieldOffset(0)] public Enums.BuildingStates state;
		[FieldOffset(1)] public byte faction_id;
		[FieldOffset(2)] public byte _unk_00;
		[FieldOffset(3)] public byte size;
		[FieldOffset(4)] public byte house_is_merged;
		[FieldOffset(5)] public byte house_size;
		[FieldOffset(6)] public ushort tile_x;
		[FieldOffset(8)] public ushort tile_y;
		[FieldOffset(10)] public byte _unk_01;
		[FieldOffset(11)] public byte _unk_02;
		[FieldOffset(12)] public int tile_grid;
		[FieldOffset(16)] public short type;
		[FieldOffset(18)] public short house_level; // subtype.house_level
		[FieldOffset(20)] public ushort road_network_id;
		[FieldOffset(22)] public ushort creation_sequence_index;
		[FieldOffset(24)] public short houses_covered;
		[FieldOffset(26)] public short percentage_houses_covered;
		[FieldOffset(28)] public short house_population;
		[FieldOffset(30)] public short house_population_room;
		[FieldOffset(32)] public short distance_from_entry;
		[FieldOffset(34)] public short house_highest_population;
		[FieldOffset(36)] public short house_unreachable_ticks;
		[FieldOffset(38)] public ushort road_access_tile_x;
		[FieldOffset(40)] public ushort road_access_tile_y;
		[FieldOffset(42)] public fixed ushort figures[4];
		[FieldOffset(50)] public ushort figure_spawn_delay;
		[FieldOffset(52)] public byte figure_roam_direction;
		[FieldOffset(53)] public byte has_water_access;

		[FieldOffset(54)] public short _unk_03; // something related to fire/collapse risk...?
		[FieldOffset(56)] public short prev_part_building_id;
		[FieldOffset(58)] public short next_part_building_id;
		[FieldOffset(60)] public ushort stored_full_amount;
		[FieldOffset(62)] public byte _unk_04;
		[FieldOffset(63)] public byte has_well_access;

		[FieldOffset(64)] public short num_workers;
		[FieldOffset(66)] public byte labor_category; // FF
		[FieldOffset(67)] public byte output_resource_id;
		[FieldOffset(68)] public byte has_road_access;
		[FieldOffset(69)] public byte house_criminal_active;

		[FieldOffset(70)] public short damage_risk;
		[FieldOffset(72)] public short fire_risk;
		[FieldOffset(74)] public short fire_duration;
		[FieldOffset(76)] public byte fire_proof;

		[FieldOffset(77)] public byte map_random_7bit; // 20 (workcamp 1)
		[FieldOffset(78)] public byte house_tax_coverage;
		[FieldOffset(79)] public byte _unk_05;
		[FieldOffset(80)] public short formation_id;
		// read_type_data(iob, b; // 42 bytes for C3, 102 for PH
		// .............
	// } BuildingDataCommon1 commons1 = new();
	// [StructLayout(LayoutKind.Sequential, Pack = 1)] public struct BuildingDataCommon2 {
		[FieldOffset(82)] public BuildingDataUnion_Housing house;
		// .............
		// int currind = iob->get_offset() - sind;
		// if (GAME_ENV == ENGINE_ENV_PHARAOH)
		//     iob->bind____skip(184 - currind;
		// [MarshalAs(UnmanagedType.ByValArray, SizeConst = 7)] public byte[] unk_02;

		[FieldOffset(184)] public int tax_income_or_storage;
		[FieldOffset(188)] public byte house_days_without_food;
		[FieldOffset(189)] public byte ruin_has_plague; // 6

		[FieldOffset(190)] public sbyte desirability;
		[FieldOffset(191)] public byte is_deleted;
		[FieldOffset(192)] public byte is_adjacent_to_water;

		[FieldOffset(193)] public byte storage_id;
		[FieldOffset(194)] public sbyte house_happiness; // sentiment.house_happiness -- 90 for house, 50 for wells
		[FieldOffset(195)] public byte show_on_problem_overlay; // 4

		// 68 additional bytes
		[FieldOffset(196)] public fixed byte _unk_final_bytes[68];
	// } BuildingDataCommon2 commons2 = new();
	}
	BuildingData data = new BuildingData(); // Feature 'target-typed object creation' is not available in C# 7.3. Please use language version 9.0 or greater.

	// overlapping fields
	[StructLayout(LayoutKind.Sequential, Pack = 1)] public unsafe struct BuildingDataUnion_Housing {
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)] public fixed short foods[8];
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)] public fixed short inventory[4];

		// for (int i = 0; i < 9; i++)
		// 	iob->bind(BIND_SIGNATURE_INT16, &b->data.house.foods_ph[i]);
		// for (int i = 0; i < 4; i++) {
		// 	int food_n = ALLOWED_FOODS(i);
		// 	b->data.house.inventory[i] = b->data.house.foods_ph[food_n];
		// 	iob->bind(BIND_SIGNATURE_INT16, &b->data.house.inventory[i + 4]);
		// }
	}

	// constructor
	public short BUILDING_IDX;
	Building(short _IDX) {
		BUILDING_IDX = _IDX;
	}
	~Building() { // this should ONLY HAPPEN WHEN RE-INITIALIZING THE Buildings ARRAY IN GD (e.g. on gameset change)
		if (in_use())
			building_delete_UNSAFE();
	}
	
	// public I/O
	public bool Fill() {
		try {
			_readFromStream(((Scribe_mono)Globals.ScribeMono).GetReader());
		} catch (Exception e) {
			PrintError(e.ToString());
			return false;
		}
		return true;
	}
	public bool Dump() {
		try {
			_writeToStream(((Scribe_mono)Globals.ScribeMono).GetWriter());
		} catch (Exception e) {
			PrintError(e.ToString());
			return false;
		}
		return true;
	}

	// private I/O
	// private void test() {
	// 	BuildingData data;
	// }
	unsafe void _readFromStream(BinaryReader reader) {
			// BuildingData data;
			// test();
			// BuildingData data = new BuildingData();
		fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<BuildingData>())) {
			data = Marshal.PtrToStructure<BuildingData>((IntPtr)ptr);
		
		// fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<BuildingData>()))
		// 	Marshal.PtrToStructure((IntPtr)ptr, data);
		
		// fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<BuildingDataCommon1>()))
		// 	Marshal.PtrToStructure((IntPtr)ptr, commons1);
		// fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<BuildingDataUnions>()))
		// 	Marshal.PtrToStructure((IntPtr)ptr, unions);
		// fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<BuildingDataCommon2>()))
		// 	Marshal.PtrToStructure((IntPtr)ptr, commons2);
		}
		// catch (Exception e) {
		// 	GD.Print(e.ToString());
		// }
	}
	unsafe void _writeToStream(BinaryWriter writer) {
		byte[] buffer = new byte[Marshal.SizeOf<BuildingData>()];
		fixed (byte* ptr = buffer)
			Marshal.StructureToPtr<BuildingData>(data, (IntPtr)ptr, false);
		writer.Write(buffer);
	}

	// raw data fields set/get (for accessing from GDScript)
	public object get(String fieldName) {
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return null;
		return field.GetValue(data);
	}
	public bool set(String fieldName, object value) {
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return false;
		try {
			field.SetValue(data, Convert.ChangeType(value, field.FieldType));
		} catch (Exception e) {
			PrintError(e.ToString());
			return false;
		}
		return true;
	}

	// =============================== Building =============================== //

	// public void create(Enums.FigureTypes type, ushort x, ushort y, byte dir) { // TODO
		
	// }
	void building_delete_UNSAFE() { // TODO
		
	}

	
	public bool in_use() {
		return data.state != Enums.BuildingStates.UNUSED;
		// return data.state != Enums.FigureStates.NONE;
	}

	// public bool has_figure(byte index, byte figure_id)
	// {
	//     return false;
	// }
	public void remove_figure(short index) { // TODO
		
	}
}
