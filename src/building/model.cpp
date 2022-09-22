#include "building/model.h"

#include "io/io.h"
#include "io/log.h"
#include "core/string.h"
#include "core/game_environment.h"

#include <stdlib.h>
#include <string.h>
#include <game/settings.h>

#define TMP_BUFFER_SIZE 100000

//int NUM_BUILDINGS = 0;
//int NUM_HOUSES = 0;

static const uint8_t ALL_BUILDINGS[] = {'A', 'L', 'L', ' ', 'B', 'U', 'I', 'L', 'D', 'I', 'N', 'G', 'S', 0};
static const uint8_t ALL_HOUSES[] = {'A', 'L', 'L', ' ', 'H', 'O', 'U', 'S', 'E', 'S', 0};

//static model_building buildings[400]; // 130 in C3, more in Pharaoh, can't be bothered to make this dynamic
//static model_house houses[20];

struct {
    model_building buildings[5][400];
    model_house houses[5][20];
//    int difficulty_level_cached = 0;
} data;

static const uint8_t *skip_non_digits(const uint8_t *str) {
    int safeguard = 0;
    while (1) {
        if (++safeguard >= 1000)
            break;

        if ((*str >= '0' && *str <= '9') || *str == '-')
            break;

        str++;
    }
    return str;
}
static const uint8_t *get_value(const uint8_t *ptr, const uint8_t *end_ptr, int *value) {
    ptr = skip_non_digits(ptr);
    *value = string_to_int(ptr);
    ptr += index_of(ptr, ',', (int) (end_ptr - ptr));
    return ptr;
}

bool model_load_file(const char *filepath, int NUM_BUILDINGS, int NUM_HOUSES, model_building *buildings, model_house *houses) {
    buffer buf(TMP_BUFFER_SIZE);
    int filesize = 0;
    filesize = io_read_file_into_buffer(filepath, NOT_LOCALIZED, &buf, TMP_BUFFER_SIZE);
    if (filesize == 0) {
        log_error("Model file not found", 0, 0);
        return false;
    }

    // go through the file to assert number of buildings
    int num_lines = 0;
    int guard = NUM_BUILDINGS + NUM_HOUSES;
    int brace_index;
    const uint8_t *haystack = buf.get_data();
    const uint8_t *ptr = &haystack[index_of_string(haystack, ALL_BUILDINGS, filesize)];
    do {
        guard--;
        brace_index = index_of(ptr, '{', filesize);
        if (brace_index) {
            ptr += brace_index;
            num_lines++;
        }
    } while (brace_index && guard > 0);
    if (num_lines != NUM_BUILDINGS + NUM_HOUSES) {
        log_error("Model has incorrect no of lines ", 0, num_lines + 1);
        return false;
    }

    // parse buildings data
    int dummy;
    ptr = &haystack[index_of_string(haystack, ALL_BUILDINGS, filesize)];
    const uint8_t *end_ptr = &haystack[filesize];
    for (int i = 0; i < NUM_BUILDINGS; i++) {
        ptr += index_of(ptr, '{', filesize);

        ptr = get_value(ptr, end_ptr, &buildings[i].cost);
        ptr = get_value(ptr, end_ptr, &buildings[i].desirability_value);
        ptr = get_value(ptr, end_ptr, &buildings[i].desirability_step);
        ptr = get_value(ptr, end_ptr, &buildings[i].desirability_step_size);
        ptr = get_value(ptr, end_ptr, &buildings[i].desirability_range);
        ptr = get_value(ptr, end_ptr, &buildings[i].laborers);
        ptr = get_value(ptr, end_ptr, &buildings[i].fire_risk);
        ptr = get_value(ptr, end_ptr, &buildings[i].damage_risk);
    }

    // parse houses data
    ptr = &haystack[index_of_string(haystack, ALL_HOUSES, filesize)];
    for (int i = 0; i < NUM_HOUSES; i++) {
        ptr += index_of(ptr, '{', filesize);

        ptr = get_value(ptr, end_ptr, &houses[i].devolve_desirability);
        ptr = get_value(ptr, end_ptr, &houses[i].evolve_desirability);
        ptr = get_value(ptr, end_ptr, &houses[i].entertainment);
        ptr = get_value(ptr, end_ptr, &houses[i].water);
        ptr = get_value(ptr, end_ptr, &houses[i].religion);
        ptr = get_value(ptr, end_ptr, &houses[i].education);
        ptr = get_value(ptr, end_ptr, &houses[i].food);
        ptr = get_value(ptr, end_ptr, &houses[i].dentist);
        ptr = get_value(ptr, end_ptr, &houses[i].physician);
        ptr = get_value(ptr, end_ptr, &houses[i].health);
        ptr = get_value(ptr, end_ptr, &houses[i].food_types);
        ptr = get_value(ptr, end_ptr, &houses[i].pottery);
        ptr = get_value(ptr, end_ptr, &houses[i].linen_oil);
        ptr = get_value(ptr, end_ptr, &houses[i].jewelry_furniture);
        ptr = get_value(ptr, end_ptr, &houses[i].beer_wine);
        ptr = get_value(ptr, end_ptr, &houses[i].crime_risk);
        ptr = get_value(ptr, end_ptr, &houses[i].crime_risk_base);
        ptr = get_value(ptr, end_ptr, &houses[i].prosperity);
        ptr = get_value(ptr, end_ptr, &houses[i].max_people);
        ptr = get_value(ptr, end_ptr, &houses[i].tax_multiplier);
        ptr = get_value(ptr, end_ptr, &houses[i].malaria_risk);
        ptr = get_value(ptr, end_ptr, &houses[i].disease_risk);
    }

    log_info("Model loaded", 0, 0);
    return true;
}

bool model_load(void) {
    switch (GAME_ENV) {
        case ENGINE_ENV_PHARAOH: {
            if (!model_load_file("Pharaoh_Model_VeryEasy.txt", 237, 20, data.buildings[0], data.houses[0]))
                return false;
            if (!model_load_file("Pharaoh_Model_Easy.txt", 237, 20, data.buildings[1], data.houses[1]))
                return false;
            if (!model_load_file("Pharaoh_Model_Normal.txt", 237, 20, data.buildings[2], data.houses[2]))
                return false;
            if (!model_load_file("Pharaoh_Model_Hard.txt", 237, 20, data.buildings[3], data.houses[3]))
                return false;
            if (!model_load_file("Pharaoh_Model_Impossible.txt", 237, 20, data.buildings[4], data.houses[4]))
                return false;
            break;
        }
    }
    return true;
}

//const model_building MODEL_ROADBLOCK = {40, 0, 0, 0, 0};
const model_building *model_get_building(int type) {
//    if (type == BUILDING_ROADBLOCK) {
//        return &MODEL_ROADBLOCK;
//    }
    auto& settings = Settings::instance();
    return &data.buildings[static_cast<int>(settings.difficulty())][type];
}
const model_house *model_get_house(int level) {
    auto& settings = Settings::instance();
    return &data.houses[static_cast<int>(settings.difficulty())][level];
}
