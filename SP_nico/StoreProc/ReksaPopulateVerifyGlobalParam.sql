
CREATE proc [dbo].[ReksaPopulateVerifyGlobalParam]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20121031 
 DESCRIPTION   : List global param dan setup parameter yg akan di otor  
    
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20130228, liliana, BATOY12006, tambah percentage karyawan swc
  20130610, liliana, LOGAM05399, perbaikan
  20130812, liliana, BAALN11010, ganti desc risk profile dan reksa type
  20140313, liliana, LIBST13021, tambah PRE (premi asuransi)
  20150130, liliana, LIBST13020, tambah country dan office
  20150420, liliana, LIBST13020, tambah reguler subscription 
  20160607, Lita, LIBST15330, add Kode KSEI untuk MNI dan CTD
 END REVISED  
*/  
 @pnProdId        varchar(10)  
 ,@pcInterfaceId  varchar(20)   
 ,@pnNIK          int   
as  
  
set nocount on  
  
declare @cErrMsg   varchar(100)  
  , @nOK    int  
  , @nErrNo   int  
  , @bCheck   bit

set @bCheck = 0
  
declare @TempParam table (  
 Seq    int identity(1,1)  
 , Id   int  
 , Code   varchar(10) null  
 , Description varchar(100)null  
 , OfficeId  char(5)  
 , ProdId  int  
 , ValueDate  datetime  
 , LastUpdate datetime null  
 , LastUser  int   null    
 , Desc2   varchar(100) null  
 , Desc3   datetime null  
 , Desc4   datetime null     
 , Desc5  varchar(100) null     
 , Desc6  varchar(100) null     
 ,Money1    decimal(25,13)  null
 ,Desc7     varchar(50) null
 ,Money2    decimal(25,13)  null
 ,Desc8     varchar(50) null
 ,Decimal1  decimal(25,13)  null
 ,TipeAction    varchar(1)
)  
  
If @pcInterfaceId = 'SAC'  
Begin  
 insert @TempParam (Id, Code, Description, ProdId, OfficeId, ValueDate, LastUpdate, LastUser ,TipeAction)  
 select TempAgentId, AgentCode, AgentDesc, ProdId,  OfficeId, DateInput, DateInput, UserInput,TipeAction  
 from dbo.ReksaAgent_TT   
 where StatusOtor = 0
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Parameter Agent'  
  goto ERROR  
 end  
End    
Else If @pcInterfaceId = 'PFP'      
Begin      
 insert @TempParam (Id, Code, ProdId, Description,  ValueDate, LastUpdate, LastUser,TipeAction)      
  select FrekuensiPendebetanId, FrekuensiPendebetan, MinJangkaWaktu, Kelipatan, DateInput, DateInput, UserInput ,TipeAction   
  from dbo.ReksaFrekPendebetanParam_TT  
  where StatusOtor = 0
  
  if @@error != 0      
  begin      
   set @cErrMsg = 'Error Insert Parameter Frekuensi Pendebetan'      
   goto ERROR      
  end      
End    
Else If @pcInterfaceId = 'MSC'      
Begin      
 insert @TempParam (Id, Code, ProdId, Desc7, Description,  ValueDate, LastUpdate, LastUser,TipeAction)      
  select rs.TempParamId, rp.ProdCode, rs.ProductId, case when rs.IsEmployee = 1 then 'Yes' else 'No' end, rs.ParamValue, rs.DateInput, rs.DateInput, rs.UserInput, rs.TipeAction    
  from dbo.ReksaRegulerSubscriptionParam_TT rs    
  join dbo.ReksaProduct_TM rp on rs.ProductId = rp.ProdId    
  where rs.ParamId = 'SubscMin'  
  and rs.StatusOtor = 0   
       
  if @@error != 0      
  begin      
   set @cErrMsg = 'Error Insert Parameter Minimum Subscription'      
   goto ERROR      
  end      
