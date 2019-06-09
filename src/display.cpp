#include <Arduino.h>
#include <SPI.h>
#include "display.h"

void _maxTransfer(uint8_t address, uint8_t value, int latchPin) {

  // Ensure LOAD/CS is LOW
  digitalWrite(latchPin, LOW);

  // Send the register address
  SPI.transfer(address);

  // Send the value
  SPI.transfer(value);

  // Tell chip to load in data
  digitalWrite(latchPin, HIGH);
}

void setupDisplay(int latchPin) {
  // All LED segments should light up
  _maxTransfer(0xFF, 0x80, latchPin);
  delay(1000);
  _maxTransfer(0xFF, 0x00, latchPin);
  // Enable mode B
  _maxTransfer(0x09, 0xFF, latchPin);
  // Use lowest intensity
  _maxTransfer(0x0A, 0x00, latchPin); 
  // Only scan one digit
  // _maxTransfer(0x0B, 0x07, latchPin);
  // Turn on chip
  _maxTransfer(0x0C, 0x01, latchPin);
  delayMicroseconds(100);
}

void _displayDigit(int value, int position, int displayDecimalPoint, int latchPin) {
  int valueByte = 0;
  int positionByte = 0;
  switch (value) {
    case 0:valueByte = 192;break;
    case 1:valueByte = 249;break;
    case 2:valueByte = 164;break;
    case 3:valueByte = 176;break;
    case 4:valueByte = 153;break;
    case 5:valueByte = 146;break;
    case 6:valueByte = 130;break;
    case 7:valueByte = 248;break;
    case 8:valueByte = 128;break;
    case 9:valueByte = 144;break;
    default: valueByte = 255;break;
  };

  switch (position) {
    case 1:positionByte = 1;break;
    case 2:positionByte = 2;break;
    case 3:positionByte = 4;break;
    case 4:positionByte = 8;break;
    case 5:positionByte = 16;break;
    case 6:positionByte = 32;break;
    case 7:positionByte = 64;break;
    case 8:positionByte = 128;break;
    default: positionByte = 0;break;
  };

  if (displayDecimalPoint == 1) {
    valueByte = valueByte + 128;
  };
  _maxTransfer(positionByte, valueByte, latchPin);
}

void _displayNegativeSign(int latchPin) {
  _maxTransfer(1, 191, latchPin);
}

void showNumber(double number, int latchPin, bool showDecimals) {
  long num = number;

  if(num < 0) {
    _displayNegativeSign(latchPin);
    num = num * -1;
  }

  int _showDec [8];
  for (int x = 0; x < 8; x++) {
    _showDec[x] = 0;
  }

  if (num  < 1000000 && showDecimals){
    num = num*100;
    _showDec[6]=1;
    _showDec[7]=0;
  }

  int digits [8];
  digits[1] = (num/10000000)%10;
  digits[2] = (num/1000000)%10;
  digits[3] = (num/100000)%10;
  digits[4] = (num/10000)%10;
  digits[5] = (num/1000)%10;
  digits[6] = (num/100)%10;
  digits[7] = (num/10)%10;
  digits[8] = (num/1)%10;

  if (showDecimals) {
    int dectest = 0;
    for (int x = 1; x<8; x++) {
      if ((dectest == 0) && (digits[x] == 0)) {
        digits[x] = 11;
      } else {
        dectest = 1;
      }
    }
  }

  _displayDigit(digits[1],1,_showDec[1], latchPin);
  _displayDigit(digits[2],2,_showDec[2], latchPin);
  _displayDigit(digits[3],3,_showDec[3], latchPin);
  _displayDigit(digits[4],4,_showDec[4], latchPin);
  _displayDigit(digits[5],5,_showDec[5], latchPin);
  _displayDigit(digits[6],6,_showDec[6], latchPin);
  _displayDigit(digits[7],7,_showDec[7], latchPin);
  _displayDigit(digits[8],8,_showDec[8], latchPin);
}
