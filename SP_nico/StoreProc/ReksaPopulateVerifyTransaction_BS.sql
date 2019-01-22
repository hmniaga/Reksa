
CREATE proc [dbo].[ReksaPopulateVerifyTransaction_BS]  
/*  
 CREATED BY    : victor  
 CREATION DATE : 20071029  
 DESCRIPTION   : menampilkan list transaksi yang perlu di authorize  
 REVISED BY    :  
 DATE,  USER,   PROJECT,  NOTE  
 -----------------------------------------------------------------------  
 20071128, victor, REKSADN002, tambah filter cabang    
 20071204, victor, REKSADN002, tambah select TranCode  
 20071218, indra_w, REKSADN002, perbaikan UAT  
 20080402, indra_w, REKSADN002, tambahan tampilan data
 20080415, mutiara, REKSADN002, full amount dan pnambahan kolom fee
 20120202, liliana, BAALN11008, tambah kolom isEditFee
 20120202, liliana, BAALN11008, ganti yes/no
 20120410, liliana, BAALN11026, tambah nik dan nama seller waperd
 20120410, liliana, BAALN11026, Order by tran Id
 20120424, liliana, LOGAM02012, L4636 - ganti nama waperd
 20130218, liliana, BATOY12006, tambah kolom percentage subs dan redemp fee
 20130220, liliana, BATOY12006, agar 0 di belakang koma tdk muncul byk
 20130221, liliana, BATOY12006, perbaikan
 20130402, liliana, BATOY12006, 4 angka pembulatan di blkng koma
 20130515, liliana, BAFEM12011, tampilkan kolom channel
 20130531, liliana, BAFEM12011, tuker2 posisi
 
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyTransaction null
*/  
@cNik        int  
  
as  
  
set nocount on  
  
declare @bCheck      bit  
--20071128, victor, REKSADN002, begin  
 ,@cOfficeId      varchar(5)  
  
select @cOfficeId = office_id_sibs  
from dbo.user_nisp_v  
where nik = @cNik  
--20071128, victor, REKSADN002, end  
set @bCheck = 0  
  
--20071204, victor, REKSADN002, begin  
--20071218, indra_w, REKSADN002, begin  
--select @bCheck as 'CheckB', a.TranId, b.ClientCode, c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY,   
--20130531, liliana, BAFEM12011, begin
--select @bCheck as 'CheckB', a.TranId, a.TranCode, a.NAVValueDate as ValueDate, b.ClientCode 
select @bCheck as 'CheckB', a.TranId, a.TranCode, 
	e.TranDesc,
	a.NAVValueDate as ValueDate, b.ClientCode   
--20130531, liliana, BAFEM12011, end
--20080402, indra_w, REKSADN002, begin  
 , b.CIFName  
--20080415, mutiara, REKSADN002, begin
-- ,case    
--	when (a.FullAmount=0) then 'Non Full Amount'    
--	when (a.FullAmount=1) then 'Full Amount'    
-- end as FullAmount    
----20080402, indra_w, REKSADN002, end
 ,case    
	when (a.FullAmount=0) then 'No'    
	when (a.FullAmount is null) then 'No'    
	when (a.FullAmount=1) then 'Yes'    
 end as FullAmount
--20080415, mutiara, REKSADN002, end

--20130531, liliana, BAFEM12011, begin
 --, c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY, 
  , c.ProdCode, d.AgentCode, a.TranCCY,    
--20130531, liliana, BAFEM12011, end
--20071218, indra_w, REKSADN002, end  
--20071204, victor, REKSADN002, end
--20130220, liliana, BATOY12006, begin  
 --a.TranAmt, a.TranUnit 
  convert(varchar(40),cast(a.TranAmt as money),1) as TranAmt ,
  convert(varchar(40),cast(a.TranUnit as money),1) as TranUnit
