
CREATE proc [dbo].[ReksaParameterReportRDN07]
/*
	CREATED BY    : liliana
	CREATION DATE : 
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED

*/
@pnCustodyCode		varchar(20)
as

set nocount on

 select distinct rp.ProdName, rp.ProdId      
  from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)    
  join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
  join dbo.ReksaCustody_TR rc on rc.CustodyId = rp.CustodyId
  where rc.CustodyCode = @pnCustodyCode


return 0
GO