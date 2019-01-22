CREATE proc [dbo].[ReksaProcessCEStart]    
/*    
 CREATED BY    : indra    
 CREATION DATE : 20071017    
 DESCRIPTION   : Pembukaan otomatis rekening reksadana close end    
     
 exec ReksaProcessCEStart 1    
     
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
  20071123, indra_w, REKSADN002, tambah kolom Full Amount    
  20071204, indra_w, REKSADN002, tambah block branch, dan dibuat tran hanya yang aktif    
  20071207, indra_w, REKSADN002, support idola    
  20071210, indra_w, REKSADN002, pindahin up front fee ke sini    
  20071218, indra_w, REKSADN002, perbaikan UAT    
  20080206, indra_w, REKSADN002, perbesar kolom address dan seragamin counter    
  20080216, indra_w, REKSADN002, simpan detail upfrontfee    
  20080217, indra_w, REKSADN002, tambah kolom outstanding    
  20080414, mutiara, REKSADN002, perubahan tipe data dan penggunaan fungsi ReksaSetRounding    
  20080415, indra_w, REKSADN002, tambahan    
  20080425, indra_w, REKSADN002, FSD perubahan data nasabah    
  20080508, indra_w, REKSADN002, report RDN27    
  20080609, indra_w, REKSADN006, fortis    
  20090723, oscar, REKSADN013, boleh booking satu CIF dgn beda no rek relasi asal masih satu cabang    
  20090723, oscar, REKSADN013, tambah inputter, seller, waperd    
  20090723, oscar, REKSADN013, bill cut off untuk close end    
  20090723, oscar, REKSADN013, tambah tgl efektif    
  20090723, oscar, REKSADN013, tambah blokir otomatis untuk transaksi booking yang blm approve    
  20090807, oscar, REKSADN013, perbaikan UAT, proses CE start u/ tgl efektif - 1    
  20090812, victor, REKSADN016, perubahan running number    
  20090812, oscar, REKSADN013, perbaikan UAT     
  20090813, oscar, REKSADN013, perbaikan UAT, tgl efektif saat proses batch akhir hari & otor booking otomatis    
  20090814, oscar, REKSADN013, otorisasi booking otomatis jalan trus kl error     
  20090821, victor, REKSADN016, perubahan running number    
  20091012, oscar, REKSADN013, saat buat bill pakai tgl next working date + 1    
  20091016, oscar, REKSADN013, remark REKSADN016    
  20091106, victor, REKSADN016, buka remarkan oscar    
  20100702, indra_w, BAING10033, proses juga Alamat konfirmasi    
  20111013, liliana, BAALN10012, penambahan untuk maturity      
  20111013, liliana, BAALN11009, centang dokumen  
  20111109, liliana, BAALN10011, Delete dari ReksaRejectBooking_TMP jika berhasil insert ke ReksaBooking_TH  
  20120717, dhanan, LOGAM02012, L4699 Perbaikan Centang Alamat Konfirmasi setelah Booking Efektif, debug helped by Roby SQ  
  20120718, liliana, BAALN12010, penambahan shareholder id (pembuatan master client lwt booking)  
  20121220, anthony, BARUS12010, tambah untuk npwp  
  20130107, liliana, BATOY12006, tambah kolom tax feebased , feebased3, feebased 4, feebased 5 fan upfrontfee  
  20130122, liliana, BATOY12006, perbaikan  
  20130205, anthony, BARUS12010, tambah kolom  
  20130220, liliana, BATOY12006, tambah kolom reksa bill  
  20130226, liliana, BATOY12006, perubahan perhitungan percentage fee  
  20130226, liliana, BATOY12006, perbaikan  
  20130328, liliana, BATOY12006, tambah pengecekan bill id  
  20130403, liliana, BATOY12006, selisih fee dimasukkan ke pendapatan cabang  
  20130418, liliana, BATOY12006, hitung ulang total fee based setelah ditambah selisih  
  20130612, anthony, LOGAM05399, fixbug  
  20130612, liliana, LOGAM05399, fixbug  
  20130618, liliana, BAFEM12011, tambah channel  
  20150130, liliana, LIBST13020, perubahan pembuatan Client Code  
  20150608, liliana, LIBST13020, rekening usd    
  20150617, liliana, LIBST13020, tambah kolom  
  20151026, liliana, LIBST13020, tambah kolom  
  20151027, liliana, LIBST13020, tambah kolom ReksaBooking_TH  
  20151104, liliana, LIBST13020, jika dana tdk cukup update checkersuid booking  
  20160830, liliana, LOGEN00196, tax amnesty
  20180910, sandi, LOGAM09694, penambahan kolom untuk result ReksaGetCIFData  
 END REVISED    
*/    
--20090723, oscar, REKSADN013, begin    
 @pbDebug bit = 0    
--20090723, oscar, REKSADN013, end    
as       
set nocount on    
    
declare @cErrMsg   varchar(100)    
  , @nOK    int    
  , @nErrNo   int    
  , @nUserSuid  int    
  , @dCurrDate  datetime    
--20090807, oscar, REKSADN013, begin    
  , @dPrevWorkingDate datetime    
--20090807, oscar, REKSADN013, end      
  , @dCurrWorkingDate datetime    
  , @dNextWorkingDate datetime    
  , @dTranDate  datetime    
  , @nProdId   int    
  , @cCIFNo   char(13)      
--20080414, mutiara, REKSADN002, begin     
--  , @mBookingAmt  money    
  , @mBookingAmt  decimal(25,13)    
--20080414, mutiara, REKSADN002, end    
  , @nIsEmployee  tinyint    
  , @nCIFNIK   int    
  , @nAgentId   int    
  , @nBankId   int    
  , @nAccountType  tinyint    
  , @cNISPAccId  varchar(19)    
  , @cNonNISPAccId varchar(50)    
  , @cNonNISPAccName varchar(50)    
  , @nReferentor  int    
  , @cClientCode  char(11)    
  , @cPFix   char(3)    
  , @cPrefix   char(3)    
  , @nCounter   int    
  , @nClientId  int    
  , @nBookingId  int    
--20071207, indra_w, REKSADN002, begin    
--20080414, mutiara, REKSADN002, begin    
--  , @mNAV    decimal(20,10)    
  , @mNAV    decimal(25,13)    
--20080414, mutiara, REKSADN002, end    
--20071207, indra_w, REKSADN002, end    
  , @cProdCCY   char(3)    
--20071204, indra_w, REKSADN002, begin    
  , @cBlockBranch  char(5)    
--20071204, indra_w, REKSADN002, end    
--20071210, indra_w, REKSADN002, begin    
  , @cPeriod   char(8)    
--20071210, indra_w, REKSADN002, end    
--20080216, indra_w, REKSADN002, begin    
  , @nBillId   int    
--20080216, indra_w, REKSADN002, end    
--20080425, indra_w, REKSADN002, begin    
 , @cIDTYPE  char(4)    
 , @cSEX   char(1)    
 , @cCTZSHIP  varchar(3)    
 , @cRELIGION varchar(3)    
 , @cSIBSCIFNo varchar(19)    
--20080425, indra_w, REKSADN002, end    
--20080508, indra_w, REKSADN002, begin    
 , @cCIFName  varchar(100)    
 , @cNISPAccName varchar(40)    
--20080508, indra_w, REKSADN002, end    
--20080609, indra_w, REKSADN006, begin    
 , @nManInvId int    
--20080609, indra_w, REKSADN006, end    
--20090723, oscar, REKSADN013, begin    
 , @nTranType int    
--20090723, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin    
 , @pcInputter varchar(40)    
 , @pnSeller  int    
 , @pnWaperd  int    
--20090723, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin   
--20111013, liliana, BAALN11009, begin  
 , @pbDocRiskProfile      bit  
 , @pbDocTermCondition    bit  
--20111013, liliana, BAALN11009, end   
 , @cTranCCY  char(3)    
--20090723, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin   
--20120718, liliana, BAALN12010, begin  
 , @pcShareholderID varchar(12)  
--20120718, liliana, BAALN12010, end     
 , @cTellerId varchar(5)    
 , @cTranBranch varchar(5)    
 , @mAvailableBalance money    
 , @cProductCode  varchar(10)    
 , @cAccountType  varchar(3)    
 , @cCurrencyType char(3)    
--20130226, liliana, BATOY12006, begin  
, @mTotalPctFeeBased        decimal(25,13)  
, @mDefaultPctTaxFee        decimal(25,13)  
, @mSubTotalPctFeeBased     decimal(25,13)  
--20130226, liliana, BATOY12006, end   
--20150130, liliana, LIBST13020, begin  
 , @nJenisPerhitunganFee    int  
 , @nPercentageFee          decimal(25,13)  
 , @nOfficeId               varchar(5)  
--20150130, liliana, LIBST13020, end  
--20160830, liliana, LOGEN00196, begin  
 , @nExtStatus    int  
--20160830, liliana, LOGEN00196, end  
     
select @cTellerId = dbo.fnReksaGetParam('TELLERID')    
select @cTranBranch = isnull(b.office_id_sibs, '99500')      
from user_nisp_v a join office_information_all_v b    
 on a.office_id = b.office_id    
where a.nik = isnull(@cTellerId, 7)    
 and isnull(ltrim(cost_centre_sibs),'') = ''    
--20090723, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin    
--remark dl    
if @pbDebug = 0    
begin    
 exec @nOK = set_usersuid @nUserSuid output      
 if @nOK != 0 or @@error != 0 return 1      
    
 exec @nOK = cek_process_table @nProcID = @@procid       
 if @nOK != 0 or @@error != 0 return 1      
    
 exec @nOK = set_process_table @@procid, null, @nUserSuid, 1      
 if @nOK != 0 or @@error != 0 return 1      
end    
--remark dl    
--20090723, oscar, REKSADN013, end    
    
set @nOK = 0    
    
select @dCurrDate = current_working_date    
from control_table    
    
select @dCurrWorkingDate = current_working_date    
 , @dNextWorkingDate = next_working_date    
 , @dTranDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate())     
--20090807, oscar, REKSADN013, begin    
  , @dPrevWorkingDate = previous_working_date    
--20090807, oscar, REKSADN013, end    
from fnGetWorkingDate()  
--20130226, liliana, BATOY12006, begin  
select @mDefaultPctTaxFee = PercentageTaxFeeDefault  
from dbo.control_table  
  
set @mSubTotalPctFeeBased = 100  
  
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee  
--20130226, liliana, BATOY12006, end    
    
If @dCurrDate < @dCurrWorkingDate    
Begin    
--20090723, oscar, REKSADN013, begin    
 if @pbDebug = 0    
 begin    
  exec @nOK = set_process_table @@procid, null, @nUserSuid, 0      
  if @nOK != 0 or @@error != 0 return 1    
    
  return 0    
 end    
--20090723, oscar, REKSADN013, end    
End    
    