--20130220, liliana, BATOY12006, end 
--20080415, mutiara, REKSADN002, begin
--20130218, liliana, BATOY12006, begin
--,a.SubcFee,a.RedempFee
--20130220, liliana, BATOY12006, begin   
--, a.SubcFee
--, case when a.TranType in (1,2,8) then a.PercentageFee else 0 end as PercentageSubcFee
--, a.RedempFee 
--, case when a.TranType in (3,4) then a.PercentageFee else 0 end as PercentageRedempFee
, convert(varchar(40),cast(a.SubcFee as money),1) as SubcFee
--20130221, liliana, BATOY12006, begin
--, case when a.TranType in (1,2,8) then convert(varchar(40),cast(a.PercentageFee as money),1) else 0 end as PercentageSubcFee
--20130402, liliana, BATOY12006, begin
--, case when a.TranType in (1,2,8) then convert(varchar(40),cast(a.PercentageFee as money),1) else convert(varchar(40),cast(0 as money),1) end as PercentageSubcFee
, case when a.TranType in (1,2,8) then convert(varchar(40),cast(a.PercentageFee as money),2) else convert(varchar(40),cast(0 as money),2) end as PercentageSubcFee
--20130402, liliana, BATOY12006, end
--20130221, liliana, BATOY12006, end
, convert(varchar(40),cast(a.RedempFee as money),1) as RedempFee 
--20130221, liliana, BATOY12006, begin
--, case when a.TranType in (3,4) then convert(varchar(40),cast(a.PercentageFee as money),1) else 0 end as PercentageRedempFee
--20130402, liliana, BATOY12006, begin
--, case when a.TranType in (3,4) then convert(varchar(40),cast(a.PercentageFee as money),1) else convert(varchar(40),cast(0 as money),1) end as PercentageRedempFee
, case when a.TranType in (3,4) then convert(varchar(40),cast(a.PercentageFee as money),2) else convert(varchar(40),cast(0 as money),2) end as PercentageRedempFee
--20130402, liliana, BATOY12006, end
--20130221, liliana, BATOY12006, end
--20130220, liliana, BATOY12006, end
--20130218, liliana, BATOY12006, end
--20080415, mutiara, REKSADN002, end
--20120202, liliana, BAALN11008, begin
--20120202, liliana, BAALN11008, begin
--, a.IsFeeEdit
 , case when a.IsFeeEdit = 1 then 'Yes' 
        when a.IsFeeEdit = 0 then 'No'
    end as IsFeeEdit
--20120202, liliana, BAALN11008, end
--20120202, liliana, BAALN11008, end
--20120410, liliana, BAALN11026, begin
, a.Seller as 'NIK WAPERD'
--20120424, liliana, LOGAM02012, begin
--, f.fullname as 'Nama WAPERD'
, g.Nama as 'Nama WAPERD'
--20120424, liliana, LOGAM02012, end
--20120410, liliana, BAALN11026, end
--20130515, liliana, BAFEM12011, begin
, cl.ChannelDesc as TransactionChannel
--20130515, liliana, BAFEM12011, end
from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d,  
 dbo.ReksaTransType_TR e  
--20071128, victor, REKSADN002, begin  
 , dbo.user_nisp_v f  
--20071128, victor, REKSADN002, end  
--20120424, liliana, LOGAM02012, begin
 , dbo.ReksaWaperd_TR g
--20120424, liliana, LOGAM02012, end
--20130515, liliana, BAFEM12011, begin
 , dbo.ReksaChannelList_TM cl
--20130515, liliana, BAFEM12011, end
where a.ClientId = b.ClientId  
 and a.ProdId = c.ProdId  
 and a.AgentId = d.AgentId  
 and a.TranType = e.TranType 
--20130515, liliana, BAFEM12011, begin
 and cl.ChannelCode = a.Channel
--20130515, liliana, BAFEM12011, end  
  
 and a.CheckerSuid is null  
 and a.Status = 0  
--20071128, victor, REKSADN002, begin  
--20120424, liliana, LOGAM02012, begin
 and g.NIK = a.Seller
--20120424, liliana, LOGAM02012, end
 and a.UserSuid = f.nik  
 and f.office_id_sibs = @cOfficeId  
--20071128, victor, REKSADN002, end
--20120410, liliana, BAALN11026, begin
order by a.TranId
--20120410, liliana, BAALN11026, end  
  
return 0
GO