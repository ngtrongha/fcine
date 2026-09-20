; Inno Setup script — F-Cine Windows installer
; Build: ISCC /DAPP_VERSION=1.0.0 windows\installer\fcine.iss
; (APP_VERSION defaults to the value below when not provided)

#ifndef APP_VERSION
  #define APP_VERSION "1.0.1"
#endif

[Setup]
AppId={{D8D7CA0B-2FAC-4EA3-B75C-5935EF0C9A74}
AppName=F-Cine
AppVersion={#APP_VERSION}
AppPublisher=FCine
AppPublisherURL=https://github.com/ngtrongha/fcine
DefaultDirName={autopf}\F-Cine
DefaultGroupName=F-Cine
DisableProgramGroupPage=yes
; Output is written to <repo root>\dist\
OutputDir=..\..\dist
OutputBaseFilename=fcine-windows-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequiredOverridesAllowed=dialog
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\fcine.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; \
    GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\F-Cine"; Filename: "{app}\fcine.exe"
Name: "{autodesktop}\F-Cine"; Filename: "{app}\fcine.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\fcine.exe"; Description: "{cm:LaunchProgram,F-Cine}"; \
    Flags: nowait postinstall skipifsilent
