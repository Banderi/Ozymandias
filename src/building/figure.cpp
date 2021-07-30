#include "figuretype/entertainer.h"
#include "building/figure.h"

#include "building/barracks.h"
#include "building/granary.h"
#include "building/industry.h"
#include "building/market.h"
#include "building/model.h"
#include "building/warehouse.h"
#include "city/buildings.h"
#include "city/entertainment.h"
#include "city/message.h"
#include "city/population.h"
#include "core/calc.h"
#include "core/config.h"
#include "core/image.h"
#include "figure/figure.h"
#include "figure/formation_legion.h"
#include "figure/movement.h"
#include "game/resource.h"
#include "map/building_tiles.h"
#include "map/desirability.h"
#include "map/image.h"
#include "map/random.h"
#include "map/road_access.h"
#include "map/terrain.h"
#include "map/water.h"

#include <math.h>
#include <city/floods.h>

const int generic_delay_table[] = {
        0,
        1,
        3,
        7,
        15,
        29,
        44
};

figure *building::get_figure(int i) {
    return figure_get(get_figureID(i));
}
void building::set_figure(int i, int figure_id) {
//    // correct index if out of bounds
//    if (i < 0)
//        i = 0;
//    if (i >= MAX_FIGURES_PER_BUILDING)
//        i = MAX_FIGURES_PER_BUILDING - 1;

//    // correct id if below zero
//    if (id < 0)
//        figure_id = 0;

    figure_ids_array[i] = figure_id;
}
void building::set_figure(int i, figure *f) {
//    if (f == nullptr)
//        return;
    set_figure(i, f->id);
}
void building::remove_figure(int i) {
    set_figure(i, 0);
}
bool building::has_figure(int i, int figure_id) {
    // seatrch through all the figures if index is -1
    if (i == -1) {
        bool has_any = false;
        for (int i = 0; i < MAX_FIGURES_PER_BUILDING; i++)
            if (has_figure(i, figure_id))
                has_any = true;
        return has_any;
    } else {

        // only check if there is a figure
        if (figure_id < 0)
            return (get_figureID(i) > 0);

        figure *f = get_figure(i);
        if (f->state && f->home() == this) { // check if figure belongs to this building...
            return (f->id == figure_id);
        } else { // decouple if figure does not belong to this building - assume cache is incorrect
            remove_figure(i);
            return false;
        }
    }
}
bool building::has_figure(int i, figure *f) {
    return has_figure(i, f->id);
}
bool building::has_figure_of_type(int i, int _type) {
    // seatrch through all the figures if index is -1
    if (i == -1) {
        bool has_any = false;
        for (int i = 0; i < MAX_FIGURES_PER_BUILDING; i++)
            if (get_figure(i)->type == _type)
                has_any = true;
        return has_any;
    }
    else
        return (get_figure(i)->type == _type);
}

figure *building::create_figure_generic(int _type, int created_action, int slot, int created_dir) {
    figure *f = figure_create(_type, road_access_x, road_access_y, created_dir);
    f->action_state = created_action;
    f->set_home(id);
    return f;
}
figure *building::create_roaming_figure(int _type, int created_action, int slot) {
    figure *f = create_figure_generic(_type, created_action, slot, figure_roam_direction);
    f->set_destination(0);
    f->set_immigrant_home(0);

    set_figure(slot, f->id); // warning: this overwrites any existing figure!
    f->init_roaming_from_building(figure_roam_direction);

    // update building to have a different roamer direction for next time
    figure_roam_direction += 2;
    if (figure_roam_direction > 6)
        figure_roam_direction = 0;

    return f;
}
figure *building::create_figure_with_destination(int _type, building *destination, int created_action, int slot) {
    figure *f = create_figure_generic(_type, created_action, slot, DIR_4_BOTTOM_LEFT);
    f->set_destination(destination->id);
    f->set_immigrant_home(0);

    set_figure(slot, f->id); // warning: this overwrites any existing figure!
    return f;
}
figure *building::create_cartpusher(int resource_id, int quantity, int created_action, int slot) {
    figure *f = create_figure_generic(FIGURE_CART_PUSHER, created_action, slot, DIR_4_BOTTOM_LEFT);
    f->load_resource(quantity, resource_id);
    f->set_destination(0);
    f->set_immigrant_home(0);

    set_figure(slot, f->id); // warning: this overwrites any existing figure!
    f->wait_ticks = 30;
}

