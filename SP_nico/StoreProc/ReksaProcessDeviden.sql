CREATE proc [dbo].[ReksaProcessDeviden]  
/*  
 CREATED BY    : indra  
 CREATION DATE : 20071017  
 DESCRIPTION   : Buat Bill Pembayaran Deviden, insert ke ReksaTransaction TT  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
	20071130, indra_w, REKSADN002, perbaikan  
	20071207, indra_w, REKSADN002, jika close end, jangan update subc unit dan subc nominal  
	20071209, indra_w, REKSADN002, perbaikan karena terbalik  
	20071210, indra_w, REKSADN002, rounding!!!  
	20071217, indra_w, REKSADN002, perbaikan UAT  
	20080206, indra_w, REKSADN002, deviden tidak perlu buat no trans  
	20080214, indra_w, REKSADN002, TUNING  
	20080414, mutiara, REKSADN002, perubahan tipe data dan penggunaan fungsi ReksaSetRounding
	20080419, indra_w, REKSADN002, update table last payment dev 
	20081219, indra_w, REKSADN009, penambahan parameter cara perhitungan deviden proteksi
	20120710, liliana, BAALN11003, tambahan parameter di fnGetDevPaymentDate
	20120924, liliana, BAALN11003, jika hari libur, diproses di hari kerja berikutnya
	20121008, liliana, BAALN11003, Bill di bulatkan 2 angka belakang koma
	20130701, liliana, BAFEM12011, perbaikan deviden
 END REVISED  
*/  
as  
  
set nocount on  
  
declare @cErrMsg   varchar(100)  
	, @nOK    int  
	, @nErrNo   int  
	, @nUserSuid  int  
	, @dCurrDate  datetime  
	, @dCurrWorkingDate datetime  
	, @dNextWorkingDate datetime 
--20120924, liliana, BAALN11003, begin
	, @dPrevWorkingDate datetime 
--20120924, liliana, BAALN11003, end 
	, @dTranDate  datetime  
	, @cTranCode  char(8)  
	, @nCounter   int  
	, @cPrefix   char(3)  
	, @nProdId   int  
	, @nClientId  int  
	, @cTranCCY   char(3)  
--20080414, mutiara, REKSADN002, begin  
--  , @mUnitBal   money  
--  , @mSubcBal   money  
	, @mUnitBal   decimal(25,13)  
	, @mSubcBal   decimal(25,13)  
--20071207, indra_w, REKSADN002, begin  
--  , @mNAV    money  
--  , @mNAV    decimal(20,10)  
	, @mNAV    decimal(25,13)  
--20071207, indra_w, REKSADN002, end  
--  , @mKurs   money  
--  , @mUnitBalanceNom money  
	, @mKurs   decimal(25,13)  
	, @mUnitBalanceNom decimal(25,13)  
	, @nParamId   int  
--  , @mTranUnit  money  
--  , @mTranNom   money  
	, @mTranUnit  decimal(25,13)  
	, @mTranNom   decimal(25,13)  
	, @cPeriod   varchar(8)  
	, @nCalcId   int  
	, @nAgentId   int  
--20071217, indra_w, REKSADN002, begin  
--  , @mProtekLastUnit money  
--  , @mProtekLastNom money  
--  , @mSubsNominal  money  
	, @mProtekLastUnit decimal(25,13)  
	, @mProtekLastNom decimal(25,13)  
	, @mSubsNominal  decimal(25,13)  
--20080414, mutiara, REKSADN002, end  
--20071217, indra_w, REKSADN002, end  
exec @nOK = set_usersuid @nUserSuid output    
if @nOK != 0 or @@error != 0 return 1    
  
exec @nOK = cek_process_table @nProcID = @@procid     
if @nOK != 0 or @@error != 0 return 1    
  
exec @nOK = set_process_table @@procid, null, @nUserSuid, 1    
if @nOK != 0 or @@error != 0 return 1    
  
set @nOK = 0  
  
--20080214, indra_w, REKSADN002, begin  
create table #tempDevPaymentDate(  
	ProdId  int  
	, PaymentDate datetime  
)  
  
