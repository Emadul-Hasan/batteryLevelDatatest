//****************************************************
//************************************************** *
//Connections of Sensors to ESP32                  * *
//  	                                             * *
//  	                                             * *
//  		                                           * *
//  	                                             * *
// 	                                               * *
//                                                 * *
//************************************************** *
//****************************************************




//****************** Header Call and Declaration of BLE***********

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t value = 0;



#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"


int x;

//**************Class Declaration for BLE with feedback**************************
class MyServerCallbacks: public BLEServerCallbacks {

    void onConnect(BLEServer* pServer)
    {
      deviceConnected = true;
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer)
    {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {

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
    void onWrite(BLECharacteristic *pCharacteristic)
    {
      std::string value = pCharacteristic->getValue();
      char message[19];
      String toFind = "batteryLevel";
      String rcvmsg = "";

      if (value.length() > 0)
      {
        for (int i = 0; i < value.length(); i++)
        {
          message[i] = value[i];
          rcvmsg = rcvmsg + message[i];
        }
        Serial.print("Length: "); Serial.println(rcvmsg.length());

        if (rcvmsg.equals(toFind))
        {
          String text = "";
          text = String(x);  // to notify
          sendData(text);
        }
         


        }
       
        strcpy(message, "");

      }
    
};

// Potentiometer is connected to GPIO 34 (Analog ADC1_CH6) 
const int potPin = 34;

// variable for storing the potentiometer value
int potValue = 0;


void setup() {

  Serial.begin(115200);



  //************Setup for bluetooth******************

  BLEDevice::init("ESP32");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );
  pCharacteristic->setCallbacks(new MyCallbacks());


  pCharacteristic->addDescriptor(new BLE2902());
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  BLEDevice::startAdvertising();

}

void loop() {

  readAnalog();

  String text = "";
  text = String(x);
  // to notify
  

  if (x<=5)
  {
    sendData(text);
    }else if(x == 100)
    {
       sendData(text);
      }
  delay(2000);
}
