import 'package:flutter/material.dart';
import 'dart:io';

import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Remote mouse controller!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String?> getIP() async {
    for (NetworkInterface interface in await NetworkInterface.list()) {
      if (interface.name == "Wi-Fi") {
        return interface.addresses.first.address;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: getIP(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator.adaptive();
                } else {
                  //String? ip = snapshot.data;
                  if (snapshot.data != null) {
                    return QrImage(
                      data: snapshot.data!,
                      version: QrVersions.auto,
                      size: 200.0,
                    );
                  } else {
                    return const Text("Sorry can not find an IP address.");
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
