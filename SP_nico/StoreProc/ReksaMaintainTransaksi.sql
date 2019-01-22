
CREATE proc [dbo].[ReksaMaintainTransaksi]            
/*            
 CREATED BY    : victor            
 CREATION DATE : 20071026            
 DESCRIPTION   : insert / update / delete ke tabel dbo.ReksaTransaction_TT            
     sementara hanya boleh insert            
 REVISED BY    :            
  DATE,  USER,   PROJECT,  NOTE            
  -----------------------------------------------------------------------            
  20071120, indra_w, REKSADN002, tambah pengecekan            
  20071123, victor, REKSADN002, tambah parameter full amount dan sales code            
  20071126, indra_w, REKSADN002, hitung fee based buat yang subsc            
  20071126, victor, REKSADN002, trandate ambil dari waktu di server sql            
  20071128, victor, REKSADN002, tambah pengecekan client, fund, dan agen harus sesuai dengan prod id            
          subscribe tidak boleh lebih dari sisa unit            
          perbaiki pengecekan transaksi subc new            
  20071129, indra_w, REKSADN002, saat insert ke table, NAV value date ngga ikutin jam            
  20071130, victor, REKSADN002, pengecekan client yang udah pernah transaksi subc new juga periksa tabel history            
  20071203, victor, REKSADN002, pengecekan client yang belum transaksi subc new juga periksa tabel history             
  20071205, indra_w, REKSADN002, perbaikan pengecekan unit            
  20071207, indra_w, REKSADN002, perbaikan            
  20071210, victor, REKSADN002, periksa jika tranamt DAN tranunit = 0 maka error            
  20071218, indra_w, REKSADN002, perbaikan UAT            
  20080216, indra_w, REKSADN002, perbaikan            
  20080402, indra_w, REKSADN002, perubahan (FSD)            
  20080414, mutiara, REKSADN002, perubahan tipe data dan penggunaan fungsi ReksaSetRounding, Update ExtStatus dan checking window period        
  20080415, indra_w, REKSADN002, tambahan        
  20080416, mutiara, REKSADN002, mengubah error message dan penambahan variabel good fund        
  20080416, indra_w, REKSADN002, perbaikan        
  20080425, indra_w, REKSADN002, rounding saat compare        
  20080604, indra_w, REKSADN005, perubahan pengecekan window period        
  20080710, indra_w, REKSADN007, penambahan error message        
  20080813, indra_w, REKSADN006, Perubahan untuk Fortis        
  20090311, oscar, REKSADN011, parameter subscription produk        
  20090723, oscar, REKSADN013, tambah kelengkapan dokumen        
  20090625, philip, REKSADN013, utk project REKSADN015            
  20090626, philip, REKSADN013, utk check in         
  20090803, oscar, REKSADN013, tambah inputter, seller, waperd        
  20090804, philip, REKSADN013, tambah pengecekan        
  20090818, oscar, REKSADN013, utk REKSADN015 perbaikan tgl valuta        
  20090904, oscar, REKSADN013, utk REKSADN015 FCD ver 1.1 rev 2        
  20090910, oscar, REKSADN013, utk REKSADN015 biaya hadiah <= 1/2 jk waktu dan perbaikan pesan error        
  20090911, oscar, REKSADN013, utk REKSADN015 biaya hadiah <= jk waktu (rese bener nih user!!!)        
  20090915, oscar, REKSADN013, utk REKSADN015 fcd ver 0.2 rev 1 cek jk waktu M+1 dari tgl terakhir debet (user makin rese!!!!)        
  20090916, oscar, REKSADN013, utk REKSADN015 perbaikan kolom Asuransi utk reg subs        
  20090917, oscar, REKSADN013, utk REKSADN015 kalo redempt all, batalkan yang reg subs        
  20090918, oscar, REKSADN013, utk REKSADN015 perbaikan kolom asuransi redemption all, dibalik        
  20091005, oscar, REKSADN013, utk REKSADN015 perbaikan asuransi kalo pertama kali jgn di-null dan pencegahan reg subs bila ada yg blm jatuh tempo        
  20091109, oscar, REKSADN017, pengecekan min subs new, min subs add, min redemp, min balance untuk karyawan        
  20100203, oscar, REKSADN014, tambah pengecekan ke ReksaUserProcess_TR untuk proses AdHoc        
  20100531, volvin, LOGAM03372, penghentian produk Mantab dan Mantab3       
  20110114, victor, BAALN10002, tambah pengecekan ke SQL_CIF         
  20110124, victor, BAALN10002, pengecekan ke SQL_CIF termasuk transaksi reguler subscription        
  20110523, liliana, BAALN11006, tambahan pengecekan expire date pada waperd        
  20110915, liliana, BAALN10011, pengecekan Minimum Subscription menurut prod Id dan IsEmployee, penambahan parameter frekuensi dan pengecekan reksa mandatory field         
  20110926, liliana, BAALN10011, tambah pengecekan      
  20111013, liliana, BAALN10012, by pass window period utk partial maturity      
  20111021, liliana, BAALN10012, by pass pengecekan  
  20111026, liliana, BAALN10012, tambah update status + remark gagal utk partial maturity  
  20111108, sheila, LOGAM02011, LOGAM04299, Pencegahan Penginputan Pro Reksa NAMA NASABAH = NAMA SELLER  
  20111114, sheila, LOGAM02011, LOGAM04299, penambahan begin end  
  20111213, liliana, LOGAM02011, by pass pengecekan rekening tdk aktif jika partial maturity  
  20120102, sheila, LOGAM02011, LOGAM04397, pengecekan NIK Seller dan NIK Waperd  
  20120118, liliana, BAALN11008, tambah pengecekan utk swc in/redempt/redempt all  
  20120118, liliana, BAALN11008, tambah pengecekan utk swc in/redempt/redempt all 2  
  20120118, liliana, BAALN11008, tambah perhitungan utk switching  
  20120202, liliana, BAALN11008, tambah kolom isEditFee  
  20120207, liliana, BAALN11008, ganti tipe @dCurrWorkingDate  
  20120208, liliana, BAALN11008, centang dokumen dibedakan dengan switching  
  20120213, liliana, BAALN11008, di atas 5 miliar tidak H+3  
  20120213, liliana, BAALN11008, tambah pengecekan utk trx yg sudah prnah di switch in  
  20120327, liliana, BAALN11026, penambahan risk validation dan notification pada menu transaksi  
  20120403, liliana, BAALN11026, Ganti TranType      
  20120410, liliana, BAALN11026, ganti keterangan  
  20120424, dhanan, LOGAM02012, L4636 - default value untuk @pcWarnMsg2  
  20120510, liliana, LOGAM02012, L4671 - sementara tidak bisa trx redempt sebagian by nominal  
  20120627, liliana, BAALN12010, jika clientcode diflag tidak bisa melakukan transaksi subsc  
  20120809, dhanan, LOGAM02012, L4846 - perbaikan pengecekan unit balance switching  
  20121008, liliana, BAALN11003, jika sudah redempt sebagian tdk dpt redempt all  
  20121019, liliana, BAALN11003, tambah maks char eror msg  
  20121019, liliana, BAALN11003, tambah maks char eror msg 2  
  20121019, liliana, BAALN11003, tambah maks char eror msg 3    
  20121019, liliana, BAALN11003, perbaikan  
  20121220, anthony, BARUS12010, pengecekan data npwp  
  20130107, liliana, BATOY12006, pengecekan minimum maksimum percentage fee  
  20130118, anthony, BARUS12010, tambah pengecekan buat trantype new, rdb, switching  
  20130122, liliana, BATOY12006, perbaikan  
  20130123, liliana, BATOY12006, diround agar 0 nya tidak terlalu byk  
  20130128, liliana, BATOY12006, redemp fee based  
  20130206, liliana, BATOY12006, tambah pengecekan jika fee based cabang dan pajak blum terisi  
  20130219, anthony, BARUS12010, FCD UAT  
  20130219, liliana, BATOY12006, tambahkan typetrx utk rdb  
  20130222, anthony, BARUS12010, revisi FCD UAT  
  20130226, liliana, BATOY12006, perubahan perhitungan percentage fee  
  20130227, liliana, BATOY12006, perubahan pengecekan min dan max pada redemption  
  20130315, anthony, BARUS12010, tambah tran tipe 2  
  20130321, liliana, BATOY12006, fix  
  20130402, liliana, BATOY12006, selisih fee dimasukkan ke pendapatan cabang  
  20130415, anthony, BARUS12010, pengecekan tidak berlaku untuk RDB berjalan  
  20130418, liliana, BATOY12006, hitung ulang total fee based setelah ditambah selisih  
  20130419, liliana, LOGAM05380, lepas pengecekan limit jika rdb otomatis 
  20130515, liliana, BAFEM12011, tambah channel phone order 
  20130520, liliana, BAFEM12011, tambah warning message jika nasabah umurnya lebih dari 55 thn
  20130521, liliana, BAFEM12011, umur dan phone order
  20130527, liliana, BAFEM12011, perbaikan
  20130529, liliana, BAFEM12011, ganti deskripsi
  20130531, liliana, BAFEM12011, tran type 3 dan 4 tidak di cek 
  20130701, liliana, BAFEM12011, pengecekan jika tgl good fund jatuh di hari libur
  20130828, liliana, BAALN11010, konversi navdate utk good fund date
  20131106, liliana, BAALN11010, mengecek apakah sudah pernah subs new sebelumnya
  20140313, liliana, LIBST13021, ganti tgl rdb menjadi tgl join date client code
  20140903, liliana, LIBST13021, lepas pengecekan kcuali cek saldo untuk RDB
  20140905, liliana, LIBST13021, untuk RDB auto debet, nav date tetap hari yg sama jika lebih dari jam 1
  20140925, liliana, LIBST13021, untuk RDB yang berhenti hanya bs redemp all
  20141002, liliana, LIBST13021, tambahan
  20150220, liliana, LOGAM06837, pencabutan pengecekan npwp
  20150304, dhanan, LOGAM06837, pengecekan unit balance redemp all
 END REVISED            
            
*/            
@pnType       tinyint, -- 1: new; 2: update; 3: delete            
@pnTranType      int,  -- 1: subscription new; 2 : subs add; 3: redemption; 4: redemption all            
@pcTranCode      char(8)     output,        
--20090723, oscar, REKSADN013, begin            
--20090625, philip, REKSADN013, begin        
--@pnTranId      int      = null,            
@pnTranId      int      = null output,            
--20090625, philip, REKSADN013, end          
--20090723, oscar, REKSADN013, end        
@pdTranDate      datetime,            
@pnProdId      int,            
@pnClientId      int,            
@pnFundId      int,            
@pnAgentId      int,            
@pcTranCCY      char(3),            
--20080414, mutiara, REKSADN002, begin            
--@pmTranAmt      money,            
--@pmTranUnit      money,            
--@pmSubcFee      money,            
--@pmRedempFee     money,            
--@pmSubcFeeBased     money,            
--@pmRedempFeeBased    money,            
@pmTranAmt      decimal(25,13),            
@pmTranUnit      decimal(25,13),            
@pmSubcFee     decimal(25,13),            
@pmRedempFee     decimal(25,13),            
@pmSubcFeeBased     decimal(25,13),            
@pmRedempFeeBased    decimal(25,13),            
--20071207, indra_w, REKSADN002, begin            
--@pmNAV       decimal(20,10),            
@pmNAV       decimal(25,13),            
--20071207, indra_w, REKSADN002, end            
@pdNAVValueDate     datetime,            
--@pmKurs       money,            
--@pmUnitBalance     money,            
--@pmUnitBalanceNom    money,            
@pmKurs       decimal(25,13),            
@pmUnitBalance     decimal(25,13),            
@pmUnitBalanceNom    decimal(25,13),            
--20080414, mutiara, REKSADN002, end            
@pnParamId      int,            
@pdProcessDate     datetime,            
@pdSettleDate     datetime,        
@pbSettled      bit,            
@pdLastUpdate     datetime,            
@pnUserSuid      int,            
@pnCheckerSuid     int,            
@pnWMCheckerSuid    int,            
@pbWMOtor      bit,            
@pnReverseSuid     int,            
@pnStatus      tinyint, --0: new; 1: authorized; 2: rejected; 3: reversed            
@pnBillId      int,            
@pbByUnit      bit,            
--20071123, victor, REKSADN002, begin            
@pbFullAmount     bit,            
@pnSalesId      int,            
--20071123, victor, REKSADN002, end            
@pnNIK       int,            
@pcGuid       varchar(50),            
@pcWarnMsg      varchar(100)  output            
--20090723, oscar, REKSADN013, begin        
,@pbDocFCSubscriptionForm           bit = 0        
,@pbDocFCDevidentAuthLetter         bit = 0        
,@pbDocFCJoinAcctStatementLetter    bit = 0        
,@pbDocFCIDCopy                     bit = 0        
,@pbDocFCOthers                     bit = 0        
,@pbDocTCSubscriptionForm           bit = 0        
,@pbDocTCTermCondition              bit = 0        
,@pbDocTCProspectus                 bit = 0         
,@pbDocTCFundFactSheet              bit = 0        
,@pbDocTCOthers                     bit = 0        
-- list dokumen lainnya pakai separator #        
,@pcDocFCOthersList   varchar(4000) = ''        
,@pcDocTCOthersList   varchar(4000) = ''        
--20090723, oscar, REKSADN013, end             
--20090723, oscar, REKSADN013, begin        
--20090625, philip, REKSADN013, begin        
,@pnJangkaWaktu int        
,@pdJatuhTempo datetime        
,@pnAutoRedemption tinyint        
,@pcGiftCode varchar(10)        
,@pnBiayaHadiah money        
,@pnAsuransi tinyint        
,@pnRegTransactionNextPayment int = 0        
--20090625, philip, REKSADN013, end           
--20090723, oscar, REKSADN013, end        
--20090803, oscar, REKSADN013, begin        
,@pcInputter varchar(40)        
 ,@pnSeller  int        
 ,@pnWaperd  int        
