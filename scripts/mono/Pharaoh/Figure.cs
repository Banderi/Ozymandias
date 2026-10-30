using Godot;
using System;
using System.IO; // BinaryReader / BinaryWriter
using System.Reflection; // FieldInfo
using System.Runtime.InteropServices; // Marshal

public class Figure : ReferenceEx
{
    [StructLayout(LayoutKind.Explicit)] public unsafe struct FigureData {
		[FieldOffset(0)] public byte alternative_location_index;
		[FieldOffset(1)] public byte anim_frame;
		[FieldOffset(2)] public bool8 is_enemy_image; // public byte is_enemy_image;
		[FieldOffset(3)] public byte flotsam_visible; // is this boolean?
		[FieldOffset(4)] public short sprite_image_id; // this is off by 18 with respect to the normal SG global ids!
		[FieldOffset(6)] public short _unk_00; // cart_image_id was here in C3
		[FieldOffset(8)] public short next_figure;
		[FieldOffset(10)] public Enums.FigureTypes type;
		[FieldOffset(11)] public byte resource_id;
		[FieldOffset(12)] public bool8 use_cross_country;
		[FieldOffset(13)] public bool8 is_friendly;
		[FieldOffset(14)] public Enums.FigureStates state;
		[FieldOffset(15)] public byte faction_id;
		[FieldOffset(16)] public Enums.FigureActions action_state_before_attack;
		[FieldOffset(17)] public Enums.FigureDirections direction;
		[FieldOffset(18)] public Enums.FigureDirections previous_tile_direction;
		[FieldOffset(19)] public Enums.FigureDirections attack_direction;
		[FieldOffset(20)] public ushort tile_x;
		[FieldOffset(22)] public ushort tile_y;
		[FieldOffset(24)] public ushort previous_tile_x;
		[FieldOffset(26)] public ushort previous_tile_y;
		[FieldOffset(28)] public ushort missile_damage;
		[FieldOffset(30)] public ushort damage;
		[FieldOffset(32)] public int tile_grid;
		[FieldOffset(36)] public ushort destination_tile_x;
		[FieldOffset(38)] public ushort destination_tile_y;
		[FieldOffset(40)] public int destination_tile_grid;
		[FieldOffset(44)] public ushort source_tile_x;
		[FieldOffset(46)] public ushort source_tile_y;
		[FieldOffset(48)] public ushort formation_position_x_soldier;
		[FieldOffset(50)] public ushort formation_position_y_soldier;
		[FieldOffset(52)] public short __unused_24; // 0
		[FieldOffset(54)] public short wait_ticks; // 0
		[FieldOffset(56)] public Enums.FigureActions action_state; // 9
		[FieldOffset(57)] public byte progress_on_tile; // 11
		[FieldOffset(58)] public short routing_path_id; // 12
		[FieldOffset(60)] public short routing_path_current_tile; // 4
		[FieldOffset(62)] public short routing_path_length; // 28
		[FieldOffset(64)] public byte in_building_wait_ticks; // 0
		[FieldOffset(65)] public byte outside_road_ticks; // 1
		[FieldOffset(66)] public short max_roam_length;
		[FieldOffset(68)] public short roam_length;
		[FieldOffset(70)] public byte roam_wander_freely;
		[FieldOffset(71)] public byte roam_random_counter;
		[FieldOffset(72)] public sbyte roam_turn_direction;
		[FieldOffset(73)] public sbyte roam_ticks_until_next_turn; // 0 ^^^^
		[FieldOffset(74)] public short cc_coords_x;
		[FieldOffset(76)] public short cc_coords_y;
		[FieldOffset(78)] public short cc_destination_x;
		[FieldOffset(80)] public short cc_destination_y;
		[FieldOffset(82)] public short cc_delta_x;
		[FieldOffset(84)] public short cc_delta_y;
		[FieldOffset(86)] public short cc_delta_xy;
		[FieldOffset(88)] public byte cc_direction;
		[FieldOffset(89)] public byte speed_multiplier;
		[FieldOffset(90)] public short home_building_id;
		[FieldOffset(92)] public short immigrant_home_building_id;
		[FieldOffset(94)] public short destination_building_id;
		[FieldOffset(96)] public short formation_id; // formation: 10
		[FieldOffset(98)] public byte index_in_formation; // 3
		[FieldOffset(99)] public byte formation_at_rest;
		[FieldOffset(100)] public byte migrant_num_people;
		[FieldOffset(101)] public bool8 is_ghost;
		[FieldOffset(102)] public byte min_max_seen;
		[FieldOffset(103)] public byte __unused_57;
		[FieldOffset(104)] public short leading_figure_id;
		[FieldOffset(106)] public byte attack_image_offset;
		[FieldOffset(107)] public byte wait_ticks_missile;
		[FieldOffset(108)] public sbyte cart_offset_x;
		[FieldOffset(109)] public sbyte cart_offset_y;
		[FieldOffset(110)] public byte empire_city_id;
		[FieldOffset(111)] public byte trader_amount_bought;
		[FieldOffset(112)] public short name; // 6
		[FieldOffset(114)] public Enums.TerrainUsage terrain_usage; // [FieldOffset()] public byte terrain_usage;
		[FieldOffset(115)] public byte is_boat;
		[FieldOffset(116)] public ushort resource_amount_full; // 4772 >>>> 112 (resource amount! 2-bytes)
		[FieldOffset(118)] public byte height_adjusted_ticks;
		[FieldOffset(119)] public byte current_height;
		[FieldOffset(120)] public byte target_height;
		[FieldOffset(121)] public byte collecting_item_id;
		[FieldOffset(122)] public byte trade_ship_failed_dock_attempts;
		[FieldOffset(123)] public byte phrase_sequence_exact;
		[FieldOffset(124)] public sbyte phrase_id;
		[FieldOffset(125)] public byte phrase_sequence_city;
		[FieldOffset(126)] public byte __unused_6f;
		[FieldOffset(127)] public byte trader_id;
		[FieldOffset(128)] public byte wait_ticks_next_target;
		// these are misaligned?????
		// [FieldOffset(129)] public short target_figure_id;
		// [FieldOffset(131)] public short targeted_by_figure_id;
		// [FieldOffset(133)] public ushort created_sequence;
		// [FieldOffset(135)] public ushort target_figure_created_sequence;
		// [FieldOffset(137)] public byte _unk_01; // [FieldOffset()] public byte figures_sametile_num;
		// [FieldOffset(138)] public byte num_attackers;
		// [FieldOffset(139)] public short attacker_id1;
		// [FieldOffset(141)] public short attacker_id2;
		// [FieldOffset(143)] public short opponent_id;
		// below are added in Pharaoh
		[FieldOffset(145)] public fixed byte unk_02[7];
		[FieldOffset(152)] public short _unk_03_269; // 269
		[FieldOffset(154)] public short _unk_04; // 0
		[FieldOffset(156)] public int market_lady_resource_image_offset; // 03 00 00 00
		[FieldOffset(160)] public fixed byte unk_05_ff[12]; // FF FF FF FF FF ...
		[FieldOffset(172)] public short market_lady_returning_home_id; // 26
		[FieldOffset(174)] public fixed byte unk_06_00[14]; // 00 00 00 00 00 00 00 ...
		[FieldOffset(188)] public short market_lady_bought_amount; // 200
		[FieldOffset(190)] public fixed byte unk_07[115];
		[FieldOffset(305)] public sbyte _unk_08_6; // 6
		[FieldOffset(307)] public short _unk_09_ffff; // -1
		[FieldOffset(308)] public fixed byte unk_10[48];
		[FieldOffset(356)] public sbyte festival_remaining_dances;
		[FieldOffset(357)] public fixed byte unk_11[27];
		[FieldOffset(384)] public short cart_image_id; // this is off by 18 with respect to the normal SG global ids!
		[FieldOffset(386)] public short _unk_12;
    }
	FigureData data = new FigureData(); // Feature 'target-typed object creation' is not available in C# 7.3. Please use language version 9.0 or greater.

