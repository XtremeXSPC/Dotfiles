-- File: homebrew.lua (Versione con Click Handler Python)
local icons = require("icons")
local colors = require("colors")
local settings =require("settings")

-- Widget per la gestione degli aggiornamenti di Homebrew
-- Usa un click handler Python esterno per la massima robustezza.

local CONFIG = {
  check_interval = 60,
  update_interval = 900,
  widget_name = "widgets.brew"
}

local THRESHOLDS = {
  { count = 0,  color = colors.grey },
  { count = 1,  color = colors.blue },
  { count = 5,  color = colors.yellow },
  { count = 10, color = colors.orange },
  { count = 15, color = colors.red }
}

-- Esegue il provider di eventi C in background
sbar.exec("pkill -f 'brew_check'")
sbar.exec("'"..os.getenv("CONFIG_DIR").."/helpers/event_providers/brew_check/bin/brew_check' brew_update "..CONFIG.check_interval.." "..CONFIG.update_interval.." &")

local function get_color(count)
  count = tonumber(count) or 0
  for i = #THRESHOLDS, 1, -1 do
    if count >= THRESHOLDS[i].count then
      return THRESHOLDS[i].color
    end
  end
  return colors.grey
end

local brew = sbar.add("item", CONFIG.widget_name, {
  position = "right",
  icon = {
    string = icons.package or "📦",
    color = colors.grey,
    font = { family = settings.font.icons, style = settings.font.style_map["Regular"], size = 10.0 },
  },
  label = {
    string = "?",
    font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = 9.0 },
    color = colors.grey,
  },
  
  -- NUOVO CLICK_SCRIPT: Esegue lo script Python, passando il pulsante ($BUTTON) e il nome del widget ($NAME)
  click_script = "$CONFIG_DIR/helpers/click_handler.py $BUTTON $NAME"
})

-- La sottoscrizione all'evento serve solo ad aggiornare l'icona
brew:subscribe("brew_update", function(env)
  if env.SENDER == "brew_update" then
    local count = tonumber(env.outdated_count) or 0
    local color = get_color(count)
    brew:set({
      icon = { color = color },
      label = { string = tostring(count), color = color }
    })
  end
end)

brew:subscribe("mouse.entered", function() brew:set({ background = { color = colors.bg2 }}) end)
brew:subscribe("mouse.exited",  function() brew:set({ background = { color = { alpha = 0 } }}) end)

sbar.add("bracket", CONFIG.widget_name .. ".bracket", { brew.name }, { background = { color = colors.bg1 }})