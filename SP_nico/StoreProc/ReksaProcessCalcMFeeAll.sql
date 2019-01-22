CREATE proc [dbo].[ReksaProcessCalcMFeeAll]
/*
	CREATED BY    : liliana
	CREATION DATE : 20121005
	DESCRIPTION   : Proses perhitungan data Maintenance Fee per periode
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130419, liliana, BATOY12006, fix
	END REVISED
*/
as
set nocount on

declare
	@nOK		tinyint,
	@cErrMsg	varchar(255),
	@nProdId	int,
	@nClientId	int,
	@dValueDate	datetime,
	@nUserSuid	int,
	@nProcID	int,
	@nErrNo		int
	,@dCurrDate			datetime
	,@dCurrWorkingDate	datetime

set @nOK = 0

exec @nOK = set_usersuid @nUserSuid output  
if @nOK != 0 or @@error != 0 return 1  

exec @nOK = cek_process_table @nProcID = @@procid   
if @nOK != 0 or @@error != 0 return 1  

exec @nOK = set_process_table @@procid, null, @nUserSuid, 1  
if @nOK != 0 or @@error != 0 return 1  


select @dValueDate = previous_working_date
	   ,@dCurrWorkingDate = current_working_date
from dbo.fnGetWorkingDate()

select @dCurrDate = current_working_date
from dbo.control_table


create table #ReksaOSUploadLog_TH (
	ClientId			int,
	ClientCode			varchar(20),
	ProdId				int
)

create table #ReksaOSUploadProcessLog_TH (
	BatchGuid		uniqueidentifier,
	NAVValueDate	datetime
)

create table #ReksaProductMaintenanceFee_TR (
	ProdId			int
)

insert #ReksaProductMaintenanceFee_TR
select distinct rp.ProdId
from dbo.ReksaProduct_TM rp
	join dbo.ReksaProductMaintenanceFee_TR rm
		on rm.ProdId = rp.ProdId
	join dbo.ReksaParamFee_TM rf
		on rf.ProdId = rp.ProdId
where rp.[Status] = 1
		and rm.MaintFee > 0
		and rf.TrxType = 'MFEE'
		and isnull(rf.PeriodEfektifMFee, 0) > 0

insert #ReksaOSUploadProcessLog_TH (BatchGuid, NAVValueDate)
select BatchGuid, NAVValueDate
from dbo.ReksaOSUploadProcessLog_TH
where NAVValueDate = @dValueDate
	and Status = 3

insert #ReksaOSUploadLog_TH (ClientCode)
select ro.ClientCode
from dbo.ReksaOSUploadLog_TH ro
	join #ReksaOSUploadProcessLog_TH tr
		on ro.BatchGuid = tr.BatchGuid
		
update th
set ClientId = rc.ClientId,
	ProdId = rc.ProdId
from #ReksaOSUploadLog_TH th
	join dbo.ReksaCIFData_TM rc
		on th.ClientCode = rc.ClientCode
		
select th.ClientId, th.ProdId
into #CalcMFee
from #ReksaOSUploadLog_TH th
	join #ReksaProductMaintenanceFee_TR rp
		on rp.ProdId = th.ProdId

if(@dCurrWorkingDate = @dCurrDate)
begin

	declare process_csr cursor for
		select ro.ProdId, ro.ClientId
--20130419, liliana, BATOY12006, begin		
		--from #CalcMFee
		from #CalcMFee ro
--20130419, liliana, BATOY12006, end		

	open process_csr
	while 1=1
	begin
		fetch process_csr into @nProdId, @nClientId
		if @@fetch_status <> 0 break
		
		exec @nOK = ReksaProcessCalcMFee @dValueDate, @nProdId, @nClientId
		if @nOK <> 0 or @@error <> 0 continue
		
	end
	close process_csr
	deallocate process_csr 
end

drop table #CalcMFee
drop table #ReksaProductMaintenanceFee_TR
drop table #ReksaOSUploadProcessLog_TH
drop table #ReksaOSUploadLog_TH

exec @nOK = set_process_table @@procid, null, @nUserSuid, 0
if @nOK != 0 or @@error != 0 return 1  
	
ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	if @@trancount>0 rollback tran  

	exec @nOK = set_process_table @@procid, null, @nUserSuid, 2
	if @nOK != 0 or @@error != 0 return 1  

	--exec @nOK = set_raiserror @@procid, @nErrNo output  
	--if @nOK<>0 or @@error<>0 return 1  

	raiserror (@cErrMsg ,16,1);
	set @nOK = 1
end

return @nOK
GO