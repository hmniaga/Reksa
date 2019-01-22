CREATE proc [dbo].[ReksaUpdateMFeeApproval]
/*
	CREATED BY    : Liliana
	CREATION DATE : 
	DESCRIPTION   : Proses approve/reject data XML upload sinkronisasi Maintenance Fee
	
	ReksaMFeeUploadProcessLog_TH, Status 
		0 = baru upload
		1 = approved
		2 = rejected
		3 = processed

	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120831, liliana, BAALN11003, ketika otor langsung efektif.
		20121008, liliana, BAALN11003, tambah pengecekan EOD
	END REVISED
*/
	@pnRefId	int,
	@pbAuth		bit = 0,
	@pnNIK		int
as
set nocount on

declare 
	@nOK		tinyint,
	@cErrMsg	varchar(100)
--20120831, liliana, BAALN11003, begin
	,@uGuid		uniqueidentifier
--20120831, liliana, BAALN11003, end

set @nOK = 0

-- validasi parameter
if not exists (select top 1 1 from ReksaMFeeUploadProcessLog_TH
	where RefId = @pnRefId)
begin
	set @cErrMsg = 'Ref Id ' + convert(varchar(50), @pnRefId) + ' tidak ditemukan'
	goto ERR_HANDLER
end
--20121008, liliana, BAALN11003, begin
--cek apakah sedang EOD atau tidak
if exists(select top 1 1 from dbo.control_table where end_of_day = 1 and begin_of_day = 0)          
begin          
 set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'          
 goto ERR_HANDLER          
end
--20121008, liliana, BAALN11003, end

-- yg sudah pernah ditolak
if exists (select top 1 1 from ReksaMFeeUploadProcessLog_TH
	where RefId = @pnRefId and [Status] = 2)
begin
	set @cErrMsg = 'Ref Id ' + convert(varchar(50), @pnRefId) + ' sudah pernah ditolak'
	goto ERR_HANDLER
end

-- yg sudah pernah dijalankan
if exists (select top 1 1 from ReksaMFeeUploadProcessLog_TH
	where RefId = @pnRefId and [Status] = 3)
begin
	set @cErrMsg = 'Ref Id ' + convert(varchar(50), @pnRefId) + ' sudah pernah dijalankan'
	goto ERR_HANDLER
end


-- update status
begin tran

update ReksaMFeeUploadProcessLog_TH
set [Status] = case @pbAuth
					when 0 then 2 
					else 1 
				end, -- Status 1 = approved, 2 = reject
	LastUpdate = getdate(),
	Supervisor = @pnNIK
where RefId = @pnRefId

if @@error <> 0
begin
	set @cErrMsg = 'Gagal otorisasi data upload, Ref ID = ' + convert(varchar(50), @pnRefId)
	rollback tran
	goto ERR_HANDLER
end
--20120831, liliana, BAALN11003, begin
if @pbAuth = 1 -- accept
begin
	select @uGuid = BatchGuid 
	from dbo.ReksaMFeeUploadProcessLog_TH
	where RefId = @pnRefId
	
	exec @nOK = ReksaUpdateMFeeProcess @uGuid
	if @nOK <> 0 or @@error <> 0
	begin
		set @cErrMsg = 'Gagal proses perhitungan ulang hasil sinkronisasi maintenance fee!'
		rollback tran
		goto ERR_HANDLER
	end
end
--20120831, liliana, BAALN11003, end

commit tran

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	raiserror (@cErrMsg,16,1)
	set @nOK = 1
end

return @nOK
GO