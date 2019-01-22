
CREATE proc [dbo].[ReksaNFSGenerateFileDownload]    
/*                  
    CREATED BY    : Lita                  
    CREATION DATE : 20160204
    DESCRIPTION   : GENERATE NFS FILE DOWNLOAD BASED ON PARAMETER             
    REVISED BY    :                  
    DATE,  USER,   PROJECT,  NOTE                  
    -----------------------------------------------------------------------                      
    END REVISED
    select * from ReksaNFSFileMaster_TM
    select * from ReksaNFSFileSetting_TR where FileCode = 'DOWN001' order by FileSettingId desc

	-- DOWNLOAD KYC FROM NFS
	declare @pcErrMsg		varchar(500) 
    exec ReksaNFSGenerateFileDownload 'DOWN001','test.csv', '<NewDataSet><Table><ClientCode>100002</ClientCode><SII>IDD160293879422</SII><IFUA>NSP69008658F0153</IFUA></Table><Table><ClientCode>200111</ClientCode><SII>IDD0205D7370734</SII><IFUA>NSP69021308F0124</IFUA></Table></NewDataSet>'
	, 'WEALTHMGMT', @pcErrMsg output

	select @pcErrMsg 
	select * from ReksaNFSDownload_TH   
	select * from ReksaNFSDownloadKYC_TT 

*/
@pcFileCode varchar(10)
, @pcFileName	varchar(50)
, @pxXMLData	xml
, @pcUserId	varchar(20)
, @pcErrMsg		varchar(500) output
as                  
set nocount on

set @pcErrMsg = ''

if (@pxXMLData is not null)
begin
	--insert into ReksaNFSDownload_TH ([FileName], FileCode, GenerateDate, UserId, XMLData)
	--select @pcFileName, @pcFileCode, getdate(), @pcUserId, @pxXMLData

	declare @cMainTable varchar(50)
	, @nDownloadId bigint
	, @cBeforeSelectCommand varchar(max)
	, @cAfterSelectCommand varchar(max)
	, @cQuery nvarchar(max)
	, @cQueryTable nvarchar(max)
	, @cQueryConvertXML nvarchar(max)

	BEGIN TRY
	select 
		  @cMainTable = MainTable 
		  , @cBeforeSelectCommand = isnull(BeforeSelectCommand,'')
		  , @cAfterSelectCommand = isnull(AfterSelectCommand,'')
	from ReksaNFSFileMaster_TM
	where FileCode = @pcFileCode

	-- CREATE DATA TEMP
	set @cQueryTable = N'
	CREATE TABLE #TempData ('

	select @cQueryTable = @cQueryTable + isnull(FieldName,'') + ' '+ isnull(FieldDataType,'')  + ','
	from ReksaNFSFileSetting_TR
	where FileCode = @pcFileCode
	order by FileSettingId

	set @cQueryTable = left(@cQueryTable, len(@cQueryTable)-1)
	set @cQueryTable = @cQueryTable + ')'+ char(10)
	set @cQueryTable = @cQueryTable + 'INSERT INTO #TempData'+ char(10)

	-- CONVERT XML
	set @cQueryConvertXML = '
	select '

	select @cQueryConvertXML = @cQueryConvertXML + 'U.value(''('+isnull(FieldName,'')+')[1]'', '''+isnull(FieldDataType,'') +'''), '
	from ReksaNFSFileSetting_TR
	where FileCode = @pcFileCode
	order by FileSettingId

	set @cQueryConvertXML = left(@cQueryConvertXML, len(@cQueryConvertXML)-1)
	set @cQueryConvertXML = @cQueryConvertXML + char(10)

	set @cQueryConvertXML = @cQueryConvertXML + 'FROM @pxXML.nodes(''/NewDataSet/Table'') AS Data(U)'

	set @cQuery = @cBeforeSelectCommand + char(10)
	set @cQuery = @cQuery + @cQueryTable + @cQueryConvertXML + char(10)
	set @cQuery = @cQuery + 'select * from #TempData' + char(10)
	set @cQuery = @cQuery + @cAfterSelectCommand

	select 'DEBUG',@cQuery

	-- Tables[1]

	BEGIN TRAN

	insert into ReksaNFSDownload_TH ([FileName], FileCode, GenerateDate, UserId, XMLData)
	select @pcFileName, @pcFileCode, getdate(), @pcUserId, @pxXMLData

	set @nDownloadId= @@identity

	exec sp_executesql @cQuery
		, N'@pxXML xml, @pnDownloadId bigint'
		, @pxXML = @pxXMLData, @pnDownloadId = @nDownloadId
		
	COMMIT TRAN	
		
	return 0	       
	END TRY
	begin catch
		if @@trancount > 0 rollback tran  
	
		set @pcErrMsg = '[ReksaNFSGenerateFileDownload] '+ error_message()
	
		return 1
	end catch
end
GO