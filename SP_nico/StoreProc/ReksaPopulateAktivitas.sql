
CREATE proc [dbo].[ReksaPopulateAktivitas]    
/*    
 CREATED BY    : indra    
 CREATION DATE : 20071017    
 DESCRIPTION   : Populate aktifitas rekening reksadana  per lient    
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
  20071127, indra_w, REKSADN002, Ambil dari table History    
  20071209, indra_w, REKSADN002, perbaikan    
  20071218, indra_w, REKSADN002, perbaikan UAT    
  20080414, mutiara, REKSADN002, perubahan tipe data dan penggunaan fungsi ReksaSetRounding    
  20080415, indra_w, REKSADN002, tambahan    
  20080722, indra_w, REKSADN006, tambah separator        
  20090723, oscar, REKSADN013, buat check in    
  20090915, oscar, REKSADN013, utk REKSADN015 tambah reguler subscription    
  20090916, oscar, REKSADN013, utk REKSADN015 perbaikan UAT    
  20100203, oscar, REKSADN014, ubah @nDeviden menjadi decimal(23, 15)    
  20111216, liliana, BAALN11008, tambah keterangan switch in dan switch out  
  20120119, liliana, BAALN11008, bedakan switch out all dan switch out  
  20120208, liliana, BAALN11008, tampilkan switching fee  
  20120209, liliana, BAALN11008, switch fee di trx switch out  
  20130408, liliana, BATOY12006, tambah parameter baru utk perhitungan maintenance fee by period  
  20131106, liliana, BAALN11010, tambah channel
  20140918, liliana, LIBST13021, tambah utk status berhenti
  20150724, liliana, LIBST13020, tambah kolom
  20150811, liliana, LIBST13020, perubahan kolom Kredit Nom
  20151027, liliana, LIBST13020, swc in rdb
  20170517, liliana, BOSOD17090, convert to decimal
 END REVISED    
*/    
 @pnClientId   int  -- Kode Client    
 ,@pdStartDate  datetime  -- tanggal mulai    
 ,@pdEndDate   datetime  -- tanggal akhir yang mo dilihat    
 ,@pbIsBalance  bit    -- apakah liat balance atau transaksi    
 ,@pnNIK    int    -- NIK user    
 ,@pcGuid   varchar(50)  -- Guid client    
--20071127, indra_w, REKSADN002, begin    
 ,@pbAktivitasOnly bit   = 0    
--20071127, indra_w, REKSADN002, end    
--20130408, liliana, BATOY12006, begin  
 ,@isMFee   bit = 0 -- apakah perhitungan maintenance fee ? jika tidak isi 0, jika ya isi 1  
--20130408, liliana, BATOY12006, end  
as    
    
set nocount on    
    
declare @cErrMsg   varchar(100)    
  , @nOK    int    
  , @nErrNo   int    
  , @nProdId   int    
  , @bDeviden   bit    
  , @nSequence  int    
  , @nLastSeq   int    
  , @dFirstTran  datetime    
--20071209, indra_w, REKSADN002, begin    
--20080414, mutiara, REKSADN002, begin    
--  , @mNAV    money    
--  , @mLastNAV   money    
  , @mNAV    decimal(25,13)    
  , @mLastNAV   decimal(25,13)    
--20071209, indra_w, REKSADN002, end    
--  , @mLastNominal  money    
--  , @mCurrNominal  money    
--  , @mLastTranNom  money    
--  , @mSaldoUnit  money    
--  , @mSaldoNom  money    
--  , @nDeviden   float    
--  , @mUnitBal   money    
--  , @mUnitBalCurr  money    
  , @mLastNominal  decimal(25,13)    
  , @mCurrNominal  decimal(25,13)    
  , @mLastTranNom  decimal(25,13)    
  , @mSaldoUnit  decimal(25,13)    
  , @mSaldoNom  decimal(25,13)    
--20100203, oscar, REKSADN014, begin    
  --, @nDeviden   decimal(25,13)    
  , @nDeviden   decimal(23,15)    
--20100203, oscar, REKSADN014, end    
  , @mUnitBal   decimal(25,13)    
  , @mUnitBalCurr  decimal(25,13)    
  , @nType   bit    
  , @bByAnum   bit    
--  , @nPercen   float    
--  , @nDays   float    
--  , @mEffBal   money    
  , @nPercen   decimal(25,13)    
  , @nDays   decimal(25,13)    
  , @mEffBal   decimal(25,13)    
  , @cCalcId   int    
