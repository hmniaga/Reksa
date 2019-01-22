alter proc [dbo].[ReksaMaintainNewBooking]    
/*    
 CREATED BY    : 
 CREATION DATE : 
 DESCRIPTION   : maintain Booking product close end by CIF   
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
 END REVISED    
*/    
  @pnType               int    
 ,@pnBookingId          int   = NULL     
 ,@pcRefID              varchar(20)  = NULL output    
 ,@pcCIF                varchar(13)  
 ,@pcCIFName            varchar(100)   
 ,@pnProdId             int       
 ,@pcOfficeId           varchar(5)       
 ,@pcCurrency           char(3)      
 ,@pmNominal            money      
 ,@pcRekening           varchar(50)   = null 
 ,@pcNamaRek            varchar(50)     
 ,@pnReferentor         int       
 ,@pnNIK                int       
 ,@pcGuid               varchar(50)     
 ,@pcInputter           varchar(40)    
 ,@pnSeller             int    
 ,@pnWaperd             int    
 ,@pbIsPhoneOrder       bit = 0
 ,@pbIsFeeEdit          bit = 0  
 ,@pbJenisPerhitunganFee int = 1 -- diisi dengan 1 = by nominal atau 2 = by percentage  
 ,@pdPercentageFee      decimal(25,13) = 0 -- kalau jenis perhitungan fee = 1, ini tidak mandatory  
 ,@pmSubcFee            decimal(25,13)
 ,@pcWarnMsg            varchar(100) = '' OUTPUT 
 ,@pcWarnMsg2           varchar(100) = '' OUTPUT 
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
,@pcDocFCOthersList         varchar(4000) = ''      
,@pcDocTCOthersList         varchar(4000) = ''  
,@pcWarnMsg3                varchar(500) = '' output
, @pbTrxTaxAmnesty                  bit = 0
as    
    
set nocount on    
    
declare @cErrMsg            varchar(100)    
  , @nOK                    int    
  , @nErrNo                 int    
  , @nProdId                int    
  , @cPFix                  char(3)    
  , @nCounter               int    
  , @nAuthType              char(1)    
  , @cProductCode           varchar(10)    
  , @cAccountType           varchar(3)    
  , @cCurrencyType          char(3) 
  , @dCurrWorkingDate       datetime      
  , @mMaxUnitAllowed        money    
  , @cProdCode              varchar(10)       
  , @mNAV                 decimal(20,10)       
  , @cAccountStatus         char(1)    
  , @cMCAllowed             char(1)      
  , @cCIFName               varchar(40)    
  , @dEndPeriod             datetime    
  , @mMinNom                decimal(25,13)      
  , @cTellerId              varchar(5)    
  , @cCIFNo                 varchar(19)    
  , @cChannel               varchar(20)
  , @nUmur                  int
  , @nProductRiskProfile    int
  , @nCustomerRiskProfile   int
  , @nEmployee              tinyint
  , @nCIFNIK                int
  , @cShareholderId         varchar(20)
  , @dMinPctFeeEmployee     decimal(25,13)
  , @dMaxPctFeeEmployee     decimal(25,13)
  , @dMinPctFeeNonEmployee  decimal(25,13)
  , @dMaxPctFeeNonEmployee  decimal(25,13)
  , @cTrxType               varchar(10)
  , @mTotalPctFeeBased      decimal(25,13)  
  , @mDefaultPctTaxFee      decimal(25,13)  
  , @mSubTotalPctFeeBased   decimal(25,13)   
  , @nSubFeeBased           decimal(25,13)  
  , @mFeeBased              decimal(25,13)  
  , @nPercentageTaxFee      decimal(25,13) 
  , @mTaxFeeBased           decimal(25,13)   
  , @nPercentageFee3        decimal(25,13)   
  , @mFeeBased3             decimal(25,13)   
  , @nPercentageFee4        decimal(25,13)   
  , @mFeeBased4             decimal(25,13)   
  , @nPercentageFee5        decimal(25,13)   
  , @mFeeBased5             decimal(25,13)   
  , @mTotalFeeBased         decimal(25,13)  
  , @mSelisihFee            decimal(25,13)
  , @pcBookingCode          varchar(20)
  , @cDocRiskProfile        bit
  , @cDocTermCondition      bit
  , @bIsMC              int
  , @cTempNoRekening    varchar(20)
  , @cNoRekeningUSD     varchar(20)
  , @cNoRekeningMC      varchar(20)
  , @cCIFNo19           varchar(20)
  , @cCFCITZ_SIBS       char(3)
  , @cNoIdentitasKTP_CIF varchar(20)  
  , @dIDExpireDateKTP_CIF datetime  
  , @cNoIdentitasPP_CIF  varchar(20)  
  , @dIDExpireDatePP_CIF datetime  
  , @cNoIdentitasKTP_SIBS varchar(20)  
  , @dIDExpireDateKTP_SIBS datetime  
  , @cNoIdentitasPP_SIBS  varchar(20)  
  , @dIDExpireDatePP_SIBS datetime     
  , @cCountryCode       varchar(50)
  , @cCountryName       varchar(200)  
  , @cNoRekeningTA       varchar(20)    
  , @cNoRekeningUSDTA    varchar(20)  
  , @cNoRekeningMCTA     varchar(20)
  , @nCIFNoBigInt        bigint  
  , @nExtStatus          int 
  , @nToday         int
  , @dToday         datetime
  , @cIFUATA            varchar(50)
  , @cSII               varchar(20)
  , @dcSII				varchar(20)
 
