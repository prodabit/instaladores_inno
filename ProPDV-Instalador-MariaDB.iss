; IMPORTANTE : O arquivo de Saida está nas pasta Instalador/Output
; -- Sample3.iss --
; Same as Sample1.iss, but creates some registry entries too.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

#define ClientFolder "C:\ProPDV\Cliente"
#define ServerFolder "C:\ProPDV\Servidor"
#define ImagesFolder "C:\ProPDV\Cliente\Imagens"
#define DBFolder     "%ProgramFiles%\MariaDB 10.7\bin"
#define MyAppName    "ProPDV"



[Setup]
AppName=PROPDV - Sistema de Controle
AppVerName=PROPDV - Versão 3.8.0
AppCopyright=Copyright (C) 2003/2022 - Prodabit Sistemas e Automação Ltda
DefaultDirName={sd}\ProPDV
DefaultGroupName=PROPDV
UninstallDisplayIcon={app}\ProPDVCliente.exe
ShowTasksTreeLines=yes
OutputDir=F:\Instalador_2022\Output
;OutputDir=C:\Temp\excluir


[Types]
Name: Cliente; Description: Instalação da versão Cliente
Name: Servidor; Description: Instalação da versão Servidor e Cliente
Name: Customizada; Description: Instalação Customizada; Flags: iscustom


[Components]
Name: Cliente; Description: Arquivos do ProPDV.Cliente; Types: Cliente Customizada
Name: Servidor; Description: Arquivos do ProPDV.Servidor; Types: Servidor Customizada
Name: Manual; Description: Manual do Usuário; Types: Cliente Servidor Customizada


[Tasks]
Name: SqlYog; Description: Gerenciador DB; Components: Servidor; Flags: unchecked
Name: FoxitPDF; Description: Foxit PDF Reader; Components: Cliente Servidor; Flags: unchecked
Name: DigitalPersona; Description: Drivers Leitor Biométrico; Components: Cliente; Flags: unchecked


[Dirs]
Name: C:\ProPDV\Cliente; Components: Cliente
Name: C:\ProPDV\Servidor; Components: Servidor
Name: C:\ProPDV\Backup; Components: Servidor
Name: C:\ProPDV\Cliente\imagens; Components: Cliente
Name: C:\ProPDV\Cliente\imagens\categorias; Components: Cliente
Name: C:\ProPDV\Cliente\imagens\produtos; Components: Cliente
Name: C:\ProPDV\Cliente\imagens\layout; Components: Cliente


[Files]
; Arquivos MySQL
Source: Support\SQLyog-12.0.6-0.x86Community.exe; DestDir: {tmp}; Tasks: SqlYog; Flags: deleteafterinstall
Source: Support\FoxitReader80.exe; DestDir: {tmp}; Tasks: FoxitPDF; Flags: deleteafterinstall
Source: Support\drivers_digitalpersona.zip; DestDir: {#ClientFolder}; Tasks: DigitalPersona 

;Arquivos Cliente
Source: config.clt.ini; DestDir: C:\ProPDV\Cliente; Components: Cliente
Source: Support\dlls_cliente\*.*; DestDir:  {#ClientFolder}; Components: Cliente

;Arquivos Servidor
Source: Support\mariadb-10.7.3-winx64.msi; DestDir: "{tmp}"; Components: Servidor
Source: config.srv.ini; DestDir: {#ServerFolder}; Components: Servidor
Source: Support\dlls_servidor\*.*; DestDir:  {#ClientFolder}; Components: Servidor
Source: iniciar-windows.txt; DestDir: {#ServerFolder}; Components: Servidor


;Arquivos Auxiliares
Source: Imagens\*; DestDir: {#ImagesFolder}; Components: Cliente; Flags: ignoreversion recursesubdirs; 
Source: Support\dlls_pastasystem\*.*; DestDir: C:\Windows\System; Components: Cliente Servidor
Source: Support\mysqldump.exe; DestDir: C:\ProPDV\Servidor; Components: Servidor
Source: Support\mysqldump_64.exe; DestDir: C:\ProPDV\Servidor; Components: Servidor


[Languages]
Name: brazilianportuguese; MessagesFile: compiler:Languages\BrazilianPortuguese.isl


[Icons]
Name: {commonprograms}\ProPDV\ProPDV; Filename: C:\ProPDV\Cliente\ProPDVCliente.exe
Name: {userdesktop}\ProPDV; Filename: C:\ProPDV\Cliente\ProPDVCliente.exe


[Run]
;Filename: msiexec; Parameters: "/i {tmp}\mariadb-10.7.3-winx64.msi PORT=3308 PASSWORD=suat4321 SERVICENAME=MySQLPRO /qn"; WorkingDir:{app}; StatusMsg: Aguarde... Instalando MariaDB-10.7.3;  Flags: runhidden
Filename: mysql.exe; Parameters: "-e ""flush privileges;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Configuring Database Servers; Flags: runhidden
;Filename: mysql.exe; Parameters: "-uroot -psuat4321 -e ""source {app}\script.sql"""; StatusMsg: "Carregando Base de Dados Inicial"; Flags: runhidden waituntilterminated;

;Instala o SQLYog
;Filename: {tmp}\SQLyog-12.0.6-0.x86Community.exe; Parameters: /S; WorkingDir: {tmp}; StatusMsg: Instalando Gerenciador SQLYog; Flags: runhidden; Tasks: SqlYog;


[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{#DBFolder}"


[Setup]
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes


; Cria atalho no Windows 10
[Icons]
Name: "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\ServidorDataSnap"; Filename: "{#ServerFolder}\ServidorDataSnapForm.exe"; WorkingDir: "{app}"