int building::worker_percentage() {
    return calc_percentage(num_workers, model_get_building(type)->laborers);
}
int building::figure_spawn_timer() {
    int pct_workers = worker_percentage();
    if (pct_workers >= 100)
        return 0;
    else if (pct_workers >= 75)
        return 1;
    else if (pct_workers >= 50)
        return 3;
    else if (pct_workers >= 25)
        return 7;
    else if (pct_workers >= 1)
        return 15;
    else
        return -1;
}
void building::check_labor_problem() {
    if ((houses_covered <= 0 && labor_category != 255) || (labor_category == 255 && num_workers <= 0))
        show_on_problem_overlay = 2;
}
void building::common_spawn_labor_seeker(int min_houses) {
    if (city_population() <= 0)
        return;
    if (config_get(CONFIG_GP_CH_GLOBAL_LABOUR)) {
        // If it can access Rome
        if (distance_from_entry)
            houses_covered = 2 * min_houses;
        else
            houses_covered = 0;
    } else if (houses_covered <= min_houses) {
        if (has_figure(1)) // no figure slot available!
            return;
        else
            create_roaming_figure(FIGURE_LABOR_SEEKER, FIGURE_ACTION_125_ROAMING, true);
    }
}
bool building::common_spawn_figure_trigger(int min_houses) {
    check_labor_problem();
    if (has_figure(0))
        return false;
    if (road_is_accessible) {
        if (main() == this) // only spawn from the main building
            common_spawn_labor_seeker(min_houses);
        int pct_workers = worker_percentage();
        int spawn_delay = figure_spawn_timer();
        if (spawn_delay == -1)
            return false;
        figure_spawn_delay++;
        if (figure_spawn_delay > spawn_delay) {
            figure_spawn_delay = 0;
            return true;
        }
    }
}
bool building::common_spawn_roamer(int type, int min_houses, int created_action) {
    if (common_spawn_figure_trigger(min_houses)) {
        create_roaming_figure(type, created_action);
        return true;
    }
    return false;
}
bool building::common_spawn_goods_output_cartpusher(bool only_one) {
    // can only have one?
    if (only_one && has_figure_of_type(0, FIGURE_CART_PUSHER))
        return false;

    // no checking for work force? doesn't matter anyways.... there's no instance
    // in the game that allows cartpushers to spawn before the workers disappear!
    if (road_is_accessible) {
        while (loads_stored) {
            int loads_to_carry = fmin(loads_stored, 4);
            create_cartpusher(output_resource_id, loads_to_carry * 100);
            loads_stored -= loads_to_carry;
            if (only_one || loads_stored == 0) // done once, or out of goods?
                return true;
        }
    }
    return false;
}

void building::spawn_figure_work_camp() {
    if (common_spawn_figure_trigger(100)) {
        building *dest = building_get(building_determine_worker_needed());
        figure *f = create_figure_with_destination(FIGURE_WORKER_PH, dest);
        dest->data.industry.worker_id = f->id;
    }
}

bool building::spawn_patrician(bool spawned) {
    return common_spawn_roamer(FIGURE_PATRICIAN, 0);
}
void building::spawn_figure_engineers_post() {
    common_spawn_roamer(FIGURE_ENGINEER, 100, FIGURE_ACTION_60_ENGINEER_CREATED);
}
void building::spawn_figure_prefecture() {
    common_spawn_roamer(FIGURE_PREFECT, 100, FIGURE_ACTION_70_PREFECT_CREATED);
}
void building::spawn_figure_police() {
    common_spawn_roamer(FIGURE_POLICEMAN, 100, FIGURE_ACTION_70_PREFECT_CREATED);
}

void building::spawn_figure_actor_juggler() {
    if (common_spawn_figure_trigger(50)) {
        building *dest = building_get(determine_venue_destination(road_access_x, road_access_y, BUILDING_PAVILLION, BUILDING_BANDSTAND, BUILDING_BOOTH));
        if (GAME_ENV == ENGINE_ENV_PHARAOH)
            create_figure_with_destination(FIGURE_JUGGLER, dest, FIGURE_ACTION_92_ENTERTAINER_GOING_TO_VENUE);
        else
            common_spawn_roamer(FIGURE_ACTOR, FIGURE_ACTION_90_ENTERTAINER_AT_SCHOOL_CREATED);
    }
}
void building::spawn_figure_gladiator_musician() {
    if (common_spawn_figure_trigger(50)) {
        building *dest = building_get(determine_venue_destination(road_access_x, road_access_y, BUILDING_PAVILLION, BUILDING_BANDSTAND, 0));
        if (GAME_ENV == ENGINE_ENV_PHARAOH)
            create_figure_with_destination(FIGURE_MUSICIAN, dest, FIGURE_ACTION_92_ENTERTAINER_GOING_TO_VENUE);
        else
            common_spawn_roamer(FIGURE_GLADIATOR, FIGURE_ACTION_90_ENTERTAINER_AT_SCHOOL_CREATED);
    }
}
void building::spawn_figure_lion_tamer_dancer() {
    if (common_spawn_figure_trigger(50)) {
        building *dest = building_get(determine_venue_destination(road_access_x, road_access_y, BUILDING_PAVILLION, 0, 0));
        if (GAME_ENV == ENGINE_ENV_PHARAOH)
            create_figure_with_destination(FIGURE_DANCER, dest, FIGURE_ACTION_92_ENTERTAINER_GOING_TO_VENUE);
        else
            common_spawn_roamer(FIGURE_LION_TAMER, FIGURE_ACTION_90_ENTERTAINER_AT_SCHOOL_CREATED);
    }
}
void building::spawn_figure_chariot_senet_master() {
    common_spawn_roamer(FIGURE_CHARIOTEER, 50, FIGURE_ACTION_90_ENTERTAINER_AT_SCHOOL_CREATED);
}

