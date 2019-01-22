alter proc [dbo].[ReksaMaintainPencadangan]
/*
	CREATED BY    : 
	CREATION DATE : 
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED

*/
@pnTipeReverse			varchar(20), --REVERSE / JURNAL
@pcProdCode				varchar(20),
@pdTanggalStart			datetime,
@pdTanggalEnd			datetime,
@pnInputter				int
as
set nocount on
declare
	@nOK tinyint
	,@cErrMsg varchar(355)
	,@nErrNo			int
	,@dStartPencadangan	datetime
	,@dEndPencadangan	datetime
    ,@dTempDate			datetime
    ,@dToday			datetime
	
	set @nOK = 0	
	
	select @dStartPencadangan = CurrentStartDate, @dEndPencadangan = CurrentEndDate
	from dbo.ReksaLastPencadangan_TM
	
	if(@pcProdCode = '')
	begin
		set @cErrMsg = 'Produk harus dipilih!'
		goto ERR_HANDLER
	end
	
	if not exists(select top 1 1 from dbo.ReksaProduct_TM where ProdCode = @pcProdCode)
	begin
		set @cErrMsg = 'Kode Produk salah!'
		goto ERR_HANDLER
	end
	
	if exists(select top 1 1 from dbo.ReksaReversePencadangan_TT where TipeReverse = @pnTipeReverse 
		and ProdCode = @pcProdCode and TanggalStart = @pdTanggalStart and TanggalEnd = @pdTanggalEnd and StatusOtor = 0)
	begin
		set @cErrMsg = 'Produk dan period tersebut sudah pernah diproses, sedang menunggu otorisasi.'
		goto ERR_HANDLER
	end

	if not exists(select top 1 1 from dbo.ReksaPencadangan_TM where StartDatePerhitungan = @pdTanggalStart and EndDatePerhitungan = @pdTanggalEnd
					and ProdCode = @pcProdCode)
	begin
		set @cErrMsg = 'Pencadangan untuk tanggal '+ convert(varchar,@pdTanggalStart,112) + ' - '+  convert(varchar,@pdTanggalEnd,112)  +' belum terbentuk tidak dapat direvisi.'
		goto ERR_HANDLER
	end
		
	set @dToday = convert(varchar,getdate(),112)
	
	select @dTempDate = @dToday
	select @dTempDate = dateadd(mm, 1, @dTempDate)
	select @dTempDate = dateadd(dd, -day(@dTempDate), @dTempDate)
	
	while (@dTempDate in (select ValueDate from dbo.ReksaHolidayTable_TM) 
	or datepart (dw, @dTempDate) in (1,7))
	begin
		set @dTempDate = dateadd(dd, -1, @dTempDate) 
	end
	
	--jika hari ini bukan tanggal akhir bulan, menu ini tidak bisa digunakan utk revisi
	if (@dTempDate != @dToday)
	begin
		set @cErrMsg = 'Menu ini hanya dapat digunakan pada tgl akhir bulan.'
		goto ERR_HANDLER
	end

	
    insert dbo.ReksaReversePencadangan_TT (TipeReverse, ProdCode, TanggalStart, TanggalEnd, Inputter, InputDate, StatusOtor)
	select @pnTipeReverse, @pcProdCode, @pdTanggalStart, @pdTanggalEnd, @pnInputter, getdate(), 0
	
 
return 0

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	if @@trancount>0 rollback tran  

	exec @nOK = set_raiserror @@procid, @nErrNo output  
	if @nOK<>0 or @@error<>0 return 1  

	raiserror ( @cErrMsg ,16,1);
	set @nOK = 1
end

return @nOK
GO