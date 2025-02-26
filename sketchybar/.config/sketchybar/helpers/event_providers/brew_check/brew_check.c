#include "../sketchybar.h"
#include "brew.h"
#include <limits.h>
#include <signal.h>
#include <stdarg.h>
#include <sys/time.h>

#define DEFAULT_UPDATE_INTERVAL 900 // 15 minuti in secondi
#define DEFAULT_CHECK_INTERVAL 60   // 1 minuto in secondi
#define MAX_EVENT_NAME_LENGTH 64
#define MAX_MESSAGE_LENGTH 1024

// Variabili globali
volatile sig_atomic_t terminate = 0;
brew_t                brew_state;
char                  event_name[MAX_EVENT_NAME_LENGTH] = {0};
float                 check_frequency                   = DEFAULT_CHECK_INTERVAL;
int                   update_interval                   = DEFAULT_UPDATE_INTERVAL;
bool                  verbose_mode                      = false;

// Prototipo per funzioni di aiuto
static void log_message(const char* format, ...);
static void cleanup_and_exit(int exit_code);

/**
 * Gestisce i segnali
 */
void handle_signal(int sig) {
  // Imposta il flag di terminazione e gestisci in base al segnale
  switch (sig) {
  case SIGINT:
  case SIGTERM:
    log_message("Ricevuto segnale %d, terminazione in corso...", sig);
    terminate = 1;
    break;
  case SIGHUP:
    log_message("Ricevuto SIGHUP, ricaricamento della configurazione...");
    // Qui si potrebbe ricaricare la configurazione se necessario
    break;
  default:
    log_message("Ricevuto segnale non gestito: %d", sig);
    break;
  }
}

/**
 * Funzione di aiuto per la registrazione di messaggi
 */
static void log_message(const char* format, ...) {
  if (!verbose_mode)
    return;

  va_list args;
  va_start(args, format);

  time_t     now       = time(NULL);
  struct tm* time_info = localtime(&now);

  char timestamp[20];
  strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", time_info);

  fprintf(stderr, "[%s] brew_check: ", timestamp);
  vfprintf(stderr, format, args);
  fprintf(stderr, "\n");

  va_end(args);
}

/**
 * Funzione ausiliaria per verificare se l'aggiornamento è necessario
 * considerando anche la responsività del sistema
 */
static bool should_update_now(brew_t* brew) {
  // Check basato sul tempo trascorso
  if (brew_needs_update(brew, update_interval)) {
    // Potremmo aggiungere logica per evitare di aggiornare durante alto carico di sistema
    // Ad esempio, controllando il carico medio con getloadavg()
    double load[1];
    if (getloadavg(load, 1) == 1 && load[0] > 2.0) {
      log_message("Sistema sotto carico (%.2f), rinvio aggiornamento", load[0]);
      return false;
    }
    return true;
  }
  return false;
}

/**
 * Esegue il controllo e notifica sketchybar
 */
static void check_and_notify(void) {
  // Verifica se è necessario aggiornare
  if (should_update_now(&brew_state)) {
    log_message("Aggiornamento database brew in corso...");
    brew_error_t result = brew_update(&brew_state);

    if (result != BREW_SUCCESS) {
      log_message("Errore durante l'aggiornamento: %s", brew_error_string(result));
    } else {
      log_message("Trovati %d pacchetti obsoleti", brew_state.outdated_count);
    }
  }

  // Prepara e invia la notifica a sketchybar
  char trigger_message[MAX_MESSAGE_LENGTH];
  int  message_len = snprintf(
      trigger_message, sizeof(trigger_message),
      "--trigger '%s' outdated_count='%d' pending_updates='%s' last_check='%ld' error='%s'",
      event_name, brew_state.outdated_count, brew_state.package_list ? brew_state.package_list : "",
      (long)brew_state.last_check, brew_error_string(brew_state.last_error));

  // Verifica overflow del buffer
  if (message_len >= (int)sizeof(trigger_message)) {
    log_message("Avviso: messaggio di trigger troncato");
  }

  // Invia il comando a sketchybar
  sketchybar(trigger_message);
  // Nota: sketchybar() è void, quindi non possiamo verificare eventuali errori
}

/**
 * Pulisce le risorse e termina il programma
 */
static void cleanup_and_exit(int exit_code) {
  log_message("Pulizia risorse in corso...");
  brew_cleanup(&brew_state);
  exit(exit_code);
}

/**
 * Mostra l'uso del programma
 */
