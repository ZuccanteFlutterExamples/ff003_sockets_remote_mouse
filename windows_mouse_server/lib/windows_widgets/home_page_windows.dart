import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
        (Socket socket) async {
          debugPrint('New Device Connected: ${socket.address.address}');
          Process process = await Process.start('powershell', []);
          process.stdin.writeln(
            'Add-Type -AssemblyName System.Windows.Forms;',
          );
          process.stdin.writeAll(
            '''
          \$cSource = @'
          using System;
          using System.Drawing;
          using System.Runtime.InteropServices;
          using System.Windows.Forms;
          public class Clicker
          {
          //https://msdn.microsoft.com/en-us/library/windows/desktop/ms646270(v=vs.85).aspx
          [StructLayout(LayoutKind.Sequential)]
          struct INPUT
          { 
              public int        type; // 0 = INPUT_MOUSE,
                                      // 1 = INPUT_KEYBOARD
                                      // 2 = INPUT_HARDWARE
              public MOUSEINPUT mi;
          }

          //https://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
          [StructLayout(LayoutKind.Sequential)]
          struct MOUSEINPUT
          {
              public int    dx ;
              public int    dy ;
              public int    mouseData ;
              public int    dwFlags;
              public int    time;
              public IntPtr dwExtraInfo;
          }

          //This covers most use cases although complex mice may have additional buttons
          //There are additional constants you can use for those cases, see the msdn page
          const int MOUSEEVENTF_MOVED      = 0x0001 ;
          const int MOUSEEVENTF_LEFTDOWN   = 0x0002 ;
          const int MOUSEEVENTF_LEFTUP     = 0x0004 ;
          const int MOUSEEVENTF_RIGHTDOWN  = 0x0008 ;
          const int MOUSEEVENTF_RIGHTUP    = 0x0010 ;
          const int MOUSEEVENTF_MIDDLEDOWN = 0x0020 ;
          const int MOUSEEVENTF_MIDDLEUP   = 0x0040 ;
          const int MOUSEEVENTF_WHEEL      = 0x0080 ;
          const int MOUSEEVENTF_XDOWN      = 0x0100 ;
          const int MOUSEEVENTF_XUP        = 0x0200 ;
          const int MOUSEEVENTF_ABSOLUTE   = 0x8000 ;

          const int screen_length = 0x10000 ;

          //https://msdn.microsoft.com/en-us/library/windows/desktop/ms646310(v=vs.85).aspx
          [System.Runtime.InteropServices.DllImport("user32.dll")]
          extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

          public static void LeftClickAtPoint(int x, int y)
          {
              //Move the mouse
              INPUT[] input = new INPUT[3];
              input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
              input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
              input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
              //Left mouse button down
              input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
              //Left mouse button up
              input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;
              SendInput(3, input, Marshal.SizeOf(input[0]));
          }
          }
          '@
          Add-Type -TypeDefinition \$cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing
          '''
                .split('\n'),
          );
          //process.stdin.writeln('Import-Module UIAutomation');
          process.stderr.listen((event) {
            debugPrint(event.toString());
          });
          process.stdout.drain();
          utf8.decoder
              .bind(socket)
              .map(
                (event) => event
                    .split('\n')
                    .where(
                      (element) => element.isNotEmpty,
                    )
                    .map(
                      (e) => Message.fromJson(json.decode(e)),
                    ),
              )
              .listen(
            (Iterable<Message> messages) async {
              int x = 0, y = 0;
              for (Message message in messages) {
                if (message.action == MessageAction.move) {
                  process.stdin.writeln(
                    '[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(${message.x},${message.y})',
                  );
                  x = message.x;
                  y = message.y;
                } else if (message.action == MessageAction.click) {
                  process.stdin.writeln(
                    '[Clicker]::LeftClickAtPoint($x,$y)',
                  );
                }
              }
            },
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