Create Table #TempCIF (    
  CFCIF   char(13) --    
--20080414, mutiara, REKSADN002, begin    
-- , CIFName  varchar(40) --    
 , CIFName  varchar(100) --    
--20080414, mutiara, REKSADN002, end    
--20080206, indra_w, REKSADN002, begin    
-- , Address1  varchar(35) --    
-- , Address2  varchar(35) --    
-- , Address3  varchar(35) --    
 , Address1  varchar(40) --    
 , Address2  varchar(40) --    
 , Address3  varchar(40) --    
--20080206, indra_w, REKSADN002, end    
 , Kota   varchar(25) --    
 , Propinsi  varchar(40) --    
 , NegaraCode varchar(3)  --    
 , Telepon  varchar(40)      
 , HP   varchar(40)     
 , TempatLhr  varchar(30) --    
 , TglLhr  datetime --    
 , KTP   varchar(40) --    
 , NPWP   varchar(40) --    
--20130205, anthony, BARUS12010, begin  
 , NamaNPWP  varchar(40)  
 , TglNPWP datetime  
--20130205, anthony, BARUS12010, end  
 , JnsNas  int    
--20090723, oscar, REKSADN013, begin    
 , DocTermCondition bit    
--20090723, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin  
--20120718, liliana, BAALN12010, begin  
 , ShareholderID    varchar(12)  
--20120718, liliana, BAALN12010, end      
--20150617, liliana, LIBST13020, begin  
 , CIFSID   varchar(100)  
 , Segment  varchar(100)  
 , SubSegment   varchar(100)  
--20150617, liliana, LIBST13020, end  
 , RiskProfile char(1)    
 , LastUpdate datetime    
--20090723, oscar, REKSADN013, end    
--20151026, liliana, LIBST13020, begin  
 , WarnMsg      varchar(500)  
--20151026, liliana, LIBST13020, end  
--20180910, sandi, LOGAM09694, begin  
, IDExpireDate datetime        
, Kewarganegaraan varchar(10)      
, Agama  varchar(50)  
--20180910, sandi, LOGAM09694, end  
)    
--20130107, liliana, BATOY12006, begin  
create table #ReksaMtncFee_TM (  
        AgentId         int,  
        ProdId          int,  
        CCY             char(3),  
        Amount          decimal(25,13),  
        TransactionDate datetime,  
        ValueDate       datetime,  
        Settled         bit,  
        SettleDate      datetime,  
        UserSuid        int,  
        [Type]          tinyint,  
        TotalAccount    int,  
        TotalUnit       decimal(25,13),  
        TotalNominal    decimal(25,13)  
        ,PercentageMFeeBased        decimal(25,13)  
        ,PercentageTaxFeeBased      decimal(25,13)  
        ,PercentageFeeBased3        decimal(25,13)  
        ,PercentageFeeBased4        decimal(25,13)  
        ,PercentageFeeBased5        decimal(25,13)  
        ,MFeeBased      decimal(25,13)  
        ,TaxFeeBased    decimal(25,13)  
        ,FeeBased3      decimal(25,13)  
        ,FeeBased4      decimal(25,13)  
        ,FeeBased5      decimal(25,13)  
        ,TotalFeeBased  decimal(25,13)  
--20130403, liliana, BATOY12006, begin  
        ,SelisihFeeBased     decimal(25,13)  
--20130403, liliana, BATOY12006, end  
--20150130, liliana, LIBST13020, begin  
        , OfficeId              varchar(5)  
--20150130, liliana, LIBST13020, end              
)  
--20130107, liliana, BATOY12006, end  
--20130226, liliana, BATOY12006, begin  
    
create table #ReksaMtncFeeDetail_TM (  
        ClientId        int,  
        AgentId         int,  
        ProdId          int,  
        CCY             char(3),  
        Amount          decimal(25,13),  
        TransactionDate datetime,  
        ValueDate       datetime,  
        UserSuid        int,  
        [Type]          tinyint,  
        NAV             decimal(25,13),  
        UnitBalance     decimal(25,13),  
        SubcUnit        decimal(25,13),  
        ProtekLastUnit  decimal(25,13)  
        ,PercentageMFeeBased        decimal(25,13)  
        ,PercentageTaxFeeBased      decimal(25,13)  
        ,PercentageFeeBased3        decimal(25,13)  
        ,PercentageFeeBased4        decimal(25,13)  
        ,PercentageFeeBased5        decimal(25,13)  
        ,MFeeBased      decimal(25,13)  
        ,TaxFeeBased    decimal(25,13)  
        ,FeeBased3      decimal(25,13)  
        ,FeeBased4      decimal(25,13)  
        ,FeeBased5      decimal(25,13)  
        ,TotalFeeBased  decimal(25,13)  
--20130403, liliana, BATOY12006, begin  
        ,SelisihFeeBased     decimal(25,13)  
--20130403, liliana, BATOY12006, end  
--20150130, liliana, LIBST13020, begin  
        , OfficeId              varchar(5)  
--20150130, liliana, LIBST13020, end              
)  
--20130226, liliana, BATOY12006, end  
    
CREATE TABLE #TempReksaTransaction_TT  (    
TranId                          int                 identity  ,    
TranType                        tinyint             not null  ,    
TranDate                        datetime            not null  ,    
ProdId                          int                 not null  ,    
ClientId                     int                 not null  ,    
FundId                          int                 null  ,    
AgentId                         int                 not null  ,    
TranCCY                         char(3    )         not null  ,    
--20080414, mutiara, REKSADN002, begin    
--TranAmt                         money               null      ,    
--TranUnit                        money               null      ,    
--SubcFee                         money               null      ,    
--RedempFee                       money   null      ,    
--SubcFeeBased                    money               null      ,    
--RedempFeeBased                  money               null      ,    
TranAmt                         decimal(25,13)               null      ,    
TranUnit                        decimal(25,13)               null      ,    
SubcFee                         decimal(25,13)               null      ,    
RedempFee                       decimal(25,13)   null      ,    
SubcFeeBased                    decimal(25,13)               null      ,    
RedempFeeBased                  decimal(25,13)               null      ,    
--20071207, indra_w, REKSADN002, begin    
--NAV                             decimal(20,10)               null      ,  
--20130107, liliana, BATOY12006, begin  
TaxFeeBased                  decimal(25,13)               null      ,   
FeeBased3                  decimal(25,13)               null      ,   
FeeBased4                  decimal(25,13)               null      ,   
FeeBased5                  decimal(25,13)               null      ,   
TotalSubcFeeBased          decimal(25,13)               null      ,  
--20130107, liliana, BATOY12006, end  
--20130418, liliana, BATOY12006, begin  
SelisihFeeBased             decimal(25,13)          null,  
--20130418, liliana, BATOY12006, end     
NAV                             decimal(25,13)               null      ,    
--20071207, indra_w, REKSADN002, end    
NAVValueDate                    datetime            null      ,    
--Kurs                          money              null      ,    
--UnitBalance     money       null      ,    
--UnitBalanceNom                money               null      ,    
Kurs                            decimal(25,13)              null      ,    
UnitBalance      decimal(25,13)       null      ,    
UnitBalanceNom                  decimal(25,13)               null      ,    
--20080414, mutiara, REKSADN002, end    
ParamId                         int                 null      ,    
ProcessDate                     datetime            null      ,    
SettleDate                      datetime            null      ,    
Settled                         bit                 null      ,    
LastUpdate                      datetime            null      ,    
UserSuid                        int                 null      ,    
CheckerSuid                     int                 null      ,    
WMCheckerSuid                   int                 null      ,    
WMOtor                          bit                 null      ,    
ReverseSuid                     int                 null      ,    
Status                          tinyint             null      ,    
BillId                          int                 null      ,    
ByUnit                          bit                 null      ,    
--20071123, indra_w, REKSADN002, begin    
--BlockSequence                   int                 null      )    
BlockSequence                   int                 null      ,    
--20071204, indra_w, REKSADN002, begin    
FullAmount      bit     null   ,    
BlockBranch      char(5)    null  
--20130618, liliana, BAFEM12011, begin  
,Channel            varchar(50)  
--20130618, liliana, BAFEM12011, end   
--20150130, liliana, LIBST13020, begin  
 , PercentageFee        decimal(25,13)  
 , JenisPerhitunganFee  int  
 , OfficeId             varchar(5)  
 , Referentor           int  
 , RefID                varchar(20)  
 , IsFeeEdit            bit  
--20150130, liliana, LIBST13020, end   
--20150608, liliana, LIBST13020, begin  
 , SelectedAccNo        varchar(20)  
--20150608, liliana, LIBST13020, end  
)    
--20071204, indra_w, REKSADN002, end    
--20071123, indra_w, REKSADN002, end    
    
--20090723, oscar, REKSADN013, begin    
create table #TempBookingList (    
BookingId int,    
BookingAmt money    
--20090813, oscar, REKSADN013, begin    
, ProdId  int    
--20090813, oscar, REKSADN013, end    
)    
--20090723, oscar, REKSADN013, end    
    
--20090723, oscar, REKSADN013, begin    
if @pbDebug = 1    
 select @dCurrWorkingDate, @dNextWorkingDate    
--20090723, oscar, REKSADN013, end    
    
--20090813, oscar, REKSADN013, begin    
--pindah sini    
-- bikin list booking    
truncate table #TempBookingList    
    
insert into #TempBookingList (BookingId, BookingAmt, ProdId)    
select a.BookingId, a.BookingAmt, a.ProdId    
from ReksaBooking_TM a     
join ReksaProduct_TM b    
 on a.ProdId = b.ProdId    
where a.Status = 0    
and b.Status = 1    
and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dNextWorkingDate    
and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < dbo.fnReksaGetEffectiveDate(@dNextWorkingDate, 1)    
and b.CloseEndBit = 1    
    
-- otor satu-satu    
declare book_csr cursor for    
 select BookingId from #TempBookingList    
    
open book_csr    
while 1=1    
begin    
 fetch book_csr into @nBookingId    
 if @@fetch_status <> 0 break    
    
 -- debug    
 if @pbDebug = 1 select 'blokir ' + convert(varchar(3), @nBookingId)    
--20090814, oscar, REKSADN013, begin    
 --exec @nOK = ReksaAuthorizeBooking @nBookingId, 1, @cTellerId, 0, 1 -- otomatis    
 exec ReksaAuthorizeBooking @nBookingId, 1, @cTellerId, 0, 1 -- otomatis    
 --if @nOK <> 0 or @@error <> 0    
 --begin    
--20090814, oscar, REKSADN013, end    
--20090814, oscar, REKSADN013, begin    
  --set @cErrMsg = 'Gagal otorisasi otomatis'    
  --goto ERROR    
--20090814, oscar, REKSADN013, begin    
  --continue    
