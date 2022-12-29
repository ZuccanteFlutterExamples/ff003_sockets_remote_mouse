import 'package:flutter/material.dart';
import 'package:windows_mouse_server/android_widgets/home_page_android.dart';

import 'package:windows_mouse_server/windows_widgets/home_page_windows.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.windows) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePageWindows(title: 'Remote mouse controller!'),
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePageAndroid(title: 'Remote mouse controller!'),
      );
    }
  }
}
