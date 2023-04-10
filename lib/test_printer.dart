import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';

class TestPrinter extends StatefulWidget {
  const TestPrinter({super.key});

  @override
  _TestPrinterState createState() => _TestPrinterState();
}

class _TestPrinterState extends State<TestPrinter> {
  List<Map<String, dynamic>> devices = [];
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool connected = false;

  @override
  initState() {
    super.initState();
    // _getDeviceList();
  }

  _getDeviceList() async {
    List<Map<String, dynamic>> results = [];
    results = await FlutterUsbPrinter.getUSBDeviceList();

    setState(() {
      devices = results;
      log(" length: ${results.length}");
    });
  }

  _connect(int vendorId, int productId) async {
    bool? returned = false;
    try {
      returned = await flutterUsbPrinter.connect(vendorId, productId);
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
    if (returned!) {
      setState(() {
        connected = true;
      });
    }
  }

  _print() async {
    try {
      var data = Uint8List.fromList(utf8.encode(" Hello POSBANK Team Testing ESC POS printer..."));
      await flutterUsbPrinter.write(data);
      // await FlutterUsbPrinter.printRawData("text");
      // await FlutterUsbPrinter.printText("Testing ESC POS printer...");
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('USB PRINTER'),
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _getDeviceList()),
            connected == true
                ? IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () {
                      _print();
                    })
                : Container(),
          ],
        ),
        body: devices.isNotEmpty
            ? ListView(
                scrollDirection: Axis.vertical,
                children: _buildList(devices),
              )
            : null,
      ),
    );
  }

  List<Widget> _buildList(List<Map<String, dynamic>> devices) {
    return devices
        .map((device) => ListTile(
              onTap: () {
                _connect(int.parse(device['vendorId']), int.parse(device['productId']));
              },
              leading: const Icon(Icons.usb),
              title: Text(device['manufacturer'] + " " + device['productName']),
              subtitle: Text(device['vendorId'] + " " + device['productId']),
            ))
        .toList();
  }
}
