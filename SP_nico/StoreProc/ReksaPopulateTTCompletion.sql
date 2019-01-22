
CREATE proc [dbo].[ReksaPopulateTTCompletion]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120923
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED

*/
@pnProdId			int
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)

if not exists(select top 1 1 from dbo.ReksaTTCompletion_TM where ProdId = @pnProdId)
begin
	set @cErrMsg = 'Produk tersebut belum terdaftar di TT Completion!'
	goto ERROR
end

select ProdCurr, NamaPemohon, AlamatPemohon1, AlamatPemohon2, NamaPenerima, AlamatPenerima1, AlamatPenerima2, AlamatPenerima3, 
	BeneficiaryBankCode, BeneficiaryAccNo, BeneficiaryBankName, BeneficiaryBankAddress, PaymentRemarks1, PaymentRemarks2,
	NoRekProduk, GLBiayaFullAmt
from dbo.ReksaTTCompletion_TM
where ProdId = @pnProdId

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