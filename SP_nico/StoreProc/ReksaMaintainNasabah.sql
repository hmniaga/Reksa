alter proc [dbo].[ReksaMaintainNasabah]  
/*  
 CREATED BY    : 
 CREATION DATE : 
 DESCRIPTION   : Maintain data master nasabah
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
END REVISED  
  
*/  
    @pnType                         tinyint  -- 1: New, 2: Update, 3: Delete 
    , @pcGuid                       varchar(50)  
    , @pcCIF                        char(13)  
    , @pcCIFName                    varchar(100)  
    , @pcOfficeId                   varchar(5)
    , @pcCIFType                    tinyint-- 1: Individual, 4: Corporate  
    , @pcShareholderID              varchar(12)
    , @pcCIFBirthPlace              varchar(30)  
    , @pdCIFBirthDay                datetime 
    , @pdJoinDate                   datetime   
    , @pbIsEmployee                 tinyint -- 0: Bukan karyawan; 1: Karyawan 
    , @pnCIFNIK                     int  
    , @pcNISPAccId                  varchar(19)
    , @pcNISPAccName                varchar(100) 
    , @pnNIKInputter                int  
    , @pbRiskProfile                bit = 0
    , @pbTermCondition              bit = 0  
    , @pdRiskProfileLastUpdate      datetime = null
    , @pcAlamatConf                 varchar(max)
    , @pcNoNPWPKK                   varchar(40) = null
    , @pcNamaNPWPKK                 varchar(40) = null
    , @pcKepemilikanNPWPKK          varchar(50) = null
    , @pcKepemilikanNPWPKKLainnya   varchar(50) = null
    , @pdTglNPWPKK                  datetime = null
    , @pcAlasanTanpaNPWP            varchar(50) = null
    , @pcNoDokTanpaNPWP             varchar(40) = null
    , @pdTglDokTanpaNPWP            datetime = null
    , @pcNoNPWPProCIF               varchar(40) = null
    , @pcNamaNPWPProCIF             varchar(40) = null
    , @pnNasabahId                  int = null
    , @pcNISPAccIdUSD               varchar(19) = null
    , @pcNISPAccNameUSD             varchar(100) = null
    , @pcNISPAccIdMC                varchar(19) = null
    , @pcNISPAccNameMC              varchar(100) = null
    , @pcAccountIdTA            varchar(19) = null  
    , @pcAccountNameTA          varchar(100) = null
    , @pcAccountIdUSDTA         varchar(19) = null  
    , @pcAccountNameUSDTA           varchar(100) = null
    , @pcAccountIdMCTA          varchar(19) = null  
    , @pcAccountNameMCTA            varchar(100) = null

with encryption     
as    
    
set nocount on      
declare   
    @cErrMsg                    varchar(200)    
  , @nOK                        int    
  , @nErrNo                     int    
  , @cCurrWorkingDate           datetime    
  , @nCIF                       bigint  
  , @cErrMsgMandatoryField      varchar(100)    
  , @cSIBSCIFNo                 varchar(20)  
  , @pnKepemilikanNPWPKK        int  
  , @pnAlasanTanpaNPWP          int  
  , @cProductCode               varchar(10)    
  , @cAccountType               varchar(3)    
  , @cCurrencyType              char(3)   
  , @cMCAllowed                 char(1)    
  , @cAccountStatus             char(1)   
  , @nNasabahId                 int  
  , @cProductCodeUSD            varchar(10)   
  , @cCurrencyTypeUSD           varchar(3)    
  , @cAccountTypeUSD            char(1)    
  , @cMCAllowedUSD              char(1)    
  , @cAccountStatusUSD          int  
  , @cProductCodeMC             varchar(10)   
  , @cCurrencyTypeMC            varchar(3)    
  , @cAccountTypeMC             char(1)    
  , @cMCAllowedMC               char(1)    
  , @cAccountStatusMC           int  
  , @cProductCodeTA             varchar(10)   
  , @cCurrencyTypeTA            varchar(3)    
  , @cAccountTypeTA             char(1)    
  , @cMCAllowedTA               char(1)    
  , @cAccountStatusTA           int
  , @cProductCodeUSDTA          varchar(10)   
  , @cCurrencyTypeUSDTA         varchar(3)    
  , @cAccountTypeUSDTA          char(1)    
  , @cMCAllowedUSDTA            char(1)    
  , @cAccountStatusUSDTA        int
  , @cProductCodeMCTA           varchar(10)   
  , @cCurrencyTypeMCTA          varchar(3)    
  , @cAccountTypeMCTA           char(1)    
  , @cMCAllowedMCTA             char(1)    
  , @cAccountStatusMCTA         int
  , @cIsTA          char(1)
  , @cAccountNoValidate varchar(19)
  , @cOfficeIdValidate varchar(5)
  , @dcNISPAccId	    decimal(19,0)
  , @dcNISPAccIdUSD		decimal(19,0)
  , @dcNISPAccIdMC		decimal(19,0)
  , @dcAccountIdTA		decimal(19,0)
  , @dcAccountIdUSDTA	decimal(19,0)
  , @dcAccountIdMCTA	decimal(19,0)
       
select @cCurrWorkingDate = current_working_date    
from dbo.fnGetWorkingDate()    
  
create table #TempErrorTable(    
    FieldName       varchar(50),    
    [Description]   varchar(500)    
)  
  
set @nCIF = convert (bigint, @pcCIF)  
set @cSIBSCIFNo = '000000'+@pcCIF  
set @pcCIF = right('0000000000000' + @pcCIF,13)  
  
  
select   
    @pnKepemilikanNPWPKK = Id   
