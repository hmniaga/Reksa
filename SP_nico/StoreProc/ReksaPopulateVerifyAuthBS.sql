alter proc [dbo].[ReksaPopulateVerifyAuthBS]      
/*      
      
    CREATED BY    : liliana      
    CREATION DATE : 20141215      
    DESCRIPTION   :       
    REVISED BY    :      
        DATE,   USER,       PROJECT,    NOTE      
        -----------------------------------------------------------------------      
        20150413, liliana, LIBST13020, tambah filter authtype      
        20150421, liliana, LIBST13020, tambah data edit transaksi      
        20150608, liliana, LIBST13020, tampilkan mata uang utk switching      
        20150611, liliana, LIBST13020, tampilkan dalam bentuk yes no + rekening relasi USD      
        20150710, liliana, LIBST13020, master nasabah      
        20150715, liliana, LIBST13020, yg nunggu otor, cek berdasar checkersuid null      
        20150723, liliana, LIBST13020, Edit dan otor dicabang yang melakukan edit      
        20150730, liliana, LIBST13020, rekening mcy      
        20150827, liliana, LIBST13020, new req      
        20150828, liliana, LIBST13020, trandate & navdate disamain aja      
        20150907, liliana, LIBST13020, baca ke control table juga      
        20151130, liliana, LIBST13020, order by    
        20160829, Elva, LOGEN00196, penambahan rekening tax amnesty   
        20160830, liliana, LOGEN00196, trx tax amnesty
    END REVISED      
          
    exec dbo.ReksaPopulateVerifyAuthBS 10012,'ACC','REDEMP','EDIT',''      
          
    exec dbo.ReksaPopulateVerifyAuthBS 10012,'ACC','REDEMP','ADD',''      
      
*/      
@cNik               int,      
@cAuthorization     varchar(20), --ACC, TRX, BLK, REV      
@cTypeTrx           varchar(20) = '', -- ALL, SUBS, REDEMP, SUBSRDB, SWCNONRDB, SWCRDB, BOOK      
@cAction            varchar(10),  -- ADD/ EDIT /DELETE,      
@cNoReferensi       varchar(50) = ''      
as      
declare      
    @bBol               bit      
    ,@cOfficeId         varchar(5)      
    , @cAuthType        int      
    , @cTranType        int      
    , @dToday           datetime      
      
select @cOfficeId = office_id_sibs      
from dbo.user_nisp_v      
where nik = @cNik      
      
select @dToday = current_working_date      
from dbo.control_table      
      
select @bBol = 0      
      
create table #tempTampil (      
    CheckB              bit,      
    KodeKantor          varchar(5),      
    NoCIF               varchar(20),      
    NamaNasabah         varchar(100),      
    NoSID               varchar(50),      
    ShareholderID       varchar(20),      
    RiskProfile         varchar(50),      
    KaryawanOCBCNISP    varchar(10),      
--20150611, liliana, LIBST13020, begin      
    --NoRekRelasi           varchar(20),      
    NoRekRelasiIDR      varchar(20),      
    NoRekRelasiUSD      varchar(20),      
--20150611, liliana, LIBST13020, end          
--20150730, liliana, LIBST13020, begin      
    NoRekRelasiMulticurrency    varchar(20),      
--20150827, liliana, LIBST13020, begin        
    --NamaRekRelasiMulticurrency    varchar(20),      
    NamaRekRelasiMulticurrency  varchar(100),         
--20150827, liliana, LIBST13020, end          
--20150730, liliana, LIBST13020, end      
    AlamatKonfirmasi    varchar(200),      
    NPWP                varchar(50),      
    UserInput           int,      
    NasabahId           int,      
    TanggalInput        datetime      
--20150710, liliana, LIBST13020, begin      
    , NoReferensi       varchar(50)      
    , NamaRekRelasiIDR  varchar(100)      
    , NamaRekRelasiUSD  varchar(100)      
    , PhoneOrder        varchar(20)      
    , LastUpdateRiskProfile datetime      
    , NoCIFBigInt       bigint      
    , NoCIF19           varchar(20)      
--20150710, liliana, LIBST13020, end          
--20150827, liliana, LIBST13020, begin      
    , UserName          varchar(200)      
--20150827, liliana, LIBST13020, end    
--20160829, Elva, LOGEN00196, begin    
 , NoRekRelasiIDRTaxAmnesty varchar(20)  
 , NamaRekRelasiIDRTaxAmnesty varchar(100)  
 , NoRekRelasiUSDTaxAmnesty varchar(20)  
 , NamaRekRelasiUSDTaxAmnesty varchar(100)  
 , NoRekRelasiMCTaxAmnesty varchar(20)  
 , NamaRekRelasiMCTaxAmnesty varchar(100)  
--20160829, Elva, LOGEN00196, end  
)      
      
create table #tempTampilEdit (      
    CheckB              bit,      
    KodeKantor          varchar(5),      
    NoCIF               varchar(20),      
    NamaNasabah         varchar(100),      
    NoSID               varchar(50),      
    ShareholderID       varchar(20),      
    RiskProfile         varchar(50),      
    KaryawanOCBCNISP    varchar(10),      
--20150611, liliana, LIBST13020, begin      
    --NoRekRelasi           varchar(20),      
    NoRekRelasiIDR      varchar(20),      
    NoRekRelasiUSD      varchar(20),      
--20150611, liliana, LIBST13020, end      
--20150730, liliana, LIBST13020, begin      
    NoRekRelasiMulticurrency    varchar(20),      
--20150827, liliana, LIBST13020, begin        
    --NamaRekRelasiMulticurrency    varchar(20),      
    NamaRekRelasiMulticurrency  varchar(100),         
--20150827, liliana, LIBST13020, end          
--20150730, liliana, LIBST13020, end          
    AlamatKonfirmasi    varchar(200),      
    NPWP                varchar(50),      
    UserInput           int,      
    NasabahId           int,      
    TanggalInput        datetime      
--20150710, liliana, LIBST13020, begin      
    , NoReferensi   varchar(50)      
    , NamaRekRelasiIDR  varchar(100)      
    , NamaRekRelasiUSD  varchar(100)      
    , PhoneOrder        varchar(20)      
    , LastUpdateRiskProfile datetime          
    , NoCIFBigInt       bigint      
    , NoCIF19           varchar(20)       
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
    , UserName          varchar(200)      
--20150827, liliana, LIBST13020, end     
--20160829, Elva, LOGEN00196, begin    
 , NoRekRelasiIDRTaxAmnesty varchar(20)  
 , NamaRekRelasiIDRTaxAmnesty varchar(100)  
 , NoRekRelasiUSDTaxAmnesty varchar(20)  
 , NamaRekRelasiUSDTaxAmnesty varchar(100)  
 , NoRekRelasiMCTaxAmnesty varchar(20)  
 , NamaRekRelasiMCTaxAmnesty varchar(100)  
--20160829, Elva, LOGEN00196, end       
)      
      
create table #tempBlocking (      
    CheckB              bit,      
    KodeBlokir          int,      
    ClientCode          varchar(20),      
    NamaNasabah         varchar(100),      
    TglBlokir           datetime,      
    TglExpiryBlokir     datetime,      
    NominalBlokir       decimal(25,13),      
    Deskripsi           varchar(100),      
    UserInput           int      
--20150827, liliana, LIBST13020, begin      
    , UserName          varchar(200)      
--20150827, liliana, LIBST13020, end          
)      
      
create table #tempTransaksi (      
    CheckB              bit,      
    NoReferensi         varchar(50),      
    OfficeId            varchar(5),           
    NoSID               varchar(50),      
    ShareholderID       varchar(20),      
    NoCIF               varchar(20),      
    NamaNasabah         varchar(100),      
--20150827, liliana, LIBST13020, begin          
    --NoRekRelasi         varchar(20),      
    NoRekRelasiIDR         varchar(20),      
    NoRekRelasiUSD         varchar(20),      
    NoRekRelasiMulticurrency  varchar(20),      
