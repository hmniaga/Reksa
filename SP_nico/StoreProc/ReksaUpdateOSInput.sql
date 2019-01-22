CREATE proc [dbo].[ReksaUpdateOSInput]  
/*  
 CREATED BY    : Oscar Marino  
 CREATION DATE : 20090508  
 DESCRIPTION   : Proses input data XML upload sinkronisasi OS Unit  
   
 ReksaOSUploadProcessLog_TH, Status   
  0 = baru upload  
  1 = approved  
  2 = rejected  
   
 delete from ReksaOSUploadProcessLog_TH  
 delete from ReksaOSUploadLog_TH  
   
 select * from ReksaOSUploadProcessLog_TH  
 select * from ReksaOSUploadLog_TH  
   
 declare @nGuid uniqueidentifier  
 exec ReksaUpdateOSInput   
  @pcFileName = 'Testing.xml'  
  ,@pdNAVDate = '20090225'  
  ,@pxXML = '<Balance><Balance><EODDate>2009-02-25 00:00:00</EODDate><CLCode>ISP-00029949</CLCode><AGCode>MED-180</AGCode><FDCode>RDISP</FDCode><EndBalUnit>1.9999000000000</EndBalUnit><CheckList>3165</CheckList></Balance><Balance><EODDate>2009-02-25 00:00
  
:00</EODDate><CLCode>PS4-00033427</CLCode><AGCode>RAD-058</AGCode><FDCode>RDPS4</FDCode><EndBalUnit>1.9999000000000</EndBalUnit><CheckList>3086</CheckList></Balance><Balance><EODDate>2009-02-25 00:00:00</EODDate><CLCode>PS4-00033961</CLCode><AGCode>GAD-63
  
4</AGCode><FDCode>RDPS4</FDCode><EndBalUnit>1.9999000000000</EndBalUnit><CheckList>3086</CheckList></Balance></Balance>'  
  ,@pnNIK = 32622  
  ,@pnBatchId = @nGuid output  
  ,@pbDebug = 1  
 select @nGuid  
  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20090610, oscar, REKSADN013, cek jam input 
  20140313, liliana, LIBST13021, pengecekan ketika eod 
 END REVISED  
*/  
 @pcFileName varchar(150),  
 @pdNAVDate datetime,  
 @pxXML  xml,  
 @pnNIK  int,  
 @pnBatchId uniqueidentifier output,  
 @pbDebug bit = 0  
as  
set nocount on  
  
declare   
 @nOK  tinyint,  
 @cErrMsg varchar(100),  
 @docHdl  int,  
 @nGuid  uniqueidentifier,  
 @nNumOfRecord int  
--20090610, oscar, REKSADN013, begin  
 , @dDateStart datetime  
 , @dDateEnd  datetime  
 , @dCurrent  datetime  
--20090610, oscar, REKSADN013, end   
--20140313, liliana, LIBST13021, begin  
 ,@dCurrDate  datetime  
 ,@dCurrWorkingDate datetime  
--20140313, liliana, LIBST13021, end  
  
/* tabel data xml */  
declare @xml table (  
 EODDate  datetime,  
 CLCode  varchar(40),  
 AGCode  varchar(20),  
 FDCode  varchar(20),  
 EndBalUnit float,  
 CheckList varchar(10)  
)  
  
set @nOK = 0  
select @nGuid = newid()  
  
--20090610, oscar, REKSADN013, begin  
-- cek jam input/upload  
select @dCurrent = convert(datetime, convert(varchar(8), getdate(), 108))   
select @dDateStart = convert(datetime, dbo.fnReksaGetParam('NAVULSTR'))  
select @dDateEnd = convert(datetime, dbo.fnReksaGetParam('NAVULEND'))  
  
if @dCurrent < @dDateStart or @dCurrent > @dDateEnd  
begin  
 set @cErrMsg = 'Waktu upload/sinkronisasi sudah diluar cut off time'  
 goto ERR_HANDLER  
end  
--20090610, oscar, REKSADN013, end  
--20140313, liliana, LIBST13021, begin  
select @dCurrDate = current_working_date  
from control_table  
  
select @dCurrWorkingDate = current_working_date  
from dbo.fnGetWorkingDate()  
  
if @dCurrDate < @dCurrWorkingDate  
begin            
  set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan mencoba kembali'            
  goto ERR_HANDLER            
end  
  
if @dCurrDate = @dCurrWorkingDate  
 and exists(select top 1 1 from dbo.process_table where stored_procedure_name = 'ReksaProcessEODEOM' and success_bit = 0)  
begin            
  set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan mencoba kembali'            
  goto ERR_HANDLER            
end  
--20140313, liliana, LIBST13021, end  
  
