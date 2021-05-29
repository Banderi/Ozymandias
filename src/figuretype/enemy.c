#include "enemy.h"

#include "city/figures.h"
#include "city/sound.h"
#include "core/calc.h"
#include "core/game_images.h"
#include "figure/combat.h"
#include "figure/formation_enemy.h"
#include "figure/formation_layout.h"
#include "figure/image.h"
#include "figure/movement.h"
#include "figure/properties.h"
#include "figure/route.h"
#include "figuretype/missile.h"
#include "map/figure.h"
#include "scenario/gladiator_revolt.h"
#include "sound/effect.h"
#include "sound/speech.h"

void figure::enemy_initial(formation *m) {
    map_figure_update();
    anim_frame = 0;
    route_remove();
    wait_ticks--;
    if (wait_ticks <= 0) {
        if (is_ghost && index_in_formation == 0) {
            if (m->layout == FORMATION_ENEMY_MOB)
                sound_speech_play_file("wavs/drums.wav");
            else if (m->layout == FORMATION_ENEMY12)
                sound_speech_play_file("wavs/horn2.wav");
            else {
                sound_speech_play_file("wavs/horn1.wav");
            }
        }
        is_ghost = 0;
        if (m->recent_fight)
            action_state = FIGURE_ACTION_154_ENEMY_FIGHTING;
        else {
            destination_x = m->destination_x + formation_position_x.enemy;
            destination_y = m->destination_y + formation_position_y.enemy;
            if (calc_general_direction(tile_x, tile_y, destination_x, destination_y) < 8)
                action_state = FIGURE_ACTION_153_ENEMY_MARCHING;

        }
    }
    if (type == FIGURE_ENEMY43_SPEAR || type == FIGURE_ENEMY46_CAMEL ||
        type == FIGURE_ENEMY51_SPEAR || type == FIGURE_ENEMY52_MOUNTED_ARCHER) {
        // missile throwers
        wait_ticks_missile++;
        map_point tile = {0, 0};
        if (wait_ticks_missile > figure_properties_for_type(type)->missile_delay) {
            wait_ticks_missile = 0;
            if (figure_combat_get_missile_target_for_enemy(this, 10, city_figures_soldiers() < 4, &tile)) {
                attack_image_offset = 1;
                direction = calc_missile_shooter_direction(tile_x, tile_y, tile.x, tile.y);
            } else
                attack_image_offset = 0;
        }
        if (attack_image_offset) {
            int missile_type;
            switch (m->enemy_type) {
                case ENEMY_4_GOTH:
                case ENEMY_5_PERGAMUM:
                case ENEMY_9_EGYPTIAN:
                case ENEMY_10_CARTHAGINIAN:
                    missile_type = FIGURE_ARROW;
                    break;
                default:
                    missile_type = FIGURE_SPEAR;
                    break;
            }
            if (attack_image_offset == 1) {
                if (tile.x == -1 || tile.y == -1)
                    map_point_get_last_result(&tile);

//                figure_create_missile(id, tile_x, tile_y, tile.x, tile.y, missile_type);
                missile_fire_at(target_figure_id, missile_type);
                formation_record_missile_fired(m);
            }
            if (missile_type == FIGURE_ARROW && city_sound_update_shoot_arrow())
                sound_effect_play(SOUND_EFFECT_ARROW);

            attack_image_offset++;
            if (attack_image_offset > 100)
                attack_image_offset = 0;

        }
    }
}
void figure::enemy_marching(const formation *m) {
    wait_ticks--;
    if (wait_ticks <= 0) {
        wait_ticks = 50;
        destination_x = m->destination_x + formation_position_x.enemy;
        destination_y = m->destination_y + formation_position_y.enemy;
        if (calc_general_direction(tile_x, tile_y, destination_x, destination_y) == DIR_FIGURE_AT_DESTINATION) {
            action_state = FIGURE_ACTION_151_ENEMY_INITIAL;
            return;
        }
        destination_building_id = m->destination_building_id;
        route_remove();
    }
    move_ticks(speed_multiplier);
    if (direction == DIR_FIGURE_AT_DESTINATION ||
        direction == DIR_FIGURE_REROUTE ||
        direction == DIR_FIGURE_LOST) {
        action_state = FIGURE_ACTION_151_ENEMY_INITIAL;
    }
}
void figure::enemy_fighting(const formation *m) {
    if (!m->recent_fight)
        action_state = FIGURE_ACTION_151_ENEMY_INITIAL;

    if (type != FIGURE_ENEMY46_CAMEL && type != FIGURE_ENEMY47_ELEPHANT) {
        if (type == FIGURE_ENEMY48_CHARIOT || type == FIGURE_ENEMY52_MOUNTED_ARCHER) {
            if (city_sound_update_march_horse())
                sound_effect_play(SOUND_EFFECT_HORSE_MOVING);

        } else {
            if (city_sound_update_march_enemy())
                sound_effect_play(SOUND_EFFECT_MARCHING);

        }
    }
    int target_id = target_figure_id;
    if (figure_get(target_id)->is_dead()) {
        target_figure_id = 0;
        target_id = 0;
    }
    if (target_id <= 0) {
        target_id = figure_combat_get_target_for_enemy(tile_x, tile_y);
        if (target_id) {
            figure *target = figure_get(target_id);
            destination_x = target->tile_x;
            destination_y = target->tile_y;
            target_figure_id = target_id;
            target_figure_created_sequence = target->created_sequence;
            target->targeted_by_figure_id = id;
            route_remove();
        }
    }
    if (target_id > 0) {
        move_ticks(speed_multiplier);
        if (direction == DIR_FIGURE_AT_DESTINATION) {
            figure *target = figure_get(target_figure_id);
            destination_x = target->tile_x;
            destination_y = target->tile_y;
            route_remove();
        } else if (direction == DIR_FIGURE_REROUTE || direction == DIR_FIGURE_LOST) {
            action_state = FIGURE_ACTION_151_ENEMY_INITIAL;
            target_figure_id = 0;
        }
    } else {
        action_state = FIGURE_ACTION_151_ENEMY_INITIAL;
        wait_ticks = 50;
    }
}
void figure::enemy_action(formation *m) {
    city_figures_add_enemy();
    terrain_usage = TERRAIN_USAGE_ENEMY;
    formation_position_x.enemy = formation_layout_position_x(m->layout, index_in_formation);
    formation_position_y.enemy = formation_layout_position_y(m->layout, index_in_formation);

    switch (action_state) {
        case FIGURE_ACTION_148_FLEEING:
            destination_x = source_x;
            destination_y = source_y;
            move_ticks(speed_multiplier);
            if (direction == DIR_FIGURE_AT_DESTINATION ||
                direction == DIR_FIGURE_REROUTE ||
                direction == DIR_FIGURE_LOST) {
                kill();
            }
            break;
        case FIGURE_ACTION_151_ENEMY_INITIAL:
            enemy_initial(m);
            break;
        case FIGURE_ACTION_152_ENEMY_WAITING:
            map_figure_update();
            break;
        case FIGURE_ACTION_153_ENEMY_MARCHING:
            enemy_marching(m);
            break;
        case FIGURE_ACTION_154_ENEMY_FIGHTING:
            enemy_fighting(m);
            break;
    }
}

