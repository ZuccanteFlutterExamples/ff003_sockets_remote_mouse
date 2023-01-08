import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../message.dart';

class ServerSocketHandler {
  late Completer<ServerSocket> _completer;

  ServerSocketHandler(
      {required Future<void> Function(Iterable<Message> messages) onMessages}) {
    _completer = Completer();
    ServerSocket.bind(InternetAddress.anyIPv4, 0).then(
      (ServerSocket serverSocket) {
        _completer.complete(serverSocket);
        serverSocket.listen(
          (Socket socket) => utf8.decoder
              .bind(socket)
              .map(
                (event) => event
                    .split('\n')
                    .where((element) => element.isNotEmpty)
                    .map((e) => Message.fromJson(json.decode(e))),
              )
              .listen(
                (Iterable<Message> messages) => onMessages(messages),
              ),
        );
      },
    );
  }

  Future<int> get port async => (await _completer.future).port;
  Future<InternetAddress> get address async =>
      (await _completer.future).address;
}
