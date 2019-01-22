CREATE proc [dbo].[ReksaProcessCalculateBalance]    
/*    
 CREATED BY    : victor    
 CREATION DATE : 20071102    
 DESCRIPTION   : Untuk Menghitung kembali oustanding unit dan nominal berdasarkan transaksiyang dilakukan     
     hari itu    
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
  20071122, indra_w, REKSADN002, penambahan field full amount    
  20071130, indra_w, REKSADN002,  - fee dari subscription tidak boleh diubah    
          - perbaikan nominal berubah karena pembulatan    
  20071205, indra_w, REKSADN002, musti berurutan    
  20071207, indra_w, REKSADN002, perbaikan, cek yang null    
  20071210, indra_w, REKSADN002, perbaikan buat BILL    
  20071217, indra_w, REKSADN002, perbaikan UAT    
  20080402, indra_w, REKSADN002, FSD    
  20080414, mutiara, REKSADN002, perubahan tipe data dan penggunaan fungsi ReksaSetRounding    
  20080415, indra_w, REKSADN002, siapin data redemption Fee    
  20080416, indra_w, REKSADN002, fee untuk cabang pemilik rekening      
  20090723, oscar, REKSADN013, biar bisa check-in       
  20090828, oscar, REKSADN013, biar bisa check-in    
  20090904, oscar, REKSADN013, utk REKSADN015 tambah reguler subscription    
  20111021, liliana, BAALN10012, redempt fee = 0 utk partial maturity    
  20120502, liliana, LOGAM02012, order by diganti menjadi trandate. agar berurutan sesuai dengan jam input    
  20121022, liliana, BAALN11003, perbaikan perhitungan agar deviden juga dihitung ulang    
  20130107, liliana, BATOY12006, pembagian redemp fee based ke 5 GL  
  20130131, liliana, BATOY12006, perbaikan  
  20130131, liliana, BATOY12006, auto redemp tidak kena fee  
  20130227, liliana, BATOY12006, perbaikan split fee  
  20130322, liliana, BATOY12006, penambahan jika ada edit fee redemp  
  20130402, liliana, BATOY12006, selisih fee dimasukkan ke pendapatan cabang  
  20130418, liliana, BATOY12006, perbaikan  
  20140313, liliana, LIBST13021, jika rdb redemp otomatis
 END REVISED    
    
 exec dbo.ReksaProcessCalculateBalance    
*/    
as    
    
create table #temp    
(    
 TranId       int,    
 TranType      tinyint,    
 ProdId       int,    
--20080414, mutiara, REKSADN002, begin    
-- TranAmt       money,    
-- TranUnit      money,    
 TranAmt       decimal(25,13),    
 TranUnit      decimal(25,13),    
 ClientId      int,    
 ByUnit       bit,    
--20071207, indra_w, REKSADN002, begin    
-- NAV        decimal(20,10),    
 NAV        decimal(25,13),    
--20071207, indra_w, REKSADN002, end    
-- Deviden       float,    
-- Kurs       money    
 Deviden       decimal(25,13),    
 Kurs       decimal(25,13)    
--20071122, indra_w, REKSADN002, begin    
 , FullAmount     bit    
--20071122, indra_w, REKSADN002, end     
--20071207, indra_w, REKSADN002, begin    
-- , SubcFee      money    
-- , SubcFeeBased     money    
 , SubcFee      decimal(25,13)    
 , SubcFeeBased     decimal(25,13)    
--20071207, indra_w, REKSADN002, end    
--20080414, mutiara, REKSADN002, end  
--20130322, liliana, BATOY12006, begin      
, IsFeeEdit    bit      
, IsByPercent   bit      
, PercentageFeeInput decimal(25,13)      
--20130322, liliana, BATOY12006, end  
)    
    
set nocount on    
    
declare @cErrMsg     varchar(100),    
  @nOK      tinyint,    
  @nErrNo      int,    
  @bError      bit,    
  @dCurrDate     datetime,    
  @dCurrWorkingDate   datetime,    
  @nTranId     int,    
  @nTranType     tinyint,    
  @nProdId     int,    
--20080414, mutiara, REKSADN002, begin    
--  @mTranAmt     money,    
--  @mTranUnit     money,    
  @mTranAmt     decimal(25,13),    
  @mTranUnit     decimal(25,13),    
  @nClientId     int,    
  @bByUnit     bit,    
--20071207, indra_w, REKSADN002, begin    
--  @mNAV      decimal(20,10),    
  @mNAV      decimal(25,13),    
