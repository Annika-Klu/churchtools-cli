[Setup]
AppName=CT CLI Installer
AppVersion=__RELEASE_TAG__
DefaultDirName={userprofile}\.ct
DisableDirPage=yes
DefaultGroupName=CTCLI
OutputDir=installer
OutputBaseFilename=ct-cli-installer
Compression=lzma
SolidCompression=yes
SetupIconFile=icon.ico

[Files]
Source: "installer.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "icon.ico"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -NoLogo -NoProfile -WindowStyle Hidden -File ""{tmp}\installer.ps1"""; StatusMsg: "CLI wird installiert..."; Flags: runhidden

[Icons]
Name: "{group}\Churchtools CLI starten"; Filename: "powershell.exe"; Parameters: "-NoLogo -NoProfile -Command ct hilfe"