#include "empire.h"

#include "building/menu.h"
#include "city/military.h"
#include "city/warning.h"
#include "core/image_group.h"
#include "empire/city.h"
#include "empire/empire.h"
#include "empire/object.h"
#include "empire/trade_route.h"
#include "empire/type.h"
#include "game/tutorial.h"
#include "graphics/generic_button.h"
#include "graphics/graphics.h"
#include "graphics/image.h"
#include "graphics/image_button.h"
#include "graphics/lang_text.h"
#include "graphics/screen.h"
#include "graphics/text.h"
#include "graphics/window.h"
#include "input/input.h"
#include "input/scroll.h"
#include "scenario/empire.h"
#include "scenario/invasion.h"
#include "window/advisors.h"
#include "window/city.h"
#include "window/message_dialog.h"
#include "window/popup_dialog.h"
#include "window/resource_settings.h"
#include "window/trade_opened.h"
#include "core/game_environment.h"
#include "game/settings.h"

const static int EMPIRE_WIDTH[2] = {
        2000+32,
        1200+32,
};
const static int EMPIRE_HEIGHT[2] = {
        1000+136,
        1600+136+20,
};
const static font_t FONT_OBJECT_INFO[2] = {
        FONT_NORMAL_GREEN,
        FONT_NORMAL_BLACK
};

static void button_help(int param1, int param2);
static void button_return_to_city(int param1, int param2);
static void button_advisor(int advisor, int param2);
static void button_open_trade(int param1, int param2);
static void button_show_resource_window(int resource, int param2);

static image_button image_button_help[] = {
        {0, 0, 27, 27, IB_NORMAL, GROUP_CONTEXT_ICONS, 0, button_help, button_none, 0, 0, 1}
};
static image_button image_button_return_to_city[] = {
        {0, 0, 24, 24, IB_NORMAL, GROUP_CONTEXT_ICONS, 4, button_return_to_city, button_none, 0, 0, 1}
};
static image_button image_button_advisor[] = {
        {-4, 0, 24, 24, IB_NORMAL, GROUP_MESSAGE_ADVISOR_BUTTONS, 12, button_advisor, button_none, ADVISOR_TRADE, 0, 1},
};
static int ADVISOR_BUTTON_X = 0;

static generic_button generic_button_trade_resource[] = {
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_WHEAT,      0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_VEGETABLES, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_FRUIT,      0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_OLIVES,     0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_VINES,      0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_MEAT_C3,    0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_WINE,       0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_OIL_C3,     0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_IRON,       0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_TIMBER_C3,  0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_CLAY_C3,    0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_MARBLE_C3,  0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_WEAPONS_C3, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_FURNITURE,  0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_POTTERY_C3, 0},
        //
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_FLAX, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_LINEN, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_GEMS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_LUXURY_GOODS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_TIMBER_PH, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_GOLD, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_REEDS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_PAPYRUS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_STONE, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_LIMESTONE, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_GRANITE, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_UNUSED12, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_CHARIOTS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_COPPER, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_SANDSTONE, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_OIL_PH, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_HENNA, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_PAINT, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_LAMPS, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_MARBLE_PH, 0},
        {0, 0, 101, 22, button_show_resource_window, button_none, RESOURCE_UNUSED16, 0},
};
static generic_button generic_button_open_trade[] = {
        {30, 56, 440, 20, button_open_trade, button_none, 0, 0}
};
#define TRADE_BUTTON_OFFSET_X 0
#define TRADE_BUTTON_OFFSET_Y 10

static struct {
    int selected_button;
    int selected_city;
    int x_min, x_max, y_min, y_max;
    int x_draw_offset, y_draw_offset;
    int focus_button_id;
    int is_scrolling;
    int finished_scroll;
    int focus_resource;
} data = {0, 1};

static void init(void) {
    data.selected_button = 0;
    int selected_object = empire_selected_object();
    if (selected_object)
        data.selected_city = empire_city_get_for_object(selected_object - 1);
    else
        data.selected_city = 0;
    data.focus_button_id = 0;
}

#define INFO_Y_TRADED -3
#define INFO_Y_SELLS 30
#define INFO_Y_BUYS 52
#define INFO_Y_LINE_3 74
#define INFO_Y_FOOTER_1 78
#define INFO_Y_FOOTER_2 71
#define INFO_Y_CITY_NAME 120
#define INFO_Y_CITY_DESC 28

const int TRADE_RESOURCE_SIZE[2] = {
        26,
        18
};
const int TRADE_RESOURCE_OFFSET[2] = {
        9,
        3
};

#define TRADE_COLUMN_SPACING 106
#define TRADE_ROW_SPACING 20