static void show_usage(const char* program_name) {
  printf("Uso: %s \"<event-name>\" \"<event_freq>\" [update_interval] [--verbose]\n", program_name);
  printf("  event-name: Nome dell'evento sketchybar da attivare\n");
  printf("  event_freq: Frequenza di controllo aggiornamenti (in secondi)\n");
  printf("  update_interval: Opzionale - Frequenza di esecuzione brew update (in secondi, default: "
         "900)\n");
  printf("  --verbose: Opzionale - Abilita messaggi dettagliati\n");
}

/**
 * Funzione principale
 */
int main(int argc, char** argv) {
  // Controlla argomenti minimi
  if (argc < 3) {
    show_usage(argv[0]);
    return 1;
  }

  // Analizza argomenti aggiuntivi e opzioni
  strncpy(event_name, argv[1], MAX_EVENT_NAME_LENGTH - 1);
  event_name[MAX_EVENT_NAME_LENGTH - 1] = '\0';

  // Conversione frequenza controllo
  if (sscanf(argv[2], "%f", &check_frequency) != 1 || check_frequency <= 0) {
    fprintf(stderr, "Errore: frequenza di controllo non valida\n");
    show_usage(argv[0]);
    return 1;
  }

  // Leggi argomenti opzionali
  for (int i = 3; i < argc; i++) {
    if (strcmp(argv[i], "--verbose") == 0) {
      verbose_mode = true;
    } else if (i == 3 && argv[i][0] != '-') {
      // Assume che il terzo argomento sia l'intervallo di aggiornamento se non è un'opzione
      if (sscanf(argv[i], "%d", &update_interval) != 1 || update_interval <= 0) {
        fprintf(stderr, "Avviso: intervallo di aggiornamento non valido, uso valore predefinito\n");
        update_interval = DEFAULT_UPDATE_INTERVAL;
      }
    }
  }

  log_message(
      "Avvio con evento '%s', frequenza %.2fs, intervallo di aggiornamento %ds", event_name,
      check_frequency, update_interval);

  // Configura gestori di segnali
  struct sigaction sa;
  memset(&sa, 0, sizeof(sa));
  sa.sa_handler = handle_signal;
  sigemptyset(&sa.sa_mask);

  sigaction(SIGINT, &sa, NULL);
  sigaction(SIGTERM, &sa, NULL);
  sigaction(SIGHUP, &sa, NULL);

  // Verifica se brew è installato
  if (!brew_is_installed()) {
    fprintf(stderr, "Errore: Homebrew non è installato\n");
    return 1;
  }

  // Inizializza lo stato brew
  if (brew_init(&brew_state) != BREW_SUCCESS) {
    fprintf(stderr, "Errore: Impossibile inizializzare lo stato brew\n");
    return 1;
  }

  // Eseguiamo un aggiornamento iniziale
  log_message("Esecuzione aggiornamento iniziale...");
  brew_error_t update_result = brew_update(&brew_state);
  if (update_result != BREW_SUCCESS) {
    log_message("Errore durante l'aggiornamento iniziale: %s", brew_error_string(update_result));
  }

  // Configuriamo l'evento in sketchybar
  char event_message[MAX_MESSAGE_LENGTH];
  snprintf(event_message, sizeof(event_message), "--add event '%s'", event_name);

  // Configurazione dell'evento in sketchybar (funzione void, non restituisce codici di errore)
  sketchybar(event_message);

  // Notifichiamo subito lo stato iniziale
  check_and_notify();

  // Calcolo del numero di microsecondi per il sonno
  unsigned long sleep_microseconds = (unsigned long)(check_frequency * 1000000);
  if (sleep_microseconds > ULONG_MAX / 2) {
    log_message("Avviso: intervallo troppo grande, limitato");
    sleep_microseconds = ULONG_MAX / 2;
  }

  // Loop principale
  log_message("Entro nel loop principale");
  while (!terminate) {
    // Esegui controllo e notifica
    check_and_notify();

    // Attesa con gestione dei segnali
    unsigned int remaining = sleep_microseconds;
    while (remaining > 0 && !terminate) {
      // Attesa a blocchi più piccoli per reattività ai segnali
      unsigned int sleep_chunk = (remaining > 500000) ? 500000 : remaining;
      usleep(sleep_chunk);
      remaining -= sleep_chunk;
    }
  }

  // Pulizia e uscita
  log_message("Terminazione regolare");
  cleanup_and_exit(0);

  // Mai raggiunto
  return 0;
}