void building::spawn_figure_theater_booth() {
    if (!is_main())
        return;
    if (common_spawn_figure_trigger(100)) {
        if (data.entertainment.days1 > 0)
            create_roaming_figure(FIGURE_JUGGLER, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
    }
}
void building::spawn_figure_amphitheater_bandstand() {
    if (!is_main())
        return;
    if (common_spawn_figure_trigger(100)) {
        if (data.entertainment.days1 > 0)
            create_roaming_figure(FIGURE_JUGGLER, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
        if (data.entertainment.days2 > 0)
            create_roaming_figure(FIGURE_MUSICIAN, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
    }
}
void building::spawn_figure_colosseum_pavillion() {
    if (!is_main())
        return;
    if (common_spawn_figure_trigger(100)) {
        if (data.entertainment.days1 > 0)
            create_roaming_figure(FIGURE_JUGGLER, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
        if (data.entertainment.days2 > 0)
            create_roaming_figure(FIGURE_MUSICIAN, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
        if (data.entertainment.days3_or_play > 0)
            create_roaming_figure(FIGURE_DANCER, FIGURE_ACTION_94_ENTERTAINER_ROAMING);
    }
}
void building::spawn_figure_hippodrome_senet() {
    // TODO
//    check_labor_problem();
//    if (prev_part_building_id)
//        return;
//    building *part = b;
//    for (int i = 0; i < 2; i++) {
//        part = part->next();
//        if (part->id)
//            part->show_on_problem_overlay = show_on_problem_overlay;
//
//    }
//    if (has_figure_of_type(FIGURE_CHARIOTEER))
//        return;
//    map_point road;
//    if (map_has_road_access_hippodrome_rotation(x, y, &road, subtype.orientation)) {
//        if (houses_covered <= 50 || data.entertainment.days1 <= 0)
//            generate_labor_seeker(road.x, road.y);
//
//        int pct_workers = worker_percentage();
//        int spawn_delay;
//        if (pct_workers >= 100)
//            spawn_delay = 7;
//        else if (pct_workers >= 75)
//            spawn_delay = 15;
//        else if (pct_workers >= 50)
//            spawn_delay = 30;
//        else if (pct_workers >= 25)
//            spawn_delay = 50;
//        else if (pct_workers >= 1)
//            spawn_delay = 80;
//        else
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            figure *f = figure_create(FIGURE_CHARIOTEER, road.x, road.y, DIR_0_TOP_RIGHT);
//            f->action_state = FIGURE_ACTION_94_ENTERTAINER_ROAMING;
//            f->home() = b;
//            figure_id = f->id;
//            f->init_roaming();
//
//            if (!city_entertainment_hippodrome_has_race()) {
//                // create mini-horses
//                figure *horse1 = figure_create(FIGURE_HIPPODROME_HORSES, x + 2, y + 1, DIR_2_BOTTOM_RIGHT);
//                horse1->action_state = FIGURE_ACTION_200_HIPPODROME_HORSE_CREATED;
//                horse1->building_id = id;
//                horse1->set_resource(0);
//                horse1->speed_multiplier = 3;
//
//                figure *horse2 = figure_create(FIGURE_HIPPODROME_HORSES, x + 2, y + 2, DIR_2_BOTTOM_RIGHT);
//                horse2->action_state = FIGURE_ACTION_200_HIPPODROME_HORSE_CREATED;
//                horse2->building_id = id;
//                horse1->set_resource(1);
//                horse2->speed_multiplier = 2;
//
//                if (data.entertainment.days1 > 0) {
//                    if (city_entertainment_show_message_hippodrome())
//                        city_message_post(true, MESSAGE_WORKING_HIPPODROME, 0, 0);
//
//                }
//            }
//        }
//    }
}

void building::set_market_graphic() {
    if (state != BUILDING_STATE_VALID)
        return;
    if (map_desirability_get(grid_offset) <= 30) {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_MARKET), TERRAIN_BUILDING);
    } else {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_MARKET_FANCY), TERRAIN_BUILDING);
    }
}
void building::spawn_figure_market() {
    set_market_graphic();
    check_labor_problem();

    if (road_is_accessible) {
        common_spawn_labor_seeker(50);
        int pct_workers = worker_percentage();
        int spawn_delay = figure_spawn_timer();
        if (!has_figure_of_type(0, FIGURE_MARKET_TRADER) && !has_figure_of_type(0, FIGURE_MARKET_BUYER)) {
            // market buyer
            building *dest = building_get(building_market_get_storage_destination(this));
            if (dest->id) {
                figure *f = create_figure_with_destination(FIGURE_MARKET_BUYER, dest, FIGURE_ACTION_145_MARKET_BUYER_GOING_TO_STORAGE);
                f->collecting_item_id = data.market.fetch_inventory_id;
            }
            else {
                // market trader
                figure_spawn_delay++;
                if (figure_spawn_delay > spawn_delay) {
                    figure_spawn_delay = 0;
                    create_roaming_figure(FIGURE_MARKET_TRADER);
                    return;
                }
            }
        }
    }
}

void building::set_bathhouse_graphic() {
    if (state != BUILDING_STATE_VALID)
        return;
    if (map_terrain_exists_tile_in_area_with_type(x, y, size, TERRAIN_GROUNDWATER))
        has_water_access = 1;
    else
        has_water_access = 0;
    if (has_water_access && num_workers) {
        if (map_desirability_get(grid_offset) <= 30) {
            map_building_tiles_add(id, x, y, size,
                                   image_id_from_group(GROUP_BUILDING_BATHHOUSE_WATER), TERRAIN_BUILDING);
        } else {
            map_building_tiles_add(id, x, y, size,
                                   image_id_from_group(GROUP_BUILDING_BATHHOUSE_FANCY_WATER), TERRAIN_BUILDING);
        }
    } else {
        if (map_desirability_get(grid_offset) <= 30) {
            map_building_tiles_add(id, x, y, size,
                                   image_id_from_group(GROUP_BUILDING_BATHHOUSE_NO_WATER), TERRAIN_BUILDING);
        } else {
            map_building_tiles_add(id, x, y, size,
                                   image_id_from_group(GROUP_BUILDING_BATHHOUSE_FANCY_NO_WATER), TERRAIN_BUILDING);
        }
    }
}
void building::spawn_figure_bathhouse() {
    if (!has_water_access)
        show_on_problem_overlay = 2;
    common_spawn_roamer(FIGURE_BATHHOUSE_WORKER, 50);
//    check_labor_problem();
//    if (!has_water_access)
//        show_on_problem_overlay = 2;
//
//    if (has_figure_of_type(FIGURE_BATHHOUSE_WORKER))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road) && has_water_access) {
//        spawn_labor_seeker(50);
//        int spawn_delay = default_spawn_delay();
//        if (!spawn_delay)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_BATHHOUSE_WORKER);
//        }
//    }
}
void building::spawn_figure_school() {
    check_labor_problem();
    if (has_figure_of_type(0, FIGURE_SCHOOL_CHILD))
        return;
    map_point road;
    if (map_has_road_access(x, y, size, &road)) {
        common_spawn_labor_seeker(50);
        int spawn_delay = figure_spawn_timer();
        if (spawn_delay == -1)
            return;
        figure_spawn_delay++;
        if (figure_spawn_delay > spawn_delay) {
            figure_spawn_delay = 0;

            figure *child1 = figure_create(FIGURE_SCHOOL_CHILD, road.x, road.y, DIR_0_TOP_RIGHT);
            child1->action_state = FIGURE_ACTION_125_ROAMING;
            child1->set_home(id);
            set_figure(0, child1->id); // first "child" (teacher) is the coupled figure to the school building
            child1->init_roaming_from_building(0);

            figure *child2 = figure_create(FIGURE_SCHOOL_CHILD, road.x, road.y, DIR_0_TOP_RIGHT);
            child2->action_state = FIGURE_ACTION_125_ROAMING;
            child1->set_home(id);
            child2->init_roaming_from_building(0);

            figure *child3 = figure_create(FIGURE_SCHOOL_CHILD, road.x, road.y, DIR_0_TOP_RIGHT);
            child3->action_state = FIGURE_ACTION_125_ROAMING;
            child1->set_home(id);
            child3->init_roaming_from_building(0);

            figure *child4 = figure_create(FIGURE_SCHOOL_CHILD, road.x, road.y, DIR_0_TOP_RIGHT);
            child4->action_state = FIGURE_ACTION_125_ROAMING;
            child1->set_home(id);
            child4->init_roaming_from_building(0);
        }
    }
}
void building::spawn_figure_library() {
    common_spawn_roamer(FIGURE_LIBRARIAN, 50);
    check_labor_problem();
//    if (has_figure_of_type(FIGURE_LIBRARIAN))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int spawn_delay = figure_spawn_timer();
//        if (spawn_delay == -1)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_LIBRARIAN);
//        }
//    }
}
void building::spawn_figure_academy() {
//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_TEACHER))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int spawn_delay = figure_spawn_timer();
//        if (spawn_delay == -1)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_TEACHER);
//        }
//    }
}
void building::spawn_figure_barber() {
    common_spawn_roamer(FIGURE_BARBER, 50);
//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_BARBER))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int spawn_delay = figure_spawn_timer();
//        if (spawn_delay == -1)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_BARBER);
//        }
//    }
}
void building::spawn_figure_doctor() {
    common_spawn_roamer(FIGURE_DOCTOR, 50);
//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_DOCTOR))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int spawn_delay = figure_spawn_timer();
//        if (spawn_delay == -1)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_DOCTOR);
//        }
//    }
}
void building::spawn_figure_hospital() {
    common_spawn_roamer(FIGURE_SURGEON, 50);
}
void building::spawn_figure_physician() {
    common_spawn_roamer(FIGURE_BATHHOUSE_WORKER, 50);
}
void building::spawn_figure_magistrate() {
    common_spawn_roamer(FIGURE_MAGISTRATE, 50);
}
void building::spawn_figure_temple() {
    common_spawn_roamer(FIGURE_PRIEST, 50);
//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_PRIEST) ||
//        (building_is_large_temple(type) && prev_part_building_id)) {
//        return;
//    }
//
//    map_point road;
//    if ((building_is_temple(type) && map_has_road_access(x, y, size, &road)) ||
//        (building_is_large_temple(type) && map_has_road_access_temple_complex(x, y, &road))) {
//
//        spawn_labor_seeker(50);
//        int pct_workers = worker_percentage();
//        int spawn_delay;
//        if (model_get_building(type)->laborers <= 0)
//            spawn_delay = 7;
//        else if (pct_workers >= 100)
//            spawn_delay = 3;
//        else if (pct_workers >= 75)
//            spawn_delay = 7;
//        else if (pct_workers >= 50)
//            spawn_delay = 10;
//        else if (pct_workers >= 25)
//            spawn_delay = 15;
//        else if (pct_workers >= 1)
//            spawn_delay = 20;
//        else
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_PRIEST);
//        }
//    }
}

