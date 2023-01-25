import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:windows_mouse_server/android_widgets/home_page_android.dart';
import 'package:windows_mouse_server/utils/display_strings.dart';

import 'package:windows_mouse_server/windows_widgets/home_page_windows.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ColorScheme lightDefaultColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    );
    final ColorScheme darkDefaultColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    );
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) =>
          MaterialApp(
        title: DisplayStrings.appTitle,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ?? lightDefaultColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ?? darkDefaultColorScheme,
        ),
        home: Theme.of(context).platform == TargetPlatform.android
            ? const MyHomePageAndroid(title: DisplayStrings.appTitle)
            : const MyHomePageWindows(
                title: DisplayStrings.appTitle,
              ),
      ),
    );
  }
}
