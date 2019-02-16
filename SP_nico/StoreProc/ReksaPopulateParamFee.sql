ALTER proc [dbo].[ReksaPopulateParamFee]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20121029
 DESCRIPTION   : menampilkan list parameter subs fee 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20130418, liliana, BATOY12006, tambah order by 
 END REVISED  
   
 exec dbo.ReksaPopulateParamFee '10001','Pro Reksa 2', 54, 'MFEE' 
 
*/  
@pnNIK			int,
@pcModule		varchar(50),
@nProdId        int,  
@cTrxType		varchar(50)
as  
  
set nocount on  
  
DECLARE
@cErrMessage					varchar(255),
@nErrNo							int,
@nOK							int,
@nFeeId							int

--create table xLog (
--NIK			int	null,
--Module		varchar(50)	null,
--ProdId		int		null,
--TrxType		varchar(50)	null)
insert xLog
select @pnNIK, @pcModule, @nProdId, @cTrxType

if(@cTrxType not in ('SUBS','REDEMP','SWC','MFEE','UPFRONT','SELLING'))
begin
	set @cErrMessage = 'Transaksi Type Salah!'
	goto ERROR
end

if(@cTrxType = 'SUBS')
begin
	select TrxType, ProdId, MinPctFeeEmployee, MaxPctFeeEmployee, MinPctFeeNonEmployee, MaxPctFeeNonEmployee
	from dbo.ReksaParamFee_TM
	where TrxType = 'SUBS'
	and ProdId = @nProdId
	
	select TrxType, ProdId, PercentFrom, PercentTo, MustApproveBy
	from dbo.ReksaTieringNotification_TM
	where TrxType = 'SUBS'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by PercentFrom
--20130418, liliana, BATOY12006, end	
	
	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'SUBS'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end
		
end
else if (@cTrxType = 'REDEMP')
begin
	select @nFeeId = FeeId
	from dbo.ReksaParamFee_TM 
	where TrxType = 'REDEMP'
	and ProdId = @nProdId
	
	select rf.TrxType, rf.ProdId, rf.MinPctFeeEmployee, rf.MaxPctFeeEmployee, rf.MinPctFeeNonEmployee, rf.MaxPctFeeNonEmployee,
		   rf.IsFlat, rf.NonFlatPeriod, rp.RedempIncFee
	from dbo.ReksaParamFee_TM rf
		join dbo.ReksaProduct_TM rp
			on rf.ProdId = rp.ProdId
	where rf.TrxType = 'REDEMP'
	and rf.ProdId = @nProdId
	
	select TrxType, ProdId, PercentFrom, PercentTo, MustApproveBy
	from dbo.ReksaTieringNotification_TM
	where TrxType = 'REDEMP'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by PercentFrom
--20130418, liliana, BATOY12006, end	
	
	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'REDEMP'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end		

	select 
		case when isnull(IsEmployee,0) = 1 then 'Karyawan'
			 when isnull(IsEmployee,0) = 0 then 'Non Karyawan'
		end as Status, 
	Fee as PercentageFee, Period, Nominal 
	from dbo.ReksaRedemPeriod_TM
	where FeeId = @nFeeId
--20130418, liliana, BATOY12006, begin
	order by IsEmployee, Period
--20130418, liliana, BATOY12006, end		
end
else if(@cTrxType = 'SWC')
begin
	select TrxType, ProdId, MinPctFeeEmployee, MaxPctFeeEmployee, MinPctFeeNonEmployee, MaxPctFeeNonEmployee,
		SwitchingFee
	from dbo.ReksaParamFee_TM
	where TrxType = 'SWC'
	and ProdId = @nProdId
	
	select TrxType, ProdId, PercentFrom, PercentTo, MustApproveBy
	from dbo.ReksaTieringNotification_TM
	where TrxType = 'SWC'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by PercentFrom
--20130418, liliana, BATOY12006, end	
	
	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'SWC'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end	

end
else if(@cTrxType = 'MFEE')
begin
	
	select TrxType, ProdId, PeriodEfektifMFee as PeriodEfektif
	from dbo.ReksaParamFee_TM
	where TrxType = 'MFEE'
	and ProdId = @nProdId

	if exists ( select top 1* from 	dbo.ReksaProductMaintenanceFee_TR
	where ProdId = @nProdId)
	begin

		select AUMMin, AUMMax, NispPct as NISPPct, FundMgrPct as FundMgrPct, MaintFee as MaintenanceFee
		from dbo.ReksaProductMaintenanceFee_TR
		where ProdId = @nProdId
		order by AUMMin
	end
	else
	begin

		select AUMMin, AUMMax, NispPct as NISPPct, FundMgrPct as FundMgrPct, MaintFee as MaintenanceFee
		from dbo.ReksaProductMaintenanceFee_TR
		where ProdId = @nProdId
		union all
		select 0,0,0,0,0
	end

	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'MFEE'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end		

end
else if(@cTrxType = 'UPFRONT')
begin
	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'UPFRONT'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end		
	
	select isnull(PctSellingUpfrontDefault,0) as PercentDefault, ProdId, TrxType
	from dbo.ReksaParamFee_TM
	where TrxType = 'UPFRONT'
	and ProdId = @nProdId	
end
else if(@cTrxType = 'SELLING')
begin
	select TrxType, ProdId, Sequence, GLName, GLNumber, Percentage, OfficeId
	from dbo.ReksaListGLFee_TM
	where TrxType = 'SELLING'
	and ProdId = @nProdId
--20130418, liliana, BATOY12006, begin
	order by Sequence
--20130418, liliana, BATOY12006, end	
	
	select isnull(PctSellingUpfrontDefault,0) as PercentDefault, ProdId, TrxType
	from dbo.ReksaParamFee_TM
	where TrxType = 'SELLING'
	and ProdId = @nProdId		
end

  
return 0

ERROR:
----------------------------------------------------------------------		
	if @@trancount > 0
		rollback tran
					
	if @cErrMessage is null 	
		set @cErrMessage = 'Error tidak diketahui pada procedure !'
	
	--exec @nOK = dbo.set_raiserror @@procid, @nErrNo output
	--if @nOK <> 0 or @@error <> 0 
	--	return 1

	raiserror (@cErrMessage ,16,1);
	return 1
