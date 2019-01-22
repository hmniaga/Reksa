
CREATE proc [dbo].[ReksaNonAktifClientId]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120423
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120627, liliana, BAALN12010, pengecekan transaksi
		20120809, liliana, BAALN12010, Tambah BillId is null
	END REVISED

*/
@pnClientId				int,
@pnNIK					int,
@pmUnitBalance			money
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)
	,@dToday			datetime
	
select @dToday = current_working_date
from dbo.control_table
	
if(@pmUnitBalance != 0)
begin
	set @cErrMsg = 'Client code tersebut masih ada outstanding, tidak bisa ditutup!'
	GOTO ERROR
end	
else if exists(select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientId and CIFStatus = 'T')
begin
	set @cErrMsg = 'Client code tersebut sudah tutup.'
	GOTO ERROR
end
else if exists(select top 1 1 from dbo.ReksaNonAktifClientId_TT where StatusOtor = 0 and ClientId = @pnClientId)
begin
	set @cErrMsg = 'Client code tersebut sudah pernah disubmit dan menunggu otorisasi.'
	GOTO ERROR
end
else if exists(select top 1 1 from  dbo.ReksaSwitchingTransaction_TM rs 
left join dbo.ReksaTransaction_TT rt on rs.TranCode = rt.TranCode
where rs.Status in (0,1) and rs.ClientIdSwcOut = @pnClientId and rt.TranCode is null
--20120809, liliana, BAALN12010, begin
  and rs.BillId is null
--20120809, liliana, BAALN12010, end
)
begin
	set @cErrMsg = 'Client code masih ada transaksi Switch out yang terjadi'
	GOTO ERROR
end
else if exists(select top 1 1 from  dbo.ReksaSwitchingTransaction_TM rs 
left join dbo.ReksaTransaction_TT rt on rs.TranCode = rt.TranCode
where rs.Status in (0,1) and rs.ClientIdSwcIn = @pnClientId and rt.TranCode is null
--20120809, liliana, BAALN12010, begin
  and rs.BillId is null
--20120809, liliana, BAALN12010, end
)
begin
	set @cErrMsg = 'Client code masih ada transaksi Switch in yang terjadi'
	GOTO ERROR
end
--20120627, liliana, BAALN12010, begin
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and ProcessDate is null and ClientId =@pnClientId and GoodFund <= @dToday)
--begin
--	set @cErrMsg = 'Client code masih ada transaksi redempt yang belum settle.'
--	GOTO ERROR
--end
--else if exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType in (3,4) and ProcessDate is null and ClientId =@pnClientId and GoodFund <= @dToday)
--begin
--	set @cErrMsg = 'Client code masih ada transaksi redempt yang belum settle.'
--	GOTO ERROR
--end
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where ProcessDate is null and ClientId =@pnClientId)
--begin
--	set @cErrMsg = 'Client code masih ada transaksi (subsc New/Add, Redemption, Switching dan RDB) yang terjadi'
--	GOTO ERROR
--end
--else if exists(select top 1 1 from dbo.ReksaTransaction_TH where ProcessDate is null and ClientId =@pnClientId)
--begin
--	set @cErrMsg = 'Client code masih ada transaksi (subsc New/Add, Redemption, Switching dan RDB) yang terjadi'
--	GOTO ERROR
--end
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and ProcessDate is null and ClientId =@pnClientId and GoodFund <= @dToday and Status = 1)
begin
	set @cErrMsg = 'Client code masih ada transaksi redempt yang belum settle.'
	GOTO ERROR
end
else if exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType in (3,4) and ProcessDate is null and ClientId =@pnClientId and GoodFund <= @dToday  and Status = 1)
begin
	set @cErrMsg = 'Client code masih ada transaksi redempt yang belum settle.'
	GOTO ERROR
end
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where ProcessDate is null and ClientId =@pnClientId and Status in (0,1))
begin
	set @cErrMsg = 'Client code masih ada transaksi (subsc New/Add, Redemption, Switching dan RDB) yang terjadi'
	GOTO ERROR
end
else if exists(select top 1 1 from dbo.ReksaTransaction_TH where ProcessDate is null and ClientId =@pnClientId  and Status in (0,1))
begin
	set @cErrMsg = 'Client code masih ada transaksi (subsc New/Add, Redemption, Switching dan RDB) yang terjadi'
	GOTO ERROR
end
--20120627, liliana, BAALN12010, end
else
begin
	
	insert dbo.ReksaNonAktifClientId_TT (ClientId, Outstanding, UserInput, DatetimeInput, StatusOtor)
	select @pnClientId, @pmUnitBalance, @pnNIK, getdate(), 0
	
end

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