static void draw_trade_resource(int resource, int trade_max, int x_offset, int y_offset) {
    graphics_draw_inset_rect(x_offset, y_offset, TRADE_RESOURCE_SIZE[GAME_ENV], TRADE_RESOURCE_SIZE[GAME_ENV]);
    image_draw(resource_get_icon(resource), x_offset + 1, y_offset + 1);

    if (data.focus_resource == resource)
        button_border_draw(x_offset - 2, y_offset - 2, 101 + 4, 24, 1);

    switch (trade_max) {
        case 15:
            image_draw(image_id_from_group(GROUP_TRADE_AMOUNT), x_offset + 21, y_offset - 1);
            break;
        case 25:
            image_draw(image_id_from_group(GROUP_TRADE_AMOUNT) + 1, x_offset + 17, y_offset - 1);
            break;
        case 40:
            image_draw(image_id_from_group(GROUP_TRADE_AMOUNT) + 2, x_offset + 13, y_offset - 1);
            break;
    }
}
static void draw_trade_city_info(const empire_object *object, const empire_city *city) {
    int x_offset = (data.x_min + data.x_max - 500) / 2;
    int y_offset = data.y_max - 113;
    if (city->is_open) {

        font_t traded_font = FONT_NORMAL_PLAIN;
//        font_t traded_font = FONT_OBJECT_INFO[GAME_ENV];

        // city sells
        lang_text_draw(47, 11, x_offset + 44, y_offset + INFO_Y_TRADED - 2, FONT_OBJECT_INFO[GAME_ENV]);
        int index = 0;
        for (int resource = RESOURCE_MIN; resource < RESOURCE_MAX[GAME_ENV]; resource++) {
            if (!empire_object_city_sells_resource(object->id, resource))
                continue;

            int column_offset = TRADE_COLUMN_SPACING * (index / 4) - 150;
            int row_offset = TRADE_ROW_SPACING * (index % 4) + 20;

            int trade_max = trade_route_limit(city->route_id, resource);
            draw_trade_resource(resource, trade_max, x_offset + column_offset + 125, y_offset + INFO_Y_TRADED + row_offset - 5);
            int trade_now = trade_route_traded(city->route_id, resource);
            if (trade_now > trade_max)
                trade_max = trade_now;
            trade_now = stack_proper_quantity(trade_now, resource);
            trade_max = stack_proper_quantity(trade_max, resource);

            int text_width = text_draw_number(trade_now, '@', "",
                                              x_offset + column_offset + 150, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            text_width += lang_text_draw(47, 12,
                                         x_offset + column_offset + 148 + text_width, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            text_draw_number(trade_max, '@', "",
                             x_offset + column_offset + 138 + text_width, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            index++;
        }
        // city buys
        lang_text_draw(47, 10, x_offset + 44 + 350, y_offset + INFO_Y_TRADED - 2, FONT_OBJECT_INFO[GAME_ENV]);
        index = 0;
        for (int resource = RESOURCE_MIN; resource < RESOURCE_MAX[GAME_ENV]; resource++) {
            if (!empire_object_city_buys_resource(object->id, resource))
                continue;

            int column_offset = TRADE_COLUMN_SPACING * (index / 4) + 200;
            int row_offset = TRADE_ROW_SPACING * (index % 4) + 20;

            int trade_max = trade_route_limit(city->route_id, resource);
            draw_trade_resource(resource, trade_max, x_offset + column_offset + 125, y_offset + INFO_Y_TRADED + row_offset - 5);
            int trade_now = trade_route_traded(city->route_id, resource);
            if (trade_now > trade_max)
                trade_max = trade_now;
            trade_now = stack_proper_quantity(trade_now, resource);
            trade_max = stack_proper_quantity(trade_max, resource);

            int text_width = text_draw_number(trade_now, '@', "",
                                              x_offset + column_offset + 150, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            text_width += lang_text_draw(47, 12,
                                         x_offset + column_offset + 148 + text_width, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            text_draw_number(trade_max, '@', "",
                             x_offset + column_offset + 138 + text_width, y_offset + INFO_Y_TRADED + row_offset, traded_font);
            index++;
        }
    } else { // trade is closed

        // selling
        int spacing = 0;
        lang_text_draw(47, 5, x_offset + 30, y_offset + INFO_Y_SELLS, FONT_OBJECT_INFO[GAME_ENV]);
        for (int resource = RESOURCE_MIN; resource < RESOURCE_MAX[GAME_ENV]; resource++) {
            if (!empire_object_city_sells_resource(object->id, resource))
                continue;

            int trade_max = trade_route_limit(city->route_id, resource);
            draw_trade_resource(resource, trade_max, x_offset + spacing + 80, y_offset + INFO_Y_SELLS - TRADE_RESOURCE_OFFSET[GAME_ENV]);
            spacing += 32;
        }

        // buying
        spacing = 0;
        lang_text_draw(47, 4, x_offset + 30, y_offset + INFO_Y_BUYS, FONT_OBJECT_INFO[GAME_ENV]);
        for (int resource = RESOURCE_MIN; resource < RESOURCE_MAX[GAME_ENV]; resource++) {
            if (!empire_object_city_buys_resource(object->id, resource))
                continue;

            int trade_max = trade_route_limit(city->route_id, resource);
            draw_trade_resource(resource, trade_max, x_offset + spacing + 80, y_offset + INFO_Y_BUYS - TRADE_RESOURCE_OFFSET[GAME_ENV]);
            spacing += 32;
        }

        // trade open button
        spacing = lang_text_draw_amount(8, 0, city->cost_to_open,
                                      x_offset + 40, y_offset + INFO_Y_FOOTER_1, FONT_OBJECT_INFO[GAME_ENV]);
        lang_text_draw(47, 6, x_offset + spacing + 40, y_offset + INFO_Y_FOOTER_1, FONT_OBJECT_INFO[GAME_ENV]);
        int image_id = image_id_from_group(GROUP_EMPIRE_TRADE_ROUTE_TYPE) + 1 - city->is_sea_trade;
        if (GAME_ENV == ENGINE_ENV_C3)
            image_draw(image_id, x_offset + 430, y_offset + 65 + 2 * city->is_sea_trade);
    }
}
static void draw_city_info(const empire_object *object) {
    int x_offset = (data.x_min + data.x_max - 240) / 2;
    int y_offset = data.y_max - 88;

    const empire_city *city = empire_city_get(data.selected_city);
    if (GAME_ENV == ENGINE_ENV_C3) {
        switch (city->type) {
            case EMPIRE_CITY_DISTANT_ROMAN:
                lang_text_draw_centered(47, 12, x_offset, y_offset + INFO_Y_BUYS, 240, FONT_OBJECT_INFO[GAME_ENV]);
                break;
            case EMPIRE_CITY_VULNERABLE_ROMAN:
                if (city_military_distant_battle_city_is_roman())
                    lang_text_draw_centered(47, 12, x_offset, y_offset + INFO_Y_BUYS, 240, FONT_OBJECT_INFO[GAME_ENV]);
                else {
                    lang_text_draw_centered(47, 13, x_offset, y_offset + INFO_Y_BUYS, 240, FONT_OBJECT_INFO[GAME_ENV]);
                }
                break;
            case EMPIRE_CITY_FUTURE_TRADE:
            case EMPIRE_CITY_DISTANT_FOREIGN:
            case EMPIRE_CITY_FUTURE_ROMAN:
                lang_text_draw_centered(47, 0, x_offset, y_offset + INFO_Y_BUYS, 240, FONT_OBJECT_INFO[GAME_ENV]);
                break;
            case EMPIRE_CITY_OURS:
                lang_text_draw_centered(47, 1, x_offset, y_offset + INFO_Y_BUYS, 240, FONT_OBJECT_INFO[GAME_ENV]);
                break;
            case EMPIRE_CITY_TRADE:
                draw_trade_city_info(object, city);
                break;
        }
    }
    else if (GAME_ENV == ENGINE_ENV_PHARAOH) {
        switch (city->type) {
            case EMPIRE_CITY_PH_OURS:
                lang_text_draw_centered(47, 1, x_offset, y_offset + INFO_Y_CITY_DESC, 240, FONT_NORMAL_BLACK);
                break;
            case EMPIRE_CITY_PH_PHARAOH:
                lang_text_draw_centered(47, 19, x_offset, y_offset + INFO_Y_CITY_DESC, 240, FONT_NORMAL_BLACK);
                break;
            case EMPIRE_CITY_PH_EGYPT:
                lang_text_draw_centered(47, 13, x_offset, y_offset + INFO_Y_CITY_DESC, 240, FONT_NORMAL_BLACK);
                break;
            case EMPIRE_CITY_PH_FOREIGN:
                lang_text_draw_centered(47, 0, x_offset, y_offset + INFO_Y_CITY_DESC, 240, FONT_NORMAL_BLACK);
                break;
            case EMPIRE_CITY_PH_PHARAOH_TRADE:
            case EMPIRE_CITY_PH_EGYPT_TRADE:
            case EMPIRE_CITY_PH_FOREIGN_TRADE:
                draw_trade_city_info(object, city);
                break;
        }
    }
}

static void draw_roman_army_info(const empire_object *object) {
    if (city_military_distant_battle_roman_army_is_traveling()) {
        if (city_military_distant_battle_roman_months_traveled() == object->distant_battle_travel_months) {
            int x_offset = (data.x_min + data.x_max - 240) / 2;
            int y_offset = data.y_max - 68;
            int text_id;
            if (city_military_distant_battle_roman_army_is_traveling_forth())
                text_id = 15;
            else {
                text_id = 16;
            }
            lang_text_draw_multiline(47, text_id, x_offset, y_offset, 240, FONT_OBJECT_INFO[GAME_ENV]);
        }
    }
}
static void draw_enemy_army_info(const empire_object *object) {
    if (city_military_months_until_distant_battle() > 0) {
        if (city_military_distant_battle_enemy_months_traveled() == object->distant_battle_travel_months) {
            lang_text_draw_multiline(47, 14,
                                     (data.x_min + data.x_max - 240) / 2,
                                     data.y_max - 68,
                                     240, FONT_OBJECT_INFO[GAME_ENV]);
        }
    }
}

static void draw_object_info(void) {
    int selected_object = empire_selected_object();
    if (selected_object) {
        const empire_object *object = empire_object_get(selected_object - 1);
        switch (object->type) {
            case EMPIRE_OBJECT_CITY:
                draw_city_info(object);
                break;
            case EMPIRE_OBJECT_ROMAN_ARMY:
                draw_roman_army_info(object);
                break;
            case EMPIRE_OBJECT_ENEMY_ARMY:
                draw_enemy_army_info(object);
                break;
        }
    } else {
        if (GAME_ENV == ENGINE_ENV_C3)
            lang_text_draw_centered(47, 8, data.x_min, data.y_max - 48, data.x_max - data.x_min, FONT_OBJECT_INFO[GAME_ENV]);
        else if (GAME_ENV == ENGINE_ENV_PHARAOH)
            lang_text_draw_centered(47, 9, data.x_min, data.y_max - 68, data.x_max - data.x_min, FONT_OBJECT_INFO[GAME_ENV]);
    }
}
static void draw_empire_object(const empire_object *obj) {
    if (obj->type == EMPIRE_OBJECT_LAND_TRADE_ROUTE || obj->type == EMPIRE_OBJECT_SEA_TRADE_ROUTE) {
        if (!empire_city_is_trade_route_open(obj->trade_route_id))
            return;
    }
    int x, y, image_id;
    if (scenario_empire_is_expanded()) {
        x = obj->expanded.x;
        y = obj->expanded.y;
        image_id = obj->expanded.image_id;
    } else {
        x = obj->x;
        y = obj->y;
        image_id = obj->image_id;
    }

    if (GAME_ENV == ENGINE_ENV_C3 && obj->type == EMPIRE_OBJECT_CITY) {
        const empire_city *city = empire_city_get(empire_city_get_for_object(obj->id));
        if (city->type == EMPIRE_CITY_DISTANT_FOREIGN ||
            city->type == EMPIRE_CITY_FUTURE_ROMAN) {
            image_id = image_id_from_group(GROUP_EMPIRE_FOREIGN_CITY);
        } else if (city->type == EMPIRE_CITY_TRADE) {
            // Fix cases where empire map still gives a blue flag for new trade cities (e.g. Massilia in campaign Lugdunum)
            image_id = image_id_from_group(GROUP_EMPIRE_CITY_TRADE);
        }
    }
    else if (GAME_ENV == ENGINE_ENV_PHARAOH) {
        if (obj->type == EMPIRE_OBJECT_CITY) {
            const empire_city *city = empire_city_get(empire_city_get_for_object(obj->id));

            int text_group = 21;
            if (setting_city_names_style() == CITIES_OLD_NAMES)
                text_group = 195;

            int text_offset_x = 0;
            int text_offset_y = 50;

            int text_x = data.x_draw_offset + x + text_offset_x;
            int text_y = data.y_draw_offset + y + text_offset_x;

            switch (obj->text_align) {
                case 0:
                    lang_text_draw_left_colored(text_group, city->name_id, text_x, text_y + (obj->height / 2), FONT_NORMAL_PLAIN, COLOR_FONT_DARK_RED);
                    break;
                case 1:
                    lang_text_draw_centered_colored(text_group, city->name_id, text_x - 150 + (obj->width / 2), text_y - 10, 300, FONT_NORMAL_PLAIN, COLOR_FONT_DARK_RED);
                    break;
                case 2:
                    lang_text_draw_colored(text_group, city->name_id, text_x + obj->width, text_y + (obj->height / 2), FONT_NORMAL_PLAIN, COLOR_FONT_DARK_RED);
                    break;
                case 3:
                    lang_text_draw_centered_colored(text_group, city->name_id, text_x - 150 + (obj->width / 2), text_y + obj->height + 5, 300, FONT_NORMAL_PLAIN, COLOR_FONT_DARK_RED);
                    break;
            }
        }
        else if (obj->type == EMPIRE_OBJECT_TEXT) {
            const full_empire_object *full = empire_get_full_object(obj->id);
            int text_x = data.x_draw_offset + x + 0;
            int text_y = data.y_draw_offset + y + 0;

            lang_text_draw_centered_colored(196, full->city_name_id, text_x - 5, text_y, 100, FONT_NORMAL_SHADED, COLOR_FONT_SHITTY_BROWN);
            return;
        }
    }
    if (obj->type == EMPIRE_OBJECT_BATTLE_ICON) {
        // handled later
        return;
    }
    if (obj->type == EMPIRE_OBJECT_ENEMY_ARMY) {
        if (city_military_months_until_distant_battle() <= 0)
            return;
        if (city_military_distant_battle_enemy_months_traveled() != obj->distant_battle_travel_months)
            return;
    }
    if (obj->type == EMPIRE_OBJECT_ROMAN_ARMY) {
        if (!city_military_distant_battle_roman_army_is_traveling())
            return;
        if (city_military_distant_battle_roman_months_traveled() != obj->distant_battle_travel_months)
            return;
    }
    image_draw(image_id, data.x_draw_offset + x, data.y_draw_offset + y);
    const image *img = image_get(image_id);
    if (img->get_animation_speed_id()) {
        int new_animation = empire_object_update_animation(obj, image_id);
        image_draw(image_id + new_animation,
                   data.x_draw_offset + x + img->get_sprite_offset_x(),
                   data.y_draw_offset + y + img->get_sprite_offset_y());
    }
}
static void draw_invasion_warning(int x, int y, int image_id) {
    image_draw(image_id, data.x_draw_offset + x, data.y_draw_offset + y);
}
static void draw_map(void) {
    graphics_set_clip_rectangle(data.x_min + 16, data.y_min + 16, data.x_max - data.x_min - 32,
                                data.y_max - data.y_min - 136);

    empire_set_viewport(data.x_max - data.x_min - 32, data.y_max - data.y_min - 136);

    data.x_draw_offset = data.x_min + 16;
    data.y_draw_offset = data.y_min + 16;
    empire_adjust_scroll(&data.x_draw_offset, &data.y_draw_offset);
    image_draw(image_id_from_group(GROUP_EMPIRE_MAP), data.x_draw_offset, data.y_draw_offset);

    empire_object_foreach(draw_empire_object);

    scenario_invasion_foreach_warning(draw_invasion_warning);

    graphics_reset_clip_rectangle();
}
static void draw_city_name(const empire_city *city) {
    if (GAME_ENV == ENGINE_ENV_C3) {
        int image_base = image_id_from_group(GROUP_EMPIRE_PANELS);
        image_draw(image_base + 6, data.x_min + 2, data.y_max - 199);
        image_draw(image_base + 7, data.x_max - 84, data.y_max - 199);
        image_draw(image_base + 8, (data.x_min + data.x_max - 332) / 2, data.y_max - 181);
        if (city) {
            lang_text_draw_centered(21, city->name_id,
                                    (data.x_min + data.x_max - 332) / 2 + 64, data.y_max - 118, 268, FONT_LARGE_BLACK);
        }
    }
    else if (GAME_ENV == ENGINE_ENV_PHARAOH) {
        if (city) {
            if (setting_city_names_style() == CITIES_OLD_NAMES)
                lang_text_draw_centered(195, city->name_id,
                                        (data.x_min + data.x_max - 332) / 2 + 32, data.y_max - INFO_Y_CITY_NAME, 268, FONT_LARGE_BLACK);
            else
                lang_text_draw_centered(21, city->name_id,
                                        (data.x_min + data.x_max - 332) / 2 + 32, data.y_max - INFO_Y_CITY_NAME, 268, FONT_LARGE_BLACK);
        }
    }
}
static void draw_panel_buttons(const empire_city *city) {
    image_buttons_draw(data.x_min + 20, data.y_max - 44, image_button_help, 1);
    image_buttons_draw(data.x_max - 44, data.y_max - 44, image_button_return_to_city, 1);

    if (GAME_ENV == ENGINE_ENV_C3)
        ADVISOR_BUTTON_X = data.x_max - 44;
    else if (GAME_ENV == ENGINE_ENV_PHARAOH)
        ADVISOR_BUTTON_X = data.x_min + 24;
    image_buttons_draw(ADVISOR_BUTTON_X, data.y_max - 120, image_button_advisor, 1);

    // trade button
    if (city && !city->is_open) {
        if (GAME_ENV == ENGINE_ENV_C3 && city->type == EMPIRE_CITY_TRADE
            || GAME_ENV == ENGINE_ENV_PHARAOH &&
           (city->type == EMPIRE_CITY_PH_PHARAOH_TRADE
            || city->type == EMPIRE_CITY_PH_EGYPT_TRADE
            || city->type == EMPIRE_CITY_PH_FOREIGN_TRADE))
            button_border_draw((data.x_min + data.x_max - 500) / 2 + 30 + TRADE_BUTTON_OFFSET_X,
                               data.y_max - 49 + TRADE_BUTTON_OFFSET_Y,
                               generic_button_open_trade[0].width, generic_button_open_trade[0].height,
                               data.selected_button);

    }
}

static void draw_paneling(void) {
    int image_base = image_id_from_group(GROUP_EMPIRE_PANELS);
    // bottom panel background
    graphics_set_clip_rectangle(data.x_min, data.y_min, data.x_max - data.x_min, data.y_max - data.y_min);
    for (int x = data.x_min; x < data.x_max; x += 70) {
        image_draw(image_base + 3, x, data.y_max - 140);
        image_draw(image_base + 3, x, data.y_max - 100);
        image_draw(image_base + 3, x, data.y_max - 60);
        image_draw(image_base + 3, x, data.y_max - 20);
    }

    // horizontal bar borders
    for (int x = data.x_min; x < data.x_max; x += 86) {
        image_draw(image_base + 1, x, data.y_min);
        image_draw(image_base + 1, x, data.y_max - 140);
        image_draw(image_base + 1, x, data.y_max - 16);
    }

    // vertical bar borders
    for (int y = data.y_min + 16; y < data.y_max; y += 86) {
        image_draw(image_base, data.x_min, y);
        image_draw(image_base, data.x_max - 16, y);
    }

    // crossbars
    image_draw(image_base + 2, data.x_min, data.y_min);
    image_draw(image_base + 2, data.x_min, data.y_max - 140);
    image_draw(image_base + 2, data.x_min, data.y_max - 16);
    image_draw(image_base + 2, data.x_max - 16, data.y_min);
    image_draw(image_base + 2, data.x_max - 16, data.y_max - 140);
    image_draw(image_base + 2, data.x_max - 16, data.y_max - 16);

    graphics_reset_clip_rectangle();
}
static void draw_background(void) {
    int s_width = screen_width();
    int s_height = screen_height();
    data.x_min = s_width <= EMPIRE_WIDTH[GAME_ENV] ? 0 : (s_width - EMPIRE_WIDTH[GAME_ENV]) / 2;
    data.x_max = s_width <= EMPIRE_WIDTH[GAME_ENV] ? s_width : data.x_min + EMPIRE_WIDTH[GAME_ENV];
    data.y_min = s_height <= EMPIRE_HEIGHT[GAME_ENV] ? 0 : (s_height - EMPIRE_HEIGHT[GAME_ENV]) / 2;
    data.y_max = s_height <= EMPIRE_HEIGHT[GAME_ENV] ? s_height : data.y_min + EMPIRE_HEIGHT[GAME_ENV];

    if (data.x_min || data.y_min)
        graphics_clear_screens();
}
static void draw_foreground(void) {
    draw_map();

    const empire_city *city = 0;
    int selected_object = empire_selected_object();
    if (selected_object) {
        const empire_object *object = empire_object_get(selected_object - 1);
        if (object->type == EMPIRE_OBJECT_CITY) {
            data.selected_city = empire_city_get_for_object(object->id);
            city = empire_city_get(data.selected_city);
        }
    }
    draw_paneling();
    draw_city_name(city);
    draw_panel_buttons(city);
    draw_object_info();
}

static int is_outside_map(int x, int y) {
    return (x < data.x_min + 16 || x >= data.x_max - 16 ||
            y < data.y_min + 16 || y >= data.y_max - 120);
}
static void determine_selected_object(const mouse *m) {
    if (!m->left.went_up || data.finished_scroll || is_outside_map(m->x, m->y)) {
        data.finished_scroll = 0;
        return;
    }
    empire_select_object(m->x - data.x_min - 16, m->y - data.y_min - 16);
    window_invalidate();
}
static void handle_input(const mouse *m, const hotkeys *h) {
    pixel_coordinate position;
    if (scroll_get_delta(m, &position, SCROLL_TYPE_EMPIRE))
        empire_scroll_map(position.x, position.y);

    if (m->is_touch) {
        const touch *t = get_earliest_touch();
        if (!is_outside_map(t->current_point.x, t->current_point.y)) {
            if (t->has_started) {
                data.is_scrolling = 1;
                scroll_drag_start(1);
            }
        }
        if (t->has_ended) {
            data.is_scrolling = 0;
            data.finished_scroll = !touch_was_click(t);
            scroll_drag_end();
        }
    }
    data.focus_button_id = 0;
    data.focus_resource = 0;
    int button_id;
    image_buttons_handle_mouse(m, data.x_min + 20, data.y_max - 44, image_button_help, 1, &button_id);
    if (button_id)
        data.focus_button_id = 1;

    image_buttons_handle_mouse(m, data.x_max - 44, data.y_max - 44, image_button_return_to_city, 1, &button_id);
    if (button_id)
        data.focus_button_id = 2;
    image_buttons_handle_mouse(m, ADVISOR_BUTTON_X, data.y_max - 120, image_button_advisor, 1, &button_id);
    if (button_id)
        data.focus_button_id = 3;

    determine_selected_object(m);
    int selected_object = empire_selected_object();
    if (selected_object) {
        const empire_object *obj = empire_object_get(selected_object - 1);
        if (obj->type == EMPIRE_OBJECT_CITY) {
            data.selected_city = empire_city_get_for_object(selected_object - 1);
            const empire_city *city = empire_city_get(data.selected_city);

            if (GAME_ENV == ENGINE_ENV_C3 && city->type == EMPIRE_CITY_TRADE
                || GAME_ENV == ENGINE_ENV_PHARAOH &&
                    (city->type == EMPIRE_CITY_PH_PHARAOH_TRADE
                    || city->type == EMPIRE_CITY_PH_EGYPT_TRADE
                    || city->type == EMPIRE_CITY_PH_FOREIGN_TRADE)) {
                if (city->is_open) {
                    int x_offset = (data.x_min + data.x_max - 500) / 2;
                    int y_offset = data.y_max - 113;
                    int index_sell = 0;
                    int index_buy = 0;

                    // we only want to handle resource buttons that the selected city trades
                    for (int resource = RESOURCE_MIN; resource < RESOURCE_MAX[GAME_ENV]; resource++) {

                        if (empire_object_city_sells_resource(obj->id, resource)) {
                            int column_offset = TRADE_COLUMN_SPACING * (index_sell / 4) - 150;
                            int row_offset = TRADE_ROW_SPACING * (index_sell % 4) + 20;
                            generic_buttons_handle_mouse(m, x_offset + column_offset + 125, y_offset + INFO_Y_TRADED + row_offset - 7,
                                                         generic_button_trade_resource + resource - 1, 1, &button_id);
                            index_sell++;
                        } else if (empire_object_city_buys_resource(obj->id, resource)) {
                            int column_offset = TRADE_COLUMN_SPACING * (index_buy / 4) + 200;
                            int row_offset = TRADE_ROW_SPACING * (index_buy % 4) + 20;
                            generic_buttons_handle_mouse(m, x_offset + column_offset + 125, y_offset + INFO_Y_TRADED + row_offset - 7,
                                                         generic_button_trade_resource + resource - 1, 1, &button_id);
                            index_buy++;
                        }

                        if (button_id) {
                            data.focus_resource = resource;
                            // if we're focusing any button we can skip further checks
                            break;
                        }
                    }
                } else {
                    generic_buttons_handle_mouse(
                            m,
                            (data.x_min + data.x_max - 500) / 2 + TRADE_BUTTON_OFFSET_X,
                            data.y_max - 105 + TRADE_BUTTON_OFFSET_Y,
                            generic_button_open_trade, 1, &data.selected_button);
                }
            }
        }
        if (input_go_back_requested(m, h)) {
            empire_clear_selected_object();
            window_invalidate();
        }
    } else {
        if (input_go_back_requested(m, h))
            window_city_show();

    }
}
static int is_mouse_hit(tooltip_context *c, int x, int y, int size) {
    int mx = c->mouse_x;
    int my = c->mouse_y;
    return x <= mx && mx < x + size && y <= my && my < y + size;
}

static int get_tooltip_resource(tooltip_context *c) {
    const empire_city *city = empire_city_get(data.selected_city);
    // we only want to check tooltips on our own closed cities.
    // open city resource tooltips are handled by their respective buttons directly
    if (city->is_open
        || (GAME_ENV == ENGINE_ENV_C3 && city->type != EMPIRE_CITY_TRADE)
        || (GAME_ENV == ENGINE_ENV_PHARAOH
            && city->type != EMPIRE_CITY_PH_PHARAOH_TRADE
            && city->type != EMPIRE_CITY_PH_EGYPT_TRADE
            && city->type != EMPIRE_CITY_PH_FOREIGN_TRADE))
        return 0;

    int object_id = empire_selected_object() - 1;
    int x_offset = (data.x_min + data.x_max - 500) / 2;
    int y_offset = data.y_max - 113;

    int item_offset = lang_text_get_width(47, 5, FONT_OBJECT_INFO[GAME_ENV]);
    for (int r = RESOURCE_MIN; r < RESOURCE_MAX[GAME_ENV]; r++) {
        if (empire_object_city_sells_resource(object_id, r)) {
            if (is_mouse_hit(c, x_offset + 18 + item_offset, y_offset + INFO_Y_SELLS - TRADE_RESOURCE_OFFSET[GAME_ENV], TRADE_RESOURCE_SIZE[GAME_ENV]))
                return r;

            item_offset += 32;
        }
    }
    item_offset += lang_text_get_width(47, 4, FONT_OBJECT_INFO[GAME_ENV]);
    for (int r = RESOURCE_MIN; r <= RESOURCE_MAX[GAME_ENV]; r++) {
        if (empire_object_city_buys_resource(object_id, r)) {
            if (is_mouse_hit(c, x_offset + 18 + item_offset, y_offset + INFO_Y_BUYS - TRADE_RESOURCE_OFFSET[GAME_ENV], TRADE_RESOURCE_SIZE[GAME_ENV]))
                return r;

            item_offset += 32;
        }
    }

    return 0;
}
static void get_tooltip_trade_route_type(tooltip_context *c) {
    int selected_object = empire_selected_object();
    if (!selected_object || empire_object_get(selected_object - 1)->type != EMPIRE_OBJECT_CITY)
        return;

    data.selected_city = empire_city_get_for_object(selected_object - 1);
    const empire_city *city = empire_city_get(data.selected_city);
    if (city->type != EMPIRE_CITY_TRADE || city->is_open)
        return;

    int x_offset = (data.x_min + data.x_max + 300) / 2;
    int y_offset = data.y_max - 41;
    int y_offset_max = y_offset + 22 - 2 * city->is_sea_trade;
    if (c->mouse_x >= x_offset && c->mouse_x < x_offset + 32 &&
        c->mouse_y >= y_offset && c->mouse_y < y_offset_max) {
        c->type = TOOLTIP_BUTTON;
        c->text_group = 44;
        c->text_id = 28 + city->is_sea_trade;
    }
}
static void get_tooltip(tooltip_context *c) {
    int resource = data.focus_resource ? data.focus_resource : get_tooltip_resource(c);
    if (resource) {
        c->type = TOOLTIP_BUTTON;
        if (GAME_ENV == ENGINE_ENV_C3)
            c->text_id = 131 + resource;
        else if (GAME_ENV == ENGINE_ENV_PHARAOH) {
            c->text_group = 23;
            c->text_id = resource;
        }
    } else if (data.focus_button_id) {
        c->type = TOOLTIP_BUTTON;
        switch (data.focus_button_id) {
            case 1:
                c->text_id = 1;
                break;
            case 2:
                c->text_id = 2;
                break;
            case 3:
                if (GAME_ENV == ENGINE_ENV_C3)
                    c->text_id = 69;
                else if (GAME_ENV == ENGINE_ENV_PHARAOH)
                    c->text_id = 70;
                break;
        }
    } else
        get_tooltip_trade_route_type(c);
}

static void button_help(int param1, int param2) {
    window_message_dialog_show(MESSAGE_DIALOG_EMPIRE_MAP, 0);
}
static void button_return_to_city(int param1, int param2) {
    window_city_show();
}
static void button_advisor(int advisor, int param2) {
    window_advisors_show_advisor(advisor);
}
static void button_show_resource_window(int resource, int param2) {
    window_resource_settings_show(resource);
}

static void confirmed_open_trade(int accepted) {
    if (accepted) {
        empire_city_open_trade(data.selected_city);
        building_menu_update(BUILDSET_NORMAL);
        window_trade_opened_show(data.selected_city);
    }
}
static void button_open_trade(int param1, int param2) {
    window_popup_dialog_show(POPUP_DIALOG_OPEN_TRADE, confirmed_open_trade, 2);
}

void window_empire_show(void) {
    window_type window = {
            WINDOW_EMPIRE,
            draw_background,
            draw_foreground,
            handle_input,
            get_tooltip
    };
    init();
    window_show(&window);
}
void window_empire_show_checked(void) {
    tutorial_availability avail = tutorial_advisor_empire_availability();
    if (avail == AVAILABLE)
        window_empire_show();
    else {
        city_warning_show(avail == NOT_AVAILABLE ? WARNING_NOT_AVAILABLE : WARNING_NOT_AVAILABLE_YET);
    }
}
