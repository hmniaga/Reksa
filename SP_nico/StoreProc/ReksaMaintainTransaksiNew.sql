
CREATE proc [dbo].[ReksaMaintainTransaksiNew]                
/*                
 CREATED BY    : liliana                
 CREATION DATE : 20141201             
 DESCRIPTION   : insert / update / delete ke tabel dbo.ReksaTransaction_TT                      
 REVISED BY    :                
  DATE,  USER,   PROJECT,  NOTE                
  -----------------------------------------------------------------------                
  20150408, liliana, LIBST13020, ganti nomor rekening dan pengecekan    
  20150608, liliana, LIBST13020, insert reksacifdata_tm    
  20150618, liliana, LIBST13020, perbaikan edit trx    
  20150625, liliana, LIBST13020, tambah rekening USD    
  20150629, liliana, LIBST13020, pending boleh diedit    
  20150630, liliana, LIBST13020, multicurrency    
  20150709, liliana, LIBST13020, pengecekan jika sedang sinkronisasi maka tdk bisa redemp    
  20150715, liliana, LIBST13020, yg nunggu otor, cek berdasar checkersuid null    
  20150813, liliana, LIBST13020, rekening multicurr, pengecekan crosscurr    
  20150828, liliana, LIBST13020, jika edit lalu edit lagi    
  20150908, liliana, LIBST13020, boleh edit jika lewat cut off jika tanggal NAV + 1    
  20150911, liliana, LIBST13020, jika switching rdb    
  20150918, liliana, LIBST13020, jika sudah terbentuk bill tidak bs edit    
  20151001, liliana, LIBST13020, jika edit + redemp all + country restriction    
  20151005, liliana, LIBST13020, round 4    
  20160818, Lita, LIBST15330, add check SID    
  20160830, liliana, LOGEN00196, tax amnesty    
  20161021, liliana, CSODD16311, cek expiry TA  
  20161031, liliana, CSODD16311, cek IFUA TA  
  20170413, liliana, COPOD17019, exception produk tax amnesty    
  20170517, liliana, LOGEN00395, project RDN   
  20171005, liliana, COPOD17271, risk profile tipe 5  
  20171018, Lita, LOGEN00466, add validasi Closed Branches  
  20171020, Lita, LOGEN00466, fix convert
  20171108, sandi, LOGAM09102, validasi trx subs new yang masih pending otorisasi  
  20171205, Lita, LOGAM09096, add SII validation
 END REVISED                
                
*/                
@pnType                         tinyint, -- 1: new; 2: update; 3: delete                
@pnTranType                     int,  -- 1: subscription new; 2 : subs add; 3: redemption; 4: redemption all; 8: RDB Subscription              
@pcTranCode                     char(8),                    
@pcRefID                        varchar(20),            
@pdTranDate                     datetime,                
@pcCIFNo                        varchar(13),      
@pcOfficeId                     varchar(5),    
--20150625, liliana, LIBST13020, begin    
--@pcNoRekening                 varchar(20),    
@pcNoRekening                   varchar(20) = null,    
--20150625, liliana, LIBST13020, end    
    
@pnProdId                       int,                
@pnClientId                     int,         
@pcClientCode                   varchar(20) ='',                   
@pcTranCCY                      char(3),                   
@pmTranAmt                      decimal(25,13),                
@pmTranUnit                     decimal(25,13),    
@pmUnitBalance                  decimal(25,13),    
@pbFullAmount                   bit,    
@pbByPhoneOrder                 bit = 0,              
@pmSubcFee                      decimal(25,13),                
@pmRedempFee                    decimal(25,13),    
@pbIsFeeEdit                    bit = 0,    
@pbJenisPerhitunganFee          int = 1, -- diisi dengan 1 = by % atau 0 = by nominal    
@pdPercentageFee                decimal(25,13) = 0, -- kalau jenis perhitungan fee = 1, ini tidak mandatory       
@pnPeriod                       int = 0,    
@pbByUnit                       bit,     
@pnJangkaWaktu                  int,    
@pdJatuhTempo                   datetime,     
@pnAutoRedemption               tinyint,    
@pnAsuransi                     tinyint,    
@pnFrekuensiPendebetan          int = 1,     
@pnRegTransactionNextPayment    int = 0,      
    
@pcInputter                     varchar(40),      
@pnSeller                       int,    
@pnWaperd                       int,                
@pnNIK                          int,        
@pnReferentor                   int,            
@pcGuid                         varchar(50),                
@pbIsPartialMaturity            bit = 0,      
     
@pcWarnMsg                      varchar(200) = ''  output,    
@pcWarnMsg2                     varchar(200) = ''  output,                 
@pcWarnMsg3                     varchar(200) = '' OUTPUT     
--20150608, liliana, LIBST13020, begin    
,@pbDocFCSubscriptionForm bit = 0            
,@pbDocFCDevidentAuthLetter         bit = 0            
,@pbDocFCJoinAcctStatementLetter    bit = 0            
,@pbDocFCIDCopy                     bit = 0            
,@pbDocFCOthers                     bit = 0            
,@pbDocTCSubscriptionForm           bit = 0            
,@pbDocTCTermCondition              bit = 0            
,@pbDocTCProspectus                 bit = 0             
,@pbDocTCFundFactSheet              bit = 0            
,@pbDocTCOthers                     bit = 0           
,@pcDocFCOthersList   varchar(4000) = ''            
,@pcDocTCOthersList   varchar(4000) = ''     
--20150608, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
, @pbTrxTaxAmnesty                  bit = 0  
--20160830, liliana, LOGEN00196, end   
as            
                
set nocount on                
                
declare @nOK            tinyint,         
  @cErrMsg              varchar(200),                
  @c3DigitClientCode    char(3),                
  @c5DigitCounter       char(5),                
  @nCounter             int,                
  @cClientCode          varchar(11),                
  @cProdCCY             char(3),                
  @dCutOff              datetime,                
  @nCutOff              int,                
  @dCurrWorkingDate     datetime,                
  @dNextWorkingDate     datetime,                
  @bProcessStatus       bit,                
  @mEffUnit             decimal(25,13),                  
  @mLastNAV             decimal(25,13),       
  @mFeeBased            decimal(25,13),       
  @nSubFeeBased         decimal(25,13),    
  @mMaksUnit            decimal(25,13),    
  @cProdCode            varchar(10),     
  @mUnitPerkiraan       decimal(25,13),      
  @cNISPAccId           varchar(19),                
  @cProductCodeRek      varchar(10),    
  @cAccountType         char(3),       
  @cMCAllowed           char(1),                
  @cAccountStatus       char(1),                
  @cCurrencyType        char(3),    
  @dCurrDate            datetime,    
  @mMinNew              decimal(25,13),      
  @mMinAdd              decimal(25,13),     
  @mMinRedemp           decimal(25,13),        
  @mMinRedempbyUnit     bit,    
  @mMinBalance          decimal(25,13),     
  @nExtStatus           int,    
  @nWindowPeriod        int,    
  @mMinBalanceByUnit    bit,     
  @nIsEmployee          tinyint,    
  @dGoodFund            datetime,    
  @nManInvId            int,                 
  @nNDayBefore          tinyint,    
  @nRedempType          tinyint,    
  @nReksaTranType       int,    
  @nSubscMin            money,      
  @nRegSubscriptionFlag int,    
  @nSubscAddMultiplier  money,    
  @nMinTimeLength       int,     
  @nTimeLengthMultiplier int,    
  @nToleratedTime       int,    
  @dPeriodStart         datetime,    
  @dHalfPeriod          datetime,    
  @nHalfMonth           int,    
  @nRegSubsTranId       int,    
  @nRegSubsStatus       int,    
  @dCurrWorkingDate2    datetime,    
  @nProdIdException     int,    
  @nProductRiskProfile  int,    
  @nCustomerRiskProfile int,    
  @cTrxType             varchar(50),    
  @dMinPctFeeEmployee   float,    
  @dMaxPctFeeEmployee   float,    
  @dMinPctFeeNonEmployee decimal(25,13),    
  @dMaxPctFeeNonEmployee decimal(25,13),    
  @nPercentageTaxFee    decimal(25,13),    
  @mTaxFeeBased         decimal(25,13),    
  @nPercentageFee3      decimal(25,13),     
  @mFeeBased3           decimal(25,13),    
  @nPercentageFee4      decimal(25,13),    
  @mFeeBased4           decimal(25,13),    
  @nPercentageFee5      decimal(25,13),    
  @mFeeBased5           decimal(25,13),    
  @mTotalFeeBased       decimal(25,13),    
  @mRedempFeeBased      decimal(25,13),    
  @mTotalRedempFeeBased decimal(25,13),    
  @nPercentageRedempFee int,    
  @mTotalPctFeeBased    decimal(25,13),    
  @mDefaultPctTaxFee    decimal(25,13),      
  @mSubTotalPctFeeBased decimal(25,13),      
  @mSelisihFee          decimal(25,13),     
  @cChannel             varchar(20),    
  @nFeeId               int ,    
  @nUmur                int,    
  @dJoinDate            datetime,    
  @CIFNIK               varchar(5),    
  @pcGiftCode           varchar(50),    
  @pnBiayaHadiah        decimal(25,13),    
  @pmNAV                decimal(25,13),    
  @pdNAVValueDate       datetime,    
  @pnProcessId          int,    
  @pnTranId             int,    
  @cPFix                varchar(10),    
  @nCounterClient       varchar(10),    
  @nAgentId             int,    
  @nFundId              int,    
  @cDefaultCCY          char(3)    
--20150608, liliana, LIBST13020, begin    
  ,@nBankId             int     
--20150608, liliana, LIBST13020, end      
--20150629, liliana, LIBST13020, begin    
  , @cCIFNo19           varchar(19)     
--20150629, liliana, LIBST13020, end    
--20150630, liliana, LIBST13020, begin    
  , @bIsMC              int    
  , @cTempNoRekening    varchar(20)    
--20150630, liliana, LIBST13020, end    
--20150813, liliana, LIBST13020, begin    
  , @cNoRekeningUSD     varchar(20)    
  , @cNoRekeningMC      varchar(20)    
--20150813, liliana, LIBST13020, end    
--20151001, liliana, LIBST13020, begin    
  , @cCountryCode       varchar(50)    
  , @cCountryName       varchar(200)    
--20151001, liliana, LIBST13020, end    
--20160818, Lita, LIBST15330, begin    
    , @cSII         varchar(20)    
--20160818, Lita, LIBST15330, end    
--20160830, liliana, LOGEN00196, begin  
  , @cNoRekeningTA       varchar(20)      
  , @cNoRekeningUSDTA    varchar(20)    
  , @cNoRekeningMCTA     varchar(20)  
  , @nCIFNoBigInt        bigint     
--20160830, liliana, LOGEN00196, end    
--20161021, liliana, CSODD16311, begin  
  , @nToday         int  
  , @dToday         datetime  
--20161021, liliana, CSODD16311, end    
--20161031, liliana, CSODD16311, begin  
  , @cIFUATA            varchar(50)  
--20161031, liliana, CSODD16311, end    
--20171018, Lita, LOGEN00466, begin  
    , @cAccountNoValidate varchar(19)  
    , @cOfficeIdValidate varchar(5)  
--20171018, Lita, LOGEN00466, end   
--20171020, Lita, LOGEN00466, begin   
 , @dcNoRekening decimal(19,0)  
 , @dcNoRekeningUSD decimal(19,0)  
 , @dcNoRekeningMC decimal(19,0)  
 , @dcNoRekeningTA decimal(19,0)  
 , @dcNoRekeningUSDTA decimal(19,0)  
 , @dcNoRekeningMCTA decimal(19,0)  
--20171020, Lita, LOGEN00466, end  
--20171205, Lita, LOGAM09096, begin
	, @dcSII	varchar(20)
