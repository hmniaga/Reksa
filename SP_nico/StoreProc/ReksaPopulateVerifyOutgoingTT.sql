
CREATE proc [dbo].[ReksaPopulateVerifyOutgoingTT]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120925
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130614, liliana, ODKIB12036, fix
		20130614, liliana, ODKIB12036, ganti tgl valuta
	END REVISED
	
	exec ReksaPopulateVerifyOutgoingTT 'Proses Outgoing TT'
	exec ReksaPopulateVerifyOutgoingTT 'Delete Outgoing TT'
	
*/
@pcJenisProses		varchar(50) --Proses Outgoing TT / Delete Outgoing TT
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)
	,@bCheck			bit
	,@nProses			int
	
if(@pcJenisProses = 'Proses Outgoing TT')
begin
	set @nProses = 3
end
else if (@pcJenisProses = 'Delete Outgoing TT')
begin
	set @nProses = 4
end

set @bCheck = 0

select @bCheck as CheckB, 
	   rt.TranGuid,
	   rt.BillId, rp.ProdName, rt.AlasanDelete, 
	   case when tt.ProcessStatusFee = 1 then 'SUCCESS'
		when tt.ProcessStatusFee = 2 then 'FAILED' 
		when tt.ProcessStatusFee = 3 then 'SUSPECT'
		when tt.ProcessStatusFee = 0 then 'WAITING TO PROCESS'
	   end as ProcessStatusFee, 
	   tt.ErrorDescriptionFee,
	  case when tt.ProcessStatusTT = 1 then 'SUCCESS'
		when tt.ProcessStatusTT = 2 then 'FAILED' 
		when tt.ProcessStatusTT = 3 then 'SUSPECT'
		when tt.ProcessStatusTT = 0 then 'WAITING TO PROCESS'
	   end as ProcessStatusTT, 
	   tt.ErrorDescriptionTT,
	   rt.NamaPemohon, rt.AlamatPemohon1, rt.AlamatPemohon2, rt.RemittanceNo,
--20130614, liliana, ODKIB12036, begin	   
	   --rt.TglPembelianReksadana, rt.TranDate as TanggalValuta, rt.NominalTransfer, rt.Currency, rt.NamaPenerima,
	   rt.TglPembelianReksadana, 
	   case when tt.ValueDate is null then rt.TranDate
	   else tt.ValueDate end as TanggalValuta, 
	   rt.NominalTransfer, rt.Currency, rt.NamaPenerima,
--20130614, liliana, ODKIB12036, end	   
	   rt.AlamatPenerima, rt.PaymentRemarks, rt.BeneficiaryBankCode, rt.BeneficiaryBankName, rt.BeneficiaryBankAddress,
	   rt.BeneficiaryAccNo, rt.NoRekProduk, rt.GLBiayaFullAmt, rt.UserProcess, rt.DateProcess
from dbo.ReksaTTOutgoing_TT rt
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = rt.ProdId
--20130614, liliana, ODKIB12036, begin		
	--join dbo.ReksaTTOrderingLog_TM tt
	left join dbo.ReksaTTOrderingLog_TM tt
--20130614, liliana, ODKIB12036, end
		on tt.TTGuid = rt.TranGuid
where rt.TranStatus in (@nProses)
	
return 0

ERROR:  
If @@trancount > 0   
 rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Unknown Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1);
return 1
GO