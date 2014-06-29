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

unit uzglabstractdrawer;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
type
TZGLAbstractDrawer=class
                        public
                        PVertexBuffer:PGDBOpenArrayOfData;
                        procedure DrawLine(const i1:TLLVertexIndex);virtual;abstract;
                        procedure DrawPoint(const i:TLLVertexIndex);virtual;abstract;
                        procedure startrender;virtual;abstract;
                        procedure endrender;virtual;abstract;
                        procedure startpaint;virtual;abstract;
                        procedure endpaint;virtual;abstract;
                        procedure SetLineWidth(const w:single);virtual;abstract;
                        procedure SetPointSize(const s:single);virtual;abstract;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;virtual;abstract;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;virtual;abstract;
                        procedure SetColor(const color: TRGB);overload;virtual;abstract;
                        procedure ClearScreen(stencil:boolean);virtual;abstract;
                        procedure TranslateCoord2D(const tx,ty:single);virtual;abstract;
                        procedure ScaleCoord2D(const sx,sy:single);virtual;abstract;
                        procedure SetLineSmooth(const smoth:boolean);virtual;abstract;
                        procedure SetPointSmooth(const smoth:boolean);virtual;abstract;
                        procedure ClearStatesMachine;virtual;abstract;
                        procedure SetFillStencilMode;virtual;abstract;
                        procedure SetDrawWithStencilMode;virtual;abstract;
                        procedure DisableStencil;virtual;abstract;
                        procedure SetZTest(Z:boolean);virtual;abstract;
                        procedure SetDisplayCSmode(const width, height:integer);virtual;abstract;
                        procedure WorkAreaResize(w,h:integer);virtual;abstract;
                        procedure SaveBuffers(w,h:integer);virtual;abstract;
                        procedure RestoreBuffers(w,h:integer);virtual;abstract;
                        procedure CreateScrbuf(w,h:integer); virtual;abstract;
                        procedure delmyscrbuf; virtual;abstract;




                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);overload;virtual;abstract;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);overload;virtual;abstract;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);overload;virtual;abstract;
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);virtual;abstract;
                   end;
TZGLGeneralDrawer=class(TZGLAbstractDrawer)
                        public
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                        procedure startrender;override;
                        procedure endrender;override;
                        procedure startpaint;override;
                        procedure endpaint;override;
                        procedure SetLineWidth(const w:single);override;
                        procedure SetPointSize(const s:single);override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                        procedure SetLineSmooth(const smoth:boolean);override;
                        procedure SetPointSmooth(const smoth:boolean);override;
                        procedure ClearStatesMachine;override;
                        procedure SetFillStencilMode;override;
                        procedure SetDrawWithStencilMode;override;
                        procedure DisableStencil;override;
                        procedure SetZTest(Z:boolean);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);overload;override;
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                        procedure SetDisplayCSmode(const width, height:integer);override;
                        procedure WorkAreaResize(w,h:integer);override;
                        procedure SaveBuffers(w,h:integer);override;
                        procedure RestoreBuffers(w,h:integer);override;
                        procedure CreateScrbuf(w,h:integer); override;
                        procedure delmyscrbuf; override;
                   end;
var
  testrender:TZGLAbstractDrawer;
implementation
uses log;
procedure TZGLGeneralDrawer.DrawLine(const i1:TLLVertexIndex);
begin
end;
procedure TZGLGeneralDrawer.DrawPoint(const i:TLLVertexIndex);
begin
end;
procedure TZGLGeneralDrawer.startrender;
begin
end;
procedure TZGLGeneralDrawer.endrender;
begin
end;
procedure TZGLGeneralDrawer.startpaint;
begin
end;
procedure TZGLGeneralDrawer.endpaint;
begin
end;
procedure TZGLGeneralDrawer.SetLineWidth(const w:single);
begin
end;
procedure TZGLGeneralDrawer.SetPointSize(const s:single);
begin
end;
procedure TZGLGeneralDrawer.SetColor(const red, green, blue, alpha: byte);
begin
end;
procedure TZGLGeneralDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
end;
procedure TZGLGeneralDrawer.SetColor(const color: TRGB);
begin
end;
procedure TZGLGeneralDrawer.ClearScreen(stencil:boolean);
begin
end;
procedure TZGLGeneralDrawer.TranslateCoord2D(const tx,ty:single);
begin
end;
procedure TZGLGeneralDrawer.ScaleCoord2D(const sx,sy:single);
begin
end;
procedure TZGLGeneralDrawer.SetLineSmooth(const smoth:boolean);
begin
end;
procedure TZGLGeneralDrawer.SetPointSmooth(const smoth:boolean);
begin
end;
procedure TZGLGeneralDrawer.ClearStatesMachine;
begin
end;
procedure TZGLGeneralDrawer.SetFillStencilMode;
begin
end;
procedure TZGLGeneralDrawer.SetDrawWithStencilMode;
begin
end;
procedure TZGLGeneralDrawer.DisableStencil;
begin
end;
procedure TZGLGeneralDrawer.SetZTest(Z:boolean);
begin
end;
procedure TZGLGeneralDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
end;
procedure TZGLGeneralDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
begin
end;
procedure TZGLGeneralDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
begin
end;
procedure TZGLGeneralDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.SetDisplayCSmode;
begin
end;
procedure TZGLGeneralDrawer.WorkAreaResize;
begin
     delmyscrbuf;
     CreateScrbuf(w,h);
end;
procedure TZGLGeneralDrawer.SaveBuffers;
begin
end;
procedure TZGLGeneralDrawer.RestoreBuffers;
begin
end;
procedure TZGLGeneralDrawer.CreateScrbuf(w,h:integer);
begin
end;
procedure TZGLGeneralDrawer.delmyscrbuf;
begin
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
end.
