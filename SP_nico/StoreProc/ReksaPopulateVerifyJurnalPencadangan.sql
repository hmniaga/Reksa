
CREATE proc [dbo].[ReksaPopulateVerifyJurnalPencadangan]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120824
	DESCRIPTION   : menampilkan list jurnal pencadangan fee yang perlu di authorize
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120830, liliana, BAALN11003, ganti jadi Id
	END REVISED

*/
@cNik								int

as

set nocount on

declare	@bCheck						bit

set @bCheck = 0

select 
	@bCheck as CheckB,
--20120830, liliana, BAALN11003, begin	
	--rr.RevId,
	rr.RevId as Id,
--20120830, liliana, BAALN11003, end	
	rr.ProdCode,  
	rp.ProdName,
	rr.TanggalStart,
	rr.TanggalEnd,
	rr.Inputter,
	rr.InputDate
from dbo.ReksaReversePencadangan_TT rr
	join dbo.ReksaProduct_TM rp
		on rp.ProdCode = rr.ProdCode
where rr.TipeReverse = 'JURNAL'
	and StatusOtor = 0

return 0
GO