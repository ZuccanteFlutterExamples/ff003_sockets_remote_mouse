import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:windows_mouse_server/utils/display_strings.dart';

class ScannerPage extends StatefulWidget {
  /// Page used to scan a QR code
  ///
  /// [title] is used for the `Scaffold AppBar` title
  const ScannerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) {
          if (barcode.rawValue == null) {
            debugPrint(DisplayStrings.scanError);
          } else {
            final String code = barcode.rawValue!;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
