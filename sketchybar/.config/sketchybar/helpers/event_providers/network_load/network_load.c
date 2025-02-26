#include "../sketchybar.h"
#include "network.h"
#include <errno.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const int MAX_MESSAGE_LENGTH = 512;

/**
 * Mostra le istruzioni per l'uso del programma
 */
static void show_usage(const char* program_name) {
  if (!program_name)
    program_name = "network_load";
  printf("Usage: %s \"<interface>\" \"<event-name>\" \"<event_freq>\"\n", program_name);
}

/**
 * Gestisce eventuali segnali
 */
static void signal_handler(int signum) {
  fprintf(stderr, "Ricevuto segnale %d, uscita in corso...\n", signum);
  exit(signum);
}

int main(int argc, char** argv) {
  float update_freq;

  // Verifica argomenti
  if (argc < 4 || (sscanf(argv[3], "%f", &update_freq) != 1) || update_freq <= 0) {
    show_usage(argv[0]);
    exit(1);
  }

  // Disattiva il segnale di allarme e imposta handler di segnali
  if (alarm(0) == (unsigned int)-1) {
    fprintf(stderr, "Avviso: errore nella disattivazione dell'allarme: %s\n", strerror(errno));
    // Non è un errore critico, possiamo continuare
  }

  // Imposta gestione dei segnali per terminazione pulita
  struct sigaction sa = {0};
  sa.sa_handler       = signal_handler;
  sigemptyset(&sa.sa_mask);

  if (sigaction(SIGINT, &sa, NULL) < 0 || sigaction(SIGTERM, &sa, NULL) < 0) {
    fprintf(stderr, "Avviso: impossibile impostare handler di segnali: %s\n", strerror(errno));
    // Non è un errore critico, possiamo continuare
  }

  // Setup the event in sketchybar
  char event_message[MAX_MESSAGE_LENGTH];
  int  msg_len = snprintf(event_message, sizeof(event_message), "--add event '%s'", argv[2]);

  if (msg_len < 0 || msg_len >= (int)sizeof(event_message)) {
    fprintf(stderr, "Errore durante la formattazione del messaggio evento\n");
    return 1;
  }

  sketchybar(event_message);

  // Inizializza la struttura network
  struct network network;
  if (network_init(&network, argv[1]) != 0) {
    fprintf(stderr, "Errore: impossibile inizializzare l'interfaccia di rete '%s'\n", argv[1]);
    return 1;
  }

  // Buffer per il messaggio di trigger
  char trigger_message[MAX_MESSAGE_LENGTH];

  // Verifica che il valore della frequenza sia in un range ragionevole
  if (update_freq < 0.1 || update_freq > 3600) {
    fprintf(stderr, "Frequenza di aggiornamento non valida (%f), uso 1 secondo\n", update_freq);
    update_freq = 1.0;
  }

  unsigned long sleep_microseconds = (unsigned long)(update_freq * 1000000);

  // Loop principale
  for (;;) {
    // Aggiorna le informazioni di rete
    network_update(&network);

    // Prepara il messaggio di evento
    int trigger_len = snprintf(
        trigger_message, sizeof(trigger_message),
        "--trigger '%s' upload='%03d%s' download='%03d%s'", argv[2], network.up,
        unit_str[network.up_unit], network.down, unit_str[network.down_unit]);

    if (trigger_len < 0 || trigger_len >= (int)sizeof(trigger_message)) {
      fprintf(stderr, "Errore o troncamento durante la formattazione del messaggio trigger\n");
      // Continuiamo comunque l'esecuzione
    }

    // Invia il trigger a sketchybar
    sketchybar(trigger_message);

    // Attesa per il prossimo aggiornamento
    usleep(sleep_microseconds);
  }

  // Mai raggiunto
  return 0;
}
