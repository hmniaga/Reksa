CREATE proc [dbo].[ReksaPindahOffice]
/*
	CREATED BY    : liliana
	CREATION DATE : 20121127
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED

*/
@pcOfficeAsal				varchar(5),
@pcOfficeTujuan				varchar(5),
@pnNIK						int
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)

if exists(select top 1 1 from dbo.ReksaPindahOffice_TT where OfficeAsal = @pcOfficeAsal AND StatusOtor = 0)
begin
	set @cErrMsg = 'Office asal '+@pcOfficeAsal+' sedang dalam proses otorisasi!'
	GOTO ERROR
end

if exists(select top 1 1 from dbo.ReksaPindahOffice_TT where OfficeAsal = @pcOfficeAsal and OfficeTujuan = @pcOfficeTujuan and StatusOtor = 0)
begin
	set @cErrMsg = 'Office asal '+@pcOfficeAsal+' dan office tujuan '+@pcOfficeTujuan+' sedang dalam proses otorisasi!'
	GOTO ERROR
end

insert dbo.ReksaPindahOffice_TT (OfficeAsal, OfficeTujuan, UserInput, DatetimeInput, StatusOtor)
select @pcOfficeAsal, @pcOfficeTujuan, @pnNIK, getdate(), 0
	

return 0

ERROR:  
If @@trancount > 0   
 rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Unknown Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1);
return 1
GO