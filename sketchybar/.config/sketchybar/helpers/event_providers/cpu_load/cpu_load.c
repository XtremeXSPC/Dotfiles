#include "../sketchybar.h"
#include "cpu.h"
#include <errno.h>
#include <stdlib.h>
#include <string.h>

static const int MAX_EVENT_MESSAGE_LENGTH   = 512;
static const int MAX_TRIGGER_MESSAGE_LENGTH = 512;

/**
 * Mostra le istruzioni per l'uso del programma
 */
static void show_usage(const char* program_name) {
  if (!program_name)
    program_name = "cpu_load";
  printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", program_name);
}

int main(int argc, char** argv) {
  float update_freq;

  // Verifica degli argomenti
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1) || update_freq <= 0) {
    show_usage(argv[0]);
    return 1;
  }

  // Disattiva il segnale di allarme
  if (alarm(0) == (unsigned int)-1) {
    fprintf(stderr, "Errore durante la disattivazione dell'allarme: %s\n", strerror(errno));
    // Non è un errore critico, possiamo continuare
  }

  // Inizializza la struttura CPU
  struct cpu cpu;
  cpu_init(&cpu);

  // Setup the event in sketchybar
  char event_message[MAX_EVENT_MESSAGE_LENGTH];
  int  msg_len = snprintf(event_message, sizeof(event_message), "--add event '%s'", argv[1]);

  if (msg_len < 0 || msg_len >= (int)sizeof(event_message)) {
    fprintf(stderr, "Errore durante la formattazione del messaggio evento\n");
    return 1;
  }

  sketchybar(event_message);

  // Prepara il buffer per il messaggio di trigger
  char trigger_message[MAX_TRIGGER_MESSAGE_LENGTH];

  // Loop principale
  while (true) {
    // Aggiorna le informazioni CPU
    cpu_update(&cpu);

    // Prepara il messaggio di evento
    int trigger_len = snprintf(
        trigger_message, sizeof(trigger_message),
        "--trigger '%s' user_load='%d' sys_load='%02d' total_load='%02d'", argv[1], cpu.user_load,
        cpu.sys_load, cpu.total_load);

    if (trigger_len < 0 || trigger_len >= (int)sizeof(trigger_message)) {
      fprintf(stderr, "Errore o troncamento durante la formattazione del messaggio trigger\n");
      // Continuiamo comunque l'esecuzione
    }

    // Invia il trigger a sketchybar
    sketchybar(trigger_message);

    // Attesa per il prossimo aggiornamento
    // Verifica che il valore non sia troppo grande o negativo
    if (update_freq <= 0 || update_freq > 3600) {
      fprintf(stderr, "Frequenza di aggiornamento non valida (%f), uso 1 secondo\n", update_freq);
      update_freq = 1.0;
    }

    unsigned long sleep_time = (unsigned long)(update_freq * 1000000);
    usleep(sleep_time);
  }

  // Mai raggiunto, ma il compilatore potrebbe avvisare senza return
  return 0;
}