--20071207, indra_w, REKSADN002, end    
--  @mKurs      money,    
--  @nDeviden     float,    
--  @mUnitBalance    money,    
--  @mUnitBalanceNom   money,    
--  @mLastUnitBalance   money,    
  @mKurs      decimal(25,13),    
  @nDeviden     decimal(25,13),    
  @mUnitBalance    decimal(25,13),    
  @mUnitBalanceNom   decimal(25,13),    
  @mLastUnitBalance   decimal(25,13),    
--20071130, indra_w, REKSADN002, begin    
--  @mLastNominal    money,    
  @mLastNominal    decimal(25,13),    
--20071130, indra_w, REKSADN002, end    
--  @mFee      money,    
--  @mFeeBased     money,    
  @mFee      decimal(25,13),    
  @mFeeBased     decimal(25,13),    
--20130107, liliana, BATOY12006, begin  
  @mTaxFeeBased  decimal(25,13),    
  @mFeeBased3  decimal(25,13),    
  @mFeeBased4  decimal(25,13),    
  @mFeeBased5  decimal(25,13),    
--20130107, liliana, BATOY12006, end    
  @dTranDate     datetime,    
  @nBillId     int,    
--  @mEffBal     money,    
  @mEffBal     decimal(25,13),    
  @nUserSuid     int    
--20071122, indra_w, REKSADN002, begin    
  , @bFullAmount    bit    
--20071122, indra_w, REKSADN002, end    
--20071205, indra_w, REKSADN002, begin    
--  , @mRedempUnit    money    
--  , @mRedempDev    money    
  , @mRedempUnit    decimal(25,13)    
  , @mRedempDev    decimal(25,13)    
--20071207, indra_w, REKSADN002, begin    
--  , @mRedempNom    money     
--  , @mSubcFee     money    
--  , @mSubcFeeBased   money              
  , @mRedempNom    decimal(25,13)     
  , @mSubcFee     decimal(25,13)    
  , @mSubcFeeBased   decimal(25,13)          
--20080414, mutiara, REKSADN002, end        
--20071205, indra_w, REKSADN002, end    
--20071207, indra_w, REKSADN002, end    
--20071217, indra_w, REKSADN002, begin    
  , @nCalcId     int    
--20071217, indra_w, REKSADN002, end  
--20130322, liliana, BATOY12006, begin          
 , @pbIsByPercent bit      
 , @bIsByPercent  bit      
 , @pbIsFeeEdit   bit      
 , @bIsFeeEdit    bit      
 , @pdPercentageFeeInput  decimal(25,13)      
 , @dPercentageFeeInput    decimal(25,13)      
 , @pdPercentageFeeOutput decimal(25,13)      
 , @dPercentageFeeOutput   decimal(25,13)          
--20130322, liliana, BATOY12006, end  
--20130402, liliana, BATOY12006, begin  
 , @mTotalFeeBased   decimal(25,13)   
 , @mSelisihFeeBased  decimal(25,13)   
--20130402, liliana, BATOY12006, end       
    
set @nOK = 0    
set @bError = 0    
    
exec @nOK = set_usersuid @nUserSuid output      
if @nOK != 0 or @@error != 0 return 1      
    
exec @nOK = cek_process_table @nProcID = @@procid       
if @nOK != 0 or @@error != 0 return 1      
    
exec @nOK = set_process_table @@procid, null, @nUserSuid, 1      
if @nOK != 0 or @@error != 0 return 1      
    
select @dCurrDate = current_working_date    
from control_table    
    
select @dCurrWorkingDate = current_working_date    
 , @dTranDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate())     
from fnGetWorkingDate()    
    
If @dCurrDate < @dCurrWorkingDate    
Begin    
 exec @nOK = set_process_table @@procid, null, @nUserSuid, 0      
 if @nOK != 0 or @@error != 0 return 1    
    
 return 0    
End    
    
    
insert #temp    
--20071205, indra_w, REKSADN002, begin    
--select a.TranId, a.TranType, a.ProdId, a.TranAmt, a.TranUnit, a.ClientId, a.ByUnit, b.NAV, b.Deviden, b.Kurs    
--20130322, liliana, BATOY12006, begin       
--select a.TranId, a.TranType, a.ProdId, isnull(a.TranAmt, 0), isnull(a.TranUnit, 0), a.ClientId, a.ByUnit, b.NAV, b.Deviden, b.Kurs        
  select a.TranId, a.TranType, a.ProdId, isnull(a.TranAmt, 0), isnull(a.TranUnit, 0), a.ClientId, a.ByUnit, b.NAV, b.Deviden, b.Kurs    
