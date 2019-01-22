CREATE proc [dbo].[ReksaProcessCalcMFee]
/*
	CREATED BY    : liliana
	CREATION DATE : 20121228
	DESCRIPTION   : Hitung Jumlah Unit Client Code sesuai Period
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130215, liliana, BATOY12006, ganti logic	
		20130226, liliana, BATOY12006, ganti orderby trandate
		20130401, liliana, BATOY12006, ganti perhitungan period
		20130408, liliana, BATOY12006, perubahan logic
	END REVISED

*/
	@pdValueDate		datetime,
	@pnProdId			int,
	@pnClientId			int,
	@pbDebug			bit = 0
as

set nocount on

--20130408, liliana, BATOY12006, begin
--declare @cErrMsg   varchar(100)      
--  , @nOK    int      
--  , @nErrNo   int          
--  , @dCurrWorkingDate datetime      
--  , @nFeeId   int                 
--  , @mOutstanding  decimal(25,13)      
--  , @mRedemToday  decimal(25,13)            
--  , @mLastNAV   decimal(25,13)            
--  , @bByUnit   bit      
--  , @nTranId   int           
--  , @mSaldoUnit  decimal(25,13)      
--  , @mTiringAmt  decimal(25,13)      
--  , @nPeriod   tinyint      
--  , @dLastDevPayment datetime      
--  , @dTranDate  datetime      
--  , @bByAnum   bit           
--  , @nPercen   decimal(25,13)      
--  , @nDays   decimal(25,13)      
--  , @nSubFeeBased  decimal(25,13)      
--  , @nRedempFeeBased decimal(25,13)          
--  , @mDeviden   decimal(25,13)      
--  , @mTotalUnit  decimal(25,13)      
--  , @mRedempUnit  decimal(25,13)      
--  , @mRedempDev  decimal(25,13)          
--  , @mTranUnit  decimal(25,13)      
--  , @mFirstMonthUnit decimal(25,13)      
--  , @mUnitBalance  decimal(25,13)      
--  , @mTotRedempDev decimal(25,13)      
--  , @nRedempDisc  decimal(25,13)          
--  , @nCalcId   int           
--  , @nIncludeDev  tinyint          
--  , @dDateStart  datetime      
--  , @dDateEnd   datetime      
--  , @dDateCurrent  datetime     
--  , @nMonthPeriod int
--  , @dTglEfektif	datetime

--set @nOK = 0

--create table #OutTran(      
----20130215, liliana, BATOY12006, begin
--	ClientId		int,
----20130215, liliana, BATOY12006, end
--   Seq  int identity(1,1) primary key      
--  , TranId int       
--  , TranType int      
--  , TranDate datetime      
--  , TranCCY char(3)          
--  , TranUnit decimal(25,13)      
--  , SaldoUnit decimal(25,13)  
----20130215, liliana, BATOY12006, begin
--  , UnitBalance	decimal(25,13)
----20130215, liliana, BATOY12006, end      
--  , TranAmt decimal(25,13)  
--  , NAV		decimal(25,13)  
--  , TglEfektif	datetime    
--  , Period tinyint      
--  , PctFee decimal(25,13)        
--  , RedempUnit decimal(25,13)      
--  , RedempDev  decimal(25,13)      
--  , Fee  decimal(25,13)      
--  , Deviden decimal(25,13)
--  , IsHitung		bit
--)           
   
--select @dCurrWorkingDate = current_working_date      
--from control_table 
     
--if @pdValueDate is not null      
-- select @dCurrWorkingDate = @pdValueDate  
 
       
-- -- cari NAV terakhir untuk Product       
     
--select top 1 @mLastNAV = NAV      
--from dbo.ReksaNAVParam_TH       
--where ProdId = @pnProdId        
--and ValueDate <= @dCurrWorkingDate      
--order by ValueDate desc      

 
-- -- cari oustanding terakhir dari subcription aja      
   
-- select @mOutstanding = SubcUnit, @mUnitBalance = UnitBalance      
-- from dbo.ReksaCIFData_TM      
-- where ClientId = @pnClientId    
 
 
----cari o/s dan unit balance dari history kl back date      
-- if @pdValueDate is not null      
--  select @mUnitBalance = isnull(UnitBalance, @mUnitBalance)      
--  from dbo.ReksaCIFDataHist_TM      
--  where ClientId = @pnClientId      
--  and TransactionDate = dbo.fnReksaGetEffectiveDate(@pdValueDate, -1)      
    
