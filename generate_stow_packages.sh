#! /bin/bash

# Directory sorgente da cui copiare le configurazioni
SOURCE_DIR="$HOME/.config"

# Directory corrente dove creare i pacchetti Stow
TARGET_DIR=$(pwd)

# Elenco delle directory da escludere
EXCLUDE=(
	".andorid" ".vscode" "crossnote" "emacs" "fzf-fit.sh" "gh" "github-copilot"
	"gtk-2.0" "jgit" "Microsoft" "raycast" "thefuck" "wireshark" "xbuild" "zsh"
)

# Controlla che la directory sorgente esista
if [[ ! -d "$SOURCE_DIR" ]]; then
	echo "Errore: la directory $SOURCE_DIR non esiste."
	exit 1
fi

# Itera su tutte le directory in ~/.config
for dir in "$SOURCE_DIR"/*; do
    # Controlla che sia una directory
    if [[ -d "$dir" ]]; then
        # Nome del pacchetto (basename della directory)
        package_name=$(basename "$dir")
        
        # Controlla se la directory è nell'elenco delle esclusioni
        if [[ " ${EXCLUDE[@]} " =~ " $package_name " ]]; then
            echo "Saltata directory esclusa: $package_name"
            continue
        fi

        # Percorso della directory del pacchetto
        package_path="$TARGET_DIR/$package_name/.config/$package_name"

        # Controlla se la directory del pacchetto esiste
        if [[ -d "$TARGET_DIR/$package_name" || -L "$TARGET_DIR/$package_name" ]]; then
            # Se è un symlink, avvisa l'utente
            if [[ -L "$TARGET_DIR/$package_name" ]]; then
                echo "Attenzione: il pacchetto '$package_name' esiste come symlink."
            else
                echo "Attenzione: il pacchetto '$package_name' esiste come directory."
            fi
            # Chiedi conferma per sovrascrivere
            read -p "Vuoi sovrascriverlo? (s/N): " response
            if [[ "$response" != "s" && "$response" != "S" ]]; then
                echo "Saltato pacchetto: $package_name"
                continue
            else
                echo "Sovrascrivo il pacchetto: $package_name"
                rm -rf "$TARGET_DIR/$package_name"
            fi
        fi

        # Crea la struttura necessaria
        mkdir -p "$package_path"
        
        # Copia i file dal sorgente al pacchetto
        cp -r "$dir/"* "$package_path/"
        
        echo "Creato pacchetto Stow: $package_name"
    fi
done

echo "Operazione completata."