#ifndef BREW_H
#define BREW_H

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

// Dimensioni buffer più accurate e gestibili
static const int BREW_MAX_PACKAGE_NAME    = 128;
static const int BREW_INITIAL_BUFFER_SIZE = 1024;
static const int BREW_MAX_BUFFER_SIZE     = 16384;
static const int BREW_CMD_SIZE            = 512;

// Codici di errore
typedef enum {
  BREW_SUCCESS = 0,
  BREW_ERROR_NOT_INSTALLED,
  BREW_ERROR_UPDATE_IN_PROGRESS,
  BREW_ERROR_MEMORY_ALLOCATION,
  BREW_ERROR_COMMAND_EXECUTION,
  BREW_ERROR_INVALID_PARAMETER,
  BREW_ERROR_BUFFER_OVERFLOW
} brew_error_t;

// Struttura rivista con più informazioni utili
typedef struct brew {
  int          outdated_count;
  char*        package_list;
  size_t       package_list_size; // Dimensione attuale del buffer
  size_t       package_list_used; // Spazio utilizzato nel buffer
  bool         update_in_progress;
  time_t       last_update;
  time_t       last_check; // Quando abbiamo verificato l'ultima volta
  brew_error_t last_error; // Ultimo errore verificatosi
} brew_t;

/**
 * Inizializza una struttura brew
 *
 * @param brew Puntatore alla struttura brew da inizializzare
 * @return BREW_SUCCESS se l'inizializzazione ha avuto successo, codice di errore altrimenti
 */
[[nodiscard]] static inline brew_error_t brew_init(brew_t* brew) {
  if (!brew)
    return BREW_ERROR_INVALID_PARAMETER;

  brew->outdated_count     = 0;
  brew->update_in_progress = false;
  brew->last_update        = 0;
  brew->last_check         = 0;
  brew->last_error         = BREW_SUCCESS;
  brew->package_list_size  = BREW_INITIAL_BUFFER_SIZE;
  brew->package_list_used  = 0;

  brew->package_list = (char*)malloc(brew->package_list_size);
  if (!brew->package_list) {
    brew->last_error = BREW_ERROR_MEMORY_ALLOCATION;
    return BREW_ERROR_MEMORY_ALLOCATION;
  }

  brew->package_list[0] = '\0';
  return BREW_SUCCESS;
}

/**
 * Libera la memoria allocata nella struttura brew
 *
 * @param brew Puntatore alla struttura brew da liberare
 */
static inline void brew_cleanup(brew_t* brew) {
  if (!brew)
    return;

  if (brew->package_list) {
    free(brew->package_list);
    brew->package_list = NULL;
  }

  brew->package_list_size = 0;
  brew->package_list_used = 0;
}

/**
 * Verifica se Homebrew è installato
 *
 * @return true se Homebrew è installato, false altrimenti
 */
[[nodiscard]] static inline bool brew_is_installed(void) {
  FILE* fp = popen("command -v brew 2>/dev/null", "r");
  if (!fp)
    return false;

  char path[BREW_CMD_SIZE] = {0};
  bool result              = (fgets(path, sizeof(path), fp) != NULL);
  pclose(fp);

  return result;
}

/**
 * Verifica se è necessario aggiornare il database Homebrew
 *
 * @param brew Puntatore alla struttura brew
 * @param update_interval Intervallo minimo tra gli aggiornamenti in secondi
 * @return true se è necessario un aggiornamento, false altrimenti
 */
[[nodiscard]] static inline bool brew_needs_update(const brew_t* brew, int update_interval) {
  if (!brew)
    return false;

  time_t current_time = time(NULL);
  if (current_time == (time_t)-1) // Controllo errore di time()
    return false;

  return (current_time - brew->last_update) >= update_interval;
}

/**
 * Funzione interna per ridimensionare il buffer della lista pacchetti
 *
 * @param brew Puntatore alla struttura brew
 * @param needed_size Dimensione necessaria
 * @return BREW_SUCCESS se il ridimensionamento ha avuto successo, codice di errore altrimenti
 */
[[nodiscard]] static inline brew_error_t brew_resize_buffer(brew_t* brew, size_t needed_size) {
  if (!brew || !brew->package_list)
    return BREW_ERROR_INVALID_PARAMETER;

  if (needed_size >= BREW_MAX_BUFFER_SIZE)
    return BREW_ERROR_BUFFER_OVERFLOW;

  // Calcola la nuova dimensione (raddoppia fino alla dimensione necessaria)
  size_t new_size = brew->package_list_size;
  while (new_size < needed_size) {
    if (new_size > BREW_MAX_BUFFER_SIZE / 2) {
      // Evita overflow moltiplicando
      new_size = BREW_MAX_BUFFER_SIZE;
      break;
    }
    new_size *= 2;
  }

  // Se la dimensione attuale è sufficiente, non fare nulla
  if (new_size == brew->package_list_size) {
    return BREW_SUCCESS;
  }

  // Ridimensiona il buffer
  char* new_buffer = (char*)realloc(brew->package_list, new_size);
  if (!new_buffer) {
    return BREW_ERROR_MEMORY_ALLOCATION;
  }

  brew->package_list      = new_buffer;
  brew->package_list_size = new_size;
  return BREW_SUCCESS;
}

