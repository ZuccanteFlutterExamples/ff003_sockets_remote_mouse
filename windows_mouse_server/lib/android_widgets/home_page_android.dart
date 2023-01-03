import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windows_mouse_server/android_widgets/scanner_page.dart';
import 'package:windows_mouse_server/utils/message.dart';

class MyHomePageAndroid extends StatefulWidget {
  const MyHomePageAndroid({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageAndroid> createState() => _MyHomePageStateAndroid();
}

class _MyHomePageStateAndroid extends State<MyHomePageAndroid> {
  String greetings = '';

  Socket? socket;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onPanUpdate: (details) async {
          int x = (details.delta.dx + details.globalPosition.dx).round();
          int y = (details.delta.dy + details.globalPosition.dy).round();
          // Send a command to the server to move the mouse cursor
          Message message = Message(action: MessageAction.move, x: x, y: y);
          socket?.writeln(jsonEncode(message.toJson()));
          await socket?.flush();
        },
        onDoubleTap: () async {
          Message message = Message(action: MessageAction.click, x: 0, y: 0);
          socket?.writeln(jsonEncode(message.toJson()));
          await socket?.flush();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerPage(
                title: 'Scan QR code',
              ),
            ),
          );
          setState(() => greetings = result);
          List<String> properties = greetings.split(',');
          String address = properties[0];
          int port = int.parse(properties[1]);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                properties.toString(),
              ),
            ),
          );
          socket = await Socket.connect(address, port);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
