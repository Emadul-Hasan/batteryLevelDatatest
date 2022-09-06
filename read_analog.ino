


void readAnalog() {
  
  

  x = map(potValue, 0, 4095, 0, 100);
  // Reading potentiometer value
  potValue = analogRead(potPin);
  Serial.println(x);

  
  
}