--20171205, Lita, LOGAM09096, end
       
select @nRegSubscriptionFlag = 0             
set @pcWarnMsg = ''      
SET @pcWarnMsg2 = ''     
set @pcWarnMsg3 = ''              
set @nOK = 0     
--20150629, liliana, LIBST13020, begin    
set @cCIFNo19 = right(('0000000000000000000'+@pcCIFNo),19)     
--20150629, liliana, LIBST13020, end    
--20151005, liliana, LIBST13020, begin    
set @pmTranUnit = round(@pmTranUnit,4)    
set @pmUnitBalance = round(@pmUnitBalance,4)    
--20151005, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
set @nCIFNoBigInt = convert(bigint,@pcCIFNo)  
--20160830, liliana, LOGEN00196, end   
--20161021, liliana, CSODD16311, begin  
set @dToday = getdate()  
set @nToday = dbo.fnDatetimeToJulian(@dToday)  
--20161021, liliana, CSODD16311, end  
    
select @mDefaultPctTaxFee = PercentageTaxFeeDefault      
from dbo.control_table      
      
set @mSubTotalPctFeeBased = 100      
      
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee      
     
select @nFeeId = FeeId      
from dbo.ReksaProduct_TM      
where ProdId = @pnProdId      
            
select @nReksaTranType = @pnTranType     
    
select @nProdIdException = ProdId       
from dbo.ReksaProduct_TM      
where ProdCode = 'RDS'        
    
select @nIsEmployee = isnull(IsEmployee, 0),    
    @CIFNIK = CIFNik     
from ReksaMasterNasabah_TM     
where CIFNo = @pcCIFNo       
    
select @nAgentId = AgentId    
from dbo.ReksaAgent_TR    
where ProdId = @pnProdId    
    and OfficeId = @pcOfficeId    
--20150608, liliana, LIBST13020, begin    
--20150813, liliana, LIBST13020, begin    
if @nReksaTranType = 8    
begin    
    set @pbFullAmount = 1    
end    
--20150813, liliana, LIBST13020, end    
    
select @nBankId = BankId    
from dbo.ReksaBankCode_TR    
where ProdId = @pnProdId    
    and BankCode = 'OCBC001'    
        
select @dJoinDate = getdate()    
--20150608, liliana, LIBST13020, end        
    
select @nFundId = FundId    
from dbo.ReksaFundCode_TR    
where ProdId = @pnProdId    
    
select @pnProcessId = ProcessId    
from dbo.ReksaUserProcess_TR    
where ProcessName = 'Process Subcription'    
--20150625, liliana, LIBST13020, begin    
--20151001, liliana, LIBST13020, begin    
select @cCountryCode = CFCITZ    
from dbo.CFMAST_v    
where CFCIF = @cCIFNo19      
    
select @cCountryName = CountryName    
from dbo.ReksaCountryRestriction_TR    
where CountryCode = @cCountryCode    
--20151001, liliana, LIBST13020, end    
    
--20150813, liliana, LIBST13020, begin    
--if(@pcTranCCY = 'USD')    
--begin    
--  select @pcNoRekening = NISPAccountIdUSD    
--  from dbo.ReksaMasterNasabah_TM    
--  where CIFNo = @pcCIFNo    
--20150813, liliana, LIBST13020, end    
--20150630, liliana, LIBST13020, begin    
--20150813, liliana, LIBST13020, begin    
    
    --if isnull(@pcNoRekening,'') = ''             
    --begin                
    --  set @cErrMsg = 'Harap melakukan setting Nomor Rekening di menu Master Nasabah (1)'                
    --  goto ERROR                
    --end    
--20150813, liliana, LIBST13020, end        
--20150630, liliana, LIBST13020, end    
--20150813, liliana, LIBST13020, begin    
--end    
--20150813, liliana, LIBST13020, end    
--20150630, liliana, LIBST13020, begin    
--20150813, liliana, LIBST13020, begin    
--else if @pcTranCCY = 'IDR' and isnull(@pcNoRekening,'') = ''     
--begin    
--  select @cTempNoRekening = NISPAccountIdUSD    
--  from dbo.ReksaMasterNasabah_TM    
--  where CIFNo = @pcCIFNo    
    
--  if isnull(@cTempNoRekening,'') = ''             
--  begin                
--      set @cErrMsg = 'Harap melakukan setting Nomor Rekening di menu Master Nasabah (2)'                
--      goto ERROR                
--  end    
        
--  select @bIsMC = case     
--      when DDNUM = 0 then 0 else 1 end    
--  from SQL_SIBS.dbo.DDMAST    
--  where ACCTNO = @cTempNoRekening    
    
--  if not exists(select top 1 1 from SQL_SIBS.dbo.DDMAST where ACCTNO = @cTempNoRekening)    
--  begin    
--      select @bIsMC = case     
--          when SCCODE like '%MC%' then 0 else 1 end    
--      from dbo.DDTNEW_v    
--      where ACCTNO = @cTempNoRekening    
--  end     
        
--  if @bIsMC = 1    
--  begin    
--      set @pcNoRekening = @cTempNoRekening    
--  end    
--  else    
--  begin    
--      set @cErrMsg = 'Harap melakukan setting Nomor Rekening di menu Master Nasabah (3)'                
--      goto ERROR          
--  end    
--end    
select @pcNoRekening = NISPAccountId,    
    @cNoRekeningUSD = NISPAccountIdUSD,    
    @cNoRekeningMC = NISPAccountIdMC    
--20160830, liliana, LOGEN00196, begin  
    , @cNoRekeningTA =  AccountIdTA  
    , @cNoRekeningUSDTA = AccountIdUSDTA  
    , @cNoRekeningMCTA = AccountIdMCTA  
--20160830, liliana, LOGEN00196, end       
from dbo.ReksaMasterNasabah_TM    
where CIFNo = @pcCIFNo    
--20171018, Lita, LOGEN00466, begin   
create table #tmpValidateOffice (  
    AccountNo decimal(19,0),  
    OfficeId int,  
    OfficeName varchar(40)  
)  
--20171020, Lita, LOGEN00466, begin   
select @dcNoRekening = case when isnull(@pcNoRekening,'') = '' then 0 else convert(decimal(19,0), @pcNoRekening) end  
 , @dcNoRekeningUSD = case when isnull(@cNoRekeningUSD,'') = '' then 0 else convert(decimal(19,0), @cNoRekeningUSD) end  
 , @dcNoRekeningMC = case when isnull(@cNoRekeningMC,'') = '' then 0 else convert(decimal(19,0), @cNoRekeningMC) end  
 , @dcNoRekeningTA = case when isnull(@cNoRekeningTA,'') = '' then 0 else convert(decimal(19,0), @cNoRekeningTA) end  
 , @dcNoRekeningUSDTA = case when isnull(@cNoRekeningUSDTA,'') = '' then 0 else convert(decimal(19,0), @cNoRekeningUSDTA) end  
 , @dcNoRekeningMCTA = case when isnull(@cNoRekeningMCTA,'') = '' then 0 else convert(decimal(19,0), @cNoRekeningMCTA) end  
--20171020, Lita, LOGEN00466, end  
  
insert #tmpValidateOffice  
select a.ACCTNO, a.BRANCH, b.office_name  
from DDMAST_v a with(nolock)  
join office_information_sibs_v b with(nolock)  
    on a.BRANCH = convert(int, b.office_id_sibs)  
where a.ACCTNO in (   
--20171020, Lita, LOGEN00466, begin  
    --isnull(convert(decimal(19,0), @pcNoRekening), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningUSD), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningMC), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningTA), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningUSDTA), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningMCTA), 0)  
 @dcNoRekening  
 , @dcNoRekeningUSD  
 , @dcNoRekeningMC  
 , @dcNoRekeningTA  
 , @dcNoRekeningUSDTA  
 , @dcNoRekeningMCTA  
--20171020, Lita, LOGEN00466, end  
)  
  
insert #tmpValidateOffice  
select a.ACCTNO, a.BRANCH, b.office_name  
from DDTNEW_v a with(nolock)  
join office_information_sibs_v b with(nolock)  
    on a.BRANCH = convert(int, b.office_id_sibs)  
where a.ACCTNO in (   
--20171020, Lita, LOGEN00466, begin  
    --isnull(convert(decimal(19,0), @pcNoRekening), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningUSD), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningMC), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningTA), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningUSDTA), 0),  
    --isnull(convert(decimal(19,0), @cNoRekeningMCTA), 0)  
 @dcNoRekening  
 , @dcNoRekeningUSD  
 , @dcNoRekeningMC  
 , @dcNoRekeningTA  
 , @dcNoRekeningUSDTA  
 , @dcNoRekeningMCTA  
--20171020, Lita, LOGEN00466, end  
)     
  
