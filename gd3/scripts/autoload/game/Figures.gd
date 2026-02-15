extends Node

const MAX_FIGURES = 2000
const MAX_ROUTES = 1000
const MAX_FORMATIONS = 50
const MAX_TRADERS = 100
const MAX_FERRIES = 50
const MAX_FIGURES_PER_FERRY = 11
const MAX_FIGURES_WAITING_PER_FERRY = 56

var figures = []
var figure_names_1 = []
var figure_names_2 = []
var figure_names_3 = []
var figure_sequence = 0
var figure_traders = []
var next_free_trader_index = 0

# formations
var formations = []
var last_used_formation
var last_formation_id
var total_formations

# ferries
var ferry_queues = []
var ferry_transiting = []

func spawn_sprites(): # TODO
	pass

class Figure:
	var a = 0

func enscribe_figure():
#	iob->bind(BIND_SIGNATURE_UINT8, &f->alternative_location_index);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->anim_frame);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->is_enemy_image);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->flotsam_visible);
#
#//    f->sprite_image_id = buf->read_i16() + 18;
#    f->sprite_image_id -= 18;
#    iob->bind(BIND_SIGNATURE_INT16, &f->sprite_image_id);
#    f->sprite_image_id += 18;
#
#    if (GAME_ENV == ENGINE_ENV_C3)
#        iob->bind(BIND_SIGNATURE_INT16, &f->cart_image_id);
#    else if (GAME_ENV == ENGINE_ENV_PHARAOH)
#        iob->bind____skip(2);
#    iob->bind(BIND_SIGNATURE_INT16, &f->next_figure);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->type);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->resource_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->use_cross_country);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->is_friendly);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->state);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->faction_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->action_state_before_attack);
#    iob->bind(BIND_SIGNATURE_INT8, &f->direction);
#    iob->bind(BIND_SIGNATURE_INT8, &f->previous_tile_direction);
#    iob->bind(BIND_SIGNATURE_INT8, &f->attack_direction);
#    iob->bind(BIND_SIGNATURE_UINT16, f->tile.private_access(_X));
#    iob->bind(BIND_SIGNATURE_UINT16, f->tile.private_access(_Y));
#    iob->bind(BIND_SIGNATURE_UINT16, f->previous_tile.private_access(_X));
#    iob->bind(BIND_SIGNATURE_UINT16, f->previous_tile.private_access(_Y));
#    iob->bind(BIND_SIGNATURE_UINT16, &f->missile_damage);
#    iob->bind(BIND_SIGNATURE_UINT16, &f->damage);
#    iob->bind(BIND_SIGNATURE_INT32, f->tile.private_access(_GRID_OFFSET));
#    iob->bind(BIND_SIGNATURE_UINT16, f->destination_tile.private_access(_X));
#    iob->bind(BIND_SIGNATURE_UINT16, f->destination_tile.private_access(_Y));
#    iob->bind(BIND_SIGNATURE_INT32, f->destination_tile.private_access(_GRID_OFFSET));
#    iob->bind(BIND_SIGNATURE_UINT16, f->source_tile.private_access(_X));
#    iob->bind(BIND_SIGNATURE_UINT16, f->source_tile.private_access(_Y));
#    iob->bind(BIND_SIGNATURE_UINT16, &f->formation_position_x.soldier);
#    iob->bind(BIND_SIGNATURE_UINT16, &f->formation_position_y.soldier);
#    iob->bind(BIND_SIGNATURE_INT16, &f->__unused_24); // 0
#    iob->bind(BIND_SIGNATURE_INT16, &f->wait_ticks); // 0
#    iob->bind(BIND_SIGNATURE_UINT8, &f->action_state); // 9
#    iob->bind(BIND_SIGNATURE_UINT8, &f->progress_on_tile); // 11
#    iob->bind(BIND_SIGNATURE_INT16, &f->routing_path_id); // 12
#    iob->bind(BIND_SIGNATURE_INT16, &f->routing_path_current_tile); // 4
#    iob->bind(BIND_SIGNATURE_INT16, &f->routing_path_length); // 28
#    iob->bind(BIND_SIGNATURE_UINT8, &f->in_building_wait_ticks); // 0
#    iob->bind(BIND_SIGNATURE_UINT8, &f->outside_road_ticks); // 1
#    iob->bind(BIND_SIGNATURE_INT16, &f->max_roam_length);
#    iob->bind(BIND_SIGNATURE_INT16, &f->roam_length);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->roam_wander_freely);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->roam_random_counter);
#    iob->bind(BIND_SIGNATURE_INT8, &f->roam_turn_direction);
#    iob->bind(BIND_SIGNATURE_INT8, &f->roam_ticks_until_next_turn); // 0 ^^^^
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_coords.x);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_coords.y);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_destination.x);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_destination.y);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_delta.x);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_delta.y);
#    iob->bind(BIND_SIGNATURE_INT16, &f->cc_delta_xy);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->cc_direction);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->speed_multiplier);
#    iob->bind(BIND_SIGNATURE_INT16, &f->home_building_id);
#    iob->bind(BIND_SIGNATURE_INT16, &f->immigrant_home_building_id);
#    iob->bind(BIND_SIGNATURE_INT16, &f->destination_building_id);
#    iob->bind(BIND_SIGNATURE_INT16, &f->formation_id); // formation: 10
#    iob->bind(BIND_SIGNATURE_UINT8, &f->index_in_formation); // 3
#    iob->bind(BIND_SIGNATURE_UINT8, &f->formation_at_rest);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->migrant_num_people);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->is_ghost);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->min_max_seen);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->__unused_57);
#    iob->bind(BIND_SIGNATURE_INT16, &f->leading_figure_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->attack_image_offset);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->wait_ticks_missile);
#    iob->bind(BIND_SIGNATURE_INT8, &f->cart_offset.x);
#    iob->bind(BIND_SIGNATURE_INT8, &f->cart_offset.y);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->empire_city_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->trader_amount_bought);
#    iob->bind(BIND_SIGNATURE_INT16, &f->name); // 6
#    iob->bind(BIND_SIGNATURE_UINT8, &f->terrain_usage);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->is_boat);
#    iob->bind(BIND_SIGNATURE_UINT16, &f->resource_amount_full); // 4772 >>>> 112 (resource amount! 2-bytes)
#    iob->bind(BIND_SIGNATURE_UINT8, &f->height_adjusted_ticks);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->current_height);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->target_height);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->collecting_item_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->trade_ship_failed_dock_attempts);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->phrase_sequence_exact);
#    iob->bind(BIND_SIGNATURE_INT8, &f->phrase_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->phrase_sequence_city);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->__unused_6f);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->trader_id);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->wait_ticks_next_target);
#    iob->bind(BIND_SIGNATURE_INT16, &f->target_figure_id);
#    iob->bind(BIND_SIGNATURE_INT16, &f->targeted_by_figure_id);
#    iob->bind(BIND_SIGNATURE_UINT16, &f->created_sequence);
#    iob->bind(BIND_SIGNATURE_UINT16, &f->target_figure_created_sequence);
#//    iob->bind(BIND_SIGNATURE_UINT8, &f->figures_sametile_num);
#    iob->bind____skip(1);
#    iob->bind(BIND_SIGNATURE_UINT8, &f->num_attackers);
#    iob->bind(BIND_SIGNATURE_INT16, &f->attacker_id1);
#    iob->bind(BIND_SIGNATURE_INT16, &f->attacker_id2);
#    iob->bind(BIND_SIGNATURE_INT16, &f->opponent_id);
#    if (GAME_ENV == ENGINE_ENV_PHARAOH) {
#//        iob->bind____skip(239);
#        iob->bind____skip(7);
#        iob->bind(BIND_SIGNATURE_INT16, &f->unk_ph1_269); // 269
#        iob->bind(BIND_SIGNATURE_INT16, &f->unk_ph2_00); // 0
#        iob->bind(BIND_SIGNATURE_INT32, &f->market_lady_resource_image_offset); // 03 00 00 00
#        iob->bind____skip(12); // FF FF FF FF FF ...
#        iob->bind(BIND_SIGNATURE_INT16, &f->market_lady_returning_home_id); // 26
#        iob->bind____skip(14); // 00 00 00 00 00 00 00 ...
#        iob->bind(BIND_SIGNATURE_INT16, &f->market_lady_bought_amount); // 200
#        iob->bind____skip(115);
#        iob->bind(BIND_SIGNATURE_INT8, &f->unk_ph3_6); // 6
#        iob->bind(BIND_SIGNATURE_INT16, &f->unk_ph4_ffff); // -1
#        iob->bind____skip(48);
#        iob->bind(BIND_SIGNATURE_INT8, &f->festival_remaining_dances);
#        iob->bind____skip(27);
#
#        f->cart_image_id -= 18;
#        iob->bind(BIND_SIGNATURE_INT16, &f->cart_image_id);
#        f->cart_image_id += 18;
#
#        iob->bind____skip(2);
#    }
	pass



func _enter_tree():
	for i in MAX_FIGURES:
		figures.push_back(Figure.new())
func _ready():
	assert(figures.size() == MAX_FIGURES)
