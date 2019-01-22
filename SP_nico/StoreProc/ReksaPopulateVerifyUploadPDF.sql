
CREATE proc [dbo].[ReksaPopulateVerifyUploadPDF]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20130624
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    

 END REVISED  
   
 exec dbo.ReksaPopulateVerifyUploadPDF null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  
  
select @bCheck as CheckB,
	rf.Id, 
	case when rf.ProcessType = 'A' then 'Add'
		 when rf.ProcessType = 'U' then 'Update'
		 when rf.ProcessType = 'D' then 'Delete'
	else rf.ProcessType end as ActionType,
	rp.ProdCode as KodeProduk,
	rp.ProdName as NamaProduk,
	rf.TypePDF as JenisKebutuhanPDF,
	rf.FilePath as FilePath,
	rf.FilePathDRIB as PDFFileName,
	rf.Inputter, 
	us.fullname as UserInputName,
	rf.DateInput
from dbo.ReksaUploadPDFIBMB_TT rf
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = rf.ProdId
	join dbo.ReksaType_TR rt
		on rt.TypeId = rp.TypeId
	join dbo.user_nisp_v us
		on us.nik = rf.Inputter
where rf.StatusOtor = 0

  
return 0
GO