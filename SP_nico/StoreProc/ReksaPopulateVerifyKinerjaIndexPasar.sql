
create proc [dbo].[ReksaPopulateVerifyKinerjaIndexPasar]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20180804
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    

 END REVISED  
   
 exec dbo.ReksaPopulateVerifyKinerjaIndexPasar null  
 
*/  
@pnNik        int,
@pcMode		 int = 0, -- 0 = master ; 1 = detail
@pnId		 int = 0 -- diisi utk detail  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  

if @pcMode = 0
begin
	  
	select @bCheck as CheckB,
		rf.Id as Id, 
		rf.NamaFileUpload,
		rf.TglUpload,
		rf.NIKUpload, 
		us.fullname as UserUploadName
	from dbo.ReksaKinerjaIndeksPasarMasterUpload_TH rf
		join dbo.user_nisp_v us
			on us.nik = rf.NIKUpload
	where rf.StatusOtor = 0

end
else if @pcMode = 1
begin
	select Id, Period, NamaIndeks, Rate 
	from dbo.ReksaKinerjaIndeksPasarDetailUpload_TH
	where Id = @pnId
end
  
return 0
GO