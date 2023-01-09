import 'package:windows_mouse_server/utils/pair.dart';

class Message {
  final String action;
  final Pair<int, int> pair;

  /// A `Message` is defined by the [action] performed in a certain [point]
  ///
  /// [action] is a String that represent what the receiver must do
  /// [point] is the location that an action must be performed.
  /// The original purpose of this object is to represent a mouse action.
  const Message({required this.action, required this.pair});

  /// Initialize a `Message` from its [json] representation
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        action: json['action'],
        pair: Pair.fromJson(json['pair']),
      );

  /// Convert the `Message` to its _json_ representation
  Map<String, dynamic> toJson() => {
        'action': action,
        'pair': pair.toJson(),
      };

  @override
  String toString() => 'Message: {action: $action, pair: $pair}';
}
