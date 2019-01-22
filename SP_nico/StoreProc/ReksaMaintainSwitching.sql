
CREATE proc [dbo].[ReksaMaintainSwitching]            
/*            
 CREATED BY    : 
 CREATION DATE : 
 DESCRIPTION   :           
 REVISED BY    :            
  DATE,  USER,   PROJECT,  NOTE            
  -----------------------------------------------------------------------            
 END REVISED            
           
      
*/            
@pnType       tinyint, -- 1: new; 2: update; 3: delete                    
@pnTranType      int,  -- 5: switching sebagian ; 6: switching all        
@pcTranCode      char(8) = null,        
@pnTranId      int      = null output,                          
@pdTranDate      datetime,                    
@pnProdIdSwcOut      int,          
@pnProdIdSwcIn      int,                     
@pnClientIdSwcOut    int,           
@pnClientIdSwcIn   int,                    
@pnFundIdSwcOut      int,           
@pnFundIdSwcIn      int,           
@pcSelectedAccNo varchar(20) = null,        
@pnAgentIdSwcOut      int,             
@pnAgentIdSwcIn      int = null,                  
@pcTranCCY      char(3),                       
@pmTranAmt      decimal(25,13),                    
@pmTranUnit      decimal(25,13),                    
@pmSwitchingFee    decimal(25,13),                                  
@pmNAVSwcOut   decimal(25,13),           
@pmNAVSwcIn    decimal(25,13),                          
@pdNAVValueDate   datetime,                    
@pmUnitBalanceSwcOut     decimal(25,13),                    
@pmUnitBalanceNomSwcOut    decimal(25,13),               
@pmUnitBalanceSwcIn     decimal(25,13),                    
@pmUnitBalanceNomSwcIn    decimal(25,13),                   
@pnUserSuid    int,                      
@pbByUnit    bit,                               
@pnSalesId    int,                    
@pcGuid      varchar(50),                    
@pcWarnMsg      varchar(100)  output                                 
,@pcInputter     varchar(40)                
,@pnSeller     int                
,@pnWaperd     int             
,@pbIsFeeEdit    bit        
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
,@pcWarnMsg2    varchar(100) = '' OUTPUT          
,@pdPercentageFee decimal(25,13) = 0        
, @pbByPhoneOrder  bit =0         
,@pcWarnMsg3    varchar(100) = '' OUTPUT         
,@pcCIFNo  varchar(20)        
,@pcOfficeId varchar(5)        
,@pcRefID  varchar(20)  output        
,@pbIsNew  bit        
,@pcClientCodeSwitchInNew varchar(20) = null        
,@pnReferentor   int        
,@pcWarnMsg4                varchar(500) = '' output      
,@pcWarnMsg5                varchar(500) = '' output      
, @pbTrxTaxAmnesty                  bit = 0    
as        
            
set nocount on            
        
declare @cErrMsg   varchar(200)             
  , @nOK    int            
  , @nErrNo   int           
  , @dCurrWorkingDate datetime        
  , @dCurrDate  datetime        
  , @nIsEmployee tinyint        
  , @nCIF     bigint          
  , @cProdCCY varchar(3)        
  , @mLastNAV  decimal(25,13)                      
  , @dNextWorkingDate  datetime        
  , @cProductCode   varchar(10)                    
  , @cAccountType   char(3)                    
  , @cMCAllowed   char(1)                    
  , @cAccountStatus  char(1)                    
  , @cCurrencyType  char(3)           
  , @dCutOff    datetime                    
  , @nCutOff    int                   
  , @cCIFNo  char(13)         
  , @bProcessStatus   bit        
  , @cClientCode varchar(11)        
  , @c3DigitClientCode  char(3)                    
  , @c5DigitCounter   char(5)                    
  , @nCounter    int          
  , @nCurrSwcOut char(3)        
  , @nCurrSwcIn  char(3)          
  , @mMinSwitchRedempt decimal(25,13)        
  , @cJenisSwitchRedempt varchar(20)        
  , @mEffUnit   decimal(25,13)        
   , @mMinBalance   decimal(25,13)        
   , @mMinBalanceByUnit bit         
   , @cOfficeId  char(5)        
   , @dCurrWorkingDate2 datetime        
 ,@nSwitchingRiskProfile   int          
 ,@nCustomerRiskProfile   int          
, @cTrxType     varchar(50)        
, @dMinPctFeeEmployee  decimal(25,13)           
, @dMaxPctFeeEmployee  decimal(25,13)         
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
, @mSwcFeeBased    decimal(25,13)         
, @nPercentageSwcFee  decimal(25,13)        
, @nBulanEfektifMFee  int        
, @bIsNew     bit        
, @mTotalPctFeeBased  decimal(25,13)        
, @mDefaultPctTaxFee  decimal(25,13)        
, @mSubTotalPctFeeBased  decimal(25,13)        
 , @mSelisihFee    decimal(25,13)        
, @cChannel     varchar(20)        
, @nUmur     int        
, @nPrevClientId   int        
, @cPFix     varchar(10)        
, @nCounterClient   varchar(10)        
, @cDefaultCCY    char(3)        
, @nBankId    int         
, @nAgentId    int        
  , @bIsMC    int        
  , @cTempNoRekening varchar(20)        
  , @cCIFNo19   varchar(19)         
  , @cNoRekeningUSD  varchar(20)        
  , @cNoRekeningMC  varchar(20)        
  , @cMustApproveBy     varchar(200)      
  , @cProdCodeSwcIn     varchar(50)      
  , @cCFCITZ_SIBS       char(3)      
  , @cNoIdentitasKTP_CIF varchar(20)        
  , @dIDExpireDateKTP_CIF datetime        
  , @cNoIdentitasPP_CIF  varchar(20)        
  , @dIDExpireDatePP_CIF datetime        
  , @cNoIdentitasKTP_SIBS varchar(20)        
  , @dIDExpireDateKTP_SIBS datetime        
  , @cNoIdentitasPP_SIBS  varchar(20)        
  , @dIDExpireDatePP_SIBS datetime           
  , @pnProcessId          int      
  , @cCountryCode       varchar(50)      
  , @cCountryName       varchar(200)        
    , @cSII         varchar(20)    
  , @cNoRekeningTA       varchar(20)        
  , @cNoRekeningUSDTA    varchar(20)      
  , @cNoRekeningMCTA     varchar(20)    
  , @nCIFNoBigInt        bigint      
  , @nExtStatus          int     
  , @nToday         int    
  , @dToday         datetime    
  , @cIFUATA   varchar(50)    
             
 create table #TempErrorTable(                
 FieldName   varchar(50)                
 ,[Description]  varchar(500)                
)         
          
set @cErrMsg = ''                    
set @nOK = 0         
set @pdTranDate  = getdate()        
set @cCIFNo19 = right(('0000000000000000000'+@pcCIFNo),19)         
set @nCIFNoBigInt = convert(bigint,@pcCIFNo)    
set @cTrxType = 'SWC'        
set @bIsNew = 0        
set @dToday = getdate()    
set @nToday = dbo.fnDatetimeToJulian(@dToday)    
if(@pbByPhoneOrder = 1)        
begin        
 set @cChannel = 'TLP'        
end        
else        
begin        
   set @cChannel = 'CBG'        
end        

set @pmTranUnit = round(@pmTranUnit,4)      
set @pmUnitBalanceSwcOut = round(@pmUnitBalanceSwcOut,4)      
--20151005, liliana, LIBST13020, end      
        