insert #tempDevPaymentDate  
--20120710, liliana, BAALN11003, begin
--select ProdId,dbo.fnGetDevPaymentDate(ProdId) 
--20130701, liliana, BAFEM12011, begin 
--select ProdId,dbo.fnGetDevPaymentDate(ProdId, 1)  
select ProdId,dbo.fnGetDevPaymentDate(ProdId, 0)  
--20130701, liliana, BAFEM12011, end
--20120710, liliana, BAALN11003, end
from ReksaProduct_TM  
  
update #tempDevPaymentDate  
set PaymentDate = isnull(PaymentDate, '19000101')  
--20080214, indra_w, REKSADN002, end  
  
select @dCurrDate = current_working_date  
from control_table  
  
  
select @dCurrWorkingDate = current_working_date  
 , @dNextWorkingDate = next_working_date  
--20120924, liliana, BAALN11003, begin
	, @dPrevWorkingDate = previous_working_date
--20120924, liliana, BAALN11003, end  
 , @dTranDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate())   
from fnGetWorkingDate()  
  
If @dCurrDate < @dCurrWorkingDate  
Begin  
	exec @nOK = set_process_table @@procid, null, @nUserSuid, 0    
	if @nOK != 0 or @@error != 0 return 1  

	return 0  
End  
  
set @cPeriod = convert(char(8), @dCurrWorkingDate, 112)  
  
declare dev_cur cursor local fast_forward for   
--20071217, indra_w, REKSADN002, begin  
	select a.ProdId, a.ClientId, b.ProdCCY, a.UnitBalance, a.SubcUnit, c.NAV, c.Kurs  
		, a.UnitNominal, b.ParamId, left(b.ProdCode,3), b.CalcId, a.AgentId  
		, a.ProtekLastUnit, a.ProtekLastNom, a.SubcNominal  
--20071217, indra_w, REKSADN002, end  
	from ReksaCIFData_TM a join ReksaProduct_TM b  
			on a.ProdId = b.ProdId  
		join ReksaNAVParam_TH c  
			on a.ProdId = c.ProdId  
			and c.ValueDate = @dCurrWorkingDate  
--20080214, indra_w, REKSADN002, begin  
		join #tempDevPaymentDate d  
			on a.ProdId = d.ProdId  
--20080214, indra_w, REKSADN002, end  
	where b.IsDeviden = 1  
--20080214, indra_w, REKSADN002, begin  
--  and dbo.fnGetDevPaymentDate(a.ProdId) >= @dCurrWorkingDate  
--  and dbo.fnGetDevPaymentDate(a.ProdId) < @dNextWorkingDate  
--20120924, liliana, BAALN11003, begin
	--and d.PaymentDate >= @dCurrWorkingDate  
	--and d.PaymentDate < @dNextWorkingDate 
	and d.PaymentDate > @dPrevWorkingDate
	and d.PaymentDate <= @dCurrWorkingDate
--20120924, liliana, BAALN11003, end   
--20071130, indra_w, REKSADN002, begin  
--20081219, indra_w, REKSADN009, begin
--	and ((a.UnitBalance != a.SubcUnit and b.CalcId = 2) or (a.UnitBalance > a.SubcUnit and b.CalcId != 2))  
	and ((a.UnitBalance != a.SubcUnit and b.CalcId in (2,5)) or (a.UnitBalance > a.SubcUnit and b.CalcId not in (2,5)))  
--20081219, indra_w, REKSADN009, end
--20071130, indra_w, REKSADN002, end  
--20080214, indra_w, REKSADN002, end  
	and a.CIFStatus = 'A'  
	and b.Status = 1  
	and a.NAVDate = @dCurrWorkingDate  
	order by a.ProdId, ClientId  
  
open dev_cur   
  
while 1=1  
begin  
	fetch dev_cur into @nProdId, @nClientId, @cTranCCY, @mUnitBal, @mSubcBal, @mNAV, @mKurs  
	, @mUnitBalanceNom, @nParamId, @cPrefix, @nCalcId, @nAgentId  
