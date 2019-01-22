CREATE proc [dbo].[ReksaUpdateOSPopulateVerify]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20090604
	DESCRIPTION   : menampilkan list batch upload OS yg perlu disinkronsasi
	
	exec ReksaUpdateOSPopulateVerify 
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20091214, oscar, REKSADN014, ganti BatchGuid menjadi RefId
		20100111, oscar, REKSADN014, batasi maks H-2 saja yg muncul    
		20100203, oscar, REKSADN014, buat check in
	END REVISED
*/
as

set nocount on

declare	@bCheck						bit,
		@cErrMsg					varchar(100),
		@nOK						tinyint     
--20100203, oscar, REKSADN014, begin		
--20100111, oscar, REKSADN014, begin
		, @dMinDate					datetime

select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) 
from control_table
--20100111, oscar, REKSADN014, end   
--20100203, oscar, REKSADN014, end

set @bCheck = 0
set @nOK = 0

--BatchGuid                            TransactionDate         FileName                                                                                                                                               NumOfRecord Status      LastUpdate              LastUser    Supervisor
-------------------------------------- ----------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------ ----------- ----------- ----------------------- ----------- -----------
--B52621FA-5744-489A-A21E-931396F6FA28 2009-06-04 10:14:10.350 D:\Projects\Projects\Reksadana\REKSADN013\Sample\Test1.xml                                                                                             19          0           2009-06-04 10:14:10.350 10008       NULL


select @bCheck as 'CheckB',
	upper(BatchGuid) as 'BatchGuid',    
--20100203, oscar, REKSADN014, begin
--20091214, oscar, REKSADN014, begin
	RefId,
--20091214, oscar, REKSADN014, end  
--20100203, oscar, REKSADN014, end
	NAVValueDate, 
	FileName, 
	NumOfRecord as UploadedRecords,
	LastUser 
from ReksaOSUploadProcessLog_TH
where Status = 0 -- uploaded
and Supervisor is null         
--20100203, oscar, REKSADN014, begin
--20100111, oscar, REKSADN014, begin
and NAVValueDate >= @dMinDate
--20100111, oscar, REKSADN014, end    
--20100203, oscar, REKSADN014, end

ERROR:
if isnull(@cErrMsg, '') != '' 
begin
	set @nOK = 1
	raiserror (@cErrMsg,16,1)
end

return @nOK
GO