select @cOfficeId = office_id_sibs                    
from user_nisp_v                    
where nik = @pnUserSuid         
        
select @cCIFNo = CIFNo from dbo.ReksaCIFData_TM where ClientId = @pnClientIdSwcOut                    
set @nCIF = convert (bigint, @cCIFNo)         
select @nIsEmployee = isnull(IsEmployee, 0) from ReksaMasterNasabah_TM where CIFNo = @cCIFNo         
select @pcSelectedAccNo = NISPAccountId,        
 @cNoRekeningUSD = NISPAccountIdUSD,        
 @cNoRekeningMC = NISPAccountIdMC    
    , @cNoRekeningTA =  AccountIdTA    
    , @cNoRekeningUSDTA = AccountIdUSDTA    
    , @cNoRekeningMCTA = AccountIdMCTA    
from dbo.ReksaMasterNasabah_TM        
where CIFNo = @pcCIFNo        
    
if @pbTrxTaxAmnesty = 1    
begin    
    if @pcTranCCY = 'IDR' and isnull(@cNoRekeningTA,'') != ''       
    begin       
        set @pcSelectedAccNo = @cNoRekeningTA      
    end      
    else if @pcTranCCY = 'USD' and isnull(@cNoRekeningUSDTA,'') != ''      
    begin      
        set @pcSelectedAccNo = @cNoRekeningUSDTA      
    end      
    else if isnull(@cNoRekeningMCTA,'') != ''      
    begin      
        set @pcSelectedAccNo = @cNoRekeningMCTA      
    end     
end    
else    
begin    
--20160830, liliana, LOGEN00196, end          
if @pcTranCCY = 'IDR' and isnull(@pcSelectedAccNo,'') != ''         
begin         
 set @pcSelectedAccNo = @pcSelectedAccNo        
end        
else if @pcTranCCY = 'USD' and isnull(@cNoRekeningUSD,'') != ''        
begin        
 set @pcSelectedAccNo = @cNoRekeningUSD        
end        
else if isnull(@cNoRekeningMC,'') != ''        
begin        
 set @pcSelectedAccNo = @cNoRekeningMC        
end     
end    
        
if isnull(@pcSelectedAccNo,'') = ''        
begin        
 set @cErrMsg = 'Harap melakukan setting Nomor Rekening di menu Master Nasabah'                    
 goto ERROR        
end        

if exists(
	select top 1 1 
	from dbo.TAMAST_v ta
	join dbo.TCLOGT_v tc
		on ta.CFCIF# = tc.TCLCIF
	where tc.TCFLAG = 7 and ta.TAFLAG = 7
		and ta.CFACC# = @pcSelectedAccNo
	)
begin                   
	set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'        
    goto ERROR  	
end 

select @cIFUATA = IFUA    
from dbo.ReksaIFUAMapping_TM    
where CIFNo = @pcCIFNo    
 and AccType = 'TA'    
     
select @cSII = isnull(CFSSNO,'')    
from CFAIDN_v    
where CFCIF = @cCIFNo19 and CFSSCD = 'SII'     
    
if isnull(@cSII,'') = ''    
begin    
    set @cErrMsg = 'SID belum terdaftar. Mohon melakukan pengkinian data melalui cabang kami.'                
    goto ERROR    
end    
    
if (@cSII like 'TDP%')    
begin    
    set @cErrMsg = 'SID yang terdaftar masih sementara. Mohon melakukan pengkinian data melalui cabang kami.'                
    goto ERROR    
end    
        
select @cDefaultCCY = CFAGTY        
 from dbo.CFAGRPMC_v        
 where convert(bigint, CFAGNO) = convert(bigint, @pcSelectedAccNo)         
        
select @dCurrWorkingDate = current_working_date        
, @dCurrWorkingDate2 = current_working_date        
from dbo.fnGetWorkingDate()                    
               
select @dCurrDate = current_working_date                    
from control_table        

select @mDefaultPctTaxFee = PercentageTaxFeeDefault        
from dbo.control_table        
        
set @mSubTotalPctFeeBased = 100        
        
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee        
        
select @nCurrSwcOut = ProdCCY                    
from dbo.ReksaProduct_TM                    
where ProdId = @pnProdIdSwcOut          
        
select @nCurrSwcIn = ProdCCY        
  , @cProdCodeSwcIn = ProdCode      
from dbo.ReksaProduct_TM                    
where ProdId = @pnProdIdSwcIn         
        
select @nBankId = BankId        
from dbo.ReksaBankCode_TR        
where ProdId = @pnProdIdSwcIn        
 and BankCode = 'OCBC001'        
        
select @nAgentId = AgentId        
from dbo.ReksaAgent_TR        
where ProdId = @pnProdIdSwcIn        
 and OfficeId = @pcOfficeId         
         
select @pnAgentIdSwcOut = AgentId        
from dbo.ReksaAgent_TR        
where ProdId = @pnProdIdSwcOut        
 and OfficeId = @pcOfficeId         
        
select @pnFundIdSwcOut = FundId        
from dbo.ReksaFundCode_TR        
where ProdId = @pnProdIdSwcOut        
           
select @pnFundIdSwcIn = FundId        
from dbo.ReksaFundCode_TR        
where ProdId = @pnProdIdSwcIn        

select @pnProcessId = ProcessId      
from dbo.ReksaUserProcess_TR      
where ProcessName = 'Process Subcription'      
      
select @cCountryCode = CFCITZ      
from dbo.CFMAST_v      
where CFCIF = @cCIFNo19        
      
select @cCountryName = CountryName      
from dbo.ReksaCountryRestriction_TR      
where CountryCode = @cCountryCode      
--20151001, liliana, LIBST13020, end      
exec dbo.ReksaGetLatestNAV @pnProdIdSwcOut, null, null, @pmNAVSwcOut output      
      
if @@error > 0      
begin      
   set @cErrMsg = 'Error ambil NAV Prod Switch Out'                  
   goto ERROR         
end      
      
exec dbo.ReksaGetLatestNAV @pnProdIdSwcIn, null, null, @pmNAVSwcIn output      
      
if @@error > 0      
begin      
   set @cErrMsg = 'Error ambil NAV Prod Switch In'                  
   goto ERROR         
end       
      
if @pbByUnit = 1      
begin      
    set @pmTranAmt = @pmTranUnit * @pmNAVSwcOut      
    set @pmUnitBalanceSwcIn = @pmUnitBalanceNomSwcOut / @pmNAVSwcIn      
    set @pmUnitBalanceNomSwcIn = @pmUnitBalanceNomSwcOut      
end      
        
select @mMinSwitchRedempt = rps.MinSwitchRedempt, @cJenisSwitchRedempt = rps.JenisSwitchRedempt        
from dbo.ReksaProdSwitchingParam_TR rps         
 join dbo.ReksaProduct_TM rp on rps.ProdSwitchOut = rp.ProdCode        
 join dbo.ReksaProduct_TM rp2 on rps.ProdSwitchIn = rp2.ProdCode        
where rp.ProdId = @pnProdIdSwcOut and rp2.ProdId = @pnProdIdSwcIn        
        
select @mMinBalance   = case @nIsEmployee when 0 then MinBalance else MinBalanceEmp end                  
  , @mMinBalanceByUnit = MinBalanceByUnit         
  from dbo.ReksaProduct_TM                     
where ProdId = @pnProdIdSwcOut          
        
insert #TempErrorTable                   
exec dbo.ReksaGetMandatoryFieldStatus @nCIF, @cErrMsg output            
        
