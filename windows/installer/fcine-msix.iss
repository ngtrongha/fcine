; Inno Setup bootstrapper — installs the F-Cine MSIX signing certificate
; into the trusted stores, then installs the MSIX package itself.
; Single double-click install: no manual certificate steps needed.
; Build: ISCC /DAPP_VERSION=1.0.0 windows\installer\fcine-msix.iss

#ifndef APP_VERSION
  #define APP_VERSION "1.0.1"
#endif

[Setup]
AppId={{D8D7CA0B-2FAC-4EA3-B75C-5935EF0C9A74}-MSIX}
AppName=F-Cine
AppVersion={#APP_VERSION}
AppPublisher=FCine
AppPublisherURL=https://github.com/ngtrongha/fcine
; Bootstrapper only: extracts to temp, installs cert + MSIX, nothing persistent
CreateAppDir=no
Uninstallable=no
OutputDir=..\..\dist
OutputBaseFilename=fcine-windows-msix-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; certutil -addstore Root requires elevation
PrivilegesRequired=admin

[Files]
Source: "..\..\windows\fcine-msix.cer"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "..\..\fcine.msix"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "certutil.exe"; Parameters: "-addstore -f ""Root"" ""{tmp}\fcine-msix.cer"""; \
    Flags: runhidden
Filename: "certutil.exe"; Parameters: "-addstore -f ""TrustedPeople"" ""{tmp}\fcine-msix.cer"""; \
    Flags: runhidden
Filename: "powershell.exe"; \
    Parameters: "-ExecutionPolicy Bypass -NoProfile -File ""{tmp}\install-msix.ps1"" -MsixPath ""{tmp}\fcine.msix"" -MinVersion ""{#APP_VERSION}.0"""; \
    Flags: runhidden waituntilterminated
Filename: "explorer.exe"; Parameters: "shell:AppsFolder\com.fcine.fcine!fcine"; \
    Description: "Launch F-Cine"; Flags: nowait postinstall skipifsilent
