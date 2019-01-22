CREATE proc [dbo].[ReksaMaintainRejectBooking]        
/*        
 CREATED BY    :       
 CREATION DATE :    
 DESCRIPTION   : maintain Booking product close end        
 REVISED BY    :        
  DATE,  USER,   PROJECT,  NOTE        
  -----------------------------------------------------------------------        

 END REVISED        
*/        
 @pnType    int        
 ,@pnBookingId  int   = NULL         
 ,@pcBookingCode  char(8)  = NULL output        
 ,@pcCIF    char(13)         
 ,@pnProdId   int           
 ,@pnAgenId   int           
 ,@pcCurrency  char(3)          
 ,@pmNominal   money          
 ,@pnJnsRek   tinyint          
 ,@pnBankId   int           
 ,@pcAccRelasi  char(19)         
 ,@pcRekening  varchar(50)         
 ,@pcNamaRek   varchar(50)         
 ,@pnReferentor  int           
 ,@pnEmployee  tinyint          
 ,@pnCIFNIK   int   = 0        
 ,@pnNIK    int           
 ,@pcGuid   varchar(50)           
--tambah inputter, seller, waperd        
 ,@pcInputter varchar(40)        
 ,@pnSeller  int        
 ,@pnWaperd  int        
--kelengkapan dok        
 ,@pbDocRiskProfile bit        
 ,@pbDocTermCondition bit        
 ,@pdRiskProfileLastUpdate datetime          
 ,@pcAlamatConf varchar(max)             
as        
        
set nocount on        
        
declare @cErrMsg   varchar(100)        
  , @nOK    int        
  , @nErrNo   int        
  , @nProdId   int        
  , @cPFix   char(3)        
  , @nCounter   int        
  , @nAuthType  char(1)        
  , @cProductCode  varchar(10)        
  , @cAccountType  varchar(3)        
  , @cCurrencyType char(3)        
  , @cProdCCY   char(3)        
  , @dCurrWorkingDate datetime             
  , @mMaxUnitAllowed money        
  , @cProdCode  varchar(10)         
  , @mNAV    decimal(20,10)          
  , @cAccountStatus char(1)        
  , @cMCAllowed  char(1)        
  , @cOfficeId  char(5)           
  , @cNISPAccName  varchar(40)        
, @cCIFName   varchar(40)        
  , @dEndPeriod  datetime        
  , @mMinNom   decimal(25,13)        
  , @dTotalSubs  money            
  , @cTellerId  varchar(5)            
  , @nNewBookingId int        
  , @nConfHeaderLength int        
  , @xmlConfHeader  xml        
  , @xmlConfData   xml        
  , @cType    varchar(10) -- 0: booking, 1: client        
  , @cCIFNo    varchar(19)        
  , @nDataType   tinyint  -- 0: client, 1: cabang        
  , @cBranch    varchar(5)             
        
select @cTellerId = dbo.fnReksaGetParam('TELLERID')               
        
select @dCurrWorkingDate = current_working_date        
from fnGetWorkingDate()        
      
select @cOfficeId = office_id_sibs        
from user_nisp_v        
where nik = @pnNIK        
       
declare @nCIF     bigint        
set @nCIF = convert (bigint, @pcCIF)        
     
If @pnType not in (1,2,3)        
 set @cErrMsg = 'Tipe Operasi Tidak Dikenal!'        
else If @pnType in (2,3) and isnull(@pnBookingId,0) = 0        
 set @cErrMsg = 'Booking Id tidak dikenal!'        
   