if exists(select top 1 1 from #TempErrorTable)         
begin              
 select * from #TempErrorTable               
 return 0              
end         
else        
begin        
 if @pnType not in (1, 2, 3)                    
 begin                    
 set @cErrMsg = 'Kode @pnType salah, 1:new, 2:update, 3:delete'                    
 goto ERROR         
 end          
 if exists(select top 1 1 from dbo.ReksaMasterNasabah_TM where CIFNo = @pcCIFNo and ApprovalStatus = 'T')        
 begin        
  set @cErrMsg = 'Shareholder ID / Nomor CIF tersebut sudah tidak aktif!'                    
  goto ERROR          
 end        

if exists(select top 1 1 from dbo.ReksaCountryRestriction_TR where CountryCode  = @cCountryCode)      
begin      
    set @cErrMsg = 'Kewarganegaraan '+ isnull(@cCountryName,'') +' tidak diijinkan untuk melakukan transaksi reksadana!'      
    goto ERROR      
end      
      
 If isnull(rtrim(@pcTranCCY), '') = ''                    
 begin                    
 set @cErrMsg = 'Mata Uang Harus Diisi'                    
 goto ERROR                    
 end         
 if (@pmTranAmt = 0) and (@pmTranUnit = 0)                    
 begin                    
 set @cErrMsg = 'Nominal / Unit harus diisi'                    
 goto ERROR                    
 end        
 if @pnTranType in (5) and @pmTranAmt > 0       
    and @pbByUnit = 0      
 begin        
  set @cErrMsg = 'Switching Sebagian Harus dalam Unit, sementara tidak bisa dalam nominal.'                  
  goto ERROR         
 end        

if @pbTrxTaxAmnesty = 1 
    and exists(select top 1 1 from dbo.ReksaProductException_TR where [Type] = 'TA' and ProdCode = @cProdCodeSwcIn )
begin
    set @cErrMsg = 'Produk Switch In tersebut tidak dapat ditransaksikan sebagai transaksi Tax Amnesty'              
    goto ERROR 
end
    
if @pbTrxTaxAmnesty = 1 and not exists(select top 1 1 from dbo.TCLOGT_v where TCLCIF = @nCIFNoBigInt and TCFLAG = 1     
    and TCEXP7 > @nToday    
    )    
begin        
    set @cErrMsg = 'Jenis transaksi Tax Amnesty hanya bisa dilakukan oleh CIF dengan flag Tax Amnesty'                  
    goto ERROR     
end     
    
if @pbTrxTaxAmnesty = 1 and exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientIdSwcOut)    
    and not exists (select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientIdSwcIn)    
    and @pbIsNew = 0    
begin    
    set @cErrMsg = 'Switch in/ switch out hanya bisa ke sesama rekening relasi Tax Amnesty'                  
    goto ERROR     
end     
    
if @pbTrxTaxAmnesty = 1 and not exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientIdSwcOut)    
    and exists (select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientIdSwcIn)    
    and @pbIsNew = 0    
begin    
    set @cErrMsg = 'Switch in/ switch out hanya bisa ke sesama rekening relasi Tax Amnesty'                  
    goto ERROR     
end       
    
if @pbTrxTaxAmnesty = 1 and isnull(@cIFUATA,'') = ''     
begin     
    set @cErrMsg = 'Tidak dapat melakukan transaksi karena IFUA TA belum terdaftar'                  
    goto ERROR     
end    

 if isnull(@nIsEmployee, 0) = 1                  
 begin            
  declare @CIFNIK varchar(5)         
  select @CIFNIK = CIFNik from ReksaMasterNasabah_TM where CIFNo = @cCIFNo         
  if @CIFNIK = @pnSeller          
  begin          
  set @cErrMsg = 'Nasabah tidak boleh sama dengan Nama/NIK Seller'                    
  goto ERROR           
  end                  
 end            
 if (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1                
 begin                
 set @cErrMsg = 'Tidak bisa melakukan booking/transaksi karena proses sinkronisasi sedang dijalankan. Harap tunggu'                
 goto ERROR                
 end           
 if exists(select top 1 1 from control_table where end_of_day = 1 and begin_of_day = 0)                    
 begin                    
 set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'                    
 goto ERROR                    
 end         
 if(@nCurrSwcOut != @nCurrSwcIn)        
 begin        
  set @cErrMsg = 'Currency beda mata uang antara prod Switch In & Switch Out tdk disupport'                    
  goto ERROR         
 end        
 if @pnType in (2, 3) and exists(select top 1 1 from ReksaSwitchingTransaction_TM where TranCode = @pcTranCode and RefID = @pcRefID and Status not in (0,1))        
 begin        
  set @cErrMsg = 'Transaksi dengan Status Rejected/ Reversed/ Cancel by PO tidak dapat diubah!'                    
  goto ERROR           
 end      
      
If @pnType in (2,3) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = @pnProcessId and ProcessStatus = 1)      
    and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranCode = @pcTranCode and NAVValueDate = @dCurrDate       
    )      
begin             
    set @cErrMsg = 'Sudah lewat cut off, tidak dapat melakukan perubahan data'      
    goto ERROR         