-- siapkan doc handler u/ data XML  
Exec @nOK = sp_xml_preparedocument @docHdl output, @pxXML  
if @nOK <> 0 or @@error <> 0  
begin  
 set @cErrMsg = 'Gagal sp_xml_preparedocument'   
 goto ERR_HANDLER  
end  
  
-- baca isi tabel  
insert into @xml (  
 EODDate, CLCode, AGCode, FDCode, EndBalUnit, CheckList  
)  
select EODDate, CLCode, AGCode, FDCode, EndBalUnit, CheckList  
from OpenXml(@docHdl, N'/Balance/Balance',2)   
with (  
 EODDate  datetime,  
 CLCode  varchar(40),  
 AGCode  varchar(20),  
 FDCode  varchar(20),  
 EndBalUnit float,  
 CheckList varchar(10)  
)  
  
-- debug  
if @pbDebug = 1 select * from @xml  
  
-- lakukan validasi  
exec @nOK = dbo.ReksaUpdateOSValidate @pdNAVDate, @pxXML, 0  
if @nOK <> 0 or @@error <> 0  
begin  
 set @cErrMsg = 'Gagal validasi data NAV'  
 goto ERR_HANDLER  
end  
  
-- cek jumlah data transaksi  
select @nNumOfRecord = count(*) from @xml where CLCode is not null  
if @nNumOfRecord = 0  
begin  
 set @cErrMsg = 'File ' + @pcFileName + ' tidak ada data'  
 goto ERR_HANDLER  
end  
  
-- proses   
begin tran  
  
-- catat di tabel log  
insert into ReksaOSUploadLog_TH (  
 BatchGuid, ClientCode, UnitBalanceBefore, UnitBalanceAfter, LastUpdate, LastUser  
)  
select @nGuid, rc.ClientCode, h.UnitBalance, x.EndBalUnit, getdate(), @pnNIK  
from @xml x   
join ReksaCIFData_TM rc  
 on replace(x.CLCode, '-', '') = rc.ClientCode  
join ReksaCIFDataHist_TM h  
 on rc.ClientId = h.ClientId  
 and h.TransactionDate = @pdNAVDate  
where x.EndBalUnit <> h.UnitBalance  
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal insert ke ReksaOSUploadLog_TH'  
 rollback tran  
 goto ERR_HANDLER  
end  
  
select @nNumOfRecord = count(*) from ReksaOSUploadLog_TH where BatchGuid = @nGuid  
  
-- debug  
if @pbDebug = 1  
 select * from ReksaOSUploadLog_TH where BatchGuid = @nGuid  
  
-- catat di tabel log proses  
insert into ReksaOSUploadProcessLog_TH (  
 BatchGuid, NAVValueDate, TransactionDate, FileName, NumOfRecord, Status,   
 LastUpdate, LastUser   
)  
select @nGuid, convert(datetime, convert(varchar(8), @pdNAVDate, 112)), getdate(), @pcFileName, @nNumOfRecord, 0, -- blm upload  
 getdate(), @pnNIK  
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal insert ke ReksaOSUploadProcessLog_TH'  
 rollback tran  
 goto ERR_HANDLER  
end  
  
-- debug  
if @pbDebug = 1  
 select * from ReksaOSUploadProcessLog_TH where BatchGuid = @nGuid  
  
----20090511, oscar, REKSADN013, begin  
----lgs otor  
--exec @nOK = ReksaUpdateOSApproval   
--  @pnGuid = @nGuid  
--  ,@pbAuth = 1  
--  ,@pnNIK = @pnNIK  
--  ,@pbDebug = 0  
--if @nOK <> 0 or @@error <> 0  
--begin  
-- set @cErrMsg = 'Gagal Approve data, batch ' + convert(varchar(50), @nGuid)  
-- rollback tran  
-- goto ERR_HANDLER  
--end  
----20090511, oscar, REKSADN013, end  
  
select @pnBatchId = @nGuid  
  
commit tran  
  
  
ERR_HANDLER:  
if isnull(@cErrMsg, '') <> ''  
begin  
 raiserror ( @cErrMsg  ,16,1)
 set @nOK = 1  
end  
  
exec sp_xml_removedocument @docHdl  
  
-- hasil upload  
select upper(BatchGuid) as SyncRefNo,   
 NAVValueDate,   
 FileName,   
 NumOfRecord as ProcessedRecords,  
 case Status   
  when 0 then 'UPLOADED'  
  when 1 then 'APPROVED'  
  when 2 then 'REJECTED'  
  when 3 then 'PROCESSED'  
 end as Status,  
 LastUser as 'UserId'  
from ReksaOSUploadProcessLog_TH  
where BatchGuid = @pnBatchId  
  
return @nOK
GO