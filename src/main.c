#include <Joystick.h>
#include "LedControl.h"

# define ENCODER_PULSES_PER_REV 4000
# define JS_VAL_MIN 0
# define JS_VAL_MAX 1023
# define JS_MIN_MAX_REVS 9
// ENCODER INPUT PINS
#define  A_PHASE 2
#define  B_PHASE 3

// RESET BUTTON
#define PIN_IN_RESET 4

// DISPLAY

// display
LedControl lc1=LedControl(12,11,10,1); 

// JOYSTICK
Joystick_ Joystick(
  JOYSTICK_DEFAULT_REPORT_ID, 
  JOYSTICK_TYPE_JOYSTICK,
  0,
  0,
  true, true, false,
  false, false, false,
  false, false, false, false, false
);

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

void resetVals() {
  JS_AXIS_VAL = JS_MIDPOINT;
  ENCODER_VAL = 0;
  PREVIOUS_ENCODER_VAL = 0;
  Joystick.setXAxis(JS_AXIS_VAL);
  Joystick.setYAxis(PREVIOUS_ENCODER_VAL);
  updateDisplay();
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
  Joystick.begin();
  Joystick.setXAxisRange(JS_VAL_MIN, JS_VAL_MAX);
  Joystick.setYAxisRange(ENCODER_MIN_VAL, ENCODER_MAX_VAL);

  for(int index=0;index<lc1.getDeviceCount();index++) {
    lc1.shutdown(index,false);
    lc1.setIntensity(index, 8);
  }
}

void printNumber(int v) {  
    int ones;  
    int tens;  
    int hundreds; 

    boolean negative=false;

    if(v < -999 || v > 999)  
        return;  
    if(v<0) {  
        negative=true; 
        v=v*-1;  
    }
    ones=v%10;  
    v=v/10;  
    tens=v%10;  
    v=v/10; hundreds=v;  
    if(negative) {  
        //print character '-' in the leftmost column  
        lc1.setChar(0,3,'-',false);  } 
    else {
        //print a blank in the sign column  
        lc1.setChar(0,3,' ',false);  
    }  
    //Now print the number digit by digit 
    lc1.setDigit(0,2,(byte)hundreds,false);
    lc1.setDigit(0,1,(byte)tens,false); 
    lc1.setDigit(0,0,(byte)ones,false); 
}

void updateDisplay() {
  // transpose JS vals around 0
  int transposedVal = JS_AXIS_VAL - transpositionFactor;
  // now scale it
  int scaledVal = (transposedVal / transposedMax) * 100;
  printNumber(scaledVal);
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
    Joystick.setXAxis(JS_AXIS_VAL);
    Joystick.setYAxis(PREVIOUS_ENCODER_VAL);
    updateDisplay();
  }
}