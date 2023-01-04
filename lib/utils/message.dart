import 'package:windows_mouse_server/utils/pair.dart';

class Message {
  final String action;
  final Pair<int, int> pair;

  const Message({required this.action, required this.pair});

  Message.fromJson(Map<String, dynamic> json)
      : action = json['action'] as String,
        pair = Pair<int, int>.fromJson(json['pair']);

  Map<String, dynamic> toJson() => {
        'action': action,
        'pair': pair.toJson(),
      };

  @override
  String toString() => 'Message: {action: $action, pair: $pair}';
}