End    
Else If @pcInterfaceId = 'SWC'      
Begin
--20130228, liliana, BATOY12006, begin
  --insert @TempParam (Id, Code, Description, Money1, Desc7, Decimal1, LastUpdate, LastUser,TipeAction)      
  --select TempIdSwitch, ProdSwitchOut, ProdSwitchIn, MinSwitchRedempt, JenisSwitchRedempt, SwitchingFee, DateInput, UserInput,TipeAction    
  --from dbo.ReksaProdSwitchingParam_TT
  --where StatusOtor = 0 
  insert @TempParam (Id, Code, Description, Money1, Desc7, Decimal1, LastUpdate, LastUser,TipeAction
    , Money2
  )      
  select TempIdSwitch, ProdSwitchOut, ProdSwitchIn, MinSwitchRedempt, JenisSwitchRedempt, SwitchingFee, DateInput, UserInput,TipeAction
    , SwitchingFeeKaryawan    
  from dbo.ReksaProdSwitchingParam_TT
  where StatusOtor = 0   
--20130228, liliana, BATOY12006, end  
  
  if @@error != 0      
  begin      
   set @cErrMsg = 'Error Insert Parameter Switching'      
   goto ERROR      
  end      
End  
Else If @pcInterfaceId = 'RPP'  
Begin  
 insert @TempParam (Id, Code, ProdId, Description, Desc2, ValueDate, LastUpdate, LastUser,TipeAction)  
 select rr.RiskProductId, rr.ProductCode, rp.ProdId, rp.ProdName, 
--20130812, liliana, BAALN11010, begin 
 --case when rr.RiskProfile = 1 then 'Conservative'
    --  when rr.RiskProfile = 2 then 'Balance'
    --  when rr.RiskProfile = 3 then 'Growth'
    --  when rr.RiskProfile = 4 then 'Agresif'
 --end,
   dr.RiskProfileDesc,
--20130812, liliana, BAALN11010, end  
 rr.DateInput, rr.DateInput, rr.UserInput, rr.TipeAction  
 from dbo.ReksaProductRiskProfile_TT rr
    join dbo.ReksaProduct_TM rp
    on rr.ProductCode = rp.ProdCode
--20130812, liliana, BAALN11010, begin
    join dbo.ReksaDescRiskProfile_TR dr
    on dr.RiskProfile = rr.RiskProfile 
--20130812, liliana, BAALN11010, end    
 where rr.StatusOtor = 0 
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Parameter Risk Profile Product'  
  goto ERROR  
 end  