--20090803, oscar, REKSADN013, end      
--20110915, liliana, BAALN10011, begin        
, @pnFrekuensiPendebetan int = 1        
--20110915, liliana, BAALN10011, end         
--20111013, liliana, BAALN10012, begin      
, @pbIsPartialMaturity   bit = 0      
--20111013, liliana, BAALN10012, end     
--20120202, liliana, BAALN11008, begin  
, @pbIsFeeEdit   bit = 0  
--20120202, liliana, BAALN11008, end  
--20120327, liliana, BAALN11026, begin  
--20120424, dhanan, LOGAM02012, begin      
--, @pcWarnMsg2 varchar(100)  output      
, @pcWarnMsg2 varchar(100) = ''  output    
--20120424, dhanan, LOGAM02012, end   
--20120327, liliana, BAALN11026, end    
--20130107, liliana, BATOY12006, begin  
, @pbJenisPerhitunganFee int = 1 -- diisi dengan 1 = by nominal atau 2 = by percentage  
, @pdPercentageFee decimal(25,13) = 0 -- kalau jenis perhitungan fee = 1, ini tidak mandatory  
--20130107, liliana, BATOY12006, end  
--20130227, liliana, BATOY12006, begin  
 , @pnPeriod  int = 0  
--20130227, liliana, BATOY12006, end
--20130515, liliana, BAFEM12011, begin
, @pbByPhoneOrder		bit =0 
--20130515, liliana, BAFEM12011, end  
--20130520, liliana, BAFEM12011, begin
,@pcWarnMsg3    varchar(100) = '' OUTPUT 
--20130520, liliana, BAFEM12011, end
as        
            
set nocount on            
            
declare @nOK     tinyint,    
--20121019, liliana, BAALN11003, begin       
  --@cErrMsg    varchar(100),   
  @cErrMsg    varchar(200),              
--20121019, liliana, BAALN11003, end   
  @c3DigitClientCode  char(3),            
  @c5DigitCounter   char(5),            
  @nCounter    int,            
@cClientCode   varchar(11),            
  @cProdCCY    char(3),            
  @dCutOff    datetime,            
  @nCutOff    int,            
  @dCurrWorkingDate  datetime,            
  @dNextWorkingDate  datetime,            
  @bProcessStatus   bit,            
--20080414, mutiara, REKSADN002, begin            
--  @mEffUnit    money,            
  @mEffUnit    decimal(25,13),            
--20071207, indra_w, REKSADN002, begin            
--  @mLastNAV    decimal(20,10)            
  @mLastNAV    decimal(25,13)            
--20071207, indra_w, REKSADN002, end            
--20071126, indra_w, REKSADN002, begin            
--  , @mFeeBased  money            
--  , @nSubFeeBased  float            
  , @mFeeBased  decimal(25,13)            
  , @nSubFeeBased  decimal(25,13)            
--20071126, indra_w, REKSADN002, end            
--20071128, victor, REKSADN002, begin            
--  , @mMaksUnit   money            
  , @mMaksUnit   decimal(25,13)            
  , @cCIFNo    char(13)            
  , @cProdCode   varchar(10)            
--20071128, victor, REKSADN002, end            
--20071205, indra_w, REKSADN002, begin            
--  , @mUnitPerkiraan  money   
  , @mUnitPerkiraan  decimal(25,13)            
--20071205, indra_w, REKSADN002, end            
--20071218, indra_w, REKSADN002, begin            
  , @cNISPAccId   varchar(19)            
  , @cProductCode   varchar(10)            
  , @cAccountType   char(3)            
  , @cMCAllowed   char(1)            
  , @cAccountStatus  char(1)            
  , @cCurrencyType  char(3)            
  , @cOfficeId  char(5)            
  , @dCurrDate   datetime            
--20080402, indra_w, REKSADN002, begin            
--  , @mMinNew    money            
--  , @mMinAdd    money            
--  , @mMinRedemp   money            
  , @mMinNew    decimal(25,13)            
  , @mMinAdd    decimal(25,13)            
  , @mMinRedemp   decimal(25,13)            
  , @mMinRedempbyUnit  bit            
--  , @mMinBalance   money            
  , @mMinBalance   decimal(25,13)        
  ,@nExtStatus   int            
  ,@nWindowPeriod   int            
  ,@bInsert   bit          
  ,@nHariTgl   int          
  , @mMinBalanceByUnit bit            
--20080416, mutiara, REKSADN002, begin        
 ,@dGoodFund datetime        
--20080416, mutiara, REKSADN002, end            
--20080604, indra_w, REKSADN005, begin        
 ,@nManInvId   int        
 , @nNDayBefore  tinyint        
--20080604, indra_w, REKSADN005, end        
--20080813, indra_w, REKSADN006, begin        
 , @nRedempType  tinyint        
--20080813, indra_w, REKSADN006, end           
--20090723, oscar, REKSADN013, begin        
--20090625, philip, REKSADN013, begin        
 , @nReksaTranType int        
 , @nRegSubscriptionFlag int        
--20090804, philip, REKSADN013, begin        
 declare @nSubscMin money        
  ,@nSubscAddMultiplier money        
  ,@nMinTimeLength int        
  ,@nTimeLengthMultiplier int        
  ,@nToleratedTime int        
--20090804, philip, REKSADN013, end        
--20090904, oscar, REKSADN013, begin        
 , @dPeriodStart datetime        
 , @dHalfPeriod datetime        
 , @nHalfMonth int        
--20090904, oscar, REKSADN013, end        
--20090917, oscar, REKSADN013, begin        
 , @nRegSubsTranId int        
 , @nRegSubsStatus int        
--20090917, oscar, REKSADN013, end        
--20091109, oscar, REKSADN017, begin        
 , @nIsEmployee tinyint        
--20091109, oscar, REKSADN017, end   
--20120207, liliana, BAALN11008, begin  
 , @dCurrWorkingDate2 datetime  
--20120207, liliana, BAALN11008, end  
--20120213, liliana, BAALN11008, begin  
 , @nProdIdException  int  
--20120327, liliana, BAALN11026, begin      
 ,@nProductRiskProfile   int      
 ,@nCustomerRiskProfile   int      
--20120327, liliana, BAALN11026, end   
--20130107, liliana, BATOY12006, begin  
, @cTrxType    varchar(50)  
--20130123, liliana, BATOY12006, begin  
--, @dMinPctFeeEmployee decimal(25,13)     
--, @dMaxPctFeeEmployee decimal(25,13)   
, @dMinPctFeeEmployee float  
, @dMaxPctFeeEmployee float   
--20130123, liliana, BATOY12006, end  
, @dMinPctFeeNonEmployee decimal(25,13)   
, @dMaxPctFeeNonEmployee decimal(25,13)   
, @nPercentageTaxFee  decimal(25,13)   
, @mTaxFeeBased    decimal(25,13)   
, @nPercentageFee3   decimal(25,13)   
, @mFeeBased3    decimal(25,13)   
, @nPercentageFee4   decimal(25,13)   
, @mFeeBased4    decimal(25,13)   
, @nPercentageFee5   decimal(25,13)   
, @mFeeBased5    decimal(25,13)   
, @mTotalFeeBased   decimal(25,13)  
--20130107, liliana, BATOY12006, end  
--20130128, liliana, BATOY12006, begin  
, @mRedempFeeBased   decimal(25,13)  
, @mTotalRedempFeeBased  decimal(25,13)  
, @nPercentageRedempFee  int  
--20130128, liliana, BATOY12006, end  
--20130226, liliana, BATOY12006, begin  
, @mTotalPctFeeBased  decimal(25,13)  
, @mDefaultPctTaxFee  decimal(25,13)  
, @mSubTotalPctFeeBased  decimal(25,13)  
--20130226, liliana, BATOY12006, end  
--20130227, liliana, BATOY12006, begin   
 , @nFeeId     int  
--20130227, liliana, BATOY12006, end  
--20130402, liliana, BATOY12006, begin  
 , @mSelisihFee    decimal(25,13)  
--20130402, liliana, BATOY12006, end
--20130515, liliana, BAFEM12011, begin
, @cChannel					varchar(20)
--20130515, liliana, BAFEM12011, end  
--20130520, liliana, BAFEM12011, begin
, @nUmur					int
--20130520, liliana, BAFEM12011, end
--20140313, liliana, LIBST13021, begin
, @dJoinDate			datetime
--20140313, liliana, LIBST13021, end
--20140903, liliana, LIBST13021, begin
,@pbIsAutoDebetRDB		bit
--20140903, liliana, LIBST13021, end
   
select @nProdIdException = ProdId   
from dbo.ReksaProduct_TM  
where ProdCode = 'RDS'  
  
--20120213, liliana, BAALN11008, end       
        
select @nRegSubscriptionFlag = 0        
--20130222, anthony, BARUS12010, begin  
select @cCIFNo = CIFNo , @cNISPAccId = NISPAccId  
from dbo.ReksaCIFData_TM  
where ClientId = @pnClientId  
--20130222, anthony, BARUS12010, end  
--20130226, liliana, BATOY12006, begin  
select @mDefaultPctTaxFee = PercentageTaxFeeDefault  
from dbo.control_table  
  
set @mSubTotalPctFeeBased = 100  
  
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee  
--20130226, liliana, BATOY12006, end  
--20130227, liliana, BATOY12006, begin   
 select @nFeeId = FeeId  
 from dbo.ReksaProduct_TM  
 where ProdId = @pnProdId  
--20130227, liliana, BATOY12006, end  
        
select @nReksaTranType = ReksaTranType        
from dbo.ReksaClientTranTypeMapping_TR        
where ClientTranType = @pnTranType        
--20090625, philip, REKSADN013, end           
--20090723, oscar, REKSADN013, end        
 set @bInsert=0          
--20080414, mutiara, REKSADN002, end            
--20080402, indra_w, REKSADN002, end   
--20130107, liliana, BATOY12006, begin  
--20130219, liliana, BATOY12006, begin  
--if @nReksaTranType in (1,2)   
if @nReksaTranType in (1,2,8)   
--20130219, liliana, BATOY12006, end  
begin  
 set @cTrxType = 'SUBS'  
end  
else if @nReksaTranType in (3,4)   
begin  
 set @cTrxType = 'REDEMP'  
end  
--20130107, liliana, BATOY12006, end 
--20130515, liliana, BAFEM12011, begin
if(@pbByPhoneOrder = 1)
begin
	set @cChannel = 'TLP'
end
else
begin
   set @cChannel = 'CBG'
end
--20130515, liliana, BAFEM12011, end
--20140903, liliana, LIBST13021, begin
if @nReksaTranType = 8 and @pnNIK = 7
begin
	set @pbIsAutoDebetRDB = 1
end
else
begin
	set @pbIsAutoDebetRDB = 0
end
--20140903, liliana, LIBST13021, end 
        
select @cOfficeId = office_id_sibs            
from user_nisp_v            
where nik = @pnNIK            
--20071218, indra_w, REKSADN002, end            
set @pcWarnMsg = ''            
set @nOK = 0            
            
--20080415, indra_w, REKSADN002, begin        
select @dCurrWorkingDate = current_working_date   
--20120207, liliana, BAALN11008, begin  
 , @dCurrWorkingDate2 = current_working_date  
--20120207, liliana, BAALN11008, end             
from dbo.fnGetWorkingDate()            
--20071218, indra_w, REKSADN002, begin            
select @dCurrDate = current_working_date            
from control_table            
--20080415, indra_w, REKSADN002, end
--20140313, liliana, LIBST13021, begin
select @dJoinDate = JoinDate
from dbo.ReksaCIFData_TM
where ClientId = @pnClientId

set @dJoinDate = convert(varchar(8), @dJoinDate, 112) 
--20140313, liliana, LIBST13021, end    
        
