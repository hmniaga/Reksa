
CREATE proc [dbo].[ReksaPopulateVerifyCEBill]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20090609
	DESCRIPTION   : menampilkan list bill yang perlu di authorize (close end)
	
	exec ReksaPopulateVerifyCEBill 32622
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
@cNik								int

as

set nocount on

declare	@bCheck						bit,
		@cErrMsg					varchar(100),
		@nOK						tinyint,
		@dToday						datetime

set @bCheck = 0
set @nOK = 0

select @dToday = current_working_date from control_table

select @bCheck as 'CheckB', a.BillId, a.BillName, 
	(case a.DebitCredit when 'D' then 'Debit' when 'C' then 'Credit' end) as 'DebitCredit', 
	a.CreateDate, a.ValueDate, b.ProdCode, c.CustodyCode, a.BillCCY, convert(varchar(40),cast(a.TotalBill as money),1) as TotalBill
	, convert(varchar(40),cast(a.Fee as money),1) as Fee, convert(varchar(40),cast(a.FeeBased as money),1) as FeeBased
from dbo.ReksaBill_TM
	a, dbo.ReksaProduct_TM b, dbo.ReksaCustody_TR c
where a.CheckerSuid is null
--	and a.BillType in (1, 2, 3, 4, 5)
	and a.ValueDate <= @dToday
	and a.ProdId = b.ProdId
	and a.CustodyId = c.CustodyId
	and b.CloseEndBit = 1
	and b.Status = 1

ERROR:
if isnull(@cErrMsg, '') != '' 
begin
	set @nOK = 1
	raiserror (@cErrMsg ,16,1);
end

return @nOK
GO