--20150827, liliana, LIBST13020, end          
    NIKWAPERD           int,      
    NamaWAPERD          varchar(100),      
    NIKSeller           int,      
    NamaSeller          varchar(100),      
    NIKReferentor       int,      
    NamaReferentor      varchar(100),         
    UserInput           int,      
--20150827, liliana, LIBST13020, begin      
    UserName            varchar(200),      
--20150827, liliana, LIBST13020, end         
    TranType            int      
--20150710, liliana, LIBST13020, begin      
    , NoCIFBigInt       bigint      
    , NoCIF19           varchar(20)       
--20150710, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
    , NoRekRelasiIDRTAX         varchar(20)      
    , NoRekRelasiUSDTAX         varchar(20)    
    , NoRekRelasiMulticurrencyTAX  varchar(20)
--20160830, liliana, LOGEN00196, end          
)      
      
create table #tempTransaksiDetail (      
    CheckB              bit,      
    NoReferensi         varchar(50),      
    JenisTransaksi      varchar(50),      
    KodeTransaksi       varchar(50),      
 TglTransaksi        datetime,      
    TglValuta           datetime,      
    KodeProduk          varchar(20),      
    KodeProdukSwcOut    varchar(20),      
    KodeProdukSwcIn     varchar(20),      
    ClientCode          varchar(20),      
    ClientCodeSwcOut    varchar(20),      
    ClientCodeSwcIn     varchar(20),      
    MataUang            varchar(3),      
    NominalTransaksi    decimal(25,13),      
    UnitTransaksi       decimal(25,13),      
    FullAmount          bit,      
    JangkaWaktu         int,      
    JatuhTempo          datetime,      
--20150710, liliana, LIBST13020, begin        
    --FrekPendebetan        bit,      
    FrekPendebetan      int,      
--20150710, liliana, LIBST13020, end          
    Asuransi            bit,      
    AutoRedemption      bit,      
    FeeEdit             bit,      
    FeeNominal          decimal(25,13),      
    PctFee              decimal(25,13),      
    Channel             varchar(50),      
    TranType            int,      
    TranId              int      
--20160830, liliana, LOGEN00196, begin
	, TrxTaxAmnesty		bit
--20160830, liliana, LOGEN00196, end     
)      
--20150421, liliana, LIBST13020, begin      
create table #tempTransaksiDetailNew (      
    CheckB         bit,      
    NoReferensi         varchar(50),      
    JenisTransaksi      varchar(50),      
    KodeTransaksi       varchar(50),      
    TglTransaksi        datetime,      
    TglValuta           datetime,      
    KodeProduk          varchar(20),      
    KodeProdukSwcOut    varchar(20),      
    KodeProdukSwcIn     varchar(20),      
    ClientCode          varchar(20),      
    ClientCodeSwcOut    varchar(20),      
    ClientCodeSwcIn     varchar(20),      
    MataUang            varchar(3),      
NominalTransaksi    decimal(25,13),      
    UnitTransaksi       decimal(25,13),      
    FullAmount          bit,      
    JangkaWaktu         int,      
    JatuhTempo          datetime,      
--20150710, liliana, LIBST13020, begin        
    --FrekPendebetan        bit,      
    FrekPendebetan      int,      
--20150710, liliana, LIBST13020, end      
    Asuransi            bit,      
    AutoRedemption      bit,      
    FeeEdit             bit,      
    FeeNominal          decimal(25,13),      
    PctFee              decimal(25,13),      
    Channel             varchar(50),      
    TranType            int,      
    TranId              int  
--20160830, liliana, LOGEN00196, begin
	, TrxTaxAmnesty		bit
--20160830, liliana, LOGEN00196, end           
)      
      
--20150421, liliana, LIBST13020, end      
if(@cAuthorization = 'ACC')      
begin      
    if(@cAction = 'ADD')      
    begin      
        set @cAuthType = 1      
    end       
    else if(@cAction = 'DELETE')      
    begin      
        set @cAuthType = 3      
    end      
    else if (@cAction = 'EDIT')      
    begin      
        set @cAuthType = 2      
      
        --data baru      
        insert #tempTampilEdit (CheckB, KodeKantor, NoCIF, NamaNasabah, ShareholderID,      
--20150611, liliana, LIBST13020, begin                    
            --KaryawanOCBCNISP, NoRekRelasi, NasabahId, UserInput, TanggalInput       
     KaryawanOCBCNISP, NoRekRelasiIDR, NasabahId, UserInput, TanggalInput,      
            NoRekRelasiUSD                
--20150611, liliana, LIBST13020, end      
--20150730, liliana, LIBST13020, begin      
            , NoRekRelasiMulticurrency, NamaRekRelasiMulticurrency      
--20150730, liliana, LIBST13020, end      
--20150710, liliana, LIBST13020, begin      
            , NoReferensi, NamaRekRelasiIDR, NamaRekRelasiUSD, LastUpdateRiskProfile, PhoneOrder      
            , NoCIFBigInt, NoCIF19        
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
            , UserName      
--20150827, liliana, LIBST13020, end         
--20160829, Elva, LOGEN00196, begin    
   , NoRekRelasiIDRTaxAmnesty  
   , NamaRekRelasiIDRTaxAmnesty  
   , NoRekRelasiUSDTaxAmnesty  
   , NamaRekRelasiUSDTaxAmnesty  
   , NoRekRelasiMCTaxAmnesty  
   , NamaRekRelasiMCTaxAmnesty  
--20160829, Elva, LOGEN00196, end                       
        )      
        select @bBol, rm.OfficeId, rm.CIFNo, rm.CIFName, rm.ShareholderID,   
--20150611, liliana, LIBST13020, begin            
            --rm.IsEmployee, rm.NISPAccountId, rm.NasabahId, rm.UserSuid, rm.LastUpdate      
            case when rm.IsEmployee = 1 then 'Yes' else 'No' end, rm.NISPAccountId, rm.NasabahId, rm.UserSuid, rm.LastUpdate,      
            rm.NISPAccountIdUSD      
--20150611, liliana, LIBST13020, end      
--20150710, liliana, LIBST13020, begin      
--20150730, liliana, LIBST13020, begin      
            , rm.NISPAccountIdMC, rm.NISPAccountNameMC      
--20150730, liliana, LIBST13020, end      
            , rm.CIFNo, rm.NISPAccountName, rm.NISPAccountNameUSD, @dToday, 'No'      
            , convert(bigint, rm.CIFNo), right(('0000000000000000000'+ rm.CIFNo),19)       
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
            , un.fullname      
--20150827, liliana, LIBST13020, end     
--20160829, Elva, LOGEN00196, begin    
   , AccountIdTA  
   , AccountNameTA  
   , AccountIdUSDTA  
   , AccountNameUSDTA  
   , AccountIdMCTA  
   , AccountNameMCTA  
--20160829, Elva, LOGEN00196, end               
        from dbo.ReksaMasterNasabah_TH rm     with(nolock) 
--20150723, liliana, LIBST13020, begin      
        join dbo.user_nisp_v un      
            on rm.UserSuid = un.nik      
--20150723, liliana, LIBST13020, end              
        where rm.CheckerSuid is null      
            and rm.AuthType in (4)      
--20150723, liliana, LIBST13020, begin                
            --and rm.OfficeId = @cOfficeId        
            and un.office_id_sibs = @cOfficeId      
--20150723, liliana, LIBST13020, end                      
      
        update te      
        set NoSID = cf.CFSSNO      
        from #tempTampilEdit  te      
--20150710, liliana, LIBST13020, begin            
        --join SQL_SIBS.dbo.CFAIDN cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
        join dbo.CFAIDN_v cf      
            on te.NoCIF19 = cf.CFCIF              
--20150710, liliana, LIBST13020, end                  
        where cf.CFSSCD = 'SII '       
      
        update te      
        set NoSID = cf.CFSSNO      
        from #tempTampilEdit  te      
--20150710, liliana, LIBST13020, begin                
        --join SQL_CIF.dbo.CFAIDN cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
        join dbo.CFAIDN_CIF_v cf      
            on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end                  
        where cf.CFSSCD = 'SII'      
      
        update te      
        set RiskProfile = dr.RiskProfileDesc              
        from #tempTampilEdit  te      
