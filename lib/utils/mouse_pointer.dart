import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windows_mouse_server/utils/pair.dart';

class MousePointer {
  static late Completer<Process> _completer;
  static MousePointer? _mousePointer;
  static const String _configuration = '''
Add-Type -AssemblyName System.Windows.Forms;
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
''';

  /// Private constructor
  MousePointer._();

  /// This is the method used to get an instance of the `MousePointer` class.
  factory MousePointer.instance() {
    if (_mousePointer == null) {
      _mousePointer = MousePointer._();
      _completer = Completer();
      Process.start('powershell', []).then(
        (Process process) {
          // stderr.listen listens to the standard error stream so that whenever
          // an error occur it will be printed out by the debugPrint function.
          process.stderr.listen(
            (error) => debugPrint('ERROR: ${error.toString()}'),
          );

          // draining the standard output allows to continue processing the standard input
          process.stdout.drain();
          process.stdin.writeln(_configuration);
          _completer.complete(process);
        },
      );
    }
    return _mousePointer!;
  }

  /// This method is used to execute a powershell command [action].
  Future<void> _execute(String action) async {
    Process process = await _completer.future;
    process.stdin.writeln(action);
  }

  /// Call this to construct the specific powershell command to move the mouse to [point]
  static String _getMove(Pair<int, int> point) =>
      '[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(${point.first}, ${point.second})';

  /// Call this to construct the specific powershell command to click the mouse in [point]
  static String _getLeftClick(Pair<int, int> point) =>
      '[Clicker]::LeftClickAtPoint(${point.first}, ${point.second})';

  /// Moves the mouse to [point]
  Future<void> move(Pair<int, int> point) async =>
      await _execute(_getMove(point));

  /// Clicks the mouse in [point]
  Future<void> leftClick(Pair<int, int> point) async =>
      await _execute(_getLeftClick(point));
}