from ReksaGlobalParam_TR   
where Value = @pcKepemilikanNPWPKK   
    and GroupId = 'KNP'  
      
select   
    @pnAlasanTanpaNPWP = Id   
from ReksaGlobalParam_TR   
where Value = @pcAlasanTanpaNPWP   
    and GroupId = 'ANP'  
      
  
If @pnType not in (1,2,3)    
begin  
    set @cErrMsg = 'Tipe Operasi Tidak Dikenal!'    
    goto ERROR  
end  

if exists(select top 1 1 from office_information_sibs_v where convert(int, office_id_sibs) = convert(int, @pcOfficeId) and lower(office_name) like '%tutup%')
begin
    set @cErrMsg = 'Kantor cabang '+ isnull(@pcOfficeId, '') +' saat ini statusnya sudah tutup, silahkan ubah ke kantor cabang pengganti!'      
    goto ERROR  
end
  
create table #tmpValidateOffice (
    AccountNo decimal(19,0),
    OfficeId int,
    OfficeName varchar(40)
)
select @dcNISPAccId		= case when isnull(@pcNISPAccId, '') = '' then 0 else convert(decimal(19,0), @pcNISPAccId) end
select @dcNISPAccIdUSD	= case when isnull(@pcNISPAccIdUSD, '') = '' then 0 else convert(decimal(19,0), @pcNISPAccIdUSD) end	
select @dcNISPAccIdMC	= case when isnull(@pcNISPAccIdMC, '') = '' then 0 else convert(decimal(19,0), @pcNISPAccIdMC) end
select @dcAccountIdTA	= case when isnull(@pcAccountIdTA, '') = '' then 0 else convert(decimal(19,0), @pcAccountIdTA) end
select @dcAccountIdUSDTA = case when isnull(@pcAccountIdUSDTA, '') = '' then 0 else convert(decimal(19,0), @pcAccountIdUSDTA) end
select @dcAccountIdMCTA	 = case when isnull(@pcAccountIdMCTA, '') = '' then 0 else convert(decimal(19,0), @pcAccountIdMCTA) end

insert #tmpValidateOffice
select a.ACCTNO, a.BRANCH, b.office_name
from DDMAST_v a with(nolock)
join office_information_sibs_v b with(nolock)
    on a.BRANCH = convert(int, b.office_id_sibs)
where a.ACCTNO in ( 

	@dcNISPAccId
	, @dcNISPAccIdUSD
	, @dcNISPAccIdMC
	, @dcAccountIdTA
	, @dcAccountIdUSDTA
	, @dcAccountIdMCTA
)

insert #tmpValidateOffice
select a.ACCTNO, a.BRANCH, b.office_name
from DDTNEW_v a with(nolock)
join office_information_sibs_v b with(nolock)
    on a.BRANCH = convert(int, b.office_id_sibs)
where a.ACCTNO in ( 
	@dcNISPAccId
	, @dcNISPAccIdUSD
	, @dcNISPAccIdMC
	, @dcAccountIdTA
	, @dcAccountIdUSDTA
	, @dcAccountIdMCTA
)   

