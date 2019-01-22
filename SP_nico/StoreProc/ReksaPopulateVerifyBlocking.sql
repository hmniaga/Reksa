
CREATE proc [dbo].[ReksaPopulateVerifyBlocking]
/*
	CREATED BY    : victor
	CREATION DATE : 20071031
	DESCRIPTION   : menampilkan list account blocking yang perlu di authorize
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071128, victor, REKSADN002, tambah filter cabang
		20071204, victor, REKSADN002, tambah select BlockDate, BlockExpiry, BlockAmount, BlockDesc

	END REVISED
		
	select * from dbo.ReksaBlocking_TM
	select * from dbo.ReksaCIFData_TM
	select * from dbo.ReksaProduct_TM
	select * from dbo.ReksaAgent_TR

	exec dbo.ReksaPopulateVerifyBlocking null
*/
@cNik								int

as

set nocount on

declare	@bCheck						bit
--20071128, victor, REKSADN002, begin
	,@cOfficeId						varchar(5)

select @cOfficeId = office_id_sibs
from dbo.user_nisp_v
where nik = @cNik
--20071128, victor, REKSADN002, end
set @bCheck = 0

select @bCheck as 'CheckB', a.BlockId, (case a.AuthType when 1 then 'Block' when 3 then 'UnBlock' end) as Action, 
--20071204, victor, REKSADN002, begin
	a.BlockDate, a.BlockExpiry, a.BlockAmount, a.BlockDesc,
--20071204, victor, REKSADN002, end
	b.CIFNo, b.CIFName,	c.ProdCode, d.AgentCode
from dbo.ReksaBlocking_TM a, dbo.ReksaCIFData_TM b, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d
--20071128, victor, REKSADN002, begin
	, dbo.user_nisp_v e
--20071128, victor, REKSADN002, end
where a.ClientId = b.ClientId
	and b.ProdId = c.ProdId
	and b.AgentId = d.AgentId
	and a.CheckerSuid is null
--20071128, victor, REKSADN002, begin
	and a.UserSuid = e.nik
	and e.office_id_sibs = @cOfficeId
--20071128, victor, REKSADN002, end
return 0
GO