End 
Else If @pcInterfaceId = 'SFC'  
Begin  
 insert @TempParam (Id, Code, ProdId, Description,  ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempFundId, FundCode, ProdId, FundDesc, DateInput, DateInput, UserInput,TipeAction  
 from dbo.ReksaFundCode_TT  
 where StatusOtor = 0  
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Parameter Fund'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'SBC'  
Begin  
 insert @TempParam (Id, Code, ProdId, Description,  ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempBankId, BankCode, ProdId, BankDesc, DateInput, DateInput, UserInput,TipeAction  
 from dbo.ReksaBankCode_TT  
 where StatusOtor = 0 
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Parameter Bank'  
  goto ERROR  
 end  
End   
Else If @pcInterfaceId = 'MNI'  
Begin  
--20160607, Lita, LIBST15330, begin
 --insert @TempParam (Id, Code,  ProdId, Description, OfficeId, ValueDate, LastUpdate, LastUser,TipeAction)  
 --select TempManInvId, ManInvCode, 0, ManInvName, '', DateInput, DateInput, UserInput,TipeAction  
insert @TempParam (Id, Code,  ProdId, Description, Desc2, OfficeId, ValueDate, LastUpdate, LastUser,TipeAction)  
select TempManInvId, ManInvCode, 0, ManInvName, NFSManInvCode, '', DateInput, DateInput, UserInput,TipeAction  
--20160607, Lita, LIBST15330, end
 from dbo.ReksaManInv_TT 
 where StatusOtor = 0  
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Manager Investasi'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'CTD'  
Begin  
--20160607, Lita, LIBST15330, begin
 --insert @TempParam (Id, Code, Description, ProdId, OfficeId, ValueDate, LastUpdate, LastUser,TipeAction)  
 --select TempCustodyId, CustodyCode, CustodyName, 0, '', DateInput, DateInput, UserInput,TipeAction  
 insert @TempParam (Id, Code, Description, Desc2, ProdId, OfficeId, ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempCustodyId, CustodyCode, CustodyName, NFSCustodyCode, 0, '', DateInput, DateInput, UserInput,TipeAction  
--20160607, Lita, LIBST15330, end
 from dbo.ReksaCustody_TT 
 where StatusOtor = 0  
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Custody'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'RTY'  
Begin
--20130812, liliana, BAALN11010, begin  
 --insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,TipeAction)  
 --select TempTypeId, TypeCode, TypeName, 0, DateInput, DateInput, UserInput ,TipeAction 
 --from dbo.ReksaType_TT  
 --where StatusOtor = 0
  insert @TempParam (Id, Code, Description, Desc2, ProdId, ValueDate, LastUpdate, LastUser,TipeAction
  )  
 select TempTypeId, TypeCode, TypeName, TypeNameEnglish, 0, DateInput, DateInput, UserInput ,TipeAction 
 from dbo.ReksaType_TT  
 where StatusOtor = 0
--20130812, liliana, BAALN11010, end   
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Type'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'RDD'  
Begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempSchecId, 'Schedule', 'Scheduler Deviden', ProdId, ValueDate, DateInput, UserInput,TipeAction  
 from dbo.ReksaDevSchedule_TT  
 where StatusOtor = 0
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Reksa Dev Schedule'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'RHT'  
Begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempHolidayId, convert(varchar(10),year(ValueDate)), HolidayDesc, 0, DateInput, DateInput, UserInput,TipeAction  
 from dbo.ReksaHolidayTable_TT
 where StatusOtor = 0
 order by ValueDate asc  
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Reksa Dev Schedule'  
  goto ERROR  
 end  
End  
Else If @pcInterfaceId = 'RSC'  
Begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempSalesId, SalesCode, SalesName, 0, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput,TipeAction  
 from dbo.ReksaSales_TT  
 where StatusOtor = 0
  
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Sales Code'  
  goto ERROR  
 end  
End    
-- event  
Else if @pcInterfaceId = 'EVT'  
begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,TipeAction)  
 select TempEventTypeId, EventTypeCode, EventTypeDesc, 0, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput,TipeAction                               
 from dbo.ReksaEventType_TT  
  where StatusOtor = 0 
   
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Event Type'  
  goto ERROR  
 end  
end  
-- master gift  
Else if @pcInterfaceId = 'GFM'  
begin                                 
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser, Desc2,TipeAction)  
 select TempGiftId, GiftCode, GiftDesc, 0, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput, convert(varchar(20), GiftCost),TipeAction                              
 from dbo.ReksaGift_TT  
 where StatusOtor = 0 
   
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Gift Master'  
  goto ERROR  
 end  
end  
-- gift to product  
Else if @pcInterfaceId = 'GFP'  
begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser,  
  Desc2, Desc3, Desc4,TipeAction)  
 select TempGiftProductId, GiftCode, convert(varchar(100), convert(money, isnull(MinSubscription, 0.0))),  
  ProdId, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput,  
  convert(varchar(3), Term), isnull(ValueDate, '19000101'), isnull([ExpireDate], '19000101'),TipeAction  
 from dbo.ReksaGiftProduct_TT  
 where StatusOtor = 0 
   
   
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert Gift Master'  
  goto ERROR  
 end  
end  
-- waperd  
Else if @pcInterfaceId = 'WPR'  
begin  
 insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser, Desc2, Desc4, Desc5, Desc6,TipeAction)  
 select TempWaperdId, NIK, WaperdNo, 0, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput, Nama, DateExpire, JobTitle, Keterangan,TipeAction   
 from dbo.ReksaWaperd_TT  
 where StatusOtor = 0 
   
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert WAPERD'  
  goto ERROR  
 end  
end   
Else if @pcInterfaceId = 'RSB'  
begin       
--20130610, liliana, LOGAM05399, begin
   --insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser, Desc2, Desc5,TipeAction)  
--20150420, liliana, LIBST13020, begin   
   --insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser, TipeAction, Desc2, Desc5) 
   insert @TempParam (Id, Code, Description, ProdId, ValueDate, LastUpdate, LastUser, TipeAction, Desc2, Desc5
   , Desc6, Desc7
   )  
--20150420, liliana, LIBST13020, end      
--20130610, liliana, LOGAM05399, end      
 select rr.TempId, rp.[ProdCode], isnull(rr.SubsFee, 0.0), rp.ProdId, isnull(rr.DateInput,'19000101'), isnull(rr.DateInput,'19000101'), rr.UserInput,rr.TipeAction  
  , isnull(rr.RedemptFee, 0.0)    
  , isnull(rr.RedemptFeeNonAsuransi, 0.0) 