set @pcWarnMsg = ''
set @pcWarnMsg2 = ''
set @pcWarnMsg3 = ''
set @cCIFNo19 = right(('0000000000000000000'+@pcCIF),19)   
set @cTrxType = 'SUBS'
set @cCIFName = @pcCIFName
set @nCIFNoBigInt = convert(bigint,@pcCIF)
set @dToday = getdate()
set @nToday = dbo.fnDatetimeToJulian(@dToday)

set @mSubTotalPctFeeBased = 100
 
select @mDefaultPctTaxFee = PercentageTaxFeeDefault  
from dbo.control_table 
  
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee  
   
select @cTellerId = dbo.fnReksaGetParam('TELLERID')      
    
select @dCurrWorkingDate = current_working_date    
from fnGetWorkingDate()    

select @nEmployee = IsEmployee, 
       @nCIFNIK = CIFNik,
       @cShareholderId = ShareholderID
    , @cDocRiskProfile = DocRiskProfile
    , @cDocTermCondition = DocTermCondition
from dbo.ReksaMasterNasabah_TM
where CIFNo = @pcCIF

select @cProdCode = ProdCode  
   , @dEndPeriod = PeriodEnd    
   , @mMinNom = MinSubcNew 
from ReksaProduct_TM    
where ProdId = @pnProdId

select @cCountryCode = CFCITZ
from dbo.CFMAST_v
where CFCIF = @cCIFNo19  

select @cCountryName = CountryName
from dbo.ReksaCountryRestriction_TR
where CountryCode = @cCountryCode

select top 1 @mNAV = NAV  
from dbo.ReksaNAVParam_TH  
where ProdId = @pnProdId  
order by ValueDate desc

if @mNAV is null   
begin  
    select @mNAV = NAV   
    from dbo.ReksaProduct_TM  
    where ProdId = @pnProdId   
end   

if(@pbIsPhoneOrder = 1)
begin
   set @cChannel = 'TLP'
end
else
begin
    set @cChannel = 'CBG'
end
select @pcRekening = NISPAccountId,
    @cNoRekeningUSD = NISPAccountIdUSD,
    @cNoRekeningMC = NISPAccountIdMC
    , @cNoRekeningTA =  AccountIdTA
    , @cNoRekeningUSDTA = AccountIdUSDTA
    , @cNoRekeningMCTA = AccountIdMCTA
