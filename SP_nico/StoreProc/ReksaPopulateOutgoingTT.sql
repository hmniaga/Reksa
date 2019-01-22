
CREATE proc [dbo].[ReksaPopulateOutgoingTT]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120925
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130508, liliana, ODKIB12036, tampilkan data h-1
		20130617, liliana, ODKIB12036, alamat nya dipisah
		20130617, liliana, ODKIB12036, perbaikan
	END REVISED

*/
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)
	,@cCurrWorkingDate	datetime
	,@bCheck			bit

--20130508, liliana, ODKIB12036, begin	
--select @cCurrWorkingDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate())
--from fnGetWorkingDate()  
select @cCurrWorkingDate = current_working_date
from fnGetWorkingDate() 
--20130508, liliana, ODKIB12036, end
--20130617, liliana, ODKIB12036, begin
declare @cCurr	varchar(3),
		@dValDate	datetime

create table #tempValuta (
	Currency		varchar(3),
	ValueDate		datetime
)

insert #tempValuta (Currency, ValueDate)
select distinct Currency, @cCurrWorkingDate 
from dbo.ReksaTTOutgoing_TT

declare process_csr cursor for
	select Currency, ValueDate 
	from #tempValuta

open process_csr
while 1=1
begin
	fetch process_csr into @cCurr, @dValDate
	if @@fetch_status <> 0 break

--20130617, liliana, ODKIB12036, begin	
	--while (exists(select top 1 1 from SQL_SIBS.dbo.SWPAR4_v where SHCURR = @cCurr
	if (exists(select top 1 1 from dbo.SWPAR4_v where SHCURR = @cCurr
--20130617, liliana, ODKIB12036, end
		and SHDAT8 = convert(varchar,@dValDate,112))
		)
	Begin
		update #tempValuta
		set ValueDate = dateadd(dd, 1, ValueDate)

	end 
	
end
close process_csr
deallocate process_csr 
--20130617, liliana, ODKIB12036, end

set @bCheck = 0

select @bCheck as CheckB, 
	   rt.BillId, rp.ProdName, rt.NamaPemohon, rt.AlamatPemohon1, rt.AlamatPemohon2, rt.RemittanceNo,
--20130617, liliana, ODKIB12036, begin	   
	   --rt.TglPembelianReksadana, rt.TranDate as TanggalValuta, rt.NominalTransfer, rt.Currency, rt.NamaPenerima,
	     rt.TglPembelianReksadana, tt.ValueDate as TanggalValuta, rt.NominalTransfer, rt.Currency, rt.NamaPenerima,
--20130617, liliana, ODKIB12036, end	   
	   rt.AlamatPenerima, rt.PaymentRemarks, rt.BeneficiaryBankCode, rt.BeneficiaryBankName, rt.BeneficiaryBankAddress,
	   rt.BeneficiaryAccNo, rt.NoRekProduk, rt.GLBiayaFullAmt
from dbo.ReksaTTOutgoing_TT rt
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = rt.ProdId
--20130617, liliana, ODKIB12036, begin
	join #tempValuta tt
		on tt.Currency = rt.Currency
--20130617, liliana, ODKIB12036, end		
where rt.TranStatus = 0
--20130508, liliana, ODKIB12036, begin
	--and rt.TranDate <= @cCurrWorkingDate
	and rt.TranDate < @cCurrWorkingDate	
--20130508, liliana, ODKIB12036, end	
	
return 0

ERROR:  
If @@trancount > 0   
 rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Unknown Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1)
return 1
GO