/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/

//#include <CapacitiveSensor.h> 

//our sensor is on pin 17, and also connected through a resistor to pin 18 per schematic at link above
//CapacitiveSensor mySensor(18, 19); 

// Midi channels
const int POTCC = 1;
const int POT2CC = 2;
const int POT3CC = 7;
const int POT4CC = 8;
const int BUTTONCC = 3;
const int JOYCLICKCC = 4;
const int JOYXCC = 5;
const int JOYYCC = 6;
const int BUT2CC = 9;
const int BUT3CC = 10;
const int FSRCC = 11;
const int IRCC = 12;

// Sensitivity settings -
const int POTSENS = 10;
const int IRSENS = 10;
const int IRMIN = 140;
const int IRMAX = 900;
const int JOYSENS = 20;
const int JOYMAX = 1023;
const int JOYMIN = 0;
const int FSRMIN = 4;
const int FSRMAX = 1023;

// Pins
const int BUTTONPIN = 0;
const int POTPIN = A0;
const int POT2PIN = A1;
const int POT3PIN = A4;
const int POT4PIN = A5;
const int JOYX = A2;
const int JOYY = A3;
const int ACCX = A6;
//const int ACCY = A7;
const int IRPIN = A7;
const int ACCZ = A9;
const int FSRPIN = A8;
const int JOYCL = 1;
const int BUT2PIN = 11;
const int BUT3PIN = 12;

// State settings
int irInit = 0;
int prevPot = 0;
int prevPot2 = 0;
int prevPot3 = 0;
int prevPot4 = 0;
int buttonPrev = 0;
int but2Prev = 0;
int but3Prev = 0;
int joyClickPrev = 0;
int prevFsr = 0;
int irPrev = 0;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);

  pinMode(BUTTONPIN, INPUT);
  pinMode(BUT2PIN, INPUT);
  pinMode(BUT3PIN, INPUT);
  pinMode(JOYX, INPUT);
  pinMode(JOYY, INPUT);
 /* pinMode(ACCX, INPUT);
  pinMode(ACCY, INPUT);
  pinMode(ACCZ, INPUT);*/
  pinMode(JOYCL, INPUT_PULLUP); 
  //pinMode(MOTPIN, INPUT);
}

