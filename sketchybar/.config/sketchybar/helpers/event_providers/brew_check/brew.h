#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define MAX_PACKAGE_LIST_SIZE 8192
#define MAX_CMD_SIZE 256

struct brew {
  int    outdated_count;
  char*  package_list;
  bool   update_in_progress;
  time_t last_update;
};

static inline void brew_init(struct brew* brew) {
  brew->outdated_count = 0;
  brew->package_list   = (char*)malloc(MAX_PACKAGE_LIST_SIZE);
  if (brew->package_list) {
    brew->package_list[0] = '\0';
  }
  brew->update_in_progress = false;
  brew->last_update        = 0;
}

static inline void brew_cleanup(struct brew* brew) {
  if (brew->package_list) {
    free(brew->package_list);
    brew->package_list = NULL;
  }
}

static inline bool brew_is_installed() {
  return (system("command -v brew > /dev/null 2>&1") == 0);
}

static inline bool brew_needs_update(struct brew* brew, int update_interval) {
  time_t current_time = time(NULL);
  return (current_time - brew->last_update) >= update_interval;
}

static inline void brew_update(struct brew* brew) {
  FILE* fp;
  char  line[MAX_PACKAGE_LIST_SIZE];
  int   count = 0;

  // Reset package list
  if (brew->package_list) {
    brew->package_list[0] = '\0';
  }

  // Check if update is already in progress
  if (brew->update_in_progress) {
    return;
  }

  brew->update_in_progress = true;

  // Run brew update silently to refresh package database
  system("brew update > /dev/null 2>&1");

  // Get outdated packages
  fp = popen("brew outdated --quiet", "r");
  if (fp == NULL) {
    brew->outdated_count     = 0;
    brew->update_in_progress = false;
    return;
  }

  // Read packages and build list
  while (fgets(line, sizeof(line) - 1, fp) != NULL) {
    // Remove newline
    line[strcspn(line, "\n")] = 0;

    // Add to list
    if (strlen(line) > 0) {
      if (count > 0 && brew->package_list) {
        strncat(brew->package_list, ",", MAX_PACKAGE_LIST_SIZE - strlen(brew->package_list) - 1);
      }
      if (brew->package_list) {
        strncat(brew->package_list, line, MAX_PACKAGE_LIST_SIZE - strlen(brew->package_list) - 1);
      }
      count++;
    }
  }

  // Close pipe and update count
  pclose(fp);
  brew->outdated_count     = count;
  brew->last_update        = time(NULL);
  brew->update_in_progress = false;
}