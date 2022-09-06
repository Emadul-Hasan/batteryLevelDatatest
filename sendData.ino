void sendData(String textdata)
{
  String text= textdata;
  if (deviceConnected)
  {
    pCharacteristic->setValue((char*)text.c_str());
    pCharacteristic->notify();    
  }
    // disconnecting
  if (!deviceConnected && oldDeviceConnected)
  {
    // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising(); // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected)
  {
      // do stuff here on connecting
      oldDeviceConnected = deviceConnected;
  }
 
}