from dbo.ReksaMasterNasabah_TM
where CIFNo = @pcCIF

if @pbTrxTaxAmnesty = 1
begin
    if @pcCurrency = 'IDR' and isnull(@cNoRekeningTA,'') != ''   
    begin   
        set @pcRekening = @cNoRekeningTA  
    end  
    else if @pcCurrency = 'USD' and isnull(@cNoRekeningUSDTA,'') != ''  
    begin  
        set @pcRekening = @cNoRekeningUSDTA  
    end  
    else if isnull(@cNoRekeningMCTA,'') != ''  
    begin  
        set @pcRekening = @cNoRekeningMCTA  
    end 
end
else
begin
if @pcCurrency = 'IDR' and isnull(@pcRekening,'') != '' 
begin 
    set @pcRekening = @pcRekening
end
else if @pcCurrency = 'USD' and isnull(@cNoRekeningUSD,'') != ''
begin
    set @pcRekening = @cNoRekeningUSD
end
else if isnull(@cNoRekeningMC,'') != ''
begin
    set @pcRekening = @cNoRekeningMC
end
end

if isnull(@pcRekening,'') = ''
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
        and ta.CFACC# = @pcRekening
    )
begin                   
    set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'        
    goto ERROR      
end 

select @cIFUATA = IFUA
from dbo.ReksaIFUAMapping_TM
where CIFNo = @pcCIF
    and AccType = 'TA'
    
  
declare @nCIF     bigint    
set @nCIF = convert (bigint, @pcCIF)  
  
create table #TempErrorTable(    
 FieldName   varchar(50)    
 ,[Description]  varchar(500)    
)   
  
insert #TempErrorTable  
exec dbo.ReksaGetMandatoryFieldStatus @nCIF, @cErrMsg output    
  