void loop() {
  int buttonState = digitalRead(BUTTONPIN);
  int but2 = digitalRead(BUT2PIN);
  int but3 = digitalRead(BUT3PIN);
  int potValue = analogRead(POTPIN);
  int pot2Value = analogRead(POT2PIN);
  int pot3Value = analogRead(POT3PIN);
  int pot4Value = analogRead(POT4PIN);
  int joyX = analogRead(JOYX);
  int joyY = analogRead(JOYY);
  int ir = analogRead(IRPIN);
  // int accX = analogRead(ACCX);
  // int accY = analogRead(ACCY);
  // int accZ = analogRead(ACCZ);
  int joyClick = digitalRead(JOYCL);
  int fsr = analogRead(FSRPIN);
  
 // int motVal = digitalRead(MOTPIN);
  int midiX = 0;
  int midiY = 0;
  int potMidi = 0;
  int pot2Midi = 0;
  int pot3Midi = 0;
  int pot4Midi = 0;
  int fsrMidi = 0;
  int irMidi = 0;

  // Midi conversion
  potMidi = map(potValue, 0, 1023, 0, 127);
  pot2Midi = map(pot2Value, 0, 1023, 0, 127);
  pot3Midi = map(pot3Value, 0, 1023, 0, 127);
  pot4Midi = map(pot4Value, 0, 1023, 0, 127);
  midiX = map(joyX, 0, 1023, 0, 127);
  midiY = map(joyY, 0, 1023, 0, 127);
  fsrMidi = map(fsr, FSRMIN, FSRMAX, 0, 127);
  irMidi = map(ir, IRMIN, IRMAX, 127, 0);
  

  // Debug output
  /*
  Serial.print("POT: ");
  Serial.print(potValue);
  Serial.print("\n");
  Serial.print("POT2: ");
  Serial.println(pot2Value);
  Serial.print("POT3: ");
  Serial.println(pot3Value);
  Serial.print("POT4: ");
  Serial.println(pot4Value);
  Serial.print("BUTTON: ");
  Serial.println(buttonState);
  Serial.print("BUTTON 2: ");
  Serial.println(but2);
  Serial.print("BUTTON 3: ");
  Serial.println(but3);
  Serial.print("JOY X: ");
  Serial.println(joyX);
  Serial.print("JOY Y: ");
  Serial.println(joyY);
  Serial.print("Click: ");
  Serial.println(joyClick);
  Serial.print("IR:" );
  Serial.println(ir);
*/
/*
 // Serial.print("MOTION: ");
  // Serial.println(motVal);
  Serial.print("ACCX: ");
  Serial.println(accX);
  Serial.print("ACCY: ");
  Serial.println(accY);
  Serial.print("ACCZ: ");
  Serial.println(accZ);

  */

    Serial.print("FSR: ");
  Serial.println(fsr);
  
  // Send Pot MIDI
  int potAbs = abs(potValue - prevPot);
  if (potAbs > POTSENS) {
    usbMIDI.sendControlChange(POTCC, potMidi, 1);
    //Serial.print("POTVAL: ");
    //Serial.println(potMidi);
  }
  prevPot = potValue;

  // Send pot2 Midi
  if (abs(pot2Value - prevPot2) > POTSENS) {
    usbMIDI.sendControlChange(POT2CC, pot2Midi, 1);
    //Serial.print("POT2VAL: ");
    //Serial.println(pot2Midi);
  }
  prevPot2 = pot2Value;

  // Send pot3 Midi
  if (abs(pot3Value - prevPot3) > POTSENS) {
    usbMIDI.sendControlChange(POT3CC, pot3Midi, 1);
    //Serial.print("POT3VAL: ");
    //Serial.println(pot3Midi);
  }
  prevPot3 = pot3Value;

  // Send pot4 Midi
  if (abs(pot4Value - prevPot4) > POTSENS) {
    usbMIDI.sendControlChange(POT4CC, pot4Midi, 1);
    //Serial.print("POT4VAL: ");
    //Serial.println(pot4Midi);
  }
  prevPot4 = pot4Value;

  // FSR
  if (fsr >= FSRMIN) { // && prevFsr != fsr) {
    usbMIDI.sendControlChange(FSRCC, fsrMidi, 1);
  }
  prevFsr = fsr;

  // Handle Joystick x
  if (joyX >= (JOYMAX - JOYSENS) || joyX <= (JOYMIN + JOYSENS)) {
    if (joyX >= (JOYMAX - JOYSENS)) {
      midiX = 127;
    } else if (joyX <= (JOYMIN + JOYSENS)) {
      midiX = 0;
    }

    usbMIDI.sendControlChange(JOYXCC, midiX, 1);
    //Serial.print("SENT JOYX: ");
    //Serial.println(midiX);
  }

  // Joystick Y
  if (joyY >= (JOYMAX - JOYSENS) || joyY <= (JOYMIN + JOYSENS)) {
    if (joyY >= (JOYMAX - JOYSENS)) {
      midiY = 127;
    } else if (joyY <= (JOYMIN + JOYSENS)) {
      midiY = 0;
    }
    
    usbMIDI.sendControlChange(JOYYCC, midiY, 1);
    //Serial.print("SENT JOYY: ");
    //Serial.println(midiY);
  }

  // Joy Click
  if (joyClick != joyClickPrev) {
 //   Serial.print("SENDING joyClick : ");
 //   Serial.println(joyClick);
    usbMIDI.sendControlChange(JOYCLICKCC, joyClick, 1);
  }
  joyClickPrev = joyClick;

  // Button
  if (buttonState != buttonPrev) {
 //   Serial.print("SENDING UBTTON : ");
 //   Serial.println(buttonState);
    usbMIDI.sendControlChange(BUTTONCC, buttonState, 1);
  }
  buttonPrev = buttonState;

  // button 2
  if (but2 != but2Prev) {
    usbMIDI.sendControlChange(BUT2CC, but2, 1);
  }
  but2Prev = but2;

  // button 2
  if (but3 != but3Prev) {
    usbMIDI.sendControlChange(BUT3CC, but3, 1);
  }
  but3Prev = but3;

  if (abs(ir - irPrev) > IRSENS) {
    usbMIDI.sendControlChange(IRCC, irMidi, 1);
  }
  irPrev = ir;

  delay(50);        // delay in between reads for stability
}
