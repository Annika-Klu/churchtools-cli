[Setup]
AppName=CT CLI Installer
AppVersion=__RELEASE_TAG__
DefaultDirName={userappdata}\CTCLI
DefaultGroupName=CTCLI
OutputDir=installer
OutputBaseFilename=ct-cli-installer
Compression=lzma
SolidCompression=yes
SetupIconFile=__ICON_PATH__

[Files]
Source: "installer\installer.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "installer\icon.ico"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -NoLogo -NoProfile -WindowStyle Hidden -File ""{tmp}\installer.ps1"""; StatusMsg: "CLI wird installiert..."; Flags: runhidden

[Icons]
Name: "{group}\Churchtools CLI starten"; Filename: "powershell.exe"; Parameters: "-NoLogo -NoProfile -Command ct hilfe"