--20100203, oscar, REKSADN014, begin        
if (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1        
begin        
 set @cErrMsg = 'Tidak bisa melakukan booking/transaksi karena proses sinkronisasi sedang dijalankan. Harap tunggu'        
 goto ERROR        
end        
--20100203, oscar, REKSADN014, end        
--cek type            
if @pnType not in (1, 2, 3)            
begin            
 set @cErrMsg = 'Kode @pnType salah, 1:new, 2:update, 3:delete'            
 goto ERROR            
end            
--20071128, victor, REKSADN002, begin            
--cek client sesuai dengan product            
--20071218, indra_w, REKSADN002, begin            
--20080402, indra_w, REKSADN002, begin  
--20120627, liliana, BAALN12010, begin  
If exists(select top 1 1 from dbo.ReksaNonAktifClientId_TT where ClientId = @pnClientId and StatusOtor = 0)              
begin              
set @cErrMsg = 'Client Code sudah Tutup'              
goto ERROR              
end   
--20120627, liliana, BAALN12010, end
--20130515, liliana, BAFEM12011, begin
--20131106, liliana, BAALN11010, begin
if @nReksaTranType in (1)
begin
	if exists (select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId and Status in (1)            
	union            
	select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId and Status in (1)        
	union         
	select top 1 1 from dbo.ReksaTransaction_TT where TranType = 8 and ClientId = @pnClientId and Status = 1 and RegSubscriptionFlag = 1         
	union        
	select top 1 1 from dbo.ReksaTransaction_TH where TranType = 8 and ClientId = @pnClientId and Status = 1 and RegSubscriptionFlag = 1         
	)                   
	begin 
		set @cErrMsg = 'Client Code tersebut sudah pernah Subscription New sebelumnya, harap melakukan Subscription Add!'              
		goto ERROR 
	end
	else if exists (select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId and Status in (0)            
	union            
	select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId and Status in (0)        
	union         
	select top 1 1 from dbo.ReksaTransaction_TT where TranType = 8 and ClientId = @pnClientId and Status = 0 and RegSubscriptionFlag = 1         
	union        
	select top 1 1 from dbo.ReksaTransaction_TH where TranType = 8 and ClientId = @pnClientId and Status = 0 and RegSubscriptionFlag = 1         
	)                   
	begin 
		set @cErrMsg = 'Client Code tersebut sudah pernah Subscription New sebelumnya dan sedang menunggu proses otorisasi.'              
		goto ERROR 
	end
end
--20131106, liliana, BAALN11010, end
if @nReksaTranType in (1) and @pbByPhoneOrder = 1
begin
 select ClientId 
 into #tempListClientCode
 from dbo.ReksaCIFData_TM
 where CIFNo = @cCIFNo
 
--20130521, liliana, BAFEM12011, begin
--if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and Status = 1 and ClientId in (select ClientId from dbo.ReksaCIFData_TM))
--or not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and Status = 1 and ClientId in (select ClientId from dbo.ReksaCIFData_TM))
--or not exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status = 1 and ClientIdSwcIn in (select ClientId from dbo.ReksaCIFData_TM))
--20130527, liliana, BAFEM12011, begin
--if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
--or not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
--or not exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status = 1 and ClientIdSwcIn in (select ClientId from #tempListClientCode))
--or not exists(select top 1 1 from dbo.ReksaBooking_TM where CIFNo = @cCIFNo and Status = 1)
--or not exists(select top 1 1 from dbo.ReksaBooking_TH where CIFNo = @cCIFNo and Status = 1)
--20130529, liliana, BAFEM12011, begin	
--if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
--and not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
--and not exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status = 1 and ClientIdSwcIn in (select ClientId from #tempListClientCode))
if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
and not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
--20130529, liliana, BAFEM12011, end
and not exists(select top 1 1 from dbo.ReksaBooking_TM where CIFNo = @cCIFNo and Status = 1)
and not exists(select top 1 1 from dbo.ReksaBooking_TH where CIFNo = @cCIFNo and Status = 1)
--20130527, liliana, BAFEM12011, end
--20130521, liliana, BAFEM12011, end
begin
--20130529, liliana, BAFEM12011, begin	
 --select @cErrMsg = 'Nasabah yang baru pertama kali melakukan transaksi tidak dapat melakukan transaksi via phone (1)!' 
  select @cErrMsg = 'Nasabah yang baru pertama kali melakukan transaksi Reksa Dana tidak dapat melakukan transaksi via phone (1)!' 
--20130529, liliana, BAFEM12011, end 
 goto ERROR 
end
end
if @nReksaTranType in (8) and @pbByPhoneOrder = 1
begin
 select @cErrMsg = 'Nasabah yang baru pertama kali melakukan transaksi tidak dapat melakukan transaksi via phone (2)!' 
 goto ERROR 
end
--20130515, liliana, BAFEM12011, end                
If not exists(select top 1 1 from ReksaCIFData_TM where ClientId = @pnClientId and CIFStatus = 'A')            
begin            
 set @cErrMsg = 'Client Belum Aktif atau sudah Tutup'            
 goto ERROR            
end            
        
--20080604, indra_w, REKSADN005, begin     
--20111026, liliana, BAALN10012, begin     
--If exists(select top 1 1 from ReksaCIFData_TH where ClientId = @pnClientId and AuthType = 4)            
--20140903, liliana, LIBST13021, begin
--If exists(select top 1 1 from ReksaCIFData_TH where ClientId = @pnClientId and AuthType = 4) and (@pbIsPartialMaturity = 0)    
If exists(select top 1 1 from ReksaCIFData_TH where ClientId = @pnClientId and AuthType = 4) and (@pbIsPartialMaturity = 0) and (@pbIsAutoDebetRDB = 0)
--20140903, liliana, LIBST13021, end 
--20111026, liliana, BAALN10012, end  
begin            
 set @cErrMsg = 'Perubahan Data Nasabah Belum Diotorisasi'            
 goto ERROR            
end         
--20080604, indra_w, REKSADN005, end        
--20090723, oscar, REKSADN013, begin            
If @nReksaTranType in (1,2) and @pmTranUnit > 0           
--20090723, oscar, REKSADN013, end         
begin            
 set @cErrMsg = 'Subscription Harus dalam Nominal'            
 goto ERROR          
end        
        
--20090311, oscar, REKSADN011, begin        
--20120510, liliana, LOGAM02012, begin  
if @nReksaTranType in (3) and @pmTranAmt > 0 and @pbIsPartialMaturity = 0  
begin  
 set @cErrMsg = 'Redemption Sebagian Harus dalam Unit, sementara tidak bisa dalam nominal.'            
 goto ERROR   
end  
--20120510, liliana, LOGAM02012, end  
--untuk subscription new & add hrs cek ke kolom subscription di produk        
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType in (1,2) and (select Subscription from ReksaProduct_TM where ProdId = @pnProdId) = 0        
--20090723, oscar, REKSADN013, end        
begin        
 select @cErrMsg = 'Subscription untuk produk ' + ProdName + ' sudah dihentikan' from ReksaProduct_TM where ProdId = @pnProdId         
 goto ERROR        
end        
--20090311, oscar, REKSADN011, end            
--20090804, philip, REKSADN013, begin          
--20100531, volvin, LOGAM03372, begin         
--utk redemption mantab dan mantab3 di-hold dahulu oleh PO        
if @nReksaTranType in (3,4) and @pnProdId in (5,11)        
begin        
 select @cErrMsg = 'Redemption produk ' + ProdName + ' di-hold, hubungi PO' from ReksaProduct_TM where ProdId = @pnProdId         
 goto ERROR        
end         
--20100531, volvin, LOGAM03372, end        
--20110523, liliana, BAALN11006, begin  
--20120627, liliana, BAALN12010, begin  
if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaFlagClientId_TT where isnull(Flag,0) = 1 and ClientId = @pnClientId and StatusOtor = 0)  
begin  
 select @cErrMsg = 'Client code tersebut di flag, tidak dapat melakukan transaksi subscription! '         
 goto ERROR   
end  
if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaCIFData_TM where isnull(Flag,0) = 1 and ClientId = @pnClientId)  
begin  
 select @cErrMsg = 'Client code tersebut di flag, tidak dapat melakukan transaksi subscription! '         
 goto ERROR   
end  
--20120627, liliana, BAALN12010, end       
if exists (select top 1 1 from dbo.ReksaWaperd_TR where DateExpire < getdate() and NIK = @pnWaperd)        
begin        
 set @cErrMsg = 'WAPERD untuk NIK '+ convert(varchar,@pnWaperd) +' sudah expired'     
 goto ERROR        
end        
--20110523, liliana, BAALN11006, end    
--20111108, sheila, LOGAM02011, begin   
--20120102, sheila, LOGAM02011, begin  
if @pnWaperd !=  @pnSeller  
begin  
 set @cErrMsg = 'NIK Seller tidak sama dengan NIK Waperd'            
 goto ERROR   
end  
--20120102, sheila, LOGAM02011, end  
select @nIsEmployee = isnull(IsEmployee, 0) from ReksaCIFData_TM where ClientId = @pnClientId  
    
if isnull(@nIsEmployee, 0) = 1          
begin    
 declare @CIFNIK varchar(5)  
   
 select @CIFNIK = CIFNIK from ReksaCIFData_TM where ClientId = @pnClientId  
   
 if @CIFNIK = @pnSeller  
--20111114, sheila, LOGAM02011, begin    
 --set @cErrMsg = 'Nasabah sama dengan Nama/NIK Seller'            
 --goto ERROR   
 begin  
 set @cErrMsg = 'Nasabah sama dengan Nama/NIK Seller'            
 goto ERROR   
 end    
--20111114, sheila, LOGAM02011, end   
--20130107, liliana, BATOY12006, begin  
--20130122, liliana, BATOY12006, begin  
end  
--20130122, liliana, BATOY12006, end  
--20130321, liliana, BATOY12006, begin  
--cek apakah data nya lengkap     
if not exists (select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId)  
begin  
    select @cErrMsg = 'Setting parameter '+ @cTrxType +' produk '+ ProdName +' belom ada , harap hubungi WM' from dbo.ReksaProduct_TM where ProdId = @pnProdId              
 goto ERROR   
end  
--20130321, liliana, BATOY12006, end    
if(@pbIsFeeEdit = 1)  
begin  
--20130227, liliana, BATOY12006, begin   
if(@nReksaTranType in (1,2,8))  
begin  
--20130227, liliana, BATOY12006, end  
 if(@nIsEmployee = 1)  
 begin  
  if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeEmployee <= @pdPercentageFee  
  and MaxPctFeeEmployee >= @pdPercentageFee)   
  begin    
--20130219, liliana, BATOY12006, begin  
   --select @dMinPctFeeEmployee = MinPctFeeEmployee, @dMaxPctFeeEmployee = MaxPctFeeEmployee  
   select @dMinPctFeeEmployee = convert(float,MinPctFeeEmployee), @dMaxPctFeeEmployee = convert(float,MaxPctFeeEmployee)  
--20130219, liliana, BATOY12006, end     
   from dbo.ReksaParamFee_TM   
   where TrxType = @cTrxType and ProdId = @pnProdId  
    
--20130321, liliana, BATOY12006, begin    
   --set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeEmployee)+' %.'         
   set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeEmployee))+' %.'           
   goto ERROR   
--20130321, liliana, BATOY12006, end   
  end  
 end  
 else   
 begin  
  if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeNonEmployee <= @pdPercentageFee  
  and MaxPctFeeNonEmployee >= @pdPercentageFee)   
  begin  
--20130219, liliana, BATOY12006, begin    
   --select @dMinPctFeeNonEmployee = MinPctFeeNonEmployee, @dMaxPctFeeNonEmployee = MaxPctFeeNonEmployee  
   select @dMinPctFeeNonEmployee = convert(float,MinPctFeeNonEmployee), @dMaxPctFeeNonEmployee = convert(float,MaxPctFeeNonEmployee)  
--20130219, liliana, BATOY12006, end  
   from dbo.ReksaParamFee_TM   
   where TrxType = @cTrxType and ProdId = @pnProdId  
     
--20130321, liliana, BATOY12006, begin    
   --set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeNonEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeNonEmployee)+' %.'   
   set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeNonEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeNonEmployee))+' %.'              
--20130321, liliana, BATOY12006, end             
   goto ERROR   
  end  
 end  
--20130227, liliana, BATOY12006, begin   
end  
else if(@nReksaTranType in (3,4))  
begin  
 if(@nIsEmployee = 1)  
 begin  
--20130321, liliana, BATOY12006, begin    
   select top 1 @dMaxPctFeeEmployee = convert(float,Fee)         
   from dbo.ReksaRedemPeriod_TM          
   where FeeId = @nFeeId          
   and IsEmployee = @nIsEmployee              
   and Period >= @pnPeriod                    
   order by Period Asc      
--20130321, liliana, BATOY12006, end   
  if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeEmployee <= @pdPercentageFee  
--20130321, liliana, BATOY12006, begin     
  --and MaxPctFeeEmployee >= @pdPercentageFee)  
  and @dMaxPctFeeEmployee >= @pdPercentageFee)    
--20130321, liliana, BATOY12006, end     
  begin    
   select @dMinPctFeeEmployee = convert(float,MinPctFeeEmployee)     
   from dbo.ReksaParamFee_TM   
   where TrxType = @cTrxType and ProdId = @pnProdId  
    
--20130321, liliana, BATOY12006, begin     
   --  select top 1 @dMaxPctFeeEmployee = convert(float,Fee)       
   --  from dbo.ReksaRedemPeriod_TM        
   --  where FeeId = @nFeeId        
   --and IsEmployee = @nIsEmployee            
   --and Period > @pnPeriod                  
   --  order by Period Asc    
--20130321, liliana, BATOY12006, end       
     
--20130321, liliana, BATOY12006, begin    
   --set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeEmployee)+' %.'           
   set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeEmployee))+' %.'           
--20130321, liliana, BATOY12006, end   
   goto ERROR   
  end  
 end  
 else   
 begin  
--20130321, liliana, BATOY12006, begin      
  select top 1 @dMaxPctFeeNonEmployee = convert(float,Fee)         
     from dbo.ReksaRedemPeriod_TM          
     where FeeId = @nFeeId          
   and IsEmployee = @nIsEmployee              
   and Period >= @pnPeriod                    
     order by Period Asc      
--20130321, liliana, BATOY12006, end
--20150220, liliana, LOGAM06837, begin
	set @dMaxPctFeeNonEmployee = isnull(@dMaxPctFeeNonEmployee,0)
--20150220, liliana, LOGAM06837, end   
  if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeNonEmployee <= @pdPercentageFee  
--20130321, liliana, BATOY12006, begin    
  --and MaxPctFeeNonEmployee >= @pdPercentageFee)  
  and @dMaxPctFeeNonEmployee >= @pdPercentageFee)  
--20130321, liliana, BATOY12006, end     
  begin  
   select @dMinPctFeeNonEmployee = convert(float,MinPctFeeNonEmployee)  
   from dbo.ReksaParamFee_TM   
   where TrxType = @cTrxType and ProdId = @pnProdId  
  
--20130321, liliana, BATOY12006, begin  
   --  select top 1 @dMaxPctFeeNonEmployee = convert(float,Fee)       
   --  from dbo.ReksaRedemPeriod_TM        
   --  where FeeId = @nFeeId        
   --and IsEmployee = @nIsEmployee            
   --and Period > @pnPeriod                  
   --  order by Period Asc    
--20130321, liliana, BATOY12006, end       
          
--20130321, liliana, BATOY12006, begin    
   --set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeNonEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeNonEmployee)+' %.'              
   set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeNonEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeNonEmployee))+' %.'              
--20130321, liliana, BATOY12006, end            
   goto ERROR   
  end  
 end  
end  
--20130227, liliana, BATOY12006, end   
end  
--20130107, liliana, BATOY12006, end   
--20130122, liliana, BATOY12006, begin           
--end   
--20130122, liliana, BATOY12006, end  
--20111108, sheila, LOGAM02011, end       
if @nReksaTranType = 8        
begin        
--20110915, liliana, BAALN10011, begin      
 --select @nSubscMin = cast(dbo.fnGetRegulerSubscParam('SubscMin') as money)        
  select @nIsEmployee = isnull(IsEmployee, 0) from ReksaCIFData_TM where ClientId = @pnClientId           
  select @nSubscMin = cast(ParamValue as money) from dbo.ReksaRegulerSubscriptionParam_TR         
  where ParamId = 'SubscMin' and ProductId = @pnProdId and IsEmployee = @nIsEmployee        
--20110915, liliana, BAALN10011, end       
 select @nSubscAddMultiplier = cast(dbo.fnGetRegulerSubscParam('SubscAddMultiplier') as money)      
--20110915, liliana, BAALN10011, begin          
 --select @nMinTimeLength = cast(dbo.fnGetRegulerSubscParam('MinTimeLength') as int)        
 --select @nTimeLengthMultiplier = cast(dbo.fnGetRegulerSubscParam('TimeLengthMultiplier') as int)       
 select @nMinTimeLength = MinJangkaWaktu from dbo.ReksaFrekPendebetanParam_TR where FrekuensiPendebetan = @pnFrekuensiPendebetan        
 select @nTimeLengthMultiplier = Kelipatan from dbo.ReksaFrekPendebetanParam_TR where FrekuensiPendebetan = @pnFrekuensiPendebetan        
