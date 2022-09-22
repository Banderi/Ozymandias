#include "io/io_buffer.h"
#include <core/calc.h>
#include <figure/figure.h>
#include <game/resource.h>
#include <grid/routing/queue.h>
#include <core/random.h>
#include "io/config/config.h"
#include "vegetation.h"
#include "grid.h"
#include "terrain.h"
#include "figure.h"
#include "grid/routing/routing.h"
#include "tiles.h"

tile_cache marshland_tiles_cache;
tile_cache trees_tiles_cache;

void foreach_marshland_tile(void (*callback)(int grid_offset)) {
    for (int i = 0; i < marshland_tiles_cache.size(); i++)
        callback(marshland_tiles_cache.at(i));
}
void foreach_tree_tile(void (*callback)(int grid_offset)) {
    for (int i = 0; i < trees_tiles_cache.size(); i++)
        callback(trees_tiles_cache.at(i));
}

static grid_xx terrain_vegetation_growth = {0, {FS_UINT8, FS_UINT8}};

int map_get_vegetation_growth(int grid_offset) {
    return map_grid_get(&terrain_vegetation_growth, grid_offset);
}
void vegetation_deplete(int grid_offset) {
    map_grid_set(&terrain_vegetation_growth, grid_offset, 0);
    map_tiles_update_vegetation(grid_offset);
}
static void vegetation_tile_update(int grid_offset) {
    int growth = map_get_vegetation_growth(grid_offset);
    if (growth < 255) {
        random_generate_next();
        int r = random_short() % 10 + 25;
        growth += r;
        if (growth > 255)
            growth -= 255;
        map_grid_set(&terrain_vegetation_growth, grid_offset, growth);
        if (growth == 255)
            map_tiles_update_vegetation(grid_offset);
    }
}
void vegetation_growth_update() {
    for (int i = 0; i < trees_tiles_cache.size(); ++i)
        vegetation_tile_update(trees_tiles_cache.at(i));
    for (int i = 0; i < marshland_tiles_cache.size(); ++i)
        vegetation_tile_update(marshland_tiles_cache.at(i));
}

io_buffer *iob_vegetation_growth = new io_buffer([](io_buffer *iob) {
    iob->bind(BIND_SIGNATURE_GRID, &terrain_vegetation_growth);
});

int gatherers_harvesting_point(int grid_offset) {
    // check if there's any figure already gathering at the spot
    int figure_id = map_figure_at(grid_offset);
    int gatherers_present = 0;
    while (figure_id) {
        figure *f = figure_get(figure_id);
        if (f->action_state == 10) // someone is already gathering at this spot!
            gatherers_present++;
        figure_id = f->next_figure;
    }
    return gatherers_present;
}
bool can_harvest_point(int grid_offset, int max_gatherers) {

    // check if harvestable
    if (map_get_vegetation_growth(grid_offset) != 255)
        return false;

    // check if there's any figure already gathering at the spot
    if (!config_get(CONFIG_GP_CH_MULTIPLE_GATHERERS))
        if (gatherers_harvesting_point(grid_offset) >= max_gatherers)
            return false;

    return true;
}
bool figure::find_resource_tile(int resource_type, int *out_x, int *out_y) {
    switch (resource_type) {
        case RESOURCE_REEDS:
            return map_routing_citizen_found_reeds(tile.x(), tile.y(), out_x, out_y);
        case RESOURCE_TIMBER:
            return map_routing_citizen_found_timber(tile.x(), tile.y(), out_x, out_y);
    }
    return false;
}