--20150710, liliana, LIBST13020, begin                
        --join SQL_SIBS.dbo.CFMAST cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)            
        join dbo.CFMAST_v cf      
            on te.NoCIF19 = cf.CFCIF                  
--20150710, liliana, LIBST13020, end                      
        join dbo.ReksaDescRiskProfile_TR dr      
            on dr.RiskProfileCFMAST = cf.CFUIC8      
      
        update te      
        set RiskProfile = dr.RiskProfileDesc      
        from #tempTampilEdit  te      
--20150710, liliana, LIBST13020, begin            
        --join SQL_CIF.dbo.CFMAST cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
        join dbo.CFMAST_CIF_v cf      
            on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end                  
        join dbo.ReksaDescRiskProfile_TR dr      
            on dr.RiskProfileCFMAST = cf.CFUIC8      
--20150710, liliana, LIBST13020, begin      
              
        update te      
        set LastUpdateRiskProfile = rcif.RiskProfileLastUpdate      
        from #tempTampilEdit  te      
        join ReksaRiskProfileLastUpdate_TM rcif      
            on te.NoCIF = rcif.CIFNo       
              
        update te       
        set PhoneOrder = 'Yes'      
        from #tempTampilEdit  te      
        join dbo.ProCIFCustTagging_TM_v ct      
            on ct.CustomerId = te.NoCIF      
        where ct.PBFaciltyType = 'FTR'      
--20150710, liliana, LIBST13020, end                  
      
        Update te        
        set NPWP = cf.CFSSNO        
        from  #tempTampilEdit te       
--20150710, liliana, LIBST13020, begin            
        --join SQL_SIBS.dbo.CFAIDN cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
        join dbo.CFAIDN_v cf      
            on te.NoCIF19 = cf.CFCIF              
--20150710, liliana, LIBST13020, end                  
        where cf.CFSSCD = 'NPWP'          
      
        Update te        
        set NPWP = cf.CFSSNO        
        from  #tempTampilEdit te       
--20150710, liliana, LIBST13020, begin                
        --join SQL_CIF.dbo.CFAIDN cf      
        --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
        join dbo.CFAIDN_CIF_v cf      
            on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end                  
        where cf.CFSSCD = 'NPWP'          
                  
        update te       
        set AlamatKonfirmasi = rtrim(ca.AddressLine1) + ' '+ rtrim(ca.AddressLine2)  + ' '+  rtrim(ca.AddressLine3) + ' ' + rtrim(ca.AddressLine4)      
        from #tempTampilEdit te      
        join dbo.ReksaCIFConfirmAddr_TH ca      
        on te.NasabahId = ca.Id      
            and ca.DataType = 2      
            and (AlamatKonfirmasi = '' or ca.Status = 4)      
                          
    end      
      
    --data lama      
    insert #tempTampil (CheckB, KodeKantor, NoCIF, NamaNasabah, ShareholderID,      
--20150611, liliana, LIBST13020, begin                    
        --KaryawanOCBCNISP, NoRekRelasi, NasabahId, UserInput, TanggalInput       
        KaryawanOCBCNISP, NoRekRelasiIDR, NasabahId, UserInput, TanggalInput,      
        NoRekRelasiUSD                
--20150611, liliana, LIBST13020, end      
--20150710, liliana, LIBST13020, begin      
--20150730, liliana, LIBST13020, begin      
        , NoRekRelasiMulticurrency, NamaRekRelasiMulticurrency      
--20150730, liliana, LIBST13020, end      
        , NoReferensi, NamaRekRelasiIDR, NamaRekRelasiUSD, LastUpdateRiskProfile, PhoneOrder      
        , NoCIFBigInt, NoCIF19      
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
            , UserName      
--20150827, liliana, LIBST13020, end       
--20160829, Elva, LOGEN00196, begin    
   , NoRekRelasiIDRTaxAmnesty  
   , NamaRekRelasiIDRTaxAmnesty  
   , NoRekRelasiUSDTaxAmnesty  
   , NamaRekRelasiUSDTaxAmnesty  
   , NoRekRelasiMCTaxAmnesty  
   , NamaRekRelasiMCTaxAmnesty  
--20160829, Elva, LOGEN00196, end                                       
    )      
    select @bBol, rm.OfficeId, rm.CIFNo, rm.CIFName, rm.ShareholderID,      
--20150611, liliana, LIBST13020, begin        
        --rm.IsEmployee, rm.NISPAccountId, rm.NasabahId, rm.UserSuid, rm.CreateDate      
        case when rm.IsEmployee = 1 then 'Yes' else 'No' end, rm.NISPAccountId, rm.NasabahId, rm.UserSuid, rm.CreateDate,      
        rm.NISPAccountIdUSD      
--20150611, liliana, LIBST13020, end      
--20150710, liliana, LIBST13020, begin      
--20150730, liliana, LIBST13020, begin      
        , rm.NISPAccountIdMC, rm.NISPAccountNameMC      
--20150730, liliana, LIBST13020, end      
        , rm.CIFNo, rm.NISPAccountName, rm.NISPAccountNameUSD, @dToday, 'No'      
        , convert(bigint, rm.CIFNo), right(('0000000000000000000'+ rm.CIFNo),19)       
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
        , un.fullname      
--20150827, liliana, LIBST13020, end     
--20160829, Elva, LOGEN00196, begin    
  , rm.AccountIdTA  
  , rm.AccountNameTA  
  , rm.AccountIdUSDTA  
  , rm.AccountNameUSDTA  
  , rm.AccountIdMCTA  
  , rm.AccountNameMCTA  
--20160829, Elva, LOGEN00196, end                      
    from dbo.ReksaMasterNasabah_TM rm      
--20150723, liliana, LIBST13020, begin      
        join dbo.user_nisp_v un      
            on rm.UserSuid = un.nik      
--20150723, liliana, LIBST13020, end          
    where rm.CheckerSuid is null      
        and rm.AuthType = @cAuthType      
--20150723, liliana, LIBST13020, begin                
        --and rm.OfficeId = @cOfficeId        
        and un.office_id_sibs = @cOfficeId      
--20150723, liliana, LIBST13020, end      
      
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTampil  te      
--20150710, liliana, LIBST13020, begin            
    --join SQL_SIBS.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
    join dbo.CFAIDN_v cf      
        on te.NoCIF19 = cf.CFCIF              
--20150710, liliana, LIBST13020, end                  
    where cf.CFSSCD = 'SII '       
      
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTampil  te      
--20150710, liliana, LIBST13020, begin                
    --join SQL_CIF.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
    join dbo.CFAIDN_CIF_v cf      
        on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end      
    where cf.CFSSCD = 'SII'      
      
    update te      
    set RiskProfile = dr.RiskProfileDesc      
    from #tempTampil  te      
--20150710, liliana, LIBST13020, begin                
    --join SQL_SIBS.dbo.CFMAST cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)            
    join dbo.CFMAST_v cf      
        on te.NoCIF19 = cf.CFCIF                  
--20150710, liliana, LIBST13020, end      
    join dbo.ReksaDescRiskProfile_TR dr      
        on dr.RiskProfileCFMAST = cf.CFUIC8      
      
    update te      
    set RiskProfile = dr.RiskProfileDesc      
    from #tempTampil  te      
--20150710, liliana, LIBST13020, begin            
    --join SQL_CIF.dbo.CFMAST cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
    join dbo.CFMAST_CIF_v cf      
        on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end      
    join dbo.ReksaDescRiskProfile_TR dr      
        on dr.RiskProfileCFMAST = cf.CFUIC8      
--20150710, liliana, LIBST13020, begin      
              
    update te      
    set LastUpdateRiskProfile = rcif.RiskProfileLastUpdate      
    from #tempTampil  te      
    join ReksaRiskProfileLastUpdate_TM rcif      
        on te.NoCIF = rcif.CIFNo       
      
    update te       
    set PhoneOrder = 'Yes'      
    from #tempTampilEdit  te      
    join dbo.ProCIFCustTagging_TM_v ct      
        on ct.CustomerId = te.NoCIF      
    where ct.PBFaciltyType = 'FTR'            
