CREATE proc [dbo].[ReksaUpdateMFeeProcessAll]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120607
	DESCRIPTION   : Proses data sinkronisasi maintenance fee
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
	@nGuid uniqueidentifier

set @nOK = 0


declare process_csr cursor for
	select BatchGuid from dbo.ReksaMFeeUploadProcessLog_TH
	where Status = 1

open process_csr
while 1=1
begin
	fetch process_csr into @nGuid
	if @@fetch_status <> 0 break
	
	exec @nOK = ReksaUpdateMFeeProcess @nGuid, @pbAdHoc
	if @nOK <> 0 or @@error <> 0 continue
end
close process_csr
deallocate process_csr 
	
ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	raiserror (@cErrMsg,16,1)
	set @nOK = 1
end

return @nOK
GO