if exists(select top 1 1 from #TempErrorTable) and (@pnType ! = 3)  
begin  
    select * from #TempErrorTable   
end  
else  
begin    
    if (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1    
    begin    
        set @cErrMsg = 'Tidak bisa melakukan booking/transaksi karena proses sinkronisasi sedang dijalankan. Harap tunggu'    
        goto ERROR 
    end  

    If @pnType not in (1,2,3)    
    begin
        set @cErrMsg = 'Tipe Operasi Tidak Dikenal!'   
         goto ERROR 
    end
    
    If @pnType in (2,3) and isnull(@pnBookingId,0) = 0    
    begin
        set @cErrMsg = 'Booking Id tidak dikenal!' 
        goto ERROR 
    end
         
    If @pnType in (1,2) and @pmNominal = 0  
    begin  
        set @cErrMsg = 'Nominal Booking Tidak Boleh Kosong!' 
        goto ERROR    
    end

    select @cSII = isnull(CFSSNO,'')
    from CFAIDN_v
    where CFCIF = @cCIFNo19 and CFSSCD = 'SII' 
	select @dcSII = isnull(SII,'')
	from ReksaIFUAMapping_TM 
	where CIFNo = @pcCIF
		and AccType = 'KYC'

	if isnull(@dcSII,'') = ''
	begin
		set @cErrMsg = 'Belum upload KYC di S-Invest. Mohon menghubungi Partnership Operation.'
		goto ERROR
	end

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
    
    if @pnType in (1,2) and exists(select top 1 1 from dbo.ReksaWaperd_TR where DateExpire < getdate() and NIK = @pnSeller)   
    begin  
        set @cErrMsg = 'WAPERD untuk NIK '+ convert(varchar,@pnSeller) +' sudah expired'  
        goto ERROR   
    end

    if exists(select top 1 1 from dbo.ReksaMasterNasabah_TM where CIFNo = @pcCIF and ApprovalStatus = 'T')
    begin
        set @cErrMsg = 'Shareholder ID / Nomor CIF tersebut sudah tidak aktif!'            
        goto ERROR  
    end 
    if exists(select top 1 1 from dbo.ReksaCountryRestriction_TR where CountryCode  = @cCountryCode)
    begin
        set @cErrMsg = 'Kewarganegaraan '+ isnull(@cCountryName,'') +' tidak diijinkan untuk melakukan transaksi reksadana!'
        goto ERROR
    end

if @pbTrxTaxAmnesty = 1 
    and exists(select top 1 1 from dbo.ReksaProductException_TR where [Type] = 'TA' and ProdCode = @cProdCode )
begin
    set @cErrMsg = 'Produk tersebut tidak dapat ditransaksikan sebagai transaksi Tax Amnesty'              
    goto ERROR 
end
    
    if @pbTrxTaxAmnesty = 1 and not exists(select top 1 1 from dbo.TCLOGT_v where TCLCIF = @nCIFNoBigInt and TCFLAG = 1 
    and TCEXP7 > @nToday
    )
    begin    
        set @cErrMsg = 'Jenis transaksi Tax Amnesty hanya bisa dilakukan oleh CIF dengan flag Tax Amnesty'              
        goto ERROR 
    end   

    if @pbTrxTaxAmnesty = 1 and isnull(@cIFUATA,'') = '' 
    begin 
        set @cErrMsg = 'Tidak dapat melakukan transaksi karena IFUA TA belum terdaftar'              
        goto ERROR 
    end 
    
    If @pnType in (2,3) and exists(select top 1 1 from ReksaBooking_TM where Status = 1 and BookingId = @pnBookingId)    
    begin
        set @cErrMsg = 'Booking Sudah Diproses!' 
        goto ERROR   
    end

    If @pnType in (1,2) and not exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1)  
    begin  
        set @cErrMsg = 'Harus Product Close End!'  
        goto ERROR   
    end

    If @pnType in (1,2) and not exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and Status = 0)  
    begin  
        set @cErrMsg = 'Produk sudah mature!'  
        goto ERROR   
    end 
    
    If @pnType in (1,2) and not exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1 and Status = 0    
          and @dCurrWorkingDate between PeriodStart and  PeriodEnd)   
    begin 
        set @cErrMsg = 'Harus dalam masa penawaran!'
        goto ERROR 
    end 

    if @pnType in (1) and exists(select top 1 1 from dbo.ReksaBooking_TM where Status = 1 and CIFNo = @pcCIF and ProdId = @pnProdId
    and NISPAccId != @pcRekening
    )
    begin
        set @cErrMsg = 'CIF tersebut sudah pernah booking sebelumnya dengan produk yang sama tetapi dengan rekening relasi yang berbeda!'
        goto ERROR 
    end

    if @pnType in (1) and exists(select top 1 1 from dbo.ReksaBooking_TH where Status = 1 and CIFNo = @pcCIF and ProdId = @pnProdId
        and NISPAccId != @pcRekening
    )   
    begin
        set @cErrMsg = 'CIF tersebut sudah pernah booking sebelumnya dengan produk yang sama tetapi dengan rekening relasi yang berbeda!'
        goto ERROR 
    end     

    if @pnType in (1) and @pbIsPhoneOrder = 1
    begin
     select ClientId 
     into #tempListClientCode
     from dbo.ReksaCIFData_TM
     where CIFNo = right('0000000000000' + @pcCIF,13)

    if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
        and not exists(select top 1 1 from dbo.ReksaTransaction_TH where TranType in (1,8) and Status = 1 and ClientId in (select ClientId from #tempListClientCode))
        and not exists(select top 1 1 from dbo.ReksaBooking_TM where CIFNo = right('0000000000000' + @pcCIF,13) and Status = 1)
        and not exists(select top 1 1 from dbo.ReksaBooking_TH where CIFNo = right('0000000000000' + @pcCIF,13) and Status = 1)
        begin
            select @cErrMsg = 'Nasabah yang baru pertama kali melakukan transaksi Reksa Dana tidak dapat melakukan transaksi via phone (1)!'     
            goto ERROR 
        end 
    end
     If @pnType in (1,2) and @pmNominal < @mMinNom 
     begin
        set @cErrMsg = 'Minimal Subscription Amount Adalah: ' + convert(varchar(30), cast(@mMinNom as money), 1)    
        goto ERROR   
     end
 
    if ((isnull(@nEmployee, 0) = 1) and (@nCIFNIK = @pnSeller))    
    begin   
        set @cErrMsg = 'Nasabah sama dengan Nama/NIK Seller'        
        goto ERROR   
    end        

    if (@nEmployee = 1) and not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId 
        and MinPctFeeEmployee <= @pdPercentageFee and MaxPctFeeEmployee >= @pdPercentageFee)   
    begin    
        select @dMinPctFeeEmployee = convert(float,MinPctFeeEmployee), @dMaxPctFeeEmployee = convert(float,MaxPctFeeEmployee)       
        from dbo.ReksaParamFee_TM   
        where TrxType = @cTrxType and ProdId = @pnProdId  
    
        set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeEmployee))+' %.'           
        goto ERROR     
    end  
 
    if (@nEmployee = 0) and not exists(select top 1 1 from dbo.ReksaParamFee_TM where TrxType = @cTrxType and ProdId = @pnProdId 
        and MinPctFeeNonEmployee <= @pdPercentageFee and MaxPctFeeNonEmployee >= @pdPercentageFee)   
    begin  
        select @dMinPctFeeNonEmployee = convert(float,MinPctFeeNonEmployee), @dMaxPctFeeNonEmployee = convert(float,MaxPctFeeNonEmployee)  
        from dbo.ReksaParamFee_TM   
        where TrxType = @cTrxType and ProdId = @pnProdId  
     
        set @cErrMsg = 'Nilai persentase fee harus diantara '+convert(varchar,convert(decimal(5,3),@dMinPctFeeNonEmployee))+' % dan '+ convert(varchar,convert(decimal(5,3),@dMaxPctFeeNonEmployee))+' %.'                           
        goto ERROR   
    end  

    exec @nOK = ReksaInqUnitNasDitwrkan     
         @pcCIFNo   = @pcCIF    
         ,@pcProdCode  = @cProdCode    
         ,@pnSisaUnit  = @mMaxUnitAllowed output    
         ,@pnNIK    = @pnNIK    
         ,@pcGuid   = @pcGuid    
         ,@pdCurrDate  = @dCurrWorkingDate    
        
    If @nOK != 0 or @@error != 0    
    Begin    
         set @cErrMsg = 'Error Cek Limit'    
         goto ERROR    
    End    
     
    if @pnType in (1,2) and (@pmNominal > (@mMaxUnitAllowed * @mNAV))   
    Begin       
        set @cErrMsg = 'Transaksi Besar Limit (' + convert(varchar(30), convert(money, @mMaxUnitAllowed * @mNAV)) + ')'      
        goto ERROR    
    End     
           
    if @dEndPeriod = @dCurrWorkingDate 
        and (select datediff(mi, '00:00:00', convert(varchar(8), getdate(), 108))) > (select CutOff from ReksaUserProcess_TR where ProcessId = 1)       
    Begin        
        set @cErrMsg = 'Sudah lewat masa penawaran, tidak bisa booking'    
        goto ERROR    
    End
 
    
     exec @nOK = dbo.ABCSAccountInquiry    
      @pcAccountID = @pcRekening    
      ,@pnSubSystemNId = 111501    
      ,@pcTransactionBranch = '99965'    
      ,@pcProductCode = @cProductCode output    
      ,@pcCurrencyType = @cCurrencyType output    
      ,@pcAccountType =@cAccountType output    
      , @pcMultiCurrencyAllowed = @cMCAllowed output    
      , @pcAccountStatus = @cAccountStatus output    
      , @pcTellerId = @cTellerId       
      ,@pcCIFName1 = @pcNamaRek output   
    
     If @cMCAllowed = 'Y'    
     Begin       
        set @cCurrencyType = @pcCurrency    
     End 
       
     if @cCurrencyType != @pcCurrency    
     Begin    
        set @cErrMsg = 'Mata Uang Relasi tidak sama dengan product!'    
        goto ERROR    
     End  
      
    if left(@cProductCode,3) = 'TKA'    
    Begin    
        set @cErrMsg = 'Tidak Boleh Rekening Taka!'    
        goto ERROR    
    End    
    
    If @cAccountStatus not in ('1' ,'4')  
    Begin    
        set @cErrMsg = 'Relasi Sudah Tidak Aktif, Mohon Ganti Relasi!'
        goto ERROR    
    End   
            

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

   
    if @pbTrxTaxAmnesty = 1
    begin
        set @nExtStatus = 74
    end