--20130322, liliana, BATOY12006, end   
--20071122, indra_w, REKSADN002, begin    
--20071207, indra_w, REKSADN002, begin    
 , isnull(a.FullAmount,0), a.SubcFee, a.SubcFeeBased    
--20071207, indra_w, REKSADN002, end    
--20071122, indra_w, REKSADN002, end    
--20071205, indra_w, REKSADN002, end  
--20130402, liliana, BATOY12006, begin    
,a.IsFeeEdit, a.JenisPerhitunganFee ,a.PercentageFee    
--20130402, liliana, BATOY12006, end     
from dbo.ReksaTransaction_TT a join ReksaNAVParam_TH b    
  on a.ProdId = b.ProdId    
   and a.NAVValueDate = b.ValueDate    
where a.CheckerSuid is not null    
--20090828, oscar, REKSADN013, begin    
--20090904, oscar, REKSADN013, begin    
-- and a.TranType in (1, 2, 3, 4)    
 and a.TranType in (1, 2, 3, 4, 8)    
--20090904, oscar, REKSADN013, end        
--20090828, oscar, REKSADN013, end    
 and a.NAVValueDate = @dCurrWorkingDate    
 and a.ProcessDate is null    
 and a.Status = 1    
--20120502, liliana, LOGAM02012, begin    
order by a.TranDate    
--20120502, liliana, LOGAM02012, end     
    
declare crs cursor    
--20071122, indra_w, REKSADN002, begin    
for select TranId, TranType, ProdId, TranAmt, TranUnit, ClientId, ByUnit, NAV, Deviden, Kurs, FullAmount    
--20071122, indra_w, REKSADN002, end    
--20071207, indra_w, REKSADN002, begin    
  , SubcFee, SubcFeeBased    
--20071207, indra_w, REKSADN002, end  
--20130322, liliana, BATOY12006, begin     
  ,IsFeeEdit  ,IsByPercent ,PercentageFeeInput    
--20130322, liliana, BATOY12006, end    
from #temp    
--20120502, liliana, LOGAM02012, begin    
--order by TranId    
--20120502, liliana, LOGAM02012, end    
    
open crs    
    
while 1 = 1    
begin    
 fetch crs into @nTranId, @nTranType, @nProdId, @mTranAmt, @mTranUnit, @nClientId, @bByUnit    
--20071122, indra_w, REKSADN002, begin    
--20071207, indra_w, REKSADN002, begin    
  , @mNAV, @nDeviden, @mKurs, @bFullAmount, @mSubcFee, @mSubcFeeBased    
--20071207, indra_w, REKSADN002, end    
--20071122, indra_w, REKSADN002, end  
--20130322, liliana, BATOY12006, begin  
--20130418, liliana, BATOY12006, begin   
 --,@bIsFeeEdit, @pbIsByPercent, @pdPercentageFeeInput  
 ,@bIsFeeEdit, @bIsByPercent, @pdPercentageFeeInput  
--20130418, liliana, BATOY12006, end    
--20130322, liliana, BATOY12006, end    
 if @@fetch_status != 0 break    
    
--20071207, indra_w, REKSADN002, begin    
 set @mFee = 0    
 set @mFeeBased  = 0    
 set @mRedempUnit = 0    
 set @mRedempDev = 0    
--20071207, indra_w, REKSADN002, end    
--20071217, indra_w, REKSADN002, begin    
 set @nCalcId = 0  
--20130402, liliana, BATOY12006, begin    
set @dPercentageFeeInput = 0    
set @dPercentageFeeInput = @pdPercentageFeeInput    
--20130402, liliana, BATOY12006, end      
    
 select @nCalcId = CalcId    
 from ReksaProduct_TM     
 where ProdId = @nProdId    
    
 if @nCalcId = 0    
 Begin    
  Set @bError = 1    
  GOTO ERROR    
 End    
--20071217, indra_w, REKSADN002, end    
--20080402, indra_w, REKSADN002, begin    
 if @nTranType = 4    
  set @bByUnit = 1    
--20080402, indra_w, REKSADN002, end    
 -- hitung unit dan nominal dari transaksi    
 if @bByUnit = 1    
 begin    
--20071122, indra_w, REKSADN002, begin     
  If @nTranType in (3,4)    
  Begin    
   If @nTranType = 4    
--20071205, indra_w, REKSADN002, begin    
--    select @mUnitBalance =  UnitBalance    
    select @mUnitBalance =  isnull(UnitBalance, 0)    
--20071205, indra_w, REKSADN002, end    
    from ReksaCIFData_TM    
    where ClientId = @nClientId      
   else    
    set @mUnitBalance = @mTranUnit    
  End    