--20080414, mutiara, REKSADN002, end    
--20071209, indra_w, REKSADN002, begin    
Create table #TempActivity(    
 Sequence   int  identity(1,1)    
--20071209, indra_w, REKSADN002, begin    
--20080414, mutiara, REKSADN002, begin    
-- , NAV    decimal(20,10)    
 , NAV    decimal(25,13)    
--20071209, indra_w, REKSADN002, end    
-- , Deviden   float    
--20100203, oscar, REKSADN014, begin    
 --, Deviden   decimal(25,13)    
 , Deviden   decimal(23,15)    
--20100203, oscar, REKSADN014, end    
 , TglTran   datetime    
 , Description  varchar(30)    
-- , Debet    money    
-- , Kredit   money    
-- , Fee    money    
-- , Saldo    money    
-- , UnitBal   money    
 , Debet    decimal(25,13)    
 , Kredit   decimal(25,13)    
 , Fee    decimal(25,13)    
 , Saldo    decimal(25,13)   
--20150724, liliana, LIBST13020, begin
 , TranUnit decimal(25,13)    
--20150724, liliana, LIBST13020, end  
, UnitBal   decimal(25,13)    
 , UserSuid   int    
 , CheckerSuid  int    
 , Operator   char(15)    
 , Checker   char(15)    
 , Type    tinyint    
-- , Mutasi   money    
 , Mutasi   decimal(25,13)    
--20080414, mutiara, REKSADN002, end    
 , ProdId   int    
 , TranId   int  
--20120208, liliana, BAALN11008, begin  
 , TranCode varchar(20)  
--20120208, liliana, BAALN11008, end 
--20131106, liliana, BAALN11010, begin
 , Channel  varchar(100)
--20131106, liliana, BAALN11010, end    
)    
    
-- Ambil tanggal sebelum tanggal mulai biar dapat dicari saldo awal     
select top 1 @dFirstTran = convert(datetime, convert(char(8), TranDate, 112))    
--20071127, indra_w, REKSADN002, begin    
--from ReksaTransaction_TT    
from ReksaTransaction_TH    
--20071127, indra_w, REKSADN002, end    
where ClientId = @pnClientId    
-- and convert(datetime, convert(char(8),TranDate, 112)) <= @pdStartDate    
order by TranId asc    
    
    
--select top 1 @dFirstTran = convert(datetime, convert(char(8), TranDate, 112))    
--from ReksaTransaction_TH    
--where ClientId = @pnClientId    
-- and convert(datetime, convert(char(8),TranDate, 112)) > @pdStartDate    
--order by TranId desc    
    
-- jika tidak ada tanggal awal, berarti tanggal transaksi pertama > tanggal mulai    
If @dFirstTran is NULL    
Begin    
 select top 1 @dFirstTran = convert(datetime, convert(char(8), TranDate, 112))    
--20071127, indra_w, REKSADN002, begin    
 from ReksaTransaction_TT    
-- from ReksaTransaction_TH    
--20071127, indra_w, REKSADN002, end    
 where ClientId = @pnClientId    
 order by TranId asc    
    
End    
    
select @bByAnum =  c.IsAnnual    
 , @nDays = case when c.IsAnnual = 1 then c.TotDays    
     else 1    
    end    
 , @nPercen = case when c.Percentage = 1 then 100    
      else 1    
    end    
 , @nProdId = b.ProdId    
 , @cCalcId = b.CalcId    
from ReksaCIFData_TM a join ReksaProduct_TM b    
  on a.ProdId = b.ProdId    
 join ReksaDevidenCalc_TR c    
  on b.CalcId = c.CalcId    
where a.ClientId = @pnClientId    
    
If @pbIsBalance = 1    
Begin    
--20071218, indra_w, REKSADN002, begin    
--20120208, liliana, BAALN11008, begin  
 --insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId)  
 insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId  
 ,TranCode  
--20150724, liliana, LIBST13020, begin
 , TranUnit    
--20150724, liliana, LIBST13020, end   
 )  
--20120208, liliana, BAALN11008, end     
--20071218, indra_w, REKSADN002, end    
 select a.ValueDate, a.NAV, a.Deviden    
  , case when b.TranDate is not null then isnull(c.TranDesc,'UnKnown')    
    else 'System Generate'    
   end    
