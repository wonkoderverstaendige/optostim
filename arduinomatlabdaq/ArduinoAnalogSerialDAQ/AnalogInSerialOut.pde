/*
  Analog input, analog output, serial output
 
 Reads an analog input pin, maps the result to a range from 0 to 255
 and uses the result to set the pulsewidth modulation (PWM) of an output pin.
 Also prints the results to the serial monitor.
 
 The circuit:
 * potentiometer connected to analog pin 0.
   Center pin of the potentiometer goes to the analog pin.
   side pins of the potentiometer go to +5V and ground
 * LED connected from digital pin 9 to ground
 
 created 29 Dec. 2008
 Modified 4 Sep 2010
 by Tom Igoe
 
 This example code is in the public domain.
 
 */

// Arduino MEGA has two different INTERANAL references 1V1 and 2V56
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#define INTERNAL INTERNAL1V1 // or INTERNAL2V56
#endif

const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to
int sensorValue = 0;        // value read from the pot 
int incomingByte = 0;	// for incoming serial data

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(57600); 
  analogReference(INTERNAL);
}

void loop() {
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    for (int n = 0; n < incomingByte; n++) {
      // read the analog in value:
      sensorValue = analogRead(analogInPin);  
    
      // send as binary data:
      Serial.write(lowByte(sensorValue));
      Serial.write(highByte(sensorValue));
      
      // settle ADC after the last reading:
      delay(5);
    }
  }                    
}