--20090814, oscar, REKSADN013, end    
--20090814, oscar, REKSADN013, end    
--20090814, oscar, REKSADN013, begin    
 --end    
--20090814, oscar, REKSADN013, end   
--20151104, liliana, LIBST13020, begin    
    if exists(select top 1 1 from dbo.ReksaBooking_TM   
        where BookingId = @nBookingId and CheckerSuid is null  
    )  
    begin  
 update dbo.ReksaBooking_TM   
        set CheckerSuid = 7  
        where BookingId = @nBookingId and CheckerSuid is null  
    end  
--20151104, liliana, LIBST13020, end     
end    
--20090814, oscar, REKSADN013, begin    
close book_csr    
--20090814, oscar, REKSADN013, end    
deallocate book_csr    
--20090813, oscar, REKSADN013, end    
    
declare client_cur cursor local fast_forward for     
 select a.ProdId, a.CIFNo, sum(a.BookingAmt), b.NAV, b.ProdCCY, left(b.ProdCode, 3)    
--20071218, indra_w, REKSADN002, begin    
--20150130, liliana, LIBST13020, begin  
   --, a.AgentId   
   , a.OfficeId    
--20150130, liliana, LIBST13020, end  
--20071218, indra_w, REKSADN002, end    
--20080609, indra_w, REKSADN006, begin    
   , b.ManInvId    
--20080609, indra_w, REKSADN006, end    
--20090723, oscar, REKSADN013, begin    
   , a.NISPAccId    
--20090723, oscar, REKSADN013, end    
 from ReksaBooking_TM a join ReksaProduct_TM b    
  on a.ProdId = b.ProdId    
 where a.Status = 0    
  and b.Status = 1    
--20090723, oscar, REKSADN013, begin    
  --and b.PeriodEnd >= @dCurrWorkingDate    
  --and b.PeriodEnd < @dNextWorkingDate    
--20090807, oscar, REKSADN013, begin    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dCurrWorkingDate    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < @dNextWorkingDate    
--20090812, oscar, REKSADN013, begin    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dNextWorkingDate    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < dbo.fnReksaGetEffectiveDate(@dNextWorkingDate, 1)    
--20090813, oscar, REKSADN013, begin    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dCurrWorkingDate    
  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < @dNextWorkingDate    
  and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dNextWorkingDate    
  and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < dbo.fnReksaGetEffectiveDate(@dNextWorkingDate, 1)    
--20090813, oscar, REKSADN013, end    
--20090812, oscar, REKSADN013, end    
--20090807, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, end    
--20071210, indra_w, REKSADN002, begin    
  and b.CloseEndBit = 1    
--20071210, indra_w, REKSADN002, end    
--20071218, indra_w, REKSADN002, begin  
--20150130, liliana, LIBST13020, begin    
 --Group by a.ProdId, a.CIFNo, b.NAV, b.ProdCCY, left(b.ProdCode, 3), a.AgentId    
 Group by a.ProdId, a.CIFNo, b.NAV, b.ProdCCY, left(b.ProdCode, 3), a.OfficeId    
--20150130, liliana, LIBST13020, end   
--20071218, indra_w, REKSADN002, end    
--20080609, indra_w, REKSADN006, begin    
   , b.ManInvId    
--20080609, indra_w, REKSADN006, end    
--20090723, oscar, REKSADN013, begin    
   , a.NISPAccId    
--20090723, oscar, REKSADN013, end    
 order by a.ProdId    
    
open client_cur     
    
while 1=1    
begin    
--20071218, indra_w, REKSADN002, begin    
--20150130, liliana, LIBST13020, begin  
 --fetch client_cur into @nProdId, @cCIFNo, @mBookingAmt, @mNAV, @cProdCCY, @cPrefix, @nAgentId    
 fetch client_cur into @nProdId, @cCIFNo, @mBookingAmt, @mNAV, @cProdCCY, @cPrefix, @nOfficeId  
--20150130, liliana, LIBST13020, end  
--20071218, indra_w, REKSADN002, end    
--20080609, indra_w, REKSADN006, begin    
  , @nManInvId    
--20080609, indra_w, REKSADN006, end    
--20090723, oscar, REKSADN013, begin    
  , @cNISPAccId    
--20090723, oscar, REKSADN013, end    
 if @@fetch_status!=0 break    
     
 select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())     
    
 -- generate data client    
 delete #TempCIF    
--20071204, indra_w, REKSADN002, begin    
 delete #TempReksaTransaction_TT    
--20071204, indra_w, REKSADN002, end    
    
 insert #TempCIF    
 exec ReksaGetCIFData @cCIFNo, 7, ''    
--20130612, anthony, LOGAM05399, begin  
    , 1  
--20130612, anthony, LOGAM05399, end  
    
 if @@error != 0 or @@rowcount = 0    
 Begin    
  set @nOK = 1    
  Goto NEXT    
 End    
    
--20080425, indra_w, REKSADN002, begin    
 select @cSIBSCIFNo = '000000'+@cCIFNo    
    
 select @cIDTYPE = isnull(a.CFSSCD,'')    
  , @cSEX = isnull(a.CFSEX,'')     
  , @cCTZSHIP = case when a.CFCITZ = '000' then 'ID' else isnull(b.JHCCOC,'') end    
  , @cRELIGION = case when a.CFRACE = 'ISL' then '001'     
         when a.CFRACE = 'KAT' then '002'     
       when a.CFRACE = 'PRO' then '003'     
       when a.CFRACE = 'BUD' then '004'     
       when a.CFRACE = 'HIN' then '005'     
       else ''    
      end    
 from CFMAST_v a left join JHCOUN_v b    
  on a.CFCITZ = b.JHCSUB     
 where a.CFCIF = @cSIBSCIFNo    
--20080425, indra_w, REKSADN002, end    
              
 select @nIsEmployee   = IsEmployee    
   ,@nCIFNIK   = CIFNIK    
--20071218, indra_w, REKSADN002, begin    
--   ,@nAgentId   = AgentId    
--20071218, indra_w, REKSADN002, end    
   ,@nBankId   = BankId    
   ,@nAccountType  = AccountType    
--20090723, oscar, REKSADN013, begin    
   --,@cNISPAccId  = NISPAccId    
--20090723, oscar, REKSADN013, end    
   ,@cNonNISPAccId  = NonNISPAccId    
   ,@cNonNISPAccName = NonNISPAccName    
   ,@nReferentor  = Referentor    
   ,@nBookingId  = BookingId    
--20080508, indra_w, REKSADN002, begin    
   , @cCIFName   = CIFName    
   , @cNISPAccName  = NISPAccName    
--20080508, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
   , @pcInputter  = Inputter    
   , @pnSeller   = Seller    
   , @pnWaperd   = Waperd    
--20090723, oscar, REKSADN013, end  
--20111013, liliana, BAALN11009, begin  
 , @pbDocRiskProfile =  DocRiskProfile    
 , @pbDocTermCondition   = DocTermCondition   
--20111013, liliana, BAALN11009, end   
--20120718, liliana, BAALN12010, begin  
 , @pcShareholderID = ShareholderID   
--20120718, liliana, BAALN12010, end  
--20150130, liliana, LIBST13020, begin  
 , @nJenisPerhitunganFee = JenisPerhitunganFee  
 , @nPercentageFee = PercentageFee  
--20150130, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
 , @nExtStatus = ExtStatus   
--20160830, liliana, LOGEN00196, end   
 from ReksaBooking_TM    
 where CIFNo = @cCIFNo    
--20071218, indra_w, REKSADN002, begin  
--20150130, liliana, LIBST13020, begin    
  --and AgentId = @nAgentId   
  and OfficeId = @nOfficeId   
--20150130, liliana, LIBST13020, end  
--20071218, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
  and NISPAccId = @cNISPAccId    
  and ProdId = @nProdId    
--20090723, oscar, REKSADN013, end    
    
 select @cPFix = Prefix    
 from ReksaClientCounter_TR     
 where ProdId = @nProdId    
    
 if @@error!= 0    
 Begin    
  set @nOK = 1    
  Goto NEXT    
 End    
--20090723, oscar, REKSADN013, begin    
 if @pbDebug = 1    
 begin    
  select * from #TempCIF    
 end    
--20090723, oscar, REKSADN013, end    
 Begin Tran    
--20080609, indra_w, REKSADN006, begin    
--   update ReksaClientCounter_TR with(rowlock)    
--   set Counter = @nCounter    
--    , @nCounter = isnull(Counter,0) + 1    
--20080206, indra_w, REKSADN002, begin    
--  where ProdId = @nProdId    
--20080206, indra_w, REKSADN002, end    
    
--20090812, victor, REKSADN016, begin    
  --update a with(rowlock)      
  --set Counter = @nCounter      
  -- , @nCounter = isnull(Counter,0) + 1      
  --from ReksaClientCounter_TR a join ReksaProduct_TM b    
  -- on a.ProdId = b.ProdId    
  --where b.ManInvId = @nManInvId    
--20090812, oscar, REKSADN013, begin    
  --update ReksaClientCounter_TR with(rowlock)      
  --set [Counter] = @nCounter,     
  -- @nCounter = isnull(Counter,0) + 1      
--20090821, victor, REKSADN016, begin    
  --update a with(rowlock)      
  --set Counter = @nCounter      
  -- , @nCounter = isnull(Counter,0) + 1      
  --from ReksaClientCounter_TR a join ReksaProduct_TM b    
  -- on a.ProdId = b.ProdId    
  --where b.ManInvId = @nManInvId    
--20091016, oscar, REKSADN013, begin     
--20091106, victor, REKSADN016, begin     
  update dbo.ReksaClientCounter_TR with(rowlock)      
  set [Counter] = @nCounter,     
   @nCounter = isnull([Counter],0) + 1      
  --update a with(rowlock)      
  --set Counter = @nCounter      
  -- , @nCounter = isnull(Counter,0) + 1      
  --from ReksaClientCounter_TR a join ReksaProduct_TM b    
  -- on a.ProdId = b.ProdId    
  --where b.ManInvId = @nManInvId       
--20091106, victor, REKSADN016, end    
--20091016, oscar, REKSADN013, end       
--20090821, victor, REKSADN016, end    
--20090812, oscar, REKSADN013, end    
--20090812, victor, REKSADN016, end      
--20080609, indra_w, REKSADN006, end    
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
    
  set @cClientCode = @cPFix + right('00000000'+convert(varchar(8),@nCounter),8)    
--20151026, liliana, LIBST13020, begin  
  select @nAgentId = AgentId  
  from dbo.ReksaAgent_TR   
  where ProdId = @nProdId  
    and OfficeId = @nOfficeId  
    
  select @nBankId = BankId  
  from dbo.ReksaBankCode_TR  
  where ProdId = @nProdId  
    and BankCode = 'OCBC001'  
      
  if @nAccountType is null  
  set @nAccountType = 0  
