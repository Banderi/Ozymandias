#include "widget/overlays/city_overlay.h"
#include "city.h"

#include "building/construction/build_planner.h"
#include "building/rotation.h"
#include "city/message.h"
#include "city/victory.h"
#include "city/warning.h"
#include "graphics/image.h"
#include "game/orientation.h"
#include "game/settings.h"
#include "game/state.h"
#include "game/time.h"
#include "graphics/boilerplate.h"
#include "graphics/elements/lang_text.h"
#include "graphics/elements/panel.h"
#include "graphics/text.h"
#include "graphics/window.h"
#include "grid/bookmark.h"
#include "scenario/building.h"
#include "scenario/criteria.h"
#include "widget/top_menu.h"
#include "widget/sidebar/city.h"
#include "window/advisors.h"
#include "window/file_dialog.h"
#include "dev/debug.h"

static int selected_legion_formation_id;

static int center_in_city(int element_width_pixels) {
    int x, y, width, height;
    city_view_get_viewport(&x, &y, &width, &height);
    int margin = (width - element_width_pixels) / 2;
    return x + margin;
}

static void draw_background(void) {
    widget_sidebar_city_draw_background();
    widget_top_menu_draw(1);
}
static void draw_paused_and_time_left(void) {
    if (scenario_criteria_time_limit_enabled() && !city_victory_has_won()) {
        int years;
        if (scenario_criteria_max_year() <= game_time_year() + 1)
            years = 0;
        else {
            years = scenario_criteria_max_year() - game_time_year() - 1;
        }
        int total_months = 12 - game_time_month() + 12 * years;
        label_draw(1, 25, 15, 1);
        int width = lang_text_draw(6, 2, 6, 29, FONT_NORMAL_BLACK_ON_LIGHT);
        text_draw_number(total_months, '@', " ", 6 + width, 29, FONT_NORMAL_BLACK_ON_LIGHT);
//        city_view_dirty = 1;
    } else if (scenario_criteria_survival_enabled() && !city_victory_has_won()) {
        int years;
        if (scenario_criteria_max_year() <= game_time_year() + 1)
            years = 0;
        else {
            years = scenario_criteria_max_year() - game_time_year() - 1;
        }
        int total_months = 12 - game_time_month() + 12 * years;
        label_draw(1, 25, 15, 1);
        int width = lang_text_draw(6, 3, 6, 29, FONT_NORMAL_BLACK_ON_LIGHT);
        text_draw_number(total_months, '@', " ", 6 + width, 29, FONT_NORMAL_BLACK_ON_LIGHT);
//        city_view_dirty = 1;
    }
    if (game_state_is_paused()) {
        int x_offset = center_in_city(448);
        outer_panel_draw(x_offset, 40, 28, 3);
        lang_text_draw_centered(13, 2, x_offset, 58, 448, FONT_NORMAL_BLACK_ON_LIGHT);
//        city_view_dirty = 1;
    }
}
static void draw_cancel_construction(void) {
    if (!mouse_get()->is_touch || !Planner.build_type)
        return;
    int x, y, width, height;
    city_view_get_viewport(&x, &y, &width, &height);
    width -= 4 * 16;
    inner_panel_draw(width - 4, 40, 3, 2);
    ImageDraw::img_generic(image_id_from_group(GROUP_OK_CANCEL_SCROLL_BUTTONS) + 4, width, 44);
//    city_view_dirty = 1;
}
static void draw_foreground(void) {
//    clear_city_view(0);
    widget_top_menu_draw(0);
    window_city_draw();
    widget_sidebar_city_draw_foreground();
    if (window_is(WINDOW_CITY) || window_is(WINDOW_CITY_MILITARY)) {
        draw_paused_and_time_left();
        draw_cancel_construction();
    }
//    city_view_dirty |= widget_city_draw_construction_cost_and_size();
    widget_city_draw_construction_cost_and_size();
    if (window_is(WINDOW_CITY))
        city_message_process_queue();
}
static void draw_foreground_military(void) {
    widget_top_menu_draw(0);
    window_city_draw();
    widget_sidebar_city_draw_foreground_military();
    draw_paused_and_time_left();
}