--20090904, oscar, REKSADN013, begin    
  --Else If @nTranType in (1,2)    
  Else If @nTranType in (1,2,8)    
--20090904, oscar, REKSADN013, end    
  Begin    
   set @mUnitBalance = @mTranUnit     
  End    
--20071122, indra_w, REKSADN002, end    
--20080414, mutiara, REKSADN002, begin    
--  set @mUnitBalanceNom = @mUnitBalance * @mNAV    
  set @mUnitBalanceNom = dbo.fnReksaSetRounding(@nProdId,3,@mUnitBalance * @mNAV)    
--20080414, mutiara, REKSADN002, end    
 end    
 else    
 begin    
  -- case jika transaksi redemp dengan nominal, tau2 NAV anjlok, nilai transaksi diset ke yang paling kecil    
  If @nTranType in (3,4)    
  Begin    
   select @mEffBal = dbo.fnGetEffUnit(@nClientId)    
    
   if @mTranAmt > @mEffBal * @mNAV    
--20080414, mutiara, REKSADN002, begin    
--    set @mTranAmt = @mEffBal * @mNAV    
    set @mTranAmt = dbo.fnReksaSetRounding(@nProdId,3,@mEffBal * @mNAV)    
--20080414, mutiara, REKSADN002, end    
  End    
    
  set @mUnitBalanceNom = @mTranAmt    
--20080414, mutiara, REKSADN002, begin    
--  set @mUnitBalance = @mTranAmt / @mNAV    
  set @mUnitBalance = dbo.fnReksaSetRounding(@nProdId,2,@mTranAmt / @mNAV)    
--20080414, mutiara, REKSADN002, end    
 end    
    
 -- hitung fee dan fee based dari transaksi      
--20071207, indra_w, REKSADN002, begin    
--20071217, indra_w, REKSADN002, begin    
 Begin Tran    
  If @nTranType in (3,4)    
  Begin    
   exec @nOK = ReksaCalcFee    
    @pnProdId   = @nProdId    
    ,@pnClientId  = @nClientId    
    ,@pnTranType  = @nTranType    
    ,@pmTranAmt   = @mUnitBalanceNom    
    ,@pmUnit   = @mUnitBalance    
    ,@pcFeeCCY   = ''    
    ,@pnFee    = @mFee output    
    ,@pnNIK    = 7    
    ,@pcGuid   = ''    
    ,@pmNAV    = @mNAV  
--20130322, liliana, BATOY12006, begin      
  , @pbFullAmount   = @bFullAmount          
  , @pbIsByPercent = @bIsByPercent          
  , @pbIsFeeEdit   = @bIsFeeEdit          
  , @pdPercentageFeeInput  = @dPercentageFeeInput          
  , @pdPercentageFeeOutput = @dPercentageFeeOutput     output             
--20130322, liliana, BATOY12006, end          
    ,@pbProcess   = 1  -- diisi 1 jika proses    
    ,@pmFeeBased  = @mFeeBased output    
--20071205, indra_w, REKSADN002, begin    
    ,@pmRedempUnit  = @mRedempUnit output    
    ,@pmRedempDev  = @mRedempDev output    
--20071205, indra_w, REKSADN002, end    
    , @pbByUnit   = @bByUnit    
    , @pmProcessTranId = @nTranId     
    , @pmErrMsg   = @cErrMsg output    
    , @pnOutType  = 1    
--20130107, liliana, BATOY12006, begin  
    , @pmTaxFeeBased = @mTaxFeeBased output        
    , @pmFeeBased3 = @mFeeBased3  output     
    , @pmFeeBased4 = @mFeeBased4  output     
    , @pmFeeBased5 = @mFeeBased5  output    
--20130107, liliana, BATOY12006, end      
    
   If @nOK != 0 or @@error!= 0 or isnull(@cErrMsg, '') != ''    
   Begin    
    Set @bError = 1    
--20071205, indra_w, REKSADN002, begin    
 --  GOTO NEXT    
    GOTO ERROR    
--20071205, indra_w, REKSADN002, end    
   End    
  End      
--20071207, indra_w, REKSADN002, end    
    
--20071122, indra_w, REKSADN002, begin    
--20090904, oscar, REKSADN013, begin    
  --if @nTranType in (1,2)    
  if @nTranType in (1,2,8)    
--20090904, oscar, REKSADN013, end    
  Begin    
   If @bFullAmount = 0    
   Begin    
--20071207, indra_w, REKSADN002, begin    
    set @mUnitBalanceNom = @mUnitBalanceNom - isnull(@mSubcFee,0)    