--20150710, liliana, LIBST13020, end      
    Update te        
    set NPWP = cf.CFSSNO        
    from  #tempTampil te       
--20150710, liliana, LIBST13020, begin            
    --join SQL_SIBS.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
    join dbo.CFAIDN_v cf      
        on te.NoCIF19 = cf.CFCIF              
--20150710, liliana, LIBST13020, end          
    where cf.CFSSCD = 'NPWP'          
      
    Update te        
    set NPWP = cf.CFSSNO        
    from  #tempTampil te       
--20150710, liliana, LIBST13020, begin                
    --join SQL_CIF.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
    join dbo.CFAIDN_CIF_v cf      
        on te.NoCIFBigInt = cf.CFCIF#             
--20150710, liliana, LIBST13020, end      
    where cf.CFSSCD = 'NPWP'          
      
    update te       
    set AlamatKonfirmasi = rtrim(ca.AddressLine1) + ' '+ rtrim(ca.AddressLine2)  + ' '+  rtrim(ca.AddressLine3) + ' ' + rtrim(ca.AddressLine4)      
    from #tempTampil te      
    join dbo.ReksaCIFConfirmAddr_TM ca      
        on te.NasabahId = ca.Id      
        and ca.DataType = 2      
           
    --data lama       
--20150710, liliana, LIBST13020, begin                                    
    --select *       
    select      
        CheckB,      
        KodeKantor,      
        NoCIF,      
        NamaNasabah,      
        NoSID,      
        ShareholderID,      
        RiskProfile,      
        LastUpdateRiskProfile,      
--20150723, liliana, LIBST13020, begin            
        --PhoneOrder,      
        PhoneOrder as TransaksiMelaluiTelepon,      
--20150723, liliana, LIBST13020, end              
        KaryawanOCBCNISP,      
        NoRekRelasiIDR,      
        NamaRekRelasiIDR,      
        NoRekRelasiUSD,      
        NamaRekRelasiUSD,         
--20150730, liliana, LIBST13020, begin      
        NoRekRelasiMulticurrency,       
        NamaRekRelasiMulticurrency,      
--20150730, liliana, LIBST13020, end              
        AlamatKonfirmasi,      
        UserInput,      
        TanggalInput,             
        NasabahId,      
        NoReferensi               
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end   
--20160829, Elva, LOGEN00196, begin    
  , NoRekRelasiIDRTaxAmnesty  
  , NamaRekRelasiIDRTaxAmnesty  
  , NoRekRelasiUSDTaxAmnesty  
  , NamaRekRelasiUSDTaxAmnesty  
  , NoRekRelasiMCTaxAmnesty  
  , NamaRekRelasiMCTaxAmnesty  
--20160829, Elva, LOGEN00196, end         
    from #tempTampil      
--20151130, liliana, LIBST13020, begin    
 order by TanggalInput    
--20151130, liliana, LIBST13020, end        
          
    --data baru      
--20150710, liliana, LIBST13020, begin        
    --select *       
    select      
        CheckB,      
        KodeKantor,      
        NoCIF,      
        NamaNasabah,      
        NoSID,      
        ShareholderID,      
        RiskProfile,      
        LastUpdateRiskProfile,      
--20150723, liliana, LIBST13020, begin            
        --PhoneOrder,      
        PhoneOrder as TransaksiMelaluiTelepon,      
--20150723, liliana, LIBST13020, end      
        KaryawanOCBCNISP,      
        NoRekRelasiIDR,      
        NamaRekRelasiIDR,      
        NoRekRelasiUSD,      
        NamaRekRelasiUSD,      
--20150730, liliana, LIBST13020, begin      
        NoRekRelasiMulticurrency,       
        NamaRekRelasiMulticurrency,      
--20150730, liliana, LIBST13020, end                  
        AlamatKonfirmasi,      
        UserInput,      
        TanggalInput,             
        NasabahId,      
        NoReferensi           
--20150710, liliana, LIBST13020, end      
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end  
--20160829, Elva, LOGEN00196, begin    
  , NoRekRelasiIDRTaxAmnesty  
  , NamaRekRelasiIDRTaxAmnesty  
  , NoRekRelasiUSDTaxAmnesty  
  , NamaRekRelasiUSDTaxAmnesty  
  , NoRekRelasiMCTaxAmnesty  
  , NamaRekRelasiMCTaxAmnesty  
--20160829, Elva, LOGEN00196, end             
    from #tempTampilEdit      
--20150710, liliana, LIBST13020, begin      
    where NoReferensi = @cNoReferensi       
--20150710, liliana, LIBST13020, end    
--20151130, liliana, LIBST13020, begin    
 order by TanggalInput    
--20151130, liliana, LIBST13020, end                 
          
end      
else if(@cAuthorization = 'BLK')      
begin      
    if (@cAction = 'ADD')      
    begin      
        set @cAuthType = 1      
    end      
    else if (@cAction = 'DELETE')      
    begin      
        set @cAuthType = 3       
    end       
          
    insert #tempBlocking (CheckB, KodeBlokir, ClientCode,      
        NamaNasabah, TglBlokir, TglExpiryBlokir, NominalBlokir, Deskripsi, UserInput         
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end                              
    )      
    select @bBol, rb.BlockId, rc.ClientCode,      
        rc.CIFName, rb.BlockDate, rb.BlockExpiry, rb.BlockAmount, rb.BlockDesc, rb.UserSuid      
--20150827, liliana, LIBST13020, begin      
        , un.fullname      
--20150827, liliana, LIBST13020, end                 
    from dbo.ReksaBlocking_TM rb      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = rb.ClientId      
    join dbo.user_nisp_v un      
        on rb.UserSuid = un.nik      
    where rb.AuthType = @cAuthType      
        and rb.CheckerSuid is null      
        and un.office_id_sibs = @cOfficeId      
              
    select *      
    from #tempBlocking      
--20151130, liliana, LIBST13020, begin    
 order by TglBlokir    
--20151130, liliana, LIBST13020, end           
      
end      
else if(@cAuthorization = 'TRX')      
begin      
    if(@cTypeTrx = 'ALL')             
    begin      
        set @cTranType = null      
    end      
    else if (@cTypeTrx = 'SUBS')      
    begin      
        set @cTranType = 1      
    end      
    else if (@cTypeTrx = 'REDEMP')      
    begin      
        set @cTranType = 3      
    end       
    else if (@cTypeTrx = 'SUBSRDB')      
    begin      
        set @cTranType = 8      
    end       
    else if (@cTypeTrx = 'SWCNONRDB')      
    begin      
        set @cTranType = 6      
    end           
    else if (@cTypeTrx = 'SWCRDB')      
    begin      
        set @cTranType = 9      
    end      
    else if (@cTypeTrx = 'BOOK')      
    begin      
        set @cTranType = 7      
    end      
                      
    if (@cAction = 'ADD')      
    begin      
        set @cAuthType = 1      
    end      
    else if (@cAction = 'EDIT')      
    begin      
        set @cAuthType = 2       
    end           
    else if (@cAction = 'DELETE')      
    begin      
        set @cAuthType = 3       
    end       
          
    --non swc      
    insert #tempTransaksi (CheckB, NoReferensi, OfficeId, ShareholderID,      
--20150827, liliana, LIBST13020, begin          
        --NoCIF, NamaNasabah, NoRekRelasi, NIKWAPERD, NIKSeller,      
        NoCIF, NamaNasabah, NoRekRelasiIDR, NoRekRelasiUSD, NoRekRelasiMulticurrency, NIKWAPERD, NIKSeller,      
--20150827, liliana, LIBST13020, end              
        NIKReferentor, UserInput, TranType      
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, NoRekRelasiIDRTAX, NoRekRelasiUSDTAX, NoRekRelasiMulticurrencyTAX  
--20160830, liliana, LOGEN00196, end                 
    )             
    select distinct @bBol, tt.RefID, tt.OfficeId, rc.ShareholderID,       
