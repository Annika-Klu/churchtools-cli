[Setup]
AppName=CT CLI Installer
AppVersion=__RELEASE_TAG__
DefaultDirName={userappdata}\..\ .ct
DisableDirPage=yes
DefaultGroupName=CTCLI
OutputDir=.
OutputBaseFilename=ct-cli-installer
Compression=lzma
SolidCompression=yes
SetupIconFile=icon.ico
AppPublisher=__PUBLISHER_NAME__
AppPublisherURL=__PUBLISHER_URL__
AppContact=__PUBLISHER_EMAIL__ 

[Files]
Source: "installer.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "icon.ico"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -NoLogo -NoProfile -WindowStyle Hidden -File ""{tmp}\installer.ps1"""; StatusMsg: "CLI wird installiert..."; Flags: runhidden

[Icons]
Name: "{group}\Churchtools CLI starten"; Filename: "powershell.exe"; Parameters: "-NoLogo -NoProfile -Command ct hilfe"