----cari SubcUnit dari history mtnc fee      
-- if @pdValueDate is not null      
--  select @mOutstanding = isnull(SubcUnit, @mOutstanding)      
--  from dbo.ReksaMtncFeeDetail_TM      
--  where ClientId = @pnClientId      
--  and ValueDate = dbo.fnReksaGetEffectiveDate(@pdValueDate, -1)      
  
----cari period efektif maintenance fee
--	select @nMonthPeriod = isnull(PeriodEfektifMFee, 0)
--	from dbo.ReksaParamFee_TM 
--	where ProdId = @pnProdId
--		and TrxType = 'MFEE'
      
-- if @pbDebug = 1       
--  select @pdValueDate, @nMonthPeriod, @pnClientId, @mOutstanding, @mUnitBalance    


-- insert #OutTran (TranId, TranType, TranDate, TranCCY, TranUnit
--		,NAV, TglEfektif
----20130215, liliana, BATOY12006, begin
--		, UnitBalance, ClientId
----20130215, liliana, BATOY12006, end  		
-- )     
-- select TranId, TranType, NAVValueDate, TranCCY, TranUnit    
----20130215, liliana, BATOY12006, begin
--		--,NAV, dateadd(mm,@nMonthPeriod, NAVValueDate) 
--		,NAV,
----20130401, liliana, BATOY12006, begin		
--		--case when TranType in (1,2, 8) then dateadd(mm,@nMonthPeriod, NAVValueDate)  
--		case when TranType in (1,2, 8) then dateadd(dd,1,dateadd(mm,@nMonthPeriod, NAVValueDate))   
----20130401, liliana, BATOY12006, end
--			 when TranType in (3,4, 6) then NAVValueDate end  
--		, UnitBalance, @pnClientId
----20130215, liliana, BATOY12006, end		
-- from dbo.ReksaTransaction_TH          
-- where ClientId = @pnClientId           
--   and Status = 1      
----20130215, liliana, BATOY12006, begin   
--   --and TranType in (1,2)    
--    and TranType in (1,2,3,4,6,8)       
----20130215, liliana, BATOY12006, end   
--   and NAVValueDate <= @dCurrWorkingDate        
-- union all      
-- select TranId, TranType, NAVValueDate, TranCCY, TranUnit     
----20130215, liliana, BATOY12006, begin
--		--,NAV, dateadd(mm,@nMonthPeriod, NAVValueDate) 
--		,NAV,
----20130401, liliana, BATOY12006, begin		
--		--case when TranType in (1,2, 8) then dateadd(mm,@nMonthPeriod, NAVValueDate)  
--		case when TranType in (1,2, 8) then dateadd(dd,1,dateadd(mm,@nMonthPeriod, NAVValueDate))   
----20130401, liliana, BATOY12006, end		 
--			 when TranType in (3,4, 6) then NAVValueDate end  
--		, UnitBalance, @pnClientId
----20130215, liliana, BATOY12006, end			
-- from dbo.ReksaTransaction_TT      
-- where ClientId = @pnClientId      
--   and Status = 1      
----20130215, liliana, BATOY12006, begin   
--   --and TranType in (1,2)    
--    and TranType in (1,2,3,4,6,8)       
----20130215, liliana, BATOY12006, end     
--   and NAVValueDate <= @dCurrWorkingDate      
--   and ProcessDate is not null   
----20130215, liliana, BATOY12006, begin          
-- --order by TranId desc
--  order by TranId      
----20130215, liliana, BATOY12006, end 
       
-- -- update saldo unit sehingga terisi jumlah unit yang belum di redemp      
-- Update #OutTran      
-- set @mOutstanding = @mOutstanding - TranUnit      
--  , SaldoUnit = case when @mOutstanding >= 0 then TranUnit else TranUnit + @mOutstanding end -- TranUnit + @mOutstanding      
--  , TranDate = convert(datetime, convert(char(8), TranDate, 112))      
        
-- update #OutTran      
-- set SaldoUnit = 0      
-- where SaldoUnit <= 0      

----20130215, liliana, BATOY12006, begin     
---- -- perhitungkan deviden dalam unit, harus diperhitungkan jika yang ada payment, dihitung dari tanggal terakhir payment      
---- If exists(select top 1 1 from dbo.ReksaProduct_TM where ProdId = @pnProdId and IsDeviden = 1)      
---- Begin      
    
