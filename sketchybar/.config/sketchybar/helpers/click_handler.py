#!/usr/bin/env python3
# File: click_handler.py (Versione Definitiva e Corretta)

import sys
import os
import subprocess
import json
import shlex

# --- Configurazione ---
BREW_PATH = "/opt/homebrew/bin/brew"
TERMINAL_APP = "kitty"
CONFIG_DIR = os.environ.get("CONFIG_DIR", os.path.expanduser("~/.config/sketchybar"))

# Icona di fallback, per evitare che sparisca
PACKAGE_ICON = "📦"
# --- Fine Configurazione ---

def run_command(command, wait=True):
    """Esegue un comando di shell. Se wait=False, non attende la fine."""
    try:
        if not wait:
            # Popen è per comandi "lancia e dimentica"
            subprocess.Popen(command, shell=True)
            return None

        # run è per comandi di cui vogliamo l'output o la cui fine vogliamo attendere
        process = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return process.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Errore eseguendo: {e.cmd}\n{e.stderr}", file=sys.stderr)
        return None

def get_outdated_count(widget_name):
    """Interroga Sketchybar per ottenere il conteggio attuale."""
    json_output = run_command(f"sketchybar --query {widget_name}")
    if json_output:
        try:
            return int(json.loads(json_output).get("label", {}).get("value", "0"))
        except (json.JSONDecodeError, ValueError):
            return 0
    return 0

def open_terminal_and_wait(main_command, success_msg, error_msg, sleep_duration):
    """
    Apre Kitty, esegue un comando, attende la chiusura, e ritorna il processo.
    La chiusura è gestita da 'read -t' dentro uno script BASH esplicito.
    """
    script = f"""
    {main_command}
    EXIT_CODE=$?
    
    echo
    if [ $EXIT_CODE -eq 0 ]; then
        echo "{success_msg}"
    else
        echo "{error_msg} (codice: $EXIT_CODE)"
    fi
    echo
    read -t {sleep_duration} -p "Premi Invio per chiudere o attendi {sleep_duration} secondi... "
    """
    
    # Forza l'uso di /bin/bash per garantire la compatibilità di 'read -t'
    final_command = [TERMINAL_APP, "-e", "/bin/bash", "-c", script]
    # Usiamo Popen ma ritorneremo l'oggetto processo per poterlo attendere
    return subprocess.Popen(final_command)

def main():
    if len(sys.argv) < 3:
        sys.exit(1)

    button = sys.argv[1]
    widget_name = sys.argv[2]

    # CORREZIONE 1: Comando di feedback più robusto per evitare che l'icona sparisca
    run_command(f"sketchybar --set {widget_name} icon='{PACKAGE_ICON}' icon.color='#FFFFFF55'")

    if button == "middle":
        # Il click centrale forza l'aggiornamento (invariato)
        run_command("pkill -USR1 -f 'brew_check'", wait=False)
        sys.exit(0)

    count = get_outdated_count(widget_name)
    proc = None # Inizializziamo la variabile del processo

    if count > 0:
        if button == "left":
            proc = open_terminal_and_wait(
                main_command=f"'{BREW_PATH}' outdated",
                success_msg="✅ Elenco pacchetti obsoleti.",
                error_msg="❌ Errore durante il controllo.",
                sleep_duration=10
            )
        elif button == "right":
            proc = open_terminal_and_wait(
                main_command=f"'{BREW_PATH}' upgrade",
                success_msg="✅ Aggiornamento completato con successo!",
                error_msg="❌ Si è verificato un errore durante l'aggiornamento.",
                sleep_duration=20
            )
    else:
        if button == "left" or button == "right":
            proc = open_terminal_and_wait(
                main_command="echo '✅ Homebrew è già aggiornato.'",
                success_msg="Nessuna operazione eseguita.",
                error_msg="",
                sleep_duration=5
            )

    if proc:
        # Attendi la fine del processo del terminale.
        proc.wait() 
        run_command("pkill -USR1 -f 'brew_check'", wait=False)

if __name__ == "__main__":
    main()