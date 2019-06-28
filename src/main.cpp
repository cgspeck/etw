// hack to make VS Code work
#ifndef ARDUINO
  #define ARDUINO 189
#endif


#include <Arduino.h>
#undef round
#include <math.h>

#include <SPI.h>
#include <Joystick.h>
#include "debounce.h"
#include "display.h"

#define JOYSTICK_ENABLE

# define ENCODER_PULSES_PER_REV 400
# define JS_VAL_MIN 0
# define JS_VAL_MAX 1023

// how many times you have to spin the elevator wheel to go from min to max
# define JS_MIN_MAX_REVS 9

// ENCODER INPUT PINS
#define  A_PHASE 2
#define  B_PHASE 3

// RESET BUTTON
#define PIN_IN_RESET 11
unsigned int inputResetButtonHistory = 0;

// ARM (A)/DISARM (B) slide switch
#define PIN_IN_ARM 12
#define PIN_IN_DISARM 13
unsigned long previousModeChanged = 0;
bool armed = true;

// DISPLAY
#define LATCH_PIN 10

// JOYSTICK
#ifdef JOYSTICK_ENABLE
  Joystick_ Joystick(
    JOYSTICK_DEFAULT_REPORT_ID, 
    JOYSTICK_TYPE_JOYSTICK,
    2,
    0,
    true, true, false,
    false, false, false,
    false, false, false, false, false
  );
#endif

int JS_MIDPOINT = round((JS_VAL_MIN + (float)JS_VAL_MAX) / 2);
int JS_AXIS_VAL;

volatile int ENCODER_VAL;
int PREVIOUS_ENCODER_VAL;
int ENCODER_AXIS_STEP;
int ENCODER_MIN_VAL;
int ENCODER_MAX_VAL;

void processPulse() {
  // stuff that figures out direction and increments or decrements the counter
  char i;
  i = digitalRead(B_PHASE);
  if (i == 1 && ENCODER_VAL > ENCODER_MIN_VAL) {
    // CCW
    ENCODER_VAL -= 1;
  } else if (ENCODER_VAL < ENCODER_MAX_VAL) {
    // CW
    ENCODER_VAL += 1;
  }
}

int scaledVal;

void updateScaledValues() {
  scaledVal = map(JS_AXIS_VAL, JS_VAL_MIN, JS_VAL_MAX, -100, 100);
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
  int jsRange = JS_VAL_MAX + abs(JS_VAL_MIN);

  // 444
  ENCODER_AXIS_STEP = ENCODER_PULSES_PER_REV / (jsRange/JS_MIN_MAX_REVS);
  // 18000
  ENCODER_MAX_VAL = (((float)JS_MIN_MAX_REVS / 2) * ENCODER_PULSES_PER_REV);
  // -18000
  ENCODER_MIN_VAL = ENCODER_MAX_VAL * -1;
  resetVals();
  pinMode(PIN_IN_RESET, INPUT_PULLUP);
  pinMode(PIN_IN_ARM, INPUT_PULLUP);
  pinMode(PIN_IN_DISARM, INPUT_PULLUP);
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

  if (ENCODER_VAL != PREVIOUS_ENCODER_VAL) {
    if (ENCODER_VAL == ENCODER_MAX_VAL || ENCODER_VAL == ENCODER_MIN_VAL) {
      JS_AXIS_VAL = (ENCODER_VAL == ENCODER_MAX_VAL) ? JS_VAL_MAX : JS_VAL_MIN;
      noInterrupts();
      PREVIOUS_ENCODER_VAL = ENCODER_VAL;
      interrupts();
      updateScaledValues();
   } else if (abs(ENCODER_VAL - PREVIOUS_ENCODER_VAL) >= ENCODER_AXIS_STEP) {
      noInterrupts();
      // reset JS_AXIS_VAL
      JS_AXIS_VAL = map(
        ENCODER_VAL,
        ENCODER_MIN_VAL,
        ENCODER_MAX_VAL,
        JS_VAL_MIN,
        JS_VAL_MAX
      );
      PREVIOUS_ENCODER_VAL = ENCODER_VAL;
      interrupts();
      updateScaledValues();
    }
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

  bool modeChanged = false;
  unsigned long currentMillis = millis();

  if (armed && !digitalRead(PIN_IN_DISARM)) {
    armed = false;
    modeChanged = true;
  } else if (!armed && !digitalRead(PIN_IN_ARM)) {
    armed = true;
    modeChanged = true;
  }

  if (modeChanged) {
    #ifndef JOYSTICK_ENABLE
      Serial.println("************************** MODE CHANGED **************************");
    #endif
    previousModeChanged = currentMillis;
    Joystick.pressButton(armed ? 0 : 1);
  } else if ((unsigned long)(currentMillis - previousModeChanged) > 1000)
  {
    Joystick.releaseButton(0);
    Joystick.releaseButton(1);
  }

  #ifdef JOYSTICK_ENABLE
    if(armed) {
      Joystick.setXAxis(JS_AXIS_VAL);
      Joystick.setYAxis(PREVIOUS_ENCODER_VAL);
    }
  #else
    Serial.print("PREVIOUS ENCODER VAL: ");
    Serial.println(PREVIOUS_ENCODER_VAL);
    Serial.print("JS_AXIS_VAL: ");
    Serial.println(JS_AXIS_VAL);
    Serial.print("SCALED VAL: ");
    Serial.println(scaledVal);
    Serial.print("ARMED: ");
    Serial.println(armed);
  #endif
  showNumber(scaledVal, LATCH_PIN);
}