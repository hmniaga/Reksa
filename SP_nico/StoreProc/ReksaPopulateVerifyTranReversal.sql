
CREATE proc [dbo].[ReksaPopulateVerifyTranReversal]
/*
	CREATED BY    : victor
	CREATION DATE : 20071112
	DESCRIPTION   : menampilkan list transaksi reversal yang dapat di authorize
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071126, victor, REKSADN002, perbaiki filter 'di hari yang sama'
		20071126, victor, REKSADN002, masih sama
		20071128, victor, REKSADN002, tambah filter cabang
		20071210, indra_w, REKSADN002, tambah tran unit di selectan
		20080402, indra_w, REKSADN002, perbaikan

	END REVISED
	
	exec dbo.ReksaPopulateVerifyTranReversal null
*/
@cNik								int

as

set nocount on

declare	@bCheck						bit,
		@dCurrWorkingDate			datetime
--20071126, victor, REKSADN002, begin
		,
		@dToday						datetime
--20071126, victor, REKSADN002, end
--20071128, victor, REKSADN002, begin
		,@cOfficeId						varchar(5)

select @cOfficeId = office_id_sibs
from dbo.user_nisp_v
where nik = @cNik
--20071128, victor, REKSADN002, end

set @bCheck = 0

select @dCurrWorkingDate = current_working_date
from dbo.control_table

--20071126, victor, REKSADN002, begin
set @dToday = @dCurrWorkingDate
--20071126, victor, REKSADN002, end

set @dCurrWorkingDate = dateadd(second, -1, (dateadd (day, 1, @dCurrWorkingDate)))

--20071210, indra_w, REKSADN002, begin
select @bCheck as 'CheckB', a.TranId, b.ClientCode, c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY, a.TranAmt, a.TranUnit
--20071210, indra_w, REKSADN002, end
from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d,
	dbo.ReksaTransType_TR e
--20071128, victor, REKSADN002, begin
	, dbo.user_nisp_v f
--20071128, victor, REKSADN002, end
where a.ClientId = b.ClientId
	and a.ProdId = c.ProdId
	and a.AgentId = d.AgentId
	and a.TranType = e.TranType

	and a.ReverseSuid is null
	and a.CheckerSuid is not null
	and a.Status = 1
--20071126, victor, REKSADN002, begin
	--and a.TranDate < @dCurrWorkingDate		--masih di hari yang sama
--20080402, indra_w, REKSADN002, begin
-- 	and a.TranDate <= @dCurrWorkingDate		--masih di hari yang sama
--20080402, indra_w, REKSADN002, end
--20071126, victor, REKSADN002, end
--20071126, victor, REKSADN002, begin
--20071126, victor, REKSADN002, begin
	--and a.TranDate > @dToday
--20080402, indra_w, REKSADN002, begin
-- 	and a.TranDate >= @dToday
	and a.NAVValueDate >= @dToday
--20080402, indra_w, REKSADN002, end
--20071126, victor, REKSADN002, end
--20071126, victor, REKSADN002, end
--20071128, victor, REKSADN002, begin
	and a.UserSuid = f.nik
	and f.office_id_sibs = @cOfficeId
--20071128, victor, REKSADN002, end

return 0
GO