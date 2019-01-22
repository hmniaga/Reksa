
CREATE proc [dbo].[ReksaPopulateProcess]
/*
	CREATED BY    : victor
	CREATION DATE : 20071106
	DESCRIPTION   : menampilkan process yang dapat di eksekusi
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071217, indra_w, REKSADN002, perbaikan UAT
	END REVISED
	exec dbo.ReksaPopulateProcess	null, null
*/
@pnNik								int,
@pcGuid								varchar(100)

as

set nocount on

declare	@bCheck						bit,
		@cErrMsg					varchar(100),
--20071217, indra_w, REKSADN002, begin
		@nOK						tinyint,
		@dCurrWorkingDate			datetime
--20071217, indra_w, REKSADN002, end

set @bCheck = 0
set @nOK = 0
--20071217, indra_w, REKSADN002, begin
select @dCurrWorkingDate = current_working_date
from dbo.fnGetWorkingDate()
select @bCheck as 'CheckB', ProcessId, SPName, ProcessName, ProcessStatus
	, dateadd(minute,CutOff,@dCurrWorkingDate) as 'Cut Off System'
--20071217, indra_w, REKSADN002, end
from dbo.ReksaUserProcess_TR

ERROR:
if isnull(@cErrMsg, '') != '' 
begin
	set @nOK = 1
	raiserror (@cErrMsg,16,1);
end

return @nOK
GO