end       

 If @pnType in (2,3) and exists(select top 1 1 from ReksaSwitchingTransaction_TM where TranCode = @pcTranCode and RefID = @pcRefID and BillId is not null)        
 begin               
  set @cErrMsg = 'Sudah terbentuk bill, tidak dapat melakukan perubahan data'        
  goto ERROR           
 end        

 If not exists(select top 1 1 from ReksaCIFData_TM where ClientId = @pnClientIdSwcOut and CIFStatus = 'A')                    
 begin                    
 set @cErrMsg = 'Client Switch Out Belum Aktif atau sudah Tutup'                    
 goto ERROR                    
 end         

 If @pbIsNew = 0 and not exists(select top 1 1 from ReksaCIFData_TM where ClientId = @pnClientIdSwcIn and CIFStatus = 'A')              
 begin                    
 set @cErrMsg = 'Client Switch In Belum Aktif atau sudah Tutup'                    
 goto ERROR                    
 end         

 If exists(select top 1 1 from dbo.ReksaNonAktifClientId_TT where ClientId = @pnClientIdSwcOut and StatusOtor = 0)                    
 begin                    
 set @cErrMsg = 'Client Switch Out sudah Tutup'                    
 goto ERROR                    
 end         
 If exists(select top 1 1 from dbo.ReksaNonAktifClientId_TT where ClientId = @pnClientIdSwcIn and StatusOtor = 0)                    
 begin                    
 set @cErrMsg = 'Client Switch In sudah Tutup'                    
 goto ERROR                    
 end         

 If exists(select top 1 1 from ReksaMasterNasabah_TH where CIFNo = @cCIFNo and AuthType = 4)            
 begin                    
 set @cErrMsg = 'Perubahan Data Master Nasabah CIF ' + @cCIFNo +  ' Belum Diotorisasi'                    
 goto ERROR                    
 end        
         

 if (select Subscription from ReksaProduct_TM where ProdId = @pnProdIdSwcIn) = 0                      
 begin                
 select @cErrMsg = 'Subscription untuk produk ' + ProdName + ' sudah dihentikan' from ReksaProduct_TM where ProdId = @pnProdIdSwcIn                 
 goto ERROR                
 end                
 if @pnWaperd !=  @pnSeller        
 begin        
  set @cErrMsg = 'NIK Seller tidak sama dengan NIK Waperd'                  
  goto ERROR         
 end         
 if exists (select top 1 1 from dbo.ReksaWaperd_TR where DateExpire < getdate() and NIK = @pnWaperd)                
 begin                
 set @cErrMsg = 'WAPERD untuk NIK '+ convert(varchar,@pnWaperd) +' sudah expired'                
 goto ERROR                
 end         
 if exists (select top 1 1 from dbo.ReksaExceptionClient_TR where ClientId = @pnClientIdSwcOut)                    
 begin                    
 set @cErrMsg = 'Client Switch Out Ini Tidak Boleh Ditransaksikan'                    
 goto ERROR                    
 end         
 if exists (select top 1 1 from dbo.ReksaExceptionClient_TR where ClientId = @pnClientIdSwcIn)                    
 begin                    
 set @cErrMsg = 'Client Switch In Ini Tidak Boleh Ditransaksikan'                    
 goto ERROR                    
 end              
 if not exists (select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientIdSwcOut and ProdId = @pnProdIdSwcOut)                    
 begin                    
 set @cErrMsg = 'Kode Client Switch Out tidak sesuai dengan Kode Produk'                    
 goto ERROR                    
 end         

 if @pbIsNew = 0 and not exists (select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientIdSwcIn and ProdId = @pnProdIdSwcIn)          
 begin                    
 set @cErrMsg = 'Kode Client Switch In tidak sesuai dengan Kode Produk'                    
 goto ERROR         
 end         

 if exists(select top 1 1 from dbo.ReksaFlagClientId_TT where isnull(Flag,0) = 1 and ClientId = @pnClientIdSwcIn and StatusOtor = 0)        
 begin        
  select @cErrMsg = 'Client code switch in di flag, tidak dapat melakukan transaksi switch in! '                 
  goto ERROR         
 end        
 if @pnTranType = 5 and exists(select top 1 1 from dbo.ReksaFlagClientId_TT where isnull(Flag,0) = 1 and ClientId = @pnClientIdSwcOut and StatusOtor = 0)        
 begin        
  select @cErrMsg = 'Client code switch out di flag, hanya dapat melakukan switching all! '                
  goto ERROR         
 end         
 if exists(select top 1 1 from dbo.ReksaCIFData_TM where isnull(Flag,0) = 1 and ClientId = @pnClientIdSwcIn)        
 begin        
  select @cErrMsg = 'Client code switch in di flag, tidak dapat melakukan transaksi switch in! '               
  goto ERROR         
 end        
 if @pnTranType = 5 and exists(select top 1 1 from dbo.ReksaCIFData_TM where isnull(Flag,0) = 1 and ClientId = @pnClientIdSwcOut)        
 begin        
  select @cErrMsg = 'Client code switch out di flag, hanya dapat melakukan switching all! '               
  goto ERROR         
 end        

 if(@pbIsFeeEdit = 1)        
 begin        
          
  if(@nIsEmployee = 1)        
  begin        
   if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdIdSwcOut and MinPctFeeEmployee <= @pdPercentageFee        
   and MaxPctFeeEmployee >= @pdPercentageFee)         
   begin        
    select @dMinPctFeeEmployee = MinPctFeeEmployee, @dMaxPctFeeEmployee = MaxPctFeeEmployee        
    from dbo.ReksaParamFee_TM         
    where TrxType = @cTrxType and ProdId = @pnProdIdSwcOut        
            
    set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeEmployee)+' %.'                  
    goto ERROR         
   end        
  end        
  else         
  begin        
   if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdIdSwcOut and MinPctFeeNonEmployee <= @pdPercentageFee        
   and MaxPctFeeNonEmployee >= @pdPercentageFee)         
   begin        
    select @dMinPctFeeNonEmployee = MinPctFeeNonEmployee, @dMaxPctFeeNonEmployee = MaxPctFeeNonEmployee        
    from dbo.ReksaParamFee_TM         
    where TrxType = @cTrxType and ProdId = @pnProdIdSwcOut        
            
    set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,@dMinPctFeeNonEmployee)+' % dan '+ convert(varchar,@dMaxPctFeeNonEmployee)+' %.'                  
    goto ERROR         
   end        
  end        
 end        
         
 exec @nOK = ABCSAccountInquiry                    
  @pcAccountID = @pcSelectedAccNo                    
  ,@pnSubSystemNId = 111501                    
  ,@pcTransactionBranch = '99965'                    
  ,@pcProductCode = @cProductCode output                    
  ,@pcCurrencyType = @cCurrencyType output                    
  ,@pcAccountType =@cAccountType output                    
  , @pcMultiCurrencyAllowed = @cMCAllowed output                    
  , @pcAccountStatus = @cAccountStatus output                              
  , @pcTellerId = '7'                             
                      
 If @cAccountStatus not in ('1','4','9') -- selain aktif, new, atau dormant                    
 Begin                    
  set @cErrMsg = 'Relasi Sudah Tidak Aktif, Mohon Ganti Relasi!'                    
  goto ERROR                   
 End           
 if @cMCAllowed != 'Y'              
 begin      
  if @cCurrencyType != @cProdCCY                  
  begin                  
   set @cErrMsg = 'Transaksi cross-currency tidak didukung'                  
   goto ERROR                  
  end         
 end       

         
 --cek sisa unit nasabah        
 select @mEffUnit = dbo.fnGetEffUnit(@pnClientIdSwcOut)        
         
  select top 1 @mLastNAV = NAV                    
  from dbo.ReksaNAVParam_TH                    
  where ProdId = @pnProdIdSwcOut                    
  order by ValueDate desc         
          
  select @mEffUnit = @mEffUnit - isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(@pnProdIdSwcOut,2,cast(TranAmt / @mLastNAV as decimal(25,13))) end), 0)                             
  from dbo.ReksaTransaction_TT                    
  where TranType in (3,4)                    
  and Status in (0,1)                    
  and ClientId = @pnClientIdSwcOut                              
  and ProcessDate is null         

        
 select @mEffUnit = @mEffUnit - isnull(sum(case when rs.ByUnit = 1 then rs.TranUnit else dbo.fnReksaSetRounding(@pnProdIdSwcOut,2, cast(rs.TranAmt / @mLastNAV as decimal(25,13))) end), 0)        
 from dbo.ReksaSwitchingTransaction_TM rs        
 left join dbo.ReksaTransaction_TT rt        
 on rs.TranCode = rt.TranCode        

 where rs.TranType in (5,6,9)        
 and rt.TranCode is null        
 and rs.Status in (0,1)        
 and rs.ClientIdSwcOut = @pnClientIdSwcOut        
 and rs.BillId is null        
      
    if(@pnType = 2)      
    begin      
        select @mEffUnit = @mEffUnit + isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(ProdSwitchOut, 2,cast(TranAmt / NAVSwcOut as decimal(25,13))) end), 0)                  
        from ReksaSwitchingTransaction_TM                  
        where TranType in (5,6,9)                 
            and Status in (0,1)                  
            and TranCode = @pcTranCode                      
    end     
    if @mEffUnit = @pmTranUnit      
    begin      
        set @pnTranType = 6      
    end      
                               
  if @pbByUnit = 1           
  begin                    
   if round(@pmTranUnit,4) > round(@mEffUnit,4)                      
   begin                    
    set @cErrMsg = 'Unit Balance client tidak mencukupi'                    
    goto ERROR                    
   end                    
  end                    
  else                    
  begin                      
   if round(@pmTranAmt,2) > round(@mEffUnit* isnull(@mLastNAV,0),2)                      
   begin                    
    set @cErrMsg = 'Nominal Balance client tidak mencukupi'                     
    goto ERROR                    
   end                    
  end              
          
 --pengecekan minimal redemption utk switching sebagian        
    if(@pnTranType = 6)        
    begin        
        if(@pbByUnit = 0)        
        begin         
            if(@cJenisSwitchRedempt = 'Nominal')        
            begin        
                if @pmTranAmt < @mMinSwitchRedempt                    
                begin           
                    set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1)        
                    goto ERROR                    
                end          
            end        
            else if(@cJenisSwitchRedempt = 'Unit')        
            begin        
                if @pmTranAmt / @pmNAVSwcOut < @mMinSwitchRedempt                
                begin                 
                    set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' Unit Perkiraan'              
                    goto ERROR                    
                end          
            end        
        end         
        else        
        begin        
            if(@cJenisSwitchRedempt = 'Nominal')        
            begin        
                if @pmTranUnit * @pmNAVSwcOut < @mMinSwitchRedempt                    
                begin                          
                    set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' (Perkiraan)'                    
                    goto ERROR                    
                end          
            end        
            else if(@cJenisSwitchRedempt = 'Unit')        
            begin        
                if @pmTranUnit < @mMinSwitchRedempt                
                begin              
                    set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' Unit'         
                    goto ERROR                    
                end          
            end        
        end
    end  

 if(@pnTranType = 5)

 begin        
  if(@pbByUnit = 0)        
  begin         
   if(@cJenisSwitchRedempt = 'Nominal')        
   begin        
    if @pmTranAmt < @mMinSwitchRedempt                    
    begin           
       set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1)        
       goto ERROR                    
    end          
   end        
   else if(@cJenisSwitchRedempt = 'Unit')        
   begin        
    if @pmTranAmt / @pmNAVSwcOut < @mMinSwitchRedempt                
    begin                 
       set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' Unit Perkiraan'              
       goto ERROR                    
    end          
   end        
  end         
  else        
  begin        
   if(@cJenisSwitchRedempt = 'Nominal')        
   begin        
    if @pmTranUnit * @pmNAVSwcOut < @mMinSwitchRedempt                    
    begin                          
       set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' (Perkiraan)'                    
       goto ERROR                    
    end          
   end        
   else if(@cJenisSwitchRedempt = 'Unit')        
   begin        
    if @pmTranUnit < @mMinSwitchRedempt                
    begin              
       set @cErrMsg = 'Minimal Switching : ' + convert(varchar(40),cast(@mMinSwitchRedempt as money),1) + ' Unit'         
       goto ERROR                    
    end          
   end        
  end             
         
  If @mMinBalanceByUnit = 1 -- pengecekan berdasarkan unit                    
  Begin                    
   if @pbByUnit = 1                    
   Begin                    
    if @mEffUnit - @pmTranUnit < @mMinBalance                    
    begin          
     set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit, sebaiknya SWITCHING ALL'             
     goto ERROR                    
    end                     
   End                    
   Else                    
   Begin                    
    if @mEffUnit - (@pmTranAmt/@mLastNAV) < @mMinBalance                    
    begin              
     set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit Perkiraan, sebaiknya SWITCHING ALL'         
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
  set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ isnull(@cProdCCY,'') + ' , sebaiknya SWITCHING ALL'         
     goto ERROR                    
    end                     
   End                    
   Else                    
   Begin                    
    if (@mEffUnit * @mLastNAV) - @pmTranAmt < @mMinBalance                    
    begin            
 set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY+ ' , sebaiknya SWITCHING ALL'        
     goto ERROR                    
    end                     
   End                    
  End                    

 end          
