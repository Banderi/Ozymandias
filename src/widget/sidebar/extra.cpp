#include "extra.h"

#include "city/labor.h"
#include "city/population.h"
#include "city/ratings.h"
#include "io/config/config.h"
#include "io/gamefiles/lang.h"
#include "core/string.h"
#include "graphics/image.h"
#include "game/settings.h"
#include "graphics/elements/arrow_button.h"
#include "graphics/boilerplate.h"
#include "graphics/elements/lang_text.h"
#include "graphics/elements/menu.h"
#include "graphics/elements/panel.h"
#include "graphics/text.h"
#include "scenario/criteria.h"
#include "scenario/property.h"

#define EXTRA_INFO_LINE_SPACE 16
#define EXTRA_INFO_HEIGHT_GAME_SPEED 64
#define EXTRA_INFO_HEIGHT_UNEMPLOYMENT 48
#define EXTRA_INFO_HEIGHT_RATINGS 176
#define EXTRA_INFO_VERTICAL_PADDING 8

static void button_game_speed(int is_down, int param2);

static arrow_button arrow_buttons_speed[] = {
        {11, 30, 17, 24, button_game_speed, 1, 0},
        {35, 30, 15, 24, button_game_speed, 0, 0},
};

typedef struct {
    int value;
    int target;
} objective;

static struct {
    int x_offset;
    int y_offset;
    int width;
    int height;
    int is_collapsed;
    int info_to_display;
    int game_speed;
    int unemployment_percentage;
    int unemployment_amount;
    objective culture;
    objective prosperity;
    objective monument;
    objective kingdom;
    objective population;
} data;

static int calculate_displayable_info(int info_to_display, int available_height) {
    if (data.is_collapsed || !config_get(CONFIG_UI_SIDEBAR_INFO) || info_to_display == SIDEBAR_EXTRA_DISPLAY_NONE)
        return SIDEBAR_EXTRA_DISPLAY_NONE;

    int result = SIDEBAR_EXTRA_DISPLAY_NONE;
    if (available_height >= EXTRA_INFO_HEIGHT_GAME_SPEED) {
        if (info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED) {
            available_height -= EXTRA_INFO_HEIGHT_GAME_SPEED;
            result |= SIDEBAR_EXTRA_DISPLAY_GAME_SPEED;
        }
    } else
        return result;
    if (available_height >= EXTRA_INFO_HEIGHT_UNEMPLOYMENT) {
        if (info_to_display & SIDEBAR_EXTRA_DISPLAY_UNEMPLOYMENT) {
            available_height -= EXTRA_INFO_HEIGHT_UNEMPLOYMENT;
            result |= SIDEBAR_EXTRA_DISPLAY_UNEMPLOYMENT;
        }
    } else
        return result;
    if (available_height >= EXTRA_INFO_HEIGHT_RATINGS) {
        if (info_to_display & SIDEBAR_EXTRA_DISPLAY_RATINGS) {
            available_height -= EXTRA_INFO_HEIGHT_RATINGS;
            result |= SIDEBAR_EXTRA_DISPLAY_RATINGS;
        }
    }
    return result;
}
static int calculate_extra_info_height(void) {
    if (data.info_to_display == SIDEBAR_EXTRA_DISPLAY_NONE)
        return 0;

    int height = 0;
    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED)
        height += EXTRA_INFO_HEIGHT_GAME_SPEED;

    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_UNEMPLOYMENT)
        height += EXTRA_INFO_HEIGHT_UNEMPLOYMENT;

    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_RATINGS)
        height += EXTRA_INFO_HEIGHT_RATINGS;

    return height;
}

static void set_extra_info_objectives(void) {
    data.culture.target = 0;
    data.prosperity.target = 0;
    data.monument.target = 0;
    data.kingdom.target = 0;
    data.population.target = 0;

    if (scenario_is_open_play())
        return;
    if (winning_culture())
        data.culture.target = winning_culture();

    if (winning_prosperity())
        data.prosperity.target = winning_prosperity();

    if (winning_monuments())
        data.monument.target = winning_monuments();

    if (winning_kingdom())
        data.kingdom.target = winning_kingdom();

    if (winning_population())
        data.population.target = winning_population();

}
static int update_extra_info_value(int value, int *field) {
    if (value == *field)
        return 0;
    else {
        *field = value;
        return 1;
    }
}
static int update_extra_info(int is_background) {
    int changed = 0;
    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED) {
        auto& settings = Settings::instance();
        changed |= update_extra_info_value(settings.game_speed(), &data.game_speed);
    }
    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_UNEMPLOYMENT) {
        changed |= update_extra_info_value(city_labor_unemployment_percentage(), &data.unemployment_percentage);
        changed |= update_extra_info_value(
                city_labor_workers_unemployed() - city_labor_workers_needed(),
                &data.unemployment_amount
        );
    }
    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_RATINGS) {
        if (is_background) {
            set_extra_info_objectives();
        }

        changed |= update_extra_info_value(city_rating_culture(), &data.culture.value);
        changed |= update_extra_info_value(city_rating_prosperity(), &data.prosperity.value);
        changed |= update_extra_info_value(city_rating_monument(), &data.monument.value);
        changed |= update_extra_info_value(city_rating_kingdom(), &data.kingdom.value);
        changed |= update_extra_info_value(city_population(), &data.population.value);
    }
    return changed;
}

#include "core/game_environment.h"