--20151026, liliana, LIBST13020, end  
    
  Insert ReksaCIFData_TM (ProdId, ClientCode, ClientCodePfix, ClientCodeCount, CIFNo, CIFName, CIFAddress1    
   , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone    
   , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus, IsEmployee, CIFNIK     
   , JoinDate, AgentId, BankId, AccountType, NISPAccId, NonNISPAccId, NonNISPAccName    
   , Referentor, BookingId, NAVDate, UnitBalance, UnitNominal, SubcUnit, SubcNominal    
--20080425, indra_w, REKSADN002, begin    
--   , LastUpdate, UserSuid, CheckerSuid, AuthType)    
   , LastUpdate, UserSuid, CheckerSuid, AuthType    
--20080508, indra_w, REKSADN002, begin    
--   , IDType, SEX, CTZSHIP, RELIGION)    
--20090723, oscar, REKSADN013, begin    
   --, IDType, SEX, CTZSHIP, RELIGION, NISPAccName)    
   , IDType, SEX, CTZSHIP, RELIGION, NISPAccName   
--20111013, liliana, BAALN11009, begin  
 , DocRiskProfile, DocTermCondition   
--20111013, liliana, BAALN11009, end       
--20120718, liliana, BAALN12010, begin       
   --, Inputter, Seller, Waperd)   
   , Inputter, Seller, Waperd  
   , ShareholderID    
   )  
--20120718, liliana, BAALN12010, end     
--20090723, oscar, REKSADN013, end    
--20080425, indra_w, REKSADN002, end    
--20080508, indra_w, REKSADN002, end    
  select @nProdId, @cClientCode, @cPFix, @nCounter, @cCIFNo, CIFName, Address1    
   , Address2, Address3, Kota, Propinsi, NegaraCode, Telepon    
   , HP, TempatLhr, TglLhr, KTP, NPWP, JnsNas, 'A', @nIsEmployee, @nCIFNIK    
   , @dNextWorkingDate, @nAgentId, @nBankId, @nAccountType, @cNISPAccId, @cNonNISPAccId, @cNonNISPAccName    
   , @nReferentor, @nBookingId, @dNextWorkingDate, 0, 0, 0, 0     
   , getdate(), 7, 7, 1    
--20080425, indra_w, REKSADN002, begin    
   , @cIDTYPE, @cSEX, @cCTZSHIP, @cRELIGION    
--20080425, indra_w, REKSADN002, end    
--20080508, indra_w, REKSADN002, begin    
   , @cNISPAccName    
--20080508, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin  
--20111013, liliana, BAALN11009, begin  
 , @pbDocRiskProfile, @pbDocTermCondition   
--20111013, liliana, BAALN11009, end     
   , @pcInputter, @pnSeller, @pnWaperd    
--20090723, oscar, REKSADN013, end  
--20120718, liliana, BAALN12010, begin   
    , @pcShareholderID  
--20120718, liliana, BAALN12010, end     
  from #TempCIF    
      
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
    
  select @nClientId = scope_identity()    
--20090723, oscar, REKSADN013, begin    
  if @pbDebug = 1    
   select @nClientId    
--20090723, oscar, REKSADN013, end  
--20121220, anthony, BARUS12010, begin  
--20150130, liliana, LIBST13020, begin  
 --if exists(select top 1 1 from ReksaBookingNPWP_TR where BookingId = @nBookingId)  
 --begin  
 -- insert into ReksaCIFDataNPWP_TR(ClientId, NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK  
 --  , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP)  
 -- select @nClientId, NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK  
 --  , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP  
 -- from ReksaBookingNPWP_TR  
 -- where BookingId = @nBookingId  
 --end  
 --else  
 --begin  
 -- insert into ReksaCIFDataNPWP_TR(ClientId)  
 -- select @nClientId  
 --end  
--20150130, liliana, LIBST13020, end   
--20121220, anthony, BARUS12010, end    
--20090723, oscar, REKSADN013, begin  
--20160830, liliana, LOGEN00196, begin  
 if @nExtStatus = 74 --tax amnesty  
 begin  
 insert dbo.ReksaClientCodeTAMapping_TM (ClientIdTax, IsTaxAmnesty, RegisterDate)  
 select @nClientId, 1, getdate()   
 end   
--20160830, liliana, LOGEN00196, end     
  --cek apakah sudah ada subscription atau blm    
  if exists (select top 1 * from ReksaTransaction_TT where ClientId = @nClientId    
   union select top 1 * from ReksaTransaction_TH where ClientId = @nClientId)    
   set @nTranType = 2 -- add    
  else    
   set @nTranType = 1 -- new      
--20090723, oscar, REKSADN013, end    
      
--20090723, oscar, REKSADN013, begin    
  if @pbDebug = 1    
   select @nTranType    
--20090723, oscar, REKSADN013, end     
      
  -- create transaksinya    
  -- ini buat ngelock doank biar ngga ada yang pake    
  Update ReksaClientCounter_TR with(rowlock)    
  set Trans = @nCounter    
--20090723, oscar, REKSADN013, begin    
  --perbaiki no counter    
   --, @nCounter = isnull(Trans, 0)    
   , @nCounter = isnull(Trans, 0) + 1    
--20090723, oscar, REKSADN013, end    
  where ProdId = @nProdId      
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
      
  insert #TempReksaTransaction_TT(TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY    
    , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate  
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased  
--20130107, liliana, BATOY12006, end       
--20130618, liliana, BAFEM12011, begin  
    , Channel  
--20130618, liliana, BAFEM12011, end     
    , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate    
--20071123, indra_w, REKSADN002, begin    
--    , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence)    
--20071204, indra_w, REKSADN002, begin    
--    , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence, FullAmount)    
    , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence, FullAmount  
--20150130, liliana, LIBST13020, begin        
    --, BlockBranch)    
    , BlockBranch, PercentageFee, JenisPerhitunganFee, OfficeId  
    , Referentor, RefID, IsFeeEdit  
--20150608, liliana, LIBST13020, begin  
    , SelectedAccNo   
--20150608, liliana, LIBST13020, end      
    )    
--20150130, liliana, LIBST13020, end      
--20071204, indra_w, REKSADN002, end    
--20071123, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
--perbaikan tran type    
  --select 1, @dNextWorkingDate, @nProdId, @nClientId, null, @nAgentId, @cProdCCY    
  select @nTranType, @dNextWorkingDate, @nProdId, @nClientId, null, @nAgentId, @cProdCCY    
--20090723, oscar, REKSADN013, end    
--20071204, indra_w, REKSADN002, begin    
   , BookingAmt, 0, SubcFee, 0, SubcFeeBased, 0, 0, @dNextWorkingDate    
--20071204, indra_w, REKSADN002, end  
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130107, liliana, BATOY12006, end  
--20130618, liliana, BAFEM12011, begin  
    , Channel  
--20130618, liliana, BAFEM12011, end      
   , 1, 0, 0, 0, null, null, 0, @dTranDate    
--20071123, indra_w, REKSADN002, begin    
--20071204, indra_w, REKSADN002, begin    
--20090723, oscar, REKSADN013, begin    
--perbaikan usersuid & checkersuid    
   --, 7, 7, null, 0, null, 1, 0, 0, BlockSequence, 1, BlockBranch     
   , UserSuid, CheckerSuid, null, 0, null, 1, 0, 0, BlockSequence, 1, BlockBranch   
--20090723, oscar, REKSADN013, end    
--20071204, indra_w, REKSADN002, end    
--20071123, indra_w, REKSADN002, end  
--20150130, liliana, LIBST13020, begin        
    ,PercentageFee, JenisPerhitunganFee, OfficeId  
    , Referentor, RefID, IsFeeEdit  
--20150130, liliana, LIBST13020, end  
--20150608, liliana, LIBST13020, begin  
    , NISPAccId   
--20150608, liliana, LIBST13020, end         
  from ReksaBooking_TM    
  where ProdId = @nProdId    
   and CIFNo = @cCIFNo    
--20071204, indra_w, REKSADN002, begin    
   and Status = 0    
--20071204, indra_w, REKSADN002, end    
--20071218, indra_w, REKSADN002, begin  
--20150130, liliana, LIBST13020, begin     
   --and AgentId = @nAgentId  
   and OfficeId = @nOfficeId    
--20150130, liliana, LIBST13020, end     
--20071218, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
   and NISPAccId = @cNISPAccId    
--20090723, oscar, REKSADN013, end    
  order by BookingId  
--20130418, liliana, BATOY12006, begin  
    
  update #TempReksaTransaction_TT  
  set TotalSubcFeeBased = isnull(SubcFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)    
    
  update #TempReksaTransaction_TT  
  set SelisihFeeBased = isnull(SubcFee, 0) -  isnull(TotalSubcFeeBased, 0)    
  
--20130612, liliana, LOGAM05399, begin    
  --update #ReksaMtncFeeDetailPersona_TM  
   update #TempReksaTransaction_TT  
--20130612, liliana, LOGAM05399, end    
  set SubcFeeBased = isnull(SubcFeeBased, 0) +  isnull(SelisihFeeBased, 0)   
  
  update #TempReksaTransaction_TT  
  set TotalSubcFeeBased = isnull(SubcFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)    
--20130418, liliana, BATOY12006, end       
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
    
  insert ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY    
    , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate    
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased  
--20130107, liliana, BATOY12006, end       
--20130618, liliana, BAFEM12011, begin  
    , Channel  
--20130618, liliana, BAFEM12011, end   
    , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate    
--20071123, indra_w, REKSADN002, begin    
--20071204, indra_w, REKSADN002, begin    
    , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence, FullAmount    
--20150130, liliana, LIBST13020, begin       
    --, BlockBranch)    
    , BlockBranch, PercentageFee, JenisPerhitunganFee, OfficeId  
    , Referentor, RefID, IsFeeEdit, AuthType  
--20150608, liliana, LIBST13020, begin  
    , SelectedAccNo   
--20150608, liliana, LIBST13020, end  
--20160830, liliana, LOGEN00196, begin  
 , ExtStatus  
--20160830, liliana, LOGEN00196, end      
    )  
--20150130, liliana, LIBST13020, end  
--20071204, indra_w, REKSADN002, end    
--20071123, indra_w, REKSADN002, end    
  select @cPrefix+right('00000'+convert(varchar(5),@nCounter + TranId),5), TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY    
   , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate    
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased  
--20130107, liliana, BATOY12006, end  
--20130618, liliana, BAFEM12011, begin  
    , Channel  
--20130618, liliana, BAFEM12011, end       
   , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate    
   , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence    
--20071123, indra_w, REKSADN002, begin    
--20071204, indra_w, REKSADN002, begin    
   , FullAmount, BlockBranch    
