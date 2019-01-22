
CREATE proc [dbo].[ReksaNFSGenerateFileUpload_TEXT]
/*                  
	CREATED BY    : Lita                  
	CREATION DATE : 20160204
	DESCRIPTION   : GENERATE NFS FILE UPLOAD BASED ON PARAMETER             
	REVISED BY    :                  
	DATE,  USER,   PROJECT,  NOTE                  
	-----------------------------------------------------------------------                      
	END REVISED
	select * from ReksaNFSFileMaster_TM
	select * from ReksaNFSFileSetting_TR where FileCode = 'UPL004' order by FileSettingId desc

	exec ReksaNFSGenerateFileUpload_TEXT 'UPL001',20160201,0  -- KYC IND
	exec ReksaNFSGenerateFileUpload_TEXT 'BCK004',20120525,0  -- SUBS REDEMP
	exec ReksaNFSGenerateFileUpload 'UPL005',20120525,0  -- SUBS REDEMP

	-- PAR001
	select NFSInvestorFundAcc,* from ReksaMasterNasabah_TM where NasabahId = 11
	exec ReksaNFSGenerateFileUpload 'PAR001',0,11
	select NFSInvestorFundAcc,* from ReksaMasterNasabah_TM where NasabahId = 11

	
*/
@pcFileCode	varchar(10)     
, @pnDate int = 0
, @pnKeyValue int = 0
as                  
set nocount on
                  
declare 
@cQueryVariable	nvarchar(max),
@cQueryTable     nvarchar(max),
@cQueryInsertTemp	nvarchar(max),
@cInsertColumnList	nvarchar(max),
@cUpdateStatement	nvarchar(max),
@cQuerySelect		nvarchar(max),
@cQueryBeforeSelect	nvarchar(max),
@cQueryAfterSelect	nvarchar(max),
@cQuerySelectParam	nvarchar(500),
@cSortBy			varchar(50),

@cFileType		char(1),
@cFieldSeparator varchar(2),

@cTableName			varchar(50),
-- change - begin
--@cWhereCondition	varchar(max),
@cInsertCommand		varchar(max),
-- change - end
@cMainTable			varchar(50),
@cFieldKey1			varchar(50),
@cFieldKeyDataType1	varchar(50),
@cFieldKey2			varchar(50),
@cFieldKeyDataType2	varchar(50),
@cFieldKey3			varchar(50),
@cFieldKeyDataType3	varchar(50),
@cFieldKey4			varchar(50),
@cFieldKeyDataType4	varchar(50),
@cFieldKey5			varchar(50),
@cFieldKeyDataType5	varchar(50)

set @cQuerySelectParam	 = ''
set @cQueryVariable	 = ''
set @cQueryTable = ''
set @cQueryInsertTemp = ''
set @cInsertColumnList = ''
set @cUpdateStatement = ''
SET @cQuerySelect = ''
SET @cQueryBeforeSelect = ''
SET @cQueryAfterSelect = ''

select @cQueryVariable = isnull(VariableList,'') + char(10) + isnull(InitializeVariable,'')
-- change - begin
	 --, @cWhereCondition = isnull(WhereCondition,''), @cMainTable = isnull(MainTable,'')
	 , @cInsertCommand = isnull(InsertCommand,''), @cMainTable = isnull(MainTable,'')
-- change - end
	 , @cFieldKey1 = isnull(FieldKey1,''), @cFieldKeyDataType1 = isnull(FieldKeyDataType1,'')
	 , @cFieldKey2 = isnull(FieldKey2,''), @cFieldKeyDataType2 = isnull(FieldKeyDataType2,'')
	 , @cFieldKey3 = isnull(FieldKey3,''), @cFieldKeyDataType3 = isnull(FieldKeyDataType3,'')
	 , @cFieldKey4 = isnull(FieldKey4,''), @cFieldKeyDataType4 = isnull(FieldKeyDataType4,'')
	 , @cFieldKey5 = isnull(FieldKey5,''), @cFieldKeyDataType5 = isnull(FieldKeyDataType5,'')
	 , @cQueryBeforeSelect = isnull(BeforeSelectCommand,''), @cQueryAfterSelect = isnull(AfterSelectCommand,'')
	 , @cFileType = FileType , @cFieldSeparator = FieldSeparator
	 , @cSortBy = SortBy
from ReksaNFSFileMaster_TM
where FileCode = @pcFileCode

--exec sp_executesql N'drop table #TempData'
set @cQueryTable = N'


CREATE TABLE #TempData ('
set @cQueryTable = @cQueryTable + @cFieldKey1 + ' '+ @cFieldKeyDataType1 + ','

