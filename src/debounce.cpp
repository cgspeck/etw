#include "Arduino.h"
#include "debounce.h"

void updateButton(unsigned int *buttonHistory, int pin) {
  *buttonHistory = *buttonHistory << 1;
  *buttonHistory |= digitalRead(pin);
}

bool isButtonPressed(unsigned int *buttonHistory) {
  bool pressed = false;

  if ((*buttonHistory & DEBOUNCE_MASK) == 0b00000111) {
    pressed = true;
    *buttonHistory = 0b11111111;
  }

  return pressed;
}

bool isButtonRelease(unsigned int *buttonHistory) {
  bool released = false;

  if ((*buttonHistory & DEBOUNCE_MASK) == 0b11000000) {
    released = true;
    *buttonHistory = 0b00000000;
  }

  return released;
}

// never see this return true!
bool isButtonDown(unsigned int *buttonHistory) {
  return (*buttonHistory == 0b11111111);
}

bool isButtonUp(unsigned int *buttonHistory) {
  return (*buttonHistory == 0b00000000);
}