-- https://wezterm.org
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.window_background_opacity = 0.7
config.window_close_confirmation = 'NeverPrompt'
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font_with_fallback {
    'Fira Code',
    'Iosevka',
    'Sarasa Mono CL',
}

return config