	// constructor
	public short FIGURE_IDX;
	Figure(short _IDX) {
		FIGURE_IDX = _IDX;
	}
	~Figure() { // this should ONLY HAPPEN WHEN RE-INITIALIZING THE Figures ARRAY IN GD (e.g. on gameset change)
		if (in_use())
			figure_delete_UNSAFE();
		// GD.Print("DESPAWNING FIGURE CS OBJECT");
	}
    
	// FigureSprite bridge (hacky but works, for now)
	public Node FigureSprite; 

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
	unsafe void _readFromStream(BinaryReader reader) {
		fixed (byte* ptr = reader.ReadBytes(Marshal.SizeOf<FigureData>()))
			data = Marshal.PtrToStructure<FigureData>((IntPtr)ptr);
	}
	unsafe void _writeToStream(BinaryWriter writer) {
		byte[] buffer = new byte[Marshal.SizeOf<FigureData>()];
		fixed (byte* ptr = buffer)
			Marshal.StructureToPtr<FigureData>(data, (IntPtr)ptr, false);
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

	// =============================== Figure =============================== //

	void set_state(Enums.FigureStates state) {
		data.state = state;
	}
	
	public bool in_use() {
		return data.state != Enums.FigureStates.NONE;
	}
    public void kill() {
        if (data.state != Enums.FigureStates.ALIVE)
            return;
        set_state(Enums.FigureStates.DYING);
        data.action_state = Enums.FigureActions.ACTION_149_CORPSE;
    }
    public void poof(String reason) {
		GD.Print($"figure {FIGURE_IDX} poofed -- reason: {reason}");
		if (data.state != Enums.FigureStates.NONE && data.state != Enums.FigureStates.DEAD)
	        set_state(Enums.FigureStates.DEAD);
    }
	
	public void create(Enums.FigureTypes type, ushort x, ushort y, byte dir) { // TODO
		
	}
	void figure_delete_UNSAFE() {
		Building b = home();
		if (b != null) {
			b.remove_figure(FIGURE_IDX);
			// Building b = home();
			// if (b.has_figure(0, FIGURE_IDX))
			// 	b.remove_figure(0);
			// if (b.has_figure(1, FIGURE_IDX))
			// 	b.remove_figure(1);
		}

		// // switch (type) {
		// // 	case FIGURE_BALLISTA:
		// // 		if (has_home())
		// // 			home()->remove_figure(3);
		// // 		break;
		// // 	case FIGURE_DOCKER:
		// // 		if (has_home()) {
		// // 			building *b = home();
		// // 			for (int i = 0; i < 3; i++) {
		// // 				if (b->data.dock.docker_ids[i] == id)
		// // 					b->data.dock.docker_ids[i] = 0;
		// // 			}
		// // 		}
		// // 		break;
		// // 	case FIGURE_ENEMY_CAESAR_LEGIONARY:
		// // 		city_emperor_mark_soldier_killed();
		// // 		break;
		// // }
		// if (data.empire_city_id != 0)
		// 	empire_city_remove_trader(data.empire_city_id, FIGURE_IDX);

		// if (has_immigrant_home())
		// 	immigrant_home()->remove_figure(2);

		// route_remove();
		// map_figure_remove();

		data.state = Enums.FigureStates.NONE;
		FigureSprite.QueueFree();
		FigureSprite = null;
	}

	// linked buildings: these double as fetchers AND checkers -- if an id is provided, checks that
	// matches (returns null if not); if no id is provided, returns the building (returns null if unset/invalid)
	Building home(short building_id = -1) {
		if (building_id == -1 || building_id == data.home_building_id)
			return GameInterfaces.getBuilding(data.home_building_id);
		return null;
	}
	Building immigrant_home(short building_id = -1) {
		if (building_id == -1 || building_id == data.immigrant_home_building_id)
			return GameInterfaces.getBuilding(data.immigrant_home_building_id);
		return null;
	}
	Building destination(short building_id = -1) {
		if (building_id == -1 || building_id == data.destination_building_id)
			return GameInterfaces.getBuilding(data.destination_building_id);
		return null;
	}

	void update_attacker() {
		// if (data.targeted_by_figure_id != 0) {
		// 	Figure attacker = getFigure(data.targeted_by_figure_id);
		// 	if (attacker.data.state != Enums.FigureStates.ALIVE)
		// 		data.targeted_by_figure_id = 0;
		// 	if (attacker.data.target_figure_id != FIGURE_IDX)
		// 		data.targeted_by_figure_id = 0;
		// }
	}
	void update_animation() {
		
	}
	void update_linked_buildings() {
// 		building *b = home();
// 		building *b_imm = immigrant_home();
// 		figure *leader = figure_get(leading_figure_id);
// 		switch ((Enums.FigureTypes)type) {
// 			case Enums.FigureTypes.IMMIGRANT:
// //                if (b_imm->state != BUILDING_STATE_VALID)
// //                    poof();
// //                if (!b_imm->house_size)
// //                    poof();
// //                if (!b_imm->has_figure(2, id))
// //                    poof();
// 				if (b_imm->type == BUILDING_BURNING_RUIN)
// 					poof();
// 				break;
// 			case Enums.FigureTypes.ENGINEER:
// 			case Enums.FigureTypes.PREFECT:
// 			case Enums.FigureTypes.POLICEMAN:
// 			case Enums.FigureTypes.MAGISTRATE:
// 			case Enums.FigureTypes.WORKER:
// 			case Enums.FigureTypes.MARKET_TRADER:
// 			case Enums.FigureTypes.NATIVE_TRADER:
// 			case Enums.FigureTypes.TAX_COLLECTOR:
// 			case Enums.FigureTypes.TOWER_SENTRY:
// 			case Enums.FigureTypes.MISSIONARY:
// //            case Enums.FigureTypes.ACTOR:
// //            case Enums.FigureTypes.GLADIATOR:
// //            case Enums.FigureTypes.LION_TAMER:
// //            case Enums.FigureTypes.CHARIOTEER:
// 			case Enums.FigureTypes.BATHHOUSE_WORKER:
// 			case Enums.FigureTypes.DOCTOR:
// 			case Enums.FigureTypes.SURGEON:
// 			case Enums.FigureTypes.BARBER:
// 			case Enums.FigureTypes.WATER_CARRIER:
// 			case Enums.FigureTypes.PRIEST:
// 				if (b->state != BUILDING_STATE_VALID || !b->has_figure(0, id))
// 					poof();
// 				break;
// 			case Enums.FigureTypes.HUNTER:
// 			case Enums.FigureTypes.REED_GATHERER:
// 			case Enums.FigureTypes.LUMBERJACK:
// 				if (b->state != BUILDING_STATE_VALID)
// 					poof();
// 				break;
// 			case Enums.FigureTypes.CART_PUSHER:
// 				if (has_destination())
// 					break;
// 				if (!building_is_floodplain_farm(b) && (b->state != BUILDING_STATE_VALID || (!b->has_figure(0, id) && !b->has_figure(1, id))))
// 					poof();
// 				break;
// 			case Enums.FigureTypes.WAREHOUSEMAN:
// 				if (has_destination())
// 					break;
// 				if (b->state != BUILDING_STATE_VALID || (!b->has_figure(0, id) && !b->has_figure(1, id)))
// 					poof();
// 				break;
// 			case Enums.FigureTypes.LABOR_SEEKER:
// //            case Enums.FigureTypes.MARKET_BUYER:
// 				if (b->state != BUILDING_STATE_VALID) //  || !b->has_figure(1, id)
// 					poof();
// 				break;
// 			case Enums.FigureTypes.DELIVERY_BOY:
// 			case Enums.FigureTypes.TRADE_CARAVAN_DONKEY:
// 				if (leading_figure_id <= 0 || leader->action_state == FIGURE_ACTION_149_CORPSE)
// 					poof();
// 				if (leader->is_ghost)
// 					is_ghost = true;
// 				break;
// 		}
	}
	void action_common_pretick() {
// 		switch (action_state) {
// 			case Enums.FigureTypes.ACTION_150_ATTACK:
// 				figure_combat_handle_attack(); break;
// 			case Enums.FigureTypes.ACTION_149_CORPSE:
// 				figure_combat_handle_corpse(); break;
// 			case Enums.FigureTypes.ACTION_125_ROAMING:
// 			case ACTION_1_ROAMING:
// 				if (type == FIGURE_IMMIGRANT || type == FIGURE_EMIGRANT || type == FIGURE_HOMELESS)
// 					break;
// 				do_roam();
// 				break;
// 			case Enums.FigureTypes.ACTION_126_ROAMER_RETURNING:
// 			case ACTION_2_ROAMERS_RETURNING:
// 				if (type == FIGURE_IMMIGRANT || type == FIGURE_EMIGRANT || type == FIGURE_HOMELESS)
// 					break;
// 				do_returnhome();
// 				break;
// 		}
// 		if (state == FIGURE_STATE_DYING) // update corpses / dying animation
// 		figure_combat_handle_corpse();
// 		if (map_terrain_is(tile.grid_offset(), TERRAIN_ROAD)) { // update road flag
// 			outside_road_ticks = 0;
// 			if (map_terrain_is(tile.grid_offset(), TERRAIN_WATER)) // bridge
// 				set_target_height_bridge();
// 		} else {
// 			if (outside_road_ticks < 255)
// 				outside_road_ticks++;
// 			if (!is_boat && map_terrain_is(tile.grid_offset(), TERRAIN_WATER))
// 				kill();
// 			if (is_boat && !map_terrain_is(tile.grid_offset(), TERRAIN_WATER))
// 				kill();
// 			if (terrain_usage == TERRAIN_USAGE_ROADS) { // walkers outside of roads for too long?
// 				if (destination_tile.x() && destination_tile.y() &&
// 					outside_road_ticks > 100) // dudes with destination have a bit of lee way
// 					poof();
// 				if (!destination_tile.x() && !destination_tile.y() && state == Enums.FigureStates.ALIVE && outside_road_ticks > 0)
// 					poof();
// 			}
// 		}
	}



	public bool tick() { // return true if the figure has despawned
		// if DEAD, delete figure -- this is UNSAFE, and must exit the tick loop immediately
		if (data.state == Enums.FigureStates.DEAD) {
			figure_delete_UNSAFE();
			return true;
		}
		
		// invalid action states?
		if (data.action_state < 0)
			set_state(Enums.FigureStates.DEAD);

		update_attacker();

		// reset values like cart image & max roaming length
		// data.cart_image_id = 0;
		// data.max_roam_length = 0;
		// data.use_cross_country = false;
		// data.is_ghost = false;
		// base lookup data
		// figure_action_property action_properties = action_properties_lookup[type];
		// if (action_properties.terrain_usage != -1 && data.terrain_usage == -1)
		// 	data.terrain_usage = action_properties.terrain_usage;
		// max_roam_length = action_properties.max_roam_length;
		// speed_multiplier = action_properties.speed_mult;

		// image_set_animation(action_properties.base_image_collection, action_properties.base_image_group);
		update_animation();

		// check for building being alive (at the start of the action)
		update_linked_buildings();

		// common action states handling
		action_common_pretick();

// 		switch (type) {
// 			case 1: immigrant_action();                 break;
// 			case 2: emigrant_action();                  break;
// 			case 3: homeless_action();                  break;
// 			case 4: cartpusher_action();                break;
// //            case 5: common_action(12, GROUP_FIGURE_LABOR_SEEKER); break;
// 			case 6: explosion_cloud_action();           break;
// 			case 7: tax_collector_action();             break;
// 			case 8: engineer_action();                  break;
// 			case 9: warehouseman_action();              break; // warehouseman_action !!!!
// 			case 10: prefect_action();                  break; //10
// 			case 11: //soldier_action();                  break;
// 			case 12: //soldier_action();                  break;
// 			case 13: soldier_action();                  break;
// 			case 14: military_standard_action();        break;
// 			case 15: //entertainer_action();              break;
// 			case 16: //entertainer_action();              break;
// 			case 17: //entertainer_action();              break;
// 			case 18: entertainer_action();              break;
// 			case 19: trade_caravan_action();            break;
// 			case 20: trade_ship_action();               break; //20
// 			case 21: trade_caravan_donkey_action();     break;
// 			case 22: protestor_action();                break;
// 			case 23: criminal_action();                 break;
// 			case 24: rioter_action();                   break;
// 			case 25: fishing_boat_action();             break;
// 			case 26: market_trader_action();            break;
// 			case 27: priest_action();                   break;
// //            case 27: common_action(12, GROUP_FIGURE_PRIEST); break;
// 			case 28: school_child_action();             break;
// //            case 29: common_action(12, GROUP_FIGURE_TEACHER_LIBRARIAN); break;
// //            case 30: common_action(12, GROUP_FIGURE_TEACHER_LIBRARIAN); break; //30
// //            case 31: common_action(12, GROUP_FIGURE_BARBER); break;
// //            case 32: common_action(12, GROUP_FIGURE_BATHHOUSE_WORKER); break;
// 			case 33: //doctor_action(); break;
// //            case 34: common_action(12, GROUP_FIGURE_DOCTOR_SURGEON); break;
// //            case 35: worker_action();                   break;
// 			case 36: editor_flag_action();              break;
// 			case 37: flotsam_action();                  break;
// 			case 38: docker_action();                   break;
// 			case 39: market_buyer_action();             break;
// //            case 40: patrician_action();                break; //40
// 			case 41: indigenous_native_action();        break;
// 			case 42: tower_sentry_action();             break;
// 			case 43: enemy43_spear_action();            break;
// 			case 44: enemy44_sword_action();            break;
// 			case 45: enemy45_sword_action();            break;
// 			case 46: enemy_camel_action();              break;
// 			case 47: enemy_elephant_action();           break;
// 			case 48: enemy_chariot_action();            break;
// 			case 49: enemy49_fast_sword_action();       break;
// 			case 50: enemy50_sword_action();            break; //50
// 			case 51: enemy51_spear_action();            break;
// 			case 52: enemy52_mounted_archer_action();   break;
// 			case 53: enemy53_axe_action();              break;
// 			case 54: enemy_gladiator_action();          break;
// //                no_action();                            break;
// //                no_action();                            break;
// 			case 57: enemy_caesar_legionary_action();   break;
// 			case 58: native_trader_action();            break;
// 			case 59: arrow_action();                    break;
// 			case 60: javelin_action();                  break; //60
// 			case 61: bolt_action();                     break;
// 			case 62: ballista_action();                 break;
// //                no_action();                            break;
// //            case 64: missionary_action();               break;
// 			case 65: seagulls_action();                 break;
// 			case 66: delivery_boy_action();             break;
// 			case 67: shipwreck_action();                break;
// 			case 68: sheep_action();                    break;
// 			case 69:
// 				if (GAME_ENV == ENGINE_ENV_C3)
// 					wolf_action();
// 				else
// 					ostrich_action();                   break;
// 			case 70: zebra_action();                    break; //70
// 			case 71: spear_action();                    break;
// 			case 72: hippodrome_horse_action();         break;
// 			// PHARAOH vvvv
// 			case 73: hunter_action();                   break;
// 			case 74: arrow_action();                    break;
// 			case 75: gatherer_action();                 break; // wood cutters
// 			case 84: hippo_action();                    break;
// 			case 85: worker_action();                   break;
// 			case 87: water_carrier_action();            break;
// 			case 88: policeman_action();                break;
// 			case 89: magistrate_action();               break;
// 			case 90: gatherer_action();                 break; // reed gatherers
// 			case 91: festival_guy_action();             break;
// 			default:
// 				break;
// 		}

		

		// poof if LOST
		if (data.direction == Enums.FigureDirections.CAN_NOT_REACH)
			poof("figure is lost (direction=FigureDirections.CAN_NOT_REACH)");

		// advance sprite offset
		FigureSprite.Call("advance_sprite_animation");
		return false;
	}
}
