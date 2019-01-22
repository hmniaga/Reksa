CREATE PROC [dbo].[ReksaMaintainRedempFee]
/*
	CREATED BY    : 
	CREATION DATE : 
	DESCRIPTION   :
	REVISED BY    :
	
	DATE, USER, PROJECT, NOTE
	-----------------------------------------------------------------------	  

	END REVISED
	
	exec ReksaMaintainRedempFee 10020,'Pro Reksa 2',4,3,3,2,2,'<DocumentElement />','<DocumentElement>
  <SettingGL>
    <Seq>1</Seq>
    <NamaGL>PENDAPATAN</NamaGL>
    <NomorGL>13212321</NomorGL>
    <Persentase>90</Persentase>
  </SettingGL>
  <SettingGL>
    <Seq>2</Seq>
    <NamaGL>PAJAK</NamaGL>
    <NomorGL>23423424</NomorGL>
    <Persentase>10</Persentase>
  </SettingGL>
  <SettingGL>
    <Seq>3</Seq>
    <NamaGL />
    <NomorGL />
    <Persentase>0</Persentase>
  </SettingGL>
  <SettingGL>
    <Seq>4</Seq>
    <NamaGL />
    <NomorGL />
    <Persentase>0</Persentase>
  </SettingGL>
  <SettingGL>
    <Seq>5</Seq>
    <NamaGL />
    <NomorGL />
    <Persentase>0</Persentase>
  </SettingGL>
</DocumentElement>','A',0,24,0,'<DocumentElement>
  <RedemPeriod>
    <Status>Karyawan</Status>
    <Period>1</Period>
    <PercentageFee>3</PercentageFee>
  </RedemPeriod>
  <RedemPeriod>
    <Status>Non Karyawan</Status>
    <Period>1</Period>
    <PercentageFee>4</PercentageFee>
  </RedemPeriod>
</DocumentElement>'

*/
@pnNIK							int,
@pcModule						varchar(20) = NULL,
@pnProdId						int,
@pnMinPctFeeEmployee			decimal(25,13) = null,
@pnMaxPctFeeEmployee			decimal(25,13) = null,
@pnMinPctFeeNonEmployee			decimal(25,13) = null,
@pnMaxPctFeeNonEmployee			decimal(25,13) = null,
@pvcXMLTieringNotif				XML = null,
@pvcXMLSettingGL				XML = null,
@pcProcessType					char(1),
@pbIsFlat						bit,
@pnNonFlatPeriod				int, 
@pbRedempIncFee					bit,
@pvcXMLTieringPctRedemp			XML = null
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@dToday							datetime,
	@nGLId							int,
	@nTieringId						int,
	@nPeriodId						int

if(@pcProcessType not in ('A','U','D'))
begin
	set @cErrMessage = 'Process Type salah!'
	goto ERROR
end	

if not exists(select top 1 1 from dbo.ReksaProduct_TM where ProdId = @pnProdId)
begin
	set @cErrMessage = 'Product tidak ditemukan!'
	goto ERROR
end

if @pcProcessType = 'A' and exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = 'REDEMP' and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter Redemp utk Product tersebut sudah ada!'
	goto ERROR
end

if exists(select top 1 1 from dbo.ReksaParamFee_TT where TrxType = 'REDEMP' and StatusOtor = 0 and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter Redemp utk produk tersebut sedang menunggu proses otorisasi!'
	goto ERROR
end

CREATE TABLE #TieringNotif(
ProdId				int,
PercentFrom			decimal(25,13),
PercentTo			decimal(25,13),
Persetujuan			varchar(100)
)

CREATE TABLE #SettingGL(
ProdId				int,
Seq					int,
NamaGL				varchar(50),
NomorGL				varchar(8),
OfficeId			varchar(5),
Persentase			decimal(25,13)
)	

create table #RedemPeriod (
ProdId				int,
StatusKaryawan		varchar(50),
IsEmployee			bit,
Period				int,
Fee					decimal(25,13)
)
	
set @dToday = getdate()
set @nGLId	= null
set @nTieringId	= null
	
