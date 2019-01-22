
CREATE proc [dbo].[ReksaNFSInsertLogFile]
/*                  
    CREATED BY    : Lita                  
    CREATION DATE : 20170825
    DESCRIPTION   : INSERT LOG FILE
    REVISED BY    :                  
    DATE,  USER,   PROJECT,  NOTE                  
    -----------------------------------------------------------------------                      
    END REVISED

*/
@pcFileCode varchar(10)
, @pcFileName varchar(200)
, @pcUserId varchar(20)
, @pnDate	int
, @pxXMLData xml
, @pxRawXMLData	xml
, @pbIsLog	bit
, @pbIsNeedAuth	bit
as                  
set nocount on

declare @cErrMsg varchar(500)

begin try
	if @pbIsNeedAuth = 1
	begin
		insert into ReksaNFSFileRequest_TT (Period, FileCode, [FileName], GenerateDate, GenerateUser, GenerateData, RawData, IsNeedAuth, AuthStatus)
		select @pnDate, @pcFileCode, @pcFileName, getdate(), @pcUserId, @pxXMLData, @pxRawXMLData, @pbIsNeedAuth, 'P'	
	end

	if (@pbIsLog = 1 and @pbIsNeedAuth = 0)
	begin
		insert into ReksaNFSFileLog_TH (LogId, Period, FileCode, [FileName], GenerateDate, GenerateUser, GenerateData, RawData, IsNeedAuth, AuthStatus, AuthDate, AuthUser)
		select max(LogId)+1, @pnDate, @pcFileCode, @pcFileName, getdate(), @pcUserId, @pxXMLData, @pxRawXMLData, @pbIsNeedAuth, 'A', getdate(), 'SYSTEM'
		from ReksaNFSFileLog_TH
	end
end try
begin catch
    if @@trancount > 0 rollback tran  
    
    set @cErrMsg = '[ReksaNFSInsertLogFile] '+ error_message()
    raiserror ( @cErrMsg , 16,1);

    return 1
end catch
GO