if exists (select top 1 1 from #tmpValidateOffice where lower(OfficeName) like '%tutup%')  
begin  
    select top 1 @cAccountNoValidate = convert(varchar(19), AccountNo), @cOfficeIdValidate = convert(varchar(5), OfficeId) from #tmpValidateOffice   
    where lower(OfficeName) like '%tutup%'  
    drop table #tmpValidateOffice  
      
    set @cErrMsg = 'Nomor rekening ' + isnull(@cAccountNoValidate, '') + ' yang masih terdaftar pada cabang yang sudah tutup, harap mengganti nomor rekening tersebut!'        
    goto ERROR  
end  
--20171018, Lita, LOGEN00466, end  
  
--20160830, liliana, LOGEN00196, begin  
if @pbTrxTaxAmnesty = 1  
begin  
    if @pcTranCCY = 'IDR' and isnull(@cNoRekeningTA,'') != ''     
    begin     
        set @pcNoRekening = @cNoRekeningTA    
    end    
    else if @pcTranCCY = 'USD' and isnull(@cNoRekeningUSDTA,'') != ''    
    begin    
        set @pcNoRekening = @cNoRekeningUSDTA    
    end    
    else if isnull(@cNoRekeningMCTA,'') != ''    
    begin    
        set @pcNoRekening = @cNoRekeningMCTA    
    end   
end  
else  
begin  
--20160830, liliana, LOGEN00196, end    
if @pcTranCCY = 'IDR' and isnull(@pcNoRekening,'') != ''     
begin     
    set @pcNoRekening = @pcNoRekening    
end    
else if @pcTranCCY = 'USD' and isnull(@cNoRekeningUSD,'') != ''    
begin    
    set @pcNoRekening = @cNoRekeningUSD    
end    
else if isnull(@cNoRekeningMC,'') != ''    
begin    
    set @pcNoRekening = @cNoRekeningMC    
end    
--20160830, liliana, LOGEN00196, begin  
end  
--20160830, liliana, LOGEN00196, end  
    
if isnull(@pcNoRekening,'') = ''    
begin    
    set @cErrMsg = 'Harap melakukan setting Nomor Rekening di menu Master Nasabah'                
    goto ERROR    
end    
--20150813, liliana, LIBST13020, end    
--20150630, liliana, LIBST13020, end    
--20150625, liliana, LIBST13020, end   
--20161031, liliana, CSODD16311, begin  
--20170517, liliana, LOGEN00395, begin  
  
if exists(  
    select top 1 1   
    from dbo.TAMAST_v ta  
    join dbo.TCLOGT_v tc  
        on ta.CFCIF# = tc.TCLCIF  
    where tc.TCFLAG = 7 and ta.TAFLAG = 7  
        and ta.CFACC# = @pcNoRekening  
    )  
begin                     
    set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'          
    goto ERROR        
end   
  
--20170517, liliana, LOGEN00395, end   
select @cIFUATA = IFUA  
from dbo.ReksaIFUAMapping_TM  
where CIFNo = @pcCIFNo  
    and AccType = 'TA'  
      
--20161031, liliana, CSODD16311, end    
select @cDefaultCCY = CFAGTY    
from dbo.CFAGRPMC_v    
where convert(bigint, CFAGNO) = convert(bigint, @pcNoRekening)    
    
--20160818, Lita, LIBST15330, begin    
select @cSII = isnull(CFSSNO,'')    
from CFAIDN_v    
where CFCIF = @cCIFNo19 and CFSSCD = 'SII'     
--20171205, Lita, LOGAM09096, begin
select @dcSII = isnull(SII,'')
from ReksaIFUAMapping_TM 
where CIFNo = @pcCIFNo
	and AccType = 'KYC'

if isnull(@dcSII,'') = ''
begin
	set @cErrMsg = 'Belum upload KYC di S-Invest. Mohon menghubungi Partnership Operation.'
	goto ERROR
end
--20171205, Lita, LOGAM09096, end
    
if isnull(@cSII,'') = ''    
begin    
    set @cErrMsg = 'SID belum terdaftar. Mohon melakukan pengkinian data melalui cabang kami.'                
    goto ERROR    
end    
    
if ((@cSII like 'TDP%' or isnull(@cSII,'') = '') and @nReksaTranType in (5,6))    
begin    
    set @cErrMsg = 'SID yang terdaftar masih sementara. Mohon melakukan pengkinian data melalui cabang kami.'                
    goto ERROR    
end    
--20160818, Lita, LIBST15330, end    
    
if @nReksaTranType in (1,2,8)       
begin      
    set @cTrxType = 'SUBS'      
end      
else if @nReksaTranType in (3,4)       
begin      
    set @cTrxType = 'REDEMP'      
end    
    
if(@pbByPhoneOrder = 1)    
begin    
    set @cChannel = 'TLP'    
end    
else    
begin    
   set @cChannel = 'CBG'    
end    
    
if @nReksaTranType not in (8)            
begin                   
    select @pnAutoRedemption = 0,                
    @pnJangkaWaktu = 0, @pdJatuhTempo = null,            
    @pcGiftCode = null, @pnBiayaHadiah = 0            
end     
                  
select @dCurrWorkingDate = current_working_date,     
    @dCurrWorkingDate2 = current_working_date       
from dbo.fnGetWorkingDate()                
           
select @dCurrDate = current_working_date                
from control_table    
               
select @cProdCode = ProdCode                   
    , @mMinNew    = case @nIsEmployee when 0 then MinSubcNew else MinSubcNewEmp end                 
    , @mMinAdd    = case @nIsEmployee when 0 then MinSubcAdd else MinSubcAddEmp end                      
    , @mMinRedemp   = case @nIsEmployee when 0 then MinRedemption else MinRedemptionEmp end               
    , @mMinRedempbyUnit  = MinRedempByUnit          
    , @mMinBalance   = case @nIsEmployee when 0 then MinBalance else MinBalanceEmp end              
    , @mMinBalanceByUnit = MinBalanceByUnit                       
    , @nWindowPeriod = WindowPeriod                
    , @nManInvId = ManInvId                   
    , @nRedempType = RedempType    
    , @cProdCCY = ProdCCY                  
from dbo.ReksaProduct_TM                 
where ProdId = @pnProdId              
                        
select @nNDayBefore = NDayBefore            
from dbo.ReksaWindowPeriod_TM            
where ProdId = @pnProdId    
    
select top 1 @pmNAV = NAV,    
    @pdNAVValueDate = ValueDate      
from dbo.ReksaNAVParam_TH      
where ProdId = @pnProdId      
order by ValueDate desc    
    
if @pmNAV is null       
begin      
    select @pmNAV = NAV       
    from dbo.ReksaProduct_TM      
    where ProdId = @pnProdId       
end     
    
if @pnType not in (1, 2, 3)                
begin                
    set @cErrMsg = 'Kode @pnType salah, 1:new, 2:update, 3:delete'                
    goto ERROR                
end    
    
if @pnType in (1) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranCode = @pcTranCode)    
begin    
    set @cErrMsg = 'Kode '+ @pcTranCode +' sudah digunakan!'                
    goto ERROR       
end    
    
--20150608, liliana, LIBST13020, begin    
--20150709, liliana, LIBST13020, begin    
if exists(select top 1 1 from dbo.ReksaMasterNasabah_TM where CIFNo = @pcCIFNo and ApprovalStatus = 'T')    
begin    
    set @cErrMsg = 'Shareholder ID / Nomor CIF tersebut sudah tidak aktif!'                
    goto ERROR      
end    
    
--20150709, liliana, LIBST13020, end    
--20151001, liliana, LIBST13020, begin    
    
if @nReksaTranType in (1,2,8) and exists(select top 1 1 from dbo.ReksaCountryRestriction_TR where CountryCode  = @cCountryCode)    
begin    
    set @cErrMsg = 'Kewarganegaraan '+ isnull(@cCountryName,'') +' tidak diijinkan untuk melakukan transaksi reksadana!'    
    goto ERROR    
end    
    
--20151001, liliana, LIBST13020, end    
if isnull(@pcClientCode,'') = ''    
begin    
    set @cErrMsg = 'Client Code tidak boleh kosong!'                
    goto ERROR       
end    
               
if exists(select top 1 1 from control_table where end_of_day = 1 and begin_of_day = 0)                
begin                
    set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'                
    goto ERROR                
end     
    
--20150608, liliana, LIBST13020, end    
If @pnType in (2,3) and @nReksaTranType in (1,2,8) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = @pnProcessId and ProcessStatus = 1)    
--20150908, liliana, LIBST13020, begin    
    and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranCode = @pcTranCode and NAVValueDate = @dCurrDate     
    )    
--20150908, liliana, LIBST13020, end    
begin           
--20151001, liliana, LIBST13020, begin    
    --set @cErrMsg = 'Sudah lewat cut off, tidak dapat melakukan perubahan data subscription'    
    set @cErrMsg = 'Sudah lewat cut off, tidak dapat melakukan perubahan data'    
--20151001, liliana, LIBST13020, end        
    goto ERROR       
end     
--20150918, liliana, LIBST13020, begin    
--20151001, liliana, LIBST13020, begin    
    
If @pnType in (2,3) and @nReksaTranType in (3,4) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = @pnProcessId and ProcessStatus = 1)    
    and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranCode = @pcTranCode and NAVValueDate = @dCurrDate     
    )    
begin           
    set @cErrMsg = 'Sudah lewat cut off, tidak dapat melakukan perubahan data'    
    goto ERROR       
end     
--20151001, liliana, LIBST13020, end    
    
If @pnType in (2,3)     
    and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranCode = @pcTranCode and BillId is not null    
    )    
begin           
    set @cErrMsg = 'Sudah terbentuk bill, tidak dapat melakukan perubahan data'    
    goto ERROR       
end    
--20150918, liliana, LIBST13020, end    
    
--20150608, liliana, LIBST13020, begin    
--If @pnType in (2,3) and exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode and AuthType in (2,3) and RefID = @pcRefID)    
--20150629, liliana, LIBST13020, begin    
--If @pnType in (2,3) and exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode and AuthType in (2,3)    
--  and Status = 0    
--  and RefID = @pcRefID)    
--20150629, liliana, LIBST13020, end        
--20150608, liliana, LIBST13020, end    
--20150629, liliana, LIBST13020, begin    
--begin           
--  set @cErrMsg = 'Perubahan sebelumnya belum diotorisasi !'    
--  goto ERROR     
--end    
--20150629, liliana, LIBST13020, end    
        
    
if @pnType in (2, 3) and exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode and UserSuid = 7 )                
begin                
    set @cErrMsg = 'Transaksi dari proses READ ONLY'                
    goto ERROR                
end    
--20150608, liliana, LIBST13020, begin    
    
--20150629, liliana, LIBST13020, begin    
--if @pnType in (2, 3) and exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode and Status = 0)    
--begin    
--  set @cErrMsg = 'Transaksi masih menunggu proses otorisasi. Tidak dapat diubah!'                
--  goto ERROR       
--end    
if @pnType in (2, 3) and exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode and Status = 2)    
begin    
    set @cErrMsg = 'Transaksi dengan Status Reject tidak dapat diubah!'                
    goto ERROR       
end    
--20150629, liliana, LIBST13020, end    
    
if @pnType in (2, 3) and not exists(select top 1 1 from ReksaTransaction_TT where TranCode = @pcTranCode)    
begin    
    set @cErrMsg = 'Transaksi tidak dapat diubah karena data sudah berpindah ke history!'                
    goto ERROR       
end    
--20150608, liliana, LIBST13020, end    
    
