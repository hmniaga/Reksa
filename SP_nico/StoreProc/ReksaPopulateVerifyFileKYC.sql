
CREATE proc [dbo].[ReksaPopulateVerifyFileKYC]  
/*  
 CREATED BY    : Lita
 CREATION DATE : 20180220
 DESCRIPTION   : populate pending auth data for Generate KYC S-Invest File
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
 END REVISED  
   
 
*/
  
@pnPeriod		int	-- @pnPeriod = 0 (ALL PERIOD)
, @pnFileType	int -- 0 : all, 1 : IND, 2 : INST
as  
  
set nocount on  
  
declare @bCheck      bit
    ,@dToday                        datetime
    , @cSQLStatement		nvarchar(max)

set @dToday = getdate()

set @bCheck = 0  

set @cSQLStatement		 = ''
set @cSQLStatement	= 'select LogId,Period,FileCode,FileName,GenerateData,RawData,GenerateDate,GenerateUser
from dbo.ReksaNFSFileRequest_TT tt left join ReksaNFSFileMaster_TM fm
on tt.FileCode = fm.FileCode
where tt.AuthStatus = ''P'''

if @pnPeriod <> 0 
	set @cSQLStatement = @cSQLStatement + ' and Period = '+ convert(varchar(10),@pnPeriod)

if @pnFileType = 1 -- IND
	set @cSQLStatement = @cSQLStatement + ' and substring(fm.TranType,5,3) = ''IND''' 
    
if @pnFileType = 2 -- INST
	set @cSQLStatement = @cSQLStatement + ' and substring(fm.TranType,5,3) = ''INS''' 

exec sp_executesql @cSQLStatement

return 0
GO