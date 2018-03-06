void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -

}

void loop() {
  
  if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
    Serial.println('!');
  }
  else{
    // send the value of analog input 0:
      Serial.print(analogRead(A0));
//      Serial.print(", ");
//      Serial.print(analogRead(A3));
      Serial.println();
  }
  //Wait for a bit to keep serial data from saturating
  delay(10);
}