static int draw_extra_info_objective(int x_offset, int y_offset, int text_group, int text_id, objective *obj, int cut_off_at_parenthesis) {
    if (cut_off_at_parenthesis) {
        // Exception for Chinese: the string for "population" includes the hotkey " (6)"
        // To fix that: cut the string off at the '('
        // Also: Pharaoh's string contains ":" at the end (same fix)
        uint8_t tmp[100];
        string_copy(lang_get_string(text_group, text_id), tmp, 100);
        for (int i = 0; i < 100 && tmp[i]; i++) {
            if (tmp[i] == '(' || tmp[i] == ':') {
                tmp[i] = 0;
                break;
            }
        }
        text_draw(tmp, x_offset + 11, y_offset, FONT_NORMAL_WHITE_ON_DARK, 0);
    } else
        lang_text_draw(text_group, text_id, x_offset + 11, y_offset, FONT_NORMAL_WHITE_ON_DARK);
    font_t font = obj->value >= obj->target ? FONT_NORMAL_BLACK_ON_DARK : FONT_NORMAL_YELLOW;
    int width = text_draw_number(obj->value, '@', "", x_offset + 11, y_offset + EXTRA_INFO_LINE_SPACE, font);
    text_draw_number(obj->target, '(', ")", x_offset + 11 + width, y_offset + EXTRA_INFO_LINE_SPACE, font);
    return EXTRA_INFO_LINE_SPACE * 2;
}
static void draw_extra_info_panel(void) {
    graphics_draw_vertical_line(data.x_offset, data.y_offset, data.y_offset + data.height, COLOR_WHITE);
    graphics_draw_vertical_line(data.x_offset + data.width - 1, data.y_offset, data.y_offset + data.height, COLOR_SIDEBAR);
    inner_panel_draw(data.x_offset + 1, data.y_offset, data.width / 16, data.height / 16);

    int y_current_line = data.y_offset;

    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED) {
        y_current_line += EXTRA_INFO_VERTICAL_PADDING * 2;

        lang_text_draw(45, 2, data.x_offset + 11, y_current_line, FONT_NORMAL_WHITE_ON_DARK);
        y_current_line += EXTRA_INFO_LINE_SPACE + EXTRA_INFO_VERTICAL_PADDING;

        text_draw_percentage(data.game_speed, data.x_offset + 60, y_current_line, FONT_NORMAL_BLACK_ON_DARK);
        arrow_buttons_draw(data.x_offset, data.y_offset, arrow_buttons_speed, 2);

        y_current_line += EXTRA_INFO_VERTICAL_PADDING * 2;
    }

    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_UNEMPLOYMENT) {
        y_current_line += EXTRA_INFO_VERTICAL_PADDING;

        if (GAME_ENV == ENGINE_ENV_C3)
            lang_text_draw(68, 148, data.x_offset + 11, y_current_line, FONT_NORMAL_WHITE_ON_DARK);
        else
            lang_text_draw(68, 135, data.x_offset + 11, y_current_line, FONT_NORMAL_WHITE_ON_DARK);
        y_current_line += EXTRA_INFO_LINE_SPACE;

        int text_width = text_draw_percentage(data.unemployment_percentage, data.x_offset + 11, y_current_line, FONT_NORMAL_BLACK_ON_DARK);
        text_draw_number(data.unemployment_amount, '(', ")", data.x_offset + 11 + text_width, y_current_line, FONT_NORMAL_BLACK_ON_DARK);

        y_current_line += EXTRA_INFO_VERTICAL_PADDING * 2;
    }

    if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_RATINGS) {
        y_current_line += EXTRA_INFO_VERTICAL_PADDING;

        if (GAME_ENV == ENGINE_ENV_C3)
            y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 4, 6, &data.population, 1);
        else if (GAME_ENV == ENGINE_ENV_PHARAOH)
            y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 53, 6, &data.population, 1);
//            y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 44, 56, &data.population, 1);
        y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 53, 1, &data.culture, 0);
        y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 53, 2, &data.prosperity, 0);
        y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 53, 3, &data.monument, 0);
        y_current_line += draw_extra_info_objective(data.x_offset, y_current_line, 53, 4, &data.kingdom, 0);
    }
    // todo: extra goal / required households
}
int sidebar_extra_draw_background(int x_offset, int y_offset, int width, int available_height, int is_collapsed, int info_to_display) {
//    if (GAME_ENV == ENGINE_ENV_PHARAOH)
//        x_offset -= 24;
    data.is_collapsed = is_collapsed;
    data.x_offset = x_offset;
    data.y_offset = y_offset;
    data.width = width;
    data.info_to_display = calculate_displayable_info(info_to_display, available_height);
    data.height = calculate_extra_info_height();

    if (data.info_to_display != SIDEBAR_EXTRA_DISPLAY_NONE) {
        update_extra_info(1);
        draw_extra_info_panel();
    }
    return data.height;
}
void sidebar_extra_draw_foreground(void) {
    if (update_extra_info(0))
        draw_extra_info_panel(); // Updates displayed speed % after clicking the arrows
    else if (data.info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED)
        arrow_buttons_draw(data.x_offset, data.y_offset, arrow_buttons_speed, 2);
}
int sidebar_extra_handle_mouse(const mouse *m) {
    if (!(data.info_to_display & SIDEBAR_EXTRA_DISPLAY_GAME_SPEED))
        return 0;

    return arrow_buttons_handle_mouse(m, data.x_offset, data.y_offset, arrow_buttons_speed, 2, 0);
}

static void button_game_speed(int is_down, int param2) {
    auto& settings = Settings::instance();
    if (is_down) {
        settings.decrease_game_speed();
    }
    else {
        settings.increase_game_speed();
    }
}