--20150709, liliana, LIBST13020, begin    
--if (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1     
if @nReksaTranType in (3,4) and (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1     
--20150709, liliana, LIBST13020, end           
begin            
    set @cErrMsg = 'Tidak bisa melakukan transaksi karena proses sinkronisasi sedang dijalankan. Harap tunggu'            
    goto ERROR            
end            
--20171108, sandi, LOGAM09102, begin    
    if exists (select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId and Status = 0)        
    begin        
        select @cErrMsg = 'Terdapat transaksi Subscription New untuk Client Code '+ isnull(@pcClientCode, '') +' dengan status Pending Otorisasi.'    
        goto ERROR         
    end      
--20171108, sandi, LOGAM09102, end
               
if @nReksaTranType in (2) and     
    not exists (    
    select TranId from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId                           
        and Status = 1                
        union                
        select TranId from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId                          
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
begin                
    set @nReksaTranType = 1             
end      
                   
If @nReksaTranType in (2,3,4) and exists(select top 1 1 from dbo.ReksaNonAktifClientId_TT where ClientId = @pnClientId and StatusOtor = 0)                  
begin                  
    set @cErrMsg = 'Client Code sudah Tutup'                  
    goto ERROR                  
end     
    
If @nReksaTranType in (2,3,4) and exists(select top 1 1 from ReksaCIFData_TH where ClientId = @pnClientId and AuthType = 4) and (@pbIsPartialMaturity = 0) and (@pnRegTransactionNextPayment = 0)    
begin                
    set @cErrMsg = 'Perubahan Data Nasabah Belum Diotorisasi'                
    goto ERROR                
end       
    
If @nReksaTranType in (1,2) and @pmTranUnit > 0                      
begin                
    set @cErrMsg = 'Subscription Harus dalam Nominal'                
    goto ERROR              
end     
--20160830, liliana, LOGEN00196, begin  
--20170413, liliana, COPOD17019, begin  
  
if @pbTrxTaxAmnesty = 1 and @nReksaTranType not in (3, 4)  
    and exists(select top 1 1 from dbo.ReksaProductException_TR where [Type] = 'TA' and ProdCode = @cProdCode )  
begin  
    set @cErrMsg = 'Produk tersebut tidak dapat ditransaksikan sebagai transaksi Tax Amnesty'                
    goto ERROR   
end  
      
--20170413, liliana, COPOD17019, end  
  
--20161021, liliana, CSODD16311, begin  
--if @pbTrxTaxAmnesty = 1 and not exists(select top 1 1 from dbo.ProCIFTaxAmnesty_CIF_v where CFCIF# = @nCIFNoBigInt and TaxAmnestyType = 1)  
if @pbTrxTaxAmnesty = 1 and not exists(select top 1 1 from dbo.TCLOGT_v where TCLCIF = @nCIFNoBigInt and TCFLAG = 1   
    and TCEXP7 > @nToday  
    )  
    and   
    @nReksaTranType not in (3, 4)  
--20161021, liliana, CSODD16311, end  
begin      
    set @cErrMsg = 'Jenis transaksi Tax Amnesty hanya bisa dilakukan oleh CIF dengan flag Tax Amnesty'                
    goto ERROR   
end   
--20160830, liliana, LOGEN00196, end  
--20161031, liliana, CSODD16311, begin  
  
  
if @pbTrxTaxAmnesty = 1 and isnull(@cIFUATA,'') = ''   
begin   
    set @cErrMsg = 'Tidak dapat melakukan transaksi karena IFUA TA belum terdaftar'                
    goto ERROR   
end  
--20161031, liliana, CSODD16311, end   
    
if @nReksaTranType in (3) and @pmTranAmt > 0 and @pbIsPartialMaturity = 0      
begin      
    set @cErrMsg = 'Redemption Sebagian Harus dalam Unit, sementara tidak bisa dalam nominal.'                
    goto ERROR       
end        
    
if @nReksaTranType in (1,2) and (select Subscription from ReksaProduct_TM where ProdId = @pnProdId) = 0                   
begin            
    select @cErrMsg = 'Subscription untuk produk ' + ProdName + ' sudah dihentikan' from ReksaProduct_TM where ProdId = @pnProdId             
    goto ERROR            
end     
    
if @nReksaTranType in (3,4) and @pnProdId in (5,11)            
begin            
    select @cErrMsg = 'Redemption produk ' + ProdName + ' di-hold, hubungi PO' from ReksaProduct_TM where ProdId = @pnProdId             
    goto ERROR            
end    
    
If @nReksaTranType not in (1,8) and not exists(select top 1 1 from ReksaCIFData_TM where ClientId = @pnClientId and CIFStatus = 'A')                
begin                
    set @cErrMsg = 'Client Belum Aktif atau sudah Tutup'                
    goto ERROR                
end     
    
if @nReksaTranType in (2) and exists(select top 1 1 from dbo.ReksaFlagClientId_TT where isnull(Flag,0) = 1 and ClientId = @pnClientId and StatusOtor = 0)      
begin      
    select @cErrMsg = 'Client code tersebut di flag, tidak dapat melakukan transaksi subscription! '             
    goto ERROR       
end    
    
if @nReksaTranType in (2) and exists(select top 1 1 from dbo.ReksaCIFData_TM where isnull(Flag,0) = 1 and ClientId = @pnClientId)      
begin      
    select @cErrMsg = 'Client code tersebut di flag, tidak dapat melakukan transaksi subscription! '             
    goto ERROR       
end      
    
if exists (select top 1 1 from dbo.ReksaWaperd_TR where DateExpire < getdate() and NIK = @pnWaperd)            
begin            
    set @cErrMsg = 'WAPERD untuk NIK '+ convert(varchar,@pnWaperd) +' sudah expired'         
    goto ERROR            
end      
     
if @pnWaperd !=  @pnSeller      
begin      
    set @cErrMsg = 'NIK Seller tidak sama dengan NIK Waperd'                
    goto ERROR       
end    
    
if not exists (select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId)      
begin      
    select @cErrMsg = 'Setting parameter '+ @cTrxType +' produk '+ ProdName +' belom ada , harap hubungi WM' from dbo.ReksaProduct_TM where ProdId = @pnProdId                  
    goto ERROR       
end     
    
if @nReksaTranType in (1) and @pbByPhoneOrder = 1    
begin    
    select ClientId     
    into #tempListClientCode    
    from dbo.ReksaCIFData_TM    
    where CIFNo = @pcCIFNo    
     
    if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))    
    and not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))    
    and not exists(select top 1 1 from dbo.ReksaBooking_TM where CIFNo = @pcCIFNo and Status = 1)    
    and not exists(select top 1 1 from dbo.ReksaBooking_TH where CIFNo = @pcCIFNo and Status = 1)    
    begin    
      select @cErrMsg = 'Nasabah yang baru pertama kali melakukan transaksi Reksa Dana tidak dapat melakukan transaksi via phone (1)!'     
     goto ERROR     
    end    
end    
              
          
if isnull(@nIsEmployee, 0) = 1 and  @CIFNIK = @pnSeller              
begin    
    set @cErrMsg = 'Nasabah sama dengan Nama/NIK Seller'                
    goto ERROR    
end      
     
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
    
--20150813, liliana, LIBST13020, begin    
--if(@cDefaultCCY <> '' and @cDefaultCCY <> @pcTranCCY)    
--begin    
--  set @cErrMsg = 'Default Currency tidak boleh berbeda dengan Currency Transaksi, Default     
--                  : ' + @cDefaultCCY + ', Transaksi : ' + @pcTranCCY    
--  goto ERROR    
--end               
--20150813, liliana, LIBST13020, end    
    
--20150608, liliana, LIBST13020, begin                  
--if exists(select top 1 1 from control_table where end_of_day = 1 and begin_of_day = 0)                
--begin                
--  set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'                
--  goto ERROR                
--end     
                        
--if @pnTranType not in (1) and not exists (select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientId and ProdId = @pnProdId)      
if @pnTranType not in (1,8) and not exists (select top 1 1 from dbo.ReksaCIFData_TM where ClientId = @pnClientId and ProdId = @pnProdId)      
--20150608, liliana, LIBST13020, end              
begin                
    set @cErrMsg = 'Kode Client tidak sesuai dengan Kode Produk'                
    goto ERROR                
end                
                 
if (@pmTranAmt = 0) and (@pmTranUnit = 0)                
begin                
    set @cErrMsg = 'Nominal / Unit harus diisi'                
    goto ERROR                
end                
           
If @nReksaTranType in (1,2) and exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1)                      
Begin                
    set @cErrMsg = 'Hanya boleh melalui menu Booking'                
    goto ERROR                
End                
         
if @nReksaTranType in (8) and not exists(select top 1 1 from dbo.ReksaRegulerSubscription_TR where ProductId = @pnProdId)            
begin            
    set @cErrMsg = 'Kode Product tidak untuk Reguler Subscription'            
    goto ERROR            
end      
--20160830, liliana, LOGEN00196, begin  
  
if @nReksaTranType in (3,4)  
and @pbTrxTaxAmnesty = 1  
and not exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientId)  
begin  
    select @cErrMsg = 'Jenis transaksi Tax Amnesty hanya dapat dilakukan oleh Client Code Tax Amnesty'             
    goto ERROR    
end  
  
if @nReksaTranType in (3,4)  
and @pbTrxTaxAmnesty = 0  
and exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientId)  
begin  
    select @cErrMsg = 'Jenis transaksi Non Tax Amnesty hanya dapat dilakukan oleh Client Code Non Tax Amnesty'             
    goto ERROR    
end  
  
--20160830, liliana, LOGEN00196, end  
    
if(@pbIsFeeEdit = 1)      
begin       
    if(@nReksaTranType in (1,2,8))      
    begin       
        if(@nIsEmployee = 1)      
        begin      
            if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeEmployee <= @pdPercentageFee      
            and MaxPctFeeEmployee >= @pdPercentageFee)       
            begin         
                select @dMinPctFeeEmployee = convert(float,MinPctFeeEmployee), @dMaxPctFeeEmployee = convert(float,MaxPctFeeEmployee)         
                from dbo.ReksaParamFee_TM       
                where TrxType = @cTrxType     
                    and ProdId = @pnProdId      
        
                set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeEmployee))+' %.'               
                goto ERROR       
            end      
        end      
        else       
        begin      
            if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeNonEmployee <= @pdPercentageFee      
            and MaxPctFeeNonEmployee >= @pdPercentageFee)       
            begin      
                select @dMinPctFeeNonEmployee = convert(float,MinPctFeeNonEmployee), @dMaxPctFeeNonEmployee = convert(float,MaxPctFeeNonEmployee)      
                from dbo.ReksaParamFee_TM       
                where TrxType = @cTrxType     
                    and ProdId = @pnProdId      
             
                set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeNonEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeNonEmployee))+' %.'                  
                goto ERROR       
            end      
        end        
    end      
    else if(@nReksaTranType in (3,4))      
    begin      
        if(@nIsEmployee = 1)      
        begin      
            select top 1 @dMaxPctFeeEmployee = convert(float,Fee)             
            from dbo.ReksaRedemPeriod_TM              
            where FeeId = @nFeeId              
                and IsEmployee = @nIsEmployee                  
                and Period >= @pnPeriod                        
            order by Period Asc     
             
            if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeEmployee <= @pdPercentageFee      
            and @dMaxPctFeeEmployee >= @pdPercentageFee)     
            begin        
                select @dMinPctFeeEmployee = convert(float,MinPctFeeEmployee)         
                from dbo.ReksaParamFee_TM       
                where TrxType = @cTrxType     
                    and ProdId = @pnProdId      
        
                set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeEmployee))+' %.'                 
                goto ERROR       
            end      
        end      
        else       
        begin           
            select top 1 @dMaxPctFeeNonEmployee = convert(float,Fee)             
            from dbo.ReksaRedemPeriod_TM              
            where FeeId = @nFeeId              
                and IsEmployee = @nIsEmployee                  
                and Period >= @pnPeriod                        
            order by Period Asc     
             
            if not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId and MinPctFeeNonEmployee <= @pdPercentageFee       
            and @dMaxPctFeeNonEmployee >= @pdPercentageFee)      
            begin      
                select @dMinPctFeeNonEmployee = convert(float,MinPctFeeNonEmployee)      
                from dbo.ReksaParamFee_TM       
                where TrxType = @cTrxType and ProdId = @pnProdId      
          
                set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeNonEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeNonEmployee))+' %.'                              
                goto ERROR       
            end      
        end      
    end         
end      
    
--20150608, liliana, LIBST13020, begin       
--if @nReksaTranType = 8     
if @nReksaTranType = 8 and @pnRegTransactionNextPayment = 0           
--20150608, liliana, LIBST13020, end    
begin               
    select @nIsEmployee = isnull(IsEmployee, 0)     
    from ReksaCIFData_TM     
    where ClientId = @pnClientId    
                   
    select @nSubscMin = cast(ParamValue as money)     
    from dbo.ReksaRegulerSubscriptionParam_TR             
    where ParamId = 'SubscMin'     
        and ProductId = @pnProdId     
        and IsEmployee = @nIsEmployee    
                    
    select @nSubscAddMultiplier = cast(dbo.fnGetRegulerSubscParam('SubscAddMultiplier') as money)          
       
    select @nMinTimeLength = MinJangkaWaktu     
    from dbo.ReksaFrekPendebetanParam_TR     
    where FrekuensiPendebetan = @pnFrekuensiPendebetan       
             
    select @nTimeLengthMultiplier = Kelipatan     
    from dbo.ReksaFrekPendebetanParam_TR     
    where FrekuensiPendebetan = @pnFrekuensiPendebetan    
                        
    select @nToleratedTime = cast(dbo.fnGetRegulerSubscParam('ToleratedTime') as int)            
      
    if(@pnNIK <> 7)      
    begin           
        if @pmTranAmt < @nSubscMin            
        begin            
            select @cErrMsg = 'Minimal Subscription Amount Adalah: ' + convert(varchar(25),@nSubscMin,1)            
            goto ERROR             
        end       
    end               
            
    if @pmTranAmt % @nSubscAddMultiplier <> 0            
    begin            
        select @cErrMsg = 'Subscription Amount Harus Kelipatan: ' + convert(varchar(25),@nSubscAddMultiplier,1)            
        goto ERROR             
    end            
            
    if @pnJangkaWaktu < @nMinTimeLength            
    begin                  
        select @cErrMsg = 'Jangka Waktu harus min ' + convert(varchar(25),@nMinTimeLength) + ' bulan dan kelipatan ' + convert(varchar(25), @nTimeLengthMultiplier) + ' bulan'                 
        goto ERROR             
    end            
            
    if @pnJangkaWaktu % @nTimeLengthMultiplier <> 0            
    begin               
        select @cErrMsg = 'Jangka Waktu harus min ' + convert(varchar(25),@nMinTimeLength) + ' bulan dan kelipatan ' + convert(varchar(25), @nTimeLengthMultiplier) + ' bulan'               
        goto ERROR             
    end            
    