--20071217, indra_w, REKSADN002, begin  
	, @mProtekLastUnit, @mProtekLastNom, @mSubsNominal  
--20071217, indra_w, REKSADN002, end  
	if @@fetch_status!=0 break  
   
	begin tran  
--20071217, indra_w, REKSADN002, begin  
--20081219, indra_w, REKSADN009, begin
--		select @mTranUnit = case when @nCalcId = 2 then @mProtekLastUnit - @mUnitBal else abs(@mUnitBal - @mSubcBal) end  
		select @mTranUnit = case when @nCalcId in (2,5) then @mProtekLastUnit - @mUnitBal else abs(@mUnitBal - @mSubcBal) end  
--20081219, indra_w, REKSADN009, end
--20080414, mutiara, REKSADN002, begin  
--  select @mTranNom = @mTranUnit * @mNAV  
		select @mTranNom = dbo.fnReksaSetRounding(@nProdId,3,@mTranUnit * @mNAV)  
--20080414, mutiara, REKSADN002, end  
--  select @mTranNom = case when @nCalcId = 2 then @mProtekLastNom - @mUnitBalanceNom else abs(@mUnitBalanceNom - @mSubsNominal) end  
--20071130, indra_w, REKSADN002, begin  
--select @nProdId, @mTranUnit, @mTranNom, @nCalcId  
--20071130, indra_w, REKSADN002, end  
--20071217, indra_w, REKSADN002, end  
--20081219, indra_w, REKSADN009, begin
--		If @nCalcId != 2 -- kalo bukan Proteksi, kredit dulu, kalo proteksi jangan di kredit  
		If @nCalcId not in (2,5) -- kalo bukan Proteksi, kredit dulu, kalo proteksi jangan di kredit  
--20081219, indra_w, REKSADN009, end
		Begin  
--20080206, indra_w, REKSADN002, begin   
--   Update ReksaClientCounter_TR with(rowlock)  
--   set @nCounter = isnull(Trans, 0) + 1  
--    ,Trans = @nCounter  
--   where ProdId = @nProdId  
  
--   if @@error!= 0 or @@rowcount = 0   
--   Begin  
--    set @nOK = 1  
--    goto NEXT  
--   End  
  
			select @cTranCode = ''--@cPrefix + right('00000'+ convert(varchar(5),@nCounter),5)  
--20080206, indra_w, REKSADN002, end  
			select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())  
  
			-- insert buat kreditnya  
			Insert ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
			, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
			, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
			, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence)  
			select @cTranCode, 5, @dCurrWorkingDate, @nProdId, @nClientId, null, @nAgentId, @cTranCCY, @mTranNom  
			, @mTranUnit, 0, 0, 0, 0, @mNAV, @dCurrWorkingDate, @mKurs, @mUnitBal  
			, @mUnitBalanceNom, @nParamId, @dTranDate, @dTranDate, 1, @dTranDate, 7, 7  
			, null, 0, null, 1, null, 1, 0  
  
			if @@error!= 0 or @@rowcount = 0   
			Begin  
				set @nOK = 1  
				goto NEXT  
			End  
		End  
--20080206, indra_w, REKSADN002, begin  
--  Update ReksaClientCounter_TR with(rowlock)  
--  set @nCounter = isnull(Trans, 0) + 1  
--   ,Trans = @nCounter  
--  where ProdId = @nProdId  
--   
--  if @@error!= 0 or @@rowcount = 0   
--  Begin  
--   set @nOK = 1  
--   goto NEXT  
--  End  
  
		select @cTranCode = ''--@cPrefix + right('00000'+ convert(varchar(5),@nCounter),5)  
--20080206, indra_w, REKSADN002, end  
  
		select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())  
  
  -- insert buat debetnya  
		Insert ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
				, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
				, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
				, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence)  
		select @cTranCode, 6, @dCurrWorkingDate, @nProdId, @nClientId, null, @nAgentId, @cTranCCY, @mTranNom  
--20071217, indra_w, REKSADN002, begin  
			, @mTranUnit, 0, 0, 0, 0, @mNAV, @dCurrWorkingDate, @mKurs  
