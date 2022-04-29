#include "routing_terrain.h"

#include "building/building.h"
#include "city/view/view.h"
#include "core/direction.h"
#include "core/image.h"
#include "map/building.h"
#include <scenario/map.h>
#include "map/image.h"
#include "map/property.h"
#include "map/random.h"
#include "routing_grids.h"
#include "map/sprite.h"
#include "map/terrain.h"

static int get_land_type_citizen_building(int grid_offset) {
    building *b = building_at(grid_offset);
    switch (b->type) {
        default:
            return CITIZEN_N1_BLOCKED;
//        case BUILDING_WAREHOUSE:
        case BUILDING_GATEHOUSE:
            return CITIZEN_0_ROAD;
        case BUILDING_ROADBLOCK:
            return CITIZEN_0_ROAD;
        case BUILDING_FORT_GROUND:
        case BUILDING_FESTIVAL_SQUARE:
            return CITIZEN_2_PASSABLE_TERRAIN;
        case BUILDING_TRIUMPHAL_ARCH:
            if (b->subtype.orientation == 3) {
                switch (map_property_multi_tile_xy(grid_offset)) {
                    case EDGE_X0Y1:
                    case EDGE_X1Y1:
                    case EDGE_X2Y1:
                       return CITIZEN_0_ROAD;
                }
            } else {
                switch (map_property_multi_tile_xy(grid_offset)) {
                    case EDGE_X1Y0:
                    case EDGE_X1Y1:
                    case EDGE_X1Y2:
                        return CITIZEN_0_ROAD;
                }
            }
            break;
//        case BUILDING_GRANARY:
//            switch (map_property_multi_tile_xy(grid_offset)) {
//                case EDGE_X1Y0:
//                case EDGE_X0Y1:
//                case EDGE_X1Y1:
//                case EDGE_X2Y1:
//                case EDGE_X1Y2:
//                    return CITIZEN_0_ROAD;
//            }
//            break;
//        case BUILDING_RESERVOIR:
//            switch (map_property_multi_tile_xy(grid_offset)) {
//                case EDGE_X1Y0:
//                case EDGE_X0Y1:
//                case EDGE_X2Y1:
//                case EDGE_X1Y2:
//                    return CITIZEN_N4_RESERVOIR_CONNECTOR; // aqueduct connect points
//            }
//            break;
    }
}
static int get_land_type_citizen_aqueduct(int grid_offset) {
    return CITIZEN_N3_AQUEDUCT;
//    int image_id = map_image_at(grid_offset) - image_id_from_group(GROUP_BUILDING_AQUEDUCT);
//    if (image_id <= 3)
//        return CITIZEN_N3_AQUEDUCT;
//    else if (image_id <= 7)
//        return CITIZEN_N1_BLOCKED;
//    else if (image_id <= 9)
//        return CITIZEN_N3_AQUEDUCT;
//    else if (image_id <= 14)
//        return CITIZEN_N1_BLOCKED;
//    else if (image_id <= 18)
//        return CITIZEN_N3_AQUEDUCT;
//    else if (image_id <= 22)
//        return CITIZEN_N1_BLOCKED;
//    else if (image_id <= 24)
//        return CITIZEN_N3_AQUEDUCT;
//    else {
//        return CITIZEN_N1_BLOCKED;
//    }
}
static int get_land_type_noncitizen(int grid_offset) {
    switch (building_at(grid_offset)->type) {
        default:
            return NONCITIZEN_1_BUILDING;
        case BUILDING_WAREHOUSE:
        case BUILDING_FORT_GROUND:
            return NONCITIZEN_0_PASSABLE;
        case BUILDING_BURNING_RUIN:
        case BUILDING_NATIVE_HUT:
        case BUILDING_NATIVE_MEETING:
        case BUILDING_NATIVE_CROPS:
            return NONCITIZEN_N1_BLOCKED;
        case BUILDING_MENU_FORTS:
            return NONCITIZEN_5_FORT;
        case BUILDING_GRANARY:
            switch (map_property_multi_tile_xy(grid_offset)) {
                case EDGE_X1Y0:
                case EDGE_X0Y1:
                case EDGE_X1Y1:
                case EDGE_X2Y1:
                case EDGE_X1Y2:
                    return NONCITIZEN_0_PASSABLE;
            }
            break;
    }
}

