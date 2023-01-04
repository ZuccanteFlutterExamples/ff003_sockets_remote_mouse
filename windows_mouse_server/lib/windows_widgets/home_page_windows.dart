import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:windows_mouse_server/utils/constant.dart';
import 'package:windows_mouse_server/windows_widgets/powershell_commands.dart';
import 'package:windows_mouse_server/windows_widgets/screen_size.dart';

import '../utils/message.dart';
import '../utils/message_action.dart';
import '../utils/pair.dart';

class MyHomePageWindows extends StatefulWidget {
  const MyHomePageWindows({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageWindows> createState() => _MyHomePageStateWindows();
}

class _MyHomePageStateWindows extends State<MyHomePageWindows> {
  ServerSocket? __serverSocket;
  int _clientWidth = 0;
  int _clientHeight = 0;
  int _hostWidth = 1920;
  int _hostHeight = 1080;

  @override
  void initState() {
    super.initState();
  }

  Future<ServerSocket> get serverSocket async {
    if (__serverSocket == null) {
      __serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      __serverSocket!.listen(
        (Socket socket) async {
          Process process = await Process.start('powershell', []);
          process.stderr.listen((event) {
            debugPrint('ERROR: ${event.toString()}');
          });
          process.stdout.drain();
          process.stdin.writeln(PowershellCommands.configuration);
          utf8.decoder
              .bind(socket)
              .map(
                (event) => event
                    .split('\n')
                    .where((element) => element.isNotEmpty)
                    .map((e) => Message.fromJson(json.decode(e))),
              )
              .listen(
            (Iterable<Message> messages) async {
              for (Message message in messages) {
                switch (message.action) {
                  case MessageAction.move:
                    process.stdin.writeln(
                      PowershellCommands.move(
                        x: translateX(message.x),
                        y: translateY(message.y),
                      ),
                    );
                    break;
                  case MessageAction.leftClick:
                    process.stdin.writeln(
                      PowershellCommands.leftClick(
                        x: translateX(message.x),
                        y: translateY(message.y),
                      ),
                    );
                    break;
                  case MessageAction.screenSize:
                    _clientWidth = message.x;
                    _clientHeight = message.y;
                    break;
                }
              }
            },
          );
        },
      );
    }
    return __serverSocket!;
  }

  int translateX(int x) {
    return (x * (_hostWidth / _clientWidth)).round();
  }

  int translateY(int y) {
    return (y * (_hostHeight / _clientHeight)).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder(
              future: Future.wait([NetworkInfo().getWifiIP(), serverSocket]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String address = snapshot.data![0] as String;
                  ServerSocket serverSocket = snapshot.data![1] as ServerSocket;
                  debugPrint('Address: $address');
                  return QrImage(
                    data: '$address,${serverSocket.port}',
                    version: QrVersions.auto,
                    size: 200.0,
                  );
                } else {
                  return const CircularProgressIndicator.adaptive();
                }
              },
            ),
            ScreenSize(
              size: Pair<int>(_hostWidth, _hostHeight),
              width: Constants.windowsWidgetWidth,
              spaceBetween: Constants.spaceBetweenWidgets,
              onChanged: (Pair<int> size) {
                _hostWidth = size.first;
                _hostHeight = size.second;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Screen size changed!',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
