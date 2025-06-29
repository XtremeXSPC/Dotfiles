-- File: homebrew.lua
-- Configures the Sketchybar item for Homebrew updates.

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- --- Configuration ---
local CONFIG = {
  widget_name = "widgets.brew",
  event_name = "brew_update_event", -- Unique event name for our C helper
  check_interval = 60,  -- Check for updates every 60 seconds
  update_interval = 900, -- Run `brew update` every 15 minutes
  helper_path = os.getenv("CONFIG_DIR") .. "/helpers/event_providers/brew_check/bin/brew_check"
}

-- --- Color Thresholds ---
local THRESHOLDS = {
  { count = 0,  color = colors.grey },
  { count = 1,  color = colors.blue },
  { count = 5,  color = colors.yellow },
  { count = 10, color = colors.orange },
  { count = 15, color = colors.red }
}

-- --- Helper Functions ---
local function get_color(count)
  count = tonumber(count) or 0
  for i = #THRESHOLDS, 1, -1 do
    if count >= THRESHOLDS[i].count then
      return THRESHOLDS[i].color
    end
  end
  return colors.grey
end

-- --- Start Background Helper ---
-- Ensure any previous instance is terminated before starting a new one.
sbar.exec("pkill -f " .. CONFIG.helper_path)
local start_cmd = string.format(
  "'%s' %s %d %d &",
  CONFIG.helper_path, CONFIG.event_name, CONFIG.check_interval, CONFIG.update_interval
)
sbar.exec(start_cmd)

-- --- Sketchybar Item Definition ---
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
  
  -- This click script is simple, safe, and reliable.
  click_script = [[
    #!/bin/bash
    # This script handles clicks directly and safely.

    WIDGET_NAME="]]..CONFIG.widget_name..[["
    HELPER_PATH="]]..CONFIG.helper_path..[["
    
    # Give instant visual feedback on click
    sketchybar --set $WIDGET_NAME icon.color='#FFFFFF55'

    if [ "$BUTTON" = "middle" ]; then
      # Middle click: Force a refresh by sending SIGUSR1 to the helper process.
      pkill -USR1 -f "$HELPER_PATH"
      
    elif [ "$BUTTON" = "left" ] || [ "$BUTTON" = "right" ]; then
      # Open Kitty terminal to perform the action.
      # The user closes the terminal manually. No complex process killing logic needed.
      COUNT=$(sketchybar --query $WIDGET_NAME | jq -r '.label.value')
      
      CMD_TO_RUN="echo '✅ Homebrew è già aggiornato.'"
      if [ "$COUNT" -gt 0 ]; then
        if [ "$BUTTON" = "left" ]; then
          CMD_TO_RUN="/opt/homebrew/bin/brew outdated"
        else # right click
          CMD_TO_RUN="/opt/homebrew/bin/brew upgrade"
        fi
      fi
      
      kitty -e sh -c "$CMD_TO_RUN; echo; read -p 'Premi Invio per chiudere...'"
    fi
  ]],
})

-- --- Event Subscription ---
-- Subscribe to the event sent by our C helper to update the UI.
brew:subscribe(CONFIG.event_name, function(env)
  local count = tonumber(env.outdated_count) or 0
  local color = get_color(count)
  
  -- Set icon, label, and tooltip
  brew:set({
    icon = { color = color },
    label = { string = tostring(count), color = color },
    tooltip = (count > 0) and ("Outdated packages: " .. (env.pending_updates or "N/A")) or "Homebrew is up to date"
  })
end)

-- Visual feedback on hover
brew:subscribe("mouse.entered", function() brew:set({ background = { color = colors.bg2 }}) end)
brew:subscribe("mouse.exited",  function() brew:set({ background = { color = { alpha = 0 } }}) end)

-- Bracket and padding
sbar.add("bracket", CONFIG.widget_name .. ".bracket", { brew.name }, { background = { color = colors.bg1 }})