--20150827, liliana, LIBST13020, begin           
        --rc.CIFNo, rc.CIFName, rc.NISPAccountId, tt.Waperd, tt.Seller,                 
        rc.CIFNo, rc.CIFName, rc.NISPAccountId, rc.NISPAccountIdUSD, rc.NISPAccountIdMC, tt.Waperd, tt.Seller,               
--20150827, liliana, LIBST13020, end              
        tt.Referentor, tt.UserSuid,      
        case when tt.TranType in (1,2) then 1      
            when tt.TranType in (3,4) then 3      
            when tt.TranType in (8) then 8 end      
--20150827, liliana, LIBST13020, begin      
        , un.fullname      
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, rc.AccountIdTA, rc.AccountIdUSDTA, rc.AccountIdMCTA  
--20160830, liliana, LOGEN00196, end                     
    from dbo.ReksaTransaction_TT tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaCIFData_TM rcc      
        on rcc.ClientId = tt.ClientId      
    join dbo.ReksaMasterNasabah_TM rc      
        on rc.CIFNo = rcc.CIFNo      
    where tt.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin        
        --and tt.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId      
        and isnull(tt.ExtStatus,0) not in (10,20,30)      
        and tt.TranType in (1,2,3,4,8)      
--20150413, liliana, LIBST13020, begin      
        and tt.AuthType = @cAuthType      
--20150413, liliana, LIBST13020, end      
      
    -- swc      
    insert #tempTransaksi (CheckB, NoReferensi, OfficeId, ShareholderID,      
--20150827, liliana, LIBST13020, begin          
        --NoCIF, NamaNasabah, NoRekRelasi, NIKWAPERD, NIKSeller,      
        NoCIF, NamaNasabah, NoRekRelasiIDR, NoRekRelasiUSD, NoRekRelasiMulticurrency, NIKWAPERD, NIKSeller,      
--20150827, liliana, LIBST13020, end          
        NIKReferentor, UserInput, TranType      
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, NoRekRelasiIDRTAX, NoRekRelasiUSDTAX, NoRekRelasiMulticurrencyTAX  
--20160830, liliana, LOGEN00196, end                    
    )             
    select distinct @bBol, tt.RefID, tt.OfficeId, rc.ShareholderID,       
--20150827, liliana, LIBST13020, begin           
        --rc.CIFNo, rc.CIFName, rc.NISPAccountId, tt.Waperd, tt.Seller,      
        rc.CIFNo, rc.CIFName, rc.NISPAccountId, rc.NISPAccountIdUSD, rc.NISPAccountIdMC, tt.Waperd, tt.Seller,      
--20150827, liliana, LIBST13020, end               
        tt.Referentor, tt.UserSuid,      
        case when tt.TranType in (5,6) then 6      
            when tt.TranType in (9) then 9 end      
--20150827, liliana, LIBST13020, begin      
        , un.fullname      
--20150827, liliana, LIBST13020, end 
--20160830, liliana, LOGEN00196, begin
		, rc.AccountIdTA, rc.AccountIdUSDTA, rc.AccountIdMCTA  
--20160830, liliana, LOGEN00196, end                   
    from dbo.ReksaSwitchingTransaction_TM tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaCIFData_TM rcc      
        on rcc.ClientId = tt.ClientIdSwcOut      
    join dbo.ReksaMasterNasabah_TM rc      
        on rc.CIFNo = rcc.CIFNo      
    where tt.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin            
        --and tt.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId      
        and tt.TranType in (5,6,9)      
--20150413, liliana, LIBST13020, begin      
        and tt.AuthType = @cAuthType      
--20150413, liliana, LIBST13020, end                  
      
    --booking      
    insert #tempTransaksi (CheckB, NoReferensi, OfficeId, ShareholderID,      
--20150827, liliana, LIBST13020, begin          
        --NoCIF, NamaNasabah, NoRekRelasi, NIKWAPERD, NIKSeller,      
        NoCIF, NamaNasabah, NoRekRelasiIDR, NoRekRelasiUSD, NoRekRelasiMulticurrency, NIKWAPERD, NIKSeller,      
--20150827, liliana, LIBST13020, end                  
        NIKReferentor, UserInput, TranType      
--20150827, liliana, LIBST13020, begin      
        , UserName      
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, NoRekRelasiIDRTAX, NoRekRelasiUSDTAX, NoRekRelasiMulticurrencyTAX  
--20160830, liliana, LOGEN00196, end                
    )             
    select distinct @bBol, rb.RefID, rb.OfficeId, rc.ShareholderID,       
--20150827, liliana, LIBST13020, begin           
        --rc.CIFNo, rc.CIFName, rc.NISPAccountId, rb.Waperd, rb.Seller,      
        rc.CIFNo, rc.CIFName, rc.NISPAccountId, rc.NISPAccountIdUSD, rc.NISPAccountIdMC, rb.Waperd, rb.Seller,      
--20150827, liliana, LIBST13020, end                 
        rb.Referentor, rb.UserSuid, 7      
--20150827, liliana, LIBST13020, begin      
        , un.fullname      
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, rc.AccountIdTA, rc.AccountIdUSDTA, rc.AccountIdMCTA  
--20160830, liliana, LOGEN00196, end               
    from dbo.ReksaBooking_TM rb      
    join dbo.user_nisp_v un      
        on rb.UserSuid = un.nik      
    join dbo.ReksaMasterNasabah_TM rc      
        on rc.CIFNo = rb.CIFNo      
    where rb.CheckerSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and rb.AuthType = @cAuthType      
--20150710, liliana, LIBST13020, begin      
      
    update #tempTransaksi      
    set NoCIFBigInt = convert(bigint, NoCIF),      
        NoCIF19 = right(('0000000000000000000'+ NoCIF),19)       
--20150710, liliana, LIBST13020, end                  
      
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTransaksi  te      
--20150710, liliana, LIBST13020, begin        
    --join SQL_SIBS.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
    join dbo.CFAIDN_v cf      
        on te.NoCIF19 = cf.CFCIF          
--20150710, liliana, LIBST13020, end              
    where cf.CFSSCD = 'SII '       
      
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTransaksi  te      
--20150710, liliana, LIBST13020, begin        
    --join SQL_CIF.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
    join dbo.CFAIDN_CIF_v cf      
        on te.NoCIFBigInt = cf.CFCIF#         
--20150710, liliana, LIBST13020, end              
    where cf.CFSSCD = 'SII'      
          
    update te      
    set NamaWAPERD = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKWAPERD       
          
    update te      
    set NamaSeller = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKSeller              
      
    update te      
    set NamaReferentor = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKReferentor              
                      
    --insert transaksi non swc      
    insert #tempTransaksiDetail(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi,      
        TglTransaksi, TglValuta, KodeProduk,       
        ClientCode, MataUang, NominalTransaksi,      
        UnitTransaksi, FullAmount, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
        FeeNominal, PctFee,       
        Channel, TranType, TranId   
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end             
    )      
    select @bBol, tt.RefID,               
        case when tt.TranType in (1) then 'Subscription New'      
            when tt.TranType in (2) then 'Subscription Add'      
            when tt.TranType in (3) then 'Redemption Sebagian'      
            when tt.TranType in (4) then 'Redemption All'      
            when tt.TranType in (8) then 'Reksadana Berjangka' end, tt.TranCode,      
        tt.TranDate, tt.NAVValueDate, rp.ProdCode,      
        rc.ClientCode, tt.TranCCY, tt.TranAmt,      
        tt.TranUnit, tt.FullAmount, tt.JangkaWaktu, tt.JatuhTempo, tt.FrekPendebetan,      
        tt.Asuransi, tt.AutoRedemption, tt.IsFeeEdit,       
        case when tt.TranType in (1,2,8) then tt.SubcFee else tt.RedempFee end, tt.PercentageFee,       
        ch.ChannelDesc,      
        case when tt.TranType in (1,2) then 1      
            when tt.TranType in (3,4) then 3      
            when tt.TranType in (8) then 8 end, tt.TranId  
