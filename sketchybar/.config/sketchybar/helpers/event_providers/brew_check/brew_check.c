#include "../sketchybar.h"
#include "brew.h"
#include <signal.h>

#define DEFAULT_UPDATE_INTERVAL 900 // 15 minutes in seconds

struct brew           brew_state;
volatile sig_atomic_t terminate = 0;

void handle_signal(int sig) {
  terminate = 1;
}

int main(int argc, char** argv) {
  float update_freq;
  int   update_interval = DEFAULT_UPDATE_INTERVAL;

  // Check arguments
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\" [update_interval]\n", argv[0]);
    printf("  event-name: The sketchybar event name to trigger\n");
    printf("  event_freq: How often to check for updates (in seconds)\n");
    printf(
        "  update_interval: Optional - How often to run brew update (in seconds, default: 900)\n");
    exit(1);
  }

  // Optional update interval parameter
  if (argc >= 4) {
    if (sscanf(argv[3], "%d", &update_interval) != 1) {
      update_interval = DEFAULT_UPDATE_INTERVAL;
    }
  }

  // Setup signal handlers
  signal(SIGINT, handle_signal);
  signal(SIGTERM, handle_signal);

  // Check if brew is installed
  if (!brew_is_installed()) {
    printf("Error: Homebrew is not installed\n");
    exit(1);
  }

  // Initialize brew state
  brew_init(&brew_state);

  // Initial update
  brew_update(&brew_state);

  // Setup the event in sketchybar
  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  char trigger_message[MAX_PACKAGE_LIST_SIZE + 256];

  // Main loop
  while (!terminate) {
    // Check if we need to update brew database
    if (brew_needs_update(&brew_state, update_interval)) {
      brew_update(&brew_state);
    }

    // Prepare the event message
    snprintf(
        trigger_message, sizeof(trigger_message),
        "--trigger '%s' outdated_count='%d' pending_updates='%s'", argv[1],
        brew_state.outdated_count, brew_state.package_list ? brew_state.package_list : "");

    // Trigger the event
    sketchybar(trigger_message);

    // Wait
    usleep(update_freq * 1000000);
  }

  // Cleanup
  brew_cleanup(&brew_state);

  return 0;
}