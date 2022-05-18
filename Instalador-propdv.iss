; IMPORTANTE : O arquivo de Saida está nas pasta Instalador/Output
; -- Sample3.iss --
; Same as Sample1.iss, but creates some registry entries too.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!


[Setup]
#define DBFolder     "%ProgramFiles%\MariaDB 10.7\bin"

AppName=PROPDV - Sistema de Controle
AppVerName=PROPDV - Versão 3.8.0
AppCopyright=Copyright (C) 2003/2022 - Prodabit Sistemas e Automação Ltda
DefaultDirName={sd}\ProPDV
DefaultGroupName=PROPDV
UninstallDisplayIcon={app}\ProPDVCliente.exe
ShowTasksTreeLines=yes
OutputDir=F:\Projects\Instalador_2022\Output
OutputBaseFilename=Instalador.ProPDV
DisableWelcomePage=no
DisableDirPage=no
UserInfoPage=no
;Compression=lzma2
;WizardStyle=modern
;OutputDir=C:\Temp\excluir


[Types]
Name: Cliente; Description: Instalação da versão Cliente
Name: Servidor; Description: Instalação da versão Servidor e Cliente
Name: Customizada; Description: Instalação Customizada; Flags: iscustom


[Components]
Name: Cliente; Description: Arquivos do ProPDV.Cliente; Types: Cliente Customizada
Name: Servidor; Description: Arquivos do ProPDV.Servidor; Types: Servidor Customizada
Name: Manual; Description: (PDF)Primeiros passos após instalação do sistema; Types: Cliente Servidor Customizada


[Tasks]
Name: SqlYog; Description: Gerenciador DB; Components: Servidor; Flags: unchecked
;Name: FoxitPDF; Description: Foxit PDF Reader; Components: Cliente Servidor; Flags: unchecked
;Name: DigitalPersona; Description: Drivers Leitor Biométrico; Components: Cliente; Flags: unchecked


[Dirs]
Name: {app}\Cliente; Components: Cliente
Name: {app}\Servidor; Components: Servidor
Name: {app}\Backup; Components: Servidor
Name: {app}\Cliente\imagens; Components: Cliente
Name: {app}\Cliente\imagens\categorias; Components: Cliente
Name: {app}\Cliente\imagens\produtos; Components: Cliente
Name: {app}\Cliente\imagens\layout; Components: Cliente


