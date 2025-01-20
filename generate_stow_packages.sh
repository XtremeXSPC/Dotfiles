#! /bin/bash

# Directory sorgente da cui copiare le configurazioni
SOURCE_DIR="$HOME/.config"

# Directory corrente dove creare i pacchetti Stow
TARGET_DIR=$(pwd)

# Elenco delle directory da escludere
EXCLUDE=(
	".andorid" ".vscode" "crossnote" "doom" "emacs" "fzf-fit.sh" "gtk-2.0"
	"gh" "github-copilot" "jgit" "Microsoft" "thefuck" "wireshark" "xbuild"
	"zsh"
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

		# Controlla se la directory del pacchetto esiste già
		if [[ -d "$TARGET_DIR/$package_name" ]]; then
			echo "Attenzione: il pacchetto '$package_name' esiste già."
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

		echo "Pacchetto Stow creato: $package_name"
	fi
done

echo "Operazione completata."