--20071204, indra_w, REKSADN002, end    
--20071123, indra_w, REKSADN002, end  
--20150130, liliana, LIBST13020, begin        
    ,PercentageFee, JenisPerhitunganFee, OfficeId  
    , Referentor, RefID, IsFeeEdit, 1  
--20150130, liliana, LIBST13020, end   
--20150608, liliana, LIBST13020, begin  
    , SelectedAccNo   
--20150608, liliana, LIBST13020, end  
--20160830, liliana, LOGEN00196, begin  
 , @nExtStatus  
--20160830, liliana, LOGEN00196, end      
  from #TempReksaTransaction_TT    
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
      
  select @nCounter = @nCounter + max(TranId)    
  from #TempReksaTransaction_TT    
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
    
  Update ReksaClientCounter_TR with(rowlock)    
  set Trans = @nCounter    
  where ProdId = @nProdId       
    
  if @@error!= 0    
  Begin    
   set @nOK = 1    
   Goto NEXT    
  End    
    
--20090723, oscar, REKSADN013, begin    
--20090813, oscar, REKSADN013, begin    
----coba blokir rek-nya (satu-satu)    
--  --@nProdId    
--  --, @mBookingAmt    
--  --, @cPrefix    
--  --, @cNISPAccId    
      
--  -- bikin list booking    
--  truncate table #TempBookingList    
      
--  insert into #TempBookingList (BookingId, BookingAmt)    
--  select a.BookingId, a.BookingAmt    
--  from ReksaBooking_TM a     
--  join ReksaProduct_TM b    
--   on a.ProdId = b.ProdId    
--  where a.Status = 0    
--  and b.Status = 1    
----20090807, oscar, REKSADN013, begin    
--  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dCurrWorkingDate    
--  --and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < @dNextWorkingDate    
--  and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) >= @dNextWorkingDate    
--  and dbo.fnReksaGetEffectiveDate(b.PeriodEnd, b.EffectiveAfter) < dbo.fnReksaGetEffectiveDate(@dNextWorkingDate, 1)    
----20090807, oscar, REKSADN013, end    
--  and b.CloseEndBit = 1    
      
--  -- otor satu-satu    
--  declare book_csr cursor for    
--   select BookingId from #TempBookingList    
      
--  open book_csr    
--  while 1=1    
--  begin    
--   fetch book_csr into @nBookingId    
--   if @@fetch_status <> 0 break    
    
--   -- debug    
--   if @pbDebug = 1 select 'blokir ' + convert(varchar(3), @nBookingId)    
--   exec ReksaAuthorizeBooking @nBookingId, 1, @cTellerId, 0, 1 -- otomatis    
--  end    
--  close book_csr    
--  deallocate book_csr    
----20090723, oscar, REKSADN013, end    
    
--  -- update tanda booking sudah diproses    
--  Update ReksaBooking_TM    
--  set Status = 1    
--  where CIFNo = @cCIFNo    
--   and ProdId = @nProdId    
----20071218, indra_w, REKSADN002, begin    
--   and AgentId = @nAgentId    
----20071218, indra_w, REKSADN002, end    
----20090723, oscar, REKSADN013, begin    
--   and NISPAccId = @cNISPAccId    
----20090723, oscar, REKSADN013, end    
--20090813, oscar, REKSADN013, end    
--20100702, indra_w, BAING10033, begin  
--20150130, liliana, LIBST13020, begin     
  --insert ReksaCIFConfirmAddr_TM(Id, DataType, CIFNo, AddressType, Branch, AddressSeq    
  --  , AddressLine1, AddressLine2, AddressLine3, AddressLine4, ZIPCode, ForeignAddr    
  --  , Description, AlamatUtama, KodeAlamat, AlamatSID, PeriodThere, PeriodThereCode    
  --  , JenisAlamat, StaySince, Kelurahan, Kecamatan, Dati2, Provinsi, KodeDati2)    
--20150130, liliana, LIBST13020, end       
--20120717, dhanan, LOGAM02012, begin  
--  select top 1 @nClientId, b.DataType, b.CIFNo, b.AddressType, b.Branch, b.AddressSeq    
--20150130, liliana, LIBST13020, begin   
    --select top 1 @nClientId, 1, right('0000000000000000000'+ltrim(rtrim(b.CIFNo)),19), b.AddressType, b.Branch, b.AddressSeq    
--20150130, liliana, LIBST13020, end  
--20120717, dhanan, LOGAM02012, end  
--20150130, liliana, LIBST13020, begin   
  --  , b.AddressLine1, b.AddressLine2, b.AddressLine3, b.AddressLine4, b.ZIPCode, b.ForeignAddr    
  --  , b.Description, b.AlamatUtama, b.KodeAlamat, b.AlamatSID, b.PeriodThere, b.PeriodThereCode    
  --  , b.JenisAlamat, b.StaySince, b.Kelurahan, b.Kecamatan, b.Dati2, b.Provinsi, b.KodeDati2    
  --from ReksaBooking_TM a join ReksaCIFConfirmAddr_TM b   
  --  on a.BookingId = b.Id    
  --   and b.DataType = 0    
  --where a.ProdId = @nProdId    
  --  and a.CIFNo = @cCIFNo    
  --  and a.AgentId = @nAgentId    
  --  and a.NISPAccId = @cNISPAccId    
    
  --if @@error!= 0    
  --Begin    
  -- set @nOK = 1    
  -- Goto NEXT    
  --End    
--20150130, liliana, LIBST13020, end    
--20100702, indra_w, BAING10033, end    
 commit tran    
    
 continue    
     
 NEXT:    
  if @@trancount >0    
   rollback tran    
end    
    
close client_cur    
deallocate client_cur    
--20090813, oscar, REKSADN013, begin    
-- update tanda booking sudah diproses    
Update ReksaBooking_TM    
set Status = 1    
from ReksaBooking_TM a join #TempBookingList b    
 on a.BookingId = b.BookingId    
 and a.ProdId = b.ProdId    
--20090813, oscar, REKSADN013, end    
--20090723, oscar, REKSADN013, begin    
--debug    
if @pbDebug = 0    
begin    
 If @nOK = 1    
 Begin    
  set @cErrMsg = 'Error Process Booking'    
  Goto ERROR    
 End    
end    
--20090723, oscar, REKSADN013, end    
    
--20071210, indra_w, REKSADN002, begin    
-- buat UpFrontFee    
select @cPeriod = convert(char(8), @dNextWorkingDate, 112)    
--20130107, liliana, BATOY12006, begin  
--splitting fee  
--20150130, liliana, LIBST13020, begin  
--insert #ReksaMtncFee_TM (AgentId, ProdId, CCY   
insert #ReksaMtncFee_TM (OfficeId, ProdId, CCY   
--20150130, liliana, LIBST13020, end   
      , Amount, TransactionDate, ValueDate        
      , Settled, SettleDate, UserSuid, Type, TotalAccount, TotalUnit, TotalNominal)   
--20150130, liliana, LIBST13020, begin         
 --select a.AgentId, a.ProdId, b.ProdCCY  
 select a.OfficeId, a.ProdId, b.ProdCCY  
--20150130, liliana, LIBST13020, end     
    , dbo.fnReksaSetRounding(a.ProdId,3,sum(cast(cast(isnull(rp.PctSellingUpfrontDefault,0)/100.00 as decimal(25,13)) * a.TranAmt as decimal(25,13))))    
  , @dCurrDate, @dNextWorkingDate      
  , 0, NULL, 7, 3    
  , count(*), dbo.fnReksaSetRounding(a.ProdId,2,sum(cast(a.TranAmt/b.NAV as decimal(25,13)))), dbo.fnReksaSetRounding(a.ProdId,3,sum(a.TranAmt))     
 from ReksaTransaction_TT a join ReksaProduct_TM b    
   on a.ProdId = b.ProdId    
  join ReksaProductParam_TM c    
   on b.ParamId = c.ParamId     
    join dbo.ReksaParamFee_TM rp  
     on rp.ProdId = a.ProdId  
        and rp.TrxType = 'UPFRONT'  
 where a.Status = 1    
  and c.PeriodEnd >= @dCurrWorkingDate    
  and c.PeriodEnd < @dNextWorkingDate    
  and c.CloseEndBit = 1    
  and isnull(rp.PctSellingUpfrontDefault,0) > 0    
  and a.TranAmt > 0  
--20130328, liliana, BATOY12006, begin  
    and isnull(a.BillId, 0) = 0   
--20130328, liliana, BATOY12006, end  
--20150130, liliana, LIBST13020, begin            
 --group by a.AgentId, a.ProdId, b.ProdCCY  
 group by a.OfficeId, a.ProdId, b.ProdCCY    
--20150130, liliana, LIBST13020, end   
  
update pa  
set PercentageMFeeBased = isnull(rl.Percentage, 0)  
from #ReksaMtncFee_TM pa  
join dbo.ReksaListGLFee_TM rl  
--20130122, liliana, BATOY12006, begin  
    --on ts.ProdId = rl.ProdId  
    on pa.ProdId = rl.ProdId  
--20130122, liliana, BATOY12006, end      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 1  
  
update pa  
set PercentageTaxFeeBased = isnull(rl.Percentage, 0)  
from #ReksaMtncFee_TM pa  
join dbo.ReksaListGLFee_TM rl  
--20130122, liliana, BATOY12006, begin  
    --on ts.ProdId = rl.ProdId  
    on pa.ProdId = rl.ProdId  
--20130122, liliana, BATOY12006, end      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 2  
  
update pa  
set PercentageFeeBased3 = isnull(rl.Percentage, 0)  
from #ReksaMtncFee_TM pa  
join dbo.ReksaListGLFee_TM rl  
--20130122, liliana, BATOY12006, begin  
    --on ts.ProdId = rl.ProdId  
    on pa.ProdId = rl.ProdId  
--20130122, liliana, BATOY12006, end      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 3       
        
update pa  
set PercentageFeeBased4 = isnull(rl.Percentage, 0)  
from #ReksaMtncFee_TM pa  
join dbo.ReksaListGLFee_TM rl  
--20130122, liliana, BATOY12006, begin  
    --on ts.ProdId = rl.ProdId  
    on pa.ProdId = rl.ProdId  
--20130122, liliana, BATOY12006, end      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 4       
        
update pa  
set PercentageFeeBased5 = isnull(rl.Percentage, 0)  
from #ReksaMtncFee_TM pa  
join dbo.ReksaListGLFee_TM rl  
--20130122, liliana, BATOY12006, begin  
    --on ts.ProdId = rl.ProdId  
    on pa.ProdId = rl.ProdId  
--20130122, liliana, BATOY12006, end      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 5               
        
