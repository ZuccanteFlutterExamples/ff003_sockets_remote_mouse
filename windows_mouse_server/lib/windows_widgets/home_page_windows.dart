import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/message.dart';

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
      __serverSocket ??= await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      __serverSocket!.listen(
        (Socket socket) {
          utf8.decoder
              .bind(socket)
              .map(
                (event) => event
                    .split('\n')
                    .where(
                      (element) => element.isNotEmpty,
                    )
                    .map(
                      (e) => Message.fromJson(
                        jsonDecode(e),
                      ),
                    ),
              )
              .listen(
                (Iterable<Message> messages) => messages.forEach(
                  (element) {
                    print(element);
                  },
                ),
              );
        },
        // if (command.startsWith('MOVE')) {
        //   List<String> parts = command.split(' ');
        //   int x = int.parse(parts[1]);
        //   int y = int.parse(parts[2]);
        //   print('x: $x, y: $y');
        // }

        /*utf8.decoder.bind(socket).listen(
          (String command) {
            print('_________ START OF MESSAGE: $message ____________');
            try {
              print(command);
              if (command.startsWith('MOVE')) {
                List<String> parts = command.split(' ');
                double x = double.parse(parts[1]);
                double y = double.parse(parts[2]);
                print('x: $x, y: $y');
*/
        //if (Platform.isWindows) {
        /*Process.runSync('powershell', [
                'Add-Type -Name Window -Namespace Console -MemberDefinition '
                    '[DllImport("user32.dll")]public static extern bool SetCursorPos(int x, int y);',
                '$x, $y | ForEach-Object {[Console.window]::SetCursorPos($x, $y)}'
              ]);*/
        /*Process.runSync(
                'powershell',
                [
                  '[DllImport("user32.dll")]',
                  'static extern bool SetCursorPos(int X, int Y);',
                  'SetCursorPos($x, $y);'
                ],
              );*/
        //}
        /*}
            } catch (error) {
              print(error);
            }
            print('_______ END OF MESSAGE: $message _____________');
            message++;*/
      );
    }
    return __serverSocket!;
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
              future: serverSocket,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return QrImage(
                    data:
                        '${snapshot.data!.address.address},${snapshot.data!.port}',
                    version: QrVersions.auto,
                    size: 200.0,
                  );
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