else if @pnType in (1,2)         
Begin        
 set @nConfHeaderLength = left(@pcAlamatConf,5)        
        
 set @xmlConfHeader = convert(xml, substring(@pcAlamatConf,6,@nConfHeaderLength))        
 set @xmlConfData = convert(xml, substring(@pcAlamatConf,6+@nConfHeaderLength,len(@pcAlamatConf)+ 1 - (6+@nConfHeaderLength)))        
        
 select @cType  = @xmlConfHeader.value('(/Header/HeaderData/Type)[1]','varchar(10)')        
 select @cCIFNo  = right('0000000000000000'+@xmlConfHeader.value('(/Header/HeaderData/CIFNo)[1]','varchar(13)'),19)        
 select @nDataType = @xmlConfHeader.value('(/Header/HeaderData/DataType)[1]','int')        
 select @cBranch  = @xmlConfHeader.value('(/Header/HeaderData/Branch)[1]','varchar(5)')        
        
 If exists(select top 1 1 from ReksaBooking_TM a join ReksaCIFConfirmAddr_TM b        
        on a.BookingId = b.Id        
         and b.DataType = 0        
       where a.BookingId != isnull(@pnBookingId ,a.BookingId)        
        and a.CIFNo = @pcCIF and a.ProdId = @pnProdId        
        and a.AgentId = @pnAgenId        
        and a.NISPAccId = @pcAccRelasi        
        and b.AddressType != @nDataType        
  )        
  set @cErrMsg = 'Alamat Konfirmasi tidak sinkron dengan booking sebelumnya (1)!'        
 else If @nDataType = 0        
 Begin        
  select T1.t.value('./Sequence[1]','int') as Sequence         
    ,T1.t.value('./Address_x0020_Line_x0020_1[1]','varchar(40)') as AddressLine1         
    ,T1.t.value('./Address_x0020_Line_x0020_2[1]','varchar(40)') as AddressLine2         
    ,T1.t.value('./Address_x0020_Line_x0020_3[1]','varchar(40)') as AddressLine3        
    ,T1.t.value('./Address_x0020_Line_x0020_4[1]','varchar(40)') as AddressLine4         
    ,T1.t.value('./Kode_x0020_Pos[1]','varchar(9)') as KodePos         
    ,T1.t.value('./Address_x0020_Line_x0020_4[1]','varchar(1)') as AlamatLuarNegeri         
    ,T1.t.value('./Keterangan[1]','varchar(20)') as Keterangan         
    ,T1.t.value('./Alamat_x0020_Utama[1]','varchar(1)') as AlamatUtama         
    ,T1.t.value('./Kode_x0020_Alamat[1]','varchar(1)') as KodeAlamat         
    ,T1.t.value('./Alamat_x0020_SID[1]','varchar(1)') as AlamatSID         
    ,T1.t.value('./PeriodThere[1]','varchar(3)') as PeriodThere         
    ,T1.t.value('./PeriodThereCode[1]','varchar(1)') as PeriodThereCode         
    ,T1.t.value('./Jenis_x0020_Alamat[1]','varchar(5)') as JenisAlamat         
    ,T1.t.value('./StaySince[1]','varchar(5)') as StaySince         
    ,T1.t.value('./Kelurahan[1]','varchar(40)') as Kelurahan         
    ,T1.t.value('./Kecamatan[1]','varchar(40)') as Kecamatan         
    ,T1.t.value('./Kota[1]','varchar(40)') as Kota         
    ,T1.t.value('./Provinsi[1]','varchar(40)') as Provinsi        
  into #TempClient         
  from @xmlConfData.nodes('/Client/Table1') T1(t)        
  order by Sequence asc        
        
  if exists(select top 1 1 from ReksaBooking_TM a join ReksaCIFConfirmAddr_TM b        
         on a.BookingId = b.Id        
          and b.DataType = 0        
        where a.BookingId != isnull(@pnBookingId ,a.BookingId)        
         and a.CIFNo = @pcCIF and a.ProdId = @pnProdId        
         and a.AgentId = @pnAgenId        
         and a.NISPAccId = @pcAccRelasi        
         and b.AddressSeq != (select Sequence  from #TempClient)        
   )        
   set @cErrMsg = 'Alamat Konfirmasi tidak sinkron dengan booking sebelumnya (2)!'        
 end        
 else If @nDataType = 1        
 Begin        
  if exists(select top 1 1 from ReksaBooking_TM a join ReksaCIFConfirmAddr_TM b        
         on a.BookingId = b.Id        
          and b.DataType = 0        
        where a.BookingId != isnull(@pnBookingId ,a.BookingId)        
         and a.CIFNo = @pcCIF and a.ProdId = @pnProdId        
         and a.AgentId = @pnAgenId        
         and a.NISPAccId = @pcAccRelasi        
         and b.Branch != @cBranch        
   )        
   set @cErrMsg = 'Alamat Konfirmasi tidak sinkron dengan booking sebelumnya (3)!'        
 End        
         
        
         
         
End        
      
else if @pnType in (1,2) and @pnJnsRek = 1        
begin        
 declare        
  @cTranBranch char(5),        
  @cGNCAccountId varchar(19)        
          
 select @cTranBranch = b.office_id_sibs        
 from user_nisp_v a join office_information_all_v b        
  on a.office_id = b.office_id        
 where a.nik = @pnNIK        
  and isnull(ltrim(cost_centre_sibs),'') = ''          
         
 exec @nOK = ABCSAccountInquiry        
  @pcAccountID = @cGNCAccountId        
  ,@pnSubSystemNId = 111501        
  ,@pcTransactionBranch = @cTranBranch        
  ,@pcMultiCurrencyAllowed = @cMCAllowed output        
  ,@pcTellerId = @cTellerId        
          
 if @cMCAllowed = 'Y'        
  set @cErrMsg = 'Rek relasi non Nisp tidak boleh menggunakan rek Multicurrency'        
end           
else if (select ProcessStatus from ReksaUserProcess_TR where ProcessId = 10) = 1        
begin        
 set @cErrMsg = 'Tidak bisa melakukan booking/transaksi karena proses sinkronisasi sedang dijalankan. Harap tunggu'        
end        
     
if isnull(@cErrMsg,'') != ''        
 goto ERROR        
        
    
select @cProdCode = ProdCode, @mNAV = NAV        
from ReksaProduct_TM        
where ProdId = @pnProdId        
        
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
        
If @pnType in (1,2)        
Begin        
 if @pmNominal > (@mMaxUnitAllowed * @mNAV)        
 Begin        
  
  set @cErrMsg = 'Transaksi Besar Limit (' + convert(varchar(30), convert(money, @mMaxUnitAllowed * @mNAV)) + ')'        
  
  goto ERROR        
 End        
  
End        
     
If @pnType in (1,2)        
Begin        
      
 if not exists(select * from ReksaAgent_TR where AgentId = @pnAgenId and OfficeId = @cOfficeId)        
 Begin        
  set @cErrMsg = 'Kode Agent Tidak Sesuai Kode Cabang!'        
  goto ERROR        
 End         
      
        
 select @cProdCCY = ProdCCY           
   , @dEndPeriod = PeriodEnd        
   , @mMinNom = MinSubcNew            
 from ReksaProduct_TM        
 where ProdId = @pnProdId        
        
 if isnull(ltrim(@cProdCCY),'') = ''        
 Begin        
  set @cErrMsg = 'Mata Uang Product tidak ditemukan!'        
  goto ERROR        
 End        
        
 if @dEndPeriod = @dCurrWorkingDate        
  and (select datediff(mi, '00:00:00', convert(varchar(8), getdate(), 108))) > (select CutOff from ReksaUserProcess_TR where ProcessId = 1)        
 Begin        
  set @cErrMsg = 'Sudah lewat masa penawaran, tidak bisa booking'        
  goto ERROR        
 End        
        
 select @dTotalSubs = sum(BookingAmt)        
 from ReksaBooking_TM        
 where ProdId = @pnProdId        
  and CIFNo = @pcCIF        
  and AgentId = @pnAgenId        
        
 if @dTotalSubs is null        
  set @dTotalSubs = 0        
        
 set @dTotalSubs = @dTotalSubs + @pmNominal        
        
 if @dTotalSubs < @mMinNom        
 Begin        
  set @cErrMsg = 'Total Subscription per agent minimal ' + convert(varchar(30), cast(@mMinNom as money), 1)        
  goto ERROR        
 End        
        
 If  @pcCurrency != @cProdCCY        
 Begin        
  set @cErrMsg = 'Mata Uang Harus ' + @cProdCCY + ' !'        
  goto ERROR         
 End        
        
 exec @nOK = ABCSAccountInquiry        
  @pcAccountID = @pcAccRelasi        
  ,@pnSubSystemNId = 111501        
  ,@pcTransactionBranch = '99965'        
  ,@pcProductCode = @cProductCode output        
  ,@pcCurrencyType = @cCurrencyType output        
  ,@pcAccountType =@cAccountType output        
  , @pcMultiCurrencyAllowed = @cMCAllowed output        
  , @pcAccountStatus = @cAccountStatus output        
  , @pcTellerId = @cTellerId        
  ,@pcCIFName1 = @cNISPAccName output        
        
 If @cMCAllowed = 'Y'        
 Begin        
  select @cCurrencyType = @cProdCCY        
 End        
  
 if @cCurrencyType != @cProdCCY        
 Begin        
  set @cErrMsg = 'Mata Uang Relasi tidak sama dengan product!'        
  goto ERROR        
 End         
  
 if left(@cProductCode,3) = 'TKA'        
 Begin        
  set @cErrMsg = 'Tidak Boleh Rekening Taka!'        
  goto ERROR        
 End        
        
    
 If @cAccountStatus not in ('1' ,'4', '9')          
 Begin        
  set @cErrMsg = 'Rekening Tidak Aktif!'        
  goto ERROR        
 End           
End        
        
  
select @cCIFName = CFNA1        
from CFMAST_v        
where CFCIF = '000000'+@pcCIF        
    
        
      
If @pnType = 1        
Begin         
      
 declare @tmp table (        
  RiskProfile varchar(20),        
  LastUpdate datetime,        
  IsRegistered bit        
 )        
        
 insert into @tmp exec ReksaGetRiskProfile @pcCIF        
        
 if (select isnull(RiskProfile, '') from @tmp) = ''        
 begin        
  set @cErrMsg = 'Data risk profile untuk CIF ' + @pcCIF + ' belum ada'        
  goto ERROR        
 end        
     
        
 select @cPFix = left(ProdCode,3)        
 from ReksaProduct_TM         
 where ProdId = @pnProdId         
        
 if @@error != 0 or @@rowcount = 0        
 Begin        
  set @cErrMsg = 'Error Get Prefix!'        
  goto ERROR        
 End        
        
     
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
  , ProdId, CIFNo, IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NonNISPAccId        
  , NonNISPAccName, Referentor, AuthType, Status,  LastUpdate, UserSuid, CheckerSuid             
  , CIFName, NISPAccName        
  , Inputter, Seller, Waperd, DocRiskProfile, DocTermCondition)          
 select @pcBookingCode, @nCounter, @pcCurrency, @pmNominal        
  , @pnProdId, @pcCIF, @pnEmployee, @pnCIFNIK, @pnAgenId, @pnBankId, @pnJnsRek, @pcAccRelasi, @pcRekening        
  , @pcNamaRek, @pnReferentor, 1, 0, getdate(), @pnNIK, null           
  , @cCIFName, @cNISPAccName        
  , @pcInputter, @pnSeller, @pnWaperd, @pbDocRiskProfile, @pbDocTermCondition          
        
 if @@error != 0 or @@rowcount = 0        
 Begin       
  set @cErrMsg = 'Error Insert Data!'        
  goto ERROR        
 End        
    
 set @nNewBookingId = @@identity        
      
        
 if not exists (select top 1 1 from ReksaRiskProfileLastUpdate_TM where CIFNo = @pcCIF)        
 begin        
  
  insert dbo.ReksaRiskProfileLastUpdate_TM (CIFNo, RiskProfileLastUpdate)        
  select @pcCIF, isnull(@pdRiskProfileLastUpdate, @dCurrWorkingDate)        
   
         
  if @@error <> 0        
  begin        
   set @cErrMsg = 'Gagal insert tabel RiskProfileLastUpdate'        
   goto ERROR        
  end         
 end        
       
 else        
 begin        
  update ReksaRiskProfileLastUpdate_TM        
  set RiskProfileLastUpdate = isnull(@pdRiskProfileLastUpdate, @dCurrWorkingDate)        
  where CIFNo = @pcCIF        
         
  if @@error <> 0        
  begin        
   set @cErrMsg = 'Gagal update tabel RiskProfileLastUpdate'        
   goto ERROR        
  end          
 end        
    
 exec @nOK = ReksaSaveConfAddress        
   @nTranType = @pnType        
   ,@pnId  = @nNewBookingId        
   ,@pnType = 0 -- booking        
   ,@pcData = @pcAlamatConf        
   ,@pnNIK = @pnNIK        
   ,@pcGuid = @pcGuid        
        
 if @@error != 0 or @nOK != 0        
 begin        
  set @cErrMsg = 'Gagal Insert Alamat Konfirmasi'        
  goto ERROR        
 end        
        
 commit tran        
      
