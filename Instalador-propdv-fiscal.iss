[Setup]
#define DBFolder     "%ProgramFiles%\MariaDB 10.7\bin"

AppName=PROPDV NFCe - Sistema de Controle
AppVerName=PROPDV - Versão 3.8.0
AppCopyright=Copyright (C) 2003/2022 - Prodabit Sistemas e Automação Ltda
DefaultDirName={sd}\ProPDVFiscal
DefaultGroupName=PROPDVFiscal
UninstallDisplayIcon={app}\ClienteNFCeOS.exe
ShowTasksTreeLines=yes
OutputDir=F:\Projects\Instalador_2022\Output
OutputBaseFilename=Instalador.ProPDVFiscal
DisableWelcomePage=no
DisableDirPage=no
UserInfoPage=no
DisableProgramGroupPage=yes
;Compression=lzma2
;WizardStyle=modern
;OutputDir=C:\Temp\excluir


[Types]
Name: Cliente; Description: Instalação da versão Cliente
Name: Servidor; Description: Instalação da versão Servidor e Cliente
Name: Customizada; Description: Instalação Customizada; Flags: iscustom


[Components]
Name: Cliente;  Description: Arquivos do ProPDV.Cliente; Types: Cliente Customizada
Name: Servidor; Description: Arquivos do ProPDV.Servidor; Types: Servidor Customizada
Name: DataBase; Description: Instala o SGBD MariaDB; Types: Servidor Customizada
Name: LoadSQL;  Description: Importa Script da Base de Dados; Types: Servidor Customizada
Name: Manual;   Description: (PDF) Primeiros passos após instalação do sistema; Types: Cliente Servidor Customizada


[Tasks]
Name: SqlYog; Description: SQLYog (Gerenciador DataBase); Components: Servidor; Flags: unchecked
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
Name: {app}\Servidor\Arquivos; Components: Servidor
Name: {app}\Servidor\Arquivos\Schemas; Components: Servidor; Attribs: hidden;



