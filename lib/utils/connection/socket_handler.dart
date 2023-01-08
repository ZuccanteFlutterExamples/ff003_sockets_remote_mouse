import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../message.dart';

class SocketHandler {
  late Completer<Socket> _completer;

  SocketHandler() {
    _completer = Completer();
  }

  Future<void> connect({required String host, required int port}) async =>
      _completer.complete(await Socket.connect(host, port));

  Future<Socket> get _socket {
    return _completer.future;
  }

  Future<void> sendMessage(Message message) async {
    Socket socket = await _socket;
    socket.writeln(jsonEncode(message.toJson()));
    await socket.flush();
  }
}