--20071207, indra_w, REKSADN002, end    
--20080414, mutiara, REKSADN002, begin    
--    set @mUnitBalance = @mUnitBalanceNom / @mNAV     
    set @mUnitBalance = dbo.fnReksaSetRounding(@nProdId,2,@mUnitBalanceNom / @mNAV)     
--20080414, mutiara, REKSADN002, end    
   end    
  End    
--20071122, indra_w, REKSADN002, end    
    
 -- hitung saldo akhir akibat transaksi tanpa deviden    
--20071130, indra_w, REKSADN002, begin    
  select @mLastUnitBalance = UnitBalance    
    ,@mLastNominal = UnitNominal    
  from ReksaCIFData_TM    
  where ClientId = @nClientId    
    
--20071205, indra_w, REKSADN002, begin    
--20090904, oscar, REKSADN013, begin    
  --select @mLastUnitBalance = isnull(@mLastUnitBalance, 0) + case when @nTranType in(1,2) then @mUnitBalance    
  select @mLastUnitBalance = isnull(@mLastUnitBalance, 0) + case when @nTranType in(1,2,8) then @mUnitBalance    
--20090904, oscar, REKSADN013, end    
               when @nTranType in(3,4) then -@mUnitBalance    
              end    
    
--20090904, oscar, REKSADN013, begin    
--  select @mLastNominal = isnull(@mLastNominal, 0) + case when @nTranType in(1,2) then @mUnitBalanceNom    
  select @mLastNominal = isnull(@mLastNominal, 0) + case when @nTranType in(1,2,8) then @mUnitBalanceNom    
--20090904, oscar, REKSADN013, end    
               when @nTranType in(3,4) then -@mUnitBalanceNom    
              end    
--20071205, indra_w, REKSADN002, end    
--20071130, indra_w, REKSADN002, end  
--20130402, liliana, BATOY12006, begin  
if @nTranType in (3,4)   
begin  
 select @mTotalFeeBased = isnull(@mFeeBased,0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0) + isnull(@mFeeBased4,0) + isnull(@mFeeBased5,0)  
   
 select @mSelisihFeeBased = isnull(@mFee,0) - isnull(@mTotalFeeBased,0)  
   
 select @mFeeBased = isnull(@mFeeBased,0) + isnull(@mSelisihFeeBased, 0)  
  
end  
--20130402, liliana, BATOY12006, end    
    
  update dbo.ReksaTransaction_TT    
--20071207, indra_w, REKSADN002, begin    
  set TranAmt = case when @nTranType in (3,4) then @mUnitBalanceNom else TranAmt end    
--20071207, indra_w, REKSADN002, end    
   , TranUnit = @mUnitBalance    
--20071130, indra_w, REKSADN002, begin    
--20090904, oscar, REKSADN013, begin    
   --, SubcFee = case when @nTranType in (1,2) then SubcFee else 0 end    
   , SubcFee = case when @nTranType in (1,2,8) then SubcFee else 0 end    
--20090904, oscar, REKSADN013, end    
--20071207, indra_w, REKSADN002, begin    
   , RedempFee = case when @nTranType in (3,4) then isnull(@mFee,0) else 0 end    
--20090904, oscar, REKSADN013, begin    
   --, SubcFeeBased = case when @nTranType in (1,2) then SubcFeeBased else 0 end     
   , SubcFeeBased = case when @nTranType in (1,2,8) then SubcFeeBased else 0 end     
--20090904, oscar, REKSADN013, end    
   , RedempFeeBased = case when @nTranType in (3,4) then isnull(@mFeeBased,0) else 0 end    
--20071207, indra_w, REKSADN002, end    
--20130131, liliana, BATOY12006, begin  
--20130227, liliana, BATOY12006, begin  
  --, TaxFeeBased = case when @nTranType in (3,4) then isnull(@mTaxFeeBased,0) else 0 end  
  --, FeeBased3 = case when @nTranType in (3,4) then isnull(@mFeeBased3,0) else 0 end    
  --, FeeBased4 = case when @nTranType in (3,4) then isnull(@mFeeBased4,0) else 0 end    
  --, FeeBased5 = case when @nTranType in (3,4) then isnull(@mFeeBased5,0) else 0 end  
  , TaxFeeBased = case when @nTranType in (3,4) then isnull(@mTaxFeeBased,0) else TaxFeeBased end  
  , FeeBased3 = case when @nTranType in (3,4) then isnull(@mFeeBased3,0) else FeeBased3 end    
  , FeeBased4 = case when @nTranType in (3,4) then isnull(@mFeeBased4,0) else FeeBased4 end    
  , FeeBased5 = case when @nTranType in (3,4) then isnull(@mFeeBased5,0) else FeeBased5 end    