--20110915, liliana, BAALN10011, end        
 select @nToleratedTime = cast(dbo.fnGetRegulerSubscParam('ToleratedTime') as int)        
  
--20130419, liliana, LOGAM05380, begin  
if(@pnNIK <> 7)  
begin  
--20130419, liliana, LOGAM05380, end        
 if @pmTranAmt < @nSubscMin        
 begin        
  select @cErrMsg = 'Minimal Subscription Amount Adalah: ' + convert(varchar(25),@nSubscMin,1)        
  goto ERROR         
 end  
--20130419, liliana, LOGAM05380, begin  
end  
--20130419, liliana, LOGAM05380, end          
        
 if @pmTranAmt % @nSubscAddMultiplier <> 0        
 begin        
  select @cErrMsg = 'Subscription Amount Harus Kelipatan: ' + convert(varchar(25),@nSubscAddMultiplier,1)        
  goto ERROR         
 end        
        
 if @pnJangkaWaktu < @nMinTimeLength        
 begin        
--20090910, oscar, REKSADN013, begin        
  --select @cErrMsg = 'Jangka Waktu Minimal ' + convert(varchar(25),@nMinTimeLength) + ' Bulan'        
  select @cErrMsg = 'Jangka Waktu harus min ' + convert(varchar(25),@nMinTimeLength) + ' bulan dan kelipatan ' + convert(varchar(25), @nTimeLengthMultiplier) + ' bulan'        
--20090910, oscar, REKSADN013, end        
  goto ERROR         
 end        
        
 if @pnJangkaWaktu % @nTimeLengthMultiplier <> 0        
 begin        
--20090910, oscar, REKSADN013, begin        
  --select @cErrMsg = 'Jangka Waktu Harus Kelipatan ' + convert(varchar(25),@nMinTimeLength) + ' Bulan'        
  select @cErrMsg = 'Jangka Waktu harus min ' + convert(varchar(25),@nMinTimeLength) + ' bulan dan kelipatan ' + convert(varchar(25), @nTimeLengthMultiplier) + ' bulan'        
--20090910, oscar, REKSADN013, end        
  goto ERROR         
 end        
--20090904, oscar, REKSADN013, begin        
--cek client hrs reguler subscription        
 if not exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)        
 begin        
  select @cErrMsg = 'Client Code bukan Nasabah Reguler Subscription'        
  goto ERROR        
 end        
         
 if exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)        
  --and exists (select top 1 1 from ReksaTransaction_TT where TranType = 8 and ClientId = @pnClientId and ProdId = @pnProdId)        
  and exists (        
   select top 1 1         
   from ReksaTransaction_TT a        
   join ReksaRegulerSubscriptionSchedule_TT b        
   on a.TranId = b.TranId        
   where a.ClientId = @pnClientId        
   and a.ProdId = @pnProdId        
--20091005, oscar, REKSADN013, begin        
   --and b.StatusId = 0        
--20091005, oscar, REKSADN013, end        
   union        
   select top 1 1         
   from ReksaTransaction_TH a        
   join ReksaRegulerSubscriptionSchedule_TT b        
   on a.TranId = b.TranId        
   where a.ClientId = @pnClientId        
   and a.ProdId = @pnProdId        
--20091005, oscar, REKSADN013, begin        
   --and b.StatusId = 0          
--20091005, oscar, REKSADN013, end        
  )        
  and @pnRegTransactionNextPayment = 0        
 begin        
  select @cErrMsg = 'Client sudah pernah memiliki reguler subscription produk ini'        
  goto ERROR        
 end         
--20090904, oscar, REKSADN013, end         
end        
--20090804, philip, REKSADN013, end        
--20090904, oscar, REKSADN013, begin        
--cek hanya boleh reg subs, redempt sebagian atau redempt all saja        
if exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)        
begin      
 if @nReksaTranType not in (3, 4, 8)        
 begin        
  select @cErrMsg = 'Client Reguler Subscription hanya boleh transaksi Reguler Subscription atau Redemption'        
  goto ERROR        
 end          
 --hanya boleh kalau sudah jatuh tempo     
 if @nReksaTranType = 3        
 begin
--20140925, liliana, LIBST13021, begin
	--kalo berhenti , hanya boleh redemp all saja
  if exists(
	select top 1 1         
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TT b        
    on a.TranId = b.TranId        
    and b.ClientId = @pnClientId        
   where a.StatusId = 5        
   union        
   select top 1 1         
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TH b        
    on a.TranId = b.TranId        
    and b.ClientId = @pnClientId        
   where a.StatusId = 5   
	)
 begin
	set @cErrMsg = 'Client Code dengan Status Berhenti hanya dapat melakukan redemp all!'        
	goto ERROR  
 end
--20140925, liliana, LIBST13021, end         
  if exists (        
   select top 1 1         
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TT b        
    on a.TranId = b.TranId        
    and b.ClientId = @pnClientId        
   where a.StatusId = 0        
   union        
   select top 1 1         
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TH b        
    on a.TranId = b.TranId        
    and b.ClientId = @pnClientId        
   where a.StatusId = 0        
   )        
  begin        
--20090915, oscar, REKSADN013, begin        
   --select @cErrMsg = 'Transaksi reguler transaction belum jatuh tempo'        
   select @cErrMsg = 'Masih ada transaksi reguler transaction yang belum dijalankan'        
   goto ERROR        
  end            
--cek tgl transaksi < tgl jatuh tempo        
  select @pdJatuhTempo = max(ScheduledDate)        
  from ReksaRegulerSubscriptionSchedule_TT a        
  join ReksaTransaction_TT b        
  on a.TranId = b.TranId        
  where b.ClientId = @pnClientId        
  and a.Type = 0        
          
  if @pdJatuhTempo is null         
   select @pdJatuhTempo = max(ScheduledDate)        
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TH b        
   on a.TranId = b.TranId        
   where b.ClientId = @pnClientId        
   and a.Type = 0         
           
  select @pdJatuhTempo = dateadd(m, 1, @pdJatuhTempo)        
        
  if (@dCurrWorkingDate < @pdJatuhTempo)           
  begin        
   select @cErrMsg = 'Transaksi Reguler Subscription belum jatuh tempo'        
   goto ERROR        
  end        
 end        
--20090915, oscar, REKSADN013, begin        
--20090918, oscar, REKSADN013, begin        
--20091005, oscar, REKSADN013, begin        
 if @nReksaTranType in (3, 4)        
 begin        
  set @pnAsuransi = null        
--20090918, oscar, REKSADN013, end        
  select @pnAsuransi = b.Asuransi        
  from ReksaRegulerSubscriptionSchedule_TT a        
  join ReksaTransaction_TT b        
  on a.TranId = b.TranId        
  where b.ClientId = @pnClientId        
--20090916, oscar, REKSADN013, begin         
 --if @pnAsuransi is null        
--20090918, oscar, REKSADN013, begin        
 --if isnull(@pnAsuransi, 0) = 0        
  if @pnAsuransi is null        
--20090918, oscar, REKSADN013, end        
--20090916, oscar, REKSADN013, end        
   select @pnAsuransi = b.Asuransi        
   from ReksaRegulerSubscriptionSchedule_TT a        
   join ReksaTransaction_TH b        
   on a.TranId = b.TranId        
   where b.ClientId = @pnClientId       
--20090915, oscar, REKSADN013, end        
 end        
--20091005, oscar, REKSADN013, end         
end        
--20090904, oscar, REKSADN013, end        
--20090915, oscar, REKSADN013, end        
        
if exists (select top 1 1 from dbo.ReksaExceptionClient_TR where ClientId = @pnClientId)            
begin            
 set @cErrMsg = 'Client Ini Tidak Boleh Ditransaksikan'            
 goto ERROR            
end            
            
If isnull(rtrim(@pcTranCCY), '') = ''            
begin            
 set @cErrMsg = 'Mata Uang Harus Diisi'            
 goto ERROR            
end            
            
if exists(select top 1 1 from control_table where end_of_day = 1 and begin_of_day = 0)            
begin            
 set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'            
 goto ERROR            
end            
            
--20080402, indra_w, REKSADN002, end            
--20071218, indra_w, REKSADN002, end            
if not exists (select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientId and ProdId = @pnProdId)            
begin            
 set @cErrMsg = 'Kode Client tidak sesuai dengan Kode Produk'            
 goto ERROR            
end            
            
--cek agent sesuai dengan product            
if not exists (select top 1 1 from dbo.ReksaAgent_TR where AgentId = @pnAgentId and ProdId = @pnProdId)            
begin            
 set @cErrMsg = 'Kode Agent tidak sesuai dengan Kode Produk'            
 goto ERROR            
end            
--20071218, indra_w, REKSADN002, begin            
--20090723, oscar, REKSADN013, begin        
--20090625, philip, REKSADN013, begin        
--If @pnType in (1) and not exists(select * from ReksaAgent_TR where AgentId = @pnAgentId and OfficeId = @cOfficeId)            
If @pnType in (1) and not exists(select * from ReksaAgent_TR where AgentId = @pnAgentId and OfficeId = @cOfficeId) and @pnNIK <> 7        
--20090625, philip, REKSADN013, end            
--20090723, oscar, REKSADN013, end        
Begin           
 set @cErrMsg = 'Kode Agent Tidak Sesuai Kode Cabang!'            
 goto ERROR            
end          
--20071218, indra_w, REKSADN002, end            
--cek fund sesuai dengan product            
if not exists (select top 1 1 from dbo.ReksaFundCode_TR where FundId = @pnFundId and ProdId = @pnProdId)            
begin            
 set @cErrMsg = 'Kode Fund tidak sesuai dengan Kode Produk'            
 goto ERROR            
end            
            
--20071210, victor, REKSADN002, begin            
--cek jika tranamt dan tranunit 2 2 nya 0 maka error            
if (@pmTranAmt = 0) and (@pmTranUnit = 0)            
begin            
 set @cErrMsg = 'Nominal / Unit harus diisi'            
 goto ERROR            
end            
--20071210, victor, REKSADN002, end            
--20071205, indra_w, REKSADN002, begin            
--20090723, oscar, REKSADN013, begin        
If @nReksaTranType in (1,2) and exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1)            
--20090723, oscar, REKSADN013, end        
Begin            
 set @cErrMsg = 'Hanya boleh melalui menu Booking'            
 goto ERROR            
End            
--20071205, indra_w, REKSADN002, end           
--20090723, oscar, REKSADN013, begin         
--20090625, philip, REKSADN013, begin        
if @nReksaTranType in (8) and not exists(select top 1 1 from dbo.ReksaRegulerSubscription_TR where ProductId = @pnProdId)        
begin        
 set @cErrMsg = 'Kode Product tidak untuk Reguler Subscription'        
 goto ERROR        
end  
--20121220, anthony, BARUS12010, begin  
--20130219, anthony, BARUS12010, begin  
--if not exists(select top 1 1 from ReksaCIFDataNPWP_TR where ClientId = @pnClientId)  
--20150220, liliana, LOGAM06837, begin
--if not exists(select top 1 1 from ReksaCIFDataNPWP_TR where CIFNo = @cCIFNo)  
--20150220, liliana, LOGAM06837, end
--20130219, anthony, BARUS12010, end  
--20130118, anthony, BARUS12010, begin  
--20130315, anthony, BARUS12010, begin  
 --and @pnTranType in (1, 8)  
--20150220, liliana, LOGAM06837, begin 
 --and @pnTranType in (1, 2, 8)  
--20150220, liliana, LOGAM06837, end
--20130315, anthony, BARUS12010, end  
--20130118, anthony, BARUS12010, end  
--20130415, anthony, BARUS12010, begin
--20150220, liliana, LOGAM06837, begin  
 --and @pnNIK <> 7  
--20150220, liliana, LOGAM06837, end 
--20130415, anthony, BARUS12010, end
--20150220, liliana, LOGAM06837, begin  
--begin  
-- set @cErrMsg = 'Data NPWP belum lengkap'  
-- goto ERROR  
--end
--20150220, liliana, LOGAM06837, end  
--20121220, anthony, BARUS12010, end        
        
if @nReksaTranType not in (8)        
begin        
--20090916, oscar, REKSADN013, begin        
 --select @pnAsuransi = 0, @pnAutoRedemption = 0,        
 select @pnAutoRedemption = 0,        
--20090916, oscar, REKSADN013, end        
  @pnJangkaWaktu = 0, @pdJatuhTempo = null,        
  @pcGiftCode = null, @pnBiayaHadiah = 0        
end        
--20090625, philip, REKSADN013, end          
--20090723, oscar, REKSADN013, end        
--20080415, indra_w, REKSADN002, begin        
--20080604, indra_w, REKSADN005, begin      
--20090904, oscar, REKSADN013, begin        
--isi biaya hadiah kalo redemption all tp di tengah jalan        
if @nReksaTranType = 4 and exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)        
begin        
 --, @dPeriodStart datetime        
 --, @dHalfPeriod datetime        
 -- @nHalfMonth        
        
 select @dPeriodStart = min(ScheduledDate), @pdJatuhTempo = max(ScheduledDate)        
 from ReksaRegulerSubscriptionSchedule_TT a        
 join ReksaTransaction_TT b        
 on a.TranId = b.TranId        
 where b.ClientId = @pnClientId        
 and a.Type = 0        
         
 if @pdJatuhTempo is null or @dPeriodStart is null        
  select @dPeriodStart = min(ScheduledDate), @pdJatuhTempo = max(ScheduledDate)        
  from ReksaRegulerSubscriptionSchedule_TT a        
  join ReksaTransaction_TH b        
  on a.TranId = b.TranId        
  where b.ClientId = @pnClientId        
  and a.Type = 0         
--20090915, oscar, REKSADN013, begin        
 --tambah sebulan        
 select @pdJatuhTempo = dateadd(m, 1, @pdJatuhTempo)        
--20090915, oscar, REKSADN013, end        
--20090911, oscar, REKSADN013, begin        
--skr kapan pun kena        
 --select @nHalfMonth = round(datediff(m, @dPeriodStart, @pdJatuhTempo) * 0.5, 0)        
 select @nHalfMonth = round(datediff(m, @dPeriodStart, @pdJatuhTempo), 0)        
--20090911, oscar, REKSADN013, end        
        