update #ReksaMtncFee_TM  
--20130226, liliana, BATOY12006, begin  
--set MFeeBased = cast(cast(PercentageMFeeBased/100.00 as decimal(25,13)) * Amount as decimal(25,13)),  
--    TaxFeeBased = cast(cast(PercentageTaxFeeBased/100.00 as decimal(25,13)) * Amount as decimal(25,13)),    
--    FeeBased3 = cast(cast(PercentageFeeBased3/100.00 as decimal(25,13)) * Amount as decimal(25,13)),     
--    FeeBased4 = cast(cast(PercentageFeeBased4/100.00 as decimal(25,13)) * Amount as decimal(25,13)),  
--    FeeBased5 = cast(cast(PercentageFeeBased5/100.00 as decimal(25,13)) * Amount as decimal(25,13))     
set MFeeBased = cast(cast(PercentageMFeeBased/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),  
    TaxFeeBased = cast(cast(PercentageTaxFeeBased/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),      
    FeeBased3 = cast(cast(PercentageFeeBased3/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),       
    FeeBased4 = cast(cast(PercentageFeeBased4/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),  
    FeeBased5 = cast(cast(PercentageFeeBased5/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13))       
--20130226, liliana, BATOY12006, end      
      
update #ReksaMtncFee_TM  
set TotalFeeBased = isnull(MFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)           
--20130107, liliana, BATOY12006, end  
--20130226, liliana, BATOY12006, begin  
--20130403, liliana, BATOY12006, begin   
--selisih pembulatan  
update #ReksaMtncFee_TM  
set SelisihFeeBased = isnull(Amount, 0) - isnull(TotalFeeBased, 0)  
  
update #ReksaMtncFee_TM  
set MFeeBased = isnull(MFeeBased, 0) + isnull(SelisihFeeBased, 0)  
  
--20130403, liliana, BATOY12006, end  
--20130418, liliana, BATOY12006, begin  
update #ReksaMtncFee_TM  
set TotalFeeBased = isnull(MFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)   
--20130418, liliana, BATOY12006, end  
--detail  
 insert #ReksaMtncFeeDetail_TM (ClientId, AgentId, ProdId, CCY     
      , Amount, TransactionDate, ValueDate, UserSuid, Type    
      , NAV, UnitBalance, SubcUnit, ProtekLastUnit  
--20150130, liliana, LIBST13020, begin      
      , OfficeId  
--20150130, liliana, LIBST13020, end        
      )    
 select a.ClientId, a.AgentId, a.ProdId, b.ProdCCY    
  , dbo.fnReksaSetRounding(@nProdId,3,(cast(isnull(rp.PctSellingUpfrontDefault,0)/100.00 as decimal(25,13)) * a.TranAmt))      
  , @dCurrDate, @dNextWorkingDate, 7, 3      
  , b.NAV, dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV), dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV), dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV)  
--20150130, liliana, LIBST13020, begin      
   , a.OfficeId  
--20150130, liliana, LIBST13020, end        
 from ReksaTransaction_TT a join ReksaProduct_TM b    
   on a.ProdId = b.ProdId    
  join ReksaProductParam_TM c    
   on b.ParamId = c.ParamId     
    join dbo.ReksaParamFee_TM rp  
     on rp.ProdId = a.ProdId  
        and rp.TrxType = 'UPFRONT'      
 where a.Status = 1    
  and c.PeriodEnd >= @dCurrWorkingDate    
  and c.PeriodEnd < @dNextWorkingDate    
  and c.CloseEndBit = 1  
--20130328, liliana, BATOY12006, begin  
    and isnull(a.BillId, 0) = 0   
--20130328, liliana, BATOY12006, end        
  and isnull(rp.PctSellingUpfrontDefault,0) > 0     
  and a.TranAmt > 0   
  
update pa  
set PercentageMFeeBased = isnull(rl.Percentage, 0)  
from #ReksaMtncFeeDetail_TM pa  
join dbo.ReksaListGLFee_TM rl  
    on pa.ProdId = rl.ProdId      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 1  
  
update pa  
set PercentageTaxFeeBased = isnull(rl.Percentage, 0)  
from #ReksaMtncFeeDetail_TM pa  
join dbo.ReksaListGLFee_TM rl  
    on pa.ProdId = rl.ProdId      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 2  
  
update pa  
set PercentageFeeBased3 = isnull(rl.Percentage, 0)  
from #ReksaMtncFeeDetail_TM pa  
join dbo.ReksaListGLFee_TM rl  
    on pa.ProdId = rl.ProdId      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 3       
        
update pa  
set PercentageFeeBased4 = isnull(rl.Percentage, 0)  
from #ReksaMtncFeeDetail_TM pa  
join dbo.ReksaListGLFee_TM rl  
    on pa.ProdId = rl.ProdId      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 4       
        
update pa  
set PercentageFeeBased5 = isnull(rl.Percentage, 0)  
from #ReksaMtncFeeDetail_TM pa  
join dbo.ReksaListGLFee_TM rl  
    on pa.ProdId = rl.ProdId      
where rl.TrxType = 'UPFRONT'  
      and rl.Sequence = 5               
        
update #ReksaMtncFeeDetail_TM     
set MFeeBased = cast(cast(PercentageMFeeBased/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),  
    TaxFeeBased = cast(cast(PercentageTaxFeeBased/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),      
    FeeBased3 = cast(cast(PercentageFeeBased3/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),       
    FeeBased4 = cast(cast(PercentageFeeBased4/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13)),  
    FeeBased5 = cast(cast(PercentageFeeBased5/@mTotalPctFeeBased as decimal(25,13)) * Amount as decimal(25,13))          
      
update #ReksaMtncFeeDetail_TM  
set TotalFeeBased = isnull(MFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)            
--20130226, liliana, BATOY12006, end  
--20130403, liliana, BATOY12006, begin   
--selisih pembulatan  
update #ReksaMtncFeeDetail_TM  
set SelisihFeeBased = isnull(Amount, 0) - isnull(TotalFeeBased, 0)  
  
update #ReksaMtncFeeDetail_TM  
set MFeeBased = isnull(MFeeBased, 0) + isnull(SelisihFeeBased, 0)  
--20130403, liliana, BATOY12006, end  
--20130418, liliana, BATOY12006, begin  
update #ReksaMtncFeeDetail_TM  
set TotalFeeBased = isnull(MFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)        
--20130418, liliana, BATOY12006, end  
    
If not exists(select top 1 1 from ReksaMtncFee_TM where Type = 3 and ValueDate = @dNextWorkingDate)    
Begin    
--20130107, liliana, BATOY12006, begin  
-- insert ReksaMtncFee_TM (AgentId, ProdId, CCY    
--      , Amount, TransactionDate, ValueDate    
--      , Settled, SettleDate, UserSuid, Type, TotalAccount, TotalUnit, TotalNominal)    
-- select a.AgentId, a.ProdId, b.ProdCCY    
----20071218, indra_w, REKSADN002, begin    
----  , sum(((d.UpFrontFee/100.00) * a.TranAmt)/365.00)    
----20080414, mutiara, REKSADN002, begin    
----  , sum(((d.UpFrontFee/100.00) * a.TranAmt))    
----20080415, indra_w, REKSADN002, begin    
----  , dbo.fnReksaSetRounding(a.ProdId,3,sum(((d.UpFrontFee/100.00) * a.TranAmt)))    
--  , dbo.fnReksaSetRounding(a.ProdId,3,sum(cast(cast(d.UpFrontFee/100.00 as decimal(25,13)) * a.TranAmt as decimal(25,13))))     
----20080415, indra_w, REKSADN002, end    
--  , @dCurrDate, @dNextWorkingDate    
--  , 0, NULL, 7, 3    
----20071218, indra_w, REKSADN002, end    
----20080415, indra_w, REKSADN002, begin    
----  , count(*), dbo.fnReksaSetRounding(a.ProdId,2,sum(a.TranAmt/b.NAV)), dbo.fnReksaSetRounding(a.ProdId,3,sum(a.TranAmt))    
--  , count(*), dbo.fnReksaSetRounding(a.ProdId,2,sum(cast(a.TranAmt/b.NAV as decimal(25,13)))), dbo.fnReksaSetRounding(a.ProdId,3,sum(a.TranAmt))    
----20080415, indra_w, REKSADN002, end    
----20080414, mutiara, REKSADN002, end    
-- from ReksaTransaction_TT a join ReksaProduct_TM b    
--   on a.ProdId = b.ProdId    
--  join ReksaProductParam_TM c    
--   on b.ParamId = c.ParamId      
--  join ReksaProductFee_TR d    
--   on c.FeeId = d.FeeId    
-- where a.Status = 1    
--  and c.PeriodEnd >= @dCurrWorkingDate    
--  and c.PeriodEnd < @dNextWorkingDate    
--  and c.CloseEndBit = 1    
-- -and d.UpFrontFee >0    
--  and a.TranAmt > 0    
-- group by a.AgentId, a.ProdId, b.ProdCCY    
----20071210, indra_w, REKSADN002, begin     
-- If @@error!= 0    
-- Begin    
--  set @cErrMsg = 'Gagal Update Data Bill Maintenance Fee!'    
--  goto ERROR    
-- End  
--20130107, liliana, BATOY12006, end    
--20071210, indra_w, REKSADN002, end  
--20130107, liliana, BATOY12006, begin  
     insert dbo.ReksaMtncFee_TM (AgentId, ProdId, CCY    
      , Amount, TransactionDate, ValueDate    
      , Settled, SettleDate, UserSuid, Type, TotalAccount, TotalUnit, TotalNominal  
      , MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20150130, liliana, LIBST13020, begin  
      , OfficeId   
--20150130, liliana, LIBST13020, end        
      )  
     select AgentId, ProdId, CCY    
      , Amount, TransactionDate, ValueDate    
      , Settled, SettleDate, UserSuid, Type, TotalAccount, TotalUnit, TotalNominal  
      , MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20150130, liliana, LIBST13020, begin  
      , OfficeId   
--20150130, liliana, LIBST13020, end          
     from #ReksaMtncFee_TM  
--20130107, liliana, BATOY12006, end  
End  
        
--20080216, indra_w, REKSADN002, begin    
If not exists(select top 1 1 from ReksaMtncFeeDetail_TM where Type = 3 and ValueDate = @dNextWorkingDate)    
Begin    
--20130226, liliana, BATOY12006, begin  
-- insert ReksaMtncFeeDetail_TM (ClientId, AgentId, ProdId, CCY    
----20080217, indra_w, REKSADN002, begin    
----      , Amount, TransactionDate, ValueDate, UserSuid, Type)    
--      , Amount, TransactionDate, ValueDate, UserSuid, Type    
--      , NAV, UnitBalance, SubcUnit, ProtekLastUnit)    
----20080414, mutiara, REKSADN002, begin    
-- select a.ClientId, a.AgentId, a.ProdId, b.ProdCCY    
----  , ((d.UpFrontFee/100.00) * a.TranAmt)    
----20080415, indra_w, REKSADN002, begin    
----  , dbo.fnReksaSetRounding(@nProdId,3,((d.UpFrontFee/100.00) * a.TranAmt))    
----20130107, liliana, BATOY12006, begin    
--  --, dbo.fnReksaSetRounding(@nProdId,3,(cast(d.UpFrontFee/100.00 as decimal(25,13)) * a.TranAmt))    
--  , dbo.fnReksaSetRounding(@nProdId,3,(cast(isnull(rp.PctSellingUpfrontDefault,0)/100.00 as decimal(25,13)) * a.TranAmt))      
----20130107, liliana, BATOY12006, end    
----20080415, indra_w, REKSADN002, end    
--  , @dCurrDate, @dNextWorkingDate, 7, 3    
----  , b.NAV, a.TranAmt/b.NAV, a.TranAmt/b.NAV, a.TranAmt/b.NAV    
--  , b.NAV, dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV), dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV), dbo.fnReksaSetRounding(@nProdId,2,a.TranAmt/b.NAV)    
----20080217, indra_w, REKSADN002, end    
----20080414, mutiara, REKSADN002, end    
-- from ReksaTransaction_TT a join ReksaProduct_TM b    
--   on a.ProdId = b.ProdId    
--  join ReksaProductParam_TM c    
--   on b.ParamId = c.ParamId    
----20130107, liliana, BATOY12006, begin       
--  --join ReksaProductFee_TR d    
--  -- on c.FeeId = d.FeeId    
--  join dbo.ReksaParamFee_TM rp  
--   on rp.ProdId = a.ProdId  
--      and rp.TrxType = 'UPFRONT'    
----20130107, liliana, BATOY12006, end     
-- where a.Status = 1    
--  and c.PeriodEnd >= @dCurrWorkingDate    
--  and c.PeriodEnd < @dNextWorkingDate    
--  and c.CloseEndBit = 1    
----20130107, liliana, BATOY12006, begin      
--  --and d.UpFrontFee >0    
--  and isnull(rp.PctSellingUpfrontDefault,0) > 0    
----20130107, liliana, BATOY12006, end    
--  and a.TranAmt > 0   
 insert dbo.ReksaMtncFeeDetail_TM (ClientId, AgentId, ProdId, CCY     
      , Amount, TransactionDate, ValueDate, UserSuid, Type    
      , NAV, UnitBalance, SubcUnit, ProtekLastUnit  
      , MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20150130, liliana, LIBST13020, begin  
      , OfficeId   
--20150130, liliana, LIBST13020, end          
      )   
  select ClientId, AgentId, ProdId, CCY   
      , Amount, TransactionDate, ValueDate, UserSuid, Type    
      , NAV, UnitBalance, SubcUnit, ProtekLastUnit  
   , MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20150130, liliana, LIBST13020, begin  
      , OfficeId   
