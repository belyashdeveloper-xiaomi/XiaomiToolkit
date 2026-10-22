#!/data/data/com.termux/files/usr/bin/bash
set -e
mkdir -p App .github/workflows installer

cat > App/App.csproj <<'E'
<Project Sdk="Microsoft.NET.Sdk">
<PropertyGroup>
<OutputType>WinExe</OutputType>
<TargetFramework>net10.0-windows</TargetFramework>
<UseWPF>true</UseWPF>
<EnableWindowsTargeting>true</EnableWindowsTargeting>
</PropertyGroup>
</Project>
E

cat > App/App.xaml <<'E'
<Application x:Class="App"
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
StartupUri="MainWindow.xaml"/>
E

cat > App/App.xaml.cs <<'E'
using System.Windows;
public partial class App : Application {}
E

cat > App/MainWindow.xaml <<'E'
<Window x:Class="MainWindow"
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="Xiaomi Toolkit" Height="500" Width="800"
Background="#151521" Foreground="White">
<StackPanel Margin="20">
<TextBlock Text="XIAOMI TOOLKIT" FontSize="28"
Foreground="#BBA5FF" Margin="0,0,0,15"/>
<WrapPanel>
<Button Content="ADB devices" Click="Adb" Margin="4" Padding="10"/>
<Button Content="Fastboot devices" Click="Fb" Margin="4" Padding="10"/>
<Button Content="GSI guide" Click="Gsi" Margin="4" Padding="10"/>
</WrapPanel>
<TextBox x:Name="Out" Margin="0,15,0,0" Height="340"
Background="#222233" Foreground="White"
AcceptsReturn="True" TextWrapping="Wrap"
VerticalScrollBarVisibility="Auto"/>
</StackPanel>
</Window>
E

cat > App/MainWindow.xaml.cs <<'E'
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
E

cat > .github/workflows/build.yml <<'E'
name: Build
on:
  workflow_dispatch:
  push:
    branches: [main]
jobs:
  build:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    - run: dotnet publish App/App.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o publish
    - uses: actions/upload-artifact@v4
      with:
        name: XiaomiToolkit-Windows-x64
        path: publish/
E

zip -qr XiaomiToolkit-Source.zip App .github
echo "Готово: XiaomiToolkit-Source.zip"
