// scrcpy-wireless.exe - tiny launcher that carries the app icon.
// Starts app\scrcpy-gui.ps1 with Windows PowerShell, without a console window.
// Built by launcher\build.ps1 with the C# compiler that ships with Windows
// (.NET Framework 4.x csc.exe); no extra SDK is needed.

using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

[assembly: AssemblyTitle("scrcpy Wireless Kit")]
[assembly: AssemblyProduct("scrcpy Wireless Kit")]
[assembly: AssemblyDescription("Launcher for scrcpy over Android Wireless debugging")]
[assembly: AssemblyVersion("1.1.1.0")]
[assembly: AssemblyFileVersion("1.1.1.0")]

static class Program
{
    [STAThread]
    static void Main()
    {
        bool ko = CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ko";
        string root = AppDomain.CurrentDomain.BaseDirectory;
        string app  = Path.Combine(root, "app");
        string gui  = Path.Combine(app, "scrcpy-gui.ps1");

        if (!File.Exists(gui) || !File.Exists(Path.Combine(app, "adb.exe")))
        {
            MessageBox.Show(
                ko ? "app 폴더를 찾을 수 없습니다.\nzip 파일의 압축을 모두 푼 뒤, scrcpy-wireless.exe와 app 폴더를 같은 위치에 두고 실행하세요."
                   : "The 'app' folder was not found.\nExtract the whole zip and keep scrcpy-wireless.exe next to the 'app' folder.",
                "scrcpy Wireless Kit", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        string ps = Path.Combine(Environment.SystemDirectory, @"WindowsPowerShell\v1.0\powershell.exe");
        var psi = new ProcessStartInfo(ps,
            "-NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File \"" + gui + "\"");
        psi.WorkingDirectory = app;
        psi.UseShellExecute  = false;
        psi.CreateNoWindow   = true;

        try { Process.Start(psi); }
        catch (Exception e)
        {
            MessageBox.Show(e.Message, "scrcpy Wireless Kit", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
