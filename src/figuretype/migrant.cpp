#include "migrant.h"

#include "building/house.h"
#include "building/model.h"
#include "city/map.h"
#include "city/population.h"
#include "core/calc.h"
#include "graphics/image.h"
#include "figure/combat.h"
#include "figure/image.h"
#include "figure/movement.h"
#include "figure/route.h"
#include "grid/road_access.h"
#include "graphics/image_groups.h"

void figure_create_immigrant(building *house, int num_people) {
    map_point *entry = city_map_entry_point();
    figure *f = figure_create(FIGURE_IMMIGRANT, entry->x(), entry->y(), DIR_0_TOP_RIGHT);
    f->action_state = FIGURE_ACTION_1_IMMIGRANT_CREATED;
    f->set_immigrant_home(house->id);
    house->set_figure(2, f->id);
    f->wait_ticks = 10 + (house->map_random_7bit & 0x7f);
    f->migrant_num_people = num_people;
}
void figure_create_emigrant(building *house, int num_people) {
    city_population_remove(num_people);
    if (num_people < house->house_population)
        house->house_population -= num_people;
    else {
        house->house_population = 0;
        building_house_change_to_vacant_lot(house);
    }
    figure *f = figure_create(FIGURE_EMIGRANT, house->tile.x(), house->tile.y(), DIR_0_TOP_RIGHT);
    f->action_state = FIGURE_ACTION_4_EMIGRANT_CREATED;
    f->wait_ticks = 0;
    f->migrant_num_people = num_people;
}
void figure_create_homeless(int x, int y, int num_people) {
    figure *f = figure_create(FIGURE_HOMELESS, x, y, DIR_0_TOP_RIGHT);
    f->action_state = FIGURE_ACTION_7_HOMELESS_CREATED;
    f->wait_ticks = 0;
    f->migrant_num_people = num_people;
    city_population_remove_homeless(num_people);
}

void figure::update_direction_and_image() {
//    figure_image_update(image_id_from_group(GROUP_FIGURE_MIGRANT));
    if (action_state == FIGURE_ACTION_2_IMMIGRANT_ARRIVING ||
        action_state == FIGURE_ACTION_6_EMIGRANT_LEAVING) {
        int dir = figure_image_direction();
        cart_image_id = image_id_from_group(GROUP_FIGURE_MIGRANT_CART) + dir;
        figure_image_set_cart_offset((dir + 4) % 8);
    }
}
static int closest_house_with_room(int x, int y) {
    int min_dist = 1000;
    int min_building_id = 0;
    int max_id = building_get_highest_id();
    for (int i = 1; i <= max_id; i++) {
        building *b = building_get(i);
        if (b->state == BUILDING_STATE_VALID && b->house_size && b->distance_from_entry > 0 &&
            b->house_population_room > 0) {
            if (!b->has_figure(2)) {
                int dist = calc_maximum_distance(x, y, b->tile.x(), b->tile.y());
                if (dist < min_dist) {
                    min_dist = dist;
                    min_building_id = i;
                }
            }
        }
    }
    return min_building_id;

}

static void add_house_population(building *house, int num_people) {
    int max_people = model_get_house(house->subtype.house_level)->max_people;
    if (house->house_is_merged)
        max_people *= 4;

    int room = max_people - house->house_population;
    if (room < 0)
        room = 0;

    if (room < num_people)
        num_people = room;

    if (!house->house_population)
        building_house_change_to(house, BUILDING_HOUSE_SMALL_TENT);

    house->house_population += num_people;
    house->house_population_room = max_people - house->house_population;
    city_population_add(num_people);
    house->remove_figure(2);
}

