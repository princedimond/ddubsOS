-- OXWM Configuration File (Lua)
-- Migrated from config.ron
-- Edit this file and reload with Mod+Shift+R (no compilation needed!)

local terminal = "kitty"
local modkey = "Mod4"
local secondary_modkey = "Mod1"

-- Color palette
local colors = {
	lavender = "#a9b1d6",
	light_blue = "#7aa2f7",
	grey = "#bbbbbb",
	cyan = "#0db9d7",
	purple = "#ad8ee6",
	bg = "#1a1b26",
	blue = "#6dade3",
	red = "#f7768e",
	green = "#9ece6a",
	fg = "#bbbbbb",
}

-- Main configuration table
return {
	-- Appearance
	border_width = 2,
	border_focused = colors.blue,
	border_unfocused = colors.grey,
	font = "monospace:style=Bold:size=10",

	-- Window gaps
	gaps_enabled = true,
	gap_inner_horizontal = 5,
	gap_inner_vertical = 5,
	gap_outer_horizontal = 5,
	gap_outer_vertical = 5,

	-- Basics
	modkey = "Mod4",
	terminal = "kitty",

	-- Workspace tags
	tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },

	-- Layout symbol overrides
	layout_symbols = {
		{ name = "tiling", symbol = "[T]" },
		{ name = "normie", symbol = "[F]" },
	},

	-- Keybindings
	keybindings = {
		{
			modifiers = { "Mod4" },
			key = "Return",
			action = "Spawn",
			arg = "kitty",
			desc = "Super+Return — Launch terminal",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "Slash",
			action = "ShowKeybindOverlay",
			desc = "Super+Shift+/  — Keyboard Bindings overlay",
		},
		{
			modifiers = { "Mod4" },
			key = "D",
			action = "Spawn",
			arg = { "sh", "-c", "dmenu_run -l 10" },
			desc = "Super+D — Open dmenu launcher",
		},
		{
			modifiers = { "Mod4" },
			key = "S",
			action = "Spawn",
			arg = { "sh", "-c", "flameshot gui" },
			desc = "Super+S — Flameshot GUI ",
		},
		{ modifiers = { "Mod4" }, key = "Q", action = "KillClient", desc = "Super+Q — Close focused window" },
		{
			modifiers = { "Mod4", "Shift" },
			key = "F",
			action = "ToggleFullScreen",
			desc = "Super+Shift+F — Toggle fullscreen",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "Space",
			action = "ToggleFloating",
			desc = "Super+Shift+Space — Toggle floating",
		},
		{
			modifiers = { "Mod4" },
			key = "F",
			action = "ChangeLayout",
			arg = "normie",
			desc = "Super+F — Switch layout to floating/normie",
		},
		{
			modifiers = { "Mod4" },
			key = "C",
			action = "ChangeLayout",
			arg = "tiling",
			desc = "Super+C — Switch layout to tiling",
		},
		{ modifiers = { "Mod1" }, key = "N", action = "CycleLayout", desc = "Alt+N — Cycle layouts" },
		{ modifiers = { "Mod4" }, key = "A", action = "ToggleGaps", desc = "Super+A — Toggle window gaps" },
		{ modifiers = { "Mod4", "Shift" }, key = "Q", action = "Quit", desc = "Super+Shift+Q — Quit OxWM" },
		{ modifiers = { "Mod4", "Shift" }, key = "R", action = "Restart", desc = "Super+Shift+R — Restart OxWM" },
		{ modifiers = { "Mod4" }, key = "H", action = "FocusDirection", arg = 2, desc = "Super+H — Focus left" },
		{ modifiers = { "Mod4" }, key = "J", action = "FocusDirection", arg = 1, desc = "Super+J — Focus down" },
		{ modifiers = { "Mod4" }, key = "K", action = "FocusDirection", arg = 0, desc = "Super+K — Focus up" },
		{ modifiers = { "Mod4" }, key = "L", action = "FocusDirection", arg = 3, desc = "Super+L — Focus right" },
		{
			modifiers = { "Mod4" },
			key = "Comma",
			action = "FocusMonitor",
			arg = -1,
			desc = "Super+, — Focus previous monitor",
		},
		{
			modifiers = { "Mod4" },
			key = "Period",
			action = "FocusMonitor",
			arg = 1,
			desc = "Super+. — Focus next monitor",
		},
		{ modifiers = { "Mod4" }, key = "1", action = "ViewTag", arg = 0, desc = "Super+1 — Switch to workspace 1" },
		{ modifiers = { "Mod4" }, key = "2", action = "ViewTag", arg = 1, desc = "Super+2 — Switch to workspace 2" },
		{ modifiers = { "Mod4" }, key = "3", action = "ViewTag", arg = 2, desc = "Super+3 — Switch to workspace 3" },
		{ modifiers = { "Mod4" }, key = "4", action = "ViewTag", arg = 3, desc = "Super+4 — Switch to workspace 4" },
		{ modifiers = { "Mod4" }, key = "5", action = "ViewTag", arg = 4, desc = "Super+5 — Switch to workspace 5" },
		{ modifiers = { "Mod4" }, key = "6", action = "ViewTag", arg = 5, desc = "Super+6 — Switch to workspace 6" },
		{ modifiers = { "Mod4" }, key = "7", action = "ViewTag", arg = 6, desc = "Super+7 — Switch to workspace 7" },
		{ modifiers = { "Mod4" }, key = "8", action = "ViewTag", arg = 7, desc = "Super+8 — Switch to workspace 8" },
		{ modifiers = { "Mod4" }, key = "9", action = "ViewTag", arg = 8, desc = "Super+9 — Switch to workspace 9" },
		{
			modifiers = { "Mod4", "Shift" },
			key = "1",
			action = "MoveToTag",
			arg = 0,
			desc = "Super+Shift+1 — Move window to workspace 1",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "2",
			action = "MoveToTag",
			arg = 1,
			desc = "Super+Shift+2 — Move window to workspace 2",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "3",
			action = "MoveToTag",
			arg = 2,
			desc = "Super+Shift+3 — Move window to workspace 3",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "4",
			action = "MoveToTag",
			arg = 3,
			desc = "Super+Shift+4 — Move window to workspace 4",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "5",
			action = "MoveToTag",
			arg = 4,
			desc = "Super+Shift+5 — Move window to workspace 5",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "6",
			action = "MoveToTag",
			arg = 5,
			desc = "Super+Shift+6 — Move window to workspace 6",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "7",
			action = "MoveToTag",
			arg = 6,
			desc = "Super+Shift+7 — Move window to workspace 7",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "8",
			action = "MoveToTag",
			arg = 7,
			desc = "Super+Shift+8 — Move window to workspace 8",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "9",
			action = "MoveToTag",
			arg = 8,
			desc = "Super+Shift+9 — Move window to workspace 9",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "H",
			action = "SwapDirection",
			arg = 2,
			desc = "Super+Shift+H — Swap with left window",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "J",
			action = "SwapDirection",
			arg = 1,
			desc = "Super+Shift+J — Swap with down window",
		},
		{
			modifiers = { "Mod4", "Mod1" },
			key = "K",
			action = "Spawn",
			arg = { "sh", "-c", "oxwm-parser" },
			desc = "Super+Alt+K — Show OxWM keybinds helper",
		},
		{
			modifiers = { "Mod4", "Shift" },
			key = "L",
			action = "SwapDirection",
			arg = 3,
			desc = "Super+Shift+L — Swap with right window",
		},
		{
			keys = {
				{ modifiers = { "Mod4" }, key = "Space" },
				{ modifiers = {}, key = "T" },
			},
			action = "Spawn",
			arg = "kitty",
			desc = "Keychord: Super+Space then t — Launch terminal",
		},
	},

	-- Status bar blocks
	status_blocks = {
		{
			format = "Ram: {used}/{total} GB",
			command = "Ram",
			interval_secs = 5,
			color = colors.light_blue,
			underline = true,
		},
		{
			format = " │  ",
			command = "Static",
			interval_secs = 999999999,
			color = colors.lavender,
			underline = false,
		},
		{
			format = "Kernel: {}",
			command = "Shell",
			command_arg = "uname -r",
			interval_secs = 999999999,
			color = colors.red,
			underline = true,
		},
		{
			format = " │  ",
			command = "Static",
			interval_secs = 999999999,
			color = colors.lavender,
			underline = false,
		},
		{
			format = "{}",
			command = "DateTime",
			command_arg = "%a, %b %d - %-I:%M %P",
			interval_secs = 1,
			color = colors.cyan,
			underline = true,
		},
	},

	-- Color schemes for bar
	scheme_normal = {
		foreground = colors.fg,
		background = colors.bg,
		underline = "#444444",
	},
	scheme_occupied = {
		foreground = colors.cyan,
		background = colors.bg,
		underline = colors.cyan,
	},
	scheme_selected = {
		foreground = colors.cyan,
		background = colors.bg,
		underline = colors.purple,
	},

	-- Autostart commands
	autostart = { "xrandr --output Virtual-1 --mode 1920x1080", "picom -b", "nitrogen --restore &", "dunst &" },
}
