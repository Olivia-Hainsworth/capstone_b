#include <Adafruit_NeoPixel.h>
#include <EEPROM.h>


// PIN ALLOC.:
#define buttonPin       2    // the pin that the pushbutton is attached to
#define computerPin     3    // the pin that the pushbutton is attached to
#define LEDInputPin     6    // outputs to the RGB LED rings 
#define IRLEDPin        7  // Controls the ground for IR ring
#define buttonLEDPin    10 // Pin for led in the middle of the button

// BUTTON  VAR.:
int buttonPushCounter =   0;      // counter for the number of button presses
int buttonState =       LOW;     // current state of the button
int lastButtonState =     0;     // previous state of the button
int lastButtonPress = millis();

// LED RING VAR. 
const int ring1Pixels = 20;
const int ring2Pixels = 24;
const int ring3Pixels = 28;
int ringTotal = ring1Pixels + ring2Pixels + ring3Pixels; 

Adafruit_NeoPixel ring1(ringTotal, LEDInputPin, NEO_GRB + NEO_KHZ800);

// LED STATE VAR.: 
int RED[3] = {255, 0, 0};
int GREEN[3] = {0, 255, 0};
int BLUE[3] = {0, 0, 255};
int PURPLE[3] = {125, 0, 125};

int color1[3] = {0, 0, 0};
int color2[3] = {0, 0, 0}; 
int testColor[3] = {999, 999, 999};


int currentState = 0;
const unsigned int MAX_MESSAGE_LENGTH = 3;

int color1Prom = 0;
int color2Prom = 0;



void setup() {
  // Read the colors from the EEPROM;

  Serial.begin(19200);
  color1Prom = EEPROM.read(51);
  color2Prom = EEPROM.read(52);    
     
  if(color1Prom == 0) for(int i = 0; i < 3; i++) color1[i] = RED[i];  
  if(color1Prom == 1) for(int i = 0; i < 3; i++) color1[i] = GREEN[i];  
  if(color1Prom == 2) for(int i = 0; i < 3; i++) color1[i] = BLUE[i];  
  if(color1Prom == 3) for(int i = 0; i < 3; i++) color1[i] = PURPLE[i];  
      
  if(color2Prom == 0) for(int i = 0; i < 3; i++) color2[i] = RED[i];  
  if(color2Prom == 1) for(int i = 0; i < 3; i++) color2[i] = GREEN[i];  
  if(color2Prom == 2) for(int i = 0; i < 3; i++) color2[i] = BLUE[i];  
  if(color2Prom == 3) for(int i = 0; i < 3; i++) color2[i] = PURPLE[i];  
      
  
  // initialize pin modes
  pinMode(LEDInputPin, OUTPUT);
  pinMode(IRLEDPin, OUTPUT);

  attachInterrupt(digitalPinToInterrupt(buttonPin), buttonPress, RISING);
  attachInterrupt(digitalPinToInterrupt(computerPin), PulseISR, CHANG);


  Serial.begin(19200);
  ring1.begin();

  
  ring1.clear();
  digitalWrite(IRLEDPin, HIGH); // Sets resistance high, short circuits and IR LEDs cant turn on 

}

bool colorCompare(int arr1[3], int arr2[3]) {
  for(int i = 0; i < 3; i++) {
    if(arr1[i] != arr2[i]) return false;
  }
  
  return true;
}

bool messageStarted = false;
void checkColors() {

  while (Serial.available() > 0) {
    //Create a place to hold the incoming message
    static char message[MAX_MESSAGE_LENGTH];
    static unsigned int message_pos = 0;

    //Read the next available byte in the serial receive buffer
    char inByte = Serial.read();
    
    
    if(!(inByte == 'A' || inByte == 'B') && !messageStarted) return;
    else if((inByte == 'A' || inByte == 'B')) {
      message_pos = 0;
      messageStarted = true;  
      message[message_pos]=inByte;        
      message_pos++;
    }
    
    //Message coming in (check not terminating character) and guard for over message size
    else if ( inByte != '\n' && (message_pos < MAX_MESSAGE_LENGTH - 1) ) {
      //Add the incoming byte to our message
      message[message_pos] = inByte;
      message_pos++;
    }
    
    //Full message received...
    else {

      message[message_pos] = '\0';
      bool changed = false;
      
      if(message[0] == 'A' && (message[1] == '0' || message[1] == '1' || message[1] == '2' || message[1] == '3') ){     
        const int prom1Color = EEPROM.read(51);
        
        if(prom1Color != String(message[1]).toInt()) {          
          Serial.println("Changed");
          EEPROM.write(51, String(message[1]).toInt());
          changed = true;
        }
        
        if(message[1] == '0') for(int i = 0; i < 3; i++) color1[i] = RED[i];  
        if(message[1] == '1') for(int i = 0; i < 3; i++) color1[i] = GREEN[i];  
        if(message[1] == '2') for(int i = 0; i < 3; i++) color1[i] = BLUE[i];  
        if(message[1] == '3') for(int i = 0; i < 3; i++) color1[i] = PURPLE[i];  
      }
      
      if(message[0] == 'B' && (message[1] == '0' || message[1] == '1' || message[1] == '2' || message[1] == '3') ){     
        const int prom2Color = EEPROM.read(52);
        
        if(prom2Color != String(message[1]).toInt()) {          
          Serial.println("Changed");
          EEPROM.write(52, String(message[1]).toInt());
          changed = true;
        }
        
        if(message[1] == '0') for(int i = 0; i < 3; i++) color2[i] = RED[i];  
        if(message[1] == '1') for(int i = 0; i < 3; i++) color2[i] = GREEN[i];  
        if(message[1] == '2') for(int i = 0; i < 3; i++) color2[i] = BLUE[i];  
        if(message[1] == '3') for(int i = 0; i < 3; i++) color2[i] = PURPLE[i];  
      }
            
      //Reset for the next message
      message_pos = 0;
      messageStarted = false;
   }
 }
}