--20150420, liliana, LIBST13020, begin
  , isnull(rr.SwcFeeAsuransi, 0.0)    
  , isnull(rr.SwcFeeNonAsuransi, 0.0) 
--20150420, liliana, LIBST13020, end          
 from dbo.ReksaRegulerSubscription_TT rr
 join dbo.[ReksaProduct_TM] rp  
  on rr.ProductId = rp.ProdId  
 where rr.StatusOtor = 0    
   
 if @@error != 0  
 begin  
  set @cErrMsg = 'Error Insert RegSubscr'  
  goto ERROR  
 end  
end
Else if @pcInterfaceId = 'ANP'  
begin  
 insert @TempParam (Id, Code, Description, ValueDate, LastUpdate, LastUser, TipeAction)      
 select ParamId, Id, Value, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput, TipeAction
 from dbo.ReksaGlobalParam_TT
 where GroupId = 'ANP'
    and StatusOtor = 0
end
Else if @pcInterfaceId = 'KNP'  
begin  
 insert @TempParam (Id, Code, Description, ValueDate, LastUpdate, LastUser, TipeAction)      
 select ParamId, Id, Value, isnull(DateInput,'19000101'), isnull(DateInput,'19000101'), UserInput, TipeAction
 from dbo.ReksaGlobalParam_TT
 where GroupId = 'KNP'
    and StatusOtor = 0
end
--20140313, liliana, LIBST13021, begin
Else if @pcInterfaceId = 'PRE'  
begin  
 insert @TempParam (Id, Code, Description, ValueDate, LastUpdate, LastUser, TipeAction)      
 select PremiId,  PremiId, Percentage, DateInput, DateInput, Inputter, ProcessType
 from dbo.ReksaPremiAsuransi_TT
 where StatusOtor = 0
end
--20140313, liliana, LIBST13021, end
--20150130, liliana, LIBST13020, begin
Else if @pcInterfaceId = 'CTR'  
begin  
 insert @TempParam (Id, Code, Description, ValueDate, LastUpdate, LastUser, TipeAction)      
 select Id, CountryCode, CountryName, DateInput, DateInput, Inputter, ProcessType
 from dbo.ReksaCountryRestriction_TT
 where StatusOtor = 0
end
Else if @pcInterfaceId = 'OFF'  
begin  
 insert @TempParam (Id, Code, Description, ValueDate, LastUpdate, LastUser, TipeAction)      
 select Id, OfficeId , OfficeDesc, DateInput, DateInput, Inputter, ProcessType
 from dbo.ReksaOffice_TT
 where StatusOtor = 0
end
--20150130, liliana, LIBST13020, end

  
select @bCheck as CheckB, 
 case when tp.TipeAction = 1 then 'Add'
    when tp.TipeAction = 2 then 'Update'
    when tp.TipeAction = 3 then 'Delete'
end as TipeAction,
tp.Id, tp.ProdId, rp.ProdCode as ProductCode,
tp.Code as Kode, tp.Description as Deskripsi     
 , isnull(tp.Desc2, '') as 'Desc2' , isnull(tp.Desc5, '') as 'Desc5',   
 isnull(tp.Desc3, '19000101') as 'Tgl Efektif', isnull(tp.Desc4, '19000101') as 'Tgl Expire'         
 ,isnull(tp.Desc6,'') as 'Keterangan'  
 ,tp.Money1 as 'MinSwitchRedempt', tp.Desc7 as 'JenisSwitchRedempt',
--20130228, liliana, BATOY12006, begin   
 --tp.Decimal1 as 'SwitchingFee' 
  tp.Decimal1 as 'SwitchingFeeNonKaryawan'  
  , tp.Money2 as 'SwitchingFeeKaryawan' 
--20130228, liliana, BATOY12006, end 
 , isnull(tp.OfficeId,'') as OfficeId, tp.ValueDate as 'Tanggal Valuta', tp.LastUpdate, tp.LastUser   
from @TempParam tp
left join dbo.ReksaProduct_TM rp
on tp.ProdId = rp.ProdId
order by tp.Seq
  
return 0  
  
ERROR:  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Error !'  
  
exec @nOK = set_raiserror @@procid, @nErrNo output    
if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1);
return 1
GO