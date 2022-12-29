import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
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
      __serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
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
                (Iterable<Message> messages) => messages.forEach(print),
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
                    print("Address: $address");
                    return QrImage(
                      data: '$address,${serverSocket.port}',
                      version: QrVersions.auto,
                      size: 200.0,
                    );
                  } else {
                    return const Text(
                      'No IP Address was found. Make sure you are connected to a Network.',
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