begin try

	insert into #TieringNotif
	select 	distinct @pnProdId as ProdId,
		Item.Loc.value('(PercentFrom/text())[1]', 'decimal(25,13)') as 'PercentFrom', 
		Item.Loc.value('(PercentTo/text())[1]', 'decimal(25,13)') as 'PercentTo', 
		Item.Loc.value('(Persetujuan/text())[1]', 'varchar(100)') as 'Persetujuan'
	from @pvcXMLTieringNotif.nodes('/DocumentElement/TieringNotif') as Item(Loc)

	insert into #SettingGL
	select 	distinct @pnProdId as ProdId,
		Item.Loc.value('(Seq/text())[1]', 'int') as 'Seq', 
		Item.Loc.value('(NamaGL/text())[1]', 'varchar(50)') as 'NamaGL', 
		Item.Loc.value('(NomorGL/text())[1]', 'varchar(8)') as 'NomorGL', 
		Item.Loc.value('(OfficeId/text())[1]', 'varchar(5)') as 'OfficeId', 
		Item.Loc.value('(Persentase/text())[1]', 'decimal(25,13)') as 'Persentase'
	from @pvcXMLSettingGL.nodes('/DocumentElement/SettingGL') as Item(Loc)	
	
	insert into #RedemPeriod
	select distinct @pnProdId as ProdId,
		Item.Loc.value('(Status/text())[1]', 'varchar(50)') as 'StatusKaryawan', 
		null,
		Item.Loc.value('(Period/text())[1]', 'int') as 'Period', 
		Item.Loc.value('(PercentageFee/text())[1]', 'decimal(25,13)') as 'Fee'
	from @pvcXMLTieringPctRedemp.nodes('/DocumentElement/RedemPeriod') as Item(Loc)	

end try
begin catch
	select @cErrMessage=ERROR_MESSAGE()
	goto ERROR
end catch


if exists(select top 1 1 from #TieringNotif)
begin
	select @nTieringId = max(TieringId)
	from dbo.ReksaTieringNotification_TT
	
	if(@nTieringId is null)
		set @nTieringId = 1
	else
		set @nTieringId = @nTieringId + 1
end

if exists(select top 1 1 from #SettingGL)
begin
	select @nGLId = max(GLId)
	from dbo.ReksaListGLFee_TT

	if(@nGLId is null)
		set @nGLId = 1
	else
		set @nGLId = @nGLId + 1
end

if exists(select top 1 1 from #RedemPeriod)
begin
	select @nPeriodId = max(PeriodId)
	from dbo.ReksaRedemPeriod_TT

	if(@nPeriodId is null)
		set @nPeriodId = 1
	else
		set @nPeriodId = @nPeriodId + 1
end


--mulai insert table

update #RedemPeriod
set IsEmployee = 1
where StatusKaryawan = 'Karyawan'

update #RedemPeriod
set IsEmployee = 0
where StatusKaryawan = 'Non Karyawan'

insert dbo.ReksaRedemPeriod_TT (PeriodId, IsEmployee,
	Fee	, Period, Nominal,
	ProcessType, DateInput, Inputter, StatusOtor
)
select @nPeriodId, IsEmployee,
	Fee	, Period, 0,
	@pcProcessType, @dToday, @pnNIK, 0 
from #RedemPeriod

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Redemp Period!'    
	goto ERROR    
end 
		
insert dbo.ReksaTieringNotification_TT (TieringId, TrxType, ProdId, PercentFrom, PercentTo,
	MustApproveBy, ProcessType, DateInput, Inputter, StatusOtor
)
select @nTieringId, 'REDEMP', ProdId, PercentFrom, PercentTo,
	Persetujuan, @pcProcessType, @dToday, @pnNIK, 0 
from #TieringNotif

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Tiering Notification!'    
	goto ERROR    
end  

insert dbo.ReksaListGLFee_TT (GLId, TrxType, ProdId, Sequence, 
	GLName, GLNumber, OfficeId, Percentage,
	ProcessType, DateInput, Inputter, StatusOtor
)
select @nGLId, 'REDEMP', ProdId, Seq,
	NamaGL, NomorGL, OfficeId, Persentase,
	@pcProcessType, @dToday, @pnNIK, 0 
from #SettingGL

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting GL Fee!'    
	goto ERROR    
end  

insert dbo.ReksaParamFee_TT (TrxType, ProdId, MinPctFeeEmployee,
	MaxPctFeeEmployee, MinPctFeeNonEmployee, MaxPctFeeNonEmployee, 
	TieringId, GLId, PeriodId,
	IsFlat, NonFlatPeriod, RedempIncFee,
	ProcessType, DateInput,Inputter, StatusOtor
)
select 'REDEMP', @pnProdId, @pnMinPctFeeEmployee, 
	@pnMaxPctFeeEmployee, @pnMinPctFeeNonEmployee, @pnMaxPctFeeNonEmployee, 
	@nTieringId, @nGLId, @nPeriodId,
	@pbIsFlat, @pnNonFlatPeriod, @pbRedempIncFee,
	@pcProcessType, @dToday, @pnNIK, 0

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting Fee Redemp!'    
	goto ERROR    
end 
          
RETURN 0

ERROR:
----------------------------------------------------------------------		
	if @@trancount > 0
		rollback tran
					
	if @cErrMessage is null 	
		set @cErrMessage = 'Error tidak diketahui pada procedure !'
	
	--exec @nOK = dbo.set_raiserror @@procid, @nErrNo output
	--if @nOK <> 0 or @@error <> 0 
	--	return 1

	raiserror (@cErrMessage ,16,1);
	return 1
GO