if @pnType = 1        
begin        

         
 select @nCutOff = CutOff, @bProcessStatus = ProcessStatus                    
 from dbo.ReksaUserProcess_TR                              
 where ProcessId in (1,2)         
                           
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
  If @dCurrDate!=convert(datetime, convert(char(8),@dCurrWorkingDate,112))          
  begin                         
   set @pdNAVValueDate = @dCurrWorkingDate              
  end              
  else         
  begin                
  set @pdNAVValueDate = @dNextWorkingDate                    
  set @pcWarnMsg = 'Valuedate dari transaksi ini : ' + convert (varchar, @pdNAVValueDate, 103)                            
  end                    
 end        
              

if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientIdSwcOut)        
 begin        
  set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan switching all hari ini.'                           
  goto ERROR          
 end        
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientIdSwcOut)        
 begin        
  set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan redempt all hari ini.'                           
  goto ERROR          
 end        
else if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientIdSwcIn)        
 begin        
  set @cErrMsg = 'Tidak bisa di switch in karena Client Code sudah pernah di switch out hari ini.'                           
  goto ERROR          
 end        
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientIdSwcIn)        
 begin        
  set @cErrMsg = 'Tidak bisa di switch in karena Client Code sudah pernah redempt hari ini.'                           
  goto ERROR          
 end        
else if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcIn = @pnClientIdSwcOut)        
begin        
 set @cErrMsg = 'Tidak bisa Switch Out karena Client Code sudah pernah di switch in hari ini.'                           
 goto ERROR          
end        
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientIdSwcOut)        
begin        
 set @cErrMsg = 'Tidak bisa Switch Out karena Client Code sudah pernah subs new/add hari ini.'                           
 goto ERROR          
end         
 SET @pcWarnMsg2 = ''        
set @pcWarnMsg3 = ''        
    set @pcWarnMsg4 = ''      
    set @pcWarnMsg5 = ''      
          
          
    if @pbIsFeeEdit = 1      
    begin      
        if exists(select top 1 1 from dbo.ReksaTieringNotification_TM where TrxType = 'SWC' and ProdId = @pnProdIdSwcIn          
            and PercentFrom <= @pdPercentageFee and PercentTo >= @pdPercentageFee)          
        begin          
          select @cMustApproveBy = isnull(MustApproveBy, '')          
          from dbo.ReksaTieringNotification_TM           
          where TrxType = 'SWC' and ProdId = @pnProdIdSwcIn          
           and PercentFrom <= @pdPercentageFee           
           and PercentTo >= @pdPercentageFee          
              
            set @pcWarnMsg4 = 'Transaksi untuk produk '+ Ltrim(Rtrim(@cProdCodeSwcIn)) +' diberikan diskon fee. Apakah diskon fee tersebut sudah mendapatkan persetujuan dari '+Ltrim(Rtrim(@cMustApproveBy))+' ?'          
        end      
    end      
      
select right(CFCIF,13) as CFCIF19, *        
into #Temp_CFMAST        
from dbo.CFMAST_v        
where CFCIF = @cCIFNo19         
        
select *        
into #Temp_ReksaCIFData_TM2        
from dbo.ReksaCIFData_TM        
where [CIFNo] = @pcCIFNo          
--20150709, liliana, LIBST13020, end        
        
--cek umur nasabah        
 exec ReksaHitungUmur @cCIFNo, @nUmur output          
        
 if(@nUmur >= 55)        
 begin        
 SET @pcWarnMsg3 = 'Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching'        
 end        