void figure::immigrant_action() {
    building *b = immigrant_home();
    switch (action_state) {
        case FIGURE_ACTION_1_IMMIGRANT_CREATED:
        case ACTION_8_RECALCULATE:
//            is_ghost = true;
            anim_frame = 0;
            wait_ticks--;
            if (wait_ticks <= 0)
                advance_action(FIGURE_ACTION_2_IMMIGRANT_ARRIVING);
            break;
        case FIGURE_ACTION_2_IMMIGRANT_ARRIVING:
        case 9: // arriving
            do_gotobuilding(immigrant_home(), true, TERRAIN_USAGE_ANY, FIGURE_ACTION_3_IMMIGRANT_ENTERING_HOUSE);
            break;
        case FIGURE_ACTION_3_IMMIGRANT_ENTERING_HOUSE:
        case 10:
            if (do_enterbuilding(false, immigrant_home()))
                add_house_population(b, migrant_num_people);
//            is_ghost = in_building_wait_ticks ? 1 : 0;
            break;
    }
    update_direction_and_image();
}
void figure::emigrant_action() {
    switch (action_state) {
        case FIGURE_ACTION_4_EMIGRANT_CREATED:
//            is_ghost = true;
            anim_frame = 0;
            wait_ticks++;
            if (wait_ticks >= 5)
                advance_action(FIGURE_ACTION_5_EMIGRANT_EXITING_HOUSE);
            break;
        case FIGURE_ACTION_5_EMIGRANT_EXITING_HOUSE:
            do_exitbuilding(false, FIGURE_ACTION_6_EMIGRANT_LEAVING);
//            is_ghost = in_building_wait_ticks ? 1 : 0;
            break;
        case FIGURE_ACTION_6_EMIGRANT_LEAVING:
        case 10:
            map_point *exit = city_map_entry_point();
            do_goto(exit->x(), exit->y(), TERRAIN_USAGE_ANY);
            break;
    }
    update_direction_and_image();
}
void figure::homeless_action() {
    switch (action_state) {
        case FIGURE_ACTION_7_HOMELESS_CREATED:
            anim_frame = 0;
            wait_ticks++;
            if (wait_ticks > 51) {
                int building_id = closest_house_with_room(tile.x(), tile.y());
                if (building_id) {
                    building *b = building_get(building_id);
                    int x_road, y_road;
                    if (map_closest_road_within_radius(b->tile.x(), b->tile.y(), b->size, 2, &x_road, &y_road)) {
                        b->set_figure(2, id);
                        set_immigrant_home(building_id);
                        advance_action(FIGURE_ACTION_8_HOMELESS_GOING_TO_HOUSE);
                    } else
                        poof();
                } else
                    advance_action(FIGURE_ACTION_10_HOMELESS_LEAVING);
            }
            break;
        case FIGURE_ACTION_8_HOMELESS_GOING_TO_HOUSE:
            do_gotobuilding(immigrant_home(), true, TERRAIN_USAGE_ANY, FIGURE_ACTION_9_HOMELESS_ENTERING_HOUSE);
            break;
        case FIGURE_ACTION_9_HOMELESS_ENTERING_HOUSE:
            if (do_enterbuilding(false, immigrant_home()))
                add_house_population(immigrant_home(), migrant_num_people);
//            is_ghost = in_building_wait_ticks ? 1 : 0;
            break;
        case ACTION_11_RETURNING_EMPTY:
        case FIGURE_ACTION_10_HOMELESS_LEAVING:
            map_point *exit = city_map_exit_point();
            do_goto(exit->x(), exit->y(), TERRAIN_USAGE_ANY);

            wait_ticks++;
            if (wait_ticks > 30) {
                wait_ticks = 0;
                int building_id = closest_house_with_room(tile.x(), tile.y());
                if (building_id > 0) {
                    building *b = building_get(building_id);
                    int x_road, y_road;
                    if (map_closest_road_within_radius(b->tile.x(), b->tile.y(), b->size, 2, &x_road, &y_road)) {
                        b->set_figure(2, id);
                        set_immigrant_home(building_id);
                        advance_action(FIGURE_ACTION_8_HOMELESS_GOING_TO_HOUSE);
                    }
                }
            }
            break;
    }
}
