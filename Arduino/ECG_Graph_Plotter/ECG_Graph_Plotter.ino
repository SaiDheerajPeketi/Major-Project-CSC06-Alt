void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  pinMode(3, INPUT); // Setup for leads off detection LO +
  pinMode(2, INPUT); // Setup for leads off detection LO -

}

void loop() {
  
  if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
    Serial.println('!');
  }
  else{
    // send the value of analog input 0:
      Serial.println(analogRead(A5));
  }
  //Wait for a bit to keep serial data from saturating
  delay(1);
}
