
CREATE PROC [dbo].[ReksaPopulateVerifyCancelTrxIBMB]
/*
	CREATED BY    : Liliana
	CREATION DATE : 20130520
	DESCRIPTION   :
	REVISED BY    :
	
	DATE, USER, PROJECT, NOTE
	-----------------------------------------------------------------------	  
	20131106, liliana, BAALN11010, perbaikan
	END REVISED
	 
*/
@cNik        int
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@dToday							datetime,
	@bCheck							bit
  
set @bCheck = 0

set @dToday = getdate()

select @bCheck as CheckB,
		ib.CancelId as Id,
		case when ib.TranType = 1 then 'Subscription New' 
			when ib.TranType = 2 then 'Subscription Add' 
			when ib.TranType = 3 then 'Redemption Sebagian' 
			when ib.TranType = 4 then 'Redemption All' 
			when ib.TranType = 5 then 'Switching Sebagian' 
			when ib.TranType = 6 then 'Switching All'
--20131106, liliana, BAALN11010, begin			 
		--else ib.TranType
		else convert(varchar(100),ib.TranType)
--20131106, liliana, BAALN11010, end		
		end as TransactionType,
		ib.TranCode as TranCode,
		ib.NoReferensi as ReferenceNumber,
		ib.TranDate,
		ib.NAVValueDate,
		rc.ClientCode,
		rp.ProdName as ProductName,		
		rc2.ClientCode as ClientCodeSwitchIn,
		rp2.ProdName as ProductNameSwitchIn,		
		ib.TranAmt,
		ib.TranUnit,
		ib.Fee,
		rcl.ChannelDesc as Channel,
		ib.UserInput,
		ib.DateInput
from dbo.ReksaCancelTrxIBMB_TT ib
	join dbo.ReksaCIFData_TM rc
		on ib.ClientId = rc.ClientId
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = ib.ProdId
--20131106, liliana, BAALN11010, begin		
	--join dbo.ReksaCIFData_TM rc2	
		--on ib.ClientId = rc2.ClientId
	--join dbo.ReksaProduct_TM rp2
	--	on rp2.ProdId = ib.ProdId		
	left join dbo.ReksaCIFData_TM rc2
		on ib.ClientIdSwitchIn = rc2.ClientId
	left join dbo.ReksaProduct_TM rp2
		on rp2.ProdId = ib.ProdIdSwitchIn
--20131106, liliana, BAALN11010, end			
	join dbo.ReksaChannelList_TM rcl
		on rcl.ChannelCode = ib.Channel
where ib.StatusOtor = 0
          
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

	raiserror (@cErrMessage ,16,1);
	return 1
GO