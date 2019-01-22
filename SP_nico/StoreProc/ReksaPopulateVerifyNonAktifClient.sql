
CREATE proc [dbo].[ReksaPopulateVerifyNonAktifClient]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20120426  
 DESCRIPTION   : menampilkan list clientcode yang akan di nonaktifkan yg akan di otor
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20120626, liliana, BAALN12010, tambah kolom
  20120626, liliana, BAALN12010, ngubah urutan kolom ???
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyNonAktifClient null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  
  

--20120626, liliana, BAALN12010, begin  
--select @bCheck as CheckB, Id, ClientId, Outstanding, UserInput, DatetimeInput
--from dbo.ReksaNonAktifClientId_TT
--where StatusOtor = 0
select @bCheck as CheckB, 
	rn.Id, rn.ClientId, 
--20120626, liliana, BAALN12010, begin
	rc.CIFNo,
	rc.ShareholderID,	
--20120626, liliana, BAALN12010, end	
	rc.ClientCode,
--20120626, liliana, BAALN12010, begin
	--rc.CIFNo,
	--rc.ShareholderID,	
--20120626, liliana, BAALN12010, end	
	rc.CIFName,
	rc.UnitBalance,
	ra.AgentCode,
	ra.AgentDesc,
	rn.UserInput, 
	us.fullname as UserInputName,
	rn.DatetimeInput
from dbo.ReksaNonAktifClientId_TT rn
	join dbo.ReksaCIFData_TM rc
		on rn.ClientId = rc.ClientId
	join dbo.ReksaAgent_TR ra
		on rc.AgentId = ra.AgentId
	join dbo.user_nisp_v us
		on us.nik = rn.UserInput
where rn.StatusOtor = 0
--20120626, liliana, BAALN12010, end
  
return 0
GO