
CREATE PROC [dbo].[ReksaPopulateCancelTrxIBMB]
/*
	CREATED BY    : Liliana
	CREATION DATE : 20130508
	DESCRIPTION   :
	REVISED BY    :
	
	DATE, USER, PROJECT, NOTE
	-----------------------------------------------------------------------	  
    20131106, liliana, BAALN11010, ganti channel
	END REVISED
	 
	 exec ReksaPopulateCancelTrxIBMB
*/
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@bCheck							bit,
	@dCurrWorkingDate				datetime	  
  
set @bCheck =0  

select @dCurrWorkingDate = current_working_date       
from dbo.control_table       
      

select   
	@bCheck as 'Check',	
	tt.ReferenceNumber as  NoReferensi,
	tt.TranCode as TranCode,
--20131106, liliana, BAALN11010, begin	
	--case when tt.Channel = 'IB' then 'Internet Banking'
	case when tt.Channel = 'INB' then 'Internet Banking'
--20131106, liliana, BAALN11010, end	
	  when tt.Channel = 'MB' then 'Mobile Banking'
	end as SumberTransaksi,
	tt.TranType,
	case when tt.TranType = 1 then 'Subscription New'
	  when tt.TranType = 2 then 'Subscription Add'
	  when tt.TranType = 3 then 'Redemption Sebagian'
	  when tt.TranType = 4 then 'Redemption All'
	end as JenisTransaksi,
--20131106, liliana, BAALN11010, begin
	rc.CIFNo as CIFNo,
--20131106, liliana, BAALN11010, end	
	rc.CIFName as NamaNasabah,
	rc.ShareholderID,
	rc.ClientCode,
	rp.ProdName as NamaProduk,
	tt.TranCCY as MataUang,
	''		   as NamaProdukTujuanPengalihan,
	''		   as ClientCodeTujuanPengalihan,	
	tt.TranDate as TanggalTransaksi,
	tt.NAVValueDate as TanggalValuta,
	tt.TranAmt as NominalTransaksi,
--20131106, liliana, BAALN11010, begin	
	--tt.TranUnit as NominalUnit,
	tt.TranUnit as UnitTransaksi,
--20131106, liliana, BAALN11010, end	
	case when tt.TranType in (1,2) then tt.SubcFee
	  when tt.TranType in (3,4) then tt.RedempFee
	end as Fee
from dbo.ReksaTransaction_TT tt
join dbo.ReksaCIFData_TM rc
	on tt.ClientId = rc.ClientId
join dbo.ReksaProduct_TM rp
	on rp.ProdId = tt.ProdId
where tt.Status = 1
	and tt.CheckerSuid is not null 
--20131106, liliana, BAALN11010, begin	
	--and tt.Channel in ('IB','MB')
	and tt.Channel in ('INB','MB')
--20131106, liliana, BAALN11010, end	
	and tt.BillId is null 
	and tt.ReverseSuid is null  
	and tt.NAVValueDate >= @dCurrWorkingDate
	and tt.TranType in (1,2,3,4)
union all
select   
	@bCheck as 'Check',
	ts.ReferenceNumber as  NoReferensi,
	ts.TranCode as TranCode,
--20131106, liliana, BAALN11010, begin		
	--case when ts.Channel = 'IB' then 'Internet Banking'
	case when ts.Channel = 'INB' then 'Internet Banking'
--20131106, liliana, BAALN11010, end	
	  when ts.Channel = 'MB' then 'Mobile Banking'
	end as SumberTransaksi,
	ts.TranType,
	case when ts.TranType = 5 then 'Switching Sebagian'
	  when ts.TranType = 6 then 'Switching All'
	end as JenisTransaksi,
--20131106, liliana, BAALN11010, begin
	rc.CIFNo as CIFNo,
--20131106, liliana, BAALN11010, end	
	rc.CIFName as NamaNasabah,
	rc.ShareholderID,
	rc.ClientCode,
	rp.ProdName as NamaProduk,
	ts.TranCCY as MataUang,
	rp1.ProdName as NamaProdukTujuanPengalihan,
	rc1.ClientCode as ClientCodeTujuanPengalihan,	
	ts.TranDate as TanggalTransaksi,
	ts.NAVValueDate as TanggalValuta,
	ts.TranAmt as NominalTransaksi,
--20131106, liliana, BAALN11010, begin		
	--ts.TranUnit as NominalUnit,
	ts.TranUnit as UnitTransaksi,
--20131106, liliana, BAALN11010, end	
	ts.SwitchingFee as Fee
from dbo.ReksaSwitchingTransaction_TM ts
join dbo.ReksaCIFData_TM rc
	on ts.ClientIdSwcOut = rc.ClientId
join dbo.ReksaProduct_TM rp
	on rp.ProdId = ts.ProdSwitchOut
join dbo.ReksaCIFData_TM rc1
	on ts.ClientIdSwcIn = rc1.ClientId
join dbo.ReksaProduct_TM rp1
	on rp1.ProdId = ts.ProdSwitchIn	
where ts.Status = 1
	and ts.CheckerSuid is not null 
--20131106, liliana, BAALN11010, begin		
	--and ts.Channel in ('IB','MB')
	and ts.Channel in ('INB','MB')
--20131106, liliana, BAALN11010, end		
	and ts.BillId is null 
	and ts.ReverseSuid is null  
	and ts.NAVValueDate >= @dCurrWorkingDate
	and ts.TranType in (5,6)
  
          
RETURN 0

ERROR:
----------------------------------------------------------------------		
	if @@trancount > 0
		rollback tran
					
	if @cErrMessage is null 	
		set @cErrMessage = 'Error tidak diketahui pada procedure !'
	
	--exec @nOK = dbo.set_raiserror @@procid, @nErrNo output
	--if @nOK <> 0 or @@error <> 0 
	--	return 1

	raiserror (@cErrMessage,16,1);
	return 1
GO