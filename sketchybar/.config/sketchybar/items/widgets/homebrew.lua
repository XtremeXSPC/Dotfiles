local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

--[[
  Widget per la gestione degli aggiornamenti di Homebrew
  Versione migliorata per maggiore robustezza ed efficienza
]]

-- Configurazione
local CONFIG = {
  check_interval = 60,         -- Controllo ogni minuto
  update_interval = 900,       -- Aggiornamento database ogni 15 minuti
  brew_path = "/opt/homebrew/bin/brew",
  terminal_app = "/Applications/kitty.app/Contents/MacOS/kitty",
  timeout = 120,               -- Timeout per operazioni in secondi
  debug = false,               -- Modalità debug
  hover_effect = true,         -- Effetto hover
  widget_name = "widgets.brew" -- Nome del widget principale
}

-- Definizione delle soglie di colore
local THRESHOLDS = {
  { count = 0,  color = colors.grey },   -- 0 pacchetti (aggiornato)
  { count = 1,  color = colors.blue },   -- 1-5 pacchetti
  { count = 5,  color = colors.yellow }, -- 6-9 pacchetti
  { count = 10, color = colors.orange }, -- 10-14 pacchetti
  { count = 15, color = colors.red }     -- 15+ pacchetti
}

-- Colori di feedback visivo
local FEEDBACK_COLORS = {
  updating = "#FF00FF00",      -- Verde per l'aggiornamento in corso
  success = "#FF55FF55",       -- Verde più chiaro per successo
  error = "#FFFF5555",         -- Rosso per errori
  loading = "#FFFFFF55"        -- Giallo per caricamento
}

-- Helper per log di debug
local function debug_log(message)
  if CONFIG.debug then
    print("[BREW] " .. message)
  end
end

-- Helper per eseguire comandi in modo sicuro
local function safe_exec(command)
  debug_log("Esecuzione comando: " .. command)
  local success, result, code = sbar.exec(command)
  
  if not success then
    debug_log("Errore nell'esecuzione del comando. Codice: " .. (code or "N/A"))
    return false, result
  end
  
  return true, result
end

-- Helper per verificare che il percorso esista
local function path_exists(path)
  local success, _ = safe_exec("[ -e \"" .. path .. "\" ] && echo 'exists' || echo 'missing'")
  return success and _.stdout and _.stdout:find("exists") ~= nil
end

-- Controllo preliminare delle dipendenze
local function check_dependencies()
  if not path_exists(CONFIG.terminal_app) then
    debug_log("AVVISO: Il terminale specificato non esiste: " .. CONFIG.terminal_app)
    CONFIG.terminal_app = "open -a Terminal"
  end
  
  if not path_exists(CONFIG.brew_path) then
    debug_log("AVVISO: Brew non trovato in: " .. CONFIG.brew_path)
    -- Tenta di trovare brew nel path
    local success, result = safe_exec("which brew")
    if success and result.stdout and result.stdout ~= "" then
      CONFIG.brew_path = result.stdout:gsub("%s+$", "")
      debug_log("Brew trovato in: " .. CONFIG.brew_path)
    else
      debug_log("ERRORE: Brew non trovato nel sistema")
    end
  end
end

-- Chiudi eventuali istanze precedenti e avvia il provider di eventi
local function start_event_provider()
  local command = string.format(
    "pkill -f 'brew_check' >/dev/null 2>&1; " ..
    "$CONFIG_DIR/helpers/event_providers/brew_check/bin/brew_check brew_update %d %d %s",
    CONFIG.check_interval, 
    CONFIG.update_interval,
    CONFIG.debug and "--verbose" or ""
  )
  
  local success, result = safe_exec(command)
  if not success then
    debug_log("Errore nell'avvio del provider di eventi: " .. (result or "Errore sconosciuto"))
    return false
  end
  
  return true
end

-- Determina il colore in base al conteggio
local function get_color(count)
  count = tonumber(count) or 0
  local color = colors.grey
  
  for i = #THRESHOLDS, 1, -1 do
    if count >= THRESHOLDS[i].count then
      color = THRESHOLDS[i].color
      break
    end
  end
  
  return color
end