[Files]
//-- Arquivos MySQL
Source: Support\SQLyog-12.0.6-0.x86Community.exe; DestDir: {tmp}; Tasks: SqlYog; Flags: deleteafterinstall
;Source: Support\FoxitReader80.exe; DestDir: {tmp}; Tasks: FoxitPDF; Flags: deleteafterinstall
;Source: Support\drivers_digitalpersona.zip; DestDir: {#ClientFolder}; Tasks: DigitalPersona 


//-- Arquivos Cliente
Source: Support\config_fiscal\Configurador.exe; DestDir: {app}\Cliente; Components: Cliente
Source: Support\config_fiscal\config.clt.ini; DestDir: {app}\Cliente; Components: Cliente
Source: Support\arquivos_cliente\*.*; DestDir:  {app}\Cliente; Components: Cliente


//-- Arquivos Servidor
Source: Support\config_fiscal\Configurador.exe; DestDir: {app}\Servidor; Components: Servidor
Source: Support\config_fiscal\config.srv.ini; DestDir: {app}\Servidor; Components: Servidor
Source: Support\arquivos_servidor\*.*; DestDir: {app}\Servidor; Components: Servidor


//-- Arquivos Fiscal
Source: Support\Schemas\*.*; DestDir: {app}\Servidor\Arquivos\Schemas; Components: Servidor
Source: Support\dlls_servidor_openssl\*.*; DestDir: {app}\Servidor; Components: Servidor


//-- Arquivos Auxiliares
Source: Imagens\*; Excludes: "*.db"; DestDir: {app}\Cliente\Imagens; Components: Cliente; Flags: ignoreversion recursesubdirs; 
Source: Support\dlls_pastasystem\*.*; DestDir: C:\Windows\System; Components: Cliente Servidor
Source: Support\Primeiros_Passos_Apos_Instalacao.pdf; DestDir: {app}; Components: Cliente Servidor


[Languages]
Name: brazilianportuguese; MessagesFile: compiler:Languages\BrazilianPortuguese.isl


[Icons]
Name: {commonprograms}\ProPDV\ProPDVFiscal; Filename: "{app}\Cliente\ClienteNFCeOS.exe"
Name: {userdesktop}\ProPDVFiscal; Filename: {app}\Cliente\ClienteNFCeOS.exe
Name: {commonstartup}\ServidorNFCeOS; Filename: "{app}\Servidor\ServidorNFCeOS.exe"
//-- iniciar do usuário
;Name: {userstartup}\ServidorDataSnap; Filename: "{app}\Servidor\ServidorDataSnapForm.exe"  


[Run]
//-- Instala e Configura o MariaDB
Filename: msiexec; Parameters: "/i {src}\mariadb-10.7.3-winx64.msi PORT=3308 PASSWORD=suat4321 SERVICENAME=MySQLPRO ADDLOCAL=ALL REMOVE=DEVEL,HeidiSQL /qn"; WorkingDir:{app}; StatusMsg: Aguarde... Instalando MariaDB-10.7.3;  Flags: runhidden
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""flush privileges;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Configuring Database Servers...; Flags: runhidden; Components: Servidor and DataBase;
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""create database IF NOT EXISTS propdvfiscal;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Criando DataBase ProPDVFiscal...; Flags: runhidden; Components: Servidor and DataBase;
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-e ""--max_allowed_packet=500000000;"" -uroot -psuat4321"; WorkingDir: {app}; StatusMsg: Configuring Max Allowed Packet...; Flags: runhidden; Components: Servidor and DataBase;

//-- Adicionamos a linha USE ProPDVFiscal; ao arquivo da base de dados
Filename: {cmd}; Parameters: "/c ""(echo USE ProPDVFiscal;) > {tmp}\temp.txt""";     Flags: runhidden waituntilterminated skipifdoesntexist; Components: Servidor and LoadSQL;
Filename: {cmd}; Parameters: "/c ""type {code:GetDataBaseFile} >> {tmp}\temp.txt"""; Flags: runhidden waituntilterminated skipifdoesntexist; Components: Servidor and LoadSQL; 
Filename: {cmd}; Parameters: "/c ""move /y {tmp}\temp.txt {code:GetDataBaseFile}"""; Flags: runhidden waituntilterminated skipifdoesntexist; Components: Servidor and LoadSQL; 


//-- Carrega base de dados inicial
Filename: {commonpf64}\MariaDB 10.7\bin\mysql.exe; Parameters: "-uroot -psuat4321 -e ""source {code:GetDataBaseFile}"""; Components: Servidor and LoadSQL; StatusMsg: "Carregando Base de Dados Inicial..."; Flags: runhidden waituntilterminated skipifdoesntexist; 

//-- Aqui fazemos 2 coisas: mandamos o MariaDB reiniciar caso tenha algum problema e Chamamos a função para alterar os dados no config.ini
Filename: {sys}\sc.exe; Parameters: "failure MySQLPro reset=0 actions=restart/0/restart/0/restart"; Flags: runhidden waituntilterminated skipifdoesntexist; BeforeInstall: AddInfosIniFile;

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
  InputQueryWizardPage: TInputQueryWizardPage;
  DataBaseFile: String;
  LocalCertificado: string;
  Serie: string;
  Senha: string;
  CSC, UF: string;


function GetComputerName(Param: string): string;
begin
  Result := GetComputerNameString();
end;  

function GetDataBaseFile(Param: string): string;
begin
  Result := DataBaseFile;
end;  


//-- Adiciona informações no arquivo config.clt.ini
//---------------------------------------------------
procedure AddInfosIniFile();
var
  i, j, TagPos: Integer;
  HostName, FileName, Line: string;    
  FileLines: TStringList;
begin  
  //-- Altera informações no config.clt.ini  
  FileName := ExpandConstant('{app}') + '\Cliente\config.clt.ini';
  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FileName);
    for i := 0 to FileLines.Count - 1 do begin
      Line := FileLines[I];
      TagPos := Pos('SRV0=Servidor|Servidor|9001', Line);
      if TagPos > 0 then begin
        HostName := GetComputerName('');
        Line := 'SRV0=' +HostName+ '|' +HostName+ '|9001';
        FileLines[I] := Line;
        FileLines.SaveToFile(FileName);
        Break;
      end;
    end;
  finally
    FileLines.Free;
  end;


  //-- Altera informações no config.srv.ini  
  //----------------------------------------------------------------
  (*FileName := ExpandConstant('{app}') + '\Servidor\config.srv.ini';
  FileLines := TStringList.Create;
  SearchStrings := TStringList.Create;

  SearchStrings.Add('Senha=123456');
  SearchStrings.Add('Senha=' + GetSenhaCertificado(''));

  SearchStrings.Add('NumSerie=serie_certificado');
  SearchStrings.Add('NumSerie=' + getSerieCertificado(''));

  SearchStrings.Add('CSC=123456789');
  SearchStrings.Add('CSC=' + getCSC(''));

  SearchStrings.Add('UF=UF');
  SearchStrings.Add('UF=' + getUF(''));

  try
    FileLines.LoadFromFile(FileName);
    for i := 0 to FileLines.Count - 1 do begin
      for j := 0 to SearchStrings.Count -1 do begin
        if((j mod 2) = 0) then begin
          Line := FileLines[I];
          TagPos := Pos(SearchStrings[j], Line);
          if TagPos > 0 then begin          
            Line := SearchStrings[j + 1]
            FileLines[I] := Line;
            FileLines.SaveToFile(FileName);
            Break;
          end;
        end;
      end;
    end;
  finally
    FileLines.Free;
    SearchStrings.Free;
  end;  *)