--20150130, liliana, LIBST13020, end          
     from #ReksaMtncFeeDetail_TM        
--20130226, liliana, BATOY12006, end     
    
 If @@error!= 0    
 Begin    
  set @cErrMsg = 'Gagal Update Data Bill Maintenance Fee!'    
  goto ERROR    
 End    
End    
--20080216, indra_w, REKSADN002, end    
    
-- langsung buat BILL untuk UpFrontFee    
Begin tran    
--proses yang Maintenance Fee    
 select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())    
    
 declare bill_cur cursor local fast_forward for     
  select ProdId, CCY    
  from ReksaMtncFee_TM    
  where Type = 3    
   and isnull(BillId, 0) = 0    
  Group by ProdId, CCY    
  order by ProdId    
    
 open bill_cur     
    
 while 1=1    
 begin    
  fetch bill_cur into @nProdId, @cProdCCY    
  if @@fetch_status!=0 break    
      
  Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate    
--20130220, liliana, BATOY12006, begin    
    --, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)  
       , ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased  
       , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5   
        )  
--20130220, liliana, BATOY12006, end        
--20130107, liliana, BATOY12006, begin        
  --select 4, @cPeriod + ' - UpFrontFee - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate   
  select 7, @cPeriod + ' - UpFrontFee - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate       
--20130107, liliana, BATOY12006, end   
   , a.ProdId, c.CustodyId, a.CCY    
--20130107, liliana, BATOY12006, begin     
   --, sum(case when a.CCY = 'IDR' then round(isnull(a.Amount,0), 0) else round(isnull(a.Amount,0), 2) end)   
--20130403, liliana, BATOY12006, begin      
     --, sum(case when a.CCY = 'IDR' then round(isnull(a.TotalFeeBased,0), 0) else round(isnull(a.TotalFeeBased,0), 2) end)  
     , sum(case when a.CCY = 'IDR' then round(isnull(a.TotalFeeBased,0), 2) else round(isnull(a.TotalFeeBased,0), 2) end)           
--20130403, liliana, BATOY12006, end       
--20130107, liliana, BATOY12006, end  
--20130220, liliana, BATOY12006, begin       
   --, 0, 0    
   , 0  
--20130403, liliana, BATOY12006, begin      
   --, sum(case when a.CCY = 'IDR' then round(isnull(a.MFeeBased,0), 0) else round(isnull(a.MFeeBased,0), 2) end)     
   --, sum(case when a.CCY = 'IDR' then round(isnull(a.TaxFeeBased,0), 0) else round(isnull(a.TaxFeeBased,0), 2) end)  
   --, sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased3,0), 0) else round(isnull(a.FeeBased3,0), 2) end)  
   -- , sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased4,0), 0) else round(isnull(a.FeeBased4,0), 2) end)  
   --  , sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased5,0), 0) else round(isnull(a.FeeBased5,0), 2) end)  
   , sum(case when a.CCY = 'IDR' then round(isnull(a.MFeeBased,0), 2) else round(isnull(a.MFeeBased,0), 2) end)     
   , sum(case when a.CCY = 'IDR' then round(isnull(a.TaxFeeBased,0), 2) else round(isnull(a.TaxFeeBased,0), 2) end)  
   , sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased3,0), 2) else round(isnull(a.FeeBased3,0), 2) end)  
    , sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased4,0), 2) else round(isnull(a.FeeBased4,0), 2) end)  
     , sum(case when a.CCY = 'IDR' then round(isnull(a.FeeBased5,0), 2) else round(isnull(a.FeeBased5,0), 2) end)     
--20130403, liliana, BATOY12006, end       
--20130220, liliana, BATOY12006, end     
  from ReksaMtncFee_TM a join ReksaProduct_TM b    
    on a.ProdId = b.ProdId    
   join ReksaCustody_TR c    
    on b.CustodyId = c.CustodyId    
  where a.Type = 3    
   and a.ProdId = @nProdId    
   and a.CCY = @cProdCCY    
   and isnull(a.BillId, 0) = 0    
  group by c.CustodyName, a.ProdId, c.CustodyId, a.CCY    
    
  If @@error!= 0    
  Begin    
   set @cErrMsg = 'Gagal Process Maintenance Fee!'    
   goto ERROR    
  End    
    
--20080216, indra_w, REKSADN002, begin    
  set @nBillId = scope_identity()    
--20080216, indra_w, REKSADN002, end    
    
  Update ReksaMtncFee_TM    
--20080216, indra_w, REKSADN002, begin    
--  set BillId = scope_identity()    
  set BillId = @nBillId    
--20080216, indra_w, REKSADN002, end    
  where isnull(BillId, 0) = 0    
   and Type = 3    
   and ProdId = @nProdId    
   and CCY = @cProdCCY     
    
  If @@error!= 0    
  Begin    
   set @cErrMsg = 'Gagal Update Data Bill Maintenance Fee!'    
   goto ERROR    
  End    
    
--20080216, indra_w, REKSADN002, begin    
  Update ReksaMtncFeeDetail_TM    
  set BillId = @nBillId    
  where isnull(BillId, 0) = 0    
   and Type = 3    
   and ProdId = @nProdId    
   and CCY = @cProdCCY     
    
  If @@error!= 0    
  Begin    
   set @cErrMsg = 'Gagal Update Data Bill Maintenance Fee Detail!'    
   goto ERROR    
  End    
--20080216, indra_w, REKSADN002, end    
    
 end    
    
 close bill_cur    
 deallocate bill_cur    
commit tran    
--20071210, indra_w, REKSADN002, end    
    
-- insert ke history    
Begin tran    
 insert ReksaBooking_TH(BookingId, BookingCode, BookingCounter, BookingCCY, BookingAmt, ProdId, CIFNo, IsEmployee    
  , AgentId, BankId, AccountType, CIFNIK, NISPAccId, NonNISPAccId, NonNISPAccName, Referentor, AuthType, Status    
--20071204, indra_w, REKSADN002, begin    
--20080508, indra_w, REKSADN002, begin    
--  , HistoryStatus, LastUpdate, UserSuid, CheckerSuid, BlockSequence, BlockBranch, SubcFee, SubcFeeBased)    
  , HistoryStatus, LastUpdate, UserSuid, CheckerSuid, BlockSequence, BlockBranch, SubcFee, SubcFeeBased      
--20071204, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
  --, CIFName, NISPAccName)    
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130107, liliana, BATOY12006, end     
  , CIFName, NISPAccName    
--20120718, liliana, BAALN12010, begin    
  --, Inputter, Seller, Waperd)   
   , Inputter, Seller, Waperd  
   , ShareholderID  
--20150130, liliana, LIBST13020, begin   
   , PercentageFee, JenisPerhitunganFee, OfficeId, RefID, IsFeeEdit  
--20150130, liliana, LIBST13020, end     
--20151027, liliana, LIBST13020, begin  
    , Channel, BookingDate, DocTCOthers, DocTCFundFactSheet, DocTCProspectus, DocTCTermCondition,   
    DocTCSubscriptionForm, DocFCOthers, DocFCIDCopy, DocFCJoinAcctStatementLetter, DocFCSubscriptionForm,   
    DocFCDevidentAuthLetter  
--20151027, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
 , ExtStatus  
--20160830, liliana, LOGEN00196, end     
   )     
--20120718, liliana, BAALN12010, end  
--20090723, oscar, REKSADN013, end    
--20080508, indra_w, REKSADN002, end    
 select  BookingId, BookingCode, BookingCounter, BookingCCY, BookingAmt, ProdId, CIFNo, IsEmployee    
  , AgentId, BankId, AccountType, CIFNIK, NISPAccId, NonNISPAccId, NonNISPAccName, Referentor, 5, Status    
--20071204, indra_w, REKSADN002, begin    
  , 'History',   LastUpdate, UserSuid, CheckerSuid, BlockSequence, BlockBranch, SubcFee, SubcFeeBased    
--20071204, indra_w, REKSADN002, end    
--20080508, indra_w, REKSADN002, begin  
--20130107, liliana, BATOY12006, begin  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130107, liliana, BATOY12006, end     
  , CIFName, NISPAccName    