--20150608, liliana, LIBST13020, begin            
    --if not exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)            
    --begin            
    --  select @cErrMsg = 'Client Code bukan Nasabah Reguler Subscription'            
    --  goto ERROR            
    --end   
                  
    --if exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)                   
    --and exists (            
    --select top 1 1             
    --from ReksaTransaction_TT a            
    --join ReksaRegulerSubscriptionSchedule_TT b            
    --  on a.TranId = b.TranId            
    --where a.ClientId = @pnClientId            
    --  and a.ProdId = @pnProdId                  
    --union            
    --select top 1 1             
    --from ReksaTransaction_TH a            
    --join ReksaRegulerSubscriptionSchedule_TT b            
    --  on a.TranId = b.TranId            
    --where a.ClientId = @pnClientId            
    --  and a.ProdId = @pnProdId                   
    --)            
    --and @pnRegTransactionNextPayment = 0            
    --begin            
    --  select @cErrMsg = 'Client sudah pernah memiliki reguler subscription produk ini'            
    --  goto ERROR            
    --end     
--20150608, liliana, LIBST13020, end                      
end    
    
if exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)            
begin          
    if @nReksaTranType not in (3, 4, 8)            
    begin            
        select @cErrMsg = 'Client Reguler Subscription hanya boleh transaksi Reguler Subscription atau Redemption'            
        goto ERROR            
    end              
        
    if @nReksaTranType = 3            
    begin    
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
        select @cErrMsg = 'Masih ada transaksi reguler transaction yang belum dijalankan'            
        goto ERROR            
    end                
             
    select @pdJatuhTempo = max(ScheduledDate)            
    from ReksaRegulerSubscriptionSchedule_TT a            
    join ReksaTransaction_TT b            
        on a.TranId = b.TranId            
    where b.ClientId = @pnClientId            
        and a.Type = 0            
              
    if @pdJatuhTempo is null          
    begin       
        select @pdJatuhTempo = max(ScheduledDate)            
        from ReksaRegulerSubscriptionSchedule_TT a            
        join ReksaTransaction_TH b            
        on a.TranId = b.TranId            
        where b.ClientId = @pnClientId            
        and a.Type = 0             
    end    
                   
    select @pdJatuhTempo = dateadd(m, 1, @pdJatuhTempo)            
            
    if (@dCurrWorkingDate < @pdJatuhTempo)               
    begin            
        select @cErrMsg = 'Transaksi Reguler Subscription belum jatuh tempo'            
        goto ERROR            
    end            
end            
    
           
if @nReksaTranType in (3, 4)            
begin            
    set @pnAsuransi = null      
                  
    select @pnAsuransi = b.Asuransi            
    from ReksaRegulerSubscriptionSchedule_TT a            
    join ReksaTransaction_TT b            
    on a.TranId = b.TranId            
    where b.ClientId = @pnClientId            
    
    if @pnAsuransi is null         
    begin             
        select @pnAsuransi = b.Asuransi            
        from ReksaRegulerSubscriptionSchedule_TT a            
        join ReksaTransaction_TH b            
        on a.TranId = b.TranId            
        where b.ClientId = @pnClientId          
    end       
 end       
     
                  
end                  
           
    
if @nReksaTranType = 4 and exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)            
begin                
    select @dPeriodStart = min(ScheduledDate), @pdJatuhTempo = max(ScheduledDate)            
    from ReksaRegulerSubscriptionSchedule_TT a            
    join ReksaTransaction_TT b            
    on a.TranId = b.TranId            
    where b.ClientId = @pnClientId            
    and a.Type = 0            
             
    if @pdJatuhTempo is null or @dPeriodStart is null      
    begin          
        select @dPeriodStart = min(ScheduledDate), @pdJatuhTempo = max(ScheduledDate)            
        from ReksaRegulerSubscriptionSchedule_TT a            
        join ReksaTransaction_TH b            
            on a.TranId = b.TranId            
        where b.ClientId = @pnClientId            
            and a.Type = 0       
    end          
      
    select @pdJatuhTempo = dateadd(m, 1, @pdJatuhTempo)                  
    select @nHalfMonth = round(datediff(m, @dPeriodStart, @pdJatuhTempo), 0)            
           
                 
    if round(datediff(m, @dPeriodStart, @dCurrWorkingDate) + 0.5 , 0) <= @nHalfMonth                  
    begin               
        select @pnBiayaHadiah = a.BiayaHadiah,            
            @pcGiftCode = a.GiftCode                
            , @pnJangkaWaktu = a.JangkaWaktu            
            , @pdJatuhTempo = a.JatuhTempo              
        from ReksaTransaction_TT a            
        join ReksaRegulerSubscriptionSchedule_TT b            
            on a.TranId = b.TranId            
        where a.ClientId = @pnClientId            
            
    if @pnBiayaHadiah is null or @pcGiftCode is null      
    begin          
        select @pnBiayaHadiah = a.BiayaHadiah,            
             @pcGiftCode = a.GiftCode                  
            , @pnJangkaWaktu = a.JangkaWaktu            
            , @pdJatuhTempo = a.JatuhTempo             
        from ReksaTransaction_TH a            
        join ReksaRegulerSubscriptionSchedule_TT b            
        on a.TranId = b.TranId            
        where a.ClientId = @pnClientId      
    end            
end            
else            
begin          
  select @pnBiayaHadiah = 0.0            
end    
    
    if exists (select top 1 1 from ReksaTransaction_TT where ClientId = @pnClientId and TranType = 8             
        and NAVValueDate = @dCurrWorkingDate and Status = 1 and BillId is not null)            
    begin                
        set @cErrMsg = 'Tidak bisa redempt all karena ada transaksi reg subs yang sudah proses bill'            
        goto ERROR            
    end              
end            
      
exec @nOK = ABCSAccountInquiry             
--20150408, liliana, LIBST13020, begin       
    --@pcAccountID = @cNISPAccId      
    @pcAccountID = @pcNoRekening            
--20150408, liliana, LIBST13020, end            
    ,@pnSubSystemNId = 111501                
    ,@pcTransactionBranch = '99965'                
    ,@pcProductCode = @cProductCodeRek output                
    ,@pcCurrencyType = @cCurrencyType output                
    ,@pcAccountType =@cAccountType output                
    , @pcMultiCurrencyAllowed = @cMCAllowed output                
    , @pcAccountStatus = @cAccountStatus output           
    , @pcTellerId = '7'                      
                
--20150408, liliana, LIBST13020, begin     
if @nOK != 0 or @@error != 0      
begin    
    set @cErrMsg = 'Error exec ABCSAccountInquiry!'                  
    goto ERROR          
end    
    
--20150408, liliana, LIBST13020, end          
If @pbIsPartialMaturity = 0 and (@cAccountStatus not in ('1','4','9')) -- selain aktif, new, atau dormant dan bukan partial maturity               
Begin                
    set @cErrMsg = 'Relasi Sudah Tidak Aktif, Mohon Ganti Relasi!'                
    goto ERROR               
End    
    
--20150813, liliana, LIBST13020, begin    
--if @cCurrencyType != @cProdCCY                
--begin                
--  set @cErrMsg = 'Transaksi cross-currency tidak didukung'                
--  goto ERROR                
--end             
--20150813, liliana, LIBST13020, end       
              
-- support rek MC            
if @cMCAllowed = 'Y'            
begin            
    set @cNISPAccId = ltrim(SQL_SIBS.dbo.fnGetSIBSCurrencyCode(@pcTranCCY, 1) + ltrim(@cNISPAccId))            
        
    if (select SQL_SIBS.dbo.fnGetSIBSCurrencyCode(@pcTranCCY, 1)) <> ''             
    set @cCurrencyType = @pcTranCCY            
end    
--20150813, liliana, LIBST13020, begin    
else    
begin    
    if @cCurrencyType != @cProdCCY                
    begin                
        set @cErrMsg = 'Transaksi cross-currency tidak didukung'                
        goto ERROR                
    end       
end    
--20150813, liliana, LIBST13020, end    
      
If @pbByUnit = 0                
Begin                          
    select  @mUnitPerkiraan = dbo.fnReksaSetRounding(@pnProdId,2,cast(@pmTranAmt / @pmNAV as decimal(25,13)))                          
End                            
      
if @nReksaTranType in (2)                  
Begin                
    exec dbo.ReksaInqUnitNasDitwrkan @pcCIFNo, @cProdCode, @mMaksUnit output, 0, '', @dCurrWorkingDate      
                           
    if @mUnitPerkiraan > @mMaksUnit                    
    begin                      
        set @cErrMsg = 'Jumlah transaksi > jumlah unit ditawarkan (' + convert (varchar(40), cast(@mMaksUnit as money),1) + ')'                      
        goto ERROR                
    end                          
end                           
          
--cek subscription new                      
if @nReksaTranType = 1                     
begin              
--20150630, liliana, LIBST13020, begin                
    --if exists (select top 1 1 from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId                        
    --  and Status = 0                
    --  union                
    --  select top 1 1 from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId                           
    --  and Status = 0            
    --  union            
    --  select top 1 1 from dbo.ReksaTransaction_TT             
    --  where TranType = 8            
    --  and ClientId = @pnClientId            
    --  and Status = 0            
    --  and RegSubscriptionFlag = 1 --NEW, 2= ADD            
    --  union            
    --  select top 1 1 from dbo.ReksaTransaction_TH            
    --  where TranType = 8            
    --  and ClientId = @pnClientId            
    --  and Status = 0            
    --  and RegSubscriptionFlag = 1 --NEW, 2= ADD            
    --)                       
    --begin                
    --  set @cErrMsg = 'Client sudah pernah transaksi Subscription New, namun belum di reject / authorize'                
    --  goto ERROR                
    --end       
--20150630, liliana, LIBST13020, end                 
                 
    if exists (select TranId from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId                         
        and Status = 1                
        union                
        select TranId from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId                           
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
--20150608, liliana, LIBST13020, begin    
    and @pnType = 1    
--20150608, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
    and not exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientId)  
    and @pbTrxTaxAmnesty = 0  
--20160830, liliana, LOGEN00196, end  
    begin                
        set @cErrMsg = 'Client sudah pernah transaksi Subscription New sebelumnya'                
        goto ERROR                
    end  
--20160830, liliana, LOGEN00196, begin  
  
    if exists (select TranId from dbo.ReksaTransaction_TT where TranType = 1 and ClientId = @pnClientId                         
        and Status = 1                
        union                
        select TranId from dbo.ReksaTransaction_TH where TranType = 1 and ClientId = @pnClientId                           
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
    and @pnType = 1    
    and exists(select top 1 1 from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1 and ClientIdTax = @pnClientId)  
   and @pbTrxTaxAmnesty = 1  
    begin                
        set @cErrMsg = 'Client sudah pernah transaksi Subscription New sebelumnya'                
        goto ERROR                
    end  
--20160830, liliana, LOGEN00196, end                    
     
               
    If @pbFullAmount = 1                
    Begin                
        if @pmTranAmt < @mMinNew                
        begin                       
            set @cErrMsg = 'Minimal New Subsc : ' + convert(varchar(40),cast(@mMinNew as money),1)                     
            goto ERROR                
        end                
    End                
    else                 
    Begin                
        if (@pmTranAmt - @pmSubcFee) < @mMinNew                
        begin                     
            set @cErrMsg = 'Minimal New Subsc : ' + convert(varchar(40), cast(@mMinNew as money),1)                 
            goto ERROR                
        end               
    End                           
end     
          
--cek subscription add                       
if @nReksaTranType = 2                    
begin            
    If @pbFullAmount = 1                
    Begin                
        if @pmTranAmt < @mMinAdd                
        begin                         
            set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(40), cast(@mMinAdd as money),1)                     
            goto ERROR                
        end                
    End                
    else                 
    Begin                
        if (@pmTranAmt - @pmSubcFee) < @mMinAdd                
        begin                          
            set @cErrMsg = 'Minimal Add Subsc : ' + convert(varchar(40),cast(@mMinAdd as money),1)                  
            goto ERROR                
        end                
    End                          