if exists (select top 1 1 from #tmpValidateOffice where lower(OfficeName) like '%tutup%')
begin
    select top 1 @cAccountNoValidate = convert(varchar(19), AccountNo), @cOfficeIdValidate = convert(varchar(5), OfficeId) from #tmpValidateOffice 
    where lower(OfficeName) like '%tutup%'
    drop table #tmpValidateOffice
    
    set @cErrMsg = 'Nomor rekening ' + isnull(@cAccountNoValidate, '') + ' masih terdaftar pada cabang yang sudah tutup, harap mengganti nomor rekening tersebut!'      
    goto ERROR
end
  
if @pnType in (1,2)  
begin
    --IDR Tax Amnesty 
    if isnull(@pcAccountIdTA,'') != ''  
    begin  
        if exists(
            select top 1 1 
            from dbo.TAMAST_v ta
            join dbo.TCLOGT_v tc
                on ta.CFCIF# = tc.TCLCIF
            where tc.TCFLAG = 7 and ta.TAFLAG = 7
                and ta.CFACC# = @pcAccountIdTA
            )
        begin    
            set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
            goto ERROR 
        end 

        exec @nOK = ABCSAccountInquiry    
                @pcAccountID = @pcAccountIdTA    
                ,@pnSubSystemNId = 111501    
                ,@pcTransactionBranch = '99965'    
                ,@pcProductCode = @cProductCodeTA output    
                ,@pcCurrencyType = @cCurrencyTypeTA output    
                ,@pcAccountType =@cAccountTypeTA output    
                ,@pcMultiCurrencyAllowed = @cMCAllowedTA output    
                , @pcAccountStatus = @cAccountStatusTA output    
                , @pcTellerId = '7'    
  
        If @cAccountStatusTA not in ('1','4','9')    
        Begin    
            set @cErrMsg = 'Relasi IDR Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
            goto ERROR    
        End  
          
        If @cMCAllowedTA = 'Y'    
        Begin    
            set @cErrMsg = 'Nomor rekening '+ @pcAccountIdTA +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
            goto ERROR  
        End        
        else  
        begin  
            if @cCurrencyTypeTA != 'IDR'  
            begin  
                set @cErrMsg = 'Rekening IDR harus diisi dengan mata uang IDR!'    
                goto ERROR        
            end           
        end  
  
        If left(@cProductCodeTA, 2) in ('TK')    
        Begin    
            set @cErrMsg = 'Rekening IDR Tidak boleh Rekening TAKA!'    
            goto ERROR    
        End     
        else If left(@cProductCodeTA, 2) in ('DP')    
        Begin    
            set @cErrMsg = 'Rekening IDR Tidak boleh Rekening Deposito!'    
            goto ERROR    
        End     
        else If @cAccountTypeTA = 'L'  
        Begin    
            set @cErrMsg = 'Rekening IDR Tidak boleh Rekening Loan!'    
            goto ERROR    
        End        
    end  

    --USD Tax Amnesty 
    if isnull(@pcAccountIdUSDTA,'') != ''  
    begin  
            if exists(
                select top 1 1 
                from dbo.TAMAST_v ta
                join dbo.TCLOGT_v tc
                    on ta.CFCIF# = tc.TCLCIF
                where tc.TCFLAG = 7 and ta.TAFLAG = 7
                    and ta.CFACC# = @pcAccountIdUSDTA
                )
            begin    
                set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
                goto ERROR 
            end 

            exec @nOK = dbo.ABCSAccountInquiry    
                    @pcAccountID = @pcAccountIdUSDTA   
                    ,@pnSubSystemNId = 111501    
                    ,@pcTransactionBranch = '99965'    
                    ,@pcProductCode = @cProductCodeUSDTA output    
                    ,@pcCurrencyType = @cCurrencyTypeUSDTA output    
                    ,@pcAccountType =@cAccountTypeUSDTA output    
                    ,@pcMultiCurrencyAllowed = @cMCAllowedUSDTA output    
                    , @pcAccountStatus = @cAccountStatusUSDTA output    
                    , @pcTellerId = '7'    
                  
            If @cAccountStatusUSDTA not in ('1','4','9')    
            Begin    
                set @cErrMsg = 'Relasi USD Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
                goto ERROR    
            End  
  
            If @cMCAllowedUSDTA = 'Y'    
            Begin    
                set @cErrMsg = 'Nomor rekening '+ @pcAccountIdUSDTA +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
                goto ERROR  
            End           
            else  
            begin  
                if @cCurrencyTypeUSDTA != 'USD'  
                begin  
                    set @cErrMsg = 'Rekening USD harus diisi dengan mata uang USD!'    
                    goto ERROR        
                end                   
            end  
  
            If left(@cProductCodeUSDTA, 2) in ('TK')    
            Begin    
                set @cErrMsg = 'Rekening USD Tidak boleh Rekening TAKA!'    
                goto ERROR    
            End     
            else If left(@cProductCodeUSDTA, 2) in ('DP')    
            Begin    
                set @cErrMsg = 'Rekening USD Tidak boleh Rekening Deposito!'    
                goto ERROR    
            End     
            else If @cAccountTypeUSDTA = 'L'  
            Begin    
                set @cErrMsg = 'Rekening USD Tidak boleh Rekening Loan!'    
                goto ERROR    
            End       
    end  

    --Multicurrency Tax Amnesty 
    if isnull(@pcAccountIdMCTA,'') != ''  
        begin  
            if exists(
                select top 1 1 
                from dbo.TAMAST_v ta
                join dbo.TCLOGT_v tc
                    on ta.CFCIF# = tc.TCLCIF
                where tc.TCFLAG = 7 and ta.TAFLAG = 7
                    and ta.CFACC# = @pcAccountIdMCTA
                )
            begin    
                set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
                goto ERROR 
            end 

            exec @nOK = dbo.ABCSAccountInquiry    
                    @pcAccountID = @pcAccountIdMCTA   
                    ,@pnSubSystemNId = 111501    
                    ,@pcTransactionBranch = '99965'    
                    ,@pcProductCode = @cProductCodeMCTA output    
                    ,@pcCurrencyType = @cCurrencyTypeMCTA output    
                    ,@pcAccountType =@cAccountTypeMCTA output    
                    ,@pcMultiCurrencyAllowed = @cMCAllowedMCTA output    
                    , @pcAccountStatus = @cAccountStatusMCTA output    
                    , @pcTellerId = '7'    
                  
            If @cAccountStatusMCTA not in ('1','4','9')    
            Begin         
                set @cErrMsg = 'Relasi Multicurrency Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
                goto ERROR    
            End  
  
            If @cMCAllowedMCTA = 'Y'    
            Begin         
                if @cCurrencyTypeMCTA not in ('AUD', 'EUR', 'IDR', 'JPY', 'SGD', 'USD')    
                Begin    
                    set @cErrMsg = 'Bukan mata uang Multicurrency!'    
                    goto ERROR    
                End     
            End  
            else  
            begin  
                set @cErrMsg = 'Rekening '+ @pcAccountIdMCTA +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
                goto ERROR                    
            end  
  
            If left(@cProductCodeMCTA, 2) in ('TK')    
            Begin    
                set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening TAKA!'    
                goto ERROR    
            End     
            else If left(@cProductCodeMCTA, 2) in ('DP')    
            Begin    
                set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening Deposito!'    
                goto ERROR    
            End     
            else If @cAccountTypeMCTA = 'L'  
            Begin    
                set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening Loan!'    
                goto ERROR    
            End           
        end     
    if isnull(@pcNISPAccId,'') != ''  
    begin  
        if exists(
            select top 1 1 
            from dbo.TAMAST_v ta
            join dbo.TCLOGT_v tc
                on ta.CFCIF# = tc.TCLCIF
            where tc.TCFLAG = 7 and ta.TAFLAG = 7
                and ta.CFACC# = @pcNISPAccId
            )
        begin    
            set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
            goto ERROR 
        end 

    exec @nOK = dbo.ABCSAccountInquiry    
            @pcAccountID = @pcNISPAccId    
            ,@pnSubSystemNId = 111501    
            ,@pcTransactionBranch = '99965'    
            ,@pcProductCode = @cProductCode output    
            ,@pcCurrencyType = @cCurrencyType output    
            ,@pcAccountType =@cAccountType output    
            ,@pcMultiCurrencyAllowed = @cMCAllowed output    
            , @pcAccountStatus = @cAccountStatus output    
            , @pcTellerId = '7'    
  
    If @cAccountStatus not in ('1','4','9')    
    Begin    
        set @cErrMsg = 'Relasi IDR Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
        goto ERROR    
    End  
          
    If @cMCAllowed = 'Y'    
    Begin    
        set @cErrMsg = 'Nomor rekening '+ @pcNISPAccId +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
        goto ERROR  
    End        
    else  
    begin  
        if @cCurrencyType != 'IDR'  
        begin  
            set @cErrMsg = 'Rekening IDR harus diisi dengan mata uang IDR!'    
            goto ERROR        
        end           
    end  
  
    If left(@cProductCode, 2) in ('TK')    
    Begin    
        set @cErrMsg = 'Rekening IDR Tidak boleh Rekening TAKA!'    
        goto ERROR    
    End     
    else If left(@cProductCode, 2) in ('DP')    
    Begin    
        set @cErrMsg = 'Rekening IDR Tidak boleh Rekening Deposito!'    
        goto ERROR    
    End     
    else If @cAccountType = 'L'  
    Begin    
        set @cErrMsg = 'Rekening IDR Tidak boleh Rekening Loan!'    
        goto ERROR    
    End        
    end  
  
    if isnull(@pcNISPAccIdUSD,'') != ''  
    begin  
        if exists(
            select top 1 1 
            from dbo.TAMAST_v ta
            join dbo.TCLOGT_v tc
                on ta.CFCIF# = tc.TCLCIF
            where tc.TCFLAG = 7 and ta.TAFLAG = 7
                and ta.CFACC# = @pcNISPAccIdUSD
            )
        begin    
            set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
            goto ERROR 
        end 

        exec @nOK = dbo.ABCSAccountInquiry    
                @pcAccountID = @pcNISPAccIdUSD   
                ,@pnSubSystemNId = 111501    
        ,@pcTransactionBranch = '99965'    
                ,@pcProductCode = @cProductCodeUSD output    
                ,@pcCurrencyType = @cCurrencyTypeUSD output    
                ,@pcAccountType =@cAccountTypeUSD output    
                ,@pcMultiCurrencyAllowed = @cMCAllowedUSD output    
                , @pcAccountStatus = @cAccountStatusUSD output    
                , @pcTellerId = '7'    
                  
        If @cAccountStatusUSD not in ('1','4','9')    
        Begin    
            set @cErrMsg = 'Relasi USD Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
            goto ERROR    
        End  
  
        If @cMCAllowedUSD = 'Y'    
        Begin    
            set @cErrMsg = 'Nomor rekening '+ @pcNISPAccIdUSD +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
            goto ERROR  
        End           
        else  
        begin  
            if @cCurrencyTypeUSD != 'USD'  
            begin  
                set @cErrMsg = 'Rekening USD harus diisi dengan mata uang USD!'    
                goto ERROR        
            end                   
        end  
  
        If left(@cProductCodeUSD, 2) in ('TK')    
        Begin    
            set @cErrMsg = 'Rekening USD Tidak boleh Rekening TAKA!'    
            goto ERROR    
        End     
        else If left(@cProductCodeUSD, 2) in ('DP')    
        Begin    
            set @cErrMsg = 'Rekening USD Tidak boleh Rekening Deposito!'    
            goto ERROR    
        End     
        else If @cAccountTypeUSD = 'L'  
        Begin    
            set @cErrMsg = 'Rekening USD Tidak boleh Rekening Loan!'    
            goto ERROR    
        End       
    end  
  
    if isnull(@pcNISPAccIdMC,'') != ''  
    begin  
        if exists(
            select top 1 1 
            from dbo.TAMAST_v ta
            join dbo.TCLOGT_v tc
                on ta.CFCIF# = tc.TCLCIF
            where tc.TCFLAG = 7 and ta.TAFLAG = 7
                and ta.CFACC# = @pcNISPAccIdMC
            )
        begin    
            set @cErrMsg = 'Nomor rekening RDN tidak bisa ditransaksikan'              
            goto ERROR 
        end 

        exec @nOK = dbo.ABCSAccountInquiry    
                @pcAccountID = @pcNISPAccIdMC   
                ,@pnSubSystemNId = 111501    
                ,@pcTransactionBranch = '99965'    
                ,@pcProductCode = @cProductCodeMC output    
                ,@pcCurrencyType = @cCurrencyTypeMC output    
                ,@pcAccountType =@cAccountTypeMC output    
                ,@pcMultiCurrencyAllowed = @cMCAllowedMC output    
                , @pcAccountStatus = @cAccountStatusMC output    
                , @pcTellerId = '7'    
                  
        If @cAccountStatusMC not in ('1','4','9')    
        Begin    
            set @cErrMsg = 'Relasi Multicurrency Sudah Tidak Aktif, Mohon Ganti Relasi!!'    
            goto ERROR    
        End  
  
        If @cMCAllowedMC = 'Y'    
        Begin         
            if @cCurrencyTypeMC not in ('AUD', 'EUR', 'IDR', 'JPY', 'SGD', 'USD')    
            Begin    
                set @cErrMsg = 'Bukan mata uang Multicurrency!'    
                goto ERROR    
            End     
        End  
        else  
        begin  
            set @cErrMsg = 'Rekening '+ @pcNISPAccIdMC +' adalah Rekening Multicurrency, harap mengisi di Rekening Multicurrency!'    
            goto ERROR                    
        end  
  
        If left(@cProductCodeMC, 2) in ('TK')    
        Begin    
            set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening TAKA!'    
            goto ERROR    
        End     
        else If left(@cProductCodeMC, 2) in ('DP')    
        Begin    
     set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening Deposito!'    
            goto ERROR    
        End     
        else If @cAccountTypeMC = 'L'  
        Begin    
            set @cErrMsg = 'Rekening Multicurrency Tidak boleh Rekening Loan!'    
            goto ERROR    
        End           
    end  
end  
  
if @pnType in (1) and exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and CheckerSuid is null)    
begin  
    set @cErrMsg = 'Nomor CIF tersebut sedang dalam proses otorisasi.'    
    goto ERROR   
