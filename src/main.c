#include <Arduino.h>

# define ENCODER_PULSES_PER_REV 4000
# define JS_VAL_MIN 0
# define JS_VAL_MAX 1023
# define JS_MIN_MAX_REVS 9
// INPUT PINS
#define  A_PHASE 2
#define  B_PHASE 3

int JS_MIDPOINT = (JS_VAL_MIN + JS_VAL_MAX) / 2;
int JS_RANGE;

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
  if (i == 1 && ENCODER_VAL < ENCODER_MAX_VAL) {
    // CCW
    ENCODER_VAL += 1;
  } else if (ENCODER_VAL > ENCODER_MIN_VAL) {
    // CW
    ENCODER_VAL += 1;
  }
}


void setup() {
  JS_RANGE = JS_VAL_MAX + abs(JS_VAL_MIN);
  ENCODER_AXIS_STEP = ENCODER_PULSES_PER_REV / (JS_RANGE/JS_MIN_MAX_REVS);
  ENCODER_MAX_VAL = ((JS_MIN_MAX_REVS / 2) * ENCODER_PULSES_PER_REV);
  ENCODER_MIN_VAL = ENCODER_MAX_VAL * -1;
  resetVals();
  pinMode(A_PHASE, INPUT);
  pinMode(B_PHASE, INPUT);
  attachInterrupt(digitalPinToInterrupt(A_PHASE), processPulse, RISING);
}


void resetVals() {
  JS_AXIS_VAL = JS_MIDPOINT;
  ENCODER_VAL = 0;
  PREVIOUS_ENCODER_VAL = 0;
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
  }
}