--20080508, indra_w, REKSADN002, end    
--20090723, oscar, REKSADN013, begin    
  , Inputter, Seller, Waperd    
--20090723, oscar, REKSADN013, end  
--20120718, liliana, BAALN12010, begin   
    , ShareholderID  
--20120718, liliana, BAALN12010, end   
--20150130, liliana, LIBST13020, begin   
   , PercentageFee, JenisPerhitunganFee, OfficeId, RefID, IsFeeEdit  
--20150130, liliana, LIBST13020, end  
--20151027, liliana, LIBST13020, begin  
    , Channel, BookingDate, DocTCOthers, DocTCFundFactSheet, DocTCProspectus, DocTCTermCondition,   
    DocTCSubscriptionForm, DocFCOthers, DocFCIDCopy, DocFCJoinAcctStatementLetter, DocFCSubscriptionForm,   
    DocFCDevidentAuthLetter  
--20151027, liliana, LIBST13020, end  
--20160830, liliana, LOGEN00196, begin  
 , ExtStatus  
--20160830, liliana, LOGEN00196, end           
 from ReksaBooking_TM    
 where Status = 1    
    
 If @@error != 0    
 Begin    
  set @cErrMsg = 'Error Pindah ke History'    
  Goto ERROR     
 End  
     
--20111109, liliana, BAALN10011, begin  
 delete   
 from dbo.ReksaRejectBooking_TMP   
 where StatusApproval = 0  
   
  If @@error != 0    
 Begin    
  set @cErrMsg = 'Error Delete Table ReksaRejectBooking_TMP'    
  Goto ERROR     
 End   
   
--20111109, liliana, BAALN10011, end      
 delete ReksaBooking_TM    
 where Status = 1    
    
 If @@error != 0    
 Begin    
  set @cErrMsg = 'Error Delete Table Master'    
  Goto ERROR     
 End    
    
Commit tran    
    
--20090723, oscar, REKSADN013, begin    
--bikin BILL    
begin tran    
    
declare bill_cur cursor local fast_forward for       
 select tt.ProdId, tt.TranCCY      
 from ReksaTransaction_TT tt    
 join ReksaProduct_TM p    
  on tt.ProdId = p.ProdId    
 -- khusus close end saja    
  and p.CloseEndBit = 1    
  and p.Status = 1    
 where tt.TranType in (1,2)      
 and isnull(tt.BillId, 0) = 0      
 Group by tt.ProdId, tt.TranCCY      
 order by tt.ProdId      
    
open bill_cur       
    
while 1=1      
begin      
 fetch bill_cur into @nProdId, @cTranCCY      
 if @@fetch_status!=0 break      
    
 --proses yang subcription by Nominal      
 Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate      
--20130220, liliana, BATOY12006, begin     
 --, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)  
  , ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased  
  , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5  
  )  
--20130220, liliana, BATOY12006, end       
--20090814, oscar, REKSADN013, begin    
-- select 1, @cPeriod + ' - Subscription - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate      
-- , a.ProdId, c.CustodyId, a.TranCCY      
-- , sum(case when a.FullAmount = 1 then case when a.TranCCY = 'IDR' then round(a.TranAmt,0)      
--     else round(a.TranAmt,2)      
--    end      
--   else case when a.TranCCY = 'IDR' then round(a.TranAmt, 0) - round(a.SubcFee, 0)      
--   else round(a.TranAmt, 2) - round(a.SubcFee, 2)      
--    end      
-- end)      
-- , case when a.TranCCY = 'IDR' then sum(round(a.SubcFee, 0)) else sum(round(a.SubcFee, 2)) end      
-- , case when a.TranCCY = 'IDR' then sum(round(a.SubcFeeBased, 0)) else sum(round(a.SubcFeeBased, 2)) end      
-- from ReksaTransaction_TT a join ReksaProduct_TM b      
-- on a.ProdId = b.ProdId      
-- join ReksaCustody_TR c      
-- on b.CustodyId = c.CustodyId      
-- where a.TranType in (1,2)      
-- and a.ProdId = @nProdId      
-- and a.TranCCY = @cTranCCY      
-- and a.Status = 1      
-- and isnull(a.BillId, 0) = 0      
----20090812, oscar, REKSADN013, begin    
-- --and a.NAVValueDate = @dCurrWorkingDate      
-- and a.NAVValueDate = @dNextWorkingDate      
----20090812, oscar, REKSADN013, end    
-- group by c.CustodyName, a.ProdId, c.CustodyId, a.TranCCY      
--20091012, oscar, REKSADN013, begin    
 --select 1, @cPeriod + ' - Subscription - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate      
 select 1, @cPeriod + ' - Subscription - '+ c.CustodyName, 'C', @dTranDate, @dNextWorkingDate      
--20091012, oscar, REKSADN013, end    
 , a.ProdId, c.CustodyId, a.TranCCY   
--20130403, liliana, BATOY12006, begin    
 --, sum(case when a.FullAmount = 1 then case when a.TranCCY = 'IDR' then round(a.TranAmt,0)      
 --    else round(a.TranAmt,2)      
 --   end      
 --  else case when a.TranCCY = 'IDR' then round(a.TranAmt, 0) - round(isnull(a.SubcFee, 0), 0)      
 --  else round(a.TranAmt, 2) - round(isnull(a.SubcFee, 0), 2)      
 --  end      
 --end)      
 --, case when a.TranCCY = 'IDR' then sum(round(isnull(a.SubcFee, 0), 0)) else sum(round(isnull(a.SubcFee, 0), 2)) end  
 , sum(case when a.FullAmount = 1 then case when a.TranCCY = 'IDR' then round(a.TranAmt,2)   
     else round(a.TranAmt,2)      
    end      
   else case when a.TranCCY = 'IDR' then round(a.TranAmt, 2) - round(isnull(a.SubcFee, 0), 2)      
   else round(a.TranAmt, 2) - round(isnull(a.SubcFee, 0), 2)      
   end      
 end)      
 , case when a.TranCCY = 'IDR' then sum(round(isnull(a.SubcFee, 0), 2)) else sum(round(isnull(a.SubcFee, 0), 2)) end   
--20130403, liliana, BATOY12006, end      
--20130107, liliana, BATOY12006, begin  
-- , case when a.TranCCY = 'IDR' then sum(round(isnull(a.SubcFeeBased, 0), 0)) else sum(round(isnull(a.SubcFeeBased, 0), 2)) end   
--20130220, liliana, BATOY12006, begin      
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.TotalSubcFeeBased, 0), 0)) else sum(round(isnull(a.TotalSubcFeeBased, 0), 2)) end  
--20130403, liliana, BATOY12006, begin     
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.SubcFeeBased, 0), 0)) else sum(round(isnull(a.SubcFeeBased, 0), 2)) end  
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.TaxFeeBased, 0), 0)) else sum(round(isnull(a.TaxFeeBased, 0), 2)) end  
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased3, 0), 0)) else sum(round(isnull(a.FeeBased3, 0), 2)) end  
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased4, 0), 0)) else sum(round(isnull(a.FeeBased4, 0), 2)) end  
--, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased5, 0), 0)) else sum(round(isnull(a.FeeBased5, 0), 2)) end  
, case when a.TranCCY = 'IDR' then sum(round(isnull(a.SubcFeeBased, 0), 2)) else sum(round(isnull(a.SubcFeeBased, 0), 2)) end  
, case when a.TranCCY = 'IDR' then sum(round(isnull(a.TaxFeeBased, 0), 2)) else sum(round(isnull(a.TaxFeeBased, 0), 2)) end  
, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased3, 0), 2)) else sum(round(isnull(a.FeeBased3, 0), 2)) end  
, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased4, 0), 2)) else sum(round(isnull(a.FeeBased4, 0), 2)) end  
, case when a.TranCCY = 'IDR' then sum(round(isnull(a.FeeBased5, 0), 2)) else sum(round(isnull(a.FeeBased5, 0), 2)) end  
--20130403, liliana, BATOY12006, end    
--20130220, liliana, BATOY12006, end   
--20130107, liliana, BATOY12006, end     
 from ReksaTransaction_TT a join ReksaProduct_TM b      
 on a.ProdId = b.ProdId      
 join ReksaCustody_TR c      
 on b.CustodyId = c.CustodyId      
 where a.TranType in (1,2)      
 and a.ProdId = @nProdId      
 and a.TranCCY = @cTranCCY      
 and a.Status = 1      
 and isnull(a.BillId, 0) = 0      
 and a.NAVValueDate = @dNextWorkingDate      
 group by c.CustodyName, a.ProdId, c.CustodyId, a.TranCCY      
--20090814, oscar, REKSADN013, end    
    
 If @@error!= 0      
 Begin      
  set @cErrMsg = 'Gagal Process Subc By Nominal!'      
  goto ERROR      
 End      
    
 Update ReksaTransaction_TT      
 set BillId = scope_identity()      
 where isnull(BillId, 0) = 0      
 and TranType in (1,2)      
 and ProdId = @nProdId      
 and TranCCY = @cTranCCY      
 and Status = 1      
--20090812, oscar, REKSADN013, begin    
 --and NAVValueDate = @dCurrWorkingDate      
 and NAVValueDate = @dNextWorkingDate      
--20090812, oscar, REKSADN013, end    
    
 If @@error!= 0      
 Begin      
  set @cErrMsg = 'Gagal Update Data Bill Subc By Nominal!'      
  goto ERROR      
 End      
     
 if @pbDebug = 1    
  select @cPeriod, scope_identity()      
end      
    
close bill_cur      
deallocate bill_cur      
    
commit tran    
--20090723, oscar, REKSADN013, end    
    
--20090723, oscar, REKSADN013, begin    
--20111013, liliana, BAALN10012, begin     
  exec @nOK = ReksaScheduleRedemption        
 if @nOK != 0 or @@error != 0 return 1    
     
--20111013, liliana, BAALN10012, end      
--remark dl    
if @pbDebug = 0    
begin    
 exec @nOK = set_process_table @@procid, null, @nUserSuid, 0      
 if @nOK != 0 or @@error != 0 return 1    
end    
--remark dl    
--20090723, oscar, REKSADN013, end    
--20130107, liliana, BATOY12006, begin  
drop table #ReksaMtncFee_TM   
--20130107, liliana, BATOY12006, end  
    
return 0    
    
ERROR:    
If @@trancount > 0     
 rollback tran    
    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Unknown Error !'    
    
--20090723, oscar, REKSADN013, begin    
--remark dl    
if @pbDebug = 0    
begin    
 exec @nOK = set_process_table @@procid, null, @nUserSuid, 2      
 if @nOK != 0 or @@error != 0 return 1    
end    
--remark dl    
--20090723, oscar, REKSADN013, end    
    
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK != 0 return 1      
      
raiserror (@cErrMsg    ,16,1);
return 1
GO