// 2>nul||@goto :batch
/*
:batch
@echo off
setlocal

:: find csc.exe
set "csc="
for /r "%SystemRoot%\Microsoft.NET\Framework\" %%# in ("*csc.exe") do  set "csc=%%#"

if not exist "%csc%" (
   echo no .net framework installed
   exit /b 10
)

if not exist "%~n0.exe" (
   call %csc% /nologo /warn:0 /out:"%~n0.exe" "%~dpsfnx0" || (
      exit /b %errorlevel% 
   )
)
%~n0.exe %*
endlocal & exit /b %errorlevel%

*/

using System;
using System.Runtime.InteropServices;

namespace MouseMover
{
    public class MouseSimulator
    {
        [DllImport("user32.dll", SetLastError = true)]
        static extern uint SendInput(uint nInputs, ref INPUT pInputs, int cbSize);

        [StructLayout(LayoutKind.Sequential)]
        struct INPUT
        {
            public SendInputEventType type;
            public MouseKeybdhardwareInputUnion mkhi;
        }
        [StructLayout(LayoutKind.Explicit)]
        struct MouseKeybdhardwareInputUnion
        {
            [FieldOffset(0)]
            public MouseInputData mi;

            [FieldOffset(0)]
            public KEYBDINPUT ki;

            [FieldOffset(0)]
            public HARDWAREINPUT hi;
        }
        [StructLayout(LayoutKind.Sequential)]
        struct KEYBDINPUT
        {
            public ushort wVk;
            public ushort wScan;
            public uint dwFlags;
            public uint time;
            public IntPtr dwExtraInfo;
        }
        [StructLayout(LayoutKind.Sequential)]
        struct HARDWAREINPUT
        {
            public int uMsg;
            public short wParamL;
            public short wParamH;
        }
        struct MouseInputData
        {
            public int dx;
            public int dy;
            public uint mouseData;
            public MouseEventFlags dwFlags;
            public uint time;
            public IntPtr dwExtraInfo;
        }

        [Flags]
        enum MouseEventFlags : uint
        {
            MOUSEEVENTF_MOVE = 0x0001,
            MOUSEEVENTF_LEFTDOWN = 0x0002,
            MOUSEEVENTF_LEFTUP = 0x0004,
            MOUSEEVENTF_RIGHTDOWN = 0x0008,
            MOUSEEVENTF_RIGHTUP = 0x0010,
            MOUSEEVENTF_MIDDLEDOWN = 0x0020,
            MOUSEEVENTF_MIDDLEUP = 0x0040,
            MOUSEEVENTF_XDOWN = 0x0080,
            MOUSEEVENTF_XUP = 0x0100,
            MOUSEEVENTF_WHEEL = 0x0800,
            MOUSEEVENTF_VIRTUALDESK = 0x4000,
            MOUSEEVENTF_ABSOLUTE = 0x8000
        }
        enum SendInputEventType : int
        {
            InputMouse,
            InputKeyboard,
            InputHardware
        }

        static void Jiggle()
        {
            int mouseDistance = 1; // num of pixels
            int moveSpeed = (int)(0.1 * 1000); // 1/10 of a second

            while(true)
            {
                MoveMouseBy(mouseDistance, 0);
                System.Threading.Thread.Sleep(moveSpeed);
                MoveMouseBy(0, -1 * (mouseDistance));
                System.Threading.Thread.Sleep(moveSpeed);
                MoveMouseBy(-1 * (mouseDistance), 0);
                System.Threading.Thread.Sleep(moveSpeed);
                MoveMouseBy(0, mouseDistance);
                System.Threading.Thread.Sleep(moveSpeed);
            }
        }

        static void MoveMouseBy(int x, int y) {
            INPUT mouseInput = new INPUT();
            mouseInput.type = SendInputEventType.InputMouse;
            mouseInput.mkhi.mi.dwFlags = MouseEventFlags.MOUSEEVENTF_MOVE;
            mouseInput.mkhi.mi.dx = x;
            mouseInput.mkhi.mi.dy = y;
            SendInput(1, ref mouseInput, Marshal.SizeOf(mouseInput));
        }

       static void PrintHelp() {
            String filename = Environment.GetCommandLineArgs()[0];
            filename = filename.Substring(0, filename.Length);
        }

        public static void Main(String[] args) {
            if (args.Length == 0) {
                Jiggle();
            }
            else
            {
                Console.WriteLine("Invalid action : " + args[0]);
                System.Environment.Exit(10);
            }
        }


    }
}
