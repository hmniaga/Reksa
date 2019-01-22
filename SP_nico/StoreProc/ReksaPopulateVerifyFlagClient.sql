
CREATE proc [dbo].[ReksaPopulateVerifyFlagClient]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20120426  
 DESCRIPTION   : menampilkan list clientcode yang akan di flag yg akan di otor
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20120626, liliana, BAALN12010, tambah kolom
  20120626, liliana, BAALN12010, nambah kolom lagi
  20120626, liliana, BAALN12010, ngubah urutan kolom???
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyFlagClient null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  
  
--20120626, liliana, BAALN12010, begin
--select @bCheck as CheckB, Id, ClientId, 
--case when Flag = 0 then 'No'
--	 when Flag = 1 then 'Yes'
--end as Flag, 
--UserInput, DatetimeInput
--from dbo.ReksaFlagClientId_TT
--where StatusOtor = 0
select @bCheck as CheckB,
	rf.Id, rf.ClientId, 
--20120626, liliana, BAALN12010, begin
	rc.CIFNo,
	rc.ShareholderID,
--20120626, liliana, BAALN12010, end	
	rc.ClientCode,
--20120626, liliana, BAALN12010, begin
--20120626, liliana, BAALN12010, begin
	--rc.CIFNo,
	--rc.ShareholderID,
--20120626, liliana, BAALN12010, end
--20120626, liliana, BAALN12010, end	
	rc.CIFName,
	rc.UnitBalance,
	ra.AgentCode,
	ra.AgentDesc,
	case when rf.Flag = 0 then 'No'
		 when rf.Flag = 1 then 'Yes'
	end as Flag, 
	rf.UserInput, 
	us.fullname as UserInputName,
	rf.DatetimeInput
from dbo.ReksaFlagClientId_TT rf
	join dbo.ReksaCIFData_TM rc
		on rf.ClientId = rc.ClientId
	join dbo.ReksaAgent_TR ra
		on rc.AgentId = ra.AgentId
	join dbo.user_nisp_v us
		on us.nik = rf.UserInput
where rf.StatusOtor = 0
--20120626, liliana, BAALN12010, end
  
return 0
GO