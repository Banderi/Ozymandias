#ifndef GAME_GAME_H
#define GAME_GAME_H

bool game_pre_init(void);

bool game_init(void);

bool game_init_editor(void);

int game_reload_language(void);

void game_run(void);

void game_draw(void);

void game_exit_editor(void);

void game_exit(void);

#endif // GAME_GAME_H
