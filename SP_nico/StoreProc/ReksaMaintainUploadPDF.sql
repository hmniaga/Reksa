
CREATE PROC [dbo].[ReksaMaintainUploadPDF]
/*
	CREATED BY    : Liliana
	CREATION DATE : 20130624
	DESCRIPTION   :
	REVISED BY    :
	
	DATE, USER, PROJECT, NOTE
	-----------------------------------------------------------------------	  

	END REVISED
	 
*/
@pnNIK							int,
@pcModule						varchar(20) = NULL,
@pnProdId						int,
@pcJenisKebutuhanPDF			varchar(100), 
@pcFilePath						varchar(200),
@pcProcessType					varchar(1)
AS 
	SET NOCOUNT ON
	DECLARE
	@cErrMessage					varchar(255),
	@nErrNo							int,
	@nOK							int,
	@dToday							datetime,
	@cProdName						varchar(200),
	@cFTPFileName					varchar(200)

set @dToday = getdate()

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

if @pcProcessType = 'A' and exists(select top 1 1 from dbo.ReksaUploadPDFIBMB_TM where ProdId = @pnProdId and TypePDF = @pcJenisKebutuhanPDF)
begin
	set @cErrMessage = 'Setting PDF '+ @pcJenisKebutuhanPDF +' utk Product tersebut sudah ada!'
	goto ERROR
end

if exists(select top 1 1 from dbo.ReksaUploadPDFIBMB_TT where StatusOtor = 0 and ProdId = @pnProdId and TypePDF = @pcJenisKebutuhanPDF)
begin
	set @cErrMessage = 'Setting PDF '+@pcJenisKebutuhanPDF +' utk produk tersebut sedang menunggu proses otorisasi!'
	goto ERROR
end

select @cProdName = ProdName
from dbo.ReksaProduct_TM
where ProdId = @pnProdId

if(@pcJenisKebutuhanPDF = 'Prospectus')
begin
	SET @cFTPFileName = 'PROSPECTUS_' + @cProdName
end
else
begin
	SET @cFTPFileName = 'FFS_' + @cProdName
end

select @cFTPFileName = replace(@cFTPFileName, ' ', '_');
set @cFTPFileName = @cFTPFileName + '.pdf'

insert dbo.ReksaUploadPDFIBMB_TT (ProdId, TypePDF, FilePath, ProcessType, DateInput, Inputter,
	FilePathDRIB,
	StatusOtor)
select @pnProdId, @pcJenisKebutuhanPDF, @pcFilePath, @pcProcessType, @dToday, @pnNIK, 
	@cFTPFileName,
	0

if @@error != 0 or @nOK != 0    
begin    
	set @cErrMessage = 'Gagal Insert Setting Upload PDF!'    
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

	raiserror (@cErrMessage, 16,1);
	return 1
GO