--20081219, indra_w, REKSADN009, begin
--			, case when @nCalcId = 2 then @mUnitBal else @mSubcBal end  
			, case when @nCalcId in (2,5) then @mUnitBal else @mSubcBal end  
--20081219, indra_w, REKSADN009, end
--20071210, indra_w, REKSADN002, begin  
--   , @mSubcBal * @mNAV, @nParamId, @dTranDate, null, 0, @dTranDate, 7, 7  
--20080414, mutiara, REKSADN002, begin  
--   , case when @nCalcId = 2 then @mUnitBal * @mNAV else @mSubcBal * @mNAV end  
--20081219, indra_w, REKSADN009, begin
--			, case when @nCalcId = 2 then dbo.fnReksaSetRounding(@nProdId,3,@mUnitBal * @mNAV) else dbo.fnReksaSetRounding(@nProdId,3,@mSubcBal * @mNAV) end  
			, case when @nCalcId in (2,5) then dbo.fnReksaSetRounding(@nProdId,3,@mUnitBal * @mNAV) else dbo.fnReksaSetRounding(@nProdId,3,@mSubcBal * @mNAV) end  
--20081219, indra_w, REKSADN009, end
--20080414, mutiara, REKSADN002, end  
			, @nParamId, @dTranDate, null, 0  
--   , case when @nCalcId = 2 then @dTranDate else null end  
--   , case when @nCalcId = 2 then 1 else 0 end  
			, @dTranDate, 7, 7  
--20071210, indra_w, REKSADN002, end  
			, null, 0, null, 1, null, 1, 0  
--20071217, indra_w, REKSADN002, end  
		if @@error!= 0 or @@rowcount = 0   
		Begin  
			set @nOK = 1  
			goto NEXT  
		End  
--20081219, indra_w, REKSADN009, begin
--		If @nCalcId != 2 -- kalo Proteksi, kebalikan  
		If @nCalcId not in (2,5) -- kalo Proteksi, kebalikan  
--20081219, indra_w, REKSADN009, end
		Begin  
			Update ReksaCIFData_TM  
--20071207, indra_w, REKSADN002, begin  
--20071209, indra_w, REKSADN002, begin  
--   set UnitBalance  = UnitBalance  
--    , UnitNominal = UnitNominal  
			set UnitBalance  = SubcUnit  
				, UnitNominal = SubcNominal  
--20071209, indra_w, REKSADN002, end  
--20071207, indra_w, REKSADN002, end  
			where ClientId = @nClientId  
  
			if @@error!= 0 or @@rowcount = 0   
			Begin  
				set @nOK = 1  
				goto NEXT  
			End  
		End  
		else  
		begin  
			Update ReksaCIFData_TM  
--20071209, indra_w, REKSADN002, begin  
--20071217, indra_w, REKSADN002, begin  
--   set SubcUnit  = UnitBalance  
--    , SubcNominal = UnitNominal  
--   set SubcUnit  = SubcUnit  
--    , SubcNominal = SubcNominal  
				set ProtekLastUnit = UnitBalance  
				, ProtekLastNom = UnitNominal  
--20071209, indra_w, REKSADN002, end  
			where ClientId = @nClientId  
--20071217, indra_w, REKSADN002, end  
			if @@error!= 0 or @@rowcount = 0   
			Begin  
				set @nOK = 1  
				goto NEXT  
			End  
		end  
	commit tran  
  
	continue  
  
NEXT:  
	if @@trancount >0   
		rollback tran  
end  
  
close dev_cur  
deallocate dev_cur  
  
If @nOK = 1  
Begin  
	set @cErrMsg = 'Error Process Deviden'  
	Goto ERROR  
End  
  