end;   


//-- Adiciona as páginas customizadas ao Wizard
//----------------------------------------------------------
procedure AddCustomQueryPage();
var
  AfterID: Integer;  
begin
  //WizardForm.LicenseAcceptedRadio.Checked := True;
  //WizardForm.PasswordEdit.Text := 'Senha Certificado';
  //WizardForm.UserInfoNameEdit.Text := 'Serie Certificado';

  AfterID := wpSelectTasks;
  //AfterID := CreateCustomPage(AfterID, 'CreateCustomPage', 'ADescription').ID;

  //-- Cria página para entrada da base de dados depois do Wizard Padrão
  Page := CreateInputFilePage(AfterID, 'BASE DE DADOS', 'Selecione o arquivo da Base de Dados a ser carregado', 'Deixe em branco se não for carregar base de dados neste momento.');
  Page.Add('&Arquivo da base de dados SQL:',                   // caption
           'Arquivos SQL|*.sql|Arquivos Bak|*.bak|Todos|*.*',  // filters
           '.sql');                                            // default extension
  AfterID := Page.ID;
  
  //-- Cria página para obter dados do Certificado depois da página da base de dados
  (*InputQueryWizardPage := CreateInputQueryPage(AfterID, 'CERTIFICADO DIGITAL', 'Informações sobre seu certificado para emissão de NFCe', 'Entre com os dados abaixo. Se não souber, informe-os nos configurador depois da instalação');
  InputQueryWizardPage.Add('&Série:', False);
  InputQueryWizardPage.Add('&Senha:', True);
  InputQueryWizardPage.Add('&Código CSC (Obtido pelo contador na Receita Estadual):', False);
  InputQueryWizardPage.Add('&UF:', False);
  AfterID := InputQueryWizardPage.ID; *)
  

  // Seta valor inicial para base de dados
  Page.Values[0] := ExpandConstant('c:\propdv\basedados.sql');
  //InputQueryWizardPage.Values[3] := 'RJ';
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
    wpReady: begin
      DataBaseFile := Page.Values[0]; 
      //LocalCertificado := ''; 
      //Serie := InputQueryWizardPage.Values[0];
      //Senha := InputQueryWizardPage.Values[1];
      //CSC   := InputQueryWizardPage.Values[2];      
      //UF    := InputQueryWizardPage.Values[3];      
    end;
    //wpSelectProgramGroup:
      //MsgBox('NextButtonClick:' #13#13 'You selected: ''' + WizardGroupValue + '''.', mbInformation, MB_OK);    
  end;

  Result := True;
end;