end                
                   
--cek redemption apakah jumlahnya cukup           
if @nReksaTranType in (3, 4)                  
begin                
    select @mEffUnit = dbo.fnGetEffUnit(@pnClientId)                
                
    select top 1 @mLastNAV = NAV                
    from ReksaNAVParam_TH                
    where ProdId = @pnProdId                
    order by ValueDate desc    
                    
    select @mEffUnit = @mEffUnit - isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(@pnProdId,2,cast(TranAmt / @mLastNAV as decimal(25,13))) end), 0)                
    from ReksaTransaction_TT                
    where TranType in (3,4)                
        and Status in (0,1)                
        and ClientId = @pnClientId                         
        and ProcessDate is null                                 
      
    select @mEffUnit = @mEffUnit - isnull(sum(case when rs.ByUnit = 1 then rs.TranUnit else dbo.fnReksaSetRounding(@pnProdId,2, cast(rs.TranAmt / @mLastNAV as decimal(25,13))) end), 0)      
    from dbo.ReksaSwitchingTransaction_TM rs      
    left join dbo.ReksaTransaction_TT rt      
        on rs.TranCode = rt.TranCode      
--20150911, liliana, LIBST13020, begin            
    --where rs.TranType in (5,6)      
    where rs.TranType in (5,6,9)    
--20150911, liliana, LIBST13020, end        
        and rt.TranCode is null      
        and rs.Status in (0,1)      
        and rs.ClientIdSwcOut = @pnClientId       
        and rs.BillId is null      
--20150608, liliana, LIBST13020, begin    
    
    if(@pnType = 2)    
    begin    
        select @mEffUnit = @mEffUnit + isnull(sum(case when ByUnit = 1 then TranUnit else dbo.fnReksaSetRounding(ProdId, 2,cast(TranAmt / NAV as decimal(25,13))) end), 0)                
        from ReksaTransaction_TT                
        where TranType in (3,4)                
            and Status in (0,1)                
            and TranCode = @pcTranCode                          
    end    
--20150608, liliana, LIBST13020, end       
--20151001, liliana, LIBST13020, begin    
        
    if @pmTranUnit = @mEffUnit       
    begin    
        set @nReksaTranType = 4    
    end    
--20151001, liliana, LIBST13020, end         
    
     
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
                
    if @nReksaTranType = 3 and @pbIsPartialMaturity = 0             
    Begin                
        If @mMinRedempbyUnit = 1 -- pengecekan berdasarkan unit                
        Begin                
            if @pbByUnit = 1                
            Begin                
                if @pmTranUnit < @mMinRedemp                    
                begin                         
                    set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' Unit'                    
                    goto ERROR                
                end                 
            End                
            Else                
            Begin                
                if @pmTranAmt/@mLastNAV < @mMinRedemp                
                begin                   
                    set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' Unit Perkiraan'                   
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
                    set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' '+ @cProdCCY + '(Perkiraan)'                    
                    goto ERROR                
                end                 
            End                
            Else                
            Begin                
                if @pmTranAmt < @mMinRedemp                
                begin                        
                    set @cErrMsg = 'Minimal Redemption : ' + convert(varchar(40),cast(@mMinRedemp as money),1) + ' '+ @cProdCCY                     
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
                    set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit, sebaiknya REDEMP ALL'                        
                    goto ERROR                
                end                 
            End                
            Else                
            Begin                
                if @mEffUnit - (@pmTranAmt/@mLastNAV) < @mMinBalance                
                begin                     
                    set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' Unit Perkiraan, sebaiknya REDEMP ALL'                      
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
               set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY + ' , sebaiknya REDEMP ALL'                       
                    goto ERROR                
                end                 
            End                
        Else                
        Begin                
            if (@mEffUnit * @mLastNAV) - @pmTranAmt < @mMinBalance                
            begin                            
                set @cErrMsg = 'Minimal Saldo : ' + convert(varchar(40),cast(@mMinBalance as money),1) + ' '+ @cProdCCY+ ' , sebaiknya REDEMP ALL'                      
                goto ERROR                
            end                 
        End                
    End                
 End    
                           
end                
           
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
    
           
select @nCutOff = CutOff,     
    @bProcessStatus = ProcessStatus                
from dbo.ReksaUserProcess_TR                         
where ProcessId = (case when @nReksaTranType in (1,2,8) then 1 when @nReksaTranType in (3,4) then 2 end)                
    
        
select @dCurrWorkingDate = current_working_date, @dNextWorkingDate = next_working_date                
from dbo.fnGetWorkingDate()                
                
set @dCutOff = dateadd (minute, @nCutOff, @dCurrWorkingDate)                
set @dCurrWorkingDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate())                
                
    
         
if @nWindowPeriod = 1 and @nReksaTranType in (3,4) and @pbIsPartialMaturity = 0             
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
    
if @nReksaTranType in (1,2,8)      
begin      
    select @nSubFeeBased = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 1      
          
    if isnull(@nSubFeeBased, 0) = 0      
    begin      
      set @cErrMsg = 'Nilai persentase subs fee based tidak ditemukan!'                
         goto ERROR        
    end      
    
    select @mFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nSubFeeBased/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))                    
                    
     if @mFeeBased > @pmSubcFee                
      set @mFeeBased = @pmSubcFee                
    
    
    --pembagian pajak fee based      
    select @nPercentageTaxFee = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 2      
          
    if isnull(@nPercentageTaxFee, 0) = 0      
    begin      
      set @cErrMsg = 'Nilai persentase tax fee based tidak ditemukan!'                
         goto ERROR        
    end      
    
    select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))      
    
    if @mTaxFeeBased > @pmSubcFee                
      set @mTaxFeeBased = @pmSubcFee           
          
    --pembagian fee based 3 (jika ada)      
    select @nPercentageFee3 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 3      
          
    select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))      
          
    if @mFeeBased3 > @pmSubcFee                
      set @mFeeBased3 = @pmSubcFee       
            
    --pembagian fee based 4 (jika ada)          
    select @nPercentageFee4 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 4      
           
    select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))       
          
    if @mFeeBased4 > @pmSubcFee                
      set @mFeeBased4 = @pmSubcFee       
          
    --pembagian fee based 5 (jika ada)          
    select @nPercentageFee5 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 5      
           
    select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/@mTotalPctFeeBased as decimal(25,13)) * @pmSubcFee as decimal(25,13)))      
          
    if @mFeeBased5 > @pmSubcFee                
      set @mFeeBased5 = @pmSubcFee       
            
    --total fee based      
    set @mTotalFeeBased = isnull(@mFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)      
          
    
    select @mSelisihFee = @pmSubcFee - @mTotalFeeBased       
          
    select @mFeeBased = isnull(@mFeeBased, 0) + @mSelisihFee      
         
    set @mTotalFeeBased = isnull(@mFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)       
    
end      
else if @nReksaTranType in (3,4)      
begin      
     select @nPercentageRedempFee = isnull(Percentage,0)      
     from dbo.ReksaListGLFee_TM      
     where TrxType = @cTrxType      
     and ProdId = @pnProdId   
     and Sequence = 1      
         
    if isnull(@nPercentageRedempFee, 0) = 0      
    begin      
      set @cErrMsg = 'Nilai persentase redemp fee based tidak ditemukan!'                
         goto ERROR        
    end      
    
     select @mRedempFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageRedempFee/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))       
                 
                   
     if @mRedempFeeBased > @pmRedempFee                
      set @mRedempFeeBased = @pmRedempFee        
          
    --pembagian pajak fee based      
    select @nPercentageTaxFee = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 2      
         
           
    if isnull(@nPercentageTaxFee, 0) = 0      
    begin      
      set @cErrMsg = 'Nilai persentase redemp fee based tidak ditemukan!'                
         goto ERROR        
    end      
         
    select @mTaxFeeBased = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageTaxFee/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))      
    
          
    if @mTaxFeeBased > @pmRedempFee                
      set @mTaxFeeBased = @pmRedempFee           
          
    --pembagian fee based 3 (jika ada)      
    select @nPercentageFee3 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 3      
           
    select @mFeeBased3 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee3/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))      
    
          
    if @mFeeBased3 > @pmRedempFee                
      set @mFeeBased3 = @pmRedempFee       
            
    --pembagian fee based 4 (jika ada)          
    select @nPercentageFee4 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 4      
          
    select @mFeeBased4 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee4/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))      
          
    if @mFeeBased4 > @pmRedempFee                
      set @mFeeBased4 = @pmRedempFee       
          
    --pembagian fee based 5 (jika ada)          
    select @nPercentageFee5 = isnull(Percentage,0)      
    from dbo.ReksaListGLFee_TM      
    where TrxType = @cTrxType      
     and ProdId = @pnProdId      
     and Sequence = 5      
          
    select @mFeeBased5 = dbo.fnReksaSetRounding(@pnProdId,3,cast(cast(@nPercentageFee5/@mTotalPctFeeBased as decimal(25,13)) * @pmRedempFee as decimal(25,13)))      
          
    if @mFeeBased5 > @pmRedempFee                
      set @mFeeBased5 = @pmRedempFee       
            
    --total fee based      
    set @mTotalRedempFeeBased = isnull(@mRedempFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)      
          
          
    select @mSelisihFee = @pmRedempFee - @mTotalRedempFeeBased       
          
    select @mRedempFeeBased = isnull(@mRedempFeeBased, 0) + @mSelisihFee      
         
    set @mTotalRedempFeeBased = isnull(@mRedempFeeBased, 0) + isnull(@mTaxFeeBased,0) + isnull(@mFeeBased3,0)+ isnull(@mFeeBased4,0)+ isnull(@mFeeBased5,0)      
    
end          
                
if @pnType = 1                
begin          
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
            if(@pnRegTransactionNextPayment = 1)    
            begin    
                set @pdNAVValueDate = @dCurrWorkingDate          
            end    
            else    
            begin    
                set @pdNAVValueDate = @dNextWorkingDate                
                set @pcWarnMsg = 'Valuedate dari transaksi ini : ' + convert (varchar, @pdNAVValueDate, 103)              
            end    
        end             
    end                
    
--20150911, liliana, LIBST13020, begin    
    --if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)       
    --begin      
    --    set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan switching all hari ini.'                         
    --    goto ERROR        
    --end      
    --else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)      
    --begin      
    --    set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan redempt all hari ini.'                         
    --    goto ERROR        
    --end      
    --else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcOut = @pnClientId)      
    --begin      
    --    set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah di switch out hari ini.'                         
    --    goto ERROR        
    --end      
    --else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)      
    --begin      
    --    set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah redempt hari ini.'                         
    --    goto ERROR        
    --end      
    --else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientIdSwcIn = @pnClientId)      
    --begin      
    --    set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah di switch in hari ini.'                         
    --    goto ERROR        
    --end      
    --else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2,8) and Status in (0, 1) and NAVValueDate  = @dCurrWorkingDate2 and ClientId = @pnClientId)      
    --begin      
    --    set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah subs new/add hari ini.'                         
    --    goto ERROR        
    --end      