If @pnType = 1    
Begin  
     select @cPFix = Prefix   
     from dbo.ReksaClientCounter_TR          
     where ProdId = @pnProdId     
    
    if @@error != 0 or @@rowcount = 0    
    Begin    
        set @cErrMsg = 'Error Get Prefix!'    
        goto ERROR    
    End

    select @cCFCITZ_SIBS = CFCITZ
    from dbo.CFMAST_v
    where CFCIF = @cCIFNo19   

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
        set @pcWarnMsg3 = 'KTP sudah expired. Lakukan update tanggal expired KTP pada Pro CIF'      
    end
  
    if isnull(@cCFCITZ_SIBS, '000') != '000'    
    and @dIDExpireDateKTP_SIBS is not null   
    and @dIDExpireDateKTP_SIBS < getdate()      
    begin        
        set @pcWarnMsg3 = 'Pasport sudah expired. Lakukan update tanggal expired Pasport pada Pro CIF'      
    end 
    
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
		WHEN LOWER(cf.[CFUIC8]) = 'e' THEN 5    
        ELSE 0      
    END          
    FROM [dbo].[CFMAST_v] cf
    WHERE cf.[CFCIF] = @cCIFNo19    
        
    IF(@nCustomerRiskProfile < @nProductRiskProfile)      
    BEGIN      
    SET @pcWarnMsg = 'Profil Risiko produk lebih tinggi dari Profil Risiko Nasabah. Apakah Nasabah sudah sudah menandatangi kolom Profil Risiko pada Subscription/Switching Form?'         
    END      

    --cek umur nasabah
    exec ReksaHitungUmur @pcCIF, @nUmur output  

     if(@nUmur >= 55)
     begin
        SET @pcWarnMsg2 = 'Umur nasabah 55 tahun atau lebih, Mohon dipastikan nasabah menandatangani pernyataan pada kolom yang disediakan di Formulir Subscription/Switching'
     end
     
    exec ReksaGenerateRefID 'BOOK', @pcRefID output  
     
    if isnull(@pcRefID,'') = '' 
    begin
        set @cErrMsg = 'Gagal generate Ref ID'              
        goto ERROR 
    end  
   
    begin tran       
    
    update ReksaClientCounter_TR with(rowlock)    
    set Booking = @nCounter    
        , @nCounter = isnull(Booking, 0) + 1    
    where ProdId = @pnProdId     

    if @@error != 0 or @@rowcount = 0    
    Begin    
        set @cErrMsg = 'Error Update Counter!'    
        goto ERROR    
    End    
    
    set @pcBookingCode = @cPFix + right('00000'+convert(varchar(5),@nCounter),5)    

    Insert ReksaBooking_TM (BookingCode, BookingCounter, BookingCCY, BookingAmt    
        , ProdId, CIFNo, IsEmployee, CIFNIK, OfficeId, AccountType, NISPAccId, NISPAccName 
        , Referentor, AuthType, Status, LastUpdate, UserSuid, CheckerSuid     
        , CIFName, Inputter, Seller, Waperd, ShareholderID
        , Channel, SubcFee, SubcFeeBased, TaxFeeBased 
        , FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
        , JenisPerhitunganFee, PercentageFee, RefID 
        , BookingDate, IsFeeEdit
        , DocRiskProfile, DocTermCondition
        , DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter            
        , DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                   
        , DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers 
        , ExtStatus
    )    
    select @pcBookingCode, @nCounter, @pcCurrency, @pmNominal    
        , @pnProdId, @pcCIF, @nEmployee, @nCIFNIK, @pcOfficeId, 0, @pcRekening, @pcNamaRek    
        , @pnReferentor, 1, 0, getdate(), @pnNIK, null     
        , @pcCIFName, @pcInputter, @pnSeller, @pnWaperd, @cShareholderId  
        , @cChannel, isnull(@pmSubcFee,0), isnull(@mFeeBased, 0), isnull(@mTaxFeeBased,0) 
        , isnull(@mFeeBased3,0), isnull(@mFeeBased4,0), isnull(@mFeeBased5,0), isnull(@mTotalFeeBased,0)  
        , @pbJenisPerhitunganFee, @pdPercentageFee, @pcRefID
        , getdate(), @pbIsFeeEdit
        , @cDocRiskProfile, @cDocTermCondition
        , @pbDocFCSubscriptionForm, @pbDocFCDevidentAuthLetter, @pbDocFCJoinAcctStatementLetter            
        , @pbDocFCIDCopy, @pbDocFCOthers, @pbDocTCSubscriptionForm                   
        , @pbDocTCTermCondition, @pbDocTCProspectus, @pbDocTCFundFactSheet, @pbDocTCOthers          
        , @nExtStatus
        if @@error != 0 or @@rowcount = 0    
        Begin   
    set @cErrMsg = 'Error Insert Data!'    
            goto ERROR    
        End 
    
        set @pnBookingId = @@identity
        
        -- DocFCOtherList     
        delete from ReksaOtherDocuments_TM      
        where TranId = @pnBookingId 
            and isnull(IsBooking, 0) = 1     
            and DocType = 'FC' -- from customer      
           
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'      
            rollback tran      
            goto ERROR      
        end      
           
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)      
        select @pnBookingId, 'FC', left(result, 255), 0, 1
        from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'      
            rollback tran      
            goto ERROR      
        end      
            
        delete from ReksaOtherDocuments_TM      
        where TranId = @pnBookingId
        and isnull(IsBooking, 0) = 1       
        and DocType = 'TC' -- ke customer      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'      
            rollback tran      
            goto ERROR      
        end      
           
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)      
        select @pnBookingId, 'TC', left(result, 255), 0, 1     
        from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'      
            rollback tran      
            goto ERROR      
        end
    
    commit tran      