--20160830, liliana, LOGEN00196, begin
		, case when isnull(tt.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                 
    from dbo.ReksaTransaction_TT tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = tt.ProdId      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = tt.ClientId      
    join dbo.ReksaChannelList_TM ch      
        on tt.Channel = ch.ChannelCode      
    where tt.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin            
        --and tt.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId        
        and isnull(tt.ExtStatus,0) not in (10,20,30)      
        and tt.TranType in (1,2,3,4,8)      
--20150413, liliana, LIBST13020, begin      
        and tt.AuthType = @cAuthType      
--20150413, liliana, LIBST13020, end              
          
    --insert transaksi swc      
    insert #tempTransaksiDetail(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi, TglTransaksi, TglValuta,       
        KodeProdukSwcOut, KodeProdukSwcIn, ClientCodeSwcOut, ClientCodeSwcIn,      
        UnitTransaksi, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
        FeeNominal, PctFee, Channel, TranType, TranId      
--20150608, liliana, LIBST13020, begin      
        , MataUang      
--20150608, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end                
    )      
    select @bBol, rs.RefID,       
        case when rs.TranType in (5) then 'Switching Sebagian'      
            when rs.TranType in (6) then 'Switching All'      
            when rs.TranType in (9) then 'Switching RDB' end, rs.TranCode,      
        rs.TranDate, rs.NAVValueDate,       
        rp.ProdCode, rp2.ProdCode, rc.ClientCode, rc2.ClientCode,      
        rs.TranUnit, rs.JangkaWaktu, rs.JatuhTempo, rs.FrekPendebetan,      
        rs.Asuransi, rs.AutoRedemption, rs.IsFeeEdit,      
        rs.SwitchingFee, rs.PercentageFee, ch.ChannelDesc,      
        case when rs.TranType in (5,6) then 6      
            when rs.TranType in (9) then 9 end, rs.TranId      
--20150608, liliana, LIBST13020, begin      
        , rs.TranCCY      
--20150608, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, case when isnull(rs.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                   
    from dbo.ReksaSwitchingTransaction_TM rs      
    join dbo.user_nisp_v un      
        on rs.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = rs.ProdSwitchOut      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = rs.ClientIdSwcOut      
    join dbo.ReksaProduct_TM rp2          
        on rp2.ProdId = rs.ProdSwitchIn      
    join dbo.ReksaCIFData_TM rc2      
        on rc2.ClientId = rs.ClientIdSwcIn            
    join dbo.ReksaChannelList_TM ch      
        on rs.Channel = ch.ChannelCode            
    where rs.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin            
        --and rs.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId        
        and rs.TranType in (5,6,9)      
--20150413, liliana, LIBST13020, begin      
        and rs.AuthType = @cAuthType      
--20150413, liliana, LIBST13020, end              
          
    --insert transaksi booking      
    insert #tempTransaksiDetail(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi,      
        TglTransaksi, KodeProduk, MataUang, NominalTransaksi,      
        FeeEdit, FeeNominal, PctFee,       
        Channel, TranType, TranId
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end              
    )      
    select @bBol, rb.RefID,       
        'Booking', rb.BookingCode,      
        rb.BookingDate, rp.ProdCode, rb.BookingCCY, rb.BookingAmt,      
        rb.IsFeeEdit, rb.SubcFee, rb.PercentageFee,      
        ch.ChannelDesc, 7, rb.BookingId
--20160830, liliana, LOGEN00196, begin
		, case when isnull(rb.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                      
    from dbo.ReksaBooking_TM rb      
    join dbo.user_nisp_v un      
        on rb.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp      
        on rp.ProdId = rb.ProdId      
    join dbo.ReksaChannelList_TM ch      
        on rb.Channel = ch.ChannelCode                
    where rb.CheckerSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and rb.AuthType = @cAuthType          
--20150421, liliana, LIBST13020, begin      
      
    --insert transaksi non swc      
    insert #tempTransaksiDetailNew(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi,      
        TglTransaksi, TglValuta, KodeProduk,       
        ClientCode, MataUang, NominalTransaksi,      
        UnitTransaksi, FullAmount, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
        FeeNominal, PctFee,       
        Channel, TranType, TranId 
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end              
    )      
    select @bBol, tmp.RefID,              
        case when tmp.TranType in (1) then 'Subscription New'      
            when tmp.TranType in (2) then 'Subscription Add'      
            when tmp.TranType in (3) then 'Redemption Sebagian'      
            when tmp.TranType in (4) then 'Redemption All'      
            when tmp.TranType in (8) then 'Reksadana Berjangka' end, tmp.TranCode,                  
        tmp.TranDate, tmp.NAVValueDate, rp.ProdCode,        
        rc.ClientCode, tmp.TranCCY, tmp.TranAmt,      
        tmp.TranUnit, tmp.FullAmount, tmp.JangkaWaktu, tmp.JatuhTempo, tmp.FrekPendebetan,      
        tmp.Asuransi, tmp.AutoRedemption, tmp.IsFeeEdit,       
        case when tmp.TranType in (1,2,8) then tmp.SubcFee else tmp.RedempFee end, tmp.PercentageFee,       
        ch.ChannelDesc,      
        case when tmp.TranType in (1,2) then 1      
            when tmp.TranType in (3,4) then 3      
            when tmp.TranType in (8) then 8 end, tmp.TranId 
--20160830, liliana, LOGEN00196, begin
		, case when isnull(tmp.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                   
    from dbo.ReksaTransaction_TT tt      
    join dbo.ReksaTransaction_TMP tmp         
        on tt.TranId = tmp.TranId      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = tt.ProdId      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = tt.ClientId      
    join dbo.ReksaChannelList_TM ch      
--20150710, liliana, LIBST13020, begin        
        --on tt.Channel = ch.ChannelCode      
        on tmp.Channel = ch.ChannelCode      
--20150710, liliana, LIBST13020, end              
    where tt.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin            
        --and tt.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId        
        and isnull(tt.ExtStatus,0) not in (10,20,30)      
        and tt.TranType in (1,2,3,4,8)      
        and tt.AuthType = @cAuthType      
        and tmp.AuthType = 4          
          
    --insert transaksi swc      
    insert #tempTransaksiDetailNew(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi, TglTransaksi, TglValuta,       
        KodeProdukSwcOut, KodeProdukSwcIn, ClientCodeSwcOut, ClientCodeSwcIn,      
        UnitTransaksi, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
        FeeNominal, PctFee, Channel, TranType, TranId      
--20150608, liliana, LIBST13020, begin      
        , MataUang      
--20150608, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end                     
    )      
    select @bBol, tmp.RefID,       
        case when tmp.TranType in (5) then 'Switching Sebagian'      
            when tmp.TranType in (6) then 'Switching All'      
            when tmp.TranType in (9) then 'Switching RDB' end, tmp.TranCode,      
        tmp.TranDate, tmp.NAVValueDate,       
        rp.ProdCode, rp2.ProdCode, rc.ClientCode, rc2.ClientCode,      
        tmp.TranUnit, tmp.JangkaWaktu, tmp.JatuhTempo, tmp.FrekPendebetan,      
        tmp.Asuransi, tmp.AutoRedemption, tmp.IsFeeEdit,      
        tmp.SwitchingFee, tmp.PercentageFee, ch.ChannelDesc,      
        case when tmp.TranType in (5,6) then 6      
            when tmp.TranType in (9) then 9 end, tmp.TranId      
--20150608, liliana, LIBST13020, begin      
        , tmp.TranCCY      