end  
  
if @pnType in (1) and exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and ApprovalStatus != 'T')    
begin  
    set @cErrMsg = 'Nomor CIF tersebut sudah terdaftar'    
    goto ERROR   
end   
  
if @pnType in (1) and exists (select top 1 1 from ReksaCIFData_TM where CIFNo = @pcCIF)    
begin  
    set @cErrMsg = 'Nomor CIF tersebut sudah terdaftar'    
    goto ERROR   
end   

if @pnType in (2,3) and exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and ApprovalStatus = 'T')    
begin  
    set @cErrMsg = 'Nomor CIF tersebut sudah tutup, tidak dapat diubah!'    
    goto ERROR   
end  
  
if @pnType in (2,3) and    
     (exists(select top 1 1 from ReksaMasterNasabah_TH where CIFNo = @pcCIF and AuthType = 4)    
      or exists(select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and CheckerSuid is null)    
     )    
begin  
    set @cErrMsg = 'Perubahan Terakhir Belum di Otorisasi!'    
    goto ERROR   
end  
--Cek IDR Tax Amnesty 
if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and AccountIdTA = @pcAccountIdTA)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  
    set @cErrMsg = 'Belum Boleh Update Relasi IDR Tax Amnesty Karena Ada Transaksi, Tunggu  H+1!'    
    goto ERROR   
