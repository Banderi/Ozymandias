#include "effect.h"

#include "game/settings.h"
#include "sound/channel.h"
#include "sound/device.h"

void sound_effect_set_volume(int percentage) {
    for (int i = SOUND_CHANNEL_EFFECTS_MIN; i <= SOUND_CHANNEL_EFFECTS_MAX; i++) {
        sound_device_set_channel_volume(i, percentage);
    }
}

void sound_effect_play(int effect) {
    auto&
     settings = Settings::instance();
    auto setting_sound_effects = settings.sound(SoundType::EFFECTS);
    if (!setting_sound_effects.enabled) {
        return;
    }
    if (sound_device_is_channel_playing(effect)) {
        return;
    }
    sound_device_play_channel(effect, setting_sound_effects.volume);
}