----  select @dLastDevPayment = PayDate      
----  from ReksaLastDevPayment_TM      
----  where ProdId = @pnProdId      
        
----  if @pdValueDate is not null      
----   select @dLastDevPayment = max(TranDate)      
----   from ReksaTransaction_TH      
----   where ClientId = @pnClientId      
----    and TranType = 6       
----   and NAVValueDate <= @pdValueDate      
         
----  if @pbDebug = 1      
----   select @dLastDevPayment      
      
----  if isnull(@dLastDevPayment, '19000101') = '19000101'      
----   select @dLastDevPayment = TranDate      
----   from ReksaTransaction_TH      
----   where ClientId = @pnClientId      
----    and TranType = 6          
      
----  if isnull(@dLastDevPayment, '19000101') = '19000101'      
----   select top 1 @dLastDevPayment = TranDate --dateadd(dd, -1, TranDate)      
----   from #OutTran      
----   order by TranId      
      
---- end      
---- else      
---- Begin      
----  -- karena hari transaksi pertama ikut diperhitungkan dalam deviden, kurangi 1 hari      
----  select top 1 @dLastDevPayment = TranDate   
----  from #OutTran      
----  order by TranId      
---- End                  
  
---- -- kursor untuk mencari feenya      
---- declare tran_cur cursor local fast_forward for       
----  select TranId,SaldoUnit,Period, TranDate, TranUnit 
----  , TglEfektif       
----  from #OutTran      
----  order by TranId      
      
---- open tran_cur       
      
---- while 1=1      
---- begin           
----  fetch tran_cur into @nTranId, @mSaldoUnit, @nPeriod, @dTranDate, @mTranUnit       
----  , @dTglEfektif     
     
----  if @@fetch_status!=0       
----   break      
        
----  set @mTiringAmt = 0      
       
----  -- hitung ulang saldo unit berdasarkan deviden           
----  set @mTotalUnit = 0      
----  set @mDeviden = 0      
----  set @mRedempUnit = 0      
----  set @mRedempDev = 0      
    
----  -- jika ada redemption di tengah bulan, hitung deviden dengan memperhitungkan redemption      
----  If exists(select top 1 1 from ReksaTranRelation_TM      
----      where NAVValueDate > @dLastDevPayment      
----      and SubcTranId = @nTranId)       
           
----  Begin      
      
----   delete #TempRedemp      
      
----   insert #TempRedemp      
----   select sum(RedempUnit), sum(RedempDev), NAVValueDate, @pnProdId      
----   from ReksaTranRelation_TM      
----   where NAVValueDate >@dLastDevPayment      
----      and SubcTranId = @nTranId      
----   group by NAVValueDate      
      
----   set @mFirstMonthUnit = @mSaldoUnit      
      
----   select @mFirstMonthUnit = @mFirstMonthUnit + isnull(RedempUnit,0)      
----   from #TempRedemp      
      
----   select @mDeviden = @mFirstMonthUnit      
      
----   select @mTotRedempDev = isnull(sum(RedempDev),0)      
----   from #TempRedemp      
----   where NAVValueDate = @dCurrWorkingDate      
      
----   select @mDeviden = @mDeviden +           
----        isnull(case when b.NAVValueDate is null then dbo.fnReksaSetRounding(@pnProdId,2,cast(cast(cast(cast(Deviden/@nPercen as decimal(25,13)) * @mDeviden as decimal(25,13))/@mLastNAV as decimal(25,13))/@nDays as decimal(25,13)))      
----         else dbo.fnReksaSetRounding(@pnProdId,2,cast(cast(cast(cast(Deviden/@nPercen as decimal(25,13)) * @mDeviden as decimal(25,13))/NAV as decimal(25,13))/@nDays as decimal(25,13)) - isnull(RedempUnit, 0) - isnull(RedempDev, 0) )      
----        end, 0)           
----   from ReksaNAVParam_TH a left join #TempRedemp b      
----     on a.ProdId = b.ProdId      
----      and a.ValueDate = b.NAVValueDate      
----   where a.ProdId = @pnProdId      
----    and a.ValueDate > @dLastDevPayment      
----    and a.ValueDate > @dTranDate      
----    and a.ValueDate <= @dCurrWorkingDate      
      
----   select @mDeviden = @mDeviden - @mSaldoUnit      
         
