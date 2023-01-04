import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:windows_mouse_server/windows_widgets/powershell_commands.dart';

import '../utils/message.dart';
import '../utils/message_action.dart';

class MyHomePageWindows extends StatefulWidget {
  const MyHomePageWindows({super.key, required this.title});

  final String title;

  @override
  State<MyHomePageWindows> createState() => _MyHomePageStateWindows();
}

class _MyHomePageStateWindows extends State<MyHomePageWindows> {
  ServerSocket? __serverSocket;

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
                    .where(
                      (element) => element.isNotEmpty,
                    )
                    .map(
                      (e) => Message.fromJson(json.decode(e)),
                    ),
              )
              .listen(
            (Iterable<Message> messages) async {
              for (Message message in messages) {
                switch (message.action) {
                  case MessageAction.move:
                    process.stdin.writeln(
                      PowershellCommands.move(x: message.x, y: message.y),
                    );
                    break;
                  case MessageAction.leftClick:
                    process.stdin.writeln(
                      PowershellCommands.leftClick(x: message.x, y: message.y),
                    );
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

  Future<String?> get ipAddress async {
    return await NetworkInfo().getWifiIP();
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
              future: Future.wait([ipAddress, serverSocket]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data![0] != null) {
                    String address = snapshot.data![0] as String;
                    ServerSocket serverSocket =
                        snapshot.data![1] as ServerSocket;
                    debugPrint("Address: $address");
                    return QrImage(
                      data: '$address,${serverSocket.port}',
                      version: QrVersions.auto,
                      size: 200.0,
                    );
                  } else {
                    return const Text(
                      'No IP Address was found. Make sure you are connected to a WiFi Network.',
                    );
                  }
                } else {
                  return const CircularProgressIndicator.adaptive();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
