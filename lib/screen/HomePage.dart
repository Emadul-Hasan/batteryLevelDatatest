import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'discover.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  static const String id = 'HomePage';

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as BluetoothDevice;
    return AppHomePage(
      device: args,
    );
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  FocusNode focusMessage = FocusNode();
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  late Stream<List> stream;
  late BluetoothCharacteristic targetCharacteristics;
  int rangeController = 0;

  bool request = true;
  late List<BluetoothService> services;

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    discoverServices();

    new Timer(const Duration(seconds: 3), () {
      if (!isReady) {
        disconnectFromDevice();
        _pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    services = await widget.device.discoverServices();

    services.forEach((service) {
      if (service.uuid.toString() == serviceUUId) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUId) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            targetCharacteristics = characteristic;
            setState(() {
              isReady = true;
            });
          }
        });
      }
    });
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> datafromdevice) {
    return utf8.decode(datafromdevice);
  }

  sendData(String data) async {
    if (targetCharacteristics == null) return;
    List<int> bytes = utf8.encode(data);
    await targetCharacteristics.write(bytes, withoutResponse: true);
  }

  void checkConnectionState() {
    widget.device.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        // widget.device.disconnect();\
        Timer(Duration(seconds: 2), () {
          // Navigator.pushReplacementNamed(context, DiscoverPage.id);
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  var x = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Colors.black38,
      ),
      body: isReady == false
          ? Center(
              child: Text("Daten Lesen...."),
            )
          : Container(
              child: StreamBuilder<List>(
                stream: stream,
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasError) {
                    Timer(Duration(seconds: 30), () {
                      // print('done');
                      // just Wait
                    });
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    try {
                      while (rangeController < 5) {
                        Timer(Duration(seconds: 2), () async {
                          await sendData("batteryLevel");
                        });
                        rangeController++;
                      }
                      x = _dataParser(snapshot.data as List<int>);
                    } catch (e) {
                      print(e);
                    }
                  }
                  checkConnectionState();

                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 200.0,
                          width: double.infinity,
                        ),
                        Text(
                          x == " " ? "no data" : "$x",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
