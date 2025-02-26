local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Configurazione
local CHECK_INTERVAL = 60  -- Controllo ogni minuto
local BREW_UPDATE_INTERVAL = 900  -- Aggiornamento database ogni 15 minuti
local THRESHOLDS = {
  { count = 0,  color = colors.blue },   -- 1-5 pacchetti
  { count = 5,  color = colors.yellow }, -- 6-9 pacchetti
  { count = 10, color = colors.orange }, -- 10-14 pacchetti
  { count = 15, color = colors.red }     -- 15+ pacchetti
}

-- Chiudi eventuali istanze precedenti e avvia il provider di eventi
sbar.exec(string.format(
  "pkill -f 'brew_check' >/dev/null 2>&1; " ..
  "$CONFIG_DIR/helpers/event_providers/brew_check/bin/brew_check brew_update %d %d",
  CHECK_INTERVAL, BREW_UPDATE_INTERVAL
))

-- Widget principale - sempre visibile
local brew = sbar.add("item", "widgets.brew", {
  position = "right",
  icon = {
    string = icons.package or "📦", -- Fallback se l'icona non è definita
    color = colors.grey,
    font = {
      family = settings.font.icons,
      style = settings.font.style_map["Regular"],
      size = 10.0,
    },
    padding_right = 4,
  },
  label = {
    string = "0",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.grey,
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6,
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
})

-- Determina il colore in base al conteggio
local function get_color(count)
  count = tonumber(count) or 0
  local color = colors.grey
  
  if count > 0 then
    color = colors.blue
    for i = #THRESHOLDS, 1, -1 do
      if count > THRESHOLDS[i].count then
        color = THRESHOLDS[i].color
        break
      end
    end
  end
  
  return color
end

-- Sottoscrivi all'evento di aggiornamento
brew:subscribe("brew_update", function(env)
  -- Ottieni e valida il conteggio
  local count = tonumber(env.outdated_count) or 0
  local pending_updates = env.pending_updates or "nessuno"
  
  -- Ottieni il colore appropriato
  local color = get_color(count)
  
  -- Aggiorna l'etichetta con il conteggio e il colore
  brew:set({
    icon = { color = color },
    label = {
      string = tostring(count),
      color = color
    }
  })
  
  -- Imposta il tooltip con i nomi dei pacchetti
  if count > 0 then
    brew:set({
      tooltip = "Pacchetti da aggiornare: " .. pending_updates
    })
  else
    brew:set({
      tooltip = "Tutti i pacchetti sono aggiornati"
    })
  end
end)

-- Azioni al click
brew:subscribe("mouse.clicked", function(env)
  if env.button == "left" then
    -- Click sinistro: apri il terminale con la lista dei pacchetti
    sbar.exec("osascript -e 'tell application \"Terminal\" to do script \"brew outdated\"'")
  elseif env.button == "right" then
    -- Click destro: aggiorna tutti i pacchetti
    sbar.exec("osascript -e 'tell application \"Terminal\" to do script \"brew upgrade\"'")
  elseif env.button == "middle" then
    -- Click centrale: forza aggiornamento manuale
    sbar.exec("pkill -USR1 -f 'brew_check'")
  end
end)

-- Sfondo intorno all'elemento brew
sbar.add("bracket", "widgets.brew.bracket", { brew.name }, {
  background = { color = colors.bg1 }
})

-- Padding intorno all'elemento brew
sbar.add("item", "widgets.brew.padding", {
  position = "right",
  width = settings.group_paddings
})