-- Creare un feedback temporaneo
local function temporary_feedback(widget, icon_color, duration, callback)
  local original_color = widget:query("icon.color").icon.color
  
  widget:set({ icon = { color = icon_color } })
  sbar.exec(string.format("sleep %f", duration))
  
  if callback then
    callback()
  else
    widget:set({ icon = { color = original_color } })
  end
end

-- Esegui comando nel terminale con feedback visivo
local function run_in_terminal(widget, command, title, color)
  -- Prepara il comando con timeout
  local terminal_cmd = string.format(
    '%s -e sh -c \'timeout %d %s; EXIT_CODE=$?; ' ..
    'if [ $EXIT_CODE -eq 124 ]; then echo "\\nOperazione interrotta per timeout"; fi; ' ..
    'echo "\\n%s"; read\'',
    CONFIG.terminal_app,
    CONFIG.timeout,
    command,
    title or "Premi Invio per chiudere"
  )
  
  -- Fornisci feedback visivo che l'operazione è in corso
  temporary_feedback(widget, color or FEEDBACK_COLORS.loading, 0.3, function()
    -- Esegui il comando e reimposta il widget
    safe_exec(terminal_cmd .. " &")
    
    -- Forza aggiornamento del widget dopo l'esecuzione del comando
    -- Attendiamo un po' più a lungo per dare tempo al terminale di completare
    sbar.exec("sleep 2 && sketchybar --trigger brew_update")
  end)
end

-- Controllo dipendenze prima di iniziare
check_dependencies()

-- Avvio del provider di eventi
local provider_started = start_event_provider()
if not provider_started then
  debug_log("ERRORE: Impossibile avviare il provider di eventi")
end

