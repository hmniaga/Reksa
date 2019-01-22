
CREATE proc [dbo].[ReksaPopulateVerifySwitching_BS]    
/*    
 CREATED BY    : liliana    
 CREATION DATE : 20111115    
 DESCRIPTION   : menampilkan list transaksi switching yg perlu di authorize    
 REVISED BY    :    
 DATE,  USER,   PROJECT,  NOTE    
 -----------------------------------------------------------------------    
  20120118, liliana, BAALN11008, transaksi yg lebih dari NAVDate tdk ditampilkan
  20120202, liliana, BAALN11008, tambah kolom isFeeEdit
  20120213, liliana, BAALN11008, pengecekan NAVDate dihapus
  20120404, liliana, BAALN11008, tambah kolom WAPERD kode
  20130321, liliana, BATOY12006, tambah kolom
  20130515, liliana, BAFEM12011, tambah kolom channel
  20130531, liliana, BAFEM12011, tuker2 posisi
 END REVISED    
 
 exec dbo.ReksaPopulateVerifySwitching_BS 10014  

*/    
@cNik        int        
as    
    
set nocount on    
    
declare @bCheck      bit       
 ,@cOfficeId      varchar(5)    
--20120118, liliana, BAALN11008, begin
 ,@dCurrentWorkingDate datetime
 
select @dCurrentWorkingDate = current_working_date from dbo.fnGetWorkingDate()
--20120118, liliana, BAALN11008, end
    
select @cOfficeId = office_id_sibs    
from dbo.user_nisp_v    
where nik = @cNik    

set @bCheck = 0   

--20130531, liliana, BAFEM12011, begin	
--select @bCheck as 'CheckB', tmp.TranId, tmp.TranCode, tmp. TranDate, tmp.NAVValueDate as ValueDate,
select @bCheck as 'CheckB', tmp.TranId, tmp.TranCode,
	case when tmp.TranType = 6 then 
	'Switching All' 
	else 
	'Switching Sebagian' 
	end as TranDesc,
	tmp. TranDate, tmp.NAVValueDate as ValueDate,
--20130531, liliana, BAFEM12011, end	
	cif.ClientCode as ClientCodeSwcOut, cif.CIFName as CIFNameSwcOut,
	cif2.ClientCode as ClientCodeSwcIn, cif2.CIFName as CIFNameSwcIn,
	rp.ProdCode as ProdSwitchOut,
	rp2.ProdCode as ProdSwitchIn,
	ra.AgentCode as AgentCode,
--20130531, liliana, BAFEM12011, begin	
	--case when tmp.TranType = 6 then 
	--'Switching All' 
	--else 
	--'Switching Sebagian' 
	--end as TranDesc,
--20130531, liliana, BAFEM12011, end	
--20130321, liliana, BATOY12006, begin
	--tmp.TranCCY, tmp.TranAmt, tmp.TranUnit, tmp.SwitchingFee as SwitchingFeePerkiraan,
	tmp.TranCCY, tmp.TranAmt, tmp.TranUnit,  tmp.PercentageFee as  PercentageFee, tmp.SwitchingFee as SwitchingFeePerkiraan,
--20130321, liliana, BATOY12006, end
--20120202, liliana, BAALN11008, begin
	case when tmp.IsFeeEdit = 1 then 'Yes' 
        when tmp.IsFeeEdit = 0 then 'No'
		end as IsFeeEdit,
--20120202, liliana, BAALN11008, end	
	tmp.SelectedAccNo as AccNoPendebetanFee,
	tmp.Inputter, tmp.Seller, tmp.Waperd
--20120404, liliana, BAALN11008, begin
	, rw.WaperdNo
--20120404, liliana, BAALN11008, end
--20130515, liliana, BAFEM12011, begin
	, cl.ChannelDesc as TransactionChannel
--20130515, liliana, BAFEM12011, end	
from dbo.ReksaSwitchingTransaction_TM tmp
	join dbo.ReksaCIFData_TM cif on cif.ClientId = tmp.ClientIdSwcOut
	join dbo.ReksaCIFData_TM cif2 on cif2.ClientId = tmp.ClientIdSwcIn
	join dbo.ReksaProduct_TM rp on rp.ProdId = tmp.ProdSwitchOut
	join dbo.ReksaProduct_TM rp2 on rp2.ProdId = tmp.ProdSwitchIn
	join dbo.ReksaAgent_TR ra on ra.AgentId= tmp.AgentId
	join dbo.user_nisp_v ni on tmp.UserSuid = ni.nik 
--20120404, liliana, BAALN11008, begin
	join dbo.ReksaWaperd_TR rw on rw.NIK = tmp.Waperd
--20120404, liliana, BAALN11008, end
--20130515, liliana, BAFEM12011, begin
	join dbo.ReksaChannelList_TM cl
		on cl.ChannelCode = tmp.Channel
--20130515, liliana, BAFEM12011, end	
where tmp.Status = 0 and tmp.CheckerSuid is null 
--20120118, liliana, BAALN11008, begin
	and ni.office_id_sibs = @cOfficeId 
--20120213, liliana, BAALN11008, begin	
	--and tmp.NAVValueDate = @dCurrentWorkingDate
--20120213, liliana, BAALN11008, end	
--20120118, liliana, BAALN11008, end
	--and ni.office_id_sibs = @cOfficeId  

 
return 0
GO