-- RESERVED FIELD - BEGIN
if (@cFieldKey2 <> '')
	set @cQueryTable = @cQueryTable + @cFieldKey2 + ' '+ @cFieldKeyDataType2 + ','

if (@cFieldKey3 <> '')
	set @cQueryTable = @cQueryTable + @cFieldKey3 + ' '+ @cFieldKeyDataType3 + ','

if (@cFieldKey4 <> '')
	set @cQueryTable = @cQueryTable + @cFieldKey4 + ' '+ @cFieldKeyDataType4 + ','

if (@cFieldKey5 <> '')
	set @cQueryTable = @cQueryTable + @cFieldKey5 + ' '+ @cFieldKeyDataType5 + ','
-- RESERVED FIELD - END

select @cQueryTable = @cQueryTable + isnull(FieldName,'') + ' '+ isnull(FieldDataType,'')  + ','
from ReksaNFSFileSetting_TR
where FileCode = @pcFileCode
order by FileSettingId

set @cQueryTable = left(@cQueryTable, len(@cQueryTable)-1)

set @cQueryTable = @cQueryTable + ')'+ char(10)

-- QUERY INSERT TABLE TEMP
set @cQueryInsertTemp = '--select @pnDate, @pnKeyValue' + char(10) + @cInsertCommand

-- UPDATE VALUE SECTION - BEGIN
if exists (select top 1 1 from ReksaNFSFileSetting_TR where FileCode = @pcFileCode and IsNeedUpdate = 1 and IsFromVariable = 0)
begin
	select @cUpdateStatement = @cUpdateStatement + UpdateStatement + char(10)
	from ReksaNFSFileSetting_TR
	where FileCode = @pcFileCode and IsNeedUpdate = 1 and IsFromVariable = 0
end
-- UPDATE VALUE SECTION - END

-- UPDATE VALUE SECTION (FROM VARIABLE) - BEGIN
if exists (select top 1 1 from ReksaNFSFileSetting_TR where FileCode = @pcFileCode and IsNeedUpdate = 1 and IsFromVariable = 1)
begin
	select @cUpdateStatement = @cUpdateStatement + 'UPDATE #TempData SET '+FieldName+' = convert(varchar,'+SourceColumn +')' +  char(10)
	from ReksaNFSFileSetting_TR
	where FileCode = @pcFileCode and IsNeedUpdate = 1 and IsFromVariable = 1
	order by FileSettingId asc
end

set @cInsertColumnList = @cInsertColumnList + char(10) + @cUpdateStatement+ char(10)
-- UPDATE VALUE SECTION (FROM VARIABLE) - END

-- SELECT SECTION - BEGIN
set @cQuerySelect ='select '

select @cQuerySelect = @cQuerySelect + 'isnull(convert(varchar, convert('+FieldDataType+',' + FieldName+')),'''') + '''+ @cFieldSeparator+ '''+'
from ReksaNFSFileSetting_TR 
where FileCode = @pcFileCode and IsVisible = 1
order by FileSettingId


set @cQuerySelect = left(@cQuerySelect, len(@cQuerySelect)-6)
SELECT '@cQuerySelect', @cQuerySelect

set @cQuerySelect = @cQuerySelect + ' from #TempData' + char(10) 
select @cQuerySelect = @cQuerySelect +  case when @cSortBy <> '' then ' order by '+ @cSortBy else ' ' + char(10) end
set @cQuerySelect = @cQuerySelect + char(10) 

-- Tables[0]
if (@cFileType <> 'P')
begin
	set @cQuerySelectParam	= '
	declare @cFormatFile varchar(5), @cFilterFileDialog varchar(20)
	select @cFormatFile = [FormatFile], @cFilterFileDialog = FilterFileDialog from ReksaNFSFileMaster_TM where FileCode = @pcFileCode
	select @cFieldSeparator, @cFileName, @cFormatFile, @cFilterFileDialog'
end

set @cQueryInsertTemp =  @cQueryVariable + char(10) + @cQueryTable + char(10)+ @cQueryInsertTemp + char(10) + @cInsertColumnList + char(10) + case when @cFileType <> 'P' then @cQuerySelectParam + CHAR(10) + @cQueryBeforeSelect + char(10) + @cQuerySelect 



else '' end + @cQueryAfterSelect + char(10) + ' drop table #TempData'

select '@cQueryInsertTemp', @cQueryInsertTemp

-- Tables[1]
exec sp_executesql @cQueryInsertTemp
		, N'@pcFileCode varchar(10), @pnDate int, @pnKeyValue int, @cFieldSeparator varchar(2)'
		, @pcFileCode = @pcFileCode, @pnDate = @pnDate, @pnKeyValue= @pnKeyValue, @cFieldSeparator = @cFieldSeparator
		
return 0
GO