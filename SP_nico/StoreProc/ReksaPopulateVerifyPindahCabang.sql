
CREATE proc [dbo].[ReksaPopulateVerifyPindahCabang]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20121120  
 DESCRIPTION   : menampilkan list office id yg akan dipindahkan cabangnya
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyPindahCabang null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  

create table #ReksaPindahOffice_TT (
	CheckB				bit,
	Id					int,
	OfficeAsal			varchar(5),
	OfficeAsalDesc		varchar(100),
	OfficeTujuan		varchar(5),
	OfficeTujuanDesc	varchar(100),
	UserInput			int,
	UserInputName		varchar(100),
	DatetimeInput		datetime
)  

insert #ReksaPindahOffice_TT (CheckB, Id, OfficeAsal, OfficeTujuan, UserInput, UserInputName, DatetimeInput)
select @bCheck as CheckB, 
	rn.Id, 
	rn.OfficeAsal, 
	rn.OfficeTujuan,
	rn.UserInput, 
	us.fullname as UserInputName,
	rn.DatetimeInput
from dbo.ReksaPindahOffice_TT rn
	join dbo.user_nisp_v us
		on us.nik = rn.UserInput
where rn.StatusOtor = 0

update tt
set OfficeAsalDesc = ra.AgentDesc
from #ReksaPindahOffice_TT tt
join dbo.ReksaAgent_TR ra
on ra.OfficeId = tt.OfficeAsal

update tt
set OfficeTujuanDesc = ra.AgentDesc
from #ReksaPindahOffice_TT tt
join dbo.ReksaAgent_TR ra
on ra.OfficeId = tt.OfficeTujuan


select CheckB, Id, OfficeAsal, OfficeAsalDesc, 
	OfficeTujuan, OfficeTujuanDesc, UserInput, UserInputName, DatetimeInput
from #ReksaPindahOffice_TT

drop table #ReksaPindahOffice_TT
  
return 0
GO