--20150911, liliana, LIBST13020, end        
    
    if isnull(@nWindowPeriod,0) = 0            
    Begin            
        if @pbByUnit=0                
        begin               
            if (@pmTranAmt>5000000000) and @nManInvId = 1 and @pnProdId != @nProdIdException           
            begin                 
                if(@pbIsPartialMaturity = 0)        
                begin        
                    set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)        
                end    
                                     
                set @nExtStatus=2                
            end                
        end                 
        else if @pbByUnit=1 and @nManInvId = 1            
        begin      
            if ((@pmTranUnit*@mLastNAV)>5000000000) and @nManInvId = 1 and @pnProdId != @nProdIdException           
            begin                 
                if(@pbIsPartialMaturity = 0)        
                begin        
                    set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)        
                end    
                                           
                set @nExtStatus=2                
            end                
        end              
    End        
    else            
    Begin               
        if(@pbIsPartialMaturity = 0)        
        begin        
            set @pdNAVValueDate=dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,3)         
        end       
                        
        if @nNDayBefore != 0            
        Begin            
            set @pcWarnMsg = 'Valuedate dari transaksi ini : ' + convert (varchar, @pdNAVValueDate, 103)                
            set @nExtStatus=6            
        End            
    End            
    
    if((@nReksaTranType=1) or (@nReksaTranType=2))                   
    begin            
        set @dGoodFund = null            
    end            
    else            
    begin                   
        If @nExtStatus = 2    
        begin       
            set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId, convert(varchar,@pdNAVValueDate,112) ,4)    
        end         
        else    
        begin            
            set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId,convert(varchar,@pdNAVValueDate,112) ,2)    
        end         
    end            
    
    --cek good fund    
    if exists(select top 1 1 from ReksaHolidayTable_TM where ValueDate = @dGoodFund)    
        or DATEPART(dw, @dGoodFund) in (1,7)    
    begin    
        set @cErrMsg = 'Good Fund tidak dapat jatuh di hari libur!'            
        goto ERROR     
    end    
--20150911, liliana, LIBST13020, begin    
    
    if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientId)       
    begin      
        set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan switching all hari ini.'                         
        goto ERROR        
    end      
    else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)      
    begin      
        set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan redempt all hari ini.'                         
        goto ERROR        
    end      
    else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientId)      
    begin      
        set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah di switch out hari ini.'                         
        goto ERROR        
    end      
    else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)      
    begin      
        set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah redempt hari ini.'                         
        goto ERROR        
    end      
    else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcIn = @pnClientId)      
    begin      
        set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah di switch in hari ini.'                         
        goto ERROR        
    end      
    else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2,8) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)      
    begin      
        set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah subs new/add hari ini.'                         
        goto ERROR        
    end      
--20150911, liliana, LIBST13020, end           
    
    select @dCurrWorkingDate = current_working_date                
    from dbo.fnGetWorkingDate()                
                          
    set @pdTranDate  = getdate()     
--20150709, liliana, LIBST13020, begin       
    select right(CFCIF,13) as CFCIF19, *    
    into #Temp_CFMAST    
    from dbo.CFMAST_v    
    where CFCIF = @cCIFNo19     
        
    select *    
    into #Temp_ReksaCIFData_TM2    
    from dbo.ReksaCIFData_TM    
    where [CIFNo] = @pcCIFNo            
--20150709, liliana, LIBST13020, end             
    
    IF(@nReksaTranType IN(1,2,8))         
    begin    
        --cek umur nasabah    
         exec ReksaHitungUmur @pcCIFNo, @nUmur output      
    
         if(@nUmur >= 55)    
         begin    
            SET @pcWarnMsg3 = 'Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching'    
         end    
    end    
    
    IF(@nReksaTranType IN(1,2,8))        
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
--20171005, liliana, COPOD17271, begin  
            WHEN LOWER(cf.[CFUIC8]) = 'e' THEN 5      
--20171005, liliana, COPOD17271, end                   
            ELSE 0          
            END          
--20150709, liliana, LIBST13020, begin                  
        --FROM [dbo].[ReksaCIFData_TM] rc          
        --JOIN [dbo].[CFMAST_v] cf          
        --  ON CONVERT(bigint, rc.[CIFNo]) = CONVERT(bigint, cf.[CFCIF])          
        --WHERE rc.[ClientId] = @pnClientId    
        FROM [dbo].#Temp_ReksaCIFData_TM2 rc      
        JOIN [dbo].#Temp_CFMAST cf      
            on cf.CFCIF19 = rc.CIFNo    
--20150813, liliana, LIBST13020, begin              
        --WHERE rc.[ClientId] = @pnClientId    
--20150813, liliana, LIBST13020, end                    
--20150709, liliana, LIBST13020, end                  
                
        IF(@nCustomerRiskProfile < @nProductRiskProfile)          
        BEGIN           
            SET @pcWarnMsg2 = 'Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah. Apakah Nasabah sudah sudah menandatangi kolom Profil Risiko pada Subscription/Switching Form?'            
        END          
    end      
--20160830, liliana, LOGEN00196, begin  
      
    if @pbTrxTaxAmnesty = 1  
    begin  
        set @nExtStatus = 74  
    end  
--20160830, liliana, LOGEN00196, end        
    
    begin tran     
        
    if @nReksaTranType IN (1,8) and not exists(select top 1 1 from dbo.ReksaCIFData_TM where ClientCode = @pcClientCode)    
    begin    
         --insert client code switch in    
         set @cPFix = left(@pcClientCode,3)    
         set @nCounterClient = right(@pcClientCode,5)    
             
          Insert ReksaCIFData_TM (ProdId, ClientCode, ClientCodePfix, ClientCodeCount, CIFNo, CIFName, CIFAddress1        
              , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone        
              , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus, IsEmployee, CIFNIK          
              , JoinDate, AgentId, BankId, AccountType, NISPAccId, NISPAccName, NonNISPAccId, NonNISPAccName         
              , Referentor, BookingId, UnitBalance, LastUpdate, UserSuid, AuthType       
              , IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile, DocTermCondition, Inputter, Seller, Waperd      
              , ShareholderID, InputterNIK, CheckerSuid       
 )       
--20150608, liliana, LIBST13020, begin            
          --select top 1 @pnProdId, @pcClientCode, @cPFix, @nCounterClient, CIFNo, CIFName, CIFAddress1        
             -- , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone        
             -- , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, 'A', IsEmployee, CIFNIK        
             -- , getdate(), AgentId, BankId, 0, NISPAccId, NISPAccName, '', ''       
             -- , 0, null, 0, getdate(), 7, 1       
             -- , IDType, SEX, CTZSHIP, RELIGION, 1, 1, @cChannel, null, null      
             -- , ShareholderID, 7, 777      
          --from dbo.ReksaCIFData_TM      
          --where CIFNo = @pcCIFNo    
          --order by LastUpdate desc     
          select @pnProdId, @pcClientCode, @cPFix, @nCounterClient, CIFNo, CIFName, ''        
              , '', '', '', '', '', ''        
              , null, CIFBirthPlace, CIFBirthDay, '', '', '', 'A', IsEmployee, CIFNik        
              , getdate(), @nAgentId, @nBankId, 0, NISPAccountId, NISPAccountName, '', ''       
              , 0, null, 0, getdate(), 7, 1       
              , '', '', '', '', 1, 1, @cChannel, null, null      
              , ShareholderID, 7, 777      
          from dbo.ReksaMasterNasabah_TM      
          where CIFNo = @pcCIFNo          
--20150608, liliana, LIBST13020, end              
              
          set @pnClientId = @@identity    
--20150608, liliana, LIBST13020, begin   
--20160830, liliana, LOGEN00196, begin    
          if @pbTrxTaxAmnesty = 1  
          begin    
              insert dbo.ReksaClientCodeTAMapping_TM (ClientIdTax, IsTaxAmnesty, RegisterDate)  
              select @pnClientId, 1, getdate()   
          end   
--20160830, liliana, LOGEN00196, end  
  
--20150629, liliana, LIBST13020, begin    
        --update rc    
        --set SEX = cf.CFSEX,    
        --  IDType = cf.CFSSCD,    
        --  CTZSHIP = case when cf.CFCITZ = '000' then 'ID' else isnull(jh.JHCCOC,'') end,      
        --    RELIGION = case when cf.CFRACE = 'ISL' then '001'       
        --              when cf.CFRACE = 'KAT' then '002'       
        --              when cf.CFRACE = 'PRO' then '003'       
        --              when cf.CFRACE = 'BUD' then '004'       
        --              when cf.CFRACE = 'HIN' then '005'       
        --              else '' end,    
        --  CIFType = case when cf.CFCLAS = 'A' then 1     
        --            when cf.CFCLAS = '' then 0     
        --            else 4 end      
        --from dbo.ReksaCIFData_TM rc    
        --join dbo.CFMAST_v cf    
        --  on convert(bigint,cf.CFCIF) = convert(bigint,rc.CIFNo)    
        --left join JHCOUN_v jh      
        --  on cf.CFCITZ = jh.JHCSUB        
        --where rc.ClientId = @pnClientId    
            
        select *    
        into #Temp_ReksaCIFData_TM    
        from dbo.ReksaCIFData_TM    
        where ClientCode = @pcClientCode    
--20150709, liliana, LIBST13020, begin       
        --select right(CFCIF,19) as CFCIF19, *    
        --into #Temp_CFMAST    
        --from dbo.CFMAST_v    
        --where CFCIF = @cCIFNo19     
--20150709, liliana, LIBST13020, end            
    
    
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
--20150709, liliana, LIBST13020, begin               
        --drop table #Temp_CFMAST    
--20150709, liliana, LIBST13020, end            
--20150629, liliana, LIBST13020, end            
            
        if @nReksaTranType IN (8)    
        begin    
            if not exists (select top 1 1 from ReksaRegulerSubscriptionClient_TM where ClientId = @pnClientId and Status = 1)    
             begin    
                insert into ReksaRegulerSubscriptionClient_TM (ClientId, Status, LastUser, LastUpdate      
                )      
                select @pnClientId, 1, @pnSeller, getdate()      
                
                if @@error <> 0      
                begin      
                    set @cErrMsg = 'Gagal flag reguler subscription'      
                    goto ERROR      
                end      
                 
             end    
        end    
--20150608, liliana, LIBST13020, end              
    end     
--20150709, liliana, LIBST13020, begin               
    drop table #Temp_CFMAST    
    drop table #Temp_ReksaCIFData_TM2    
--20150709, liliana, LIBST13020, end                   
    
    insert dbo.ReksaTransaction_TT (TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId,                
        TranCCY, TranAmt, TranUnit, SubcFee, RedempFee, NAV, NAVValueDate, UnitBalance, UnitBalanceNom,                           
        UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,ExtStatus,GoodFund                            
        ,JangkaWaktu,JatuhTempo,AutoRedemption,GiftCode,BiayaHadiah            
        ,RegSubscriptionFlag,Asuransi,Inputter, Seller, Waperd               
        , FrekPendebetan, IsFeeEdit       
        , RedempFeeBased, TotalRedempFeeBased      
        , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased      
        , JenisPerhitunganFee, PercentageFee, Channel    
        , RefID, Referentor, OfficeId, AuthType     
--20150608, liliana, LIBST13020, begin    
        , DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter                
        , DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                       
        , DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers     
--20150608, liliana, LIBST13020, end          
    )                         
    select @pcTranCode, @nReksaTranType, @pdTranDate, @pnProdId, @pnClientId, @nFundId, @nAgentId, @pcTranCCY,                          
        @pmTranAmt, @pmTranUnit, @pmSubcFee, @pmRedempFee, @pmNAV, convert(char(8),@pdNAVValueDate,112), @pmUnitBalance,                          
        @pmUnitBalance * @pmNAV, @pnNIK, 0, 0, @pbByUnit                          
        , @pbFullAmount, 0, isnull(@mFeeBased, 0)                           
        , @nExtStatus, @dGoodFund               
        ,@pnJangkaWaktu,@pdJatuhTempo,@pnAutoRedemption,@pcGiftCode,@pnBiayaHadiah            
        ,@nRegSubscriptionFlag,@pnAsuransi,@pcInputter, @pnSeller, @pnWaperd                
        , @pnFrekuensiPendebetan, @pbIsFeeEdit      
        , isnull(@mRedempFeeBased, 0), isnull(@mTotalRedempFeeBased,0)     
        , isnull(@mTaxFeeBased,0) , isnull(@mFeeBased3,0), isnull(@mFeeBased4,0), isnull(@mFeeBased5,0)      
        , isnull(@mTotalFeeBased,0)      
        , @pbJenisPerhitunganFee, @pdPercentageFee, @cChannel      
        , @pcRefID, @pnReferentor, @pcOfficeId, 1    