--20150608, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, case when isnull(tmp.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                       
    from dbo.ReksaSwitchingTransaction_TM rs      
    join dbo.ReksaSwitchingTransaction_TMP tmp      
        on rs.TranId = tmp.TranId       
    join dbo.user_nisp_v un      
        on rs.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = rs.ProdSwitchOut      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = rs.ClientIdSwcOut      
    join dbo.ReksaProduct_TM rp2          
        on rp2.ProdId = rs.ProdSwitchIn      
    join dbo.ReksaCIFData_TM rc2      
        on rc2.ClientId = rs.ClientIdSwcIn            
    join dbo.ReksaChannelList_TM ch      
--20150710, liliana, LIBST13020, begin        
        --on rs.Channel = ch.ChannelCode      
        on tmp.Channel = ch.ChannelCode      
--20150710, liliana, LIBST13020, end                      
    where rs.CheckerSuid is null      
--20150715, liliana, LIBST13020, begin            
        --and rs.Status = 0      
--20150715, liliana, LIBST13020, end              
        and un.office_id_sibs = @cOfficeId        
        and rs.TranType in (5,6,9)      
        and rs.AuthType = @cAuthType          
        and tmp.AuthType = 4          
          
    --insert transaksi booking      
    insert #tempTransaksiDetailNew(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi,      
        TglTransaksi, KodeProduk, MataUang, NominalTransaksi,      
        FeeEdit, FeeNominal, PctFee,       
        Channel, TranType, TranId  
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end             
    )      
    select @bBol, th.RefID,       
        'Booking', th.BookingCode,      
        th.BookingDate, rp.ProdCode, th.BookingCCY, th.BookingAmt,      
        th.IsFeeEdit, th.SubcFee, th.PercentageFee,      
        ch.ChannelDesc, 7, th.BookingId
--20160830, liliana, LOGEN00196, begin
		, case when isnull(rb.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end
--20160830, liliana, LOGEN00196, end                    
    from dbo.ReksaBooking_TM rb      
    join dbo.ReksaBooking_TH th      
        on rb.BookingId = th.BookingId      
    join dbo.user_nisp_v un      
        on rb.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp      
        on rp.ProdId = rb.ProdId      
    join dbo.ReksaChannelList_TM ch      
--20150710, liliana, LIBST13020, begin            
        --on rb.Channel = ch.ChannelCode      
        on th.Channel = ch.ChannelCode        
--20150710, liliana, LIBST13020, end                      
    where rb.CheckerSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and rb.AuthType = @cAuthType          
        and th.AuthType = 4       
--20150421, liliana, LIBST13020, end         
--20150828, liliana, LIBST13020, begin      
      
    update new      
    set TglTransaksi = old.TglTransaksi  ,      
        TglValuta = old.TglValuta      
    from #tempTransaksiDetailNew new      
    join #tempTransaksiDetail old      
        on old.KodeTransaksi = new.KodeTransaksi      
        and old.NoReferensi = new.NoReferensi      
        and old.TranType = new.TranType      
--20150828, liliana, LIBST13020, end               
              
    select * from #tempTransaksi      
    where TranType = isnull(@cTranType, TranType)      
--20151130, liliana, LIBST13020, begin    
 order by NoReferensi asc    
--20151130, liliana, LIBST13020, end    
      
--20150907, liliana, LIBST13020, begin      
    --select * from #tempTransaksiDetail      
 select *, @dToday as Today      
 from #tempTransaksiDetail      
--20150907, liliana, LIBST13020, end            
    where TranType = isnull(@cTranType, TranType)      
        and NoReferensi = @cNoReferensi      
--20150421, liliana, LIBST13020, begin     
--20151130, liliana, LIBST13020, begin    
 order by TglTransaksi asc    
--20151130, liliana, LIBST13020, end    
      
--20150907, liliana, LIBST13020, begin      
    --select * from #tempTransaksiDetailNew      
    select *, @dToday as Today       
    from #tempTransaksiDetailNew      
--20150907, liliana, LIBST13020, end          
    where NoReferensi = @cNoReferensi      
--20150421, liliana, LIBST13020, end    
--20151130, liliana, LIBST13020, begin    
 order by TglTransaksi asc    
--20151130, liliana, LIBST13020, end            
              
end      
else if (@cAuthorization = 'REV')      
begin      
    if(@cTypeTrx = 'ALL')             
    begin      
        set @cTranType = null      
    end      
    else if (@cTypeTrx = 'SUBS')      
    begin      
        set @cTranType = 1      
    end      
    else if (@cTypeTrx = 'REDEMP')      
    begin      
        set @cTranType = 3      
    end       
    else if (@cTypeTrx = 'SUBSRDB')      
    begin      
        set @cTranType = 8      
    end       
    else if (@cTypeTrx = 'SWCNONRDB')      
    begin      
        set @cTranType = 6      
    end           
    else if (@cTypeTrx = 'SWCRDB')      
    begin      
        set @cTranType = 9      
    end      
    else if (@cTypeTrx = 'BOOK')      
    begin      
        set @cTranType = 7      
    end      
          
    --non swc      
    insert #tempTransaksi (CheckB, NoReferensi, OfficeId, ShareholderID,      
--20150827, liliana, LIBST13020, begin          
        --NoCIF, NamaNasabah, NoRekRelasi, NIKWAPERD, NIKSeller,      
        NoCIF, NamaNasabah, NoRekRelasiIDR, NoRekRelasiUSD, NoRekRelasiMulticurrency, NIKWAPERD, NIKSeller,      
--20150827, liliana, LIBST13020, end                     
        NIKReferentor, UserInput, TranType      
--20150827, liliana, LIBST13020, begin      
        , UserName            
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, NoRekRelasiIDRTAX, NoRekRelasiUSDTAX, NoRekRelasiMulticurrencyTAX  
--20160830, liliana, LOGEN00196, end                  
    )             
    select distinct @bBol, tt.RefID, tt.OfficeId, rc.ShareholderID,       
--20150827, liliana, LIBST13020, begin          
        --rc.CIFNo, rc.CIFName, rc.NISPAccountId, tt.Waperd, tt.Seller,      
        rc.CIFNo, rc.CIFName, rc.NISPAccountId, rc.NISPAccountIdUSD, rc.NISPAccountIdMC, tt.Waperd, tt.Seller,      
--20150827, liliana, LIBST13020, end              
        tt.Referentor, tt.UserSuid,      
        case when tt.TranType in (1,2) then 1      
            when tt.TranType in (3,4) then 3      
            when tt.TranType in (8) then 8 end      
--20150827, liliana, LIBST13020, begin      
        , un.fullname             
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, rc.AccountIdTA, rc.AccountIdUSDTA, rc.AccountIdMCTA  
--20160830, liliana, LOGEN00196, end                     
    from dbo.ReksaTransaction_TT tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaCIFData_TM rcc      
        on rcc.ClientId = tt.ClientId      
    join dbo.ReksaMasterNasabah_TM rc      
        on rc.CIFNo = rcc.CIFNo      
    where tt.CheckerSuid is not null      
        and tt.Status = 1      
        and tt.ReverseSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and tt.NAVValueDate >= @dToday      
        and isnull(tt.ExtStatus,0) not in (10,20,30)      
        and tt.TranType in (1,2,3,4,8)      
              
    -- swc      
    insert #tempTransaksi (CheckB, NoReferensi, OfficeId, ShareholderID,      
--20150827, liliana, LIBST13020, begin          
        --NoCIF, NamaNasabah, NoRekRelasi, NIKWAPERD, NIKSeller,      
        NoCIF, NamaNasabah, NoRekRelasiIDR, NoRekRelasiUSD, NoRekRelasiMulticurrency, NIKWAPERD, NIKSeller,      
--20150827, liliana, LIBST13020, end                 
        NIKReferentor, UserInput, TranType      
--20150827, liliana, LIBST13020, begin      
        , UserName            
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, NoRekRelasiIDRTAX, NoRekRelasiUSDTAX, NoRekRelasiMulticurrencyTAX  
--20160830, liliana, LOGEN00196, end                
    )             
    select distinct @bBol, tt.RefID, tt.OfficeId, rc.ShareholderID,       
--20150827, liliana, LIBST13020, begin            
        --rc.CIFNo, rc.CIFName, rc.NISPAccountId, tt.Waperd, tt.Seller,      
        rc.CIFNo, rc.CIFName, rc.NISPAccountId, rc.NISPAccountIdUSD, rc.NISPAccountIdMC, tt.Waperd, tt.Seller,      