int figure::get_direction() {
    int dir;
    if (action_state == FIGURE_ACTION_150_ATTACK)
        dir = attack_direction;
    else if (direction < 8)
        dir = direction;
    else {
        dir = previous_tile_direction;
    }
    return figure_image_normalize_direction(dir);
}
int figure::get_missile_direction(const formation *m) {
    int dir;
    if (action_state == FIGURE_ACTION_150_ATTACK)
        dir = attack_direction;
    else if (m->missile_fired || direction < 8)
        dir = direction;
    else {
        dir = previous_tile_direction;
    }
    return figure_image_normalize_direction(dir);
}

void figure::enemy43_spear_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_missile_direction(m);
    is_enemy_image = 1;

    switch (m->enemy_type) {
        case ENEMY_5_PERGAMUM:
        case ENEMY_6_SELEUCID:
        case ENEMY_7_ETRUSCAN:
        case ENEMY_8_GREEK:
            break;
        default:
            return;
    }
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 745 + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = 745 + dir;
    } else if (action_state == FIGURE_ACTION_151_ENEMY_INITIAL)
        sprite_image_id = 697 + dir + 8 * figure_image_missile_launcher_offset();
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 793 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 745 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy44_sword_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    switch (m->enemy_type) {
        case ENEMY_5_PERGAMUM:
        case ENEMY_6_SELEUCID:
        case ENEMY_9_EGYPTIAN:
            break;
        default:
            return;
    }
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 545 + dir + 8 * ((attack_image_offset - 12) / 2);
        else {
            sprite_image_id = 545 + dir;
        }
    } else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 593 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 545 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 449 + dir + 8 * anim_frame;
}
void figure::enemy45_sword_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    switch (m->enemy_type) {
        case ENEMY_7_ETRUSCAN:
        case ENEMY_8_GREEK:
        case ENEMY_10_CARTHAGINIAN:
            break;
        default:
            return;
    }
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 545 + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = 545 + dir;
    } else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 593 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 545 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 449 + dir + 8 * anim_frame;
}
void figure::enemy_camel_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 601 + dir + 8 * anim_frame;
    else if (action_state == FIGURE_ACTION_150_ATTACK)
        sprite_image_id = 601 + dir;
    else if (action_state == FIGURE_ACTION_151_ENEMY_INITIAL)
        sprite_image_id = 697 + dir + 8 * figure_image_missile_launcher_offset();
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 745 + figure_image_corpse_offset();
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy_elephant_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (direction == DIR_FIGURE_ATTACK || action_state == FIGURE_ACTION_150_ATTACK)
        sprite_image_id = 601 + dir + 8 * anim_frame;
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 705 + figure_image_corpse_offset();
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy_chariot_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 3;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (direction == DIR_FIGURE_ATTACK || action_state == FIGURE_ACTION_150_ATTACK)
        sprite_image_id = 697 + dir + 8 * (anim_frame / 2);
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 745 + figure_image_corpse_offset();
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy49_fast_sword_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 2;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    int attack_id, corpse_id, normal_id;
    if (m->enemy_type == ENEMY_0_BARBARIAN) {
        attack_id = 393;
        corpse_id = 441;
        normal_id = 297;
    } else if (m->enemy_type == ENEMY_1_NUMIDIAN) {
        attack_id = 593;
        corpse_id = 641;
        normal_id = 449;
    } else if (m->enemy_type == ENEMY_4_GOTH) {
        attack_id = 545;
        corpse_id = 593;
        normal_id = 449;
    } else
        return;
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = attack_id + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = attack_id + dir;
    } else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = corpse_id + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = attack_id + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = normal_id + dir + 8 * anim_frame;
}
void figure::enemy50_sword_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (m->enemy_type != ENEMY_2_GAUL && m->enemy_type != ENEMY_3_CELT)
        return;
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 545 + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = 545 + dir;
    } else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 593 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 545 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 449 + dir + 8 * anim_frame;
}
void figure::enemy51_spear_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 2;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_missile_direction(m);
    is_enemy_image = 1;

    if (m->enemy_type != ENEMY_1_NUMIDIAN)
        return;
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 593 + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = 593 + dir;
    } else if (action_state == FIGURE_ACTION_151_ENEMY_INITIAL)
        sprite_image_id = 545 + dir + 8 * figure_image_missile_launcher_offset();
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 641 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 593 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 449 + dir + 8 * anim_frame;
}
void figure::enemy52_mounted_archer_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 3;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_missile_direction(m);
    is_enemy_image = 1;

    if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 601 + dir + 8 * anim_frame;
    else if (action_state == FIGURE_ACTION_150_ATTACK)
        sprite_image_id = 601 + dir;
    else if (action_state == FIGURE_ACTION_151_ENEMY_INITIAL)
        sprite_image_id = 697 + dir + 8 * figure_image_missile_launcher_offset();
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 745 + figure_image_corpse_offset();
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy53_axe_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (m->enemy_type != ENEMY_2_GAUL)
        return;
    if (action_state == FIGURE_ACTION_150_ATTACK) {
        if (attack_image_offset >= 12)
            sprite_image_id = 697 + dir + 8 * ((attack_image_offset - 12) / 2);
        else
            sprite_image_id = 697 + dir;
    } else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = 745 + figure_image_corpse_offset();
    else if (direction == DIR_FIGURE_ATTACK)
        sprite_image_id = 697 + dir + 8 * (anim_frame / 2);
    else
        sprite_image_id = 601 + dir + 8 * anim_frame;
}
void figure::enemy_gladiator_action() {
//    terrain_usage = TERRAIN_USAGE_ANY;
//    use_cross_country = 0;
//    figure_image_increase_offset(12);
    if (scenario_gladiator_revolt_is_finished()) {
        // end of gladiator revolt: kill gladiators
        if (action_state != FIGURE_ACTION_149_CORPSE) {
            action_state = FIGURE_ACTION_149_CORPSE;
            wait_ticks = 0;
            direction = 0;
        }
    }
    switch (action_state) {
//        case FIGURE_ACTION_150_ATTACK:
//            figure_combat_handle_attack();
////            figure_image_increase_offset(16);
//            break;
//        case FIGURE_ACTION_149_CORPSE:
//            figure_combat_handle_corpse();
//            break;
        case FIGURE_ACTION_158_NATIVE_CREATED:
            anim_frame = 0;
            wait_ticks++;
            if (wait_ticks > 10 + (id & 3)) {
                wait_ticks = 0;
                action_state = FIGURE_ACTION_159_NATIVE_ATTACKING;
                int x_tile, y_tile;
                int building_id = formation_rioter_get_target_building(&x_tile, &y_tile);
                if (building_id) {
                    destination_x = x_tile;
                    destination_y = y_tile;
                    destination_building_id = building_id;
                    route_remove();
                } else {
                    kill();
                }
            }
            break;
        case FIGURE_ACTION_159_NATIVE_ATTACKING:
            city_figures_set_gladiator_revolt();
            terrain_usage = TERRAIN_USAGE_ENEMY;
            move_ticks(1);
            if (direction == DIR_FIGURE_AT_DESTINATION ||
                direction == DIR_FIGURE_REROUTE ||
                direction == DIR_FIGURE_LOST) {
                action_state = FIGURE_ACTION_158_NATIVE_CREATED;
            }
            break;
    }
    int dir;
    if (action_state == FIGURE_ACTION_150_ATTACK || direction == DIR_FIGURE_ATTACK)
        dir = attack_direction;
    else if (direction < 8)
        dir = direction;
    else {
        dir = previous_tile_direction;
    }
    dir = figure_image_normalize_direction(dir);

    if (action_state == FIGURE_ACTION_150_ATTACK || direction == DIR_FIGURE_ATTACK)
        sprite_image_id = image_id_from_group(GROUP_FIGURE_GLADIATOR) + dir + 104 + 8 * (anim_frame / 2);
    else if (action_state == FIGURE_ACTION_149_CORPSE)
        sprite_image_id = image_id_from_group(GROUP_FIGURE_GLADIATOR) + 96 + figure_image_corpse_offset();
    else {
        sprite_image_id = image_id_from_group(GROUP_FIGURE_GLADIATOR) + dir + 8 * anim_frame;
    }
}
void figure::enemy_caesar_legionary_action() {
//    figure_image_increase_offset(12);
//    cart_image_id = 0;

    city_figures_add_imperial_soldier();

    speed_multiplier = 1;
    formation *m = formation_get(formation_id);
    enemy_action(m);
    int dir = get_direction();
    is_enemy_image = 1;

    if (direction == DIR_FIGURE_ATTACK) {
        sprite_image_id = image_id_from_group(GROUP_FIGURE_CAESAR_LEGIONARY) + dir +
                      8 * ((attack_image_offset - 12) / 2);
    }
    switch (action_state) {
        case FIGURE_ACTION_150_ATTACK:
            if (attack_image_offset >= 12) {
                sprite_image_id = image_id_from_group(GROUP_FIGURE_CAESAR_LEGIONARY) + dir +
                              8 * ((attack_image_offset - 12) / 2);
            } else {
                sprite_image_id = image_id_from_group(GROUP_FIGURE_CAESAR_LEGIONARY) + dir;
            }
            break;
        case FIGURE_ACTION_149_CORPSE:
            sprite_image_id = image_id_from_group(GROUP_FIGURE_CAESAR_LEGIONARY) +
                              figure_image_corpse_offset() + 152;
            break;
        case FIGURE_ACTION_84_SOLDIER_AT_STANDARD:
            if (m->is_halted && m->layout == FORMATION_COLUMN && m->missile_attack_timeout)
                sprite_image_id = image_id_from_group(GROUP_BUILDING_FORT_LEGIONARY) + dir + 144;
            else {
                sprite_image_id = image_id_from_group(GROUP_BUILDING_FORT_LEGIONARY) + dir;
            }
            break;
        default:
            sprite_image_id = image_id_from_group(GROUP_FIGURE_CAESAR_LEGIONARY) + 48 + dir + 8 * anim_frame;
            break;
    }
}
