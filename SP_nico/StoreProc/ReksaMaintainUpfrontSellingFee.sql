
CREATE PROC [dbo].[ReksaMaintainUpfrontSellingFee]
/*
	CREATED BY    : Liliana
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
@pvcXMLSettingGL				XML = null,
@pcProcessType					char(1),
@pcJenisFee						varchar(50),
@pdPercentageDefault			decimal(25,13)
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@dToday							datetime,
	@nGLId							int
	
if(@pcProcessType not in ('A','U','D'))
begin
	set @cErrMessage = 'Process Type salah!'
	goto ERROR
end	

if(@pcJenisFee not in ('UPFRONT','SELLING'))
begin
	set @cErrMessage = 'Jenis Trx salah!'
	goto ERROR
end

if not exists(select top 1 1 from dbo.ReksaProduct_TM where ProdId = @pnProdId)
begin
	set @cErrMessage = 'Product tidak ditemukan!'
	goto ERROR
end

if @pcJenisFee = 'UPFRONT' and exists(select top 1 1  from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 0)
begin
	set @cErrMessage = 'Upfront fee hanya untuk Product Close End!'
	goto ERROR
end

if @pcJenisFee = 'SELLING' and exists(select top 1 1  from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1)
begin
	set @cErrMessage = 'Selling fee hanya untuk Product Open End!'
	goto ERROR
end


if @pcProcessType = 'A' and exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @pcJenisFee and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter '+LOWER(@pcJenisFee)+' Fee utk Product tersebut sudah ada!'
	goto ERROR
end

if exists(select top 1 1 from dbo.ReksaParamFee_TT where TrxType = @pcJenisFee and StatusOtor = 0 and ProdId = @pnProdId)
begin
	set @cErrMessage = 'Setting Parameter '+LOWER(@pcJenisFee)+' Fee utk produk tersebut sedang menunggu proses otorisasi!'
	goto ERROR
end

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

begin try

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


if exists(select top 1 1 from #SettingGL)
begin
	select @nGLId = max(GLId)
	from dbo.ReksaListGLFee_TT

	if(@nGLId is null)
		set @nGLId = 1
	else
		set @nGLId = @nGLId + 1
end
		

insert dbo.ReksaListGLFee_TT (GLId, TrxType, ProdId, Sequence, 
	GLName, GLNumber, OfficeId, Percentage,
	ProcessType, DateInput, Inputter, StatusOtor
)
select @nGLId, @pcJenisFee, ProdId, Seq,
	NamaGL, NomorGL, OfficeId, Persentase,
	@pcProcessType, @dToday, @pnNIK, 0 
from #SettingGL

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting GL Fee!'    
	goto ERROR    
end  

insert dbo.ReksaParamFee_TT (TrxType, ProdId, GLId, PctSellingUpfrontDefault,
	ProcessType, DateInput,Inputter, StatusOtor
)
select @pcJenisFee, @pnProdId,@nGLId, @pdPercentageDefault,
	@pcProcessType, @dToday, @pnNIK, 0

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting Fee !'    
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

	--raiserror @nErrNo @cErrMessage
	raiserror (@cErrMessage, 16,1);
	return 1
GO