--20150827, liliana, LIBST13020, end              
        tt.Referentor, tt.UserSuid,      
        case when tt.TranType in (5,6) then 6      
            when tt.TranType in (9) then 9 end      
--20150827, liliana, LIBST13020, begin      
        , un.fullname             
--20150827, liliana, LIBST13020, end
--20160830, liliana, LOGEN00196, begin
		, rc.AccountIdTA, rc.AccountIdUSDTA, rc.AccountIdMCTA  
--20160830, liliana, LOGEN00196, end                      
    from dbo.ReksaSwitchingTransaction_TM tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaCIFData_TM rcc      
        on rcc.ClientId = tt.ClientIdSwcOut      
    join dbo.ReksaMasterNasabah_TM rc      
        on rc.CIFNo = rcc.CIFNo      
    where tt.CheckerSuid is not null      
        and tt.Status = 1      
        and tt.ReverseSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and tt.NAVValueDate >= @dToday      
        and tt.TranType in (5,6,9)            
--20150710, liliana, LIBST13020, begin      
      
    update #tempTransaksi      
    set NoCIFBigInt = convert(bigint, NoCIF),      
        NoCIF19 = right(('0000000000000000000'+ NoCIF),19)       
              
--20150710, liliana, LIBST13020, end          
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTransaksi  te      
--20150710, liliana, LIBST13020, begin        
    --join SQL_SIBS.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF)      
    join dbo.CFAIDN_v cf      
        on te.NoCIF19 = cf.CFCIF          
--20150710, liliana, LIBST13020, end      
    where cf.CFSSCD = 'SII '       
      
    update te      
    set NoSID = cf.CFSSNO      
    from #tempTransaksi  te      
--20150710, liliana, LIBST13020, begin        
    --join SQL_CIF.dbo.CFAIDN cf      
    --  on convert(bigint,te.NoCIF) = convert(bigint,cf.CFCIF#)      
    join dbo.CFAIDN_CIF_v cf      
        on te.NoCIFBigInt = cf.CFCIF#         
--20150710, liliana, LIBST13020, end      
    where cf.CFSSCD = 'SII'      
          
    update te      
    set NamaWAPERD = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKWAPERD       
          
    update te      
    set NamaSeller = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKSeller              
      
    update te      
    set NamaReferentor = un.fullname      
    from #tempTransaksi  te      
    join user_nisp_v un      
        on un.nik = te.NIKReferentor          
      
    --insert transaksi non swc      
    insert #tempTransaksiDetail(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi,      
        TglTransaksi, TglValuta, KodeProduk,       
        ClientCode, MataUang, NominalTransaksi,      
        UnitTransaksi, FullAmount, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
  FeeNominal, PctFee,       
        Channel, TranType, TranId  
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end             
    )      
    select @bBol, tt.RefID,               
        case when tt.TranType in (1) then 'Subscription New'      
            when tt.TranType in (2) then 'Subscription Add'      
            when tt.TranType in (3) then 'Redemption Sebagian'      
            when tt.TranType in (4) then 'Redemption All'      
            when tt.TranType in (8) then 'Reksadana Berjangka' end, tt.TranCode,      
        tt.TranDate, tt.NAVValueDate, rp.ProdCode,      
        rc.ClientCode, tt.TranCCY, tt.TranAmt,      
        tt.TranUnit, tt.FullAmount, tt.JangkaWaktu, tt.JatuhTempo, tt.FrekPendebetan,      
        tt.Asuransi, tt.AutoRedemption, tt.IsFeeEdit,       
        case when tt.TranType in (1,2,8) then tt.SubcFee else tt.RedempFee end, tt.PercentageFee,       
        ch.ChannelDesc,      
        case when tt.TranType in (1,2) then 1      
            when tt.TranType in (3,4) then 3      
            when tt.TranType in (8) then 8 end, tt.TranId   
--20160830, liliana, LOGEN00196, begin
		, case when isnull(tt.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end		
--20160830, liliana, LOGEN00196, end               
    from dbo.ReksaTransaction_TT tt      
    join dbo.user_nisp_v un      
        on tt.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = tt.ProdId      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = tt.ClientId      
    join dbo.ReksaChannelList_TM ch      
        on tt.Channel = ch.ChannelCode      
    where tt.CheckerSuid is not null      
        and tt.Status = 1      
        and tt.ReverseSuid is null      
        and un.office_id_sibs = @cOfficeId      
        and tt.NAVValueDate >= @dToday      
        and isnull(tt.ExtStatus,0) not in (10,20,30)      
        and tt.TranType in (1,2,3,4,8)      
      
    --insert transaksi swc      
    insert #tempTransaksiDetail(CheckB, NoReferensi,       
        JenisTransaksi, KodeTransaksi, TglTransaksi, TglValuta,       
        KodeProdukSwcOut, KodeProdukSwcIn, ClientCodeSwcOut, ClientCodeSwcIn,      
        UnitTransaksi, JangkaWaktu, JatuhTempo, FrekPendebetan,      
        Asuransi, AutoRedemption, FeeEdit,       
        FeeNominal, PctFee, Channel, TranType, TranId 
--20160830, liliana, LOGEN00196, begin
		, TrxTaxAmnesty		
--20160830, liliana, LOGEN00196, end               
    )      
    select @bBol, rs.RefID,       
        case when rs.TranType in (5) then 'Switching Sebagian'      
            when rs.TranType in (6) then 'Switching All'      
            when rs.TranType in (9) then 'Switching RDB' end, rs.TranCode,      
        rs.TranDate, rs.NAVValueDate,       
        rp.ProdCode, rp2.ProdCode, rc.ClientCode, rc2.ClientCode,      
        rs.TranUnit, rs.JangkaWaktu, rs.JatuhTempo, rs.FrekPendebetan,      
        rs.Asuransi, rs.AutoRedemption, rs.IsFeeEdit,      
        rs.SwitchingFee, rs.PercentageFee, ch.ChannelDesc,      
        case when rs.TranType in (5,6) then 6      
            when rs.TranType in (9) then 9 end, rs.TranId
--20160830, liliana, LOGEN00196, begin
		, case when isnull(rs.ExtStatus,0) = 74 then convert(bit,1) else convert(bit,0) end		
--20160830, liliana, LOGEN00196, end                   
    from dbo.ReksaSwitchingTransaction_TM rs      
    join dbo.user_nisp_v un      
        on rs.UserSuid = un.nik      
    join dbo.ReksaProduct_TM rp       
        on rp.ProdId = rs.ProdSwitchOut      
    join dbo.ReksaCIFData_TM rc      
        on rc.ClientId = rs.ClientIdSwcOut      
    join dbo.ReksaProduct_TM rp2          
        on rp2.ProdId = rs.ProdSwitchIn      
    join dbo.ReksaCIFData_TM rc2      
        on rc2.ClientId = rs.ClientIdSwcIn            
    join dbo.ReksaChannelList_TM ch      
        on rs.Channel = ch.ChannelCode            
    where rs.CheckerSuid is not null      
        and rs.Status = 1      
        and rs.ReverseSuid is null      
        and rs.NAVValueDate >= @dToday      
        and un.office_id_sibs = @cOfficeId        
        and rs.TranType in (5,6,9)      
          
    select * from #tempTransaksi      
    where TranType = isnull(@cTranType, TranType)      
--20151130, liliana, LIBST13020, begin    
 order by NoReferensi    
--20151130, liliana, LIBST13020, end        
          
    select * from #tempTransaksiDetail      
    where TranType = isnull(@cTranType, TranType)      
        and NoReferensi = @cNoReferensi       
--20151130, liliana, LIBST13020, begin     
	order by TglTransaksi    
--20151130, liliana, LIBST13020, end                
              
end      
      
drop table #tempTampil      
drop table #tempTampilEdit      
drop table #tempBlocking      
drop table #tempTransaksi      
drop table #tempTransaksiDetail      
--20150421, liliana, LIBST13020, begin      
drop table #tempTransaksiDetailNew      
--20150421, liliana, LIBST13020, end      
      
return 0
GO