End

     
else if @pnType = 2    
Begin    
    select @pcBookingCode = BookingCode
    from dbo.ReksaBooking_TM
    where BookingId = @pnBookingId    

    if exists(select top 1 1 from dbo.ReksaBooking_TH where BookingId = @pnBookingId and AuthType = 4)
    begin
        delete from dbo.ReksaBooking_TH 
        where BookingId = @pnBookingId 
            and AuthType = 4
    end

    begin tran 
    
    insert ReksaBooking_TH(BookingId, BookingCode, BookingCounter, BookingCCY, BookingAmt, ProdId, CIFNo    
        , IsEmployee, CIFNIK, OfficeId, AccountType, NISPAccId, NISPAccName, Referentor      
        , AuthType, HistoryStatus, LastUpdate, UserSuid, CheckerSuid       
        , CIFName, Inputter, Seller, Waperd, ShareholderID, Channel  
        , SubcFee, SubcFeeBased, TaxFeeBased 
        , FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
        , JenisPerhitunganFee, PercentageFee, RefID
        , BookingDate, IsFeeEdit   
        , DocRiskProfile, DocTermCondition
        , DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter            
        , DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                   
        , DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers 
        , ExtStatus
     )   
    select @pnBookingId, @pcBookingCode, @nCounter, @pcCurrency, @pmNominal, @pnProdId, @pcCIF 
       , @nEmployee, @nCIFNIK, @pcOfficeId, 0, @pcRekening, @pcNamaRek, @pnReferentor 
        , 4, 'Update', getdate(), @pnNIK, null       
        , @cCIFName, @pcInputter, @pnSeller, @pnWaperd, @cShareholderId, @cChannel
        , isnull(@pmSubcFee,0), isnull(@mFeeBased, 0), isnull(@mTaxFeeBased,0) 
        , isnull(@mFeeBased3,0), isnull(@mFeeBased4,0), isnull(@mFeeBased5,0), isnull(@mTotalFeeBased,0)  
        , @pbJenisPerhitunganFee, @pdPercentageFee, @pcRefID 
        , null, @pbIsFeeEdit
        , @cDocRiskProfile, @cDocTermCondition
        , @pbDocFCSubscriptionForm, @pbDocFCDevidentAuthLetter, @pbDocFCJoinAcctStatementLetter            
        , @pbDocFCIDCopy, @pbDocFCOthers, @pbDocTCSubscriptionForm                   
        , @pbDocTCTermCondition, @pbDocTCProspectus, @pbDocTCFundFactSheet, @pbDocTCOthers   
        , @nExtStatus
       
      if @@error != 0 or @@rowcount = 0    
      Begin    
        set @cErrMsg = 'Error Request Update Data!'    
        goto ERROR    
      End    
        
        -- DocFCOtherList     
        delete from ReksaOtherDocuments_TM      
        where TranId = @pnBookingId 
            and isnull(IsBooking, 0) = 1     
            and DocType = 'FC' -- from customer      
           
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'      
            rollback tran      
            goto ERROR      
        end      
           
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)      
        select @pnBookingId, 'FC', left(result, 255), 0, 1
        from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'      
            rollback tran      
            goto ERROR      
        end      
            
        delete from ReksaOtherDocuments_TM      
        where TranId = @pnBookingId
        and isnull(IsBooking, 0) = 1       
        and DocType = 'TC' -- ke customer      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'      
            rollback tran      
            goto ERROR      
        end      
           
        insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching, IsBooking)      
        select @pnBookingId, 'TC', left(result, 255), 0, 1     
        from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))      
          
        if @@error <> 0      
        begin      
            set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'      
            rollback tran      
            goto ERROR      
        end             

    
  Update ReksaBooking_TM     
  set AuthType = 2
     , UserSuid = @pnNIK
  where BookingId = @pnBookingId    
    
  if @@error != 0 or @@rowcount = 0    
  Begin    
    set @cErrMsg = 'Error Update Flag Update!'    
    goto ERROR    
  End    
     
    commit tran    
End    
else if @pnType = 3    
Begin    
    Begin tran    
    
    delete ReksaBooking_TM    
    where BookingId = @pnBookingId    
        and AuthType = 4    
    
    if @@error != 0       
    Begin    
   set @cErrMsg = 'Gagal Delete Request Update!'    
        goto ERROR    
    End    
    
    Update ReksaBooking_TM    
    set CheckerSuid  = NULL    
        , AuthType  = 3    
        , UserSuid = @pnNIK
    where BookingId = @pnBookingId    
    
    if @@error != 0 or @@rowcount = 0    
    Begin    
        set @cErrMsg = 'Gagal Update Status jadi Delete!'    
        goto ERROR    
    End
       
    commit tran    
End    
end  
  
drop table #TempErrorTable      
    
return 0    
    
ERROR:    
if @@trancount > 0     
 rollback tran    
    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Error !'    
    
exec @nOK = set_raiserror @@procid, @nErrNo output      
if @nOK != 0 return 1      
      
raiserror (@cErrMsg ,16,1);
return 1
GO