--20090910, oscar, REKSADN013, begin        
 --if round(datediff(m, @dPeriodStart, @dCurrWorkingDate) + 0.5 , 0) < @nHalfMonth        
 if round(datediff(m, @dPeriodStart, @dCurrWorkingDate) + 0.5 , 0) <= @nHalfMonth        
--20090910, oscar, REKSADN013, end        
 begin        
  -- kena biaya hadiah        
  select @pnBiayaHadiah = a.BiayaHadiah,        
    @pcGiftCode = a.GiftCode        
--20090911, oscar, REKSADN013, begin        
    , @pnJangkaWaktu = a.JangkaWaktu        
    , @pdJatuhTempo = a.JatuhTempo        
--20090911, oscar, REKSADN013, end          
  from ReksaTransaction_TT a        
  join ReksaRegulerSubscriptionSchedule_TT b        
  on a.TranId = b.TranId        
  where a.ClientId = @pnClientId        
        
  if @pnBiayaHadiah is null or @pcGiftCode is null        
   select @pnBiayaHadiah = a.BiayaHadiah,        
     @pcGiftCode = a.GiftCode        
--20090911, oscar, REKSADN013, begin        
    , @pnJangkaWaktu = a.JangkaWaktu        
    , @pdJatuhTempo = a.JatuhTempo        
--20090911, oscar, REKSADN013, end         
   from ReksaTransaction_TH a        
   join ReksaRegulerSubscriptionSchedule_TT b        
   on a.TranId = b.TranId        
   where a.ClientId = @pnClientId          
 end        
 else        
  -- ga usah kena biaya hadiah        
  select @pnBiayaHadiah = 0.0        
--20090917, oscar, REKSADN013, begin        
 if exists (select top 1 1 from ReksaTransaction_TT where ClientId = @pnClientId and TranType = 8         
  and NAVValueDate = @dCurrWorkingDate and Status = 1 and BillId is not null)        
 begin        
  -- sudah bill jadi tidak bisa redemption all        
  set @cErrMsg = 'Tidak bisa redempt all karena ada transaksi reg subs yang sudah proses bill'        
  goto ERROR        
 end        
--20090917, oscar, REKSADN013, end        
end        
--20090904, oscar, REKSADN013, end        
-- if exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and WindowPeriod = 1)        
--   and day(@dCurrWorkingDate) not in (select tgl from ReksaWindowPeriod_TM where ProdId = @pnProdId)        
--20090723, oscar, REKSADN013, begin        
--  and @nReksaTranType in (3,4)             
--20090723, oscar, REKSADN013, end        
-- Begin            
--  set @cErrMsg = 'Tidak Boleh Redemp di luar Window Period'            
--  goto ERROR            
-- End            
--20080415, indra_w, REKSADN002, end        
--20080604, indra_w, REKSADN005, end            
--cek subscription tidak boleh lebih besar dari jumlah unit ditawarkan per nasabah            
--20071218, indra_w, REKSADN002, begin   
--20130222, anthony, BARUS12010, begin  
--select @cCIFNo = CIFNo , @cNISPAccId = NISPAccId            
--20130222, anthony, BARUS12010, end  
--20071218, indra_w, REKSADN002, end            
--20130222, anthony, BARUS12010, begin  
--from dbo.ReksaCIFData_TM             
--where ClientId = @pnClientId            
--20130222, anthony, BARUS12010, end  
        
--20110114, victor, BAALN10002, begin        
--20110124, victor, BAALN10002, begin        
--if @nReksaTranType in (1, 2)           
if @nReksaTranType in (1, 2, 8)           
--20110124, victor, BAALN10002, end        
--20110915, liliana, BAALN10011, begin
--20140903, liliana, LIBST13021, begin
and (@pbIsAutoDebetRDB = 0)
--20140903, liliana, LIBST13021, end       
--begin        
--declare @nCIF     bigint        
--set @nCIF = convert (bigint, @cCIFNo)          
--exec dbo.ReksaGetMandatoryFieldStatus @nCIF, @cErrMsg output        
        
--if isnull (@cErrMsg, '') != ''        
--begin        
-- set @cErrMsg = @cErrMsg        
-- goto ERROR         
--end        
begin        
 declare @nCIF     bigint        
 set @nCIF = convert (bigint, @cCIFNo)       
       
 create table #TempErrorTable(        
 FieldName   varchar(50)        
 ,[Description]  varchar(500)        
)       
      
insert #TempErrorTable           
exec dbo.ReksaGetMandatoryFieldStatus @nCIF, @cErrMsg output      
      
--20110926, liliana, BAALN10011, begin      
--if exists(select top 1 1 from #TempErrorTable)      
if exists(select top 1 1 from #TempErrorTable) and (@pnType != 3)      
--20110926, liliana, BAALN10011, end      
begin      
 select * from #TempErrorTable       
 return 0      
end      
      
drop table #TempErrorTable      
end        
--20110114, victor, BAALN10002, end        
--20110915, liliana, BAALN10011, end       
        
--20091109, oscar, REKSADN017, begin        
select @nIsEmployee = isnull(IsEmployee, 0) from ReksaCIFData_TM where ClientId = @pnClientId            
select @cProdCode = ProdCode             
--20080402, indra_w, REKSADN002, begin            
  --, @mMinNew    = MinSubcNew            
  , @mMinNew    = case @nIsEmployee when 0 then MinSubcNew else MinSubcNewEmp end        
  --, @mMinAdd    = MinSubcAdd            
  , @mMinAdd    = case @nIsEmployee when 0 then MinSubcAdd else MinSubcAddEmp end        
  --, @mMinRedemp   = MinRedemption            
  , @mMinRedemp   = case @nIsEmployee when 0 then MinRedemption else MinRedemptionEmp end           
  , @mMinRedempbyUnit  = MinRedempByUnit            
  --, @mMinBalance   = MinBalance            
  , @mMinBalance   = case @nIsEmployee when 0 then MinBalance else MinBalanceEmp end          
  , @mMinBalanceByUnit = MinBalanceByUnit            
--20091109, oscar, REKSADN017, end        
--20080402, indra_w, REKSADN002, end        
--20080604, indra_w, REKSADN005, begin        
 , @nWindowPeriod = WindowPeriod            
 , @nManInvId = ManInvId        
--20080604, indra_w, REKSADN005, end        
--20080813, indra_w, REKSADN006, begin        
 , @nRedempType = RedempType        
--20080813, indra_w, REKSADN006, end        
from dbo.ReksaProduct_TM             
where ProdId = @pnProdId            
--20080813, indra_w, REKSADN006, begin           
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType in (3,4)                   
--20090723, oscar, REKSADN013, end        
begin        
 If @pbByUnit = 0 and @nRedempType = 2        
 Begin            
  set @cErrMsg = 'Redemption hanya boleh by Unit'            
  goto ERROR           
 End          
        
 If @pbByUnit = 1 and @nRedempType = 1        
 Begin            
  set @cErrMsg = 'Redemption hanya boleh by Nominal'            
  goto ERROR           
 End          
end        
--20080813, indra_w, REKSADN006, end        
        
--20080415, indra_w, REKSADN002, begin        
--20080604, indra_w, REKSADN005, begin        
select @nNDayBefore = NDayBefore        
from ReksaWindowPeriod_TM        
where ProdId = @pnProdId        
--20080604, indra_w, REKSADN005, end        
--select @dCurrWorkingDate = current_working_date            
--from dbo.fnGetWorkingDate()            
--20071218, indra_w, REKSADN002, begin            
--select @dCurrDate = current_working_date            
--from control_table            
--20080415, indra_w, REKSADN002, end        
            
exec @nOK = ABCSAccountInquiry            
 @pcAccountID = @cNISPAccId            
 ,@pnSubSystemNId = 111501            
 ,@pcTransactionBranch = '99965'            
 ,@pcProductCode = @cProductCode output            
 ,@pcCurrencyType = @cCurrencyType output            
 ,@pcAccountType =@cAccountType output            
 , @pcMultiCurrencyAllowed = @cMCAllowed output            
 , @pcAccountStatus = @cAccountStatus output            
--20071218, indra_w, REKSADN002, begin            
 , @pcTellerId = '7'            
--20071218, indra_w, REKSADN002, end            
            
--20080402, indra_w, REKSADN002, begin            
--If @cAccountStatus != '1'             
--20111213, liliana, LOGAM02011, begin 
--If @cAccountStatus not in ('1','4','9') -- selain aktif, new, atau dormant        
If @pbIsPartialMaturity = 0 and (@cAccountStatus not in ('1','4','9')) -- selain aktif, new, atau dormant dan bukan partial maturity     
--20111213, liliana, LOGAM02011, end      
--20080402, indra_w, REKSADN002, end            
--20090723, oscar, REKSADN013, begin        
Begin            
 set @cErrMsg = 'Relasi Sudah Tidak Aktif, Mohon Ganti Relasi!'            
 goto ERROR           
End            
--20071218, indra_w, REKSADN002, end           
-- support rek MC        
if @cMCAllowed = 'Y'        
begin        
 set @cNISPAccId = ltrim(SQL_SIBS.dbo.fnGetSIBSCurrencyCode(@pcTranCCY, 1) + ltrim(@cNISPAccId))        
 if (select SQL_SIBS.dbo.fnGetSIBSCurrencyCode(@pcTranCCY, 1)) <> ''         
  set @cCurrencyType = @pcTranCCY        
end        
--20090723, oscar, REKSADN013, end        
--20071205, indra_w, REKSADN002, begin            
If @pbByUnit = 0            
Begin            
--20080414, mutiara, REKSADN002, begin            
-- select  @mUnitPerkiraan = @pmTranAmt / @pmNAV         
--20080415, indra_w, REKSADN002, begin           
-- select  @mUnitPerkiraan = dbo.fnReksaSetRounding(@pnProdId,2,@pmTranAmt / @pmNAV)            
 select  @mUnitPerkiraan = dbo.fnReksaSetRounding(@pnProdId,2,cast(@pmTranAmt / @pmNAV as decimal(25,13)))            
--20080415, indra_w, REKSADN002, end        
--20080414, mutiara, REKSADN002, end            
End            
--20071205, indra_w, REKSADN002, end            
            
--20071207, indra_w, REKSADN002, begin            
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType in (1,2)            
--20090723, oscar, REKSADN013, end        
Begin            
 exec dbo.ReksaInqUnitNasDitwrkan @cCIFNo, @cProdCode, @mMaksUnit output, 0, '', @dCurrWorkingDate            
--20071205, indra_w, REKSADN002, begin            
--if @pmTranUnit > @mMaksUnit            
 if @mUnitPerkiraan > @mMaksUnit            
--20071205, indra_w, REKSADN002, end            
 begin            
--20080416, indra_w, REKSADN002, begin        
--  set @cErrMsg = 'Jumlah transaksi > jumlah unit ditawarkan (' + convert (varchar, @mMaksUnit) + ')'            
  set @cErrMsg = 'Jumlah transaksi > jumlah unit ditawarkan (' + convert (varchar(40), cast(@mMaksUnit as money),1) + ')'            
--20080416, indra_w, REKSADN002, end        
  goto ERROR            
 end            
--20071128, victor, REKSADN002, end            
end            
--20071207, indra_w, REKSADN002, end            
            
--20071120, indra_w, REKSADN002, begin            
if exists(select top 1 1 from ReksaTransaction_TT where TranId = @pnTranId and UserSuid = 7 )            
begin            
 set @cErrMsg = 'Transaksi dari proses READ ONLY'            
 goto ERROR            
end            
--20071120, indra_w, REKSADN002, end            
            
--cek status client            
if (select CIFStatus from dbo.ReksaCIFData_TM where ClientId = @pnClientId) != 'A'            
begin            
 set @cErrMsg = 'Transaksi ditolak, status client tidak aktif'            
 goto ERROR            
end            
            
--cek apakah currency transaksi sama dengan produk            
select @cProdCCY = ProdCCY            
from dbo.ReksaProduct_TM            
where ProdId = @pnProdId            
            
if @pcTranCCY != @cProdCCY            
begin            
 set @cErrMsg = 'Transaksi cross-currency tidak didukung'            
 goto ERROR            
end            
            
--cek subscription new           
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType = 1            
--20090723, oscar, REKSADN013, end        
begin            
--20071128, victor, REKSADN002, begin            
 if exists (select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId            
--20071130, victor, REKSADN002, begin            
  --and Status = 0)            
 and Status = 0            
 union            
 select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId            
--20090723, oscar, REKSADN013, begin        
--20090626, philip, REKSADN013, begin        
 --and Status = 0)            
  and Status = 0        
 union        
 select top 1 1 from dbo.ReksaTransaction_TT         
 where TranType = 8        
  and ClientId = @pnClientId        
  and Status = 0        
  and RegSubscriptionFlag = 1 --NEW, 2= ADD        
 union        
 select top 1 1 from dbo.ReksaTransaction_TH        
 where TranType = 8        
  and ClientId = @pnClientId        
  and Status = 0        
  and RegSubscriptionFlag = 1 --NEW, 2= ADD        
 )        
--20090626, philip, REKSADN013, end           
--20090723, oscar, REKSADN013, end        
--20071130, victor, REKSADN002, end            
 begin            
  set @cErrMsg = 'Client sudah pernah transaksi Subscription New, namun belum di reject / authorize'            
  goto ERROR            
 end            
--20071128, victor, REKSADN002, end            
 if exists (select TranId from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId            
--20071130, victor, REKSADN002, begin            
  --and Status = 1)            
   and Status = 1            
  union            
  select TranId from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId            
--20090723, oscar, REKSADN013, begin        
--20090626, philip, REKSADN013, begin        
  --and Status = 1)            
   and Status = 1        
  union         
  select top 1 1 from dbo.ReksaTransaction_TT         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
   and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
  union        
  select top 1 1 from dbo.ReksaTransaction_TH         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
   and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
 )              
--20090626, philip, REKSADN013, end        
--20090723, oscar, REKSADN013, end        
--20071130, victor, REKSADN002, end            
 begin            
  set @cErrMsg = 'Client sudah pernah transaksi Subscription New sebelumnya'            
  goto ERROR            
 end            
--20080402, indra_w, REKSADN002, begin            
 If @pbFullAmount = 1            
 Begin            
  if @pmTranAmt < @mMinNew            
  begin            
--20080415, indra_w, REKSADN002, begin        
   set @cErrMsg = 'Minimal New Subsc : ' + convert(varchar(40),cast(@mMinNew as money),1)            