--20130227, liliana, BATOY12006, end        
  , TotalRedempFeeBased = case when @nTranType in (3,4) then isnull(@mFee,0) else 0 end  
--20130131, liliana, BATOY12006, end  
   , NAV = @mNAV    
   , Kurs = @mKurs    
   , UnitBalance = @mLastUnitBalance    
--   , UnitBalanceNom = @mLastUnitBalance * @mNAV    
   , UnitBalanceNom = @mLastNominal    
--20071130, indra_w, REKSADN002, end    
   , ProcessDate = @dTranDate    
   , RedempUnit = @mRedempUnit    
   , RedempDev = @mRedempDev    
  where TranId = @nTranId    
--20111021, liliana, BAALN10012, begin    
    
  update dbo.ReksaTransaction_TT     
  set RedempFee = 0    
--20130107, liliana, BATOY12006, begin  
   ,RedempFeeBased = 0  
--20130107, liliana, BATOY12006, end  
--20130131, liliana, BATOY12006, begin  
  , TaxFeeBased = 0  
  , FeeBased3 = 0  
  , FeeBased4 =0   
  , FeeBased5 = 0    
  , TotalRedempFeeBased =0  
--20130131, liliana, BATOY12006, end    
  where TranId = @nTranId and UserSuid = 7 and CheckerSuid = 777   
--20140313, liliana, LIBST13021, begin   
	and TranType in (4)
	and ExtStatus not in (10, 20)   
	and Channel not in ('INB','MB')
--20140313, liliana, LIBST13021, end	
--20111021, liliana, BAALN10012, end  
--20130107, liliana, BATOY12006, begin  
--20130131, liliana, BATOY12006, begin  
  --update dbo.ReksaTransaction_TT    
  --set TaxFeeBased = isnull(@mTaxFeeBased, 0),  
  -- FeeBased3 = isnull(@mFeeBased3, 0),  
  -- FeeBased4 = isnull(@mFeeBased4, 0),  
  -- FeeBased5 = isnull(@mFeeBased5, 0),  
  -- TotalRedempFeeBased = isnull(RedempFee, 0)  
  --where TranId = @nTranId    
  --and TranType in (3,4)  
  --and UserSuid != 7 and CheckerSuid != 777  
  --and ExtStatus not in (10, 20)  
--20130131, liliana, BATOY12006, end    
--20130107, liliana, BATOY12006, end         
    
  If @nOK != 0 or @@error!= 0    
  Begin    
   Set @bError = 1    
--20071205, indra_w, REKSADN002, begin    
--   GOTO NEXT    
   GOTO ERROR    
--20071205, indra_w, REKSADN002, end    
  End    
    
--20071205, indra_w, REKSADN002, begin    
--20080414, mutiara, REKSADN002, begin    
--  set @mRedempNom = @mRedempUnit * @mNAV    
  set @mRedempNom = dbo.fnReksaSetRounding(@nProdId,3,@mRedempUnit * @mNAV)    
--20080414, mutiara, REKSADN002, end    
--20071205, indra_w, REKSADN002, end    
    
  update dbo.ReksaCIFData_TM    
  set UnitBalance =@mLastUnitBalance    
--20071205, indra_w, REKSADN002, begin    
--   ,UnitNominal = @mLastUnitBalance * @mNAV    
   ,UnitNominal = @mLastNominal    
--20071207, indra_w, REKSADN002, begin      
--20090723, oscar, REKSADN013, begin    
--   ,SubcUnit = case when @nCalcId not != 2 then    
--20121022, liliana, BAALN11003, begin    
   --,SubcUnit = case when @nCalcId not in  (2,5) then    
   ,SubcUnit =     
--20121022, liliana, BAALN11003, end    
--20090723, oscar, REKSADN013, end    
--20090904, oscar, REKSADN013, begin    
       --case when isnull(SubcUnit, 0) + case when @nTranType in (1,2) then @mUnitBalance     
       case when isnull(SubcUnit, 0) + case when @nTranType in (1,2,8) then @mUnitBalance     
--20090904, oscar, REKSADN013, end    
--20071207, indra_w, REKSADN002, end    
--             else -@mUnitBalance     
--20071207, indra_w, REKSADN002, begin    
              when @nTranType = 4 then -SubcUnit    
--20071207, indra_w, REKSADN002, end    
             else -@mRedempUnit     
           end < 0     
         then 0    
--20090904, oscar, REKSADN013, begin    
        --else isnull(SubcUnit, 0) + case when @nTranType in (1,2) then @mUnitBalance     
        else isnull(SubcUnit, 0) + case when @nTranType in (1,2,8) then @mUnitBalance     