--20090915, oscar, REKSADN013, begin       
  --, case when b.TranType in (1,2,5) then isnull(b.TranAmt,0) -- isnull(b.SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(b.TranAmt,0) -- isnull(b.SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then 0    
    else 0    
   end as 'Kredit'    
--20090915, oscar, REKSADN013, begin       
  --, case when b.TranType in (1,2,5) then 0    
  , case when b.TranType in (1,2,5,8) then 0    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(b.TranAmt,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Debet'    
--20071218, indra_w, REKSADN002, begin     
--20090915, oscar, REKSADN013, begin       
  --, case when b.TranType in (1,2,5) then isnull(SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(RedempFee,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Fee'    
--20071218, indra_w, REKSADN002, end    
  , isnull(b.UnitBalanceNom,0), isnull(b.UnitBalance,0), b.UserSuid, b.CheckerSuid    
  , case when b.TranId is not null then 0 else 1 end    
  , a.ProdId    
  , b.TranId    
--20071127, indra_w, REKSADN002, begin   
--20120208, liliana, BAALN11008, begin  
  , b.TranCode  
--20120208, liliana, BAALN11008, end 
--20150724, liliana, LIBST13020, begin
 , b.TranUnit    
--20150724, liliana, LIBST13020, end     
--From ReksaNAVParam_TH a  with (nolock) full join ReksaTransaction_TT b  with (nolock)    
 From ReksaNAVParam_TH a  with (nolock) left join ReksaTransaction_TH b  with (nolock)     
--20071127, indra_w, REKSADN002, end    
   on a.ValueDate = convert(datetime, convert(char(8), b.NAVValueDate, 112))    
    and b.ClientId = @pnClientId    
--    and b.ProcessDate is not NULL    
    and Status = 1    
    and b.CheckerSuid is not null    
    and a.ValueDate >= @dFirstTran    
    and a.ValueDate < dateadd(dd,1,@pdEndDate)    
  left join ReksaTransType_TR c with (nolock)     
   on b.TranType = c.TranType    
 where a.ProdId = @nProdId    
   and a.ValueDate >= @dFirstTran    
    and a.ValueDate < dateadd(dd,1,@pdEndDate)    
 union all    
 select a.ValueDate, a.NAV, a.Deviden    
  , case when b.TranDate is not null then isnull(c.TranDesc,'UnKnown')    
    else 'System Generate'    
   end    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(b.TranAmt,0) -- isnull(b.SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(b.TranAmt,0) -- isnull(b.SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then 0    
    else 0    
   end as 'Kredit'    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then 0    
  , case when b.TranType in (1,2,5,8) then 0    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(b.TranAmt,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Debet'    
--20071218, indra_w, REKSADN002, begin    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(RedempFee,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Fee'    
--20071218, indra_w, REKSADN002, end    
  , isnull(b.UnitBalanceNom,0), isnull(b.UnitBalance,0), b.UserSuid, b.CheckerSuid    
  , case when b.TranId is not null then 0 else 1 end    
  , a.ProdId    
  , b.TranId  
--20120208, liliana, BAALN11008, begin  
  , b.TranCode  
--20120208, liliana, BAALN11008, end 
--20150724, liliana, LIBST13020, begin
 , b.TranUnit    
--20150724, liliana, LIBST13020, end      
 From ReksaNAVParam_TH a  with (nolock) left join ReksaTransaction_TT b  with (nolock)     
   on a.ValueDate = convert(datetime, convert(char(8), b.NAVValueDate, 112))    
    and b.ClientId = @pnClientId    
--    and b.ProcessDate is not NULL    
    and b.Status = 1    
    and b.CheckerSuid is not null    
    and a.ValueDate >= @dFirstTran    
    and a.ValueDate < dateadd(dd,1,@pdEndDate)    
  left join ReksaTransType_TR c with (nolock)     
   on b.TranType = c.TranType    
 where a.ProdId = @nProdId    
   and a.ValueDate >= @dFirstTran    
   and a.ValueDate < dateadd(dd,1,@pdEndDate)    
   and b.ProcessDate is not Null    
 order by a.ValueDate, b.TranId    
    
 set @nSequence  = 0    
 set @mNAV   = 0    
 set @mLastNAV  = 0    
 set @nDeviden  = 0    
 set @mUnitBal  = 0    
 set @mUnitBalCurr = 0    
 set @nType = 1    
    
 declare actv_cur cursor local fast_forward for     
  select Sequence, NAV, Deviden, UnitBal, Type    
  from #TempActivity    
  order by Sequence    
    
 open actv_cur     
    
 while 1=1    
 begin    
  fetch actv_cur into @nSequence, @mNAV, @nDeviden, @mUnitBal, @nType    
  if @@fetch_status!=0     
  Begin    
   update #TempActivity    
   set Description = case when Description = 'System Generate' then 'Balance' else Description end    
    , Type = 2    
   where Sequence = @nLastSeq    
    
   break    
  End     
      
  set @mSaldoUnit = 0    
  set @mSaldoNom = 0    
    
  If @nType = 1    
  Begin    
   -- hitung unit akhir dari deviden dulu    
 --  If @bByAnum = 0    
 --   set @mSaldoUnit = @mUnitBalCurr + ((@nDeviden * @mUnitBalCurr)/@mNAV)    
 --  else     
        
   -- bedakan antara yang biasa ama yang proteksi    
--20090723, oscar, REKSADN013, begin    
   If @cCalcId in (2,5) -- kalo proteksi    
--20090723, oscar, REKSADN013, end    
   Begin    
--20080414, mutiara, REKSADN002, begin    
--    set @mSaldoUnit = @mUnitBalCurr - ((((@nDeviden/@nPercen)*(@mUnitBalCurr*@mNAV))/ 365.00)/@mNAV)    
--20080415, indra_w, REKSADN002, begin    
--    set @mSaldoUnit = @mUnitBalCurr - dbo.fnReksaSetRounding(@nProdId,2,((((@nDeviden/@nPercen)*(@mUnitBalCurr*@mNAV))/ 365.00)/@mNAV))    
    set @mSaldoUnit = @mUnitBalCurr - dbo.fnReksaSetRounding(@nProdId,2,cast(cast(cast(cast(@nDeviden/@nPercen as decimal(25,13))*cast(@mUnitBalCurr*@mNAV as decimal(25,13)) as decimal(25,13))/ 365.00 as decimal(25,13))/@mNAV as decimal(25,13)))    
--20080415, indra_w, REKSADN002, end    
--20080414, mutiara, REKSADN002, end    
   End    
   Else    
   Begin    
--20080414, mutiara, REKSADN002, begin    
--    set @mSaldoUnit = @mUnitBalCurr + ((((@nDeviden/@nPercen) * @mUnitBalCurr)/@mNAV)/@nDays)    
--20080415, indra_w, REKSADN002, begin    
--    set @mSaldoUnit = @mUnitBalCurr + dbo.fnReksaSetRounding(@nProdId,2,((((@nDeviden/@nPercen) * @mUnitBalCurr)/@mNAV)/@nDays))    
    set @mSaldoUnit = @mUnitBalCurr + dbo.fnReksaSetRounding(@nProdId,2,cast(cast(cast(cast(@nDeviden/@nPercen as decimal(25,13)) * @mUnitBalCurr as decimal(25,13))/@mNAV as decimal(25,13))/@nDays as decimal(25,13)))    
--20080415, indra_w, REKSADN002, end    
--20080414, mutiara, REKSADN002, end    
   End    
--20080414, mutiara, REKSADN002, begin    
--   set @mLastNominal = (@mUnitBalCurr * @mLastNAV)    
--   set @mCurrNominal = (@mSaldoUnit * @mNAV)    
   set @mLastNominal = dbo.fnReksaSetRounding(@nProdId,3,(@mUnitBalCurr * @mLastNAV))    
   set @mCurrNominal = dbo.fnReksaSetRounding(@nProdId,3,(@mSaldoUnit * @mNAV))    
--20080414, mutiara, REKSADN002, end    
   If @pbIsBalance = 0     
   Begin    
    select @mSaldoNom = @mCurrNominal - @mLastTranNom    
   End    
   Else    
   Begin    
    select @mSaldoNom = @mCurrNominal - @mLastNominal    
   End    
    
   update #TempActivity    
   set Kredit  = case when @mSaldoNom >= 0 then @mSaldoNom    
         else 0     
        end    
    , Debet  = case when @mSaldoNom <= 0  then @mSaldoNom     
         else 0     
       end    
--20080414, mutiara, REKSADN002, begin    
--    , Saldo  = @mSaldoUnit * @mNAV    
    , Saldo  = dbo.fnReksaSetRounding(@nProdId,3,@mSaldoUnit * @mNAV)    
--20080414, mutiara, REKSADN002, end    
    , UnitBal = @mSaldoUnit    
    , Fee  = 0    
    , Operator = case when Type = 1 then 'System' else NULL end    
    , Checker = case when Type = 1 then 'System' else NULL end    
    , Mutasi = @mSaldoNom    
   where Sequence = @nSequence    
    
   set @mUnitBalCurr = @mSaldoUnit    
  End    
  Else    
  Begin    
   set @mUnitBalCurr = @mUnitBal    
--20080414, mutiara, REKSADN002, begin    
--   set @mLastTranNom = @mUnitBal * @mNAV    
   set @mLastTranNom =dbo.fnReksaSetRounding(@nProdId,3, @mUnitBal * @mNAV)    
--20080414, mutiara, REKSADN002, end    
  End    
  set @nLastSeq = @nSequence    
  set @mLastNAV = @mNAV    
 end    
    
 close actv_cur    
 deallocate actv_cur    
end    
else    
Begin    
--20071218, indra_w, REKSADN002, begin    
--20090915, oscar, REKSADN013, begin    
 --insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId)  
--20120208, liliana, BAALN11008, begin     
 --insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId)  
insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId  
  , TranCode  
--20150724, liliana, LIBST13020, begin
 , TranUnit    
--20150724, liliana, LIBST13020, end    
 )  
--20120208, liliana, BAALN11008, end     
--20090915, oscar, REKSADN013, end    
--20071218, indra_w, REKSADN002, end    
 select a.NAVValueDate, a.NAV, 0, b.TranDesc    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(a.TranAmt,0) -- isnull(b.SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(a.TranAmt,0) -- isnull(b.SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then 0    
    else 0    
   end as 'Kredit'    
--20090915, oscar, REKSADN013, begin   
  --, case when b.TranType in (1,2,5) then 0    
  , case when b.TranType in (1,2,5,8) then 0    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(a.TranAmt,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Debet'    
--20071218, indra_w, REKSADN002, begin    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(RedempFee,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Fee'    
--20071218, indra_w, REKSADN002, end    
  , a.UnitBalanceNom, a.UnitBalance, a.UserSuid, a.CheckerSuid, 0, a.ProdId    
--20090915, oscar, REKSADN013, begin    
  , a.TranId    
--20090915, oscar, REKSADN013, end    
--20120208, liliana, BAALN11008, begin  
  , a.TranCode     
--20120208, liliana, BAALN11008, end
--20150724, liliana, LIBST13020, begin
 , a.TranUnit    
--20150724, liliana, LIBST13020, end    
 from ReksaTransaction_TH a left join ReksaTransType_TR b with (nolock)     
   on a.TranType = b.TranType    
 where a.ClientId = @pnClientId    
  and a.Status = 1    
--20071218, indra_w, REKSADN002, begin    
  and a.NAVValueDate >= @pdStartDate    
  and a.NAVValueDate < dateadd(dd, 1, @pdEndDate)    
--20071218, indra_w, REKSADN002, end    
 order by a.TranId    
--20071218, indra_w, REKSADN002, begin    
--20090915, oscar, REKSADN013, begin    
 --insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId)  
--20120208, liliana, BAALN11008, begin     
 --insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId)  
 insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Fee, Saldo, UnitBal, UserSuid, CheckerSuid, Type, ProdId, TranId  
 , TranCode  
--20150724, liliana, LIBST13020, begin
 , TranUnit    
--20150724, liliana, LIBST13020, end   
 )  
--20120208, liliana, BAALN11008, end     
--20090915, oscar, REKSADN013, end    
--20071218, indra_w, REKSADN002, end    
 select a.NAVValueDate, a.NAV, 0, b.TranDesc    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(a.TranAmt,0) -- isnull(b.SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(a.TranAmt,0) -- isnull(b.SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then 0    
    else 0    
   end as 'Kredit'    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then 0    
  , case when b.TranType in (1,2,5,8) then 0    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(a.TranAmt,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Debet'    
--20071218, indra_w, REKSADN002, begin    
--20090915, oscar, REKSADN013, begin    
  --, case when b.TranType in (1,2,5) then isnull(SubcFee,0)    
  , case when b.TranType in (1,2,5,8) then isnull(SubcFee,0)    
--20090915, oscar, REKSADN013, end    
    when b.TranType in (3,4,6) then isnull(RedempFee,0) -- isnull(b.RedempFee,0)    
    else 0    
   end as 'Fee'    
--20071218, indra_w, REKSADN002, end    
  , a.UnitBalanceNom, a.UnitBalance, a.UserSuid, a.CheckerSuid, 0, a.ProdId    
--20090915, oscar, REKSADN013, begin    
  , a.TranId    
--20090915, oscar, REKSADN013, end  
--20120208, liliana, BAALN11008, begin  
  , a.TranCode  
--20120208, liliana, BAALN11008, end 
--20150724, liliana, LIBST13020, begin
 , a.TranUnit    
--20150724, liliana, LIBST13020, end     
 from ReksaTransaction_TT a left join ReksaTransType_TR b with (nolock)     
   on a.TranType = b.TranType    
 where a.ClientId = @pnClientId    
  and a.Status = 1    
  and a.ProcessDate is not null    
--20071218, indra_w, REKSADN002, begin    
  and a.NAVValueDate >= @pdStartDate    
  and a.NAVValueDate < dateadd(dd, 1, @pdEndDate)    
--20071218, indra_w, REKSADN002, end    
 order by a.TranId    
End    
  
--20111216, liliana, BAALN11008, begin  
update ta  
set Description = 'Switch Out'  
from #TempActivity ta join dbo.ReksaTransaction_TT tt  
on ta.TranId = tt.TranId  
--20120119, liliana, BAALN11008, begin  
--and tt.TranType in (3,4) and ExtStatus = 10  
and tt.TranType = 3 and ExtStatus = 10  
--20120119, liliana, BAALN11008, end  
  
update ta  
set Description = 'Switch Out'  
from #TempActivity ta join dbo.ReksaTransaction_TH tt  
on ta.TranId = tt.TranId  
--20120119, liliana, BAALN11008, begin  
--and tt.TranType in (3,4) and ExtStatus = 10  
and tt.TranType = 3 and ExtStatus = 10  
  
update ta  
set Description = 'Switch Out All'  
from #TempActivity ta join dbo.ReksaTransaction_TT tt  
on ta.TranId = tt.TranId  
and tt.TranType = 4 and ExtStatus = 10  
  
update ta  
set Description = 'Switch Out All'  
from #TempActivity ta join dbo.ReksaTransaction_TH tt  
on ta.TranId = tt.TranId  
and tt.TranType = 4 and ExtStatus = 10  
--20120119, liliana, BAALN11008, end  
  
update ta  
set Description = 'Switch In'  
from #TempActivity ta join dbo.ReksaTransaction_TT tt  
on ta.TranId = tt.TranId  
and tt.TranType in (1, 2) and ExtStatus = 20  
  
update ta  
set Description = 'Switch In'  
from #TempActivity ta join dbo.ReksaTransaction_TH tt  
on ta.TranId = tt.TranId  
and tt.TranType in (1, 2) and ExtStatus = 20  
  
--20111216, liliana, BAALN11008, end  
--20120208, liliana, BAALN11008, begin  
--20151027, liliana, LIBST13020, begin

update ta  
set Description = 'Switch In'  
from #TempActivity ta join dbo.ReksaTransaction_TT tt  
on ta.TranId = tt.TranId  
and tt.TranType in (8) and ExtStatus = 20  
  
update ta  
set Description = 'Switch In'  
from #TempActivity ta join dbo.ReksaTransaction_TH tt  
on ta.TranId = tt.TranId  
and tt.TranType in (8) and ExtStatus = 20  
  
--20151027, liliana, LIBST13020, end
update ta  
set Fee = isnull(rs.ActualSwitchingFee, 0)  
from #TempActivity ta join dbo.ReksaSwitchingTransaction_TM rs  
 on ta.TranCode = rs.TranCode   
--20120209, liliana, BAALN11008, begin   
--where ta.Description = 'Switch In'  
where ta.Description in ('Switch Out','Switch Out All')  
--20120209, liliana, BAALN11008, end  
  
--20120208, liliana, BAALN11008, end 
Update a    
set Operator = isnull(b.name, 'UnKnown')    
 , Checker = isnull(c.name, 'UnKnown')
from #TempActivity  a left join user_nisp_v b     
  on a.UserSuid = b.nik    
 left join user_nisp_v c   
--20150724, liliana, LIBST13020, begin   
  --on a.UserSuid = c.nik  
  on a.CheckerSuid = c.nik   
--20150724, liliana, LIBST13020, end  
where a.Type = 0    
--20090915, oscar, REKSADN013, begin    
--reg subs pengen jadi new/add (rese bener nih user!&^&*!^)    
--20090916, oscar, REKSADN013, begin    
--update a    
--set Description = 'Subscription New'    
--from #TempActivity a    
--join ReksaRegulerSubscriptionSchedule_TT b    
-- on a.TranId = b.TranId    
     
--update a    
--set Description = 'Subscription Add'    
-- from #TempActivity a    
--join ReksaTransaction_TH b    
-- on a.TranId = b.TranId    
-- and b.TranType = 8    
--where a.Description = 'Reguler Subscription'    
--20090916, oscar, REKSADN013, end    
--20090915, oscar, REKSADN013, end
--20131106, liliana, BAALN11010, begin
update ta  
set Channel = rcl.ChannelDesc
from #TempActivity ta 
join dbo.ReksaTransaction_TT tt  
    on ta.TranId = tt.TranId  
join dbo.ReksaChannelList_TM rcl
    on rcl.ChannelCode = tt.Channel 

update ta  
set Channel = rcl.ChannelDesc
from #TempActivity ta 
join dbo.ReksaTransaction_TH tt  
    on ta.TranId = tt.TranId  
join dbo.ReksaChannelList_TM rcl
    on rcl.ChannelCode = tt.Channel 

--20131106, liliana, BAALN11010, end 
--20140918, liliana, LIBST13021, begin
--20150811, liliana, LIBST13020, begin
update ta  
set Kredit = tt.TranAmt - tt.SubcFee
from #TempActivity ta 
join dbo.ReksaTransaction_TT tt  
    on ta.TranId = tt.TranId  
where tt.TranType in (1,2)
    and isnull(tt.FullAmount,0) = 0 
    
update ta  
set Kredit = tt.TranAmt - tt.SubcFee
from #TempActivity ta 
join dbo.ReksaTransaction_TH tt  
    on ta.TranId = tt.TranId  
where tt.TranType in (1,2)
    and isnull(tt.FullAmount,0) = 0 
    
--20150811, liliana, LIBST13020, end
--berhenti
insert #TempActivity (TranId, Description, TglTran, Type)
select rs.TranId, 'Berhenti', min(rs.ScheduledDate), 0
from dbo.ReksaRegulerSubscriptionSchedule_TT rs
join dbo.ReksaTransaction_TT tt
    on tt.TranId = rs.TranId
where rs.ScheduledDate < dateadd(dd, 1, @pdEndDate)
     and rs.StatusId in (5)
     and tt.ClientId = @pnClientId  
group by rs.TranId
union all
select rs.TranId, 'Berhenti', min(rs.ScheduledDate), 0
from dbo.ReksaRegulerSubscriptionSchedule_TT rs
join dbo.ReksaTransaction_TH tt
    on tt.TranId = rs.TranId
where rs.ScheduledDate < dateadd(dd, 1, @pdEndDate)
     and rs.StatusId in (5)
     and tt.ClientId = @pnClientId  
group by rs.TranId          

--20140918, liliana, LIBST13021, end     
if @pbIsBalance = 1    
Begin    
 select TglTran as 'Tanggal Transaksi'    
  , Description as 'Keterangan Transaksi'         
--20080414, mutiara, REKSADN002, begin    
--20080722, indra_w, REKSADN006, begin    
  , convert(varchar(40),cast(Debet as money),1) as 'Debet Nom'    
  , convert(varchar(40),cast(Kredit as money),1) as 'Kredit Nom'    
  , convert(varchar(40),cast(Fee as money),1) as Fee     
  , convert(varchar(40),cast(Saldo as money),1)  'Saldo Nom'    
--20150811, liliana, LIBST13020, begin  
  --, convert(varchar(40),cast(NAV as money),1) as NAV   
  , convert(varchar(40),cast(NAV as money),2) as NAV   
--20150811, liliana, LIBST13020, end       
--20150724, liliana, LIBST13020, begin
  --, convert(varchar(40),cast(UnitBal as money),1) as 'Unit Balance' 
  , convert(varchar(40),cast(TranUnit as money),2) as 'Unit Transaction' 
  , convert(varchar(40),cast(UnitBal as money),2) as 'Unit Balance' 
--20150724, liliana, LIBST13020, end   
--20080722, indra_w, REKSADN006, end    
--20080414, mutiara, REKSADN002, end
--20131106, liliana, BAALN11010, begin
  , Channel as 'Channel Transaksi'
--20131106, liliana, BAALN11010, end      
  , Operator    
  , Checker    
 from #TempActivity    
 where (TglTran >= @pdStartDate -- buat ngefilter kalo yang cek balance, ngga ngefek ke yang transaksi    
  and (isnull(Debet,0) != 0 or isnull(Kredit,0) != 0 or isnull(Fee,0) != 0))    
  or Type = 2    
 order by Sequence    
End    
Else    
Begin    
 insert #TempActivity (TglTran, NAV, Deviden, Description, Kredit, Debet, Saldo, UnitBal    
   , Operator, Checker, Type, ProdId)    
    
 select NAVDate, NAV, 0, 'Balance'    
  , 0, 0, UnitNominal, UnitBalance, '', '', 0, ProdId    
 from ReksaCIFData_TM    
 where ClientId = @pnClientId    
  
--20130408, liliana, BATOY12006, begin  
if(@isMFee = 1)  
begin  
 select TglTran as 'Tanggal Transaksi'    
  , Description as 'Keterangan Transaksi'    
  , Debet as 'Debet Nom'    
  , Kredit as 'Kredit Nom'    
  , Fee  as Fee    
  , Saldo  as 'Saldo Nom'    
  , NAV  as NAV    
  , UnitBal  as 'Unit Balance'    
  , Operator    
  , Checker    
 from #TempActivity    
 where Type in (0,2)    
  and TglTran >= @pdStartDate     
  and TglTran < dateadd(dd, 1, @pdEndDate)     
 order by Sequence   
end  
else  
begin  
--20130408, liliana, BATOY12006, end    
 select TglTran as 'Tanggal Transaksi'    
  , Description as 'Keterangan Transaksi'    
--20080722, indra_w, REKSADN006, begin    
  , convert(varchar(40),cast(Debet as money),1) as 'Debet Nom'    
  , convert(varchar(40),cast(Kredit as money),1) as 'Kredit Nom'    
  , convert(varchar(40),cast(Fee as money),1) as Fee    
  , convert(varchar(40),cast(Saldo as money),1) as 'Saldo Nom'    
--20150811, liliana, LIBST13020, begin  
  --, convert(varchar(40),cast(NAV as money),1) as NAV   
--20170517, liliana, BOSOD17090, begin  
  --, convert(varchar(40),cast(NAV as money),2) as NAV   
  , convert(decimal(19,4),convert(varchar(40),cast(NAV as money),2)) as NAV   
--20170517, liliana, BOSOD17090, end  
--20150811, liliana, LIBST13020, end   
--20150724, liliana, LIBST13020, begin
  --, convert(varchar(40),cast(UnitBal as money),1) as 'Unit Balance' 
--20170517, liliana, BOSOD17090, begin  
  --, convert(varchar(40),cast(TranUnit as money),2) as 'Unit Transaction' 
  --, convert(varchar(40),cast(UnitBal as money),2) as 'Unit Balance'
    , convert(decimal(19,4),convert(varchar(40),cast(TranUnit as money),2)) as 'Unit Transaction' 
  , convert(decimal(19,4),convert(varchar(40),cast(UnitBal as money),2)) as 'Unit Balance'
--20170517, liliana, BOSOD17090, end   
--20150724, liliana, LIBST13020, end     
--20080722, indra_w, REKSADN006, end
--20131106, liliana, BAALN11010, begin
  , Channel as 'Channel Transaksi'
--20131106, liliana, BAALN11010, end      
  , Operator    
  , Checker    
 from #TempActivity    
 where Type in (0,2)    
  and TglTran >= @pdStartDate    
--20071218, indra_w, REKSADN002, begin    
  and TglTran < dateadd(dd, 1, @pdEndDate)    
--20071218, indra_w, REKSADN002, end    
 order by Sequence   
--20130408, liliana, BATOY12006, begin  
end  
--20130408, liliana, BATOY12006, end    
End    
    
--20071127, indra_w, REKSADN002, begin    
if @pbAktivitasOnly = 0    
Begin    
 select top 1 @mLastNAV = NAV    
 from ReksaNAVParam_TH    
 where ProdId = @nProdId    
 order by ValueDate desc    
    
 select @mEffBal = dbo.fnGetEffUnit(@pnClientId)    
--20071218, indra_w, REKSADN002, begin    
--20080414, mutiara, REKSADN002, begin    
-- select @mEffBal as EffBal , convert(money, @mEffBal * @mLastNAV) as NomBal    
 select @mEffBal as EffBal , dbo.fnReksaSetRounding(@nProdId,3,convert(money, @mEffBal * @mLastNAV)) as NomBal    
--20080414, mutiara, REKSADN002, end    
--20071218, indra_w, REKSADN002, end    
End    
--20071127, indra_w, REKSADN002, end    
--20071209, indra_w, REKSADN002, end    
return 0    
    
ERROR:    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Error !'    
    
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK != 0 return 1      
      
raiserror (@cErrMsg    ,16,1)
return 1
GO