
CREATE proc [dbo].[ReksaPopulateVerifyProduct]
/*
	CREATED BY    : victor
	CREATION DATE : 20071109
	DESCRIPTION   : menampilkan list product yang perlu di authorize
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071116, indra_w, REKSADN002, Untuk Close End saja di akhir periode penawaran
		20090323, oscar, REKSADN012, munculkan data khusus untuk WM (118)
		20090723, oscar, REKSADN013, tambah kolom untuk H+x efektif
		20090807, oscar, REKSADN013, perbaikan UAT, boleh otor s/d tgl efektif - 1
	END REVISED
	
	exec dbo.ReksaPopulateVerifyProduct null
	select * from dbo.ReksaProduct_TM
*/
@cNik								int

as

set nocount on

declare	@bCheck						bit
--20071116, indra_w, REKSADN002, begin
		,@dCurrWorkingDate		datetime
		,@dNextWorkingDate		datetime
--20090323, oscar, REKSADN012, begin
		,@nClassificationId	int
		,@nOK tinyint
		,@cErrMsg varchar(100)
		,@nErrNo int
		
select @dCurrWorkingDate = current_working_date
		, @dNextWorkingDate = next_working_date
from dbo.fnGetWorkingDate()
--20071116, indra_w, REKSADN002, end
set @bCheck = 0

set @nOK = 0
select @nClassificationId = classification_id from user_table_classification_v
where module = 'Pro Reksa 2'
and nik = @cNik

-- menu ini khusus WM (118)
if @nClassificationId <> 118
begin
	set @cErrMsg = 'Menu ini khusus untuk user Wealth Management (118)'
	goto ERROR_HANDLER
end
--20090323, oscar, REKSADN012, end
select @bCheck as 'CheckB', a.ProdId, a.ProdCode, a.ProdName, a.ProdCCY, b.TypeName, c.ManInvName,
	a.NAV
--20090723, oscar, REKSADN013, begin
	, a.EffectiveAfter 
--20090723, oscar, REKSADN013, end
from dbo.ReksaProduct_TM a, dbo.ReksaType_TR b, dbo.ReksaManInv_TR c
where a.TypeId = b.TypeId
	and a.ManInvId = c.ManInvId

	and a.WMCheckerSuid is null
	and a.Status = 0
--20071116, indra_w, REKSADN002, begin
--20090807, oscar, REKSADN013, begin
	--and a.PeriodEnd >= @dCurrWorkingDate
	and (a.PeriodEnd < @dNextWorkingDate
		or dbo.fnReksaGetEffectiveDate(a.PeriodEnd, isnull(a.EffectiveAfter, 1)) > @dCurrWorkingDate)
--20090807, oscar, REKSADN013, end
--20071116, indra_w, REKSADN002, end

--20090323, oscar, REKSADN012, begin
ERROR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	--exec @nOK=set_raiserror @@procid, @nErrNo output
	--if @nOK!=0 return 1
	raiserror (@cErrMsg ,16,1);
	set @nOK = 1
end

--return 0
return @nOK
--20090323, oscar, REKSADN012, end
GO