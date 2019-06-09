#ifndef debounce_h
#define debounce_h

#include "Arduino.h"

// implementation of https://hackaday.com/2015/12/10/embed-with-elliot-debounce-your-noisy-buttons-part-ii/
#define DEBOUNCE_MASK 0b11000111

void updateButton(unsigned int *buttonHistory, int pin);

// true on rising edge
bool isButtonPressed(unsigned int *buttonHistory);

// true on flling edge
bool isButtonRelease(unsigned int *buttonHistory);

// all 1s
bool isButtonDown(unsigned int *buttonHistory);
// all 0s
bool isButtonUp(unsigned int *buttonHistory);
#endif