void building::set_water_supply_graphic() {
    if (state != BUILDING_STATE_VALID)
        return;
    if (map_desirability_get(grid_offset) <= 30) {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_BATHHOUSE_WATER), TERRAIN_BUILDING);
    } else {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_BATHHOUSE_WATER) + 2, TERRAIN_BUILDING);
    }
}
void building::spawn_figure_watersupply() {
    common_spawn_roamer(FIGURE_WATER_CARRIER, 50);
//    set_water_supply_graphic();

//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_WATER_CARRIER))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(100);
//        int pct_workers = worker_percentage();
//        int spawn_delay;
//        if (pct_workers >= 100)
//            spawn_delay = 0;
//        else if (pct_workers >= 75)
//            spawn_delay = 1;
//        else if (pct_workers >= 50)
//            spawn_delay = 3;
//        else if (pct_workers >= 25)
//            spawn_delay = 7;
//        else if (pct_workers >= 1)
//            spawn_delay = 15;
//        else
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            figure *f = figure_create(FIGURE_WATER_CARRIER, road.x, road.y, DIR_0_TOP_RIGHT);
//            f->action_state = ACTION_1_ROAMING;
//            f->home() = b;
//            figure_id = f->id;
//        }
//    }
}

void building::set_senate_graphic() {
    if (state != BUILDING_STATE_VALID)
        return;
    if (map_desirability_get(grid_offset) <= 30) {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_SENATE), TERRAIN_BUILDING);
    } else {
        map_building_tiles_add(id, x, y, size,
                               image_id_from_group(GROUP_BUILDING_SENATE_FANCY), TERRAIN_BUILDING);
    }
}
void building::spawn_figure_tax_collector() {
    if (type == BUILDING_SENATE_UPGRADED)
        set_senate_graphic();

    common_spawn_roamer(FIGURE_TAX_COLLECTOR, 50);

//    check_labor_problem();
//    if (has_figure_of_type(FIGURE_TAX_COLLECTOR))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int pct_workers = worker_percentage();
//        int spawn_delay;
//        if (pct_workers >= 100)
//            spawn_delay = 0;
//        else if (pct_workers >= 75)
//            spawn_delay = 1;
//        else if (pct_workers >= 50)
//            spawn_delay = 3;
//        else if (pct_workers >= 25)
//            spawn_delay = 7;
//        else if (pct_workers >= 1)
//            spawn_delay = 15;
//        else
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            figure *f = figure_create(FIGURE_TAX_COLLECTOR, road.x, road.y, DIR_0_TOP_RIGHT);
//            f->action_state = FIGURE_ACTION_40_TAX_COLLECTOR_CREATED;
//            f->home() = b;
//            figure_id = f->id;
//        }
//    }
}
void building::spawn_figure_senate() {
    check_labor_problem();
//    if (has_figure_of_type(FIGURE_MAGISTRATE))
//        return;
    map_point road;
    if (map_has_road_access(x, y, size, &road)) {
        common_spawn_labor_seeker(50);
//        int spawn_delay = default_spawn_delay();
//        if (spawn_delay == -1)
//            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay) {
//            figure_spawn_delay = 0;
//            create_roaming_figure(road.x, road.y, FIGURE_MAGISTRATE);
//        }
    }
}
void building::spawn_figure_mission_post() {
//    if (has_figure_of_type(FIGURE_MISSIONARY))
//        return;
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        if (city_population() > 0) {
//            city_buildings_set_mission_post_operational();
//            figure_spawn_delay++;
//            if (figure_spawn_delay > 1) {
//                figure_spawn_delay = 0;
//                create_roaming_figure(road.x, road.y, FIGURE_MISSIONARY);
//            }
//        }
//    }
}

#include "city/data.h"

void building::spawn_figure_industry() {
    check_labor_problem();
    if (road_is_accessible) {
        if (labor_category != 255) { // normal farms
            common_spawn_labor_seeker(50);
            if (has_figure_of_type(0, FIGURE_CART_PUSHER))
                return;
            if (building_industry_has_produced_resource(this)) {
                building_industry_start_new_production(this);
                create_cartpusher(output_resource_id, 100);
            }
        } else { // floodplain farms!!
            if (has_figure_of_type(0, FIGURE_CART_PUSHER))
                return;
            if (building_industry_has_produced_resource(this)) {
                create_cartpusher(output_resource_id, data.industry.progress / 2.5);
                building_farm_deplete_soil(this);
                data.industry.progress = 0;
                data.industry.worker_id = 0;
                data.industry.labor_state = 0;
                data.industry.labor_days_left = 0;
                num_workers = 0;
            }
        }
    }
}
void building::spawn_figure_wharf() {
    common_spawn_figure_trigger(100);
//    if (common_spawn_figure_trigger()) {
//        create_figure_generic(FIGURE_FISHING_BOAT, ACTION_8_RECALCULATE, 0, DIR_4_BOTTOM_LEFT);
//    }
    common_spawn_goods_output_cartpusher();




//    check_labor_problem();
//    if (data.industry.fishing_boat_id) {
//        figure *f = figure_get(data.industry.fishing_boat_id);
//        if (f->state != FIGURE_STATE_ALIVE || f->type != FIGURE_FISHING_BOAT)
//            data.industry.fishing_boat_id = 0;
//
//    }
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        if (has_figure_of_type(FIGURE_CART_PUSHER))
//            return;
//        if (figure_spawn_delay) {
//            figure_spawn_delay = 0;
//            data.industry.has_fish = 0;
//            output_resource_id = RESOURCE_MEAT_C3;
//            figure *f = figure_create(FIGURE_CART_PUSHER, road.x, road.y, DIR_4_BOTTOM_LEFT);
//            f->action_state = FIGURE_ACTION_20_CARTPUSHER_INITIAL;
//            f->set_resource(RESOURCE_MEAT_C3);
//            f->home() = b;
//            figure_id = f->id;
//            f->wait_ticks = 30;
//        }
//    }
}
void building::spawn_figure_shipyard() {
//    check_labor_problem();
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        if (has_figure_of_type(FIGURE_FISHING_BOAT))
//            return;
//        int pct_workers = worker_percentage();
//        if (pct_workers >= 100)
//            data.industry.progress += 10;
//        else if (pct_workers >= 75)
//            data.industry.progress += 8;
//        else if (pct_workers >= 50)
//            data.industry.progress += 6;
//        else if (pct_workers >= 25)
//            data.industry.progress += 4;
//        else if (pct_workers >= 1)
//            data.industry.progress += 2;
//
//        if (data.industry.progress >= 160) {
//            data.industry.progress = 0;
//            map_point boat;
//            if (map_water_can_spawn_fishing_boat(x, y, size, &boat)) {
//                figure *f = figure_create(FIGURE_FISHING_BOAT, boat.x, boat.y, DIR_0_TOP_RIGHT);
//                f->action_state = FIGURE_ACTION_190_FISHING_BOAT_CREATED;
//                f->home() = b;
//                figure_id = f->id;
//            }
//        }
//    }
}
void building::spawn_figure_dock() {
//    check_labor_problem();
//    map_point road;
//    if (map_has_road_access(x, y, size, &road)) {
//        spawn_labor_seeker(50);
//        int pct_workers = worker_percentage();
//        int max_dockers;
//        if (pct_workers >= 75)
//            max_dockers = 3;
//        else if (pct_workers >= 50)
//            max_dockers = 2;
//        else if (pct_workers > 0)
//            max_dockers = 1;
//        else {
//            max_dockers = 0;
//        }
//        // count existing dockers
//        int existing_dockers = 0;
//        for (int i = 0; i < 3; i++) {
//            if (data.dock.docker_ids[i]) {
//                if (figure_get(data.dock.docker_ids[i])->type == FIGURE_DOCKER)
//                    existing_dockers++;
//                else {
//                    data.dock.docker_ids[i] = 0;
//                }
//            }
//        }
//        if (existing_dockers > max_dockers) {
//            // too many dockers, poof one of them
//            for (int i = 2; i >= 0; i--) {
//                if (data.dock.docker_ids[i]) {
//                    figure_get(data.dock.docker_ids[i])->poof();
//                    break;
//                }
//            }
//        } else if (existing_dockers < max_dockers) {
//            figure *f = figure_create(FIGURE_DOCKER, road.x, road.y, DIR_4_BOTTOM_LEFT);
//            f->action_state = FIGURE_ACTION_132_DOCKER_IDLING;
//            f->home() = b;
//            for (int i = 0; i < 3; i++) {
//                if (!data.dock.docker_ids[i]) {
//                    data.dock.docker_ids[i] = f->id;
//                    break;
//                }
//            }
//        }
//    }
}
void building::spawn_figure_warehouse() {
    check_labor_problem();
    building *space = this;
    for (int i = 0; i < 8; i++) {
        space = space->next();
        if (space->id)
            space->show_on_problem_overlay = show_on_problem_overlay;
    }
    if (road_is_accessible) {
        common_spawn_labor_seeker(100);
        int resource = 0;
        int amount = 0;
        int task = building_warehouse_determine_worker_task(this, &resource, &amount);
        if (task != WAREHOUSE_TASK_NONE && amount > 0) {

            // assume amount has been set to more than one.
//            if (true) // TODO: multiple loads setting?????
//                amount = 1;

            if (!has_figure(0)) {
                figure *f = figure_create(FIGURE_WAREHOUSEMAN, road_access_x, road_access_y, DIR_4_BOTTOM_LEFT);
                f->action_state = FIGURE_ACTION_50_WAREHOUSEMAN_CREATED;

                switch (task) {
                    case WAREHOUSE_TASK_GETTING:
                    case WAREHOUSE_TASK_GETTING_MOAR:
                        f->load_resource(0, RESOURCE_NONE);
                        f->collecting_item_id = resource;
                        break;
                    case WAREHOUSE_TASK_DELIVERING:
                    case WAREHOUSE_TASK_EMPTYING:
                        amount = fmin(amount, 4);
                        f->load_resource(amount * 100, resource);
                        building_warehouse_remove_resource(this, resource, amount);
                        break;
                }
                set_figure(0, f->id);
                f->set_home(id);

            } else if (task == WAREHOUSE_TASK_GETTING_MOAR && !has_figure_of_type(1,FIGURE_WAREHOUSEMAN)) {
                figure *f = figure_create(FIGURE_WAREHOUSEMAN, road_access_x, road_access_y, DIR_4_BOTTOM_LEFT);
                f->action_state = FIGURE_ACTION_50_WAREHOUSEMAN_CREATED;

                f->load_resource(0, RESOURCE_NONE);
                f->collecting_item_id = resource;

                set_figure(1, f->id);
                f->set_home(id);
            }
        }
    }
}
void building::spawn_figure_granary() {
    check_labor_problem();
    map_point road;
    if (map_has_road_access(x, y, size, &road)) { //map_has_road_access_granary(x, y, &road)
        common_spawn_labor_seeker(100);
        if (has_figure_of_type(0, FIGURE_WAREHOUSEMAN))
            return;
        int task = building_granary_determine_worker_task(this);
        if (task != GRANARY_TASK_NONE) {
            figure *f = figure_create(FIGURE_WAREHOUSEMAN, road.x, road.y, DIR_4_BOTTOM_LEFT);
            f->action_state = FIGURE_ACTION_50_WAREHOUSEMAN_CREATED;
            f->load_resource(0, task);
            set_figure(0, f->id);
            f->set_home(id);
        }
    }
}

#include "city/data_private.h"

bool building::can_spawn_hunter() { // no cache because fuck the system (also I can't find the memory offset for this)
    int lodges = 0;
    int hunters_total = 0;
    int hunters_this_lodge = 0;
    int huntables = city_data.figure.animals;
//    for (int b = 0; b < MAX_BUILDINGS[GAME_ENV]; b++) {
//        if (building_get()->type == 115)
//            lodges++;
//    }
    for (int i = 0; i < MAX_FIGURES[GAME_ENV]; i++) {
        figure *f = figure_get(i);
        if (f->type == 73) { // hunter
            hunters_total++;
            if (f->has_home(this)) // belongs to this lodge
                hunters_this_lodge++;
        }
        if (hunters_total >= huntables)
            break;
    }
    if (hunters_total < huntables && hunters_this_lodge < 3 && hunters_this_lodge + loads_stored < 5)
        return true;
    return false;
}
void building::spawn_figure_hunting_lodge() {
    check_labor_problem();
    if (road_is_accessible) {
        common_spawn_labor_seeker(100);
        int pct_workers = worker_percentage();
        int spawn_delay = figure_spawn_timer();
        if (spawn_delay == -1)
            return;
        figure_spawn_delay++;
        if (figure_spawn_delay > spawn_delay && can_spawn_hunter()) {
            figure_spawn_delay = 0;
            create_figure_generic(FIGURE_HUNTER, ACTION_8_RECALCULATE, 0, DIR_4_BOTTOM_LEFT);
        }
    }
    common_spawn_goods_output_cartpusher();

//    check_labor_problem();
//    if (road_is_accessible) {
//        spawn_labor_seeker(50);
//        int pct_workers = worker_percentage();
//        int spawn_delay = figure_spawn_timer();
////        if (pct_workers >= 100)
////            spawn_delay = 0;
////        else if (pct_workers >= 75)
////            spawn_delay = 1;
////        else if (pct_workers >= 50)
////            spawn_delay = 3;
////        else if (pct_workers >= 25)
////            spawn_delay = 7;
////        else if (pct_workers >= 1)
////            spawn_delay = 15;
////        else
////            return;
//        figure_spawn_delay++;
//        if (figure_spawn_delay > spawn_delay && can_spawn_hunter()) {
//            figure_spawn_delay = 0;
//            create_figure_generic(FIGURE_HUNTER, ACTION_8_RECALCULATE, 0, DIR_4_BOTTOM_LEFT);
//        }
//        if (has_figure_of_type(0, FIGURE_CART_PUSHER))
//            return;
//        if (loads_stored) {
//            int loads_to_carry = fmin(loads_stored, 4);
//            create_cartpusher(RESOURCE_GAMEMEAT, loads_to_carry);
//            loads_stored -= loads_to_carry;
////            figure *f = figure_create(FIGURE_CART_PUSHER, road.x, road.y, DIR_4_BOTTOM_LEFT);
////            f->action_state = FIGURE_ACTION_20_CARTPUSHER_INITIAL;
////            int loads_to_carry = fmin(loads_stored, 4);
////            loads_stored -= loads_to_carry;
////            f->load_resource(loads_to_carry * 100, RESOURCE_GAMEMEAT);
////            f->set_home(id);
////            set_figure(0, f->id);
////            f->wait_ticks = 30;
//        }
//    }
}

void building::spawn_figure_native_hut() {
//    map_image_set(grid_offset, image_id_from_group(GROUP_BUILDING_NATIVE) + (map_random_get(grid_offset) & 1));
//    if (has_figure_of_type(FIGURE_INDIGENOUS_NATIVE))
//        return;
//    int x_out, y_out;
//    if (subtype.native_meeting_center_id > 0 &&
//        map_terrain_get_adjacent_road_or_clear_land(x, y, size, &x_out, &y_out)) {
//        figure_spawn_delay++;
//        if (figure_spawn_delay > 4) {
//            figure_spawn_delay = 0;
//            figure *f = figure_create(FIGURE_INDIGENOUS_NATIVE, x_out, y_out, DIR_0_TOP_RIGHT);
//            f->action_state = FIGURE_ACTION_158_NATIVE_CREATED;
//            f->home() = b;
//            figure_id = f->id;
//        }
//    }
}
void building::spawn_figure_native_meeting() {
//    map_building_tiles_add(id, x, y, 2,
//                           image_id_from_group(GROUP_BUILDING_NATIVE) + 2, TERRAIN_BUILDING);
//    if (city_buildings_is_mission_post_operational() && !has_figure_of_type(FIGURE_NATIVE_TRADER)) {
//        int x_out, y_out;
//        if (map_terrain_get_adjacent_road_or_clear_land(x, y, size, &x_out, &y_out)) {
//            figure_spawn_delay++;
//            if (figure_spawn_delay > 8) {
//                figure_spawn_delay = 0;
//                figure *f = figure_create(FIGURE_NATIVE_TRADER, x_out, y_out, DIR_0_TOP_RIGHT);
//                f->action_state = FIGURE_ACTION_162_NATIVE_TRADER_CREATED;
//                f->home() = b;
//                figure_id = f->id;
//            }
//        }
//    }
}

void building::spawn_figure_tower() {
    check_labor_problem();
    map_point road;
    if (map_has_road_access(x, y, size, &road)) {
        common_spawn_labor_seeker(50);
        if (num_workers <= 0)
            return;
        if (has_figure(0) && !has_figure(3)) // has sentry but no ballista -> create
            create_figure_generic(FIGURE_BALLISTA, FIGURE_ACTION_180_BALLISTA_CREATED, 3, DIR_0_TOP_RIGHT);
        if (!has_figure(0))
            building_barracks_request_tower_sentry();
    }
}
void building::spawn_figure_barracks() {
    check_labor_problem();
//    map_point road;
    if (road_is_accessible) {
        common_spawn_labor_seeker(100);
        int pct_workers = worker_percentage();
        int spawn_delay = figure_spawn_timer();
//        if (pct_workers >= 100)
//            spawn_delay = 8;
//        else if (pct_workers >= 75)
//            spawn_delay = 12;
//        else if (pct_workers >= 50)
//            spawn_delay = 16;
//        else if (pct_workers >= 25)
//            spawn_delay = 32;
//        else if (pct_workers >= 1)
//            spawn_delay = 48;
//        else
//            return;
        figure_spawn_delay++;
        if (figure_spawn_delay > spawn_delay) {
            figure_spawn_delay = 0;
            switch (subtype.barracks_priority) {
                case PRIORITY_FORT:
                    if (!barracks_create_soldier())
                        barracks_create_tower_sentry();
                    break;
                default:
                    if (!barracks_create_tower_sentry())
                        barracks_create_soldier();
            }
        }
    }
}

void building::update_native_crop_progress() {
    data.industry.progress++;
    if (data.industry.progress >= 5)
        data.industry.progress = 0;

    map_image_set(grid_offset, image_id_from_group(GROUP_BUILDING_FARMLAND) + data.industry.progress);
}

void building::update_road_access() {
    // update building road access
    map_point road;
    if (type == BUILDING_WAREHOUSE)
        road_is_accessible = map_has_road_access(x, y, 3, &road);
    else
        road_is_accessible = map_has_road_access(x, y, size, &road);
    road_access_x = road.x;
    road_access_y = road.y;
}
bool building::figure_generate() {
    show_on_problem_overlay = 0;

    bool patrician_generated = false;
    if (type >= BUILDING_HOUSE_SMALL_VILLA && type <= BUILDING_HOUSE_LUXURY_PALACE) {
        patrician_generated = spawn_patrician(patrician_generated);
    }
    else if (is_farm() || is_workshop() || is_extractor())
        spawn_figure_industry();
    else if (is_tax_collector())
        spawn_figure_tax_collector();
    else if (is_senate())
        spawn_figure_senate();
    else if (is_temple() || is_large_temple())
        spawn_figure_temple();
    else {
        // single building type
        switch (type) {
            case BUILDING_WAREHOUSE:
                spawn_figure_warehouse(); break;
            case BUILDING_GRANARY:
                spawn_figure_granary(); break;
            case BUILDING_TOWER:
                spawn_figure_tower(); break;
            case BUILDING_ENGINEERS_POST:
                spawn_figure_engineers_post(); break;
            case BUILDING_PREFECTURE:
                if (GAME_ENV == ENGINE_ENV_PHARAOH)
                    spawn_figure_police();
                else
                    spawn_figure_prefecture();
                break;
            case BUILDING_FIREHOUSE:
                spawn_figure_prefecture(); break;
            case BUILDING_WATER_SUPPLY:
                spawn_figure_watersupply(); break;
            case BUILDING_ACTOR_COLONY:
                spawn_figure_actor_juggler(); break;
            case BUILDING_GLADIATOR_SCHOOL:
                spawn_figure_gladiator_musician(); break;
            case BUILDING_LION_HOUSE:
                spawn_figure_lion_tamer_dancer(); break;
            case BUILDING_CHARIOT_MAKER:
                spawn_figure_chariot_senet_master(); break;
            case BUILDING_AMPHITHEATER:
                spawn_figure_amphitheater_bandstand(); break;
            case BUILDING_THEATER:
                spawn_figure_theater_booth(); break;
            case BUILDING_HIPPODROME:
                spawn_figure_hippodrome_senet(); break;
            case BUILDING_COLOSSEUM:
                spawn_figure_colosseum_pavillion(); break;
            case BUILDING_MARKET:
                spawn_figure_market(); break;
            case BUILDING_PHYSICIAN:
                spawn_figure_physician(); break;
            case BUILDING_BATHHOUSE:
                spawn_figure_bathhouse(); break;
            case BUILDING_SCHOOL:
                spawn_figure_school(); break;
            case BUILDING_LIBRARY:
                spawn_figure_library(); break;
            case BUILDING_ACADEMY:
                spawn_figure_academy(); break;
            case BUILDING_BARBER:
                spawn_figure_barber(); break;
            case BUILDING_DOCTOR:
                spawn_figure_doctor(); break;
            case BUILDING_HOSPITAL:
                spawn_figure_hospital(); break;
            case BUILDING_MISSION_POST:
                spawn_figure_mission_post(); break;
            case BUILDING_DOCK:
                spawn_figure_dock(); break;
            case BUILDING_WHARF:
                spawn_figure_wharf(); break;
            case BUILDING_SHIPYARD:
                spawn_figure_shipyard(); break;
            case BUILDING_NATIVE_HUT:
                spawn_figure_native_hut(); break;
            case BUILDING_NATIVE_MEETING:
                spawn_figure_native_meeting(); break;
            case BUILDING_NATIVE_CROPS:
                update_native_crop_progress(); break;
            case BUILDING_FORT:
                formation_legion_update_recruit_status(this); break;
            case BUILDING_BARRACKS:
                spawn_figure_barracks(); break;
            case BUILDING_VILLAGE_PALACE:
            case BUILDING_TOWN_PALACE:
            case BUILDING_CITY_PALACE:
            case BUILDING_MILITARY_ACADEMY:
                common_spawn_figure_trigger(100); break;
            case BUILDING_HUNTING_LODGE:
                spawn_figure_hunting_lodge(); break;
            case BUILDING_WORK_CAMP:
                spawn_figure_work_camp(); break;
            case BUILDING_COURTHOUSE:
                spawn_figure_magistrate(); break;
        }
    }
}

void building_figure_generate(void) {
    building_barracks_decay_tower_sentry_request();
    int max_id = building_get_highest_id();
    for (int i = 1; i <= max_id; i++) {
        building *b = building_get(i);
        if (b->state != BUILDING_STATE_VALID)
            continue;

        if (b->type == BUILDING_WAREHOUSE_SPACE || (b->type == BUILDING_HIPPODROME && b->prev_part_building_id))
            continue;

        b->update_road_access();
        b->figure_generate();
    }
}