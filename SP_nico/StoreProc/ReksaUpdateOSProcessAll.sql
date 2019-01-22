CREATE proc [dbo].[ReksaUpdateOSProcessAll]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20100111
	DESCRIPTION   : Proses data sinkronisasi OS Unit Balance (otomatis)
	
	select dbo.fnReksaGetEffectiveDate(current_working_date, -2) 
	from control_table
	
	exec ReksaUpdateOSProcessAll 0
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
	@pbAdHoc bit = 0
as
set nocount on

declare
	@nOK tinyint,
	@cErrMsg varchar(255),
	@nGuid uniqueidentifier,
	@dMinDate datetime

set @nOK = 0
select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) 
from control_table

declare process_csr cursor for
	select BatchGuid from ReksaOSUploadProcessLog_TH
	where Status = 1
	and NAVValueDate >= @dMinDate
	order by NAVValueDate

open process_csr
while 1=1
begin
	fetch process_csr into @nGuid
	if @@fetch_status <> 0 break
	
	exec @nOK = ReksaUpdateOSProcess @nGuid, @pbAdHoc
	if @nOK <> 0 or @@error <> 0 continue
end
close process_csr
deallocate process_csr 
	
ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	raiserror (@cErrMsg ,16,1)
	set @nOK = 1
end

return @nOK
GO