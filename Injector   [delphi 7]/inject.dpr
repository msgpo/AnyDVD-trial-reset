////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
///                                                                              ///
///           AnyDVD trial reset injecter by JohnWho{TEAM RESURRECTiON}          /// 
///                                                                              ///
///              Using Avanced API Hook by Ms-Rem (great stuff, thx)             ///
///                                                                              ///
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
program inject;

uses
      windows, messages, registry, SHFolder, classes, sysutils, advApiHook;

const
      ID_Dialog     = 101;
      ID_Reset      = 1002;
      ID_Exit       = 1004;

Var

  hDlg:dword = 0;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  Reg:TRegistry;
  path,exe,fname: string;
  rStream: TResourceStream;
  fStream: TFileStream;
  delfiles,dllpath,fullpath:string;

{$R resource.RES}

{$R Dlg.res}




function GetSpecialFolderPath(folder : integer) : string;
 const
   SHGFP_TYPE_CURRENT = 0;
var
   path: array [0..MAX_PATH] of char;
begin
   if SUCCEEDED(SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0])) then
     Result := path
   else
     Result := '';
end;





procedure reset();
begin

  ZeroMemory(@StartInfo, SizeOf(TStartupInfo));
  StartInfo.cb := SizeOf(TStartupInfo);


  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartInfo.wShowWindow := SW_HIDE;

 Reg := TRegistry.Create;

 Reg.RootKey := HKEY_LOCAL_MACHINE;
 Reg.OpenKey('\SOFTWARE\SlySoft\AnyDVD',false);
 path:=Reg.ReadString('Path');
 exe:=Reg.ReadString('Path')+'\AnyDVDtray.exe';
 Reg.CloseKey;

 if not fileExists(exe) then
 begin
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 Reg.OpenKey('\SOFTWARE\Wow6432Node\SlySoft\AnyDVD',false);
 path:=Reg.ReadString('Path');
 exe:=Reg.ReadString('Path')+'\AnyDVDtray.exe';
 Reg.CloseKey;
 end;


/////////////////////// not needed for trial resetting /////////////////////////

        Reg.RootKey := HKEY_LOCAL_MACHINE;

        if Reg.KeyExists('\SOFTWARE\SlySoft\AnyDVD\Key\') then
        begin
        Reg.OpenKey('\SOFTWARE\SlySoft\AnyDVD\',false);
        Reg.DeleteKey('Key');
        Reg.CloseKey;
        end;

        if Reg.KeyExists('\SOFTWARE\Wow6432Node\SlySoft\AnyDVD\Key\') then
        begin
        Reg.OpenKey('\SOFTWARE\Wow6432Node\SlySoft\AnyDVD\',false);
        Reg.DeleteKey('Key');
        Reg.CloseKey;
        end;

////////////////////////////////////////////////////////////////////////////////



 Reg.Free;


 if not fileExists(exe) then
 begin
 MessageBox(0, 'AnyDVD doesn´t seem to be installed on your system!','Error',0);
 Exit;
 end;




/////////////////////// not needed for trial resetting /////////////////////////

 delfiles := dllpath + '\SlySoft\AnyDVD\';

    If  FileExists(delfiles+'AnyDVD.lic') then DeleteFile(delfiles+'AnyDVD.lic');
    If  FileExists(delfiles+'AnyDVD.chk') then DeleteFile(delfiles+'AnyDVD.chk');

////////////////////////////////////////////////////////////////////////////////



 dllpath := PAnsiChar(GetSpecialFolderPath(CSIDL_COMMON_APPDATA));


     fname:=dllpath+'\data.dll';
     rStream := TResourceStream.Create
                (hInstance, 'data', RT_RCDATA);
     try
      fStream := TFileStream.Create(fname, fmCreate);
      try
       fStream.CopyFrom(rStream, 0);
      finally
       fStream.Free;
      end;
     finally
      rStream.Free;
     end;


  CreateProcess(nil, pchar(exe), nil, nil, False, 0,nil, nil, StartInfo, ProcInfo);

  Sleep(50);

  fullpath := dllpath + '\data.dll';

  InjectDll(ProcInfo.hProcess, pchar(fullpath));

  sleep(100);

  MessageBox(0, 'Reset process done','Done',0);

  DeleteFile(fullpath);

end;









    
function DlgFunc(hWnd: hWnd; uMSG: DWord; wParam: wParam; lParam: lParam): Bool; stdcall;
begin
  result := true;

  case umsg of

    WM_LBUTTONDOWN:
      SendMessage(hWnd, WM_SYSCOMMAND, 61458, 0);

    WM_INITDIALOG:
      begin
      end;

    WM_CLOSE:
      begin
      EndDialog(hWnd, 0);
      end;

    WM_DESTROY:
      begin
      PostQuitMessage(0);
      end;

    WM_COMMAND:
      begin
      if ((hiWord(wParam) = BN_CLICKED) and (loword(wparam) = ID_Reset)) then
           reset;

      if ((hiWord(wParam) = BN_CLICKED) and (loword(wparam) = ID_Exit)) then
           SendMessage(hwnd, WM_CLOSE, 0, 0);
      end
   else result := false;
  end;
end;

begin
  hDlg := DialogBoxParam(HInstance, MAKEINTRESOURCE(ID_Dialog), 0, @DlgFunc, 0);
end.








