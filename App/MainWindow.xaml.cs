using System.Diagnostics;
using System.Windows;
public partial class MainWindow : Window
{
 public MainWindow() {
  InitializeComponent();
  Out.Text="Xiaomi Toolkit 0.1\\nADB/Fastboot диагностика.";
 }
 async void Run(string exe,string args) {
  try {
   var p=new Process();
   p.StartInfo=new ProcessStartInfo(exe,args) {
    UseShellExecute=false,RedirectStandardOutput=true,
    RedirectStandardError=true,CreateNoWindow=true
   };
   p.Start();
   string a=await p.StandardOutput.ReadToEndAsync();
   string b=await p.StandardError.ReadToEndAsync();
   await p.WaitForExitAsync();
   Out.Text=a+"\\n"+b;
  } catch(Exception e) { Out.Text=e.Message; }
 }
 void Adb(object s,RoutedEventArgs e)=>Run("adb","devices -l");
 void Fb(object s,RoutedEventArgs e)=>Run("fastboot","devices");
 void Gsi(object s,RoutedEventArgs e)=>Out.Text=
  "GSI checklist:\\n1. Check exact device model.\\n"+
  "2. Check Treble and image architecture.\\n"+
  "3. Backup data.\\n4. Verify recovery method.";
}