--20150608, liliana, LIBST13020, begin    
        , @pbDocFCSubscriptionForm, @pbDocFCDevidentAuthLetter, @pbDocFCJoinAcctStatementLetter                
        , @pbDocFCIDCopy, @pbDocFCOthers, @pbDocTCSubscriptionForm                       
        , @pbDocTCTermCondition, @pbDocTCProspectus, @pbDocTCFundFactSheet, @pbDocTCOthers       
--20150608, liliana, LIBST13020, end                
                
    if @@error <> 0            
    begin            
        set @cErrMsg = 'Gagal insert data ReksaTransaction_TT'            
        rollback tran            
        goto ERROR            
    end            
                  
    select @pnTranId = scope_identity()        
                      
    if @nReksaTranType = 8 and @pnRegTransactionNextPayment = 0            
    begin            
        insert dbo.ReksaRegulerSubscriptionSchedule_TT(TranId, ScheduledDate, Type,             
        TranAmount, NAV, NAVValueDate, StatusId, LastAttemptDate)            
        select @pnTranId, ScheduledDate, Type,            
        @pmTranAmt, 0, null, 0, null              
        from dbo.fnGetReksaScheduledDate(@dJoinDate, @pnJangkaWaktu, @pnAutoRedemption, @pnFrekuensiPendebetan)      
                
        update dbo.ReksaRegulerSubscriptionSchedule_TT            
        set StatusId = 1            
            , LastAttemptDate = @pdTranDate            
            , NAVValueDate = convert(varchar(8), @pdNAVValueDate, 112)            
            , NAV = @pmNAV            
        where TranId = @pnTranId     
            and ScheduledDate = convert(varchar(8), @dJoinDate, 112)            
    end     
--20150608, liliana, LIBST13020, begin    
        
        -- DocFCOtherList         
        delete from ReksaOtherDocuments_TM          
        where TranId = @pnTranId     
            and isnull(IsBooking, 0) = 0      
            and isnull(IsSwitching, 0) = 0     
            and DocType = 'FC' -- from customer          
               
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'          
            rollback tran          
            goto ERROR          
        end          
               
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)          
        select @pnTranId, 'FC', left(result, 255), 0, 0    
        from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'          
            rollback tran          
            goto ERROR          
        end          
                
        delete from ReksaOtherDocuments_TM          
        where TranId = @pnTranId     
            and isnull(IsBooking, 0) = 0      
            and isnull(IsSwitching, 0) = 0         
        and DocType = 'TC' -- ke customer          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'          
            rollback tran          
            goto ERROR          
        end          
               
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)          
        select @pnTranId, 'TC', left(result, 255), 0, 0         
        from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'          
            rollback tran          
            goto ERROR          
        end                 
--20150608, liliana, LIBST13020, end                
                 
    commit tran            
         
end    
else if @pnType = 2                
begin    
--20150608, liliana, LIBST13020, begin    
    select @pnTranId = TranId    
    from dbo.ReksaTransaction_TH    
    where TranCode = @pcTranCode    
            
    select @pnTranId = TranId    
    from dbo.ReksaTransaction_TT    
    where TranCode = @pcTranCode    
        
    if(@pnTranId is null)    
    begin    
        set @cErrMsg = 'Tidak dapat melakukan Edit, Nomor Transaksi tidak ditemukan!'        
        goto ERROR                  
    end    
        
--20150608, liliana, LIBST13020, end    
--20150828, liliana, LIBST13020, begin    
    
    if exists(select top 1 1 from dbo.ReksaTransaction_TMP where TranId = @pnTranId and AuthType = 4)    
    begin    
        delete from dbo.ReksaTransaction_TMP     
        where TranId = @pnTranId and AuthType = 4    
    end    
        
--20150828, liliana, LIBST13020, end   
--20160830, liliana, LOGEN00196, begin  
      
    if @pbTrxTaxAmnesty = 1  
    begin  
        set @nExtStatus = 74  
    end  
--20160830, liliana, LOGEN00196, end     
    begin tran     
        
    insert dbo.ReksaTransaction_TMP (TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId,                
        TranCCY, TranAmt, TranUnit, SubcFee, RedempFee, NAV, NAVValueDate, UnitBalance, UnitBalanceNom,                           
        UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,ExtStatus,GoodFund                            
        ,JangkaWaktu,JatuhTempo,AutoRedemption,GiftCode,BiayaHadiah            
        ,RegSubscriptionFlag,Asuransi,Inputter, Seller, Waperd                   
        , FrekPendebetan, IsFeeEdit       
        , RedempFeeBased, TotalRedempFeeBased      
        , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased      
        , JenisPerhitunganFee, PercentageFee, Channel    
        , RefID, Referentor, OfficeId, AuthType       
        , NIKUpdate, DateUpdate, HistoryStatus    
--20150608, liliana, LIBST13020, begin    
        , TranId    
        , DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter                
        , DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                       
        , DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers          
--20150608, liliana, LIBST13020, end                 
    )                         
    select @pcTranCode, @nReksaTranType, @pdTranDate, @pnProdId, @pnClientId, @nFundId, @nAgentId, @pcTranCCY,                          
        @pmTranAmt, @pmTranUnit, @pmSubcFee, @pmRedempFee, @pmNAV, convert(char(8),@pdNAVValueDate,112), @pmUnitBalance,                          
        @pmUnitBalance * @pmNAV, @pnNIK, 0, 0, @pbByUnit                          
        , @pbFullAmount, 0, isnull(@mFeeBased, 0)                           
        , @nExtStatus, @dGoodFund               
        ,@pnJangkaWaktu,@pdJatuhTempo,@pnAutoRedemption,@pcGiftCode,@pnBiayaHadiah            
        ,@nRegSubscriptionFlag,@pnAsuransi,@pcInputter, @pnSeller, @pnWaperd                
        , @pnFrekuensiPendebetan, @pbIsFeeEdit      
        , isnull(@mRedempFeeBased, 0), isnull(@mTotalRedempFeeBased,0)     
        , isnull(@mTaxFeeBased,0) , isnull(@mFeeBased3,0), isnull(@mFeeBased4,0), isnull(@mFeeBased5,0)      
        , isnull(@mTotalFeeBased,0)      
        , @pbJenisPerhitunganFee, @pdPercentageFee, @cChannel      
        , @pcRefID, @pnReferentor, @pcOfficeId, 4          
        , @pnNIK, getdate(),' Updated'    
--20150608, liliana, LIBST13020, begin    
        , @pnTranId    
        , @pbDocFCSubscriptionForm, @pbDocFCDevidentAuthLetter, @pbDocFCJoinAcctStatementLetter                
        , @pbDocFCIDCopy, @pbDocFCOthers, @pbDocTCSubscriptionForm                       
        , @pbDocTCTermCondition, @pbDocTCProspectus, @pbDocTCFundFactSheet, @pbDocTCOthers                  
    
--20150618, liliana, LIBST13020, begin          
        if @@error != 0 or @@rowcount = 0        
        Begin        
            set @cErrMsg = 'Error Request Update Data!'        
            goto ERROR        
        End      
            
--20150618, liliana, LIBST13020, end        
        -- DocFCOtherList         
        delete from ReksaOtherDocuments_TM          
        where TranId = @pnTranId     
            and isnull(IsBooking, 0) = 0      
            and isnull(IsSwitching, 0) = 0     
            and DocType = 'FC' -- from customer          
               
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'          
            rollback tran          
            goto ERROR          
        end          
               
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)          
        select @pnTranId, 'FC', left(result, 255), 0, 0    
        from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'          
            rollback tran          
            goto ERROR          
        end          
                
        delete from ReksaOtherDocuments_TM          
        where TranId = @pnTranId     
            and isnull(IsBooking, 0) = 0      
            and isnull(IsSwitching, 0) = 0         
        and DocType = 'TC' -- ke customer          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'          
            rollback tran          
            goto ERROR          
        end          
               
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)          
        select @pnTranId, 'TC', left(result, 255), 0, 0         
        from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))          
              
        if @@error <> 0          
        begin          
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'          
            rollback tran          
            goto ERROR          
        end                         
--20150608, liliana, LIBST13020, end            
    
--20150618, liliana, LIBST13020, begin          
    --if @@error != 0 or @@rowcount = 0        
    --Begin        
    --  set @cErrMsg = 'Error Request Update Data!'        
    --  goto ERROR        
    --End      
--20150618, liliana, LIBST13020, end         
    
    Update ReksaTransaction_TT         
    set AuthType = 2     
--20150608, liliana, LIBST13020, begin    
--20150715, liliana, LIBST13020, begin    
        --, Status = 0    
--20150715, liliana, LIBST13020, end            
        , CheckerSuid = NULL    
--20150608, liliana, LIBST13020, end     
--20150813, liliana, LIBST13020, begin    
        , UserSuid = @pnNIK    
--20150813, liliana, LIBST13020, end          
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
Begin        
    Begin tran        
    
    Update ReksaTransaction_TT        
    set CheckerSuid  = NULL        
        , AuthType  = 3     
--20150608, liliana, LIBST13020, begin    
--20150715, liliana, LIBST13020, begin    
        --, Status = 0    
--20150715, liliana, LIBST13020, end            
--20150608, liliana, LIBST13020, end    
--20150813, liliana, LIBST13020, begin    
        , UserSuid = @pnNIK    
--20150813, liliana, LIBST13020, end               
    where TranCode = @pcTranCode     
        and RefID = @pcRefID       
        
    if @@error != 0 or @@rowcount = 0        
    Begin        
        set @cErrMsg = 'Gagal Update Status jadi Delete!'        
        goto ERROR        
    End    
           
    commit tran        
End                  
--20171018, Lita, LOGEN00466, begin  
drop table #tmpValidateOffice  
--20171018, Lita, LOGEN00466, end  
             
return 0            
          
ERROR:    
--20150608, liliana, LIBST13020, begin                
--if isnull(@cErrMsg, '') != ''                 
--begin     
--20150608, liliana, LIBST13020, end    
    if(@pbIsPartialMaturity = 1)      
    begin      
        update dbo.ReksaRedemptionSchedule_TT       
        set Status = 0,      
            AlasanGagal = @cErrMsg      
        where ClientId = @pnClientId      
            and ProdId = @pnProdId      
            and ValueDate = @pdTranDate      
    end      
--20150608, liliana, LIBST13020, begin    
--  set @nOK = 1                
--  raiserror 50000 @cErrMsg                    
--end        
    if(@pnRegTransactionNextPayment = 1)    
    begin    
         select top 1 @pnTranId = TranId    
          from dbo.ReksaTransaction_TH    
          where ClientId = @pnClientId    
            and TranType = 8    
            and Status = 1    
            and CheckerSuid != 777    
          order by TranDate desc        
            
        update ReksaRegulerSubscriptionSchedule_TT        
        set StatusId = 3,        
            LastAttemptDate = getdate() ,        
            ErrorDescription = error_message()         
        where RegulerSubscriptionTranId = @pnTranId          
    end     
     
    set @nOK = 1    
         
    if @@trancount >0      
        rollback tran      
            
    if isnull(@cErrMsg ,'') = ''      
        set @cErrMsg = error_message()          
            
    raiserror ( @cErrMsg ,16,1);
           
--20150608, liliana, LIBST13020, end    
            
return @nOK
GO