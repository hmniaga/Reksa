CREATE proc [dbo].[ReksaUpdateOSSHDIDPopulateVerify]
/*
	CREATED BY    : liliana
	CREATION DATE : 20150604
	DESCRIPTION   : menampilkan list batch upload OS yg perlu disinkronsasi
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
*/
as

set nocount on

declare	@bCheck						bit,
		@cErrMsg					varchar(100),
		@nOK						tinyint     
		, @dMinDate					datetime

select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) 
from control_table

set @bCheck = 0
set @nOK = 0


select @bCheck as 'CheckB',
	upper(BatchGuid) as 'BatchGuid',    
	RefId,
	NAVValueDate, 
	FileName, 
	NumOfRecord as UploadedRecords,
	LastUser 
from ReksaOSSHDIDUploadProcessLog_TH
where Status = 0 -- uploaded
and Supervisor is null         
and NAVValueDate >= @dMinDate

ERROR:
if isnull(@cErrMsg, '') != '' 
begin
	set @nOK = 1
	raiserror (@cErrMsg ,16,1)
end

return @nOK
GO