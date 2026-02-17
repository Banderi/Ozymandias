using Godot;
using System;
using System.Runtime.InteropServices; // Marshal

public class Figures_mono : Node
{
    // [StructLayout(LayoutKind.Sequential, Pack = 1)]
    // public class FigureData
    // {
    //     // var _p = Scribe._compressed_top.get_position()
	// 	// assert(_p % 388 == 0)
		
	// 	// Scribe.sync_record([Figures.figures, i], TYPE_DICTIONARY)
	
	// 	public u8 alternative_location_index;
	// 	public u8 anim_frame;
	// 	public u8 is_enemy_image;
	// 	public u8 flotsam_visible;
	// 	public i16 sprite_image_id; // this is off by 18 with respect to the normal SG global ids!
	// 	if Assets.GAME_SET == "C3":
	// 		public i16 cart_image_id;
	// 	elif Assets.GAME_SET == "Pharaoh":
	// 		Scribe.skip(2)
	// 	public i16 next_figure;
	// 	public u8 type;
		
    //     //		if figures[i].type == 0:
    //     //			_skipped += 1
    //     //			Scribe.skip(388 - 11)
    //     //			continue
		
	// 	public u8 resource_id;
	// 	public u8 use_cross_country;
	// 	public u8 is_friendly;
	// 	public u8 state;
	// 	public u8 faction_id;
	// 	public u8 action_state_before_attack;
	// 	public i8 direction;
	// 	public i8 previous_tile_direction;
	// 	public i8 attack_direction;
	// 	public u16 tile_x;
	// 	public u16 tile_y;
	// 	public u16 previous_tile_x;
	// 	public u16 previous_tile_y;
	// 	public u16 missile_damage;
	// 	public u16 damage;
	// 	public i32 tile_grid;
	// 	public u16 destination_tile_x;
	// 	public u16 destination_tile_y;
	// 	public i32 destination_tile_grid;
	// 	public u16 source_tile_x;
	// 	public u16 source_tile_y;
	// 	public u16 formation_position_x.soldier;
	// 	public u16 formation_position_y.soldier;
	// 	public i16 __unused_24; // 0
	// 	public i16 wait_ticks; // 0
	// 	public u8 action_state; // 9
	// 	public u8 progress_on_tile; // 11
	// 	public i16 routing_path_id; // 12
	// 	public i16 routing_path_current_tile; // 4
	// 	public i16 routing_path_length; // 28
	// 	public u8 in_building_wait_ticks; // 0
	// 	public u8 outside_road_ticks; // 1
	// 	public i16 max_roam_length;
	// 	public i16 roam_length;
	// 	public u8 roam_wander_freely;
	// 	public u8 roam_random_counter;
	// 	public i8 roam_turn_direction;
	// 	public i8 roam_ticks_until_next_turn; // 0 ^^^^
	// 	public i16 cc_coords.x;
	// 	public i16 cc_coords.y;
	// 	public i16 cc_destination.x;
	// 	public i16 cc_destination.y;
	// 	public i16 cc_delta.x;
	// 	public i16 cc_delta.y;
	// 	public i16 cc_delta_xy;
	// 	public u8 cc_direction;
	// 	public u8 speed_multiplier;
	// 	public i16 home_building_id;
	// 	public i16 immigrant_home_building_id;
	// 	public i16 destination_building_id;
	// 	public i16 formation_id; // formation: 10
	// 	public u8 index_in_formation; // 3
	// 	public u8 formation_at_rest;
	// 	public u8 migrant_num_people;
	// 	public u8 is_ghost;
	// 	public u8 min_max_seen;
	// 	public u8 __unused_57;
	// 	public i16 leading_figure_id;
	// 	public u8 attack_image_offset;
	// 	public u8 wait_ticks_missile;
	// 	public i8 cart_offset.x;
	// 	public i8 cart_offset.y;
	// 	public u8 empire_city_id;
	// 	public u8 trader_amount_bought;
	// 	public i16 name; // 6
	// 	public u8 terrain_usage;
	// 	public u8 is_boat;
	// 	public u16 resource_amount_full; // 4772 >>>> 112 (resource amount! 2-bytes)
	// 	public u8 height_adjusted_ticks;
	// 	public u8 current_height;
	// 	public u8 target_height;
	// 	public u8 collecting_item_id;
	// 	public u8 trade_ship_failed_dock_attempts;
	// 	public u8 phrase_sequence_exact;
	// 	public i8 phrase_id;
	// 	public u8 phrase_sequence_city;
	// 	public u8 __unused_6f;
	// 	public u8 trader_id;
	// 	public u8 wait_ticks_next_target;
	// 	public i16 target_figure_id;
	// 	public i16 targeted_by_figure_id;
	// 	public u16 created_sequence;
	// 	public u16 target_figure_created_sequence;
	// //    public u8 figures_sametile_num;
	// 	Scribe.skip(1)
	// 	public u8 num_attackers;
	// 	public i16 attacker_id1;
	// 	public i16 attacker_id2;
	// 	public i16 opponent_id;
	// 	if Assets.GAME_SET == "Pharaoh":
	// //        Scribe.skip(239")
	// 		Scribe.skip(7)
	// 		public i16 unk_ph1_269; // 269
	// 		public i16 unk_ph2_00; // 0
	// 		public i32 market_lady_resource_image_offset; // 03 00 00 00
	// 		Scribe.skip(12) // FF FF FF FF FF ...
	// 		public i16 market_lady_returning_home_id; // 26
	// 		Scribe.skip(14) // 00 00 00 00 00 00 00 ...
	// 		public i16 market_lady_bought_amount; // 200
	// 		Scribe.skip(115)
	// 		public i8 unk_ph3_6; // 6
	// 		public i16 unk_ph4_ffff; // -1
	// 		Scribe.skip(48)
	// 		public i8 festival_remaining_dances;
	// 		Scribe.skip(27)
	// 		public i16 cart_image_id; // this is off by 18 with respect to the normal SG global ids!
	// 		Scribe.skip(2)
    // }
    
    public void enscribe_figures()
    {
        
    }
}