--20080415, indra_w, REKSADN002, end        
   goto ERROR            
  end            
 End            
 else             
 Begin            
  if (@pmTranAmt - @pmSubcFee) < @mMinNew            
  begin            
--20080415, indra_w, REKSADN002, begin        
   set @cErrMsg = 'Minimal New Subsc : ' + convert(varchar(40), cast(@mMinNew as money),1)        
--20080415, indra_w, REKSADN002, end        
   goto ERROR            
  end           
 End            
--20080402, indra_w, REKSADN002, end            
end            
            
--cek subscription add            
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType = 2            
--20090723, oscar, REKSADN013, end      
begin            
 if not exists (select TranId from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId            
--20071203, victor, REKSADN002, begin            
  --and Status = 1)            
  and Status = 1            
  union            
  select TranId from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId            
--20090723, oscar, REKSADN013, begin        
--20090626, philip, REKSADN013, begin        
  --and Status = 1)            
and Status = 1        
  union         
  select top 1 1 from dbo.ReksaTransaction_TT         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
   and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
  union        
  select top 1 1 from dbo.ReksaTransaction_TH         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
 and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
 )              
--20090626, philip, REKSADN013, end             
--20090723, oscar, REKSADN013, end        
--20071203, victor, REKSADN002, end            
 begin            
  set @cErrMsg = 'Client belum pernah transaksi Subscription New sebelumnya'            
  goto ERROR            
 end            
--20080402, indra_w, REKSADN002, begin            
 If @pbFullAmount = 1            
 Begin            
  if @pmTranAmt < @mMinAdd            
  begin            
--20080415, indra_w, REKSADN002, begin        
--   set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(20),@mMinAdd)            
   set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(40), cast(@mMinAdd as money),1)            
--20080415, indra_w, REKSADN002, end        
   goto ERROR            
  end            
 End            
 else             
 Begin            
  if (@pmTranAmt - @pmSubcFee) < @mMinAdd            
  begin            
--20080415, indra_w, REKSADN002, begin        
--   set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(20),@mMinAdd)            
   set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(40),cast(@mMinAdd as money),1)        
--20080415, indra_w, REKSADN002, end        
   goto ERROR            
  end            
 End            
--20080402, indra_w, REKSADN002, end            
end            
            
--cek redemption apakah jumlahnya cukup            
--20090723, oscar, REKSADN013, begin        
if @nReksaTranType in (3, 4)            
--20090723, oscar, REKSADN013, end        
begin            
 select @mEffUnit = dbo.fnGetEffUnit(@pnClientId)            
            
 select top 1 @mLastNAV = NAV            
 from ReksaNAVParam_TH            
 where ProdId = @pnProdId            
 order by ValueDate desc            
--20071218, indra_w, REKSADN002, begin            
--20080414, mutiara, REKSADN002, begin            
-- select @mEffUnit = @mEffUnit - isnull(sum(case when ByUnit = 1 then TranUnit else TranAmt / @mLastNAV end), 0)            
--20080415, indra_w, REKSADN002, begin       
-- select @mEffUnit = @mEffUnit - isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(@pnProdId,2,TranAmt / @mLastNAV) end), 0)            
 select @mEffUnit = @mEffUnit - isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(@pnProdId,2,cast(TranAmt / @mLastNAV as decimal(25,13))) end), 0)            
--20080415, indra_w, REKSADN002, end        
--20080414, mutiara, REKSADN002, end            
 from ReksaTransaction_TT            
 where TranType in (3,4)            
 and Status in (0,1)            
 and ClientId = @pnClientId            
--20071218, indra_w, REKSADN002, end            
--20080216, indra_w, REKSADN002, begin            
 and ProcessDate is null            
--20080216, indra_w, REKSADN002, end     
--20120118, liliana, BAALN11008, begin  
  
select @mEffUnit = @mEffUnit - isnull(sum(case when rs.ByUnit = 1 then rs.TranUnit else dbo.fnReksaSetRounding(@pnProdId,2, cast(rs.TranAmt / @mLastNAV as decimal(25,13))) end), 0)  
from dbo.ReksaSwitchingTransaction_TM rs  
left join dbo.ReksaTransaction_TT rt  
on rs.TranCode = rt.TranCode  
where rs.TranType in (5,6)  
and rt.TranCode is null  
and rs.Status in (0,1)  
and rs.ClientIdSwcOut = @pnClientId  
  
--20120118, liliana, BAALN11008, end        
--20120809, dhanan, LOGAM02012, begin  
and rs.BillId is null  
--20120809, dhanan, LOGAM02012, end  
 if @pbByUnit = 1            
 begin            
--20080425, indra_w, REKSADN002, begin        
  if round(@pmTranUnit,4) > round(@mEffUnit,4)        
--20080425, indra_w, REKSADN002, end        
  begin            
   set @cErrMsg = 'Unit Balance client tidak mencukupi'            
   goto ERROR            
  end            
 end            
 else            
 begin            
--20080425, indra_w, REKSADN002, begin        
  if round(@pmTranAmt,2) > round(@mEffUnit* isnull(@mLastNAV,0),2)        
--20080425, indra_w, REKSADN002, end        
  begin            
   set @cErrMsg = 'Nominal Balance client tidak mencukupi'             
   goto ERROR            
  end            
 end            
--20080402, indra_w, REKSADN002, begin            
 -- cek minimal penarikan           
--20090723, oscar, REKSADN013, begin       
--20111021, liliana, BAALN10012, begin  
-- if @nReksaTranType = 3 
--20150304, dhanan, LOGAM06837, begin
if @nReksaTranType = 4 
	and isnull(@pnNIK,0) <> 7
	and isnull(@pbByUnit,0) = 1
begin
	if isnull(@pnUserSuid,0) <> 7
	begin
		if round(@pmTranUnit,0) != round(@mEffUnit,0)             
		begin            
			set @cErrMsg = 'Untuk Redemp All, Tran Unit '+ convert(varchar,round(@pmTranUnit,4)) +' harus sama dengan Unit Balance'  + convert(varchar,round(@mEffUnit,4))          
			goto ERROR
		end            
	end      
end
--20150304, dhanan, LOGAM06837, end           
if @nReksaTranType = 3 and @pbIsPartialMaturity = 0     
--20111021, liliana, BAALN10012, end  
--20090723, oscar, REKSADN013, end        
 Begin            
  If @mMinRedempbyUnit = 1 -- pengecekan berdasarkan unit            
  Begin            
   if @pbByUnit = 1            
   Begin            
    if @pmTranUnit < @mMinRedemp                
    begin            
--20080415, indra_w, REKSADN002, begin        
--     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(20),@mMinRedemp) + ' Unit'            
     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' Unit'            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
   Else            
   Begin            
    if @pmTranAmt/@mLastNAV < @mMinRedemp            
    begin       
--20080415, indra_w, REKSADN002, begin        
--     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(20),@mMinRedemp) + ' Unit Perkiraan'            
     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' Unit Perkiraan'            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
  End            
  else             
  Begin            
   if @pbByUnit = 1            
   Begin            
  if @pmTranUnit *  @mLastNAV < @mMinRedemp            
    begin            
--20080415, indra_w, REKSADN002, begin        
--     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(20),@mMinRedemp) + ' '+ @cProdCCY + '(Perkiraan)'            
     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' '+ @cProdCCY + '(Perkiraan)'            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
   Else            
  Begin            
    if @pmTranAmt < @mMinRedemp            
    begin            
--20080415, indra_w, REKSADN002, begin        
--     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(20),@mMinRedemp) + ' '+ @cProdCCY            
     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' '+ @cProdCCY            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
  End            
            
  If @mMinBalanceByUnit = 1 -- pengecekan berdasarkan unit            
  Begin            
   if @pbByUnit = 1            
   Begin            
    if @mEffUnit - @pmTranUnit < @mMinBalance 
    begin            
--20080415, indra_w, REKSADN002, begin        
     set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit, sebaiknya REDEMP ALL'            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
   Else            
   Begin            
    if @mEffUnit - (@pmTranAmt/@mLastNAV) < @mMinBalance            
    begin            
--20080415, indra_w, REKSADN002, begin        
     set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit Perkiraan, sebaiknya REDEMP ALL'            
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
  End            
  else             
  Begin            
   if @pbByUnit = 1            
   Begin            
    if (@mEffUnit * @mLastNAV) - (@pmTranUnit * @mLastNAV)  < @mMinBalance            
    begin            
--20080415, indra_w, REKSADN002, begin        
--20080416, mutiara, REKSADN002, begin             
--  set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY + ' , sebaiknya REDEMP ALL'            
 set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY + ' , sebaiknya REDEMP ALL'            
--20080416, mutiara, REKSADN002, end        
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
   Else            
   Begin            
    if (@mEffUnit * @mLastNAV) - @pmTranAmt < @mMinBalance            
    begin            
--20080415, indra_w, REKSADN002, begin        
--20080416, mutiara, REKSADN002, begin             
--     set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY+ ' , sebaiknya REDEMP ALL'            
  set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY+ ' , sebaiknya REDEMP ALL'            
--20080416, mutiara, REKSADN002, end        
--20080415, indra_w, REKSADN002, end        
     goto ERROR            
    end             
   End            
  End            
 End            
--20080402, indra_w, REKSADN002, end            
end            
--20090723, oscar, REKSADN013, begin        
--20090626, philip, REKSADN013, begin          
if @nReksaTranType = 8        
begin        
 if exists (        
  select top 1 1         
  from dbo.ReksaTransaction_TT         
  where TranType = 1 and ClientId = @pnClientId            
   and Status = 1            
  union all        
  select top 1 1         
  from dbo.ReksaTransaction_TH         
  where TranType = 1         
   and ClientId = @pnClientId            
   and Status = 1        
  union         
  select top 1 1         
  from dbo.ReksaTransaction_TT         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
   and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
  union        
  select top 1 1         
  from dbo.ReksaTransaction_TH         
  where TranType = 8 --reguler subscription        
   and ClientId = @pnClientId        
   and Status = 1 and RegSubscriptionFlag = 1 --NEW! 2= ADD        
 )              
  select @nRegSubscriptionFlag = 2        
 else        
  select @nRegSubscriptionFlag = 1         
end        
--20090626, philip, REKSADN013, end            
--20090723, oscar, REKSADN013, end        
--cek sekarang udah lewat cutoff time belum            
select @nCutOff = CutOff, @bProcessStatus = ProcessStatus            
from dbo.ReksaUserProcess_TR           
--20090723, oscar, REKSADN013, begin        
--20090818, oscar, REKSADN013, begin        
--where ProcessId = (case when @nReksaTranType in (1,2) then 1 when @nReksaTranType in (3,4) then 2 end)            
where ProcessId = (case when @nReksaTranType in (1,2,8) then 1 when @nReksaTranType in (3,4) then 2 end)            
--20090818, oscar, REKSADN013, end        
--20090723, oscar, REKSADN013, end    
select @dCurrWorkingDate = current_working_date, @dNextWorkingDate = next_working_date            
from dbo.fnGetWorkingDate()            
            
set @dCutOff = dateadd (minute, @nCutOff, @dCurrWorkingDate)            
set @dCurrWorkingDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())            
            
if (@dCurrWorkingDate < @dCutOff) and (@bProcessStatus = 0)            
begin            
 set @pdNAVValueDate = @dCurrWorkingDate        
end            
else            
begin            
--20071218, indra_w, REKSADN002, begin            
--20071218, indra_w, REKSADN002, begin            
 If @dCurrDate!=convert(datetime, convert(char(8),@dCurrWorkingDate,112))            
--20071218, indra_w, REKSADN002, end            
  set @pdNAVValueDate = @dCurrWorkingDate            
else            
--20140905, liliana, LIBST13021, begin
begin
	if(@pbIsAutoDebetRDB = 1)
	begin
		set @pdNAVValueDate = @dCurrWorkingDate      
	end
	else
	begin
--20140905, liliana, LIBST13021, end
 set @pdNAVValueDate = @dNextWorkingDate            
 set @pcWarnMsg = 'Valuedate dari transaksi ini : ' + convert (varchar, @pdNAVValueDate, 103)            
--20071218, indra_w, REKSADN002, end
--20140905, liliana, LIBST13021, begin
	end
end
--20140905, liliana, LIBST13021, endd            
end            
--20080604, indra_w, REKSADN005, begin        
--20080710, indra_w, REKSADN007, begin   
--20120118, liliana, BAALN11008, begin  
--pengecekan antara switching dan transaksi  
--20120207, liliana, BAALN11008, begin  
--if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and NAVValueDate  = @dCurrWorkingDate and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, end  
--20120213, liliana, BAALN11008, end  
--20120207, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan switching all hari ini.'                     
 goto ERROR    
end  
--20120207, liliana, BAALN11008, begin  
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and NAVValueDate  = @dCurrWorkingDate and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, end  
--20120213, liliana, BAALN11008, end  
--20120207, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan redempt all hari ini.'                     
 goto ERROR    
end  
--20120118, liliana, BAALN11008, begin  
--else if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and NAVValueDate  = @dCurrWorkingDate and ClientIdSwcOut = @pnClientId)  
--20120207, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and NAVValueDate  = @dCurrWorkingDate and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)  
--20120213, liliana, BAALN11008, end  
--20120213, liliana, BAALN11008, end  
--20120207, liliana, BAALN11008, end  
--20120118, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah di switch out hari ini.'                     
 goto ERROR    
end  
--20120118, liliana, BAALN11008, begin  
--else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and NAVValueDate  = @dCurrWorkingDate and ClientId = @pnClientId)  
--20120207, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and NAVValueDate  = @dCurrWorkingDate and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20120213, liliana, BAALN11008, end  
--20120213, liliana, BAALN11008, end  
--20120207, liliana, BAALN11008, end  
--20120118, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah redempt hari ini.'                     
 goto ERROR    
end  
--20120213, liliana, BAALN11008, begin  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcIn = @pnClientId)  
else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcIn = @pnClientId)  
--20120213, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah di switch in hari ini.'                     
 goto ERROR    
end  
--20120213, liliana, BAALN11008, begin  
--else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2) and Status = 1 and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20141002, liliana, LIBST13021, begin
--else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2,8) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20141002, liliana, LIBST13021, end
--20120213, liliana, BAALN11008, end  
begin  
 set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah subs new/add hari ini.'                     
 goto ERROR    
