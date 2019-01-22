
CREATE PROC [dbo].[ReksaMaintainSubsFee]
/*
	CREATED BY    : 
	CREATION DATE : 20121022
	DESCRIPTION   :
	REVISED BY    :
	
	DATE, USER, PROJECT, NOTE
	-----------------------------------------------------------------------	  

	END REVISED
	 
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
@pcProcessType					char(1)
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@dToday							datetime,
	@nGLId							int,
	@nTieringId						int

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

if @pcProcessType = 'A' and exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = 'SUBS' and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter Subs utk Product tersebut sudah ada!'
	goto ERROR
end

if exists(select top 1 1 from dbo.ReksaParamFee_TT where TrxType = 'SUBS' and StatusOtor = 0 and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter Subs utk produk tersebut sedang menunggu proses otorisasi!'
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
		
insert dbo.ReksaTieringNotification_TT (TieringId, TrxType, ProdId, PercentFrom, PercentTo,
	MustApproveBy, ProcessType, DateInput, Inputter, StatusOtor
)
select @nTieringId, 'SUBS', ProdId, PercentFrom, PercentTo,
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
select @nGLId, 'SUBS', ProdId, Seq,
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
	TieringId, GLId,
	ProcessType, DateInput,Inputter, StatusOtor
)
select 'SUBS', @pnProdId, @pnMinPctFeeEmployee, 
	@pnMaxPctFeeEmployee, @pnMinPctFeeNonEmployee, @pnMaxPctFeeNonEmployee, 
	@nTieringId, @nGLId,
	@pcProcessType, @dToday, @pnNIK, 0

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting Fee Subs!'    
	goto ERROR    
end 
          
RETURN 0

ERROR:
----------------------------------------------------------------------		
	if @@trancount > 0
		rollback tran
					
	if @cErrMessage is null 	
		set @cErrMessage = 'Error tidak diketahui pada procedure !'
	
	exec @nOK = dbo.set_raiserror @@procid, @nErrNo output
	if @nOK <> 0 or @@error <> 0 
		return 1

	raiserror ( @cErrMessage, 16,1);
	return 1
GO