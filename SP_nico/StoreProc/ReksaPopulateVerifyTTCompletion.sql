
CREATE proc [dbo].[ReksaPopulateVerifyTTCompletion]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20120924
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    

 END REVISED  
   
 exec dbo.ReksaPopulateVerifyTTCompletion null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  
  
select @bCheck as CheckB,
	   rt.IdTTCompletion as Id,
	   case when rt.ActionType = 'A' then 'Add'
			when rt.ActionType = 'U' then 'Update'
			when rt.ActionType = 'D' then 'Delete'
	   end as [Action],
	   rp.ProdCode as Produk,
	   rt.ProdCurr as MataUang,
	   rt.NamaPemohon,
	   rt.AlamatPemohon1 + ' ' + rt.AlamatPemohon2 as AlamatPemohon,
	   rt.NamaPenerima,
	   rt.AlamatPenerima1 + ' ' + rt.AlamatPenerima2 + ' ' + rt.AlamatPenerima3 as AlamatPenerima,
	   rt.BeneficiaryBankCode,
	   rt.BeneficiaryAccNo,
	   rt.BeneficiaryBankAddress,
	   rt.PaymentRemarks1,
	   rt.PaymentRemarks2,
	   rt.NoRekProduk,
	   rt.GLBiayaFullAmt,
	   rt.InputterNIK,
	   rt.InputDate
from dbo.ReksaTTCompletion_TT rt
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = rt.ProdId
where rt.StatusOtor = 0

  
return 0
GO