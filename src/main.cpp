// hack to make VS Code work
#ifndef ARDUINO
  #define ARDUINO 189
#endif

#include <Arduino.h>
#include <SPI.h>
#include <Joystick.h>
#include "debounce.h"
#include "display.h"

//#define JOYSTICK_ENABLE

# define ENCODER_PULSES_PER_REV 4000
# define JS_VAL_MIN 0
# define JS_VAL_MAX 1023
# define JS_MIN_MAX_REVS 9
// ENCODER INPUT PINS
#define  A_PHASE 2
#define  B_PHASE 3

// RESET BUTTON
#define PIN_IN_RESET 13
unsigned int inputResetButtonHistory = 0;

// DISPLAY
#define LATCH_PIN 10

// JOYSTICK
#ifdef JOYSTICK_ENABLE
  Joystick_ Joystick(
    JOYSTICK_DEFAULT_REPORT_ID, 
    JOYSTICK_TYPE_JOYSTICK,
    0,
    0,
    true, true, false,
    false, false, false,
    false, false, false, false, false
  );
#endif

int JS_MIDPOINT = (JS_VAL_MIN + JS_VAL_MAX) / 2;
int JS_RANGE;
int JS_AXIS_VAL;

const int transpositionFactor = 0 - JS_MIDPOINT;
const int transposedMin = JS_VAL_MIN - transpositionFactor;
const int transposedMax = JS_VAL_MAX - transpositionFactor;

volatile int ENCODER_VAL;
int PREVIOUS_ENCODER_VAL;
int ENCODER_AXIS_STEP;
int ENCODER_MIN_VAL;
int ENCODER_MAX_VAL;

void processPulse() {
  // stuff that figures out direction and increments or decrements the counter
  char i;
  i = digitalRead(B_PHASE);
  if (i == 1 && ENCODER_VAL < ENCODER_MAX_VAL) {
    // CCW
    ENCODER_VAL += 1;
  } else if (ENCODER_VAL > ENCODER_MIN_VAL) {
    // CW
    ENCODER_VAL += 1;
  }
}

int scaledVal;

void updateScaledValues() {
  // transpose JS vals around 0
  int transposedVal = JS_AXIS_VAL - transpositionFactor;
  // now scale it
  scaledVal = (transposedVal / transposedMax) * 100;
}

void resetVals() {
  JS_AXIS_VAL = JS_MIDPOINT;
  ENCODER_VAL = 0;
  PREVIOUS_ENCODER_VAL = 0;
  #ifdef JOYSTICK_ENABLE
    Joystick.setXAxis(JS_AXIS_VAL);
    Joystick.setYAxis(PREVIOUS_ENCODER_VAL);
  #endif
  updateScaledValues();
}

void setup() {
  JS_RANGE = JS_VAL_MAX + abs(JS_VAL_MIN);
  ENCODER_AXIS_STEP = ENCODER_PULSES_PER_REV / (JS_RANGE/JS_MIN_MAX_REVS);
  ENCODER_MAX_VAL = ((JS_MIN_MAX_REVS / 2) * ENCODER_PULSES_PER_REV);
  ENCODER_MIN_VAL = ENCODER_MAX_VAL * -1;
  resetVals();
  pinMode(PIN_IN_RESET, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIN_IN_RESET), resetVals, RISING);
  pinMode(A_PHASE, INPUT);
  pinMode(B_PHASE, INPUT);
  attachInterrupt(digitalPinToInterrupt(A_PHASE), processPulse, RISING);

  #ifdef JOYSTICK_ENABLE
    Joystick.begin();
    Joystick.setXAxisRange(JS_VAL_MIN, JS_VAL_MAX);
    Joystick.setYAxisRange(ENCODER_MIN_VAL, ENCODER_MAX_VAL);
  #else
    Serial.begin(9600);
  #endif

  pinMode(LATCH_PIN,OUTPUT);
  SPI.setBitOrder(MSBFIRST);
  SPI.begin();
  setupDisplay(LATCH_PIN);
}

void loop() {
  if (abs(ENCODER_VAL - PREVIOUS_ENCODER_VAL) >= ENCODER_AXIS_STEP) {
    noInterrupts();
    // increase/decrease axis val
    if (ENCODER_VAL > PREVIOUS_ENCODER_VAL) {
      JS_AXIS_VAL += 1;
    } else {
      JS_AXIS_VAL -= 1;
    }
    PREVIOUS_ENCODER_VAL = ENCODER_VAL;
    interrupts();
    updateScaledValues();
  }

  updateButton(&inputResetButtonHistory, PIN_IN_RESET);

  if (isButtonPressed(&inputResetButtonHistory)) {
    /* Reset button has just been released.
      
      Names are confusing, logic is flipped because of internal pull up resistor
    */
    #ifndef JOYSTICK_ENABLE
      Serial.println("************************** RESET **************************");
    #endif
    resetVals();
  }

  #ifdef JOYSTICK_ENABLE
    Joystick.setXAxis(JS_AXIS_VAL);
    Joystick.setYAxis(PREVIOUS_ENCODER_VAL);
  #else
    Serial.print("PREVIOUS ENCODER VAL: ");
    Serial.println(PREVIOUS_ENCODER_VAL);
    Serial.print("JS_AXIS_VAL: ");
    Serial.println(JS_AXIS_VAL);
    Serial.print("SCALED BAL: ");
    Serial.println(scaledVal);
  #endif
  showNumber(scaledVal, LATCH_PIN);
}