end   

--Cek USD Tax Amnesty 
if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and AccountIdUSDTA = @pcAccountIdUSDTA)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  
    set @cErrMsg = 'Belum Boleh Update Relasi USD Tax Amnesty Karena Ada Transaksi, Tunggu  H+1!'    
    goto ERROR   
end   

--Cek Multicurrency Tax Amnesty 
if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and AccountIdMCTA = @pcAccountIdMCTA)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  
    set @cErrMsg = 'Belum Boleh Update Relasi Multicurrency Tax Amnesty Karena Ada Transaksi, Tunggu  H+1!'    
    goto ERROR   
end   

if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and NISPAccountId = @pcNISPAccId)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  

    set @cErrMsg = 'Belum Boleh Update Relasi IDR Karena Ada Transaksi, Tunggu  H+1!'  
    goto ERROR   
end 

if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and NISPAccountIdUSD = @pcNISPAccIdUSD)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  
    set @cErrMsg = 'Belum Boleh Update Relasi USD Karena Ada Transaksi, Tunggu  H+1!'    
    goto ERROR   
end   
  
if @pnType in (2,3) and not exists (select top 1 1 from ReksaMasterNasabah_TM where CIFNo = @pcCIF and NISPAccountIdMC = @pcNISPAccIdMC)    
    and exists(  
        select top 1 1 from ReksaTransaction_TT tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientId  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            and tt.TranType in (1,2,8)  
            and ((tt.CheckerSuid is not null and tt.WMOtor = 0)     
            or (tt.WMCheckerSuid is not null and tt.WMOtor = 1)) )   
    and exists(  
        select top 1 1 from ReksaSwitchingTransaction_TM tt  
        join ReksaCIFData_TM rc  
            on rc.ClientId = tt.ClientIdSwcIn  
        where tt.Status = 1   
            and rc.CIFNo = @pcCIF  
            and isnull(tt.Settled,0) = 0    
            )             
begin  
    set @cErrMsg = 'Belum Boleh Update Relasi USD Karena Ada Transaksi, Tunggu  H+1!'    
    goto ERROR   
end       
  
if(isnull(@pcKepemilikanNPWPKK, '') <> '')  
begin  
    if not exists(select top 1 1  from ReksaGlobalParam_TR where Value = @pcKepemilikanNPWPKK and GroupId = 'KNP')  
    begin  
        select @cErrMsg = 'Parameter Kepemilikan NPWP sudah dihapus / diubah.'  
        goto ERROR   
    end  
      
    if exists(select top 1 1  from ReksaGlobalParam_TT where Value = @pcKepemilikanNPWPKK and GroupId = 'KNP' and StatusOtor = 0)  
    begin  
        select @cErrMsg = 'Parameter Kepemilikan NPWP sedang dalam proses hapus / update.'  
        goto ERROR   
    end  
end  
  