End         
else if @pnType = 2        
Begin        
 begin transaction        
  insert ReksaBooking_TH(BookingId, BookingCode, BookingCounter, BookingCCY, BookingAmt, ProdId, CIFNo        
    , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NonNISPAccId, NonNISPAccName, Referentor           
    , AuthType, HistoryStatus, LastUpdate, UserSuid, CheckerSuid           
    , CIFName, NISPAccName        
    , Inputter, Seller, Waperd        
    , DocRiskProfile, DocTermCondition)         
  select @pnBookingId, @pcBookingCode, @nCounter, @pcCurrency, @pmNominal        
   , @pnProdId, @pcCIF, @pnEmployee, @pnCIFNIK, @pnAgenId, @pnBankId, @pnJnsRek, @pcAccRelasi, @pcRekening        
   , @pcNamaRek, @pnReferentor, 4, 'Update', getdate(), @pnNIK, null         
   , @cCIFName, @cNISPAccName        
   , @pcInputter, @pnSeller, @pnWaperd        
   , @pbDocRiskProfile, @pbDocTermCondition        
  
  if @@error != 0 or @@rowcount = 0        
  Begin        
   set @cErrMsg = 'Error Request Update Data!'        
   goto ERROR        
  End        
        
  Update ReksaBooking_TM         
  set AuthType = 2        
  where BookingId = @pnBookingId        
        
  if @@error != 0 or @@rowcount = 0        
  Begin        
   set @cErrMsg = 'Error Update Flag Update!'        
   goto ERROR        
  End        
       
  if exists (select top 1 1 from ReksaRiskProfileLastUpdate_TM where CIFNo = @pcCIF)        
  begin        
      
   update ReksaRiskProfileLastUpdate_TM        
   set RiskProfileLastUpdate = isnull(@pdRiskProfileLastUpdate, @dCurrWorkingDate)        
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
   select @pcCIF, isnull(@pdRiskProfileLastUpdate, @dCurrWorkingDate)        
  
          
   if @@error <> 0        
   begin        
    set @cErrMsg = 'Gagal insert tabel RiskProfileLastUpdate'        
    goto ERROR        
   end         
  end          
  
 exec @nOK = ReksaSaveConfAddress        
   @nTranType = @pnType        
   ,@pnId  = @pnBookingId        
   ,@pnType = 0 -- booking        
   ,@pcData = @pcAlamatConf        
   ,@pnNIK = @pnNIK        
   ,@pcGuid = @pcGuid        
        
 if @@error != 0 or @nOK != 0        
 begin        
  set @cErrMsg = 'Gagal Insert Alamat Konfirmasi'        
  goto ERROR        
 end        
   
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
  where BookingId = @pnBookingId        
        
  if @@error != 0 or @@rowcount = 0        
  Begin        
   set @cErrMsg = 'Gagal Update Status jadi Delete!'        
   goto ERROR        
  End        
 commit tran        
End        
  
        
return 0        
        
ERROR:        
if @@trancount > 0         
 rollback tran        
        
if isnull(@cErrMsg ,'') = ''        
 set @cErrMsg = 'Error !'        
        
--exec @nOK = set_raiserror @@procid, @nErrNo output          
--if @nOK != 0 return 1          
          
raiserror ( @cErrMsg        ,16,1);
return 1
GO