--20090904, oscar, REKSADN013, end    
--            else -@mUnitBalance     
--20071207, indra_w, REKSADN002, begin    
             when @nTranType = 4 then -SubcUnit    
--20071207, indra_w, REKSADN002, end    
            else -@mRedempUnit     
           end    
       end    
--20071207, indra_w, REKSADN002, begin    
--20121022, liliana, BAALN11003, begin    
      --else @mLastUnitBalance    
      --end    
--20121022, liliana, BAALN11003, end    
--20090723, oscar, REKSADN013, begin    
--   ,SubcNominal = case when @nCalcId != 2 then    
--20121022, liliana, BAALN11003, begin    
   --,SubcNominal = case when @nCalcId not in (2,5) then    
   ,SubcNominal =     
--20121022, liliana, BAALN11003, end    
--20090723, oscar, REKSADN013, end    
--20090904, oscar, REKSADN013, begin    
        --case when isnull(SubcNominal, 0)  + case when @nTranType in (1,2) then @mUnitBalanceNom     
        case when isnull(SubcNominal, 0)  + case when @nTranType in (1,2,8) then @mUnitBalanceNom     
--20090904, oscar, REKSADN013, end    
--20071207, indra_w, REKSADN002, end    
--             else -@mUnitBalanceNom     
--20071207, indra_w, REKSADN002, begin    
              when @nTranType = 4 then -SubcNominal    
--20071207, indra_w, REKSADN002, end    
             else -@mRedempNom     
            end < 0     
         then 0    
--20090904, oscar, REKSADN013, begin    
         --else isnull(SubcNominal, 0) + case when @nTranType in (1,2) then @mUnitBalanceNom     
         else isnull(SubcNominal, 0) + case when @nTranType in (1,2,8) then @mUnitBalanceNom     
--20090904, oscar, REKSADN013, end    
--              else -@mUnitBalanceNom     
--20071207, indra_w, REKSADN002, begin    
               when @nTranType = 4 then -SubcNominal    
--20071207, indra_w, REKSADN002, end    
              else -@mRedempNom     
             end    
        end    
--20071205, indra_w, REKSADN002, end    
--20121022, liliana, BAALN11003, begin    
       --else @mLastNominal    
       --end    
--20121022, liliana, BAALN11003, end    
--20090904, oscar, REKSADN013, begin    
   --,ProtekLastUnit = case when isnull(ProtekLastUnit, 0) + case when @nTranType in (1,2) then @mUnitBalance     
   ,ProtekLastUnit = case when isnull(ProtekLastUnit, 0) + case when @nTranType in (1,2,8) then @mUnitBalance     
--20090904, oscar, REKSADN013, end    
              when @nTranType = 4 then -ProtekLastUnit    
             else -@mRedempUnit     
           end < 0     
        then 0    
--20090904, oscar, REKSADN013, begin    
       --else isnull(ProtekLastUnit, 0) + case when @nTranType in (1,2) then @mUnitBalance     
       else isnull(ProtekLastUnit, 0) + case when @nTranType in (1,2,8) then @mUnitBalance     
--20090904, oscar, REKSADN013, end    
             when @nTranType = 4 then -ProtekLastUnit    
            else -@mRedempUnit     
           end    
      end    
--20090904, oscar, REKSADN013, begin    
   --,ProtekLastNom = case when isnull(ProtekLastNom, 0)  + case when @nTranType in (1,2) then @mUnitBalanceNom     
   ,ProtekLastNom = case when isnull(ProtekLastNom, 0)  + case when @nTranType in (1,2,8) then @mUnitBalanceNom     
--20090904, oscar, REKSADN013, end    
              when @nTranType = 4 then -ProtekLastNom    
             else -@mRedempNom     
            end < 0     
        then 0    
--20090904, oscar, REKSADN013, begin    
        --else isnull(ProtekLastNom, 0) + case when @nTranType in (1,2) then @mUnitBalanceNom     
        else isnull(ProtekLastNom, 0) + case when @nTranType in (1,2,8) then @mUnitBalanceNom     
--20090904, oscar, REKSADN013, end    
               when @nTranType = 4 then -ProtekLastNom    
              else -@mRedempNom     
             end    
       end    
  where ClientId = @nClientId    
    
  If @nOK != 0 or @@error!= 0    
  Begin    
   Set @bError = 1    
--20071205, indra_w, REKSADN002, begin    
--   GOTO NEXT    
   GOTO ERROR    
--20071205, indra_w, REKSADN002, end    
  End    
 Commit tran    
 continue    