----   If @mDeviden < 0      
----    set @mDeviden = 0      
      
----  End      
----  else      
----  Begin          
----   select @mDeviden = @mSaldoUnit      
  
----   select @mDeviden = @mDeviden + dbo.fnReksaSetRounding(@pnProdId,2,cast(cast(cast(cast(Deviden/@nPercen as decimal(25,13)) * @mDeviden as decimal(25,13))/@mLastNAV as decimal(25,13))/@nDays as decimal(25,13)))           
----   from ReksaNAVParam_TH       
----   where ProdId = @pnProdId      
----    and ValueDate > @dLastDevPayment      
----    and ValueDate > @dTranDate      
----    and ValueDate <= @dCurrWorkingDate      
----   select @mDeviden = @mDeviden - @mSaldoUnit      
----  End          
----  if @mDeviden < 0 or @mDeviden is null      
----   set @mDeviden = 0          
      
----  Update #OutTran       
----  set Deviden = isnull(@mDeviden,0)      
----  where TranId = @nTranId       
          
      
----  If @mRedemToday >= @mSaldoUnit       
----  Begin      
----   set @mRedemToday = @mRedemToday - @mSaldoUnit      
----   set @mSaldoUnit = 0      
----  End      
----  Else      
----  Begin      
----   set @mSaldoUnit = @mSaldoUnit - @mRedemToday      
----   set @mRedemToday = 0      
----  End      
      
----  If @mRedemToday >= @mDeviden      
----  Begin      
----   set @mRedemToday = @mRedemToday - @mDeviden      
----   set @mDeviden = 0      
----  End             
----  else      
----  Begin      
----   set @mDeviden = @mDeviden - @mRedemToday      
----  End      
----  select @mTotalUnit =isnull(@mSaldoUnit,0)+ isnull(@mDeviden,0)      


----  if(@dTglEfektif  <= @dCurrWorkingDate)
----  begin
----	set @mTotalUnit = isnull(@mTotalUnit,0) - isnull(@mTranUnit, 0)
----  end         
      
----  If @mTotalUnit <= 0      
----  Begin      
----   continue      
----  End      
      
----  If @mRedempUnit is null      
----   set @mRedempUnit = 0      
      
----  If @mRedempDev is null      
----   set @mRedempDev = 0        
      
 
----  Update #OutTran      
----  set TranAmt = dbo.fnReksaSetRounding(@pnProdId,3, cast(@mTotalUnit * @mLastNAV as decimal(25,13)))                  
----   , RedempUnit = @mRedempUnit       
----   , RedempDev = @mRedempDev      
----  where TranId = @nTranId      
      
----  update #OutTran
----  set IsHitung = 0
----  where TranId = @nTranId   
  
----  update #OutTran
----  set IsHitung = 1
----  where TranId = @nTranId   
----	and TglEfektif <= @dCurrWorkingDate          
 
----end
          
      
----close tran_cur      
----deallocate tran_cur      
      
----insert dbo.ReksaCalcMaintenanceFeeDetail_TM (ClientId, ValueDate, ProdId, TranId, TranType, TranDate, TranCCY, TranUnit, SaldoUnit, TranAmt,
----		NAV, TglEfektif, Deviden, IsHitung, ProcessDate )	 	
----select @pnClientId, @pdValueDate, @pnProdId, TranId, TranType, TranDate, TranCCY, TranUnit, SaldoUnit, TranAmt,
----		NAV, TglEfektif, Deviden, IsHitung, getdate()
----from #OutTran
--if @pbDebug = 1 
--begin
--select top 1 @pnClientId as ClientId, @pdValueDate as ValueDate, @pnProdId as ProdId, TranId, TranType, TranDate, TranCCY, TranUnit, TranAmt,
--		NAV, TglEfektif, Deviden, IsHitung, UnitBalance
--from #OutTran
--where TglEfektif <= @dCurrWorkingDate
----20130226, liliana, BATOY12006, begin 
----order by TglEfektif desc
--order by TranDate desc
----20130226, liliana, BATOY12006, end
--end
----20130401, liliana, BATOY12006, begin

--Update #OutTran        
--set IsHitung = 1        
--where TranType in (1,2,8) 
--	and TglEfektif <= @dCurrWorkingDate            
        
