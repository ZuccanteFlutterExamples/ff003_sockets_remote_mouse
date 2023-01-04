import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windows_mouse_server/android_widgets/scanner_page.dart';
import 'package:windows_mouse_server/utils/constant.dart';
import 'package:windows_mouse_server/utils/display_strings.dart';
import 'package:windows_mouse_server/utils/message.dart';

import '../utils/message_action.dart';
import '../utils/pair.dart';

class MyHomePageAndroid extends StatefulWidget {
  const MyHomePageAndroid({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageAndroid> createState() => _MyHomePageStateAndroid();
}

class _MyHomePageStateAndroid extends State<MyHomePageAndroid> {
  late GlobalKey _key;
  late Pair<int, int> _point;
  Widget? _icon;
  Socket? _socket;

  @override
  void initState() {
    super.initState();
    _point = Constants.defaultScreenSize;
    _key = GlobalKey();
  }

  Future<void> _sendLeftClick() async {
    Message message = Message(
      action: MessageAction.leftClick,
      pair: _point,
    );
    _socket?.writeln(jsonEncode(message.toJson()));
    await _socket?.flush();
  }

  Future<void> _sendMove(DragUpdateDetails details) async {
    _point = Pair(
      (details.delta.dx + details.globalPosition.dx).round(),
      (details.delta.dy + details.globalPosition.dy).round(),
    );
    // Send a command to the server to move the mouse cursor
    Message message = Message(
      action: MessageAction.move,
      pair: _point,
    );
    _socket?.writeln(jsonEncode(message.toJson()));
    await _socket?.flush();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 1000,
            ),
            child: _icon,
          ),
        ],
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
                title: DisplayStrings.qrCodePageTitle,
              ),
            ),
          ).then(
            (var result) {
              List<String> properties = result.split(',');
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
                  _socket = value;
                  setState(() {
                    _icon = Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Constants.spaceBetweenWidgets),
                        child: const Icon(Icons.check));
                  });
                  Message message = Message(
                    action: MessageAction.screenSize,
                    pair: Pair<int, int>(
                      MediaQuery.of(context).size.width.round(),
                      MediaQuery.of(context).size.height.round(),
                    ),
                  );
                  _socket!.writeln(jsonEncode(message));
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
