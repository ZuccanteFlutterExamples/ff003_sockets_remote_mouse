import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:windows_mouse_server/utils/constant.dart';
import 'package:windows_mouse_server/utils/display_strings.dart';
import 'package:windows_mouse_server/windows_widgets/powershell_commands.dart';
import 'package:windows_mouse_server/windows_widgets/screen_size_form.dart';
import 'package:windows_mouse_server/utils/connection/server_socket_handler.dart';

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
  Pair<int, int> _clientSize = const Pair(0, 0);
  Pair<int, int> _hostSize = Constants.defaultScreenSize;
  late ServerSocketHandler _serverSocketHandler;

  @override
  void initState() {
    super.initState();
    Completer<Process> processCompleter = Completer();
    Process.start('powershell', []).then((process) {
      process.stderr.listen((event) {
        debugPrint('ERROR: ${event.toString()}');
      });
      process.stdout.drain();
      process.stdin.writeln(PowershellCommands.configuration);
      processCompleter.complete(process);
    });
    _serverSocketHandler = ServerSocketHandler(
      onMessages: (messages) async {
        Process process = await processCompleter.future;
        for (Message message in messages) {
          switch (message.action) {
            case MessageAction.move:
              process.stdin.writeln(
                PowershellCommands.move(_translate(message.pair)),
              );
              break;
            case MessageAction.leftClick:
              process.stdin.writeln(
                PowershellCommands.leftClick(_translate(message.pair)),
              );
              break;
            case MessageAction.screenSize:
              _clientSize = message.pair;
              break;
          }
        }
      },
    );
  }

  Pair<int, int> _translate(Pair<int, int> source) => Pair(
        (source.first * (_hostSize.first / _clientSize.first)).round(),
        (source.second * (_hostSize.second / _clientSize.second)).round(),
      );

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
              future: Future.wait(
                [
                  NetworkInfo().getWifiIP(),
                  _serverSocketHandler.port,
                ],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String address = snapshot.data![0] as String;
                  int port = snapshot.data![1] as int;
                  return QrImage(
                    data: '$address,$port',
                    version: QrVersions.auto,
                    size: Constants.windowsWidgetWidth,
                  );
                } else {
                  return const CircularProgressIndicator.adaptive();
                }
              },
            ),
            ScreenSizeForm(
              size: _hostSize,
              width: Constants.windowsWidgetWidth,
              spaceBetween: Constants.spaceBetweenWidgets,
              onChanged: (Pair<int, int> size) {
                _hostSize = size;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      DisplayStrings.changedScreenSize,
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
