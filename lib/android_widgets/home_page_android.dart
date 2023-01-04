import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windows_mouse_server/android_widgets/scanner_page.dart';
import 'package:windows_mouse_server/utils/constant.dart';
import 'package:windows_mouse_server/utils/message.dart';

import '../utils/message_action.dart';

class MyHomePageAndroid extends StatefulWidget {
  const MyHomePageAndroid({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageAndroid> createState() => _MyHomePageStateAndroid();
}

class _MyHomePageStateAndroid extends State<MyHomePageAndroid> {
  late String _greetings;

  Socket? socket;
  int _x = 0;
  int _y = 0;

  late GlobalKey _key;

  @override
  void initState() {
    super.initState();
    _greetings = '';
    _key = GlobalKey();
  }

  Future<void> _sendLeftClick() async {
    Message message = Message(
      action: MessageAction.leftClick,
      x: _x,
      y: _y,
    );
    socket?.writeln(jsonEncode(message.toJson()));
    await socket?.flush();
  }

  Future<void> _sendMove(DragUpdateDetails details) async {
    _x = (details.delta.dx + details.globalPosition.dx).round();
    _y = (details.delta.dy + details.globalPosition.dy).round();
    // Send a command to the server to move the mouse cursor
    Message message = Message(
      action: MessageAction.move,
      x: _x,
      y: _y,
    );
    socket?.writeln(jsonEncode(message.toJson()));
    await socket?.flush();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                key: _key,
                onPanUpdate: _sendMove,
                onDoubleTap: _sendLeftClick,
                child: Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(Constants.spaceBetweenWidgets),
                    elevation: Constants.spaceBetweenWidgets,
                    child: Container(),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _sendLeftClick,
              child: const Icon(Icons.ads_click),
            ),
            const Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerPage(
                title: 'Scan QR code',
              ),
            ),
          ).then(
            (var result) {
              setState(() => _greetings = result);
              List<String> properties = _greetings.split(',');
              String address = properties[0];
              int port = int.parse(properties[1]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    properties.toString(),
                  ),
                ),
              );
              Socket.connect(address, port).then(
                (Socket value) {
                  socket = value;
                  Message message = Message(
                    action: MessageAction.screenSize,
                    x: MediaQuery.of(context).size.width.round(),
                    y: MediaQuery.of(context).size.height.round(),
                  );
                  socket!.writeln(jsonEncode(message));
                },
              );
            },
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
