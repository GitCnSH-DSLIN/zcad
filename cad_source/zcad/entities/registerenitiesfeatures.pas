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
unit registerenitiesfeatures;
{$INCLUDE def.inc}

interface
uses sysutils,
     GDBCommandsDB,GDBCable,GDBNet,GDBDevice,TypeDescriptors,dxflow,gdbfieldprocessor,UGDBOpenArrayOfByte,gdbasetypes,gdbase,gdbobjectextender,GDBSubordinated,GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,UGDBDrawingdef;

implementation
function EntIOLoad_OWNERHANDLE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.OwnerHandle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_HANDLE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.Handle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_UPGRADE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.AddExtAttrib^.Upgrade:=strtoint(_value);
     result:=true;
end;
function EntIOLoad_LAYER(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.vp.Layer:=drawing.getlayertable.getAddres(_value);
     result:=true;
end;
function EntIOLoadUSES(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    uou:PTObjectUnit;
begin
     uou:=pointer(units.findunit(_Value));
     PEnt^.ou.InterfaceUses.addnodouble(@uou);
     result:=true;
end;
function EntIOLoadDollar(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    svn,vn,vv:GDBString;
    pvd:pvardesk;
    offset:GDBInteger;
    tc:PUserTypeDescriptor;
begin
     extractvarfromdxfstring2(_Value,vn,svn,vv);
     pvd:=PEnt^.ou.InterfaceVariables.findvardesc(vn);
     offset:=GDBPlatformint(pvd.data.Instance);
     if pvd<>nil then
     begin
          PRecordDescriptor(pvd^.data.PTD)^.ApplyOperator('.',svn,offset,tc);
     end;
     PBaseTypeDescriptor(tc)^.SetValueFromString(pointer(offset),vv);
     result:=true;
end;
function EntIOLoadAmpersand(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring2(_Value,vn,vt,vun);
     PEnt^.ou.setvardesc(vd,vn,vun,vt);
     PEnt^.ou.InterfaceVariables.createvariable(vd.name,vd);
     result:=true;
end;
function EntIOLoadPercent(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     ptu.setvardesc(vd,vn,vun,vt);
     ptu.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;
function EntIOLoadHash(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     OldVersVarRename(vn,vt,vv,vun);
     PEnt^.ou.setvardesc(vd,vn,vun,vt);
     PEnt^.ou.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;

procedure EntityIOSave_all(var outhandle:GDBOpenArrayOfByte;PEnt:PGDBObjEntity);
var
   ishavevars:boolean;
   pvd:pvardesk;
   pfd:PFieldDescriptor;
   pvu:PTUnit;
   ir,ir2:itrec;
   str,sv:gdbstring;
   i:integer;
   tp:pointer;
begin
     if PEnt^.ou.InterfaceVariables.vardescarray.Count>0 then
                                                       ishavevars:=true
                                                   else
                                                       ishavevars:=false;
     begin
         if ishavevars then
         begin
              pvu:=PEnt^.ou.InterfaceUses.beginiterate(ir);
              if pvu<>nil then
              repeat
                    str:='USES='+pvu^.Name;
                    dxfGDBStringout(outhandle,1000,str);
              pvu:=PEnt^.ou.InterfaceUses.iterate(ir);
              until pvu=nil;

              i:=0;
              pvd:=PEnt^.ou.InterfaceVariables.vardescarray.beginiterate(ir);
              if pvd<>nil then
              repeat
                    if (pvd^.data.PTD.GetTypeAttributes and TA_COMPOUND)=0 then
                    begin
                         sv:=PBaseTypeDescriptor(pvd^.data.ptd)^.GetValueAsString(pvd^.data.Instance);
                         str:='#'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName;
                         str:=str+'|'+sv+'|'+pvd^.username;
                         dxfGDBStringout(outhandle,1000,str);
                    end
                    else
                    begin
                         str:='&'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName+'|'+pvd^.username;
                         dxfGDBStringout(outhandle,1000,str);
                         inc(i);
                         tp:=pvd^.data.Instance;
                         pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.beginiterate(ir2);
                         if pfd<>nil then
                         repeat
                               str:='$'+inttostr(i)+'='+pvd^.name+'|'+pfd^.base.ProgramName+'|'+pfd^.base.PFT^.GetValueAsString(tp);
                               dxfGDBStringout(outhandle,1000,str);
                               ptruint(tp):=ptruint(tp)+ptruint(pfd^.base.PFT^.SizeInGDBBytes); { TODO : сделать на оффсете }
                               inc(i);
                               pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.iterate(ir2);
                         until pfd=nil;
                         str:='&'+inttostr(i)+'=END';
                         inc(i);
                    end;
              inc(i);
              pvd:=PEnt^.ou.InterfaceVariables.vardescarray.iterate(ir);
              until pvd=nil;
         end;
         dxfGDBStringout(outhandle,1000,'_OWNERHANDLE='+inttohex(PEnt^.bp.ListPos.owner.GetHandle,10));
    end;
end;


function TextIOLoad_TMPL1(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjText):boolean;
begin
     pent^.template:=_value;
     result:=true;
end;
procedure TextIOSave_TMPL1(var outhandle:GDBOpenArrayOfByte;PEnt:PGDBObjText);
begin
     if pent^.content<>convertfromunicode(pent^.template) then
       dxfGDBStringout(outhandle,1000,'_TMPL1='+pent^.template);
end;

function BlockDefIOLoad_TYPE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BT_CONNECTOR' then
                               begin
                                pent^.BlockDesc.BType:=BT_Connector;
                                result:=true;
                           end
else if _Value='BT_UNKNOWN' then
                               begin
                                pent^.BlockDesc.BType:=BT_Unknown;
                                result:=true;
                           end;
end;
function BlockDefIOLoad_GROUP(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BG_EL_DEVICE' then
                               begin
                                pent^.BlockDesc.BGroup:=BG_El_Device;
                                result:=true;
                           end
else if _Value='BG_UNKNOWN' then
                               begin
                                pent^.BlockDesc.BGroup:=BG_Unknown;
                                result:=true;
                           end;
end;
function BlockDefIOLoad_BORDER(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BB_OWNER' then
                           begin
                                pent^.BlockDesc.BBorder:=BB_Owner;
                                result:=true;
                           end
else if _Value='BB_SELF' then
                          begin
                                pent^.BlockDesc.BBorder:=BB_Self;
                                result:=true;
                          end
else if _Value='BB_EMPTY' then
                          begin
                                pent^.BlockDesc.BBorder:=BB_Empty;
                                result:=true;
                          end;
end;
procedure DeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString; pEntity:PGDBObjGenericWithSubordinated);
begin
     if (pvn<>nil) then
     begin
     if (formatstr<>'') then
                                      begin
                                           if pEntity<>nil then
                                                               pstring(pvn^.data.Instance)^:=textformat(formatstr,pEntity)
                                                            else
                                                               pstring(pvn^.data.Instance)^:='!!ERR(pEnttity=nil)';
                                           pvn^.attrib:=pvn^.attrib or vda_RO;
                                      end
                                         else
                                             pvn^.attrib:=pvn^.attrib and (not vda_RO);
     end;

end;
procedure DeviceNameProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvnt:pvardesk;
begin
     pvn:=pEntity^.OU.FindVariable('NMO_Name');
     pvnt:=pEntity^.OU.FindVariable('NMO_Template');

     if (pvnt<>nil) then
     DeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pEntity);

     DBLinkProcess(pentity,drawing);
end;
procedure CableNameProcess(pCable:PGDBObjCable;const drawing:TDrawingDef);
var
   pvn,pvnt:pvardesk;
   ptn:PTNodeProp;
   s:GDBstring;
   //c:gdbinteger;
   pdev:PGDBObjDevice;
begin
     pvn:=pCable^.OU.FindVariable('NMO_Name');
     if pvn<>nil then
     if pstring(pvn^.data.Instance)^='@1' then
                                                 s:=s;
     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getelement(0);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pCable^.OU.FindVariable('NMO_Prefix');
     pvnt:=pCable^.OU.FindVariable('NMO_PrefixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pdev);

     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getelement(pCable^.NodePropArray.Count-1);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pCable^.OU.FindVariable('NMO_Suffix');
     pvnt:=pCable^.OU.FindVariable('NMO_SuffixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pdev);

     pvn:=pCable^.OU.FindVariable('NMO_Name');
     pvnt:=pCable^.OU.FindVariable('NMO_Template');
     if (pvnt<>nil) then
     DeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pCable);

     pvn:=pCable^.OU.FindVariable('GC_HDGroup');
     pvnt:=pCable^.OU.FindVariable('GC_HDGroupTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     pvn:=pCable^.OU.FindVariable('GC_HeadDevice');
     pvnt:=pCable^.OU.FindVariable('GC_HeadDeviceTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);


     pvn:=pCable^.OU.FindVariable('GC_HDShortName');
     pvnt:=pCable^.OU.FindVariable('GC_HDShortNameTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     DBLinkProcess(pCable,drawing);
end;

begin
  {from GDBObjEntity}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_OWNERHANDLE',@EntIOLoad_OWNERHANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_HANDLE',@EntIOLoad_HANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_UPGRADE',@EntIOLoad_UPGRADE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_LAYER',@EntIOLoad_LAYER);
  GDBObjEntity.GetDXFIOFeatures.RegisterSaveFeature(@EntityIOSave_all);

  {from GDBObjGenericWithSubordinated}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('USES',@EntIOLoadUSES);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('$',@EntIOLoadDollar);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('&',@EntIOLoadAmpersand);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('%',@EntIOLoadPercent);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('#',@EntIOLoadHash);

  {from GDBObjText}
  GDBObjText.GetDXFIOFeatures.RegisterNamedLoadFeature('_TMPL1',@TextIOLoad_TMPL1);
  GDBObjText.GetDXFIOFeatures.RegisterSaveFeature(@TextIOSave_TMPL1);

  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_TYPE',@BlockDefIOLoad_TYPE);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_GROUP',@BlockDefIOLoad_GROUP);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_BORDER',@BlockDefIOLoad_BORDER);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterFormatFeature(@CableNameProcess);
end.