/**
 * Aggiorna il database Homebrew e recupera i pacchetti obsoleti
 *
 * @param brew Puntatore alla struttura brew
 * @return BREW_SUCCESS se l'aggiornamento ha avuto successo, codice di errore altrimenti
 */
[[nodiscard]] static inline brew_error_t brew_update(brew_t* brew) {
  if (!brew)
    return BREW_ERROR_INVALID_PARAMETER;

  // Reset della lista pacchetti
  if (brew->package_list) {
    brew->package_list[0]   = '\0';
    brew->package_list_used = 0;
  } else {
    return BREW_ERROR_MEMORY_ALLOCATION;
  }

  // Verifica se l'aggiornamento è già in corso
  if (brew->update_in_progress) {
    return BREW_ERROR_UPDATE_IN_PROGRESS;
  }

  brew->update_in_progress = true;
  brew->last_check         = time(NULL);
  if (brew->last_check == (time_t)-1) { // Controllo errore di time()
    brew->update_in_progress = false;
    brew->last_error         = BREW_ERROR_COMMAND_EXECUTION;
    return BREW_ERROR_COMMAND_EXECUTION;
  }

  // Esegui brew update silenziosamente per aggiornare il database
  int update_result = system("brew update > /dev/null 2>&1");
  if (update_result != 0) {
    brew->update_in_progress = false;
    brew->last_error         = BREW_ERROR_COMMAND_EXECUTION;
    return BREW_ERROR_COMMAND_EXECUTION;
  }

  // Ottieni pacchetti obsoleti
  FILE* fp = popen("brew outdated --quiet", "r");
  if (!fp) {
    brew->outdated_count     = 0;
    brew->update_in_progress = false;
    brew->last_error         = BREW_ERROR_COMMAND_EXECUTION;
    return BREW_ERROR_COMMAND_EXECUTION;
  }

  // Leggi i pacchetti e costruisci la lista
  char package[BREW_MAX_PACKAGE_NAME];
  int  count = 0;

  while (fgets(package, sizeof(package) - 1, fp) != NULL) {
    // Rimuovi il newline
    package[strcspn(package, "\n")] = 0;

    // Se non è una stringa vuota, aggiungila alla lista
    if (package[0] != '\0') {
      // Lunghezza necessaria = lunghezza attuale + lunghezza pacchetto + virgola + null terminator
      size_t needed_len = brew->package_list_used + strlen(package) + 2;

      // Ridimensiona il buffer se necessario
      if (needed_len >= brew->package_list_size) {
        brew_error_t resize_result = brew_resize_buffer(brew, needed_len);
        if (resize_result != BREW_SUCCESS) {
          pclose(fp);
          brew->update_in_progress = false;
          brew->last_error         = resize_result;
          return resize_result;
        }
      }

      // Aggiungi virgola se non è il primo elemento
      if (count > 0) {
        size_t remaining = brew->package_list_size - brew->package_list_used - 1;
        if (strncat(brew->package_list, ",", remaining) == NULL) {
          pclose(fp);
          brew->update_in_progress = false;
          brew->last_error         = BREW_ERROR_BUFFER_OVERFLOW;
          return BREW_ERROR_BUFFER_OVERFLOW;
        }
        brew->package_list_used += 1;
      }

      // Aggiungi il pacchetto alla lista
      size_t remaining = brew->package_list_size - brew->package_list_used - 1;
      if (strncat(brew->package_list, package, remaining) == NULL) {
        pclose(fp);
        brew->update_in_progress = false;
        brew->last_error         = BREW_ERROR_BUFFER_OVERFLOW;
        return BREW_ERROR_BUFFER_OVERFLOW;
      }
      brew->package_list_used += strlen(package);

      count++;
    }
  }

  // Chiudi il pipe e aggiorna il conteggio
  pclose(fp);
  brew->outdated_count = count;
  brew->last_update    = time(NULL);
  if (brew->last_update == (time_t)-1) { // Controllo errore di time()
    brew->update_in_progress = false;
    brew->last_error         = BREW_ERROR_COMMAND_EXECUTION;
    return BREW_ERROR_COMMAND_EXECUTION;
  }

  brew->update_in_progress = false;
  return BREW_SUCCESS;
}

/**
 * Ottiene il messaggio di errore corrispondente a un codice di errore
 *
 * @param error Codice di errore
 * @return Stringa con il messaggio di errore
 */
[[nodiscard]] static inline const char* brew_error_string(brew_error_t error) {
  switch (error) {
  case BREW_SUCCESS:
    return "Nessun errore";
  case BREW_ERROR_NOT_INSTALLED:
    return "Homebrew non è installato";
  case BREW_ERROR_UPDATE_IN_PROGRESS:
    return "Aggiornamento già in corso";
  case BREW_ERROR_MEMORY_ALLOCATION:
    return "Errore di allocazione memoria";
  case BREW_ERROR_COMMAND_EXECUTION:
    return "Errore nell'esecuzione del comando";
  case BREW_ERROR_INVALID_PARAMETER:
    return "Parametro non valido";
  case BREW_ERROR_BUFFER_OVERFLOW:
    return "Overflow del buffer";
  default:
    return "Errore sconosciuto";
  }
}

#endif /* BREW_H */