if(isnull(@pcAlasanTanpaNPWP, '') <> '')  
begin  
    if not exists(select top 1 1  from ReksaGlobalParam_TR where Value = @pcAlasanTanpaNPWP and GroupId = 'ANP')  
    begin  
        select @cErrMsg = 'Parameter Alasan Tanpa NPWP sudah dihapus / diubah.'  
        goto ERROR   
    end  
      
    if exists(select top 1 1  from ReksaGlobalParam_TT where Value = @pcAlasanTanpaNPWP and GroupId = 'ANP' and StatusOtor = 0)  
    begin  
        select @cErrMsg = 'Parameter Alasan Tanpa NPWP sedang dalam proses hapus / update.'  
        goto ERROR   
    end  
end  
  
if @pnType in (1) and exists(select top 1 1 from dbo.ReksaMasterNasabah_TM where ShareholderID = @pcShareholderID and CIFNo != @pcCIF)    
begin  
    set @cErrMsg = 'Shareholder ID tersebut sudah terdaftar! Lakukan generate ulang Shareholder ID tersebut.'  
    goto ERROR  
end   
  
if @pnType in (1) and exists(select top 1 1 from dbo.ReksaBooking_TM where ShareholderID = @pcShareholderID and CIFNo != @pcCIF)  
begin  
    set @cErrMsg = 'Shareholder ID tersebut sudah terdaftar! Lakukan generate ulang Shareholder ID tersebut.'  
    goto ERROR  
end   
  
  
insert #TempErrorTable  
exec dbo.ReksaGetMandatoryFieldStatus @nCIF, @cErrMsgMandatoryField output  
  
if @@error != 0  
Begin  
    set @cErrMsg = 'Error Mendapatkan Mandatory Status!'  
    goto ERROR  
End  
  