--if not exists(select top 1 1 from #OutTran where IsHitung = 1)        
--begin         
-- delete from #OutTran
--end
----20130401, liliana, BATOY12006, end

--insert dbo.ReksaCalcMaintenanceFeeDetail_TM (ClientId, ValueDate, ProdId, TranId, TranType, TranDate, TranCCY, TranUnit, SaldoUnit, TranAmt,
--		NAV, TglEfektif, Deviden, IsHitung, ProcessDate )	 	
--select top 1 @pnClientId, @pdValueDate, @pnProdId, TranId, TranType, TranDate, TranCCY, TranUnit, UnitBalance, TranAmt,
--		NAV, TglEfektif, Deviden, IsHitung, getdate()
--from #OutTran
--where TglEfektif <= @dCurrWorkingDate 
----20130226, liliana, BATOY12006, begin 
----order by TglEfektif desc
--order by TranDate desc
----20130226, liliana, BATOY12006, end
----20130215, liliana, BATOY12006, end   	
declare @cErrMsg   varchar(100)        
  , @nOK     int        
  , @nErrNo     int            
  , @dCurrWorkingDate  datetime                
  , @nMonthPeriod   int  
  , @dTglEfektif   datetime  
  , @dJoinDate    datetime  
  , @uGuid     uniqueidentifier  
  , @cProdCCY    char(3)  
  , @dOutstandingTotal  decimal(25,13)
  
set @nOK = 0  
  
  
create table #OutTran2 (             
 TanggalTransaksi   datetime,  
 KeteranganTransaksi   varchar(50),  
 DebetNom     decimal(25,13), 
 KreditNom     decimal(25,13),
 Fee       decimal(25,13),
 SaldoNom     decimal(25,13), 
 NAV       decimal(25,13),
 UnitBalance    decimal(25,13), 
 Operator     varchar(50),  
 Checker      varchar(50),  
 TranType     int  
)        
  
create table #OutHitung (   
 Seq       int identity(1,1),            
 TanggalTransaksi   datetime,  
 KeteranganTransaksi   varchar(50),  
 DebetNom     decimal(25,13),  
 KreditNom     decimal(25,13),  
 Fee       decimal(25,13),  
 SaldoNom     decimal(25,13),  
 NAV       decimal(25,13),  
 UnitBalance     decimal(25,13),  
 Operator     varchar(50),  
 Checker      varchar(50),  
 TranType     int,  
 TranUnit     decimal(25,13),  
 TranAmt      decimal(25,13)  
)            
     
select @dCurrWorkingDate = current_working_date        
from dbo.control_table   
  
select @cProdCCY = ProdCCY   
from dbo.ReksaProduct_TM  
where ProdId = @pnProdId  
  
select @dJoinDate = JoinDate 
from dbo.ReksaCIFData_TM  
where ClientId = @pnClientId  
  
--cari period efektif maintenance fee  
select @nMonthPeriod = isnull(PeriodEfektifMFee, 0)  
from dbo.ReksaParamFee_TM   
where ProdId = @pnProdId  
 and TrxType = 'MFEE'    
  
set @uGuid = newid()  
  
--ambil outstanding dari sp ReksaPopulateAktivitas  
insert #OutTran2 (TanggalTransaksi, KeteranganTransaksi, DebetNom, KreditNom, Fee, SaldoNom, NAV, UnitBalance, Operator, Checker)  
exec ReksaPopulateAktivitas @pnClientId, @dJoinDate, @dCurrWorkingDate, 0, 777, @uGuid, 1, 1  
       
update ot  
set TranType = rtt.TranType  
from #OutTran2 ot  
join dbo.ReksaTransType_TR rtt  
 on rtt.TranDesc = ot.KeteranganTransaksi  
  
update #OutTran2  
set TranType = 9  
where KeteranganTransaksi = 'Switch In'  
  
update #OutTran2  
set TranType = 10  
where KeteranganTransaksi = 'Switch Out'  
  
update #OutTran2  
set TranType = 11  
where KeteranganTransaksi = 'Switch Out All'  
  
if @pbDebug = 1   
begin  
 print 'select all data'  
 select *  
 from #OutTran2  
end  
  