static int is_surrounded_by_water(int grid_offset) {
    return map_terrain_is(grid_offset + map_grid_delta(0, -1), TERRAIN_WATER) &&
           map_terrain_is(grid_offset + map_grid_delta(-1, 0), TERRAIN_WATER) &&
           map_terrain_is(grid_offset + map_grid_delta(1, 0), TERRAIN_WATER) &&
           map_terrain_is(grid_offset + map_grid_delta(0, 1), TERRAIN_WATER);
}
static int is_wall_tile(int grid_offset) {
    return map_terrain_is(grid_offset, TERRAIN_WALL_OR_GATEHOUSE) ? 1 : 0;
}
static int count_adjacent_wall_tiles(int grid_offset) {
    int adjacent = 0;
    switch (city_view_orientation()) {
        case DIR_0_TOP_RIGHT:
            adjacent += is_wall_tile(grid_offset + map_grid_delta(0, 1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(1, 1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(1, 0));
            break;
        case DIR_2_BOTTOM_RIGHT:
            adjacent += is_wall_tile(grid_offset + map_grid_delta(0, 1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(-1, 1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(-1, 0));
            break;
        case DIR_4_BOTTOM_LEFT:
            adjacent += is_wall_tile(grid_offset + map_grid_delta(0, -1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(-1, -1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(-1, 0));
            break;
        case DIR_6_TOP_LEFT:
            adjacent += is_wall_tile(grid_offset + map_grid_delta(0, -1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(1, -1));
            adjacent += is_wall_tile(grid_offset + map_grid_delta(1, 0));
            break;
    }
    return adjacent;
}

static bool fix_incorrect_buildings(int grid_offset) {
    // shouldn't happen...?
    if (!map_building_at(grid_offset)) {
        // set caches automatically to fix this?
//        map_grid_set(&terrain_land_citizen, grid_offset, CITIZEN_4_CLEAR_TERRAIN);
//        map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_0_PASSABLE);

        map_terrain_remove(grid_offset, TERRAIN_BUILDING);
        map_image_set(grid_offset, (map_random_get(grid_offset) & 7) +
                                   image_id_from_group(GROUP_TERRAIN_EMPTY_LAND));
        map_property_mark_draw_tile(grid_offset);
        map_property_set_multi_tile_size(grid_offset, 1);
        return true;
    }
    return false;
}

int map_routing_tile_check(int routing_type, int grid_offset) {
    int terrain = map_terrain_get(grid_offset);
    int x = map_grid_offset_to_x(grid_offset);
    int y = map_grid_offset_to_y(grid_offset);
    switch (routing_type) {
        case ROUTING_TYPE_CITIZEN:
//            if (!map_tile_inside_map_area(x, y))
//                return CITIZEN_N1_BLOCKED;
            if (terrain & TERRAIN_ROAD && !(terrain & TERRAIN_WATER))
                return CITIZEN_0_ROAD;
            else if (terrain & (TERRAIN_RUBBLE | TERRAIN_ACCESS_RAMP | TERRAIN_GARDEN
            | TERRAIN_MARSHLAND | TERRAIN_FLOODPLAIN | TERRAIN_TREE)) // TODO?
                return CITIZEN_2_PASSABLE_TERRAIN;
            else if (terrain & (TERRAIN_BUILDING | TERRAIN_GATEHOUSE)) {
                if (fix_incorrect_buildings(grid_offset))
                    return CITIZEN_4_CLEAR_TERRAIN;
                else
                    return get_land_type_citizen_building(grid_offset);
            }
            else if (terrain & TERRAIN_AQUEDUCT)
                return get_land_type_citizen_aqueduct(grid_offset);
            else if (terrain & TERRAIN_NOT_CLEAR)
                return CITIZEN_N1_BLOCKED;
            else
                return CITIZEN_4_CLEAR_TERRAIN;
            ////////////////
        case ROUTING_TYPE_NONCITIZEN:
            if (terrain & TERRAIN_GATEHOUSE)
                return NONCITIZEN_4_GATEHOUSE;
            else if (terrain & TERRAIN_ROAD)
                return NONCITIZEN_0_PASSABLE;
            else if (terrain & (TERRAIN_GARDEN | TERRAIN_ACCESS_RAMP | TERRAIN_RUBBLE))
                return NONCITIZEN_2_CLEARABLE;
            else if (terrain & TERRAIN_BUILDING)
                return get_land_type_noncitizen(grid_offset);
            else if (terrain & TERRAIN_AQUEDUCT)
                return NONCITIZEN_2_CLEARABLE;
            else if (terrain & TERRAIN_WALL)
                return NONCITIZEN_3_WALL;
            else if (terrain & TERRAIN_NOT_CLEAR)
                return NONCITIZEN_N1_BLOCKED;
            else
                return NONCITIZEN_0_PASSABLE;
            ////////////////
        case ROUTING_TYPE_WATER:
            if (terrain & TERRAIN_WATER && is_surrounded_by_water(grid_offset)) {
                if (x > 0 && x < map_data()->width - 1 && y > 0 && y < map_data()->height - 1) {
                    switch (map_sprite_animation_at(grid_offset)) {
                        case 5:
                        case 6: // low bridge middle section
                            return WATER_N3_LOW_BRIDGE;
                        case 13: // ship bridge pillar
                            return WATER_N1_BLOCKED;
                        default:
                            return WATER_0_PASSABLE;
                    }
                } else
                    return WATER_N2_MAP_EDGE;
            } else
                return WATER_N1_BLOCKED;
            ////////////////
        case ROUTING_TYPE_WALLS:
            if (terrain & TERRAIN_WALL) {
                if (count_adjacent_wall_tiles(grid_offset) == 3)
                    return WALL_0_PASSABLE;
                else
                    return WALL_N1_BLOCKED;
            } else if (map_terrain_is(grid_offset, TERRAIN_GATEHOUSE))
                return WALL_0_PASSABLE;
            else
                return WALL_N1_BLOCKED;
    }
    // fallback case
    return NO_VALID_ROUTING_CHECK_RESULT;
}

void map_routing_update_land_citizen(void) {
    map_grid_fill(&terrain_land_citizen, -1);
    int grid_offset = map_data()->start_offset;
    for (int y = 0; y < map_data()->height; y++, grid_offset += map_data()->border_size) {
        for (int x = 0; x < map_data()->width; x++, grid_offset++) {
            map_grid_set(&terrain_land_citizen, grid_offset, map_routing_tile_check(ROUTING_TYPE_CITIZEN, grid_offset));
//            int terrain = map_terrain_get(grid_offset);
//            if (terrain & TERRAIN_ROAD && !(terrain & TERRAIN_WATER)) {
//                map_grid_set(&terrain_land_citizen, grid_offset, CITIZEN_0_ROAD);
//            } else if (terrain & (TERRAIN_RUBBLE | TERRAIN_ACCESS_RAMP | TERRAIN_GARDEN | TERRAIN_REEDS | TERRAIN_FLOODPLAIN)) { // TODO?
//                map_grid_set(&terrain_land_citizen, grid_offset, CITIZEN_2_PASSABLE_TERRAIN);
//            } else if (terrain & (TERRAIN_BUILDING | TERRAIN_GATEHOUSE)) {
//                if (!map_building_at(grid_offset)) {
//                    // shouldn't happen
//                    map_grid_set(&terrain_land_noncitizen, grid_offset, CITIZEN_4_CLEAR_TERRAIN); // BUG: should be citizen grid?
//                    map_terrain_remove(grid_offset, TERRAIN_BUILDING);
//                    map_image_set(grid_offset, (map_random_get(grid_offset) & 7) +
//                                               image_id_from_group(GROUP_TERRAIN_EMPTY_LAND));
//                    map_property_mark_draw_tile(grid_offset);
//                    map_property_set_multi_tile_size(grid_offset, 1);
//                    continue;
//                }
//                map_grid_set(&terrain_land_citizen, grid_offset, get_land_type_citizen_building(grid_offset));
//            } else if (terrain & TERRAIN_AQUEDUCT) {
//                map_grid_set(&terrain_land_citizen, grid_offset, get_land_type_citizen_aqueduct(grid_offset));
//            } else if (terrain & TERRAIN_NOT_CLEAR) {
//                map_grid_set(&terrain_land_citizen, grid_offset, CITIZEN_N1_BLOCKED);
//            } else {
//                map_grid_set(&terrain_land_citizen, grid_offset, CITIZEN_4_CLEAR_TERRAIN);
//            }
        }
    }
}
static void map_routing_update_land_noncitizen(void) {
    map_grid_fill(&terrain_land_noncitizen, -1);
    int grid_offset = map_data()->start_offset;
    for (int y = 0; y < map_data()->height; y++, grid_offset += map_data()->border_size) {
        for (int x = 0; x < map_data()->width; x++, grid_offset++) {
            map_grid_set(&terrain_land_noncitizen, grid_offset,
                         map_routing_tile_check(ROUTING_TYPE_NONCITIZEN, grid_offset));
//            int terrain = map_terrain_get(grid_offset);
//            if (terrain & TERRAIN_GATEHOUSE) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_4_GATEHOUSE);
//            } else if (terrain & TERRAIN_ROAD) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_0_PASSABLE);
//            } else if (terrain & (TERRAIN_GARDEN | TERRAIN_ACCESS_RAMP | TERRAIN_RUBBLE)) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_2_CLEARABLE);
//            } else if (terrain & TERRAIN_BUILDING) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, get_land_type_noncitizen(grid_offset));
//            } else if (terrain & TERRAIN_AQUEDUCT) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_2_CLEARABLE);
//            } else if (terrain & TERRAIN_WALL) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_3_WALL);
//            } else if (terrain & TERRAIN_NOT_CLEAR) {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_N1_BLOCKED);
//            } else {
//                map_grid_set(&terrain_land_noncitizen, grid_offset, NONCITIZEN_0_PASSABLE);
//            }
        }
    }
}
void map_routing_update_land(void) {
    map_routing_update_land_citizen();
    map_routing_update_land_noncitizen();
}
void map_routing_update_water(void) {
    map_grid_fill(&terrain_water, -1);
    int grid_offset = map_data()->start_offset;
    for (int y = 0; y < map_data()->height; y++, grid_offset += map_data()->border_size) {
        for (int x = 0; x < map_data()->width; x++, grid_offset++) {
            map_grid_set(&terrain_water, grid_offset, map_routing_tile_check(ROUTING_TYPE_WATER, grid_offset));
//            if (map_terrain_is(grid_offset, TERRAIN_WATER) && is_surrounded_by_water(grid_offset)) {
//                if (x > 0 && x < map_data()->width - 1 &&
//                    y > 0 && y < map_data()->height - 1) {
//                    switch (map_sprite_animation_at(grid_offset)) {
//                        case 5:
//                        case 6: // low bridge middle section
//                            map_grid_set(&terrain_water, grid_offset, WATER_N3_LOW_BRIDGE);
//                            break;
//                        case 13: // ship bridge pillar
//                            map_grid_set(&terrain_water, grid_offset, WATER_N1_BLOCKED);
//                            break;
//                        default:
//                            map_grid_set(&terrain_water, grid_offset, WATER_0_PASSABLE);
//                            break;
//                    }
//                } else {
//                    map_grid_set(&terrain_water, grid_offset, WATER_N2_MAP_EDGE);
//                }
//            } else {
//                map_grid_set(&terrain_water, grid_offset, WATER_N1_BLOCKED);
//            }
        }
    }
}
void map_routing_update_walls(void) {
    map_grid_fill(&terrain_walls, -1);
    int grid_offset = map_data()->start_offset;
    for (int y = 0; y < map_data()->height; y++, grid_offset += map_data()->border_size) {
        for (int x = 0; x < map_data()->width; x++, grid_offset++) {
            map_grid_set(&terrain_water, grid_offset, map_routing_tile_check(ROUTING_TYPE_WALLS, grid_offset));
//            if (map_terrain_is(grid_offset, TERRAIN_WALL)) {
//                if (count_adjacent_wall_tiles(grid_offset) == 3) {
//                    map_grid_set(&terrain_walls, grid_offset, WALL_0_PASSABLE);
//                } else {
//                    map_grid_set(&terrain_walls, grid_offset, WALL_N1_BLOCKED);
//                }
//            } else if (map_terrain_is(grid_offset, TERRAIN_GATEHOUSE)) {
//                map_grid_set(&terrain_walls, grid_offset, WALL_0_PASSABLE);
//            } else {
//                map_grid_set(&terrain_walls, grid_offset, WALL_N1_BLOCKED);
//            }
        }
    }
}

void map_routing_update_all(void) {
    map_routing_update_land();
    map_routing_update_water();
    map_routing_update_walls();
}

/////////////

bool map_routing_passable_by_usage(int terrain_usage, int grid_offset) {
    switch (terrain_usage) {
        case TERRAIN_USAGE_ANY:
            return true;
        case TERRAIN_USAGE_ROADS:
            return map_grid_get(&terrain_land_citizen, grid_offset) == CITIZEN_0_ROAD;
        case TERRAIN_USAGE_ENEMY:
            return map_grid_get(&terrain_land_noncitizen, grid_offset) >= NONCITIZEN_0_PASSABLE;
        case TERRAIN_USAGE_PREFER_ROADS:
            return map_grid_get(&terrain_land_citizen, grid_offset) >= CITIZEN_0_ROAD;
        case TERRAIN_USAGE_WALLS:
            return map_grid_get(&terrain_walls, grid_offset) == WALL_0_PASSABLE;
        case TERRAIN_USAGE_ANIMAL:
            return map_grid_get(&terrain_land_noncitizen, grid_offset) >= NONCITIZEN_0_PASSABLE;
    }
}

int map_routing_is_wall_passable(int grid_offset) {
    return map_grid_get(&terrain_walls, grid_offset) == WALL_0_PASSABLE;
}
static int wall_tile_in_radius(int x, int y, int radius, int *x_wall, int *y_wall) {
    int size = 1;
    int x_min, y_min, x_max, y_max;
    map_grid_get_area(x, y, size, radius, &x_min, &y_min, &x_max, &y_max);

    for (int yy = y_min; yy <= y_max; yy++) {
        for (int xx = x_min; xx <= x_max; xx++) {
            if (map_routing_is_wall_passable(map_grid_offset(xx, yy))) {
                *x_wall = xx;
                *y_wall = yy;
                return 1;
            }
        }
    }
    return 0;
}
int map_routing_wall_tile_in_radius(int x, int y, int radius, int *x_wall, int *y_wall) {
    for (int i = 1; i <= radius; i++) {
        if (wall_tile_in_radius(x, y, i, x_wall, y_wall))
            return 1;

    }
    return 0;
}
int map_routing_citizen_is_passable(int grid_offset) {
    return map_grid_get(&terrain_land_citizen, grid_offset) == CITIZEN_0_ROAD ||
           map_grid_get(&terrain_land_citizen, grid_offset) == CITIZEN_2_PASSABLE_TERRAIN;
}
int map_routing_citizen_is_road(int grid_offset) {
    return map_grid_get(&terrain_land_citizen, grid_offset) == CITIZEN_0_ROAD;
}
int map_routing_citizen_is_passable_terrain(int grid_offset) {
    return map_grid_get(&terrain_land_citizen, grid_offset) == CITIZEN_2_PASSABLE_TERRAIN;
}
int map_routing_noncitizen_is_passable(int grid_offset) {
    return map_grid_get(&terrain_land_noncitizen, grid_offset) >= NONCITIZEN_0_PASSABLE;
}
int map_routing_is_destroyable(int grid_offset) {
    return map_grid_get(&terrain_land_noncitizen, grid_offset) > NONCITIZEN_0_PASSABLE &&
           map_grid_get(&terrain_land_noncitizen, grid_offset) != NONCITIZEN_5_FORT;
}
int map_routing_get_destroyable(int grid_offset) {
    switch (map_grid_get(&terrain_land_noncitizen, grid_offset)) {
        case NONCITIZEN_1_BUILDING:
            return DESTROYABLE_BUILDING;
        case NONCITIZEN_2_CLEARABLE:
            return DESTROYABLE_AQUEDUCT_GARDEN;
        case NONCITIZEN_3_WALL:
            return DESTROYABLE_WALL;
        case NONCITIZEN_4_GATEHOUSE:
            return DESTROYABLE_GATEHOUSE;
        default:
            return DESTROYABLE_NONE;
    }
}