if exists(select top 1 1 from #TempErrorTable) and (@pnType = 1)  
begin  
    select * from #TempErrorTable     
end    
else   
begin  
  
    If @pnType = 1    
    Begin  
        if not exists(select top 1 1 from dbo.ReksaBooking_TM where CIFNo = @pcCIF and ShareholderID = @pcShareholderID)  
        and not exists(select top 1 1 from dbo.ReksaMasterNasabah_TM where CIFNo = @pcCIF and ShareholderID = @pcShareholderID)  
        begin  
            insert dbo.ReksaShareholderID_TM(ShareholderID)  
            select @pcShareholderID  
                  
            if @@error!= 0    
            Begin    
                set @cErrMsg = 'Shareholder ID tersebut sudah terpakai, harap generate ulang!'    
                goto ERROR    
            End    
        end  
          
        Begin Tran  
        if (isnull(@pcAccountIdTA,'') = '' and isnull(@pcAccountIdUSDTA,'') = '' and isnull(@pcAccountIdMCTA,'') = '') 
        begin
            set @cIsTA = 0
        end 
        else 
        begin
            set @cIsTA = 1
        end 

        --insert master nasabah  
        Insert ReksaMasterNasabah_TM(ShareholderID, CIFNo, CIFName, CIFBirthPlace, CIFBirthDay, OfficeId,  
            IsEmployee, CIFNik, NISPAccountId, NISPAccountName, CreateDate, UserSuid, AuthType,  
            DocRiskProfile, DocTermCondition, ApprovalStatus  
            , LastUpdate, NISPAccountIdUSD, NISPAccountNameUSD  
            , NISPAccountIdMC, NISPAccountNameMC  
            , AccountIdTA, AccountNameTA
            , AccountIdUSDTA, AccountNameUSDTA
            , AccountIdMCTA, AccountNameMCTA
            , isTA
        )  
        select @pcShareholderID, @pcCIF, @pcCIFName, @pcCIFBirthPlace, @pdCIFBirthDay, @pcOfficeId,  
            @pbIsEmployee, @pnCIFNIK, @pcNISPAccId, @pcNISPAccName, getdate(), @pnNIKInputter, 1,  
            @pbRiskProfile, @pbTermCondition, 'N'  
            , getdate(), @pcNISPAccIdUSD, @pcNISPAccNameUSD  
            , @pcNISPAccIdMC, @pcNISPAccNameMC  
            , @pcAccountIdTA, @pcAccountNameTA
            , @pcAccountIdUSDTA, @pcAccountNameUSDTA
            , @pcAccountIdMCTA, @pcAccountNameMCTA
            , @cIsTA
  
        set @nNasabahId = @@identity  
          
        If @@error != 0     
        Begin    
            set @cErrMsg = 'Error Input Data Nasabah!'    
            goto ERROR    
        End

        if @cIsTA = 1
        begin
            exec @nOK = ReksaNFSGenerateIFUA @pcCIF, @cErrMsg output, 1

            If @nOK != 0 or @@error != 0 or isnull(@cErrMsg,'') != ''
            Begin    
                set @cErrMsg = 'Gagal Generate IFUA!' + @cErrMsg   
                goto ERROR    
            End     
        end
          
         insert into ReksaCIFDataNPWP_TR(NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK  
          , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP  
          , CIFNo, EditDate  
          , NoNPWPProCIF, NamaNPWPProCIF  
          )  
         select @pcNoNPWPKK, @pcNamaNPWPKK, @pnKepemilikanNPWPKK, @pcKepemilikanNPWPKKLainnya, @pdTglNPWPKK  
          , @pnAlasanTanpaNPWP, @pcNoDokTanpaNPWP, @pdTglDokTanpaNPWP  
          , @pcCIF, getdate()  
          , @pcNoNPWPProCIF, @pcNamaNPWPProCIF  
  
         insert into ReksaCIFDataNPWP_TH( NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK  
          , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP  
          , CIFNo, EditDate  
          , NoNPWPProCIF, NamaNPWPProCIF, EditNIK  
          )  
         select @pcNoNPWPKK, @pcNamaNPWPKK, @pnKepemilikanNPWPKK, @pcKepemilikanNPWPKKLainnya, @pdTglNPWPKK  
          , @pnAlasanTanpaNPWP, @pcNoDokTanpaNPWP, @pdTglDokTanpaNPWP  
          , @pcCIF, getdate()  
          , @pcNoNPWPProCIF, @pcNamaNPWPProCIF, @pnNIKInputter  
  
        update ReksaBookingNPWP_TR  
        set NoNPWPKK = @pcNoNPWPKK, NamaNPWPKK = @pcNamaNPWPKK, KepemilikanNPWPKK = @pnKepemilikanNPWPKK, KepemilikanNPWPKKLainnya = @pcKepemilikanNPWPKKLainnya, TglNPWPKK = @pdTglNPWPKK  
        , AlasanTanpaNPWP = @pnAlasanTanpaNPWP, NoDokTanpaNPWP = @pcNoDokTanpaNPWP, TglDokTanpaNPWP = @pdTglDokTanpaNPWP  
        , EditDate = getdate(), NoNPWPProCIF = @pcNoNPWPProCIF, NamaNPWPProCIF = @pcNamaNPWPProCIF  
        where CIFNo = @pcCIF  
   
        --insert risk profile last update  
        if not exists (select top 1 1 from ReksaRiskProfileLastUpdate_TM where CIFNo = @pcCIF)  
        begin  
            insert dbo.ReksaRiskProfileLastUpdate_TM (CIFNo, RiskProfileLastUpdate)  
            select @pcCIF, isnull(@pdRiskProfileLastUpdate, @cCurrWorkingDate)  
                  
            if @@error <> 0  
            begin  
                set @cErrMsg = 'Gagal insert tabel RiskProfileLastUpdate'  
                goto ERROR  
            end   
        end  
        else  
        begin  
            update ReksaRiskProfileLastUpdate_TM  
            set RiskProfileLastUpdate = isnull(@pdRiskProfileLastUpdate, @cCurrWorkingDate)  
            where CIFNo = @pcCIF  
          
            if @@error <> 0  
            begin  
                set @cErrMsg = 'Gagal update tabel RiskProfileLastUpdate'  
                goto ERROR  
            end       
        end  
  
        exec @nOK = ReksaSaveConfAddress  
             @nTranType = @pnType  
             ,@pnId     = @nNasabahId  
             ,@pnType   = 2  
             ,@pcData   = @pcAlamatConf  
             ,@pnNIK    = @pnNIKInputter  
             ,@pcGuid   = @pcGuid  
  
        if @@error != 0 or @nOK != 0  
        begin  
            set @cErrMsg = 'Gagal Insert Alamat Konfirmasi'  
            goto ERROR  
        end  
  
        if(not exists(select top 1 1 from dbo.ReksaCIFEmail_TM where CIFNo = @pcCIF))  
        begin  
            insert dbo.ReksaCIFEmail_TM   
            select @pcCIF, 1   
        end   
          
        If @@error != 0       
        Begin      
            set @cErrMsg = 'Error Input Data ReksaCIFEmail_TM!'      
            goto ERROR      
        End  
        Commit Tran  
      
    End  
    Else if @pnType = 2    
    Begin    
        Begin Tran    
        if (isnull(@pcAccountIdTA,'') = '' and isnull(@pcAccountIdUSDTA,'') = '' and isnull(@pcAccountIdMCTA,'') = '') 
        begin
            set @cIsTA = 0
        end 
        else 
        begin
            set @cIsTA = 1
        end 

        Insert ReksaMasterNasabah_TH(NasabahId, ShareholderID, CIFNo, CIFName, CIFBirthPlace, CIFBirthDay, OfficeId,
            IsEmployee, CIFNik, NISPAccountId, NISPAccountName, CreateDate, UserSuid, AuthType,  
            DocRiskProfile, DocTermCondition, HistoryStatus, LastUpdate  
            , NISPAccountIdUSD, NISPAccountNameUSD  
            , NISPAccountIdMC, NISPAccountNameMC  
            , AccountIdTA, AccountNameTA
            , AccountIdUSDTA, AccountNameUSDTA
            , AccountIdMCTA, AccountNameMCTA
            , isTA
        )
        select @pnNasabahId, @pcShareholderID, @pcCIF, @pcCIFName, @pcCIFBirthPlace, @pdCIFBirthDay, @pcOfficeId,
            @pbIsEmployee, @pnCIFNIK, @pcNISPAccId, @pcNISPAccName, getdate(), @pnNIKInputter, 4,
            @pbRiskProfile, @pbTermCondition, 'Update', getdate()
            , @pcNISPAccIdUSD, @pcNISPAccNameUSD
            , @pcNISPAccIdMC, @pcNISPAccNameMC
            , @pcAccountIdTA, @pcAccountNameTA
            , @pcAccountIdUSDTA, @pcAccountNameUSDTA
            , @pcAccountIdMCTA, @pcAccountNameMCTA
            , @cIsTA
        
        If @@error != 0   
        Begin  
            set @cErrMsg = 'Error Reserve Update Data Nasabah!'  
            goto ERROR  
        End  

        if @cIsTA = 1
        begin
            exec @nOK = ReksaNFSGenerateIFUA @pcCIF, @cErrMsg output, 1

            If @nOK != 0 or @@error != 0 or isnull(@cErrMsg,'') != ''
            Begin    
                set @cErrMsg = 'Gagal Generate IFUA!' + @cErrMsg   
                goto ERROR    
            End     
        end
      
        Update ReksaMasterNasabah_TM  
        set AuthType = 2,
            CheckerSuid = null
            , LastUpdate = getdate()
            , UserSuid = @pnNIKInputter  
        where CIFNo = @pcCIF  
      
        If @@error != 0   
        Begin  
            set @cErrMsg = 'Error Update Flag!'  
            goto ERROR  
        End  
        
        if rtrim(replace(@pcNoNPWPKK, '.', '')) != '' or rtrim(replace(@pcNoDokTanpaNPWP, '.', '')) != '' or rtrim(replace(@pcNoNPWPProCIF, '.', '')) != ''
        begin
             if not exists(select top 1 1 from ReksaCIFDataNPWP_TR where CIFNo = @pcCIF)
             begin
                  insert into ReksaCIFDataNPWP_TR(NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK
                   , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP
                   , CIFNo, EditDate
                  , NoNPWPProCIF, NamaNPWPProCIF
                   )
                  select @pcNoNPWPKK, @pcNamaNPWPKK, @pnKepemilikanNPWPKK, @pcKepemilikanNPWPKKLainnya, @pdTglNPWPKK
                   , @pnAlasanTanpaNPWP, @pcNoDokTanpaNPWP, @pdTglDokTanpaNPWP
                   , @pcCIF, getdate()
                  , @pcNoNPWPProCIF, @pcNamaNPWPProCIF
            end
          
            insert into ReksaCIFDataNPWP_TH(NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK
            , AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP
            , CIFNo, EditDate
            , NoNPWPProCIF, NamaNPWPProCIF, EditNIK
            )
            select @pcNoNPWPKK, @pcNamaNPWPKK, @pnKepemilikanNPWPKK, @pcKepemilikanNPWPKKLainnya, @pdTglNPWPKK
            , @pnAlasanTanpaNPWP, @pcNoDokTanpaNPWP, @pdTglDokTanpaNPWP
            , @pcCIF, getdate()
            , @pcNoNPWPProCIF, @pcNamaNPWPProCIF, @pnNIKInputter
          
            update ReksaBookingNPWP_TR
            set NoNPWPKK = @pcNoNPWPKK, NamaNPWPKK = @pcNamaNPWPKK, KepemilikanNPWPKK = @pnKepemilikanNPWPKK, KepemilikanNPWPKKLainnya = @pcKepemilikanNPWPKKLainnya, TglNPWPKK = @pdTglNPWPKK
            , AlasanTanpaNPWP = @pnAlasanTanpaNPWP, NoDokTanpaNPWP = @pcNoDokTanpaNPWP, TglDokTanpaNPWP = @pdTglDokTanpaNPWP
            , EditDate = getdate(), NoNPWPProCIF = @pcNoNPWPProCIF, NamaNPWPProCIF = @pcNamaNPWPProCIF
            where CIFNo = @pcCIF
     
        end

        if exists (select top 1 1 from ReksaRiskProfileLastUpdate_TM where CIFNo = @pcCIF)
        begin
            update ReksaRiskProfileLastUpdate_TM
            set RiskProfileLastUpdate = isnull(@pdRiskProfileLastUpdate, @cCurrWorkingDate)
            where CIFNo = @pcCIF
        
            if @@error <> 0
            begin
                set @cErrMsg = 'Gagal update tabel RiskProfileLastUpdate'
                goto ERROR
            end 
        end
        else
        begin
            insert dbo.ReksaRiskProfileLastUpdate_TM (CIFNo, RiskProfileLastUpdate)
            select @pcCIF, isnull(@pdRiskProfileLastUpdate, @cCurrWorkingDate)
        
            if @@error <> 0
            begin
                set @cErrMsg = 'Gagal insert tabel RiskProfileLastUpdate'
                goto ERROR
            end 
        end
        
        exec @nOK = ReksaSaveConfAddress
             @nTranType = @pnType
             ,@pnId     = @pnNasabahId
             ,@pnType   = 2
             ,@pcData   = @pcAlamatConf
             ,@pnNIK    = @pnNIKInputter
             ,@pcGuid   = @pcGuid

        if @@error != 0 or @nOK != 0
        begin
            set @cErrMsg = 'Gagal Insert Alamat Konfirmasi'
            goto ERROR
        end
        
        commit tran  
    End  
    Else if @pnType = 3  
    Begin  
        Begin Tran 
         
        delete ReksaMasterNasabah_TH  
        where CIFNo = @pcCIF  
        and AuthType = 4  
      
        If @@error != 0   
        Begin  
            set @cErrMsg = 'Error Hapus Request Update!'  
            goto ERROR  
        End  
      
        Update ReksaMasterNasabah_TM  
        set UserSuid = @pnNIKInputter  
            , CheckerSuid = NULL  
            , AuthType = 3  
            , LastUpdate = getdate()
        where CIFNo = @pcCIF  
      
        If @@error != 0   
        Begin  
            set @cErrMsg = 'Error Update Request Delete!'  
            goto ERROR  
        End  
        
            
        commit tran  
    End  
end

drop table #TempErrorTable
drop table #tmpValidateOffice

return 0  
  
ERROR:  
if @@trancount >0  
    rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
    set @cErrMsg = 'Error !'  
  
exec @nOK = set_raiserror @@procid, @nErrNo output    
if @nOK != 0 return 1   
    
raiserror ( @cErrMsg,16,1 );

--raiserror @nErrNo @cErrMsg  
return 1
GO