-- Widget principale - sempre visibile
local brew = sbar.add("item", CONFIG.widget_name, {
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
    string = "?", -- Inizializzazione con "?" invece di "0" per indicare stato sconosciuto
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

-- Sottoscrivi all'evento di aggiornamento
brew:subscribe("brew_update", function(env)
  -- Ottieni e valida il conteggio
  local count = tonumber(env.outdated_count) or 0
  local pending_updates = env.pending_updates or "nessuno"
  local last_check = tonumber(env.last_check) or 0
  local error_message = env.error or ""
  
  -- Ottieni il colore appropriato
  local color = get_color(count)
  
  -- Log di debug delle informazioni ricevute
  if CONFIG.debug then
    debug_log(string.format(
      "Aggiornamento ricevuto: count=%d, updates=%s, last_check=%d, error=%s",
      count, pending_updates, last_check, error_message
    ))
  end
  
  -- Aggiorna l'etichetta con il conteggio e il colore
  brew:set({
    icon = { color = color },
    label = {
      string = tostring(count),
      color = color
    }
  })
  
  -- Costruisci un tooltip più informativo
  local tooltip = ""
  
  if error_message ~= "" and error_message ~= "Nessun errore" then
    tooltip = "ERRORE: " .. error_message .. "\n\n"
  end
  
  if count > 0 then
    tooltip = tooltip .. "Pacchetti da aggiornare: " .. pending_updates
    
    -- Aggiungi informazioni sul tempo dell'ultimo controllo
    if last_check > 0 then
      local time_diff = os.time() - last_check
      local time_str = ""
      
      if time_diff < 60 then
        time_str = string.format("%d secondi fa", time_diff)
      elseif time_diff < 3600 then
        time_str = string.format("%d minuti fa", math.floor(time_diff / 60))
      else
        time_str = string.format("%d ore fa", math.floor(time_diff / 3600))
      end
      
      tooltip = tooltip .. "\n\nUltimo controllo: " .. time_str
    end
    
    tooltip = tooltip .. "\n\nClick sinistro: Mostra dettagli\nClick destro: Aggiorna tutto\nClick centrale: Forza controllo"
  else
    tooltip = tooltip .. "Tutti i pacchetti sono aggiornati"
    
    if last_check > 0 then
      local time_diff = os.time() - last_check
      local time_str = ""
      
      if time_diff < 60 then
        time_str = string.format("%d secondi fa", time_diff)
      elseif time_diff < 3600 then
        time_str = string.format("%d minuti fa", math.floor(time_diff / 60))
      else
        time_str = string.format("%d ore fa", math.floor(time_diff / 3600))
      end
      
      tooltip = tooltip .. "\nUltimo controllo: " .. time_str
    end
    
    tooltip = tooltip .. "\n\nClick centrale: Forza controllo"
  end
  
  brew:set({ tooltip = tooltip })
end)

-- Imposta lo script di click per gestire le interazioni dell'utente
brew:set({
  click_script = [[
    # Assicuriamoci di essere nella home directory dell'utente
    cd "$HOME"
    
    # Percorsi delle applicazioni
    TERMINAL="]] .. CONFIG.terminal_app .. [["
    BREW="]] .. CONFIG.brew_path .. [["
    
    # Gestione dei click in base al pulsante premuto
    case "$BUTTON" in
      "left")
        # Mostra i pacchetti da aggiornare se ce ne sono
        if [ "$(sketchybar --query $NAME | jq -r '.label.value')" != "0" ]; then
          # Feedback visivo
          sketchybar --set $NAME icon.color=]] .. FEEDBACK_COLORS.loading .. [[
          # Esegui comando
          "$TERMINAL" -e sh -c '$BREW outdated; echo ""; echo "Premi Invio per chiudere"; read' &
          # Reimposta colore dopo breve feedback
          sleep 0.3
          sketchybar --trigger brew_update
        else
          # Nessun pacchetto da aggiornare
          sketchybar --set $NAME icon.color=]] .. FEEDBACK_COLORS.success .. [[
          sleep 0.5
          sketchybar --trigger brew_update
        fi
        ;;
      "right")
        # Aggiorna tutti i pacchetti se ce ne sono
        if [ "$(sketchybar --query $NAME | jq -r '.label.value')" != "0" ]; then
          # Feedback visivo
          sketchybar --set $NAME icon.color=]] .. FEEDBACK_COLORS.updating .. [[
          # Esegui comando di aggiornamento con gestione degli errori
          "$TERMINAL" -e sh -c 'echo "⏳ Aggiornamento in corso..."; $BREW upgrade && echo "✅ Aggiornamento completato con successo!" || echo "❌ Si è verificato un errore durante l'aggiornamento"; echo ""; echo "Premi Invio per chiudere"; read' &
          # Reimposta il widget dopo un po' di tempo per dare tempo all'aggiornamento
          sleep 1
          sketchybar --trigger brew_update
        else
          # Nessun pacchetto da aggiornare
          sketchybar --set $NAME icon.color=]] .. FEEDBACK_COLORS.success .. [[
          sleep 0.5
          sketchybar --trigger brew_update
        fi
        ;;
      "middle")
        # Forza aggiornamento manuale del check
        # Prima invia SIGUSR1 al processo brew_check se esiste
        if pgrep -f "brew_check" > /dev/null; then
          pkill -USR1 -f 'brew_check'
        else
          # Se il processo non esiste, riavvialo
          $CONFIG_DIR/helpers/event_providers/brew_check/bin/brew_check brew_update ]] .. CONFIG.check_interval .. [[ ]] .. CONFIG.update_interval .. [[ ]] .. (CONFIG.debug and "--verbose" or "") .. [[ &
        fi
        
        # Fornisci un feedback visivo che l'aggiornamento è stato richiesto
        sketchybar --set $NAME icon.color=]] .. FEEDBACK_COLORS.updating .. [[
        sleep 0.7
        sketchybar --trigger brew_update
        ;;
    esac
  ]]
})

-- Aggiungi effetto hover per feedback visivo
if CONFIG.hover_effect then
  brew:subscribe("mouse.entered", function(env)
    brew:set({ 
      background = { 
        color = colors.bg2
      }
    })
  end)
  
  brew:subscribe("mouse.exited", function(env)
    brew:set({ 
      background = { 
        color = { alpha = 0 }
      }
    })
  end)
end

-- Sfondo intorno all'elemento brew
sbar.add("bracket", CONFIG.widget_name .. ".bracket", { brew.name }, {
  background = { color = colors.bg1 }
})

-- Padding intorno all'elemento brew
sbar.add("item", CONFIG.widget_name .. ".padding", {
  position = "right",
  width = settings.group_paddings
})

-- Trigger iniziale per aggiornare lo stato
sbar.exec("sketchybar --trigger brew_update")

debug_log("Widget Homebrew inizializzato con successo")