end  
--20120213, liliana, BAALN11008, end  
--20121008, liliana, BAALN11003, begin  
--20121019, liliana, BAALN11003, begin    
--else if @nReksaTranType in (4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3) and Status in (0, 1) and ExtStatus not in (10,20) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)  
--20121019, liliana, BAALN11003, begin  
--else if @nReksaTranType in (4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3) and Status in (0, 1) and ExtStatus not in (10,20) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId  
--20131106, liliana, BAALN11010, begin
--else if @nReksaTranType in (4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId  
--20131106, liliana, BAALN11010, end
--20121019, liliana, BAALN11003, end 
--20131106, liliana, BAALN11010, begin 
--and ProcessDate is null  
--20131106, liliana, BAALN11010, end
--20121019, liliana, BAALN11003, begin 
--20131106, liliana, BAALN11010, begin 
--and isnull(ExtStatus,0) not in (10,20)
--20131106, liliana, BAALN11010, end  
--20121019, liliana, BAALN11003, end 
--20131106, liliana, BAALN11010, begin 
--)  
--20131106, liliana, BAALN11010, end
--20121019, liliana, BAALN11003, end
--20131106, liliana, BAALN11010, begin  
--begin  
-- declare @cNoTranCode varchar(20)  
   
-- select @cNoTranCode = isnull(TranCode,'')   
-- from dbo.ReksaTransaction_TT   
-- where TranType in (3) and Status in (0, 1)
--20131106, liliana, BAALN11010, end    
--20121019, liliana, BAALN11003, begin   
  --and ExtStatus not in (10,20)  
--20131106, liliana, BAALN11010, begin  
--  and isnull(ExtStatus,0) not in (10,20) 
--20131106, liliana, BAALN11010, end   
--20121019, liliana, BAALN11003, end
--20131106, liliana, BAALN11010, begin    
--  and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId  
   
-- set @cErrMsg = 'Sudah dilakukan redemption sebagian dengan TransCode : '+@cNoTranCode+', silahkan reject/reverse transaksi tersebut kemudian input kembali redemption all.'                     
-- goto ERROR    
--end  
--20131106, liliana, BAALN11010, end
--20121008, liliana, BAALN11003, end  
   
--20120118, liliana, BAALN11008, end       
--if @nWindowPeriod = 1        
-- and dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate) = 0        
--20090723, oscar, REKSADN013, begin        
-- and @nReksaTranType in (3,4)        
--20090723, oscar, REKSADN013, end        
--Begin            
-- set @cErrMsg = 'Tidak Boleh Redemp di luar Window Period'            
-- goto ERROR            
--End         
--20090723, oscar, REKSADN013, begin        
--20111013, liliana, BAALN10012, begin      
--if @nWindowPeriod = 1 and @nReksaTranType in (3,4)        
if @nWindowPeriod = 1 and @nReksaTranType in (3,4) and @pbIsPartialMaturity = 0      
--20111013, liliana, BAALN10012, end      
--20090723, oscar, REKSADN013, end    
Begin        
 if(@pbByUnit=0)        
 begin        
   if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate,@mUnitPerkiraan) =  0        
   Begin            
     set @cErrMsg = 'Tidak Boleh Redemp di luar Window Period'            
     goto ERROR            
   End          
   if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate,@mUnitPerkiraan) =  2        
   Begin            
     set @cErrMsg = 'Nilai Redemp melebihi nilai AUM'            
     goto ERROR            
   End            
 end        
 else        
 begin        
   if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate,@pmTranUnit) =  0        
   Begin            
     set @cErrMsg = 'Tidak Boleh Redemp di luar Window Period'            
     goto ERROR            
   End          
   if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate,@pmTranUnit) =  2        
   Begin            
     set @cErrMsg = 'Nilai Redemp melebihi nilai AUM'            
     goto ERROR            
   End        
 end        
end        
--20080710, indra_w, REKSADN007, end        
        
--20080414, mutiara, REKSADN002, begin                
if isnull(@nWindowPeriod,0) = 0        
Begin        
 if @pbByUnit=0            
 begin       
--20120213, liliana, BAALN11008, begin              
  --if (@pmTranAmt>5000000000) and @nManInvId = 1     
  if (@pmTranAmt>5000000000) and @nManInvId = 1 and @pnProdId != @nProdIdException  
--20120213, liliana, BAALN11008, end       
  begin         
--20111021, liliana, BAALN10012, begin         
   --set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)      
   if(@pbIsPartialMaturity = 0)    
   begin    
  set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)    
   end           
--20111021, liliana, BAALN10012, end       
   set @nExtStatus=2            
  end            
 end             
 else if @pbByUnit=1 and @nManInvId = 1        
 begin  
--20120213, liliana, BAALN11008, begin          
  --if ((@pmTranUnit*@mLastNAV)>5000000000) and @nManInvId = 1  
  if ((@pmTranUnit*@mLastNAV)>5000000000) and @nManInvId = 1 and @pnProdId != @nProdIdException    
--20120213, liliana, BAALN11008, end        
  begin            
--20111021, liliana, BAALN10012, begin        
   --set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)    
  if(@pbIsPartialMaturity = 0)    
   begin    
  set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)    
   end               
--20111021, liliana, BAALN10012, end         
   set @nExtStatus=2            
  end            
 end          
End    
else        
Begin        
--20111021, liliana, BAALN10012, begin    
-- set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,3)     
 if(@pbIsPartialMaturity = 0)    
 begin    
   set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,3)     
 end    
--20111021, liliana, BAALN10012, end             
 if @nNDayBefore != 0        
 Begin        
  set @pcWarnMsg = 'Valuedate dari transaksi ini : ' + convert (varchar, @pdNAVValueDate, 103)            
  set @nExtStatus=6        
 End        
End        
--20080414, mutiara, REKSADN002, end            
--20080604, indra_w, REKSADN005, end        
--20080416, mutiara, REKSADN002, begin        
--20090723, oscar, REKSADN013, begin        
if((@nReksaTranType=1) or (@nReksaTranType=2))        
--20090723, oscar, REKSADN013, end        
begin        
 set @dGoodFund = null        
end        
else        
begin        
--20080604, indra_w, REKSADN005, begin        
 If @nExtStatus = 2   
--20130828, liliana, BAALN11010, begin      
  --set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,4)  
  set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId, convert(varchar,@pdNAVValueDate,112) ,4)  
--20130828, liliana, BAALN11010, end       
 else        
--20130828, liliana, BAALN11010, begin  
  --set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,2)
  set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId,convert(varchar,@pdNAVValueDate,112) ,2)
--20130828, liliana, BAALN11010, end           
--20080604, indra_w, REKSADN005, end        
end        
--20080416, mutiara, REKSADN002, end
--20130701, liliana, BAFEM12011, begin
--cek good fund
if exists(select top 1 1 from ReksaHolidayTable_TM where ValueDate = @dGoodFund)
	or DATEPART(dw, @dGoodFund) in (1,7)
begin
  set @cErrMsg = 'Good Fund tidak dapat jatuh di hari libur!'        
  goto ERROR 
end	
--20130701, liliana, BAFEM12011, end        
            
if @pnType = 1            
begin            
--20071126, victor, REKSADN002, begin            
 select @dCurrWorkingDate = current_working_date            
 from dbo.fnGetWorkingDate()            
            
--20080402, indra_w, REKSADN002, begin            
--  set @pdTranDate = dateadd(hour, (datepart(hour, getdate())), (dateadd(minute, (datepart(minute, getdate())), @pdTranDate)))            
 set @pdTranDate  = getdate()            
--20071126, victor, REKSADN002, end            
--20080402, indra_w, REKSADN002, end            
            
 select @cClientCode = ClientCode            
 from dbo.ReksaCIFData_TM            
 where ClientId = @pnClientId            
            
 update dbo.ReksaClientCounter_TR            
 set Trans = @nCounter            
  , @nCounter = isnull(Trans, 0) + 1            
 where ProdId = @pnProdId            
            
 set @c5DigitCounter = right ( ('00000' + convert(varchar, @nCounter)) , 5)            
 set @c3DigitClientCode = left (@cClientCode, 3)            
            
 set @pcTranCode = @c3DigitClientCode + @c5DigitCounter            
            
--20071126, indra_w, REKSADN002, begin            
--20080414, mutiara, REKSADN002, begin   
--20130107, liliana, BATOY12006, begin            
 --select @nWindowPeriod=WindowPeriod,@nSubFeeBased = c.SubcFeeBased     
 select @nWindowPeriod=WindowPeriod     
--20130107, liliana, BATOY12006, end        
--20080414, mutiara, REKSADN002, end           
 from ReksaProduct_TM a join ReksaProductParam_TM b            
   on a.ParamId = b.ParamId            
  join ReksaProductFee_TR c            
   on b.FeeId = c.FeeId            
 where a.ProdId = @pnProdId            
--20080414, mutiara, REKSADN002, begin            
-- select @mFeeBased = (@nSubFeeBased/100.00) * @pmSubcFee         
--20080415, indra_w, REKSADN002, begin           
-- select @mFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,(@nSubFeeBased/100.00) * @pmSubcFee)      
--20130107, liliana, BATOY12006, begin    
--pembagian subc/redemp fee based  
--20130128, liliana, BATOY12006, begin  
if @nReksaTranType in (1,2,8)  
begin  
--20130128, liliana, BATOY12006, end  
select @nSubFeeBased = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 1  
--20130107, liliana, BATOY12006, end        
--20130206, liliana, BATOY12006, begin  
if isnull(@nSubFeeBased, 0) = 0  
begin  
  set @cErrMsg = 'Nilai persentase subs fee based tidak ditemukan!'            
     goto ERROR    
end  
--20130206, liliana, BATOY12006, end  
--20130226, liliana, BATOY12006, begin  
 --select @mFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nSubFeeBased/100.00 as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
select @mFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nSubFeeBased/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))        
--20130226, liliana, BATOY12006, end        
--20080415, indra_w, REKSADN002, end        
--20080414, mutiara, REKSADN002, end            
            
 if @mFeeBased > @pmSubcFee            
  set @mFeeBased = @pmSubcFee            
--20071126, indra_w, REKSADN002, end  
--20130107, liliana, BATOY12006, begin  
--pembagian pajak fee based  
select @nPercentageTaxFee = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 2  
--20130206, liliana, BATOY12006, begin  
if isnull(@nPercentageTaxFee, 0) = 0  
begin  
  set @cErrMsg = 'Nilai persentase tax fee based tidak ditemukan!'            
     goto ERROR    
end  
--20130206, liliana, BATOY12006, end   
  
--20130226, liliana, BATOY12006, begin  
--select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/100.00 as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mTaxFeeBased > @pmSubcFee            
  set @mTaxFeeBased = @pmSubcFee       
  
--pembagian fee based 3 (jika ada)  
select @nPercentageFee3 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 3  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/100.00 as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased3 > @pmSubcFee            
  set @mFeeBased3 = @pmSubcFee   
    
--pembagian fee based 4 (jika ada)      
select @nPercentageFee4 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 4  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/100.00 as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased4 > @pmSubcFee            
  set @mFeeBased4 = @pmSubcFee   
  
--pembagian fee based 5 (jika ada)      
select @nPercentageFee5 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 5  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/100.00 as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased5 > @pmSubcFee            
  set @mFeeBased5 = @pmSubcFee   
    
--total fee based  
set @mTotalFeeBased = isnull(@mFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)  
  
--20130402, liliana, BATOY12006, begin  
--if @mTotalFeeBased > @pmSubcFee  
-- set @mTotalFeeBased = @pmSubcFee  
select @mSelisihFee = @pmSubcFee - @mTotalFeeBased   
  
select @mFeeBased = isnull(@mFeeBased, 0) + @mSelisihFee  
--20130402, liliana, BATOY12006, end   
--20130107, liliana, BATOY12006, end  
--20130128, liliana, BATOY12006, begin  
--20130418, liliana, BATOY12006, begin  
set @mTotalFeeBased = isnull(@mFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)   
--20130418, liliana, BATOY12006, end  
end  
else if @nReksaTranType in (3,4)  
begin  
 select @nPercentageRedempFee = isnull(Percentage,0)  
 from dbo.ReksaListGLFee_TM  
 where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 1  
--20130206, liliana, BATOY12006, begin  
if isnull(@nPercentageRedempFee, 0) = 0  
begin  
  set @cErrMsg = 'Nilai persentase redemp fee based tidak ditemukan!'            
     goto ERROR    
end  
--20130206, liliana, BATOY12006, end  
  
--20130226, liliana, BATOY12006, begin      
 --select @mRedempFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageRedempFee/100.00 as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
 select @mRedempFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageRedempFee/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))   
--20130226, liliana, BATOY12006, end             
           
 if @mRedempFeeBased > @pmRedempFee            
  set @mRedempFeeBased = @pmRedempFee    
  
--pembagian pajak fee based  
select @nPercentageTaxFee = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 2  
--20130206, liliana, BATOY12006, begin  
if isnull(@nPercentageTaxFee, 0) = 0  
begin  
  set @cErrMsg = 'Nilai persentase redemp fee based tidak ditemukan!'            
     goto ERROR    
end  
--20130206, liliana, BATOY12006, end  
  
--20130226, liliana, BATOY12006, begin  
--select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/100.00 as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mTaxFeeBased > @pmRedempFee            
  set @mTaxFeeBased = @pmRedempFee       
  
--pembagian fee based 3 (jika ada)  
select @nPercentageFee3 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 3  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/100.00 as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased3 > @pmRedempFee            
  set @mFeeBased3 = @pmRedempFee   
    
--pembagian fee based 4 (jika ada)      
select @nPercentageFee4 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 4  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/100.00 as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased4 > @pmRedempFee            
  set @mFeeBased4 = @pmRedempFee   
  
--pembagian fee based 5 (jika ada)      
select @nPercentageFee5 = isnull(Percentage,0)  
from dbo.ReksaListGLFee_TM  
where TrxType = @cTrxType  
 and ProdId = @pnProdId  
 and Sequence = 5  
  
--20130226, liliana, BATOY12006, begin  
--select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/100.00 as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))  
--20130226, liliana, BATOY12006, end  
  
if @mFeeBased5 > @pmRedempFee            
  set @mFeeBased5 = @pmRedempFee   
    
--total fee based  
set @mTotalRedempFeeBased = isnull(@mRedempFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)  
  