--20130618, liliana, BAFEM12011, end          
          
 -- SWITCHING RISK NOTIFICATION          
 IF(@pnTranType = 5 OR @pnTranType = 6)          
 BEGIN          
  SELECT @nSwitchingRiskProfile = rprp.RiskProfile          
  FROM [dbo].[ReksaProduct_TM] rp          
  LEFT JOIN [dbo].[ReksaProductRiskProfile_TM] rprp          
   ON rp.[ProdCode] = rprp.[ProductCode]          
   WHERE rp.[ProdId] = @pnProdIdSwcIn          
           
  -- GET CUSTOMER RISK          
  SELECT @nCustomerRiskProfile = CASE          
     WHEN LOWER(cf.[CFUIC8]) = 'a' THEN 1          
     WHEN LOWER(cf.[CFUIC8]) = 'b' THEN 2          
     WHEN LOWER(cf.[CFUIC8]) = 'c' THEN 3          
     WHEN LOWER(cf.[CFUIC8]) = 'd' THEN 4          
     ELSE 0          
END          
  FROM [dbo].#Temp_ReksaCIFData_TM2 rc          
  JOIN [dbo].#Temp_CFMAST cf          
 on cf.CFCIF19 = rc.CIFNo        

    select @cCFCITZ_SIBS = CFCITZ      
    from #Temp_CFMAST      
      
    if @cCFCITZ_SIBS = '000'        
    begin        
        select @cNoIdentitasKTP_SIBS = CFSSNO,        
            @dIDExpireDateKTP_SIBS =          
            case when isnull(CFIEX6, 0) != 0            
            then dbo.fnConvertDate6ToDate(CFIEX6) else null end         
        from dbo.CFAIDN_v         
        where CFCIF = @cCIFNo19        
            and CFSSCD = 'KTP'        
      
        if isnull(@cNoIdentitasKTP_SIBS,'')= ''        
        begin        
            select @cNoIdentitasKTP_SIBS = CFSSNO,        
                @dIDExpireDateKTP_SIBS =          
                case when isnull(CFIEX6, 0) != 0            
                then dbo.fnConvertDate6ToDate(CFIEX6) else null end         
            from dbo.CFMAST_v         
            where CFCIF = @cCIFNo19        
                and CFSSCD = 'KTP'        
                and CFCITZ = '000'        
        end           
    end      
    else      
    begin      
        select @cNoIdentitasPP_SIBS = CFSSNO,        
            @dIDExpireDatePP_SIBS =          
            case when isnull(CFIEX6, 0) != 0            
            then dbo.fnConvertDate6ToDate(CFIEX6) else null end         
        from dbo.CFAIDN_v         
        where CFCIF = @cCIFNo19        
            and CFSSCD = 'PP'        
      
        if isnull(@cNoIdentitasPP_SIBS,'') = ''        
        begin        
            select @cNoIdentitasPP_SIBS = CFSSNO,        
                @dIDExpireDatePP_SIBS =          
                case when isnull(CFIEX6, 0) != 0            
                then dbo.fnConvertDate6ToDate(CFIEX6) else null end         
            from dbo.CFMAST_v         
            where CFCIF = @cCIFNo19        
                and CFSSCD = 'PP'        
                and CFCITZ != '000'        
        end        
    end      
          
    if isnull(@cCFCITZ_SIBS, '000') = '000'          
    and @dIDExpireDateKTP_SIBS is not null         
    and @dIDExpireDateKTP_SIBS < getdate()            
    begin              
        set @pcWarnMsg5 = 'KTP sudah expired. Lakukan update tanggal expired KTP pada Pro CIF'            
    end      
        
    if isnull(@cCFCITZ_SIBS, '000') != '000'          
    and @dIDExpireDateKTP_SIBS is not null         
    and @dIDExpireDateKTP_SIBS < getdate()            
    begin              
        set @pcWarnMsg5 = 'Pasport sudah expired. Lakukan update tanggal expired Pasport pada Pro CIF'            
    end       
           
  IF(@nCustomerRiskProfile < @nSwitchingRiskProfile)          
  BEGIN          
      SET @pcWarnMsg2 = 'Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah. Apakah Nasabah sudah sudah menandatangi kolom Profil Risiko pada Subscription/Switching Form?'         
  END          
 END        
end        

 --pembagian switching fee based        
 select @nPercentageSwcFee = isnull(Percentage,0)    
 from dbo.ReksaListGLFee_TM        
 where TrxType = @cTrxType        
  and ProdId = @pnProdIdSwcOut        
  and Sequence = 1        
--20130206, liliana, BATOY12006, begin        
 if isnull(@nPercentageSwcFee,0) = 0        
 begin        
  set @cErrMsg = 'Nilai persentase switching fee based tidak ditemukan!'                      
  goto ERROR          
 end        

 select @mSwcFeeBased = dbo.fnReksaSetRounding(@pnProdIdSwcOut,3,cast(cast(@nPercentageSwcFee/@mTotalPctFeeBased as decimal(25,13)) * @pmSwitchingFee as decimal(25,13)))        

        
 if @mSwcFeeBased > @pmSwitchingFee                  
   set @mSwcFeeBased = @pmSwitchingFee               
        
 --pembagian pajak fee based        
 select @nPercentageTaxFee = isnull(Percentage,0)        
 from dbo.ReksaListGLFee_TM        
 where TrxType = @cTrxType        
  and ProdId = @pnProdIdSwcOut        
  and Sequence = 2        

 if isnull(@nPercentageTaxFee,0) = 0        
 begin        
  set @cErrMsg = 'Nilai persentase tax fee based tidak ditemukan!'                      
  goto ERROR          
 end        

 select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdIdSwcOut,3,cast(cast(@nPercentageTaxFee/@mTotalPctFeeBased as decimal(25,13)) * @pmSwitchingFee as decimal(25,13)))         
        
 if @mTaxFeeBased > @pmSwitchingFee                  
   set @mTaxFeeBased = @pmSwitchingFee             
        
 --pembagian fee based 3 (jika ada)        
 select @nPercentageFee3 = isnull(Percentage,0)        
 from dbo.ReksaListGLFee_TM        
 where TrxType = @cTrxType        
  and ProdId = @pnProdIdSwcOut        
  and Sequence = 3        
        

 select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdIdSwcOut,3,cast(cast(@nPercentageFee3/@mTotalPctFeeBased as decimal(25,13)) * @pmSwitchingFee as decimal(25,13)))         

        
 if @mFeeBased3 > @pmSwitchingFee                  
   set @mFeeBased3 = @pmSwitchingFee         
           
 --pembagian fee based 4 (jika ada)            
 select @nPercentageFee4 = isnull(Percentage,0)        
 from dbo.ReksaListGLFee_TM        
 where TrxType = @cTrxType        
  and ProdId = @pnProdIdSwcOut        
  and Sequence = 4        
        

 select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdIdSwcOut,3,cast(cast(@nPercentageFee4/@mTotalPctFeeBased as decimal(25,13)) * @pmSwitchingFee as decimal(25,13)))        

        
 if @mFeeBased4 > @pmSwitchingFee                  
   set @mFeeBased4 = @pmSwitchingFee         
        
 --pembagian fee based 5 (jika ada)            
 select @nPercentageFee5 = isnull(Percentage,0)        
 from dbo.ReksaListGLFee_TM        
 where TrxType = @cTrxType        
  and ProdId = @pnProdIdSwcOut        
  and Sequence = 5        
        

 select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdIdSwcOut,3,cast(cast(@nPercentageFee5/@mTotalPctFeeBased as decimal(25,13)) * @pmSwitchingFee as decimal(25,13)))         
        
 if @mFeeBased5 > @pmSwitchingFee                  
   set @mFeeBased5 = @pmSwitchingFee         
          
  --total fee based        
 set @mTotalFeeBased = isnull(@mSwcFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)        
        
 select @mSelisihFee = @pmSwitchingFee - @mTotalFeeBased         
        
 select @mSwcFeeBased = isnull(@mSwcFeeBased, 0) + @mSelisihFee        
 set @mTotalFeeBased = isnull(@mSwcFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)        
        
        
    if @pbTrxTaxAmnesty = 1    
    begin    
        set @nExtStatus = 74    
    end    
