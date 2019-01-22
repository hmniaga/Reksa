
CREATE proc [dbo].[ReksaPopulateVerifyParamFeeDetail]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20121029
 DESCRIPTION   : menampilkan list parameter fee detail yg akan di authorize  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20130222, liliana, BATOY12006, tampilkan data old
  20130226, liliana, BATOY12006, data new yang delete tidak perlu ditampilkan
 END REVISED  
 
 exec ReksaPopulateVerifyParamFeeDetail 10034, 'Pro Reksa 2', 7, 'RKPF04'
 
*/ 
@pnNIK				int,
@pcModule			varchar(50),
@pnSubsID			int,
@cJenisFee			varchar(50)
  
as  
  
set nocount on  

declare 
	@nGLId			int,
	@nTieringId		int,
	@nPeriodId		int,
	@nProdId		int,
	@nMFeeId		int
--20130222, liliana, BATOY12006, begin
	,@nFeeId			int
	,@cProdCode			varchar(20)
--20130222, liliana, BATOY12006, end	

select @nGLId = GLId, @nTieringId = TieringId
	   ,@nPeriodId = PeriodId, @nProdId = ProdId
	   ,@nMFeeId = MFeeId
from dbo.ReksaParamFee_TT
where StatusOtor = 0
and SubsId = @pnSubsID
--20130222, liliana, BATOY12006, begin

select @cProdCode = ProdCode
from dbo.ReksaProduct_TM
where ProdId = @nProdId
--20130222, liliana, BATOY12006, end

if(@cJenisFee = 'RKPF01') --subs
begin  
	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TT rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.TieringId = @nTieringId
		and rt.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rt.ProcessType != 'D'
--20130226, liliana, BATOY12006, end	
	order by rt.PercentFrom
	
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TM rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.ProdId = @nProdId
		and rt.TrxType = 'SUBS'
	order by rt.PercentFrom

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'SUBS'
	order by rl.Sequence	
--20130222, liliana, BATOY12006, end
end
else if(@cJenisFee = 'RKPF02') --redemp
begin
	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TT rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.TieringId = @nTieringId
		and rt.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rt.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rt.PercentFrom
	
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence

--20130222, liliana, BATOY12006, begin	
	--select @nProdId as Product,
		select @cProdCode as Product,
--20130222, liliana, BATOY12006, end	
		case when rr.IsEmployee = 1 then 'Karyawan'
			 when rr.IsEmployee = 0 then 'Non Karyawan'
		else '' end as StatusKaryawan,
		rr.Period, rr.Fee
	from dbo.ReksaRedemPeriod_TT rr	
	where rr.PeriodId = @nPeriodId
		and rr.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rr.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rr.IsEmployee, rr.Period
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TM rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.ProdId = @nProdId
		and rt.TrxType = 'REDEMP'
	order by rt.PercentFrom

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'REDEMP'
	order by rl.Sequence

	select @nFeeId = FeeId
	from dbo.ReksaProduct_TM
	where ProdId = @nProdId
	
	select @cProdCode as Product,
		case when rr.IsEmployee = 1 then 'Karyawan'
			 when rr.IsEmployee = 0 then 'Non Karyawan'
		else '' end as StatusKaryawan,
		rr.Period, rr.Fee
	from dbo.ReksaRedemPeriod_TM rr
	where rr.FeeId = @nFeeId
	order by rr.IsEmployee, rr.Period	
--20130222, liliana, BATOY12006, end
end
else if(@cJenisFee = 'RKPF03') --switching
begin
	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TT rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.TieringId = @nTieringId
		and rt.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rt.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rt.PercentFrom
	
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rt.PercentFrom, rt.PercentTo,
		   rt.MustApproveBy
	from dbo.ReksaTieringNotification_TM rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.ProdId = @nProdId
		and rt.TrxType = 'SWC'
	order by rt.PercentFrom

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'SWC'
	order by rl.Sequence	
--20130222, liliana, BATOY12006, end	
end
else if(@cJenisFee = 'RKPF04') --maintenance fee
begin
	select rp.ProdCode as Product, rt.AUMMin, rt.AUMMax,
		   rt.NispPct, rt.FundMgrPct, rt.MaintFee
	from dbo.ReksaProductMaintenanceFee_TT rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.MFeeId = @nMFeeId
		and rt.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rt.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rt.AUMMin 
	
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rt.AUMMin, rt.AUMMax,
		   rt.NispPct, rt.FundMgrPct, rt.MaintFee
	from dbo.ReksaProductMaintenanceFee_TR rt
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rt.ProdId
	where rt.ProdId = @nProdId
	order by rt.AUMMin

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'MFEE'
	order by rl.Sequence	
--20130222, liliana, BATOY12006, end	
end
else if(@cJenisFee = 'RKPF05') --UpFront fee
begin
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'UPFRONT'
	order by rl.Sequence
--20130222, liliana, BATOY12006, end	
end
else if(@cJenisFee = 'RKPF06') --Selling fee
begin
	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TT rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.GLId = @nGLId
		and rl.StatusOtor = 0
--20130226, liliana, BATOY12006, begin
		and rl.ProcessType != 'D'
--20130226, liliana, BATOY12006, end			
	order by rl.Sequence
--20130222, liliana, BATOY12006, begin

	select rp.ProdCode as Product, rl.Sequence, rl.GLName, rl.GLNumber, rl.OfficeId,
		   rl.Percentage 
	from dbo.ReksaListGLFee_TM rl
		join dbo.ReksaProduct_TM  rp
			on rp.ProdId = rl.ProdId
	where rl.ProdId = @nProdId
		and rl.TrxType = 'SELLING'
	order by rl.Sequence
--20130222, liliana, BATOY12006, end	
end
  
return 0
GO