#ifndef display_h
#define display_h

#include <Arduino.h>
#include <SPI.h>

void _maxTransfer(uint8_t address, uint8_t value, int latchPin);

void setupDisplay(int latchPin);

void _displayDigit(int value, int position, int displayDecimalPoint, int latchPin);

void _displayNegativeSign(int latchPin);

void showNumber(double number, int latchPin, bool showDecimals = true);
#endif