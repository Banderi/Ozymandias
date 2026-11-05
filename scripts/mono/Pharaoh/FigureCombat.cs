using Godot;

public partial class Figure : ReferenceEx {

    void ostrich_panic_something(int mode) {
        // // Modes with no counter involvement: just call with a fixed value
        // switch (mode) {
        //     case 0:  figure_advance(0); return;
        //     case 6:  figure_advance(1); return;
        //     case 12: figure_advance(2); return;
        // }
        // if (mode < 0 || mode > 17) { // default
        //     figure_advance(3);
        //     return;
        // }

        // const CounterStep *s = &STEPS[mode];
        // if (*counter < s->limit) {
        //     if (s->below != NO_CALL)
        //         figure_advance(s->below);
        //     (*counter)++;
        // } else {
        //     if (s->at_end != NO_CALL)
        //         figure_advance(s->at_end);
        //     *counter = 0;
        // }
    }
    void figure_advance(int frames) {
        // while (true) {
        //     if (frames < 1) {
        //         FIGURE_SOMETHING_TILE_ADVANCE = 0;
        //         return;
        //     }
        //     frames--;
        //     data.progress_on_tile++;
        //     if (data.progress_on_tile > 14) {
        //         FUN_004baa10(figure_id,0);
        //         data.progress_on_tile = 15;

        //         // no route
        //         if (data.routing_path_id < 1)
        //             FUN_004b2d20(figure_id);
                
        //         FUN_004b33d0(figure_id);
        //         FUN_004b3530(figure_id);

        //         // check if figure is lost
        //         if (data.direction > Enums.FigureDirections.TOP) {
        //             FIGURE_SOMETHING_TILE_ADVANCE = 0;
        //             return;
        //         }
        //         data.routing_current_tile = data.routing_current_tile + 1;
        //         data.prev_direction = data.direction;
        //         data.progress_on_tile = 0;
        //     }

        //     // reached the center of the tile
        //     if (data.progress_on_tile == 8)
        //         FUN_004b3c60(figure_id);
        //     FUN_004b3f00(figure_id);
        // }
    }
}