--20071217, indra_w, REKSADN002, end    
 NEXT:    
  if @@trancount > 0     
   rollback tran    
end    
    
close crs    
deallocate crs    
    
drop table #temp    
    
If @bError = 1    
 Goto ERROR    
--20080402, indra_w, REKSADN002, begin    
/*    
-- rebalance Bill transaksi    
create table #TempBill(    
 BillId  int    
 , TotalBill money    
 , Fee  money    
 , FeeBased money    
)    
    
insert #TempBill    
--20071210, indra_w, REKSADN002, begin    
--select isnull(BillId,0), sum(isnull(TranAmt,0)), sum(isnull(RedempFee,0)), sum(isnull(RedempFeeBased,0))    
select isnull(BillId,0)    
 , sum(case when TranCCY = 'IDR' then round(isnull(TranAmt,0),0) else round(isnull(TranAmt,0),2) end )    
 , sum(case when TranCCY = 'IDR' then round(isnull(RedempFee,0),0) else round(isnull(RedempFee,0),2) end )    
 , sum(case when TranCCY = 'IDR' then round(isnull(RedempFeeBased,0),0) else round(isnull(RedempFeeBased,0),2) end )    
--20071210, indra_w, REKSADN002, end    
from ReksaTransaction_TT     
--20071210, indra_w, REKSADN002, begin    
where isnull(BillId,0) != 0    
 and Status = 1    
 and TranType in (3,4)    
--20071210, indra_w, REKSADN002, end    
group by BillId    
    
if @@error != 0    
Begin    
 set @cErrMsg = 'Error Prepare data Bill'    
 goto ERROR    
End    
    
update a     
--20071210, indra_w, REKSADN002, begin    
--set TotalBill = b.TotalBill    
set TotalBill = b.TotalBill - (b.Fee - b.FeeBased)    
--20071210, indra_w, REKSADN002, end    
 , Fee  = b.Fee    
 , FeeBased = b.FeeBased    
from ReksaBill_TM a join #TempBill b    
 on a.BillId = b.BillId    
where a.BillType = 2    
    
if @@error != 0    
Begin    
 set @cErrMsg = 'Error Update data Bill'    
 goto ERROR    
End    
*/    
--20080402, indra_w, REKSADN002, end    
--20080415, indra_w, REKSADN002, begin    
-- pindahkan fee2 ke table yang berbeda    
delete a    
from ReksaRedempFee_TM a join ReksaTransaction_TT b    
 on a.TranId = b.TranId    
where b.NAVValueDate = @dCurrWorkingDate    
    
if @@error != 0    
Begin    
 set @cErrMsg = 'Error Clear Table Fee'    
 goto ERROR    
End    
    
--20080416, indra_w, REKSADN002, begin    
insert ReksaRedempFee_TM (MainBillId, BillId, AgentId, ClientId, TranId, TransactionDate, ValueDate, ProdId    
--20130107, liliana, BATOY12006, begin  
  ,TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130107, liliana, BATOY12006, end  
  , CCY, Fee, FeeBased, Settled, SettleDate, Type, UserSuid, CheckerSuid)    
select a.BillId, null, b.AgentId, a.ClientId, a.TranId, a.TranDate, a.NAVValueDate, a.ProdId    
--20130107, liliana, BATOY12006, begin  
  ,a.TaxFeeBased, a.FeeBased3, a.FeeBased4, a.FeeBased5, a.TotalRedempFeeBased  
--20130107, liliana, BATOY12006, end  
  , a.TranCCY, a.RedempFee, a.RedempFeeBased, 0, null, 1, null, null    
from ReksaTransaction_TT a join ReksaCIFData_TM b    
 on a.ClientId = b.ClientId    
where a.RedempFee > 0    
 and a.NAVValueDate = @dCurrWorkingDate    
 and a.ProcessDate is not null    
 and a.Status = 1    
 and a.TranType in (3,4)    
--20080416, indra_w, REKSADN002, end    
    
if @@error != 0    
Begin    
 set @cErrMsg = 'Error Insert Table Fee'    
 goto ERROR    
End    
--20080415, indra_w, REKSADN002, end    
exec @nOK = set_process_table @@procid, null, @nUserSuid, 0      
if @nOK != 0 or @@error != 0 return 1    
    
return 0    
    
ERROR:    
If @@trancount > 0     
 rollback tran    
    
drop table #temp    
    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Unknown Error !'    
    
exec @nOK = set_process_table @@procid, null, @nUserSuid, 2      
if @nOK != 0 or @@error != 0 return 1    
    
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK != 0 return 1      
      
raiserror (@cErrMsg    ,16,1)
return 1
GO