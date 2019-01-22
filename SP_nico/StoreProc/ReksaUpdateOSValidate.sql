CREATE proc [dbo].[ReksaUpdateOSValidate]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20090508
	DESCRIPTION   : Validasi data XML upload sinkronisasi OS Unit Balance
	
	exec ReksaUpdateOSValidate 
		@pdNAVDate = '20090101'
		,@pxXML = '<Balance><Balance><EODDate>2009-01-01 00:00:00</EODDate><CLCode>DM3-00026476</CLCode><AGCode>SUM-014</AGCode><FDCode>RDDM3</FDCode><EndBalUnit>49579.999000000000000</EndBalUnit><CheckList>3165</CheckList></Balance><Balance><EODDate>2009-01-01 00:00:00</EODDate><CLCode>DM3-00026710</CLCode><AGCode>ASI-060</AGCode><FDCode>RDDM3</FDCode><EndBalUnit>4957.961000000000000</EndBalUnit><CheckList>3086</CheckList></Balance></Balance>'
		,@pbDebug = 1

	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20090610, oscar, REKSADN013, cek jam input
		20090713, oscar, REKSADN013, cek boleh upload data maks H-7
		20100319, oscar, REKSADN014, buat check-in
	END REVISED
*/
	@pdNAVDate	datetime,
	@pxXML		xml,
	@pbDebug	bit = 0
as
set nocount on
--20100319, oscar, REKSADN014, begin
--buat check in doang
--20100319, oscar, REKSADN014, end
declare 
	@nOK		tinyint,
	@cErrMsg	varchar(100),
	@docHdl		int,
	@nUploadBal	float,
	@nUnitBal	float
--20090610, oscar, REKSADN013, begin
	, @dDateStart	datetime
	, @dDateEnd		datetime
	, @dCurrent		datetime
--20090610, oscar, REKSADN013, end	
--20090713, oscar, REKSADN013, begin
	, @dCurrentWorkingDate	 datetime
	, @dMinDate		datetime
--20090713, oscar, REKSADN013, end

/* tabel data xml */
declare @xml table (
	EODDate		datetime,
	CLCode		varchar(40),
	AGCode		varchar(20),
	FDCode		varchar(20),
	EndBalUnit	float,
	CheckList	varchar(10)
)

set @nOK = 0
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
	EODDate		datetime,
	CLCode		varchar(40),
	AGCode		varchar(20),
	FDCode		varchar(20),
	EndBalUnit	float,
	CheckList	varchar(10)
)

-- debug
if @pbDebug = 1	select * from @xml

-- mulai validasi
-- 1. Cek parameter Tgl NAV vs Tgl EODDate pada file upload
if exists (select top 1 1 from @xml where EODDate <> convert(datetime, convert(varchar(8), @pdNAVDate, 112)))
begin
	set @cErrMsg = 'Tanggal EOD pada file tidak sesuai dengan tanggal NAV (' + convert(varchar(8), @pdNAVDate, 112) + ')'
	goto ERR_HANDLER
end

-- 2. cek waktu upload, hrs pada jam cut off
if (convert(varchar(8), getdate(), 8) < dbo.fnReksaGetParam('NAVULSTR') or 
	convert(varchar(8), getdate(), 8) > dbo.fnReksaGetParam('NAVULEND') )
begin
	set @cErrMsg = 'Hanya bisa upload data antara pkl ' + dbo.fnReksaGetParam('NAVULSTR') + ' dan ' + dbo.fnReksaGetParam('NAVULEND')
	goto ERR_HANDLER
end

---- 3. cek no nasabah apakah semua ada di ReksaCIFData_TM
--if exists (select top 1 rc.ClientCode, x.CLCode from ReksaCIFData_TM rc
--	right join @xml x
--	on rc.ClientCode = replace(x.CLCode, '-', '')
--	where rc.ClientCode is null)
--begin
--	set @cErrMsg = 'Ada kode Client yang tidak terdaftar di ProReksa'
--	goto ERR_HANDLER
--end

-- 4. Cek apakah tgl NAV > tgl data yg sudah pernah upload sblmnya
if exists (select top 1 1 from ReksaOSUploadProcessLog_TH 
	where NAVValueDate >= convert(datetime, convert(varchar(8), @pdNAVDate, 112)))
begin
	set @cErrMsg = 'Data tgl ' + convert(varchar(8), @pdNAVDate, 112) + ' bukan data terbaru'
	goto ERR_HANDLER
end

-- 5. cek end balance
select @nUploadBal = sum(EndBalUnit) from @xml
select @nUnitBal = sum(rc.UnitBalance)
from ReksaCIFData_TM rc
join @xml x
	on rc.ClientCode = replace(x.CLCode, '-', '')
	
--20090713, oscar, REKSADN013, begin
-- 6. cek tgl NAV, maks H-7
select @dCurrentWorkingDate = current_working_date from dbo.fnGetWorkingDate()
select @dMinDate = dbo.fnReksaGetEffectiveDate(convert(varchar(8), @dCurrentWorkingDate, 112), -7)
if @pdNAVDate < @dMinDate
begin
	set @cErrMsg = 'Data sinkronisasi O/S tidak bisa < H-7 (tgl ' + convert(varchar(10), @dMinDate, 105) + ')'
	goto ERR_HANDLER
end
--20090713, oscar, REKSADN013, end

-- debug
if @pbDebug = 1
	select @nUploadBal, @nUnitBal
	
if @nUploadBal = @nUnitBal
begin
	set @cErrMsg = 'Saldo akhir tidak ada perubahan, sinkronisasi tidak diperlukan'
	goto ERR_HANDLER
end

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	raiserror (@cErrMsg,16,1)
	set @nOK = 1
end

exec sp_xml_removedocument @docHdl

return @nOK
GO