[Files]
//-- Arquivos MySQL
Source: Support\SQLyog-12.0.6-0.x86Community.exe; DestDir: {tmp}; Tasks: SqlYog; Flags: deleteafterinstall
;Source: Support\FoxitReader80.exe; DestDir: {tmp}; Tasks: FoxitPDF; Flags: deleteafterinstall
;Source: Support\drivers_digitalpersona.zip; DestDir: {#ClientFolder}; Tasks: DigitalPersona 

//-- Arquivos Cliente
Source: Support\config_nao_fiscal\config.clt.ini; DestDir: {app}\Cliente; Components: Cliente
Source: Support\arquivos_cliente\*.*; DestDir:  {app}\Cliente; Components: Cliente

//-- Arquivos Servidor
Source: Support\config_nao_fiscal\config.srv.ini; DestDir: {app}\Servidor; Components: Servidor
Source: Support\arquivos_servidor\*.*; DestDir: {app}\Servidor; Components: Servidor

//-- Arquivos Auxiliares
Source: Imagens\*; Excludes: "*.db"; DestDir: {app}\Cliente\Imagens; Components: Cliente; Flags: ignoreversion recursesubdirs; 
Source: Support\dlls_pastasystem\*.*; DestDir: C:\Windows\System; Components: Cliente Servidor
Source: Support\Primeiros_Passos_Apos_Instalacao.pdf; DestDir: {app}; Components: Cliente Servidor


[Languages]
Name: brazilianportuguese; MessagesFile: compiler:Languages\BrazilianPortuguese.isl


[Icons]
Name: {commonprograms}\ProPDV\ProPDV; Filename: "{app}\Cliente\ProPDVCliente.exe"
Name: {userdesktop}\ProPDV; Filename: {app}\Cliente\ProPDVCliente.exe

//-- iniciar do usuário
;Name: {userstartup}\ServidorDataSnap; Filename: "{app}\Servidor\ServidorDataSnapForm.exe"  

//-- iniciar do Sistema
Name: {commonstartup}\ServidorDataSnap; Filename: "{app}\Servidor\ServidorDataSnapForm.exe";


[Run]
//-- Instala e Configura o MariaDB
Filename: msiexec; Parameters: "/i {src}\mariadb-10.7.3-winx64.msi PORT=3308 PASSWORD=suat4321 SERVICENAME=MySQLPRO ADDLOCAL=ALL REMOVE=DEVEL,HeidiSQL /qn"; WorkingDir:{app}; StatusMsg: Aguarde... Instalando MariaDB-10.7.3;  Flags: runhidden
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""flush privileges;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Configuring Database Servers; Flags: runhidden
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""create database IF NOT EXISTS propdv;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Criando DataBase ProPDV; Flags: runhidden
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""--max_allowed_packet=500000000;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Configuring Max Allowed Packet; Flags: runhidden

//-- Adicionamos a linha USE ProPDV; ao arquivo da base de dados
Filename: {cmd}; Parameters: "/c ""(echo USE ProPDV;) > {tmp}\temp.txt""";           Flags: runhidden waituntilterminated skipifdoesntexist; 
Filename: {cmd}; Parameters: "/c ""type {code:GetDataBaseFile} >> {tmp}\temp.txt"""; Flags: runhidden waituntilterminated skipifdoesntexist; 
Filename: {cmd}; Parameters: "/c ""move /y {tmp}\temp.txt {code:GetDataBaseFile}"""; Flags: runhidden waituntilterminated skipifdoesntexist; 


//-- Carrega base de dados inicial
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-uroot -psuat4321 -e ""source {code:GetDataBaseFile}"""; StatusMsg: "Carregando Base de Dados Inicial"; Flags: runhidden waituntilterminated skipifdoesntexist;

//-- Aqui fazemos 2 coisas: mandamos o MariaDB reiniciar caso tenha algum problema e Chamamos a função para alterar o HostName no config.clt
Filename: {sys}\sc.exe; Parameters: "failure MySQLPro reset=0 actions=restart/0/restart/0/restart"; Flags: runhidden waituntilterminated skipifdoesntexist; BeforeInstall: AddHostNameIniFile;

;Instala o SQLYog
Filename: {tmp}\SQLyog-12.0.6-0.x86Community.exe; Parameters: /S; WorkingDir: {tmp}; StatusMsg: Instalando Gerenciador SQLYog; Flags: runhidden; Tasks: SqlYog; 

; Instala o Foxit PDF
;Filename: {tmp}\FoxitReader80.exe; Parameters: "/S /VERYSILENT /NORESTART" ; WorkingDir: {tmp}; StatusMsg: Instalando Foxit PDF; Flags: runhidden; Tasks: FoxitPDF;


[Registry]
; Adiciona o MariaDB no Path do Windows
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{#DBFolder}"


[Setup]
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes


[code]
var
  Page: TInputFileWizardPage;
  DataBaseFile: String;


function GetComputerName(Param: string): string;
begin
  Result := GetComputerNameString();
end;  

function GetDataBaseFile(Param: string): string;
begin
  Result := DataBaseFile;
end;  

procedure AddHostNameIniFile();
var
  i, TagPos: Integer;
  HostName, FileName, Line: string;    
  FileLines: TStringList;
begin  
  FileName := ExpandConstant('{app}') + '\Cliente\config.clt.ini';

  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FileName);
    for i := 0 to FileLines.Count - 1 do begin
      Line := FileLines[I];
      TagPos := Pos('SRV0=Servidor|Servidor|8085', Line);
      if TagPos > 0 then begin
        HostName := GetComputerName('');
        Line := 'SRV0=' +HostName+ '|' +HostName+ '|8085';
        FileLines[I] := Line;
        FileLines.SaveToFile(FileName);
        Break;
      end;
    end;
  finally
    FileLines.Free;
  end;
end;   


procedure AddCustomQueryPage();
begin
  Page := CreateInputFilePage(wpWelcome, 'Selecione o arquivo da Base de Dados a ser carregado', 'Deixe em branco se não quer carregar base de dados.', '');

  // Add item
  Page.Add('&Localização da base de dados:',                   // caption
           'Arquivos SQL|*.sql|Arquivos Bak|*.bak|Todos|*.*',  // filters
           '.sql');                                            // default extension

  // Set initial value (optional)
  Page.Values[0] := ExpandConstant('c:\propdv\basedados.sql');
end;


procedure InitializeWizard();
begin
  AddCustomQueryPage();  
end;


function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  case CurPageID of
    100: 
      DataBaseFile := Page.Values[0]; 
    //wpSelectDir:
      //MsgBox('NextButtonClick:' #13#13 'You selected: ''' + WizardDirValue + '''.', mbInformation, MB_OK);
    //wpSelectProgramGroup:
      //MsgBox('NextButtonClick:' #13#13 'You selected: ''' + WizardGroupValue + '''.', mbInformation, MB_OK);    
  end;

  Result := True;
end;