-- Buat Billnya  
--proses yang subcription by Nominal  
Begin Tran  
	select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())  
  
	declare bill_cur cursor local fast_forward for   
		select ProdId, TranCCY  
		from ReksaTransaction_TT  
		where TranType in (6)  
			and isnull(BillId, 0) = 0  
		Group by ProdId, TranCCY  
		order by ProdId  
  

 	open bill_cur   
  
	while 1=1  
	begin  
		fetch bill_cur into @nProdId, @cTranCCY  
		if @@fetch_status!=0 break  
    
		Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
				, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)  
		select 3, @cPeriod + ' - Deviden - '+ c.CustodyName, 'D', @dTranDate, @dCurrWorkingDate  
--20071210, indra_w, REKSADN002, begin  
--   , a.ProdId, c.CustodyId, a.TranCCY, sum(a.TranAmt), sum(a.SubcFee), sum(a.SubcFeeBased)  
			, a.ProdId, c.CustodyId, a.TranCCY  
--20121008, liliana, BAALN11003, begin			
			--, sum(case when a.TranCCY = 'IDR' then round(isnull(a.TranAmt,0),0) else round(isnull(a.TranAmt,0),2) end)  
			, sum(case when a.TranCCY = 'IDR' then round(isnull(a.TranAmt,0),2) else round(isnull(a.TranAmt,0),2) end)  
--20121008, liliana, BAALN11003, end			
			, sum(case when a.TranCCY = 'IDR' then round(isnull(a.SubcFee,0),0) else round(isnull(a.SubcFee,0),2) end)  
			, sum(case when a.TranCCY = 'IDR' then round(isnull(a.SubcFeeBased,0),0) else round(isnull(a.SubcFeeBased,0),2) end)  
--20071210, indra_w, REKSADN002, end  
		from ReksaTransaction_TT a join ReksaProduct_TM b  
				on a.ProdId = b.ProdId  
			join ReksaCustody_TR c  
				on b.CustodyId = c.CustodyId  
		where a.TranType in (6)  
			and a.ProdId = @nProdId  
			and a.TranCCY = @cTranCCY  
--20071217, indra_w, REKSADN002, begin  
--   and b.CalcId != 2 -- yang proteksi ngga dibagikan  
--20071217, indra_w, REKSADN002, end  
			and isnull(a.BillId, 0) = 0  
		group by c.CustodyName, a.ProdId, c.CustodyId, a.TranCCY  
  
		If @@error!= 0  
		Begin  
			set @cErrMsg = 'Gagal Process Subc By Nominal!'  
			goto ERROR  
		End  

		Update ReksaTransaction_TT  
		set BillId = scope_identity()  
		from ReksaTransaction_TT a join ReksaProduct_TM b  
				on a.ProdId = b.ProdId  
		where isnull(a.BillId, 0) = 0  
				and a.TranType in (6)  
				and a.ProdId = @nProdId  
				and a.TranCCY = @cTranCCY  
--20071217, indra_w, REKSADN002, begin  
--   and b.CalcId != 2  
--20071217, indra_w, REKSADN002, end  
		If @@error!= 0  
		Begin  
			set @cErrMsg = 'Gagal Update Data Bill Subc By Nominal!'  
			goto ERROR  
		End  

--20080419, indra_w, REKSADN002, begin
		Update ReksaLastDevPayment_TM
--20120710, liliana, BAALN11003, begin		
		--set PayDate = @dCurrWorkingDate
		set PayDate = dbo.fnGetDevPaymentDate(ProdId, 0)  --jangan perhitungkan hari libur
--20120710, liliana, BAALN11003, end		
		where ProdId = @nProdId

		If @@error!= 0  
		Begin  
			set @cErrMsg = 'Gagal Update Last Payment Date!'  
			goto ERROR  
		End  
--20080419, indra_w, REKSADN002, end
 
	end  
  
	close bill_cur  
	deallocate bill_cur  
commit tran  
  
  
exec @nOK = set_process_table @@procid, null, @nUserSuid, 0    
if @nOK != 0 or @@error != 0 return 1  
  
return 0  
  
ERROR:  
If @@trancount > 0   
	rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
	set @cErrMsg = 'Unknown Error !'  
  
exec @nOK = set_process_table @@procid, null, @nUserSuid, 2    
if @nOK != 0 or @@error != 0 return 1  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg ,16,1)
return 1
GO