#ifndef NETWORK_H
#define NETWORK_H

#include <errno.h>
#include <math.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>
#include <sys/sysctl.h>

// Array di stringhe per le unità
static const char unit_str[3][6] = {
    {" Bps"},
    {"KBps"},
    {"MBps"},
};

enum unit { UNIT_BPS, UNIT_KBPS, UNIT_MBPS };

struct network {
  uint32_t         row;
  struct ifmibdata data;
  struct timeval   tv_nm1, tv_n, tv_delta;

  int       up;   // Upload speed
  int       down; // Download speed
  enum unit up_unit, down_unit;
};

/**
 * Ottiene i dati dell'interfaccia di rete
 *
 * @param net_row Indice dell'interfaccia
 * @param data Puntatore alla struttura dati da riempire
 * @return 0 in caso di successo, -1 altrimenti
 */
[[nodiscard]] static inline int ifdata(uint32_t net_row, struct ifmibdata* data) {
  if (!data)
    return -1;

  static size_t  size          = sizeof(struct ifmibdata);
  static int32_t data_option[] = {CTL_NET,      PF_LINK, NETLINK_GENERIC,
                                  IFMIB_IFDATA, 0,       IFDATA_GENERAL};
  data_option[4]               = net_row;

  int result = sysctl(data_option, 6, data, &size, NULL, 0);
  return (result < 0) ? -1 : 0;
}

/**
 * Inizializza una struttura network
 *
 * @param net Puntatore alla struttura network da inizializzare
 * @param ifname Nome dell'interfaccia
 * @return 0 in caso di successo, -1 altrimenti
 */
[[nodiscard]] static inline int network_init(struct network* net, char* ifname) {
  if (!net || !ifname)
    return -1;

  memset(net, 0, sizeof(struct network));

  static int count_option[]  = {CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_SYSTEM, IFMIB_IFCOUNT};
  uint32_t   interface_count = 0;
  size_t     size            = sizeof(uint32_t);

  if (sysctl(count_option, 5, &interface_count, &size, NULL, 0) < 0) {
    fprintf(stderr, "Errore nell'ottenere il numero di interfacce: %s\n", strerror(errno));
    return -1;
  }

  bool interface_found = false;
  for (uint32_t i = 0; i < interface_count; i++) {
    if (ifdata(i, &net->data) < 0)
      continue;

    if (strcmp(net->data.ifmd_name, ifname) == 0) {
      net->row        = i;
      interface_found = true;
      break;
    }
  }

  if (!interface_found) {
    fprintf(stderr, "Interfaccia '%s' non trovata\n", ifname);
    return -1;
  }

  // Initialize timeval structures
  gettimeofday(&net->tv_n, NULL);
  net->tv_nm1 = net->tv_n;

  return 0;
}

/**
 * Aggiorna i dati di rete
 *
 * @param net Puntatore alla struttura network da aggiornare
 */
static inline void network_update(struct network* net) {
  if (!net)
    return;

  // Aggiorna i timestamp
  if (gettimeofday(&net->tv_n, NULL) < 0) {
    fprintf(stderr, "Errore nell'ottenere il timestamp: %s\n", strerror(errno));
    return;
  }

  timersub(&net->tv_n, &net->tv_nm1, &net->tv_delta);
  net->tv_nm1 = net->tv_n;

  // Salva i valori precedenti
  uint64_t ibytes_nm1 = net->data.ifmd_data.ifi_ibytes;
  uint64_t obytes_nm1 = net->data.ifmd_data.ifi_obytes;

  // Ottieni nuovi dati
  if (ifdata(net->row, &net->data) < 0) {
    fprintf(stderr, "Errore nell'ottenere i dati dell'interfaccia\n");
    return;
  }

  // Calcola la scala temporale
  double time_scale = (net->tv_delta.tv_sec + 1e-6 * net->tv_delta.tv_usec);

  // Verifica che il tempo sia in un range ragionevole
  static const double MIN_VALID_TIME = 1e-6;
  static const double MAX_VALID_TIME = 1e2;

  if (time_scale < MIN_VALID_TIME || time_scale > MAX_VALID_TIME) {
    return;
  }

  // Calcola le velocità in byte al secondo
  double delta_ibytes = (double)(net->data.ifmd_data.ifi_ibytes - ibytes_nm1) / time_scale;
  double delta_obytes = (double)(net->data.ifmd_data.ifi_obytes - obytes_nm1) / time_scale;

  // Evita log di valori negativi o zero
  double exponent_ibytes = (delta_ibytes > 0) ? log10(delta_ibytes) : 0;
  double exponent_obytes = (delta_obytes > 0) ? log10(delta_obytes) : 0;

  // Imposta le unità per download (incoming bytes)
  if (exponent_ibytes < 3) {
    net->down_unit = UNIT_BPS;
    net->down      = (int)delta_ibytes;
  } else if (exponent_ibytes < 6) {
    net->down_unit = UNIT_KBPS;
    net->down      = (int)(delta_ibytes / 1000.0);
  } else { // exponent_ibytes < 9
    net->down_unit = UNIT_MBPS;
    net->down      = (int)(delta_ibytes / 1000000.0);
  }

  // Imposta le unità per upload (outgoing bytes)
  if (exponent_obytes < 3) {
    net->up_unit = UNIT_BPS;
    net->up      = (int)delta_obytes;
  } else if (exponent_obytes < 6) {
    net->up_unit = UNIT_KBPS;
    net->up      = (int)(delta_obytes / 1000.0);
  } else { // exponent_obytes < 9
    net->up_unit = UNIT_MBPS;
    net->up      = (int)(delta_obytes / 1000000.0);
  }
}

#endif /* NETWORK_H */
