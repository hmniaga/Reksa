
CREATE proc [dbo].[ReksaMaintainProdNAV]
/*
	CREATED BY    :
	CREATION DATE :
	DESCRIPTION   : Simpan data update NAV produk
	
	begin tran
	exec ReksaMaintainProdNAV 2, 1075.3232000000000, '2010-12-25', '2009-12-25', 0.0, 10005 
	rollback tran
	
	begin tran
	exec ReksaMaintainProdNAV 2, 1075.3232000000000, '2010-01-04', null, 0.0251812121, 10005 
	select * from ReksaNAVUpdate_TH
	rollback tran
	
	select * from ReksaNAVUpdate_TH
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
	@pnProdId		int,         
	--@pnNAV			decimal,
	@pnNAV			decimal(25, 13),
	@pdNAVValueDate	datetime,
	@pdDevidentDate	datetime,
	@pnDeviden		decimal(23, 15),	-- nominal pembagi deviden
	@pnNIK			int	,
	@pfHargaUnitPerHari						float
as
set nocount on

declare
	@nOK tinyint,
	@cErrMsg varchar(100),
	@dCurrent datetime
	, @nRefId int
	, @dMinDate datetime

set @nOK = 0	
select @dCurrent = current_working_date from dbo.fnGetWorkingDate()

-- validasi
if exists(select top 1 1 from ReksaHolidayTable_TM where ValueDate = @pdNAVValueDate)
				or DATEPART(dw, @pdNAVValueDate) in (1,7)
begin
	set @cErrMsg = 'Tidak boleh hari libur.'
	goto ERR_HANDLER
end

if @pdNAVValueDate >= @dCurrent
begin
	set @cErrMsg = 'Tgl valuta NAV harus < dari tgl hari ini'
	goto ERR_HANDLER
end     

select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) from dbo.fnGetWorkingDate()
--tgl NAV tidak bole < H-2
if @pdNAVValueDate < @dMinDate
begin
	set @cErrMsg = 'Tgl NAV < H-2 (' + convert(varchar(8), @dMinDate, 112) + ')'
	goto ERR_HANDLER
end
if @pdDevidentDate < @dMinDate 
	and (select IsDeviden from ReksaProduct_TM where ProdId = @pnProdId) = 1
begin
	set @cErrMsg = 'Tgl Deviden < H-2 (' + convert(varchar(8), @dMinDate, 112) + ')'
	goto ERR_HANDLER
end


if isnull(@pnNAV, 0) = 0 or isnull(@pdNAVValueDate, '') = ''
begin
	set @cErrMsg = 'NAV dan Tanggal Valuta harus diisi.'
	goto ERR_HANDLER
end

-- boleh dikosongin
if (select IsDeviden from ReksaProduct_TM where ProdId = @pnProdId) = 1
begin
	select @pdDevidentDate = isnull(@pdDevidentDate, '19000101'), 
		@pnDeviden = case when @pnDeviden = 0.0 then -1 else @pnDeviden end
end

if (select Status from ReksaProduct_TM where ProdId = @pnProdId) <> 1
begin
	set @cErrMsg = 'Product sudah tidak aktif.'
	goto ERR_HANDLER
end

insert into ReksaNAVUpdate_TH (
	ProdId, NAV, NAVValueDate, DevidentDate, DevidentAmount, LastUpdate, 
	LastUser, Status, HargaUnitPerHari)
select 
	@pnProdId, dbo.fnReksaSetRounding(@pnProdId, 1, @pnNAV), @pdNAVValueDate, @pdDevidentDate, @pnDeviden, getdate(), 
	@pnNIK, 0
	, @pfHargaUnitPerHari
	
if @@error <> 0
begin
	set @cErrMsg = 'Gagal insert ReksaNAVUpdate_TH'
	goto ERR_HANDLER
end

set @nRefId = @@identity
--update kolom OldNAV
update ReksaNAVUpdate_TH
set OldNAV = b.NAV
from ReksaNAVUpdate_TH a
join ReksaNAVParam_TH b
	on a.ProdId = b.ProdId
	and a.NAVValueDate = b.ValueDate
where a.RefId = @nRefId

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	set @nRefId = -1
	raiserror (@cErrMsg ,16,1);
	set @nOK = 1
end

--20091207, oscar, REKSADN014, begin
select @nRefId as 'RefId'
--20091207, oscar, REKSADN014, end   
--20100203, oscar, REKSADN014, end
return @nOK
GO