# define ENCODER_PULSES_PER_REV 4000
# define JS_VAL_MIN 0
# define JS_VAL_MAX 1023
# define JS_MIN_MAX_REVS 9
// INPUT PINS
#define  A_PHASE 2
#define  B_PHASE 3

int JS_MIDPOINT = (MIN_JS_VAL + MAX_JS_VAL) / 2;
int JS_RANGE = JS_VAL_MAX + abs(JS_VAL_MIN);
int JS_AXIS_VAL = 0;
int varient ENCODER_VAL = 0;
int PREVIOUS_ENCODER_VAL = 0;
int ENCODER_AXIS_STEP = ENCODER_PULSES_PER_REV / (JS_RANGE/JS_MIN_MAX_REVS);

void setup() {
  pinMode(A_PHASE, INPUT);
  pinMode(B_PHASE, INPUT);
  attachInterrupt(digitalPinToInterrupt(A_PHASE), processPulse, RISING);
}


void reset() {
  JS_AXIS_VAL = JS_MIDPOINT;
  ENCODER_VAL = 0;
  PREVIOUS_ENCODER_VAL = 0;
}

void processPulse() {
  // stuff that figures out direction and increments or decrements the counter
  char i;
  i = digitalRead( B_PHASE);
  if (i == 1) {
    // CCW
    ENCODER_VAL += 1;
  } else {
    // CW
    ENCODER_VAL += 1;
  }
}

void loop() {
  if (abs(ENCODER_VAL - PREVIOUS_ENCODER_VAL) >= ENCODER_AXIS_STEP) {
    noInterrupt();
    // increase/decrease axis val
    if (ENCODER_VAL > PREVIOUS_ENCODER_VAL) {
      JS_AXIS_VAL += 1;
    } else {
      JS_AXIS_VAL -= 1;
    }
    PREVIOUS_ENCODER_VAL = ENCODER_VAL;
    interrupt();
  }
}