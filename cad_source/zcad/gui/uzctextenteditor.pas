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

unit uzctextenteditor;
{$INCLUDE def.inc}
interface
uses
     uzcsysvars,gdbase,gdbasetypes,uzcsysinfo,
     uzcinfoform,Varman,zcadinterface,
     uzedrawingdef,strproc,uzeenttext,gdbobjectsconstdef,uzcstrconsts,uzcfsinglelinetexteditor,
     Controls,Classes,Forms;
var
    InfoForm:TInfoForm=nil;
procedure RunTextEditor(Pobj:GDBPointer;var drawing:TDrawingDef);
implementation
uses
    uzccommandsmanager;
procedure RunTextEditor(Pobj:GDBPointer;var drawing:TDrawingDef);
var
   modalresult:integer;
   astring:ansistring;
begin
     astring:=ConvertFromDxfString(PGDBObjText(pobj)^.Template);


     if PGDBObjText(pobj)^.vp.ID=GDBMTextID then
     begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND',SysParam.ScreenX,SysParam.Screeny);
     end;
     //InfoForm.DialogPanel.ShowButtons:=[pbOK, pbCancel{, pbClose, pbHelp}];
     InfoForm.caption:=(rsMTextEditor);

     InfoForm.memo.text:=astring;
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;
     modalresult:=DOShowModal(InfoForm);
     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(InfoForm.memo.text);
                              StoreBoundsToSavedUnit('TEdWND',InfoForm.BoundsRect);
                         end;
     end
     else
     begin
     if not assigned(SingleLineTextEditorForm) then
     Application.CreateForm(TSingleLineTextEditorForm, SingleLineTextEditorForm);
     SingleLineTextEditorForm.caption:=(rsTextEditor);

     SingleLineTextEditorForm.helptext.Caption:=rsTextEdCaption;
     SingleLineTextEditorForm.EditField.TEXT:=astring;
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        SingleLineTextEditorForm.EditField.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;

     modalresult:=DOShowModal(SingleLineTextEditorForm);

     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(SingleLineTextEditorForm.EditField.text);
                         end;
     end;
     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.YouChanged(drawing);
                              if assigned(redrawoglwndproc) then redrawoglwndproc;
                         end;

end;
begin
end.