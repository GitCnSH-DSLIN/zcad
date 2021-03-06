{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzcsysinfo;
{$INCLUDE def.inc}
interface
uses MacroDefIntf,uzmacros,uzcsysparams,LCLProc,uzclog,uzbpaths,uzbtypesbase,Forms,uzbtypes{$IFNDEF DELPHI},{fileutil}LazUTF8{$ENDIF},sysutils;
{$INCLUDE revision.inc}
const
  zcaduniqueinstanceid='zcad unique instance';
type
  TZCADPathsMacroMethods=class
    class function MacroFuncZCADPath(const {%H-}Param: string; const Data: PtrInt;
                                       var {%H-}Abort: boolean): string;
    class function MacroFuncTEMPPath(const {%H-}Param: string; const Data: PtrInt;
                                       var {%H-}Abort: boolean): string;
  end;
var
  SysDefaultFormatSettings:TFormatSettings;
  disabledefaultmodule:boolean;

Procedure GetSysInfo;
implementation
function GetVersion({_file:pchar}):TmyFileVersionInfo;
var
 (*VerInfoSize, Dummy: DWord;
 PVerBbuff, PFixed : GDBPointer;
 FixLength : UINT;*)

  i: Integer;
  //Version: TFileVersionInfo;
  {MyFile,} MyVersion{,ts}: GDBString;

begin
     result.build:=0;
     result.major:=0;
     result.minor:=0;
     result.release:=0;

     {Version:=TFileVersionInfo.create(Nil);
     Version.fileName:=_file;

     With Version do begin
       For i:=0 to VersionStrings.Count-1 do begin
         If VersionCategories[I]='FileVersion' then
         begin
           MyVersion := VersionStrings[i];
           break;
         end;
       end;
     end;}

     result.major:=0;
     result.minor:=9;
     result.release:=8;

     MyVersion:=inttostr(result.major)+'.'+inttostr(result.minor)+'.'+inttostr(result.release)+'.'+Revision;
     result.versionstring:=MyVersion;

     val(Revision,result.revision,i);


(* fillchar(result,sizeof(result),0);
 VerInfoSize := GetFileVersionInfoSize(_file, Dummy);
 if VerInfoSize = 0 then Exit;
 GetMem(PVerBbuff, VerInfoSize);
 try
   if GetFileVersionInfo(_file,0,VerInfoSize,PVerBbuff) then
   begin
     if VerQueryValue(PVerBbuff,'\',PFixed,FixLength) then
     begin
       result.major:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Hi;
       result.minor:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Lo;
       result.release:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Hi;
       result.build:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Lo;
     end;
   end;
 finally
   FreeMem(PVerBbuff);
 end;*)
end;

procedure ProcessParamStr;
var
   i:integer;
   param,paramUC:GDBString;
const
  LogEnableModulePrefix='LEM_';
  LogDisableModulePrefix='LDM_';
begin
     //programlog.LogOutStr('ProcessParamStr',lp_IncPos,LM_Necessarily);
     debugln('{N+}ProcessParamStr');
     SysParam.notsaved.otherinstancerun:=false;
     SysParam.saved.UniqueInstance:=true;
     LoadParams(expandpath(ProgramPath+'rtl/config.xml'),SysParam.saved);
     SysParam.notsaved.PreloadedFile:='';
     uzbtypes.VerboseLog:=@uzclog.VerboseLog;
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            {$ifdef windows}param:={Tria_AnsiToUtf8}SysToUTF8(paramstr(i));{$endif}
            {$ifndef windows}param:=paramstr(i);{$endif}
            paramUC:=uppercase(param);

            debugln('{N}Found param command line parameter "%s"',[paramUC]);
            //programlog.LogOutStr(format('Found param command line parameter "%s"',[paramUC]),lp_OldPos,LM_Necessarily);

            if fileexists(UTF8toSys(param)) then
                                     SysParam.notsaved.PreloadedFile:=param
       else if (paramUC='NOTCHECKUNIQUEINSTANCE')or(paramUC='NCUI')then
                                                   SysParam.saved.UniqueInstance:=false
       else if (paramUC='NOSPLASH')or(paramUC='NS')then
                                                   SysParam.saved.NoSplash:=true
       else if (paramUC='VERBOSELOG')or(paramUC='VL')then
                                                          uzclog.VerboseLog:=true
       else if (paramUC='NOLOADLAYOUT')or(paramUC='NLL')then
                                                               SysParam.saved.NoLoadLayout:=true
       else if (paramUC='UPDATEPO')then
                                                               SysParam.saved.UpdatePO:=true
       else if (paramUC='LM_TRACE')then
                                       programlog.SetLogMode(LM_Trace)
       else if (paramUC='LM_DEBUG')then
                                       programlog.SetLogMode(LM_Debug)
       else if (paramUC='LM_INFO')then
                                       programlog.SetLogMode(LM_Info)
       else if (paramUC='LM_WARNING')then
                                       programlog.SetLogMode(LM_Warning)
       else if (paramUC='LM_ERROR')then
                                       programlog.SetLogMode(LM_Error)
       else if (paramUC='LM_FATAL')then
                                       programlog.SetLogMode(LM_Fatal)
       else if (paramUC='LEAM')then
                                   programlog.enableallmodules
       else if pos(LogEnableModulePrefix,paramUC)=1 then
                                       begin
                                         paramUC:=copy(paramUC,
                                                      length(LogEnableModulePrefix)+1,
                                                      length(paramUC)-length(LogEnableModulePrefix)+1);
                                         programlog.enablemodule(paramUC);
                                       end
       else if pos(LogDisableModulePrefix,paramUC)=1 then
                                       begin
                                         paramUC:=copy(paramUC,
                                                      length(LogEnableModulePrefix)+1,
                                                      length(paramUC)-length(LogEnableModulePrefix)+1);
                                         if paramUC<>'DEFAULT'then
                                           programlog.disablemodule(paramUC)
                                         else
                                           disabledefaultmodule:=true;
                                       end;
       end;
     debugln('{N-}end;{ProcessParamStr}');
     //programlog.LogOutStr('end;{ProcessParamStr}',lp_DecPos,LM_Necessarily);
end;
Procedure GetSysInfo;
begin
     //programlog.LogOutStr('GetSysInfo',lp_IncPos,LM_Necessarily);
     debugln('{N+}GetSysInfo');
     SysDefaultFormatSettings:=DefaultFormatSettings;
     SysParam.notsaved.ScreenX:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     SysParam.notsaved.ScreenY:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;


     {SysParam.ScreenX:=800;
     SysParam.ScreenY:=800;}



     {$IFDEF FPC}
                 SysParam.notsaved.Ver:=GetVersion({'zcad.exe'});
     {$ELSE}
                 sysparam.ver:=GetVersion({'ZCAD.exe'});
     {$ENDIF}

     ProcessParamStr;
     //SysParam.verstr:=Format('%d.%d.%d.%d SVN: %s',[SysParam.Ver.major,SysParam.Ver.minor,SysParam.Ver.release,SysParam.Ver.build,RevisionStr]);
     debugln('{N}ZCAD log v'+sysparam.notsaved.ver.versionstring+' started');
{$IFDEF FPC}                 debugln('{N}Program compiled on Free Pascal Compiler');{$ENDIF}
{$IFDEF DEBUGBUILD}          debugln('{N}Program compiled with {$DEFINE DEBUGDUILD}');{$ENDIF}
{$IFDEF PERFOMANCELOG}       debugln('{N}Program compiled with {$DEFINE PERFOMANCELOG}');{$ENDIF}
{$IFDEF BREACKPOINTSONERRORS}debugln('{N}Program compiled with {$DEFINE BREACKPOINTSONERRORS}');{$ENDIF}
                             {$if FPC_FULlVERSION>=20701}
                             debugln('{N}DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage));
                             //programlog.logoutstr('DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage),0,LM_Necessarily);
                             debugln('{N}DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage));
                             //programlog.logoutstr('DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage),0,LM_Necessarily);
                             debugln('{N}UTF8CompareLocale:='+inttostr(UTF8CompareLocale));
                             //programlog.logoutstr('UTF8CompareLocale:='+inttostr(UTF8CompareLocale),0,LM_Necessarily);
                             {modeswitch systemcodepage}
                             {$ENDIF}
     debugln('{N}SysParam.ProgramPath="%s"',[ProgramPath]);
     //programlog.LogOutStr(format('SysParam.ProgramPath="%s"',[ProgramPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.TempPath="%s"',[TempPath]);
     //programlog.LogOutStr(format('SysParam.TempPath="%s"',[TempPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenX=%d',[SysParam.notsaved.ScreenX]);
     //programlog.LogOutStr(format('SysParam.ScreenX=%d',[SysParam.ScreenX]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenY=%d',[SysParam.notsaved.ScreenY]);
     //programlog.LogOutStr(format('SysParam.ScreenY=%d',[SysParam.ScreenY]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoSplash=%s',[BoolToStr(SysParam.saved.NoSplash,true)]);
     //programlog.LogOutStr(format('SysParam.NoSplash=%s',[BoolToStr(SysParam.NoSplash,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.saved.NoLoadLayout,true)]);
     //programlog.LogOutStr(format('SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.NoLoadLayout,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.UpdatePO=%s',[BoolToStr(SysParam.saved.UpdatePO,true)]);
     //programlog.LogOutStr(format('SysParam.UpdatePO=%s',[BoolToStr(SysParam.UpdatePO,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.PreloadedFile="%s"',[SysParam.notsaved.PreloadedFile]);
     //programlog.LogOutStr(format('SysParam.PreloadedFile="%s"',[SysParam.PreloadedFile]),lp_OldPos,LM_Necessarily);

     debugln('{N-}end;{GetSysInfo}');
     //programlog.LogOutStr('end;{GetSysInfo}',lp_DecPos,LM_Necessarily);
     if disabledefaultmodule then programlog.disablemodule('DEFAULT');
end;
class function TZCADPathsMacroMethods.MacroFuncZCADPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=ProgramPath;
end;
class function TZCADPathsMacroMethods.MacroFuncTEMPPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=TempPath;
end;
initialization
GetSysInfo;
DefaultMacros.AddMacro(TTransferMacro.Create('ZCADPath','',
                       'Path to ZCAD',TZCADPathsMacroMethods.MacroFuncZCADPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('TEMP','',
                       'TEMP path',TZCADPathsMacroMethods.MacroFuncTEMPPath,[]));
disabledefaultmodule:=false;
end.