if @pnType = 1        
begin          
   exec ReksaGenerateRefID 'SWCNONRDB', @pcRefID output          
           
   if isnull(@pcRefID,'') = ''         
   begin        
  set @cErrMsg = 'Gagal generate Ref ID'                      
  goto ERROR         
   end                                       
           
 if(@pbIsNew = 1)        
 begin        
   --insert client code switch in        
  --generate client code        
  set @nCounterClient = 0        
  set @cPFix = ''          
        
   select @cPFix = Prefix            
   from dbo.ReksaClientCounter_TR            
   where ProdId = @pnProdIdSwcIn            
              
   If isnull(ltrim(@cPFix ),'') = ''            
   Begin            
   set @cErrMsg = 'Kode Prefix Nasabah Belum Terdefinisi!'            
   goto ERROR        
   end        
            
   update dbo.ReksaClientCounter_TR with(rowlock)            
   set [Counter] = @nCounterClient,           
   @nCounterClient = isnull([Counter],0) + 1           
           
   set @pcClientCodeSwitchInNew = @cPFix + right('00000000'+convert(varchar(8),@nCounterClient),8)          
            
   set @cPFix = left(@pcClientCodeSwitchInNew,3)        
   set @nCounterClient = right(@pcClientCodeSwitchInNew,5)        
           
    Insert ReksaCIFData_TM (ProdId, ClientCode, ClientCodePfix, ClientCodeCount, CIFNo, CIFName, CIFAddress1            
     , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone            
     , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus, IsEmployee, CIFNIK              
     , JoinDate, AgentId, BankId, AccountType, NISPAccId, NISPAccName, NonNISPAccId, NonNISPAccName             
     , Referentor, BookingId, UnitBalance, LastUpdate, UserSuid, AuthType           
     , IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile, DocTermCondition, Inputter, Seller, Waperd          
     , ShareholderID, InputterNIK, CheckerSuid           
    )           
     select @pnProdIdSwcIn, @pcClientCodeSwitchInNew, @cPFix, @nCounterClient, CIFNo, CIFName, ''            
      , '', '', '', '', '', ''            
      , '', CIFBirthPlace, CIFBirthDay, '', '', '', 'A', IsEmployee, CIFNik            
      , getdate(), @nAgentId, @nBankId, 0, NISPAccountId, NISPAccountName, '', ''           
      , 0, null, 0, getdate(), 7, 1           
      , '', '', '', '', 1, 1, @cChannel, null, null          
      , ShareholderID, 7, 777          
     from dbo.ReksaMasterNasabah_TM        
     where CIFNo = @pcCIFNo            
            
    set @pnClientIdSwcIn = @@identity        
      if @pbTrxTaxAmnesty = 1    
      begin      
          insert dbo.ReksaClientCodeTAMapping_TM (ClientIdTax, IsTaxAmnesty, RegisterDate)    
          select @pnClientIdSwcIn, 1, getdate()     
      end     
           
  select *        
  into #Temp_ReksaCIFData_TM        
  from dbo.ReksaCIFData_TM        
  where ClientCode = @pcClientCodeSwitchInNew        
                 
  update rc        
        set SEX = cf.CFSEX,        
            IDType = cf.CFSSCD,        
            CTZSHIP = case when cf.CFCITZ = '000' then 'ID' else isnull(jh.JHCCOC,'') end,        
            RELIGION = case when cf.CFRACE = 'ISL' then '001'        
                        when cf.CFRACE = 'KAT' then '002'        
                        when cf.CFRACE = 'PRO' then '003'        
                        when cf.CFRACE = 'BUD' then '004'        
                        when cf.CFRACE = 'HIN' then '005'        
                        else '' end,        
            CIFType = case when cf.CFCLAS = 'A' then 1        
                      when cf.CFCLAS = '' then 0        
                      else 4 end        
        from #Temp_ReksaCIFData_TM rc        
        join #Temp_CFMAST cf        
            on cf.CFCIF19 = rc.CIFNo        
        left join JHCOUN_v jh        
            on cf.CFCITZ = jh.JHCSUB               
           
  drop table #Temp_ReksaCIFData_TM         
 end         
        

 drop table #Temp_CFMAST        
 drop table #Temp_ReksaCIFData_TM2        
         

  select @cClientCode = ClientCode                    
  from dbo.ReksaCIFData_TM                    
  where ClientId = @pnClientIdSwcIn                      
                     
  update dbo.ReksaClientCounter_TR                    
  set Trans = @nCounter                   
   , @nCounter = isnull(Trans, 0) + 1                    
  where ProdId = @pnProdIdSwcIn                    
                     
  set @c5DigitCounter = right ( ('00000' + convert(varchar, @nCounter)) , 5)                    
  set @c3DigitClientCode = left (@cClientCode, 3)                    
                     
  set @pcTranCode = @c3DigitClientCode + @c5DigitCounter                      
         
  begin tran         
          
  insert dbo.ReksaSwitchingTransaction_TM (TranCode, TranType, TranDate, ProdSwitchOut, ProdSwitchIn,         
  ClientIdSwcOut, ClientIdSwcIn, FundIdSwcOut, FundIdSwcIn, SelectedAccNo, AgentId,         
  SalesId, TranCCY, TranAmt, TranUnit, SwitchingFee, NAVSwcOut, NAVSwcIn, NAVValueDate,         
  UnitBalanceSwcOut, UnitBalanceNomSwcOut, UnitBalanceSwcIn, UnitBalanceNomSwcIn, Status, ByUnit,         
  Inputter, UserSuid, ReverseSuid, CheckerSuid, Seller, Waperd, InputDate, AuthDate        
  , IsFeeEdit        
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
 ,PercentageFee        
 ,JenisPerhitunganFee        
 , SwitchingFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased        
 , Channel        
 , RefID, OfficeId, Referentor, AuthType        
 , IsNew        
 , ExtStatus    
  )        
  select @pcTranCode, @pnTranType, @pdTranDate, @pnProdIdSwcOut, @pnProdIdSwcIn,        
  @pnClientIdSwcOut, @pnClientIdSwcIn, @pnFundIdSwcOut, @pnFundIdSwcIn, @pcSelectedAccNo, @pnAgentIdSwcOut,        
  @pnSalesId, @pcTranCCY, @pmTranAmt, @pmTranUnit, @pmSwitchingFee, @pmNAVSwcOut, @pmNAVSwcIn, convert(char(8),@pdNAVValueDate,112),        
  @pmUnitBalanceSwcOut, @pmUnitBalanceNomSwcOut, @pmUnitBalanceSwcIn, @pmUnitBalanceNomSwcIn, 0, @pbByUnit,        
   @pcInputter, @pnUserSuid, null, null, @pnSeller, @pnWaperd, getdate(), null        
  , @pbIsFeeEdit        
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
 ,@pdPercentageFee        
 , case when @pbIsFeeEdit = 1 then 2 else 1 end --jika di edit, perhitungan menggunakan percentage (2), kalo tidak diedit menggunakan nominal (1)        
 , @mSwcFeeBased, @mTaxFeeBased, @mFeeBased3, @mFeeBased4, @mFeeBased5, @mTotalFeeBased        
 , @cChannel        
 , @pcRefID        
 , @pcOfficeId, @pnReferentor, 1        
 , @pbIsNew        
 , @nExtStatus    
          
        
  if @@error <> 0                
  begin                
  set @cErrMsg = 'Gagal insert data ReksaSwitchingTransaction_TM'                
  rollback tran                
  goto ERROR                
  end            
          
  select @pnTranId = scope_identity()         

 delete from ReksaOtherDocuments_TM              
 where TranId = @pnTranId         
  and isnull(IsSwitching, 0) = 1             
  and DocType = 'FC' -- from customer              
            
 if @@error <> 0              
 begin           
  set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'              
  rollback tran              
  goto ERROR              
 end              
            
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)              
 select @pnTranId, 'FC', left(result, 255), 1, 0              
 from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'              
  rollback tran              
  goto ERROR              
 end              
             
 delete from ReksaOtherDocuments_TM              
 where TranId = @pnTranId        
 and isnull(IsSwitching, 0) = 1               
 and DocType = 'TC' -- ke customer              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'              
  rollback tran              
  goto ERROR              
 end              
            
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)             
 select @pnTranId, 'TC', left(result, 255), 1, 0                
 from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'              
  rollback tran              
  goto ERROR              
 end        
 commit tran        
