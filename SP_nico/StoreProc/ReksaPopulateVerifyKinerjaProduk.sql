
CREATE proc [dbo].[ReksaPopulateVerifyKinerjaProduk]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20130404
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    

 END REVISED  
   
 exec dbo.ReksaPopulateVerifyKinerjaProduk null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  
  
select @bCheck as CheckB,
	rf.KinerjaId as Id, 
	case when rf.ProcessType = 'A' then 'Add'
		 when rf.ProcessType = 'U' then 'Update'
		 when rf.ProcessType = 'D' then 'Delete'
	else rf.ProcessType end as ActionType,
	rp.ProdCode as KodeProduk,
	rp.ProdName as NamaProduk,
	rp.ProdCCY as MataUang,
	rt.TypeName as TypeReksadana,
	rf.ValueDate as TanggalValuta,
	case when rf.IsVisible = 1 then 'Yes'
		 else 'No' end as TampilDiIBMB,
	convert(varchar(40),cast(rf.Sehari as money),1) as Sehari,
	convert(varchar(40),cast(rf.Seminggu as money),1) as Seminggu,
	convert(varchar(40),cast(rf.Sebulan as money),1) as Sebulan,
	convert(varchar(40),cast(rf.Setahun as money),1) as Setahun,
	rf.UserInput, 
	us.fullname as UserInputName,
	rf.DateInput
from dbo.ReksaKinerjaProduct_TT rf
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = rf.ProdId
	join dbo.ReksaType_TR rt
		on rt.TypeId = rp.TypeId
	join dbo.user_nisp_v us
		on us.nik = rf.UserInput
where rf.StatusOtor = 0

  
return 0
GO