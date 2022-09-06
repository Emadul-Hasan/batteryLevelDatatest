import 'dart:async';
import 'dart:ui';

import 'package:battery_test/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location/location.dart';

class DiscoverPage extends StatefulWidget {
  static const String id = 'DiscoverPage';
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List scannedDevicesName = [];
  List<BluetoothDevice> scannedDevice = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  var subscription;
  late bool _serviceEnabled;

  Location location = new Location();

  Future<bool> _checkDeviceBluetoothIsOn() async {
    return await flutterBlue.isOn;
  }

  Future<void> scanForBluetoothDevice() async {
    scannedDevice.clear();
    scannedDevicesName.clear();
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      scannedDevice.add(connectedDevices[0]);
      scannedDevicesName.add(connectedDevices[0].name);
    }

// Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));

// Listen to scan results
    subscription = flutterBlue.scanResults.listen((results) {
      if (results.length == 0) {
        setState(() {});
      }

      // // do something with scan results
      for (ScanResult r in results) {
        print(r);
        print('${r.device.name} found! rssi: ${r.rssi}');
        setState(() {
          if (r.device.name == '') {
          } else {
            scannedDevicesName.add(r.device.name);
            scannedDevicesName = scannedDevicesName.toSet().toList();
            scannedDevice.add(r.device);
            scannedDevice = scannedDevice.toSet().toList();
          }
        });
      }
    });

// Stop scanning
    flutterBlue.stopScan();
    // subscription.cancel();
  }

  Future<void> turnOnLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
  }

  @override
  void initState() {
    turnOnLocation();
    super.initState();
  }

  @override
  void dispose() {
    scannedDevice.clear();
    scannedDevicesName.clear();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80.0,
            ),
            const Text(
              "SPLASH-X",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.bluetooth,
                size: 40.0,
                color: Colors.blue,
              ),
              title: Text(
                "Turn your bluetooth to connect",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(
              height: 3.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.blue)),
              onPressed: () async {
                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                } else if (_serviceEnabled) {
                  var checkS = await _checkDeviceBluetoothIsOn();
                  if (!checkS) {
                    // await EasyLoading.showInfo("Bluetooth aktivieren");
                  } else {
                    setState(() {
                      scanForBluetoothDevice();
                      Timer(Duration(seconds: 4), () {});
                    });
                  }
                }
              },
              child: const Text(
                "Search ble device",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 30.0, bottom: 0.0),
                  child: const Text(
                    'Available Devices',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(
                          top: 0.0, left: 10.0, right: 10.0),
                      child: ListTile(
                        title: Text(scannedDevicesName[index]),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: scannedDevice[index].state,
                            builder: (c, snapshot) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) => Colors.blue)),
                                    onPressed: () async {
                                      Timer(Duration(seconds: 2), () {
                                        Navigator.pushNamed(
                                            context, Homepage.id,
                                            arguments: scannedDevice[index]);
                                      });
                                    },
                                    child: Text("Open"));
                              }
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.blue)),
                                  onPressed: () {
                                    Timer(const Duration(seconds: 2), () async {
                                      await scannedDevice[index]
                                          .connect(autoConnect: false);
                                    });
                                  },
                                  child: Text("Connect"));
                            }),
                        onTap: () async {
                          // loadingIgnite();
                          // await scannedDevice[index].connect();
                          // EasyLoading.dismiss();
                        },
                      ));
                },
                itemCount: scannedDevicesName.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