static void exit_military_command(void) {
    if (window_is(WINDOW_CITY_MILITARY))
        window_city_show();

}
static void show_overlay(int overlay) {
    exit_military_command();
    if (game_state_overlay() == overlay)
        game_state_set_overlay(OVERLAY_NONE);
    else
        game_state_set_overlay(overlay);

    select_city_overlay();
    window_invalidate();
}
static void cycle_legion(void) {
    static int current_legion_id = 1;
    if (window_is(WINDOW_CITY)) {
        int legion_id = current_legion_id;
        current_legion_id = 0;
        for (int i = 1; i < MAX_FORMATIONS; i++) {
            legion_id++;
            if (legion_id > MAX_LEGIONS)
                legion_id = 1;

            const formation *m = formation_get(legion_id);
            if (m->in_use == 1 && !m->is_herd && m->is_legion) {
                if (current_legion_id == 0) {
                    current_legion_id = legion_id;
                    break;
                }
            }
        }
        if (current_legion_id > 0) {
            const formation *m = formation_get(current_legion_id);
            camera_go_to_mappoint(map_point(MAP_OFFSET(m->x_home, m->y_home)));
            window_invalidate();
        }
    }
}
static void toggle_pause(void) {
    game_state_toggle_paused();
    city_warning_clear_all();
}

bool city_has_loaded = false;

static void handle_hotkeys(const hotkeys *hotkeys) {
    handle_debug_hotkeys(hotkeys);
    ////
    if (hotkeys->toggle_pause) {
        toggle_pause();
    }
    if (hotkeys->decrease_game_speed) {
        auto& settings = Settings::instance();
        settings.decrease_game_speed();
    }
    if (hotkeys->increase_game_speed) {
        auto& settings = Settings::instance();
        settings.increase_game_speed();
    }
    if (hotkeys->show_overlay) {
        show_overlay(hotkeys->show_overlay);
    }
    if (hotkeys->toggle_overlay) {
        exit_military_command();
        game_state_toggle_overlay();
        select_city_overlay();
        window_invalidate();
    }
    if (hotkeys->show_advisor) {
        window_advisors_show_advisor(hotkeys->show_advisor);
    }
    if (hotkeys->cycle_legion) {
        cycle_legion();
    }
    if (hotkeys->rotate_map_left) {
        game_orientation_rotate_left();
        window_invalidate();
    }
    if (hotkeys->rotate_map_right) {
        game_orientation_rotate_right();
        window_invalidate();
    }
    if (hotkeys->go_to_bookmark) {
        if (map_bookmark_go_to(hotkeys->go_to_bookmark - 1))
            window_invalidate();

    }
    if (hotkeys->set_bookmark) {
        map_bookmark_save(hotkeys->set_bookmark - 1);
    }
    if (hotkeys->load_file) {
        window_file_dialog_show(FILE_TYPE_SAVED_GAME, FILE_DIALOG_LOAD);
    }
    if (hotkeys->save_file) {
        window_file_dialog_show(FILE_TYPE_SAVED_GAME, FILE_DIALOG_SAVE);
    }
    if (hotkeys->rotate_building) {
        building_rotation_rotate_by_hotkey();
    }
    if (hotkeys->change_building_variant) {
        building_rotation_variant_by_hotkey();
    }
    if (hotkeys->building) {
        if (scenario_building_allowed(hotkeys->building)) {
            Planner.construction_cancel();
            Planner.setup_build(hotkeys->building);
        }
    }
}
static void handle_input(const mouse *m, const hotkeys *h) {
    handle_hotkeys(h);
    if (!Planner.in_progress) {

        widget_top_menu_handle_input(m, h);
        widget_sidebar_city_handle_mouse(m);

//        if (widget_top_menu_handle_input(m, h))
//            return;
//        if (widget_sidebar_city_handle_mouse(m))
//            return;
    }
    widget_city_handle_input(m, h);
    city_has_loaded = true;
}
static void handle_input_military(const mouse *m, const hotkeys *h) {
    handle_hotkeys(h);
    widget_city_handle_input_military(m, h, selected_legion_formation_id);
}

static void get_tooltip(tooltip_context *c) {
    int text_id = widget_top_menu_get_tooltip_text(c);
    if (!text_id)
        text_id = widget_sidebar_city_get_tooltip_text();

    if (text_id) {
        c->type = TOOLTIP_BUTTON;
        c->text_id = text_id;
        return;
    }
    widget_city_get_tooltip(c);
}

void window_city_draw_all(void) {
    draw_background();
    draw_foreground();
}
void window_city_draw_panels(void) {
    draw_background();
}
void window_city_draw(void) {
    widget_city_draw();
}
void window_city_show(void) {
    window_type window = {
            WINDOW_CITY,
            draw_background,
            draw_foreground,
            handle_input,
            get_tooltip
    };
    window_show(&window);
    city_has_loaded = false;
}
void window_city_military_show(int legion_formation_id) {
    selected_legion_formation_id = legion_formation_id;
    window_type window = {
            WINDOW_CITY_MILITARY,
            draw_background,
            draw_foreground_military,
            handle_input_military,
            get_tooltip
    };
    window_show(&window);
}
