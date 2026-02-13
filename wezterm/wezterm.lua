local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function spawn_layout(window, pane, layout_id)
  if layout_id == "default" then
    window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
  elseif layout_id == "2-columns" then
    window:perform_action(
      act.Multiple({
        act.SpawnTab("CurrentPaneDomain"),
        act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
      }),
      pane
    )
  end
end

wezterm.on("rename-current-tab", function(window, pane)
	window:perform_action(
		act.PromptInputLine({
			description = "Rename current tab",
			action = wezterm.action_callback(function(win, _, line)
				if line ~= nil then
					win:active_tab():set_title(line)
				end
			end),
		}),
		pane
	)
end)

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local is_active = tab.is_active
	local bg = "#3d484d"
	local fg = "#d8cacc"

	if is_active then
		bg = "#a7c080"
		fg = "#2d353b"
	elseif hover then
		bg = "#475258"
	end

	local title = tab.tab_title
	if not title or #title == 0 then
		title = tab.active_pane.title
	end

	title = wezterm.truncate_right(title, math.max(max_width - 6, 1))

	return {
		{ Foreground = { Color = bg } },
		{ Text = "" },
		{ Background = { Color = bg }, Foreground = { Color = fg } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = "#2d353b" }, Foreground = { Color = bg } },
		{ Text = "" },
		{ Text = " " },
	}
end)

wezterm.on("update-right-status", function(window, _pane)
  local segments = {}
  if window:leader_is_active() then
    table.insert(segments, "🧭 LEADER")
  end
  window:set_right_status(table.concat(segments, "  "))
end)

wezterm.on("open-layout-selector", function(window, pane)
  window:perform_action(
    act.InputSelector({
      title = "Select tab layout",
      fuzzy = true,
      choices = {
        { id = "default", label = "default · single pane" },
        { id = "2-columns", label = "2-columns · two columns" },
      },
      action = wezterm.action_callback(function(win, p, id, _label)
        if id then
          spawn_layout(win, p, id)
        end
      end),
    }),
    pane
  )
end)

-- Font setup (Kitty: font_family/italic_font/symbol_map)
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"VictorMono Nerd Font",
	"MesloLGS NF",
	"Symbols Nerd Font Mono",
})
config.font_size = 17.0
config.font_rules = {
	{
		italic = true,
		font = wezterm.font("VictorMono Nerd Font", { style = "Italic" }),
	},
}

-- tmux-like multiplexer behavior
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1200 }
config.audible_bell = "Disabled"
config.disable_default_key_bindings = true

config.keys = {
  -- converged app-level keys (macOS)
  { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
  { key = "f", mods = "SUPER", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "n", mods = "SUPER", action = act.SpawnWindow },
  { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },
  { key = "r", mods = "SUPER", action = act.ReloadConfiguration },
  { key = "=", mods = "SUPER", action = act.IncreaseFontSize },
  { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
  { key = "0", mods = "SUPER", action = act.ResetFontSize },
  { key = "LeftArrow", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },

  -- converged app-level keys (cross-platform)
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

  -- Send literal Ctrl-a (tmux: prefix + a)
  { key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },

	-- Split panes (tmux: _ and -)
	{ key = "_", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pane navigation (tmux: h/j/k/l)
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Pane resizing (tmux: H/J/K/L)
	{ key = "h", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 2 }) },
	{ key = "j", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 2 }) },
	{ key = "k", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 2 }) },
	{ key = "l", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 2 }) },

	-- Rotate pane layout to mimic tmux swap-pane < and >
	{ key = ",", mods = "LEADER", action = act.EmitEvent("rename-current-tab") },
	{ key = ",", mods = "LEADER|SHIFT", action = act.RotatePanes("CounterClockwise") },
	{ key = ".", mods = "LEADER|SHIFT", action = act.RotatePanes("Clockwise") },

	-- Shift + arrow to switch tabs (tmux windows)
	{ key = "LeftArrow", mods = "SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT", action = act.ActivateTabRelative(1) },

	-- tmux-like workflow helpers
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	  { key = "Enter", mods = "LEADER", action = act.ActivateCopyMode },
	  { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
    { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "TABS" }) },
    { key = "g", mods = "LEADER", action = act.EmitEvent("open-layout-selector") },
	}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

-- Preserve default copy-mode keys, only remap H/L to tmux behavior.
if wezterm.gui then
	local key_tables = wezterm.gui.default_key_tables()
	local copy_mode = key_tables.copy_mode

	for i = #copy_mode, 1, -1 do
		local entry = copy_mode[i]
		if entry.key == "H" or entry.key == "L" then
			table.remove(copy_mode, i)
		end
	end

	table.insert(copy_mode, { key = "H", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") })
	table.insert(copy_mode, { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") })
	table.insert(copy_mode, { key = "L", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") })
	table.insert(copy_mode, { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") })

	config.key_tables = key_tables
end

-- Window/UI
config.window_decorations = "RESIZE" -- Kitty titlebar-only
config.window_background_opacity = 1.0
config.macos_window_background_blur = 20
config.initial_cols = 90
config.initial_rows = 28

-- Terminal behavior
config.term = "xterm-256color"
config.scrollback_lines = 10000 -- Match tmux history-limit
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 1000

-- Tab bar (Kitty: tab_bar_style separator)
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true

-- Theme: everforest-dark-medium-kitty.conf
config.colors = {
	foreground = "#d8cacc",
	background = "#323d43",

	cursor_bg = "#7fbbb3",
	cursor_fg = "#323d43",

	selection_fg = "#3c474d",
	selection_bg = "#525c62",

	ansi = {
		"#4a555b",
		"#e68183",
		"#a7c080",
		"#dbbc7f",
		"#7fbbb3",
		"#d699b6",
		"#83c092",
		"#d8caac",
	},

	brights = {
		"#525c62",
		"#e68183",
		"#a7c080",
		"#dbbc7f",
		"#7fbbb3",
		"#d699b6",
		"#83c092",
		"#d8caac",
	},

	tab_bar = {
		background = "#2d353b",
		inactive_tab_edge = "#2d353b",
		active_tab = {
			bg_color = "#a7c080",
			fg_color = "#2d353b",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#3d484d",
			fg_color = "#d8cacc",
		},
		inactive_tab_hover = {
			bg_color = "#475258",
			fg_color = "#d8cacc",
		},
		new_tab = {
			bg_color = "#323d43",
			fg_color = "#a7c080",
		},
		new_tab_hover = {
			bg_color = "#3d484d",
			fg_color = "#a7c080",
			italic = true,
		},
	},
}

return config
