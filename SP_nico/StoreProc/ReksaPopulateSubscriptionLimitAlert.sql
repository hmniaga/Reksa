
CREATE proc [dbo].[ReksaPopulateSubscriptionLimitAlert]
/*
	CREATED BY    : victor
	CREATION DATE : 
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
	
	exec dbo.ReksaPopulateSubscriptionLimitAlert null, null, null
*/
@pnNIK									int,
@pcModule								varchar(25),
@pcErrMsg								varchar(100)	output

as

set nocount on 

select ProdName								as ProductName, 
	ProdCCY									as Currency,
	SubcWarningLimit						as Limit
from dbo.ReksaProduct_TM
where SubcWarningLimit is not null

return 0
GO