end        
else if @pnType = 2        
begin        
    select @pnTranId = TranId      
    from dbo.ReksaSwitchingTransaction_TM      
    where TranCode = @pcTranCode          
          
    if(@pnTranId is null)      
    begin      
        set @cErrMsg = 'Tidak dapat melakukan Edit, Nomor Transaksi tidak ditemukan!'          
        goto ERROR                    
    end      
          
    if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TMP where TranId = @pnTranId and AuthType = 4)      
    begin      
        delete dbo.ReksaSwitchingTransaction_TMP       
        where TranId = @pnTranId       
            and AuthType = 4      
    end      
      
  begin tran         
          
 insert dbo.ReksaSwitchingTransaction_TMP (TranCode, TranType, TranDate, ProdSwitchOut, ProdSwitchIn,         
 ClientIdSwcOut, ClientIdSwcIn, FundIdSwcOut, FundIdSwcIn, SelectedAccNo, AgentId,         
 SalesId, TranCCY, TranAmt, TranUnit, SwitchingFee, NAVSwcOut, NAVSwcIn, NAVValueDate,         
 UnitBalanceSwcOut, UnitBalanceNomSwcOut, UnitBalanceSwcIn, UnitBalanceNomSwcIn, Status, ByUnit,         
 Inputter, UserSuid, ReverseSuid, CheckerSuid, Seller, Waperd, InputDate, AuthDate        
 , IsFeeEdit,DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter                  
 ,DocFCIDCopy,DocFCOthers,DocTCSubscriptionForm,DocTCTermCondition,DocTCProspectus                               
 ,DocTCFundFactSheet,DocTCOthers,PercentageFee,JenisPerhitunganFee        
 , SwitchingFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased        
 , Channel, RefID, OfficeId, Referentor, AuthType        
 , IsNew        
 , TranId      
 , ExtStatus    
 )        
 select @pcTranCode, @pnTranType, @pdTranDate, @pnProdIdSwcOut, @pnProdIdSwcIn,        
 @pnClientIdSwcOut, @pnClientIdSwcIn, @pnFundIdSwcOut, @pnFundIdSwcIn, @pcSelectedAccNo, @pnAgentIdSwcOut,        
 @pnSalesId, @pcTranCCY, @pmTranAmt, @pmTranUnit, @pmSwitchingFee, @pmNAVSwcOut, @pmNAVSwcIn, convert(char(8),@pdNAVValueDate,112),           
 @pmUnitBalanceSwcOut, @pmUnitBalanceNomSwcOut, @pmUnitBalanceSwcIn, @pmUnitBalanceNomSwcIn, 0, @pbByUnit,        
 @pcInputter, @pnUserSuid, null, null, @pnSeller, @pnWaperd, getdate(), null        
 , @pbIsFeeEdit,@pbDocFCSubscriptionForm,@pbDocFCDevidentAuthLetter,@pbDocFCJoinAcctStatementLetter                  
 ,@pbDocFCIDCopy,@pbDocFCOthers,@pbDocTCSubscriptionForm,@pbDocTCTermCondition                            
 ,@pbDocTCProspectus,@pbDocTCFundFactSheet,@pbDocTCOthers,@pdPercentageFee        
 , case when @pbIsFeeEdit = 1 then 2 else 1 end --jika di edit, perhitungan menggunakan percentage (2), kalo tidak diedit menggunakan nominal (1)        
 , @mSwcFeeBased, @mTaxFeeBased, @mFeeBased3, @mFeeBased4, @mFeeBased5, @mTotalFeeBased        
 , @cChannel, @pcRefID, @pcOfficeId, @pnReferentor, 4        
 , @pbIsNew        
 , @pnTranId      
 , @nExtStatus    
         
 if @@error != 0 or @@rowcount = 0            
 Begin            
  set @cErrMsg = 'Error Request Update Data!'            
  goto ERROR            
 End          

 -- DocFCOtherList             
 delete from ReksaOtherDocuments_TM              
 where TranId = @pnTranId         
  and isnull(IsSwitching, 0) = 1             
  and DocType = 'FC' -- from customer              
            
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'              
  rollback tran              
  goto ERROR              
 end              
            
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)              
 select @pnTranId, 'FC', left(result, 255), 1, 0              
 from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'              
  rollback tran              
  goto ERROR              
 end              
             
 delete from ReksaOtherDocuments_TM              
 where TranId = @pnTranId        
 and isnull(IsSwitching, 0) = 1               
 and DocType = 'TC' -- ke customer              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'              
  rollback tran              
  goto ERROR              
 end              
            
 insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)              
 select @pnTranId, 'TC', left(result, 255), 1, 0                
 from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))              
           
 if @@error <> 0              
 begin              
  set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'              
  rollback tran              
  goto ERROR              
 end        
        
 Update ReksaSwitchingTransaction_TM             
 set AuthType = 2            
  , CheckerSuid = null        
  , UserSuid = @pnUserSuid        
 where TranCode = @pcTranCode         
  and RefID = @pcRefID        
        
 if @@error != 0 or @@rowcount = 0            
 Begin            
  set @cErrMsg = 'Error Update Flag Update!'            
  goto ERROR            
 End         
         
  commit tran          
        
end         
else if @pnType = 3        
begin        
 begin tran        
        
 Update ReksaSwitchingTransaction_TM             
 set AuthType = 3            
  , CheckerSuid = null        
  , UserSuid = @pnUserSuid        
 where TranCode = @pcTranCode         
  and RefID = @pcRefID        
            
 if @@error != 0 or @@rowcount = 0            
 Begin            
  set @cErrMsg = 'Gagal Update Status jadi Delete!'            
  goto ERROR            
 End        
         
 commit tran        
end        
        
         
end        
           
drop table #TempErrorTable              
        
          
return 0            
            
ERROR:            
if isnull(@cErrMsg ,'') = ''            
 set @cErrMsg = 'Error !'            
            
--exec @nOK = set_raiserror @@procid, @nErrNo output              
--if @nOK != 0 return 1              
              
raiserror (@cErrMsg ,16,1);
return 1
GO