void loop() {
  
  // If the button is being held down for more than 5 seconds.
  if (millis() - lastButtonPress >= 5000 && digitalRead(buttonPin) == HIGH) {    

    if(buttonState == HIGH) buttonState = LOW;
    else buttonState = HIGH;

    Serial.print("Switching States - New State: ");
    Serial.println(buttonState);
  }
  
  if (buttonState == HIGH){
//    Serial.println("Device is off");

    ring1.setPixelColor(1, 10, 10, 10);
    ring1.clear();
    digitalWrite(IRLEDPin, HIGH);
    return;
  }
  else {    

     digitalWrite(buttonLEDPin,  HIGH);     
        
      // Arduino modes
      if(buttonPushCounter == 0) {
        ring1.clear();
        ring1.setPixelColor(1, 10, 10, 10);
        ring1.show();
        delay(500);
        ring1.clear();
        ring1.setPixelColor(1, 0, 0, 0);
        ring1.show();
        delay(500);
      }
  
      if(buttonPushCounter == 1) {
        checkColors();
        ring1.clear();

        if (colorCompare(color1, PURPLE)) digitalWrite(IRLEDPin, LOW); 
        else {                 
          for(int i = 0; i < ringTotal; i++) ring1.setPixelColor(i, ring1.Color(color1[0], color1[1], color1[2]));
          ring1.show();  
          digitalWrite(IRLEDPin, HIGH);      
        }
      }
    
      if(buttonPushCounter == 2){
        checkColors();
        ring1.clear();
        
        if (colorCompare(color2, PURPLE)) digitalWrite(IRLEDPin, LOW); 
        else {
          for(int i = 0; i < ringTotal; i++) ring1.setPixelColor(i, ring1.Color(color2[0], color2[1], color2[2]));
          ring1.show();
          digitalWrite(IRLEDPin, HIGH);
        }       
      }
    
      if(buttonPushCounter >= 4) {
        buttonPushCounter = 1;
        Serial.println("Back to 1");
      }  
  }
}

void buttonPress() {
  
  if(millis() - lastButtonPress > 1000) {
    Serial.print("Button Pressed - ");
  
    buttonPushCounter++;
    Serial.print("number of button pushes: ");
    Serial.println(buttonPushCounter);
  }  
  lastButtonPress = millis();
}

void PulseISR() {
  
  if (buttonPushCounter == 3){    

    if (currentState == 0) {
      digitalWrite(LED_BUILTIN, HIGH);
      
      ring1.clear();
      if (colorCompare(color2, PURPLE)) digitalWrite(IRLEDPin, LOW);
      else {
        for(int i = 0; i < ringTotal; i++) ring1.setPixelColor(i, ring1.Color(color2[0], color2[1], color2[2]));
        ring1.show();
        digitalWrite(IRLEDPin, HIGH);      
      }
        
      currentState = 1;
    }
    
    else if (currentState == 1) {
      digitalWrite(LED_BUILTIN, LOW);
      
      ring1.clear();     
      if (colorCompare(color1, PURPLE)) digitalWrite(IRLEDPin, LOW); 
      else {
        for(int i = 0; i < ringTotal; i++) ring1.setPixelColor(i, ring1.Color(color1[0], color1[1], color1[2]));
        ring1.show();
        digitalWrite(IRLEDPin, HIGH);
      }

      currentState = 0;
    }
    
    else {
      Serial.print("error");
      currentState = 0;
    }
  }
}
