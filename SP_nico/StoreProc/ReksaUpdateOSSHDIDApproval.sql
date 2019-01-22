CREATE proc [dbo].[ReksaUpdateOSSHDIDApproval]  
/*  
 CREATED BY    : liliana
 CREATION DATE : 20150508  
 DESCRIPTION   : Proses approve/reject data XML upload sinkronisasi OS Unit Balance  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
	20150619, liliana, LIBST13020, validasi
 END REVISED  
*/  
 @pnGuid  uniqueidentifier,  
 @pbAuth  bit = 0,  
 @pnNIK  int,  
 @pbDebug bit = 0  
as  
set nocount on  
  
declare   
 @nOK  tinyint,  
 @cErrMsg varchar(100)  
 ,@dValueDate datetime  
 ,@dCustodyId    int   
 ,@dCurrDate  datetime  
 ,@dCurrWorkingDate datetime  
  
set @nOK = 0  
  
-- validasi parameter  
--20150619, liliana, LIBST13020, begin
--if not exists (select top 1 1 from ReksaOSUploadProcessLog_TH 
if not exists (select top 1 1 from ReksaOSSHDIDUploadProcessLog_TH   
--20150619, liliana, LIBST13020, end
 where BatchGuid = @pnGuid)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' tidak ditemukan'  
 goto ERR_HANDLER  
end  
 
select @dCurrDate = current_working_date  
from control_table  
  
select @dCurrWorkingDate = current_working_date  
from dbo.fnGetWorkingDate()  
  
-- yg sudah pernah ditolak  
--20150619, liliana, LIBST13020, begin
--if exists (select top 1 1 from ReksaOSUploadProcessLog_TH 
if exists (select top 1 1 from ReksaOSSHDIDUploadProcessLog_TH   
--20150619, liliana, LIBST13020, end
 where BatchGuid = @pnGuid and [Status] = 2)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah ditolak'  
 goto ERR_HANDLER  
end  
  
-- yg sudah pernah dijalankan  
--20150619, liliana, LIBST13020, begin
--if exists (select top 1 1 from ReksaOSUploadProcessLog_TH  
if exists (select top 1 1 from ReksaOSSHDIDUploadProcessLog_TH  
--20150619, liliana, LIBST13020, end
 where BatchGuid = @pnGuid and [Status] = 3)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah dijalankan'  
 goto ERR_HANDLER  
end  
  
-- update status 
update ReksaOSSHDIDUploadProcessLog_TH  
set [Status] = case @pbAuth  
     when 0 then 2   
     else 1   
    end, -- Status 1 = approved, 2 = reject  
 LastUpdate = getdate(),  
 Supervisor = @pnNIK  
where BatchGuid = @pnGuid  
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal otorisasi data upload, batch Guid = ' + convert(varchar(50), @pnGuid)  
 goto ERR_HANDLER  
end  
  
  
ERR_HANDLER:  
if isnull(@cErrMsg, '') <> ''  
begin  
 raiserror (@cErrMsg  ,16,1)
 set @nOK = 1  
end  
  
return @nOK
GO