--ambil yg data sudah efektif saja (bagian yg kredit)  
select ot.TanggalTransaksi, ot.KeteranganTransaksi, convert(decimal(25,13),ot.DebetNom) as DebetNom, convert(decimal(25,13),ot.KreditNom) as KreditNom,   
  convert(decimal(25,13),ot.Fee) as Fee, convert(decimal(25,13),ot.SaldoNom) as SaldoNom,   
  convert(decimal(25,13),ot.NAV) as NAV, convert(decimal(25,13),ot.UnitBalance) as UnitBalance,   
  ot.Operator, ot.Checker  
    , ot.TranType, convert(decimal(25,13),0) as TranUnit  
    , dateadd(dd,1,dateadd(mm, @nMonthPeriod, ot.TanggalTransaksi)) as TanggalEfektif
into #OutTranKredit  
from #OutTran2 ot  
where ot.DebetNom = convert(decimal(25,13),0)  
 and ot.KreditNom > convert(decimal(25,13),0) 
 
delete  #OutTranKredit
where TanggalEfektif > @pdValueDate
  
update #OutTranKredit  
set TranUnit = convert(decimal(25,13),KreditNom / NAV)  
  
if @pbDebug = 1   
begin  
 print 'select data kredit efektif'  
 select *  
 from #OutTranKredit  
end  
  
--ambil yg data bagian yg debet  
select ot.TanggalTransaksi, ot.KeteranganTransaksi, convert(decimal(25,13),ot.DebetNom) as DebetNom, convert(decimal(25,13),ot.KreditNom) as KreditNom,   
  convert(decimal(25,13),ot.Fee) as Fee, convert(decimal(25,13),ot.SaldoNom) as SaldoNom,   
  convert(decimal(25,13),ot.NAV) as NAV, convert(decimal(25,13),ot.UnitBalance) as UnitBalance,   
  ot.Operator, ot.Checker  
    , ot.TranType, convert(decimal(25,13),0) as TranUnit  
into #OutTranDebet  
from #OutTran2 ot  
where ot.DebetNom > convert(decimal(25,13),0)  
 and ot.KreditNom = convert(decimal(25,13),0)  
  
update #OutTranDebet  
set TranUnit = convert(decimal(25,13), (DebetNom / NAV) * -1)  
  
if @pbDebug = 1   
begin  
 print 'select data debet efektif'  
 select *  
 from #OutTranDebet  
end  
  
insert #OutHitung (TanggalTransaksi, KeteranganTransaksi, DebetNom, KreditNom, Fee, SaldoNom, NAV, UnitBalance, Operator, Checker, TranType, TranUnit, TranAmt)  
select TanggalTransaksi, KeteranganTransaksi, DebetNom, KreditNom, Fee, SaldoNom, NAV, UnitBalance, Operator, Checker  
  , TranType, TranUnit, KreditNom  
from  #OutTranKredit  
union all  
select TanggalTransaksi, KeteranganTransaksi, DebetNom, KreditNom, Fee, SaldoNom, NAV, UnitBalance, Operator, Checker  
  , TranType, TranUnit, DebetNom  
from  #OutTranDebet  
order by TanggalTransaksi  
  
if @pbDebug = 1   
begin  
 print 'select data akhir'  
 select *  
 from #OutHitung  
end  
  
select @dOutstandingTotal = sum(TranUnit)  
from #OutHitung

if @pbDebug = 1   
begin 
	print 'select outstanding total sebelum dicek minusnya'  
	select @dOutstandingTotal  
end

if(@dOutstandingTotal <= 0)
begin
	delete from #OutHitung
end

if @pbDebug = 1   
begin 
	print 'select outstanding total setelah dicek minusnya'  
	select sum(TranUnit)  
	from #OutHitung  
end
  
insert dbo.ReksaCalcMaintenanceFeeDetail_TM (ClientId, ValueDate, ProdId, TranId, TranType, TranDate, TranCCY, TranUnit, SaldoUnit, TranAmt,  
  NAV, TglEfektif, Deviden, IsHitung, ProcessDate )     
select @pnClientId, @pdValueDate, @pnProdId, 0, TranType, TanggalTransaksi,  @cProdCCY, TranUnit, UnitBalance, TranAmt,   
  NAV, @dTglEfektif, 0, 1, getdate()  
from #OutHitung    
  
drop table #OutHitung  
drop table #OutTranKredit  
drop table #OutTranDebet  
drop table #OutTran2  
--20130408, liliana, BATOY12006, end

ERROR:
if isnull(@cErrMsg, '') <> ''
begin
	if @@trancount > 0 rollback tran
	raiserror (@cErrMsg,16,1);
	set @nOK = 1
end

return @nOK
GO