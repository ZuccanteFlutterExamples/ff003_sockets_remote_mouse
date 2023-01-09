import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../message.dart';

class SocketHandler {
  late Completer<Socket> _completer;

  /// Initialize a `Socket` to send `Message` to another one
  SocketHandler() {
    _completer = Completer();
  }

  /// Connect to the remote `Socket` at [host] address and [port]
  ///
  /// [host] is the address of the remote `Socket`
  /// [port] is the port which is listening to
  Future<void> connect({required String host, required int port}) async =>
      _completer.complete(await Socket.connect(host, port));

  /// Syntactic sugar to easily retrieve the initialized `Socket`
  Future<Socket> get _socket => _completer.future;

  /// Send a `Message` [message]
  Future<void> sendMessage(Message message) async {
    Socket socket = await _socket;
    socket.writeln(jsonEncode(message.toJson()));
    await socket.flush();
  }
}