--20130402, liliana, BATOY12006, begin  
--if @mTotalRedempFeeBased > @pmRedempFee  
-- set @mTotalRedempFeeBased = @pmRedempFee     
select @mSelisihFee = @pmRedempFee - @mTotalRedempFeeBased   
  
select @mRedempFeeBased = isnull(@mRedempFeeBased, 0) + @mSelisihFee  
--20130402, liliana, BATOY12006, end  
--20130418, liliana, BATOY12006, begin  
set @mTotalRedempFeeBased = isnull(@mRedempFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)  
--20130418, liliana, BATOY12006, end  
end  
--20130128, liliana, BATOY12006, end            
            
--20080414, mutiara, REKSADN002, begin            
--20080415, indra_w, REKSADN002, begin        
--if(@pnProdId=1)          
--begin          
-- set @nHariTgl=day(getdate())          
-- if exists(select tgl from ReksaWindowPeriod_TM where tgl between 1 and @nHariTgl)          
-- begin          
--  set @bInsert=0;          
-- end          
-- else          
-- begin          
--  set @bInsert=1;          
-- end          
--end          
--20080414, mutiara, REKSADN002, end          
--20080415, indra_w, REKSADN002, end        
          
--20080414, mutiara, REKSADN002, begin          
--20080415, indra_w, REKSADN002, begin        
--if(@bInsert=0)          
--begin          
--20090723, oscar, REKSADN013, begin        
--tambah detail dokumen lainnya        
--20120327, liliana, BAALN11026, begin      
SET @pcWarnMsg2 = '' 
--20130520, liliana, BAFEM12011, begin
set @pcWarnMsg3 = ''

--20130531, liliana, BAFEM12011, begin
IF(@nReksaTranType IN(1,2,8))     
begin
--20130531, liliana, BAFEM12011, end
--cek umur nasabah
 exec ReksaHitungUmur @cCIFNo, @nUmur output  

 if(@nUmur >= 55)
 begin
	SET @pcWarnMsg3 = 'Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching'
 end
--20130520, liliana, BAFEM12011, end       
--20130531, liliana, BAFEM12011, begin
end
--20130531, liliana, BAFEM12011, end
  
--20120403, liliana, BAALN11026, begin    
--IF(@pnTranType IN(1,2,8))    
IF(@nReksaTranType IN(1,2,8))    
--20120403, liliana, BAALN11026, end  
BEGIN    
  -- GET PRODUCT RISK      
 SELECT @nProductRiskProfile = rprp.RiskProfile      
 FROM [dbo].[ReksaProduct_TM] rp      
 LEFT JOIN [dbo].[ReksaProductRiskProfile_TM] rprp      
  ON rp.[ProdCode] = rprp.[ProductCode]      
  WHERE rp.[ProdId] = @pnProdId      
        
  -- GET CUSTOMER RISK      
 SELECT @nCustomerRiskProfile = CASE      
    WHEN LOWER(cf.[CFUIC8]) = 'a' THEN 1      
    WHEN LOWER(cf.[CFUIC8]) = 'b' THEN 2      
    WHEN LOWER(cf.[CFUIC8]) = 'c' THEN 3      
    WHEN LOWER(cf.[CFUIC8]) = 'd' THEN 4      
    ELSE 0      
   END      
 FROM [dbo].[ReksaCIFData_TM] rc      
 JOIN [dbo].[CFMAST_v] cf      
  ON CONVERT(bigint, rc.[CIFNo]) = CONVERT(bigint, cf.[CFCIF])      
  WHERE rc.[ClientId] = @pnClientId      
        
 IF(@nCustomerRiskProfile < @nProductRiskProfile)      
 BEGIN      
--20120410, liliana, BAALN11026, begin   
  --SET @pcWarnMsg2 = 'Apakah nasabah sudah menandatangani kolom Profile Resiko di Formulir Subscription?'   
    SET @pcWarnMsg2 = 'Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah. Apakah Nasabah sudah sudah menandatangi kolom Profil Risiko pada Subscription/Switching Form?'   
--20120410, liliana, BAALN11026, end       
 END      
end     
--20120327, liliana, BAALN11026, end  
 begin tran        
--20090723, oscar, REKSADN013, end        
 insert dbo.ReksaTransaction_TT (TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId,            
  TranCCY, TranAmt, TranUnit, SubcFee, RedempFee, NAV, NAVValueDate, UnitBalance, UnitBalanceNom,            
--20071123, victor, REKSADN002, begin            
  --UserSuid, WMOtor, Status, ByUnit)            
--20071126, indra_w, REKSADN002, begin            
--  UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId)        
--20080414, mutiara, REKSADN002, begin            
--  UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased)            
--20090723, oscar, REKSADN013, begin        
--  UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,ExtStatus,GoodFund)            
  UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,ExtStatus,GoodFund            
,DocFCSubscriptionForm                  
,DocFCDevidentAuthLetter                 
,DocFCJoinAcctStatementLetter            
,DocFCIDCopy                             
,DocFCOthers                             
,DocTCSubscriptionForm                   
,DocTCTermCondition                      
,DocTCProspectus                         
,DocTCFundFactSheet                      
,DocTCOthers                        
--20090625, philip, REKSADN013, begin        
,JangkaWaktu        
,JatuhTempo        
,AutoRedemption        
,GiftCode        
,BiayaHadiah        
,RegSubscriptionFlag        
,Asuransi        
--20090625, philip, REKSADN013, end        
--20090803, oscar, REKSADN013, begin        
,Inputter, Seller, Waperd        
--20090803, oscar, REKSADN013, end      
--20110915, liliana, BAALN10011, begin        
, FrekPendebetan        
--20110915, liliana, BAALN10011, end   
--20120202, liliana, BAALN11008, begin  
, IsFeeEdit  
--20120202, liliana, BAALN11008, end      
--20130107, liliana, BATOY12006, begin  
--20130128, liliana, BATOY12006, begin  
, RedempFeeBased, TotalRedempFeeBased  
--20130128, liliana, BATOY12006, end  
, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased  
, JenisPerhitunganFee, PercentageFee  
--20130107, liliana, BATOY12006, end
--20130515, liliana, BAFEM12011, begin
, Channel
--20130515, liliana, BAFEM12011, end    
)             
--20090723, oscar, REKSADN013, end        
--20080414, mutiara, REKSADN002, end            
--20071126, indra_w, REKSADN002, end            
--20071123, victor, REKSADN002, end            
--20090723, oscar, REKSADN013, begin        
 select @pcTranCode, @nReksaTranType, @pdTranDate, @pnProdId, @pnClientId, @pnFundId, @pnAgentId, @pcTranCCY,             
--20090723, oscar, REKSADN013, end        
--20071129, indra_w, REKSADN002, begin            
--  @pmTranAmt, @pmTranUnit, @pmSubcFee, @pmRedempFee, @pmNAV, @pdNAVValueDate, @pmUnitBalance,             
  @pmTranAmt, @pmTranUnit, @pmSubcFee, @pmRedempFee, @pmNAV, convert(char(8),@pdNAVValueDate,112), @pmUnitBalance,             
--20071129, indra_w, REKSADN002, end            
  @pmUnitBalanceNom, @pnUserSuid, @pbWMOtor, 0, @pbByUnit            
--20071123, victor, REKSADN002, begin            
--20071126, indra_w, REKSADN002, begin            
--20080414, mutiara, REKSADN002, begin            
  , @pbFullAmount, @pnSalesId, isnull(@mFeeBased, 0)            
--20080416, mutiara, REKSADN002, begin        
--20090723, oscar, REKSADN013, begin        
--  , @nExtStatus, dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,2)            
  , @nExtStatus, @dGoodFund        
,@pbDocFCSubscriptionForm                  
,@pbDocFCDevidentAuthLetter                 
,@pbDocFCJoinAcctStatementLetter            
,@pbDocFCIDCopy                             
,@pbDocFCOthers                             
,@pbDocTCSubscriptionForm                   
,@pbDocTCTermCondition                      
,@pbDocTCProspectus                         
,@pbDocTCFundFactSheet                      
,@pbDocTCOthers             
--20090625, philip, REKSADN013, begin        
,@pnJangkaWaktu        
,@pdJatuhTempo        
,@pnAutoRedemption        
,@pcGiftCode        
,@pnBiayaHadiah        
,@nRegSubscriptionFlag        
,@pnAsuransi        
--20090625, philip, REKSADN013, end        
--20090803, oscar, REKSADN013, begin        
,@pcInputter, @pnSeller, @pnWaperd        
--20090803, oscar, REKSADN013, end        
--20110915, liliana, BAALN10011, begin        
, @pnFrekuensiPendebetan        
--20110915, liliana, BAALN10011, end      
--20120202, liliana, BAALN11008, begin  
, @pbIsFeeEdit  
--20120202, liliana, BAALN11008, end     
--20130107, liliana, BATOY12006, begin  
--20130128, liliana, BATOY12006, begin  
, isnull(@mRedempFeeBased, 0), isnull(@mTotalRedempFeeBased,0)  
--20130128, liliana, BATOY12006, end  
, isnull(@mTaxFeeBased,0) , isnull(@mFeeBased3,0), isnull(@mFeeBased4,0), isnull(@mFeeBased5,0)  
, isnull(@mTotalFeeBased,0)  
, @pbJenisPerhitunganFee, @pdPercentageFee  
--20130107, liliana, BATOY12006, end
--20130515, liliana, BAFEM12011, begin
, @cChannel
--20130515, liliana, BAFEM12011, end      
        
 if @@error <> 0        
 begin        
 set @cErrMsg = 'Gagal insert data ReksaTransaction_TT'        
 rollback tran        
 goto ERROR        
end        
         
 -- data dokumen lainnya        
 select @pnTranId = scope_identity()    
        
--20090625, philip, REKSADN013, begin        
if @nReksaTranType = 8 and @pnRegTransactionNextPayment = 0        
begin        
 insert dbo.ReksaRegulerSubscriptionSchedule_TT(TranId, ScheduledDate, Type,         
  TranAmount, NAV, NAVValueDate, StatusId, LastAttemptDate)        
 select @pnTranId, ScheduledDate, Type,        
  @pmTranAmt, 0, null, 0, null        
--20090904, oscar, REKSADN013, begin         
-- from dbo.fnGetReksaScheduledDate(@pdTranDate, @pnJangkaWaktu, @pnAutoRedemption)      
--20110915, liliana, BAALN10011, begin         
 --from dbo.fnGetReksaScheduledDate(@dCurrDate, @pnJangkaWaktu, @pnAutoRedemption)   
--20140313, liliana, LIBST13021, begin    
  --from dbo.fnGetReksaScheduledDate(@dCurrDate, @pnJangkaWaktu, @pnAutoRedemption, @pnFrekuensiPendebetan)    
  from dbo.fnGetReksaScheduledDate(@dJoinDate, @pnJangkaWaktu, @pnAutoRedemption, @pnFrekuensiPendebetan)  
--20140313, liliana, LIBST13021, end         
--20110915, liliana, BAALN10011, end         
         
 update dbo.ReksaRegulerSubscriptionSchedule_TT        
 set StatusId = 1        
  , LastAttemptDate = @pdTranDate        
  , NAVValueDate = convert(varchar(8), @pdNAVValueDate, 112)        
  , NAV = @pmNAV        
 where TranId = @pnTranId 
--20140313, liliana, LIBST13021, begin            
  --and ScheduledDate = convert(varchar(8), @dCurrDate, 112)
  and ScheduledDate = convert(varchar(8), @dJoinDate, 112)    
--20140313, liliana, LIBST13021, end         
--20090904, oscar, REKSADN013, end        
end        
--20090625, philip, REKSADN013, end        
 -- DocFCOtherList        
 delete from ReksaOtherDocuments_TM        
 where TranId = @pnTranId  
--20120208, liliana, BAALN11008, begin  
 and isnull(IsSwitching, 0) = 0  
--20120208, liliana, BAALN11008, end         
 and DocType = 'FC' -- from customer        
         
 if @@error <> 0        
 begin        
 set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'        
 rollback tran        
 goto ERROR        
 end        
  
--20120208, liliana, BAALN11008, begin         
 --insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc)        
 --select @pnTranId, 'FC', left(result, 255)  
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching)        
 select @pnTranId, 'FC', left(result, 255), 0  
--20120208, liliana, BAALN11008, end         
 from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))        
        
 if @@error <> 0        
 begin        
 set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'        
 rollback tran        
 goto ERROR        
 end        
          
 delete from ReksaOtherDocuments_TM        
 where TranId = @pnTranId  
--20120208, liliana, BAALN11008, begin   
 and isnull(IsSwitching, 0) = 0  
--20120208, liliana, BAALN11008, end         
 and DocType = 'TC' -- ke customer        
        
 if @@error <> 0        
 begin        
 set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'        
 rollback tran        
 goto ERROR        
 end        
  
--20120208, liliana, BAALN11008, begin          
 --insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc)        
 --select @pnTranId, 'TC', left(result, 255)    
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching)        
 select @pnTranId, 'TC', left(result, 255), 0        
--20120208, liliana, BAALN11008, end   
 from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))        
        
 if @@error <> 0        
 begin        
 set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'        
 rollback tran        
 goto ERROR        
 end         
         
 commit tran        
--20090723, oscar, REKSADN013, end        
--20080416, mutiara, REKSADN002, end        
--20080414, mutiara, REKSADN002, end        
--20071126, indra_w, REKSADN002, end            
--20071123, victor, REKSADN002, end          
--20080414, mutiara, REKSADN002, begin          
--end          
--20080414, mutiara, REKSADN002, end          
end            
--20080415, indra_w, REKSADN002, end        
--20090723, oscar, REKSADN013, begin        
--20090625, philip, REKSADN013, begin            
return 0        
--20090625, philip, REKSADN013, end        
--20090723, oscar, REKSADN013, end        
ERROR:            
if isnull(@cErrMsg, '') != ''             
begin           
--20111026, liliana, BAALN10012, begin   
  if(@pbIsPartialMaturity = 1)  
 begin  
  update dbo.ReksaRedemptionSchedule_TT   
  set Status = 0,  
  AlasanGagal = @cErrMsg  
  where ClientId = @pnClientId  
  and ProdId = @pnProdId  
  and ValueDate = @pdTranDate  
 end  
--20111026, liliana, BAALN10012, end  
 set @nOK = 1            
 raiserror ( @cErrMsg ,16,1);
end            
            
return @nOK
GO