CREATE proc [dbo].[ReksaUpdateCIFData]
/*          
 CREATED BY    : Oscar Marino          
 CREATION DATE : 20090701          
 DESCRIPTION   : Sinkronisasi data Client dari CFMAST dkk (ambil data dari CFMAST_v, dkk)          
          
 exec ReksaUpdateCIFData 1          
          
 REVISED BY    :          
 DATE,  USER,   PROJECT,  NOTE          
 -----------------------------------------------------------------------          
 20091019, oscar, REKSADN013, jangan dijalankan          
 20100702, indra_w, BAING10033, sinkronisasi setiap 5 menit          
 20100827, indra_w, BAING10033, tambahan UAT          
 20100922, indra_w, BAING10033, Perbaikan UAT          
 20121128, chendra, ODTJH12006, tambah kolom        
 20150129, Ferry, LIBST13020, ubah cara pengambilan alamat konfirmasi       
 20150818, liliana, LIBST13020, ubah cif cfaddr    
 20160314, sandi, LOGAM07888, sinkronisasi perubahan nama nasabah antara ProCIF dan ProReksa        
 20160829, Elva, LOGEN00196, penambahan rekening tax amnesty  
 20170711, sandi, LOGAM08736, update master nasabah  
 20180726, Lita, BOSOD17054, tambah history address
 20180906, Lita, BOSOD17054, tambah type address
 END REVISED          
*/          
--20100702, indra_w, BAING10033, begin          
 @pbDebug bit = 0          
 ,@pbCIFUpdate bit = 0          
 ,@pxmlData  xml = null          
 ,@pbOutTran  bit = 0          
--20100702, indra_w, BAING10033, end          
as           
set nocount on          
          
--20091019, oscar, REKSADN013, begin          
--declare          
-- @nOK tinyint,          
-- @cErrMsg varchar(100)          
          
--set @nOK = 1          
          
--Declare @CIFList table (          
-- CIFNo char(19)          
--)          
          
--Declare @TempCIF table(            
-- CFCIF   char(19) --            
-- , CIFName  varchar(100) --            
-- , Address1  varchar(40) --            
-- , Address2  varchar(40) --            
-- , Address3  varchar(40) --            
-- , Kota   varchar(25) --            
-- , Propinsi  varchar(40) --            
-- , Negara  varchar(20) --            
-- , NegaraCode varchar(3)  --            
-- , Telepon  varchar(40)              
-- , HP   varchar(40)             
-- , TempatLhr  varchar(30) --            
-- , TglLhr  datetime --            
-- , KTP   varchar(40) --            
-- , NPWP   varchar(40) --            
-- , PostalCode char(5)  --            
-- , JnsNas  int          
-- , IDType char(4    )          
-- , SEX char(1    )          
-- , CTZSHIP varchar(3    )          
-- , RELIGION varchar(3    )            
--)            
          
---- siapkan list CIF          
--if @pbDebug = 0          
-- insert into @CIFList          
-- select distinct right('0000000000000000000' + CIFNo, 19)           
-- from ReksaCIFData_TM          
-- where CIFNo is not null          
--else          
-- insert into @CIFList            
-- select distinct right('0000000000000000000' + a.CIFNo, 19)           
-- from ReksaCIFData_TM a          
-- join CFMAST_v b          
-- on right('0000000000000000000' + CIFNo, 19) = b.CFCIF          
            
---- isi data2 yang ada di CFMAST            
--insert @TempCIF (CFCIF, CIFName, TempatLhr, TglLhr, KTP, Negara, JnsNas)            
--select a.CFCIF, a.CFNA1, a.CFYBIP, a.CFBIR6, a.CFSSNO, upper(b.JHCNAM),            
-- case when a.CFCLAS = 'A' then 1            
--  else 4            
-- end            
--from CFMAST_v a join JHCOUN_v b            
-- on a.CFCOUN = b.JHCCOC            
--join @CIFList c          
-- on a.CFCIF = c.CIFNo          
            
--Update a            
--set NegaraCode = b.JHCCOC            
--from @TempCIF a join JHCOUN_v b            
-- on a.Negara =  b.JHCNAM            
--where b.JHCOD = 'SW'            
            
---- isi alamat berdasarkan tempat tinggal            
--Update a            
--set Address1  = UPPER(CFNA2)            
-- , Address2  = UPPER(CFNA3)            
-- , Address3  = UPPER(CFNA4)            
-- , Propinsi  = upper(CF2PRV)            
-- , PostalCode = CFZIP            
--from @TempCIF a join CFADDR_v b            
--  on a.CFCIF = b.CFCIF            
--where b.CFINVC = 'J'            
            
---- jika tidak ada alamat tempat tinggal, isi dengan yang SEQ 1            
--If @@rowcount = 0            
--Begin            
-- Update a            
-- set Address1  = UPPER(CFNA2)            
--  , Address2  = UPPER(CFNA3)            
--  , Address3  = UPPER(CFNA4)            
--  , Propinsi  = upper(CF2PRV)            
--  , PostalCode = CFZIP            
-- from @TempCIF a join CFADDR_v b            
--   on a.CFCIF = b.CFCIF            
-- where b.CFASEQ = '1'            
--End            
            
---- update nama kota berdasarkan kode pos            
--Update a            
--set Kota = City            
--from  @TempCIF a join SIBSPostalCode_TR_v b            
-- on a.PostalCode = b.PostalCode            
            
---- NPWP            
--Update a            
--set NPWP = CFSSNO            
--from  @TempCIF a join CFAIDN_v b            
-- on a.CFCIF = b.CFCIF            
--where b.CFSSCD = 'NPWP'            
            
----20080205, indra_w, REKSADN002, begin            
---- Telepon            
--if exists(select top 1 1 from @TempCIF where JnsNas = 1)            
--begin            
-- Update a            
-- set Telepon = CFEADD            
-- from  @TempCIF a join CFCONN_v b            
--  on a.CFCIF = b.CFCIF            
-- where b.CFEADC = 'TR'            
            
-- -- HP            
-- Update a            
-- set Telepon = CFEADD            
-- from  @TempCIF a join CFCONN_v b            
--  on a.CFCIF = b.CFCIF            
-- where b.CFEADC = 'HP'            
--end            
--else             
--Begin            
-- Update a            
-- set Telepon = CFEADD            
-- from  @TempCIF a join CFCONN_v b            
--  on a.CFCIF = b.CFCIF            
-- where b.CFEADC = 'TK'            
--end            
          
--update @TempCIF          
--set IDType = isnull(a.CFSSCD,'')          
-- , SEX = isnull(a.CFSEX,'')           
-- , CTZSHIP = case when a.CFCITZ = '000' then 'ID' else isnull(b.JHCCOC,'') end          
-- , RELIGION = case when a.CFRACE = 'ISL' then '001'           
--        when a.CFRACE = 'KAT' then '002'           
--      when a.CFRACE = 'PRO' then '003'           
--      when a.CFRACE = 'BUD' then '004'           
--      when a.CFRACE = 'HIN' then '005'           
--      else ''          
--     end          
--from @TempCIF cif          
--join CFMAST_v a           
-- on cif.CFCIF = a.CFCIF          
--left join JHCOUN_v b          
-- on a.CFCITZ = b.JHCSUB           
          
---- update data di ReksaCIFData_TM          
--begin tran          
          
---- debug          
--if @pbDebug = 1          
-- select top 10 'before', a.* from ReksaCIFData_TM a          
-- join @TempCIF b          
-- on CIFNo = right(b.CFCIF, 13)          
          
--update ReksaCIFData_TM set          
-- CIFName = b.CIFName           
-- , CIFAddress1 = isnull(b.Address1, CIFAddress1)          
-- , CIFAddress2 = isnull(b.Address2, CIFAddress2)          
-- , CIFAddress3 = isnull(b.Address3, CIFAddress3)          
-- , CIFCity = isnull(b.Kota, CIFCity)           
-- , CIFProvince = isnull(b.Propinsi, CIFProvince)          
-- , CIFCountryCode = b.NegaraCode           
-- , CIFTelephone = b.Telepon            
-- , CIFHP = b.HP             
-- , CIFBirthPlace = b.TempatLhr            
-- , CIFBirthDay = b.TglLhr            
-- , CIFIDNo = b.KTP             
-- , CIFNPWP = b.NPWP            
-- , CIFType = isnull(b.JnsNas, CIFType)          
-- , IDType = b.IDType           
-- , SEX = b.SEX           
-- , CTZSHIP = b.CTZSHIP           
-- , RELIGION = b.RELIGION           
--from ReksaCIFData_TM a          
--join @TempCIF b          
--on a.CIFNo = right(b.CFCIF, 13)          
          
--if @@error <> 0          
--begin          
-- set @cErrMsg = 'Gagal update data CIF'          
-- goto ERR_HANDLER          
--end           
          
---- debug          
--if @pbDebug = 1          
-- select top 10 'after', a.* from ReksaCIFData_TM a          
-- join @TempCIF b          
-- on CIFNo = right(b.CFCIF, 13)          
           
--commit tran           
           
--ERR_HANDLER:          
--if isnull(@cErrMsg, '') <> ''          
--begin          
-- if @@trancount > 0 rollback tran          
-- raiserror 50000 @cErrMsg          
-- set @nOK = 1          
--end          
          
--return @nOK          
--20091019, oscar, REKSADN013, end          
--20100702, indra_w, BAING10033, begin          
declare  @cErrMsg    varchar(100)          
   ,@nErrno    int          
   ,@nOK     int          
   ,@cTableName   varchar(50)          
   ,@cCIFNo    varchar(19)          
   ,@nId    int          
   ,@nDataType   tinyint          
   ,@nAddrSeqNo  int          
   ,@dLastProcess  datetime          
   ,@dLastUnapproved datetime          
   ,@dUpdateDate  datetime          
   ,@cTelType   char(2)          
   ,@cAddIDType  char(4)          
   ,@bChangeBit  bit      
--20150818, liliana, LIBST13020, begin      
 ,@bCIFNo bigint      
--20150818, liliana, LIBST13020, end              
--20180726, Lita, BOSOD17054, begin
, @bIsCorrAddress	bit

set @bIsCorrAddress = 0
--20180726, Lita, BOSOD17054, end
          
if @pbCIFUpdate = 1          
Begin          
 if ltrim(convert(varchar(max),@pxmlData)) = ''          
  return 0          
          
 select @dLastProcess = PrevLastRun          
 from ReksaUserProcess_TR          
 where ProcessId = 1          
          
 select @cTableName = ltrim(@pxmlData.value('(/Root/DATA/Type)[1]','varchar(50)'))          
 select @cCIFNo = right('0000000000000000000'+ltrim(@pxmlData.value('(/Root/DATA/CFCIF)[1]','varchar(13)')), 19)          
--20150818, liliana, LIBST13020, begin      
 select @bCIFNo = convert(bigint,@cCIFNo)      
--20150818, liliana, LIBST13020, end       
          
 if ltrim(rtrim(@cTableName)) = 'CFADDR'          
 Begin          
  select @nAddrSeqNo = @pxmlData.value('(/Root/DATA/CFASEQ)[1]','int')          
      
--20150818, liliana, LIBST13020, begin          
  --select right('0000000000000000000'+T1.t.value('./CFCIF[1]','varchar(19)'),19) as CFCIF#       
  select convert(bigint,T1.t.value('./CFCIF[1]','varchar(19)')) as CFCIF#        
--20150818, liliana, LIBST13020, end           
    ,T1.t.value('./CFASEQ[1]','int') as CFASEQ           
    ,T1.t.value('./CFNA2[1]','varchar(40)') as AddressLine1           
    ,T1.t.value('./CFNA3[1]','varchar(40)') as AddressLine2           
    ,T1.t.value('./CFNA4[1]','varchar(40)') as AddressLine3          
    , T1.t.value('./CFNA5[1]','varchar(40)') as AddressLine4          
    , T1.t.value('./CFZIP[1]','varchar(9)') as ZIPCode          
    , T1.t.value('./CFFORN[1]','varchar(1)') as ForeignAddr          
    , T1.t.value('./CFADSC[1]','varchar(20)') as Description          
    , T1.t.value('./CFUSE[1]','varchar(1)') as AlamatUtama          
    , T1.t.value('./CFINVC[1]','varchar(1)') as KodeAlamat          
    , T1.t.value('./CFMAIL[1]','varchar(1)') as AlamatSID          
    , T1.t.value('./CFAYRS[1]','varchar(3)') as PeriodThere          
    , T1.t.value('./CFAYRC[1]','varchar(1)') as PeriodThereCode          
    , T1.t.value('./CFAPTY[1]','varchar(5)') as JenisAlamat          
    , T1.t.value('./CFSTSN[1]','varchar(5)') as StaySince          
    , T1.t.value('./CF2KEL[1]','varchar(40)') as Kelurahan          
    , T1.t.value('./CF2KEC[1]','varchar(40)') as Kecamatan          
    ,T1.t.value('./CF2DT2[1]','varchar(40)') as Dati2           
    ,T1.t.value('./CF2PRV[1]','varchar(40)') as Provinsi           
, T1.t.value('./CFCDDT[1]','varchar(5)') as KodeDati2          
  into #tempADDR          
  from @pxmlData.nodes('/Root/DATA') T1(t)            
               
  if @@error != 0          
  begin          
   set @cErrMsg = 'Error Prepare Data (CFADDR)'          
   goto ERROR_HANDLER          
  end           
   
--20180726, Lita, BOSOD17054, begin
	
	if exists(select top 1 1            
       from ReksaCIFConfirmAddr_TM a join #tempADDR b          
        on a.CIFNo = b.CFCIF#          
         and a.AddressSeq = b.CFASEQ          
       where (ltrim(rtrim(isnull(a.AddressLine1,''))) != ltrim(rtrim(b.AddressLine1))       
          or ltrim(rtrim(isnull(a.AddressLine2,''))) != ltrim(rtrim(b.AddressLine2))          
          or ltrim(rtrim(isnull(a.AddressLine3,''))) != ltrim(rtrim(b.AddressLine3))          
          or ltrim(rtrim(isnull(a.Dati2,''))) != ltrim(rtrim(b.Dati2))          
          or ltrim(rtrim(isnull(a.Provinsi,''))) != ltrim(rtrim(b.Provinsi))          
         )                  
         and a.DataType = 2          
       )
	begin
	   set @bIsCorrAddress = 1
	end        

--20180906, Lita, BOSOD17054, begin
	--if exists(select top 1 1 from #tempADDR where KodeAlamat = 'S') -- alamat sesuai KTP
	if exists(select top 1 1 from #tempADDR where KodeAlamat IN ('S', 'J')) -- alamat sesuai KTP
--20180906, Lita, BOSOD17054, end
		or @bIsCorrAddress = 1
	begin
		--insert history	
		insert into ReksaCIFHistory_TH (TableName, CIFNo, CIFName, CIFAddress1, CIFAddress2, CIFAddress3, CIFAddress4
							  , CIFKel, CIFKec, CIFCity, CIFProvince, CIFZipCode, CIFForeignAddress, CIFCFINV, CIFAddressSeq
							  , LastUpdate, DataStatus, isCorrAddress)                
		select distinct ltrim(rtrim(@cTableName)), addr.CFCIF#, rmn.CIFName, cf.CFNA2, cf.CFNA3, cf.CFNA4, cf.CFNA5
						, cf.CF2KEL, cf.CF2KEC, cf.CF2DT2, cf.CF2PRV, cf.CFZIP, cf.CFFORN, cf.CFINVC, cf.CFASEQ
						, getdate(), 'OLD', @bIsCorrAddress
		from #tempADDR addr join dbo.ReksaMasterNasabah_TM rmn
		on addr.CFCIF# = convert(bigint, rmn.CIFNo) and rmn.ApprovalStatus = 'A'
		left join dbo.CFADDR_v cf
		on addr.CFCIF# = convert(bigint, cf.CFCIF) and addr.CFASEQ = cf.CFASEQ 
		         
		if @@error != 0          
		begin          
			set @cErrMsg = 'Error Insert Data Old Reksa (CFADDR ReksaCIFHistory_TH)'          
			goto ERROR_HANDLER          
		end           

		-- insert  updated value
		insert ReksaCIFHistory_TH (TableName, CIFNo, CIFName, CIFAddress1, CIFAddress2, CIFAddress3, CIFAddress4
							  , CIFKel, CIFKec, CIFCity, CIFProvince, CIFZipCode, CIFForeignAddress, CIFCFINV, CIFAddressSeq
							  , LastUpdate, DataStatus, isCorrAddress)                
		select distinct ltrim(rtrim(@cTableName)), addr.CFCIF#, rmn.CIFName, addr.AddressLine1, addr.AddressLine2, addr.AddressLine3, addr.AddressLine4
						, addr.Kelurahan, addr.Kecamatan, addr.Dati2, addr.Provinsi, addr.ZIPCode, addr.ForeignAddr, addr.KodeAlamat, addr.CFASEQ 
						, getdate(), 'NEW', @bIsCorrAddress
		from #tempADDR addr join dbo.ReksaMasterNasabah_TM rmn 
		on addr.CFCIF# = convert(bigint, rmn.CIFNo) and rmn.ApprovalStatus = 'A' 

		if @@error != 0          
		begin          
			set @cErrMsg = 'Error Insert Data Old Reksa (CFADDR ReksaCIFHistory_TH)'          
			goto ERROR_HANDLER          
		end       
	end
--20180726, Lita, BOSOD17054, end

  declare sinkron_cur cursor local fast_forward for           
   select Id, DataType          
   from ReksaCIFConfirmAddr_TM          
--20150818, liliana, LIBST13020, begin      
   --where CIFNo = @cCIFNo      
 where CIFNo = @bCIFNo      
--20150818, liliana, LIBST13020, end              
    and AddressType = 0          
    and AddressSeq = @nAddrSeqNo          
   order by Id          
  open sinkron_cur           
          
  while 1=1          
  begin          
   fetch sinkron_cur into @nId, @nDataType             
   if @@fetch_status!=0 break          
           
   set @bChangeBit = 0          
          
   select @dUpdateDate = getdate()          
          
   if @pbOutTran = 0  
    begin tran          
          
--20150129, Ferry, LIBST13020, begin      
   --if @nDataType = 1          
   if @nDataType = 2      
--20150129, Ferry, LIBST13020, end      
   Begin          
    if exists(select top 1 1            
       from ReksaCIFConfirmAddr_TM a join #tempADDR b          
        on a.CIFNo = b.CFCIF#          
         and a.AddressSeq = b.CFASEQ          
       where (ltrim(rtrim(isnull(a.AddressLine1,''))) != ltrim(rtrim(b.AddressLine1))       
          or ltrim(rtrim(isnull(a.AddressLine2,''))) != ltrim(rtrim(b.AddressLine2))          
          or ltrim(rtrim(isnull(a.AddressLine3,''))) != ltrim(rtrim(b.AddressLine3))          
          or ltrim(rtrim(isnull(a.Dati2,''))) != ltrim(rtrim(b.Dati2))          
          or ltrim(rtrim(isnull(a.Provinsi,''))) != ltrim(rtrim(b.Provinsi))          
         )          
         and a.Id =  @nId          
         and a.DataType = @nDataType          
       )          
    Begin          
     set @bChangeBit = 1          
                
     insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
       , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
       , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
       , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
       , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
       , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
       , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end               
     select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
       , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
       , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
       , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
       , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
       , 2, 'Old', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
       , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, b.AddressLine1, b.AddressLine2          
       , b.AddressLine3, b.Dati2, b.Provinsi, @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType        
--20121128, chendra, ODTJH12006, end               
--20150129, Ferry, LIBST13020, begin      
     --from ReksaCIFData_TM a join ReksaCIFConfirmAddr_TM b          
       --on a.ClientId = b.Id          
    from dbo.ReksaCIFData_TM a       
 join dbo.ReksaMasterNasabah_TM rmn       
  on a.CIFNo = rmn.CIFNo      
 join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
--20150129, Ferry, LIBST13020, end      
--20170711, sandi, LOGAM08736, begin     
     --where a.ClientId = @nId
     where rmn.NasabahId = @nId           
--20170711, sandi, LOGAM08736, end     
       and b.DataType = @nDataType and b.AddressType = 0                       
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data Old Reksa (CFADDR)'          
      goto ERROR_HANDLER          
     end           
    End          
   End          
          
   update a      
   set   AddressLine1 = b.AddressLine1     
    , AddressLine2 = b.AddressLine2          
    , AddressLine3 = b.AddressLine3          
    , AddressLine4 = b.AddressLine4          
    , ZIPCode  = b.ZIPCode          
    , ForeignAddr = b.ForeignAddr          
    , Description = b.Description          
    , AlamatUtama = b.AlamatUtama          
    , KodeAlamat = b.KodeAlamat          
    , AlamatSID  = b.AlamatSID          
    , PeriodThere = b.PeriodThere          
    , PeriodThereCode= b.PeriodThereCode          
    , JenisAlamat = b.JenisAlamat          
    , StaySince  = b.StaySince          
    , Kelurahan  = b.Kelurahan          
    , Kecamatan  = b.Kecamatan          
    , Dati2   = b.Dati2          
    , Provinsi  = b.Provinsi          
    , KodeDati2  = b.KodeDati2          
   from ReksaCIFConfirmAddr_TM a , #tempADDR b          
   where a.Id = @nId          
    and a.DataType = @nDataType          
    and a.AddressType = 0          
          
   if @@error != 0          
   begin          
    set @cErrMsg = 'Error Update Address Confirmasi'          
    goto ERROR_HANDLER          
   end           
          
--20150129, Ferry, LIBST13020, begin          
   --if @nDataType = 1 and @bChangeBit = 1          
   if @nDataType = 2 and @bChangeBit = 1      
--20150129, Ferry, LIBST13020, end      
   Begin          
    -- insert yang new          
    insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
      , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
      , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
      , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
      , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
      , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
      , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end         
    select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
      , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
      , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
      , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
      , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
      , 2, 'Updated', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
      , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, b.AddressLine1, b.AddressLine2          
      , b.AddressLine3, b.Dati2, b.Provinsi, @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType        
--20121128, chendra, ODTJH12006, end                     
--20150129, Ferry, LIBST13020, begin      
    --from ReksaCIFData_TM a join ReksaCIFConfirmAddr_TM b          
    --  on a.ClientId = b.Id          
    --where a.ClientId = @nId         
    from dbo.ReksaCIFData_TM a      
    join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
 join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
 where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end       
      and b.DataType = @nDataType and b.AddressType = 0           
          
    if @@error != 0          
    begin          
     set @cErrMsg = 'Error Insert Data New Reksa (CFADDR)'          
     goto ERROR_HANDLER          
    end           
         
    if exists(select top 1 1 from ReksaCIFData_TH where ClientId = @nId           
       and AuthType = 4 and LastUpdate > @dLastProcess)          
    Begin          
     update ReksaCIFData_TH          
     set CIFConfAddress1     = b.AddressLine1          
      ,CIFConfAddress2    = b.AddressLine2          
      ,CIFConfAddress3    = b.AddressLine3          
      ,CIFConfCity        = b.Dati2          
      ,CIFConfProvince    = b.Provinsi          
      ,ActualChangeDate   = a.LastUpdate          
      ,LastUpdate   = @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
   ,CIFConfZipCode = b.ZIPCode        
   ,CIFConfAddress4 = b.AddressLine4        
   ,CIFConfKelurahan = b.Kelurahan        
   ,CIFConfKecamatan = b.Kecamatan        
   ,AddressType = b.AddressType        
--20121128, chendra, ODTJH12006, end               
--20150129, Ferry, LIBST13020, begin      
     --from ReksaCIFData_TH a join ReksaCIFConfirmAddr_TM b          
     --  on a.ClientId = b.Id          
     --where a.ClientId = @nId          
     from dbo.ReksaCIFData_TH a      
     join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
  join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
--20150129, Ferry, LIBST13020, end      
      and b.DataType = @nDataType and b.AddressType = 0           
      and a.AuthType = 4           
      and a.LastUpdate > @dLastProcess          
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data Old Reksa (CFADDR)'          
      goto ERROR_HANDLER          
     end           
    End          
   end          
          
   if @pbOutTran = 0          
    commit tran          
  end          
          
  close sinkron_cur          
  deallocate sinkron_cur          
          
  drop table #tempADDR          
 End          
 if @cTableName = 'CFMAST'          
 Begin          
  select right('0000000000000'+T1.t.value('./CFCIF[1]','varchar(19)'),13) as CFCIF#           
    ,T1.t.value('./CFSSCD[1]','char(4)') as IDType          
    ,T1.t.value('./CFSSNO[1]','varchar(40)') as CIFIDNo           
    ,T1.t.value('./CFSEX[1]','char(1)') as SEX          
    ,T1.t.value('./CFRACE[1]','char(3)') as RELIGION          
--20100827, indra_w, BAING10033, begin          
    ,T1.t.value('./CFBIR6[1]','Datetime') as CFBIR6          
--20100827, indra_w, BAING10033, end          
  into #tempCFMAST          
  from @pxmlData.nodes('/Root/DATA') T1(t)          
          
  if @@error != 0          
  begin          
   set @cErrMsg = 'Error Prepare Data (CFMAST)'          
   goto ERROR_HANDLER          
  end           
            
  declare sinkron_cur cursor local fast_forward for           
   select ClientId          
   from ReksaCIFData_TM          
   where CIFNo = right(@cCIFNo,13)          
   order by ClientId          
  open sinkron_cur           
          
  while 1=1          
  begin          
   fetch sinkron_cur into @nId          
   if @@fetch_status!=0 break          
          
   select @dUpdateDate = getdate()          
          
   if @pbOutTran = 0          
    begin tran          
          
   if exists(select top 1 1            
      from ReksaCIFData_TM a join #tempCFMAST b          
       on a.CIFNo = b.CFCIF#          
      where (ltrim(rtrim(isnull(a.IDType,''))) != ltrim(rtrim(b.IDType))          
         or ltrim(rtrim(isnull(a.CIFIDNo,''))) != ltrim(rtrim(b.CIFIDNo))          
         or ltrim(rtrim(isnull(a.SEX,''))) != ltrim(rtrim(b.SEX))          
         or ltrim(rtrim(isnull(a.RELIGION,''))) != ltrim(rtrim(b.RELIGION))          
--20100922, indra_w, BAING10033, begin          
         or isnull(a.CIFBirthDay,'19000101') != isnull(b.CFBIR6, '19000101')          
--20100922, indra_w, BAING10033, end          
        )          
       and a.ClientId = @nId          
      )          
   Begin          
    -- insert yang old          
    insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
      , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
      , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
      , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
      , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
      , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
      , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end               
    select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
      , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
      , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
      , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
      , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
      , 2, 'Old', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
      , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(b.AddressLine1, a.CIFAddress1)          
      , isnull(b.AddressLine2, a.CIFAddress2)          
      , isnull(b.AddressLine3, a.CIFAddress3)          
      , isnull(b.Dati2, a.CIFCity)          
      , isnull(b.Provinsi, a.CIFProvince)          
      , @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType        
--20121128, chendra, ODTJH12006, end                
--20150129, Ferry, LIBST13020, begin      
    --from ReksaCIFData_TM a left join ReksaCIFConfirmAddr_TM b          
    --  on a.ClientId = b.Id          
    --   and b.DataType = 1          
    --where a.ClientId = @nId          
    from dbo.ReksaCIFData_TM a      
    join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
 join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
   and DataType = 2      
 where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end      
                
    if @@error != 0          
    begin         
     set @cErrMsg = 'Error Insert Data Old Reksa (CFMAST)'          
     goto ERROR_HANDLER          
    end           
          
    -- insert yang new          
    insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
      , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
      , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
      , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
      , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
      , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
      , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end                  
    select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
      , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
--20100827, indra_w, BAING10033, begin          
--      , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, b.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
      , a.CIFHP, a.CIFBirthPlace, b.CFBIR6, b.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
--20100827, indra_w, BAING10033, end          
      , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
      , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
      , 2, 'Updated', b.IDType, b.SEX, a.CTZSHIP          
      , case b.RELIGION when 'ISL' then '001'           
          when 'KAT' then '002'           
          when 'PRO' then '003'           
          when 'BUD' then '004'           
          when 'HIN' then '005'           
          else ''          
      end          
      , a.DocRiskProfile          
      , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(c.AddressLine1, a.CIFAddress1)          
      , isnull(c.AddressLine2, a.CIFAddress2)          
      , isnull(c.AddressLine3, a.CIFAddress3)          
      , isnull(c.Dati2, a.CIFCity)          
      , isnull(c.Provinsi, a.CIFProvince)          
      , @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , c.ZIPCode, c.AddressLine4, c.Kelurahan, c.Kecamatan, c.AddressType        
--20121128, chendra, ODTJH12006, end                 
    from ReksaCIFData_TM a join #tempCFMAST b          
       on a.CIFNo = b.CFCIF#          
--20150129, Ferry, LIBST13020, begin      
    --  left join ReksaCIFConfirmAddr_TM c          
    --   on a.ClientId = c.Id          
    --    and c.DataType = 1          
    --where a.ClientId = @nId          
    join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
 left join dbo.ReksaCIFConfirmAddr_TM c      
  on rmn.NasabahId = c.Id      
   and c.DataType = 2      
 where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end      
          
    if @@error != 0          
    begin          
     set @cErrMsg = 'Error Insert Data New Reksa (CFMAST)'          
     goto ERROR_HANDLER          
    end           
          
    update a          
    set IDType  = b.IDType          
     ,CIFIDNo    = b.CIFIDNo          
     ,SEX  = b.SEX         
     ,RELIGION   = case b.RELIGION when 'ISL' then '001'           
         when 'KAT' then '002'           
         when 'PRO' then '003'           
         when 'BUD' then '004'           
         when 'HIN' then '005'           
         else ''          
        end          
--20100827, indra_w, BAING10033, begin          
     ,CIFBirthDay = b.CFBIR6          
--20100827, indra_w, BAING10033, end          
     ,LastUpdate   = @dUpdateDate          
    from ReksaCIFData_TM a, #tempCFMAST b          
    where a.ClientId = @nId          
          
    if @@error != 0          
    begin          
     set @cErrMsg = 'Error Update Data Master (CFMAST)'          
     goto ERROR_HANDLER          
    end
--20170711, sandi, LOGAM08736, begin    
    update a          
    set a.CIFBirthDay = b.CFBIR6, 
        a.LastUpdate  = @dUpdateDate          
    from ReksaMasterNasabah_TM a 
    join #tempCFMAST b
        on a.CIFNo = b.CFCIF#        
          
    if @@error != 0          
    begin          
     set @cErrMsg = 'Error Update Data Master Nasabah (CFMAST)'          
     goto ERROR_HANDLER          
    end 
--20170711, sandi, LOGAM08736, end               
          
    if exists(select top 1 1 from ReksaCIFData_TH where ClientId = @nId           
       and AuthType = 4 and LastUpdate > @dLastProcess)          
    Begin          
     update a          
     set IDType  = b.IDType          
      ,CIFIDNo    = b.CIFIDNo          
      ,SEX  = b.SEX          
      ,RELIGION   = case b.RELIGION when 'ISL' then '001'           
          when 'KAT' then '002'           
          when 'PRO' then '003'           
          when 'BUD' then '004'           
          when 'HIN' then '005'           
          else ''          
         end          
--20100827, indra_w, BAING10033, begin          
      ,CIFBirthDay = b.CFBIR6          
--20100827, indra_w, BAING10033, end          
      ,ActualChangeDate   = a.LastUpdate          
      ,LastUpdate   = @dUpdateDate          
     from ReksaCIFData_TH a, #tempCFMAST b          
     where a.ClientId = @nId          
      and a.AuthType = 4           
      and a.LastUpdate > @dLastProcess          
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data Old Reksa (CFADDR)'          
      goto ERROR_HANDLER          
     end           
    End          
   End          
          
   if @pbOutTran = 0          
    commit tran          
  end          
          
  close sinkron_cur          
  deallocate sinkron_cur          
          
  drop table #tempCFMAST          
 End          
 if @cTableName = 'CFCONN'          
 Begin          
  select @cTelType = @pxmlData.value('(/Root/DATA/CFEADC)[1]','char(2)')          
          
  if @cTelType in ('TR','HP','TK')          
  Begin          
   select right('0000000000000'+T1.t.value('./CFCIF[1]','varchar(19)'),13) as CFCIF#           
     ,T1.t.value('./CFEADC[1]','char(2)') as CFEADC          
     ,T1.t.value('./CFEADD[1]','varchar(40)') as CFEADD           
          
   into #tempCFCONN          
   from @pxmlData.nodes('/Root/DATA') T1(t)          
          
   if @@error != 0          
   begin          
    set @cErrMsg = 'Error Prepare Data (CFCONN)'          
    goto ERROR_HANDLER          
   end           
          
   declare sinkron_cur cursor local fast_forward for           
    select ClientId          
    from ReksaCIFData_TM          
    where CIFNo = right(@cCIFNo,13)          
    order by ClientId          
   open sinkron_cur           
          
   while 1=1          
   begin          
    fetch sinkron_cur into @nId          
    if @@fetch_status!=0 break          
          
    select @dUpdateDate = getdate()          
          
    if @pbOutTran = 0        
     begin tran          
          
    if exists(select top 1 1            
       from ReksaCIFData_TM a join #tempCFCONN b          
        on a.CIFNo = b.CFCIF#          
       where (ltrim(rtrim(case when a.CIFType = 1 and @cTelType = 'TR' then isnull(a.CIFTelephone,'')          
          when a.CIFType = 4 and @cTelType = 'TK' then isnull(a.CIFTelephone,'')          
         end)) != ltrim(rtrim(b.CFEADD)))          
        or (ltrim(rtrim(case when @cTelType = 'HP' then isnull(a.CIFHP,'') end)) != ltrim(rtrim(b.CFEADD)))          
      )          
    Begin          
     -- insert yang old          
     insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
       , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
       , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
       , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
       , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
       , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
       , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end                
     select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
       , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
       , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
       , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
       , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
       , 2, 'Old', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
       , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(b.AddressLine1, a.CIFAddress1)          
       , isnull(b.AddressLine2, a.CIFAddress2)          
       , isnull(b.AddressLine3, a.CIFAddress3)          
       , isnull(b.Dati2, a.CIFCity)          
       , isnull(b.Provinsi, a.CIFProvince)          
       , @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType        
--20121128, chendra, ODTJH12006, end                  
--20150129, Ferry, LIBST13020, begin      
     --from ReksaCIFData_TM a left join ReksaCIFConfirmAddr_TM b          
     --  on a.ClientId = b.Id          
     --   and b.DataType = 1          
     --where a.ClientId = @nId          
     from dbo.ReksaCIFData_TM a      
     join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
  join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
   and b.DataType = 2      
  where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end      
                 
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data Old Reksa (CFMAST)'          
      goto ERROR_HANDLER          
     end           
               
     -- insert yang new          
     insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
       , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
       , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
       , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
       , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
       , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
       , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end               
     select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
       , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode          
       ,case when a.CIFType = 1 and @cTelType = 'TR' then b.CFEADD          
        when a.CIFType = 4 and @cTelType = 'TK' then b.CFEADD          
        else a.CIFTelephone          
       end          
       ,case when @cTelType = 'HP' then b.CFEADD          
        else a.CIFHP          
       end          
       , a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
       , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
       , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
       , 2, 'Updated', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
       , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(c.AddressLine1, a.CIFAddress1)          
       , isnull(c.AddressLine2, a.CIFAddress2)          
       , isnull(c.AddressLine3, a.CIFAddress3)          
       , isnull(c.Dati2, a.CIFCity)          
       , isnull(c.Provinsi, a.CIFProvince)          
       , @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , c.ZIPCode, c.AddressLine4, c.Kelurahan, c.Kecamatan, c.AddressType        
--20121128, chendra, ODTJH12006, end                    
--20150129, Ferry, LIBST13020, begin      
     --from ReksaCIFData_TM a join #tempCFCONN b          
     --   on a.CIFNo = b.CFCIF#          
     --  left join ReksaCIFConfirmAddr_TM c          
     --   on a.ClientId = c.Id          
     --    and c.DataType = 1          
     --where a.ClientId = @nId          
     from dbo.ReksaCIFData_TM a      
     join #tempCFCONN b      
  on a.CIFNo = b.CFCIF#      
join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
  left join ReksaCIFConfirmAddr_TM c      
  on rmn.NasabahId = c.Id      
   and DataType = 2      
  where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end      
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data New Reksa (CFMAST)'          
      goto ERROR_HANDLER          
     end           
          
     update a          
     set CIFTelephone = case when a.CIFType = 1 and @cTelType = 'TR' then b.CFEADD          
           when a.CIFType = 4 and @cTelType = 'TK' then b.CFEADD          
           else a.CIFTelephone          
          end          
      ,CIFHP = case when @cTelType = 'HP' then b.CFEADD          
         else a.CIFHP          
        end          
      ,LastUpdate   = @dUpdateDate          
     from ReksaCIFData_TM a, #tempCFCONN b          
     where a.ClientId = @nId          
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Update Data master (CFCONN)'          
      goto ERROR_HANDLER          
     end           
          
     if exists(select top 1 1 from ReksaCIFData_TH where ClientId = @nId           
        and AuthType = 4 and LastUpdate > @dLastProcess)          
     Begin          
      update a          
      set CIFTelephone = case when a.CIFType = 1 and @cTelType = 'TR' then b.CFEADD          
            when a.CIFType = 4 and @cTelType = 'TK' then b.CFEADD          
            else a.CIFTelephone          
           end          
       ,CIFHP = case when @cTelType = 'HP' then b.CFEADD          
          else a.CIFHP          
         end          
       ,ActualChangeDate   = a.LastUpdate          
       ,LastUpdate   = @dUpdateDate          
      from ReksaCIFData_TH a, #tempCFCONN b          
      where a.ClientId = @nId          
 and a.AuthType = 4           
       and a.LastUpdate > @dLastProcess          
          
      if @@error != 0          
      begin          
       set @cErrMsg = 'Error Update Data Perubahan Reksa (CFCONN)'          
       goto ERROR_HANDLER          
      end           
     End          
    End          
          
    if @pbOutTran = 0          
     commit tran           
   end          
          
   close sinkron_cur          
   deallocate sinkron_cur          
          
   drop table #tempCFCONN     
  end          
 End          
 if @cTableName = 'CFAIDN'          
 Begin          
          
  select @cAddIDType = @pxmlData.value('(/Root/DATA/CFSSCD)[1]','char(4)')          
          
  if @cAddIDType = 'NPWP'          
  Begin          
   select right('0000000000000'+T1.t.value('./CFCIF[1]','varchar(19)'),13) as CFCIF#           
     ,T1.t.value('./CFSSCD[1]','char(4)') as CFSSCD          
     ,T1.t.value('./CFSSNO[1]','varchar(40)') as CFSSNO           
   into #tempCFAIDN          
   from @pxmlData.nodes('/Root/DATA') T1(t)          
          
   if @@error != 0          
   begin          
    set @cErrMsg = 'Error Prepare Data (CFAIDN)'          
    goto ERROR_HANDLER          
   end           
          
   declare sinkron_cur cursor local fast_forward for           
    select ClientId          
    from ReksaCIFData_TM          
    where CIFNo = right(@cCIFNo,13)          
    order by ClientId          
   open sinkron_cur           
          
   while 1=1          
   begin          
    fetch sinkron_cur into @nId          
    if @@fetch_status!=0 break          
          
    select @dUpdateDate = getdate()          
          
    if @pbOutTran = 0          
     begin tran          
          
    if exists(select top 1 1            
       from ReksaCIFData_TM a join #tempCFAIDN b          
        on a.CIFNo = b.CFCIF#          
       where (ltrim(rtrim(isnull(a.CIFNPWP,''))) != ltrim(rtrim(b.CFSSNO)))          
      )          
    Begin          
     -- insert yang old          
     insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
       , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
       , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus        
       , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
       , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
       , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
       , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end                 
     select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
       , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
       , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
       , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
       , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
       , 2, 'Old', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
       , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(b.AddressLine1, a.CIFAddress1)          
       , isnull(b.AddressLine2, a.CIFAddress2)          
       , isnull(b.AddressLine3, a.CIFAddress3)          
       , isnull(b.Dati2, a.CIFCity)          
       , isnull(b.Provinsi, a.CIFProvince)          
       , @dUpdateDate          
--20121128, chendra, ODTJH12006, begin               
    , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType        
--20121128, chendra, ODTJH12006, end          
--20150129, Ferry, LIBST13020, begin       
     --from ReksaCIFData_TM a left join ReksaCIFConfirmAddr_TM b          
     --  on a.ClientId = b.Id          
     --   and b.DataType = 1          
     --where a.ClientId = @nId          
     from dbo.ReksaCIFData_TM a      
     join dbo.ReksaMasterNasabah_TM rmn      
  on a.CIFNo = rmn.CIFNo      
  left join dbo.ReksaCIFConfirmAddr_TM b      
  on rmn.NasabahId = b.Id      
   and b.DataType = 2      
  where rmn.NasabahId = @nId      
--20150129, Ferry, LIBST13020, end      
                 
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data Old Reksa (CFAIDN)'          
      goto ERROR_HANDLER          
     end           
               
     -- insert yang new          
     insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
       , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
       , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
       , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
       , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
       , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
       , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
--20121128, chendra, ODTJH12006, begin               
--       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate)          
       , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
       , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
       )        
--20121128, chendra, ODTJH12006, end                 
     select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
       , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
       , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, b.CFSSNO, a.CIFType, a.CIFStatus          
       , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
       , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
       , 2, 'Updated', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
       , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(c.AddressLine1, a.CIFAddress1)          
       , isnull(c.AddressLine2, a.CIFAddress2)          
       , isnull(c.AddressLine3, a.CIFAddress3)          
       , isnull(c.Dati2, a.CIFCity)          
       , isnull(c.Provinsi, a.CIFProvince)          
       , @dUpdateDate        
--20121128, chendra, ODTJH12006, begin               
    , c.ZIPCode, c.AddressLine4, c.Kelurahan, c.Kecamatan, c.AddressType        
--20121128, chendra, ODTJH12006, end                   
     from ReksaCIFData_TM a join #tempCFAIDN b          
        on a.CIFNo = b.CFCIF#          
--20150129, Ferry, LIBST13020, begin      
  join dbo.ReksaMasterNasabah_TM rmn      
     on a.CIFNo = rmn.CIFNo      
--20150129, Ferry, LIBST13020, end      
       left join ReksaCIFConfirmAddr_TM c          
--20150129, Ferry, LIBST13020, begin      
        --on a.ClientId = c.Id          
        -- and c.DataType = 1      
        on rmn.NasabahId = c.Id      
   and c.DataType = 2      
--20150129, Ferry, LIBST13020, end          
     where a.ClientId = @nId          
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Insert Data New Reksa (CFAIDN)'          
      goto ERROR_HANDLER          
     end           
          
     update a          
     set CIFNPWP = b.CFSSNO          
      ,LastUpdate   = @dUpdateDate          
     from ReksaCIFData_TM a, #tempCFAIDN b         
     where a.ClientId = @nId          
          
     if @@error != 0          
     begin          
      set @cErrMsg = 'Error Update Data Master (CFAIDN)'        
      goto ERROR_HANDLER          
     end           
          
     if exists(select top 1 1 from ReksaCIFData_TH where ClientId = @nId           
        and AuthType = 4 and LastUpdate > @dLastProcess)          
     Begin          
      update a          
      set CIFNPWP = b.CFSSNO          
       ,ActualChangeDate   = a.LastUpdate          
       ,LastUpdate   = @dUpdateDate          
      from ReksaCIFData_TH a, #tempCFAIDN b          
      where a.ClientId = @nId          
       and a.AuthType = 4           
       and a.LastUpdate > @dLastProcess          
          
      if @@error != 0          
      begin          
       set @cErrMsg = 'Error Update Data Perubahan Reksa (CFAIDN)'          
       goto ERROR_HANDLER          
      end           
     End          
    End          
          
    if @pbOutTran = 0          
     commit tran          
   end          
          
   close sinkron_cur          
   deallocate sinkron_cur          
          
   drop table #tempCFAIDN          
  end          
 End     
--20160314, sandi, LOGAM07888, begin     
    if @cTableName = 'CFNAME'          
    Begin          
        select right('0000000000000'+T1.t.value('./CFCIF[1]','varchar(19)'),13) as CFCIF#           
        ,T1.t.value('./CFYTIB[1]','char(15)') as CFYTIB          
        ,T1.t.value('./CFNA1[1]','varchar(40)') as CFNA1           
        ,T1.t.value('./CFNA1A[1]','varchar(40)') as CFNA1A          
        ,T1.t.value('./CFYTIA[1]','char(15)') as CFYTIA          
        into #tempCFNAME          
        from @pxmlData.nodes('/Root/DATA') T1(t)          
    
        if @@error != 0          
        begin          
            set @cErrMsg = 'Error Prepare Data (CFNAME)'          
            goto ERROR_HANDLER          
        end           
    
        declare sinkron_cur cursor local fast_forward for           
        select ClientId          
        from ReksaCIFData_TM          
        where CIFNo = right(@cCIFNo,13)          
        order by ClientId          
        open sinkron_cur           
    
        while 1=1          
        begin          
            fetch sinkron_cur into @nId          
            if @@fetch_status!=0 break          
    
            select @dUpdateDate = getdate()          
    
            if @pbOutTran = 0          
            begin tran          
    
            if exists(select top 1 1            
            from ReksaCIFData_TM a join #tempCFNAME b          
            on a.CIFNo = b.CFCIF#          
            where (ltrim(rtrim(isnull(a.CIFName,''))) != ltrim(rtrim(b.CFNA1)))          
            and a.ClientId = @nId          
            )          
            Begin          
                -- insert yang old          
                insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
                , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
                , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
                , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
                , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
                , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
                , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2          
                , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
                , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
                )        
                select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, a.CIFName, a.CIFAddress1          
                , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
                , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
                , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
                , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
                , 2, 'Old', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION, a.DocRiskProfile          
          , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(b.AddressLine1, a.CIFAddress1)          
                , isnull(b.AddressLine2, a.CIFAddress2)          
                , isnull(b.AddressLine3, a.CIFAddress3)          
                , isnull(b.Dati2, a.CIFCity)          
                , isnull(b.Provinsi, a.CIFProvince)          
                , @dUpdateDate                     
                , b.ZIPCode, b.AddressLine4, b.Kelurahan, b.Kecamatan, b.AddressType          
                from dbo.ReksaCIFData_TM a      
                join dbo.ReksaMasterNasabah_TM rmn      
                    on a.CIFNo = rmn.CIFNo      
                join dbo.ReksaCIFConfirmAddr_TM b      
                    on rmn.NasabahId = b.Id      
                    and DataType = 2      
                where a.ClientId = @nId        
    
                if @@error != 0          
                begin         
                    set @cErrMsg = 'Error Insert Data Old Reksa (CFNAME)'          
                    goto ERROR_HANDLER          
                end           
    
                -- insert yang new          
                insert ReksaCIFData_TH (ClientId, ProdId, ClientCode, CIFNo, CIFName, CIFAddress1          
                , CIFAddress2, CIFAddress3, CIFCity, CIFProvince, CIFCountryCode, CIFTelephone          
                , CIFHP, CIFBirthPlace, CIFBirthDay, CIFIDNo, CIFNPWP, CIFType, CIFStatus          
                , IsEmployee, CIFNIK, AgentId, BankId, AccountType, NISPAccId, NISPAccName          
                , NonNISPAccId, NonNISPAccName, Referentor, LastUpdate, UserSuid, CheckerSuid          
                , AuthType, HistoryStatus, IDType, SEX, CTZSHIP, RELIGION, DocRiskProfile          
                , DocTermCondition, Inputter, Seller, Waperd, CIFConfAddress1, CIFConfAddress2       
                , CIFConfAddress3, CIFConfCity, CIFConfProvince, ActualChangeDate        
                , CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan, CIFConfKecamatan, AddressType        
                )        
                select a.ClientId, a.ProdId, a.ClientCode, a.CIFNo, b.CFNA1, a.CIFAddress1          
                , a.CIFAddress2, a.CIFAddress3, a.CIFCity, a.CIFProvince, a.CIFCountryCode, a.CIFTelephone          
                , a.CIFHP, a.CIFBirthPlace, a.CIFBirthDay, a.CIFIDNo, a.CIFNPWP, a.CIFType, a.CIFStatus          
                , a.IsEmployee, a.CIFNIK, a.AgentId, a.BankId, a.AccountType, a.NISPAccId, a.NISPAccName          
                , a.NonNISPAccId, a.NonNISPAccName, a.Referentor, dateadd(ss, -1, @dUpdateDate), a.UserSuid, a.CheckerSuid          
                , 2, 'Updated', a.IDType, a.SEX, a.CTZSHIP, a.RELIGION         
                , a.DocRiskProfile          
                , a.DocTermCondition, a.Inputter, a.Seller, a.Waperd, isnull(c.AddressLine1, a.CIFAddress1)          
                , isnull(c.AddressLine2, a.CIFAddress2)          
                , isnull(c.AddressLine3, a.CIFAddress3)          
                , isnull(c.Dati2, a.CIFCity)          
                , isnull(c.Provinsi, a.CIFProvince)          
                , @dUpdateDate                 
                , c.ZIPCode, c.AddressLine4, c.Kelurahan, c.Kecamatan, c.AddressType        
                from ReksaCIFData_TM a join #tempCFNAME b          
                    on a.CIFNo = b.CFCIF#          
                join dbo.ReksaMasterNasabah_TM rmn      
                    on a.CIFNo = rmn.CIFNo      
                left join dbo.ReksaCIFConfirmAddr_TM c      
                    on rmn.NasabahId = c.Id      
                    and c.DataType = 2      
                where a.ClientId = @nId       
    
                if @@error != 0          
                begin          
                    set @cErrMsg = 'Error Insert Data New Reksa (CFNAME)'          
                    goto ERROR_HANDLER          
                end           
    
                update a          
                set CIFName = b.CFNA1        
                    ,LastUpdate   = @dUpdateDate          
                from ReksaCIFData_TM a, #tempCFNAME b          
          where a.ClientId = @nId          
    
                if @@error != 0          
                begin          
                    set @cErrMsg = 'Error Update Data Master (CFNAME)'          
                    goto ERROR_HANDLER          
                end           
    
                if exists(select top 1 1 from ReksaCIFData_TH where ClientId = @nId           
                and AuthType = 4 and LastUpdate > @dLastProcess)          
                Begin          
                    update a          
                    set CIFName = b.CFNA1         
                        ,LastUpdate   = @dUpdateDate          
                    from ReksaCIFData_TH a, #tempCFNAME b          
                    where a.ClientId = @nId          
                    and a.AuthType = 4           
                    and a.LastUpdate > @dLastProcess          
    
                    if @@error != 0          
                    begin          
                        set @cErrMsg = 'Error Insert Data Old Reksa (CFNAME)'          
                        goto ERROR_HANDLER          
                    end           
                End          
            End          
    
            if @pbOutTran = 0          
            commit tran          
        end          
    
        close sinkron_cur          
        deallocate sinkron_cur          
    
        if @pbOutTran = 0          
            begin tran    
                
        if exists(select top 1 1            
            from ReksaMasterNasabah_TM a join #tempCFNAME b          
            on a.CIFNo = b.CFCIF#          
            where ltrim(rtrim(isnull(a.CIFName,''))) != ltrim(rtrim(b.CFNA1))      
        )                   
        begin    
            insert ReksaMasterNasabah_TH(    
                NasabahId, ShareholderID, CIFNo, CIFName, CIFBirthPlace, CIFBirthDay, OfficeId, IsEmployee, CIFNik, NISPAccountId, NISPAccountName, NISPAccountIdUSD,    
                NISPAccountNameUSD, NISPAccountIdMC, NISPAccountNameMC, CreateDate, UserSuid, CheckerSuid, AuthType, DocRiskProfile, DocTermCondition, HistoryStatus,    
                LastUpdate, CIFConfAddress1, CIFConfAddress2, CIFConfAddress3, CIFConfCity, CIFConfProvince, CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan,    
--20160829, Elva, LOGEN00196, begin    
                --CIFConfKecamatan, ApprovalStatus, ActualChangeDate)    
                CIFConfKecamatan, ApprovalStatus, ActualChangeDate    
    , AccountIdTA     
    , AccountNameTA     
    , AccountIdUSDTA    
    , AccountNameUSDTA     
    , AccountIdMCTA     
    , AccountNameMCTA    
    , isTA)      
--20160829, Elva, LOGEN00196, end    
            select     
                rn.NasabahId, rn.ShareholderID, rn.CIFNo, rn.CIFName, rn.CIFBirthPlace, rn.CIFBirthDay, rn.OfficeId, rn.IsEmployee, rn.CIFNik, rn.NISPAccountId,     
                rn.NISPAccountName, rn.NISPAccountIdUSD, rn.NISPAccountNameUSD, rn.NISPAccountIdMC, rn.NISPAccountNameMC, rn.CreateDate, rn.UserSuid, rn.CheckerSuid,     
                rn.AuthType, rn.DocRiskProfile, rn.DocTermCondition, 'Old', dateadd(ss, -1, @dUpdateDate),     
                rca.AddressLine1, rca.AddressLine2, rca.AddressLine3, rca.Dati2, rca.Provinsi, rca.ZIPCode, rca.AddressLine4, rca.Kelurahan, rca.Kecamatan,    
                rn.ApprovalStatus, @dUpdateDate    
--20160829, Elva, LOGEN00196, begin    
    , rn.AccountIdTA     
    , rn.AccountNameTA     
    , rn.AccountIdUSDTA    
    , rn.AccountNameUSDTA     
    , rn.AccountIdMCTA     
    , rn.AccountNameMCTA     
    , rn.isTA    
--20160829, Elva, LOGEN00196, end      
            from ReksaMasterNasabah_TM rn      
            join #tempCFNAME tmc          
                on rn.CIFNo = tmc.CFCIF#        
            left join ReksaCIFConfirmAddr_TM rca        
                on rn.NasabahId = rca.Id     
                and rca.DataType = 2    
                        
            if @@error != 0          
            begin         
                set @cErrMsg = 'Error Insert Data Old Reksa Master Nasabah (CFNAME)'          
                goto ERROR_HANDLER          
            end        
    
            insert ReksaMasterNasabah_TH(    
                NasabahId, ShareholderID, CIFNo, CIFName, CIFBirthPlace, CIFBirthDay, OfficeId, IsEmployee, CIFNik, NISPAccountId, NISPAccountName, NISPAccountIdUSD,    
                NISPAccountNameUSD, NISPAccountIdMC, NISPAccountNameMC, CreateDate, UserSuid, CheckerSuid, AuthType, DocRiskProfile, DocTermCondition, HistoryStatus,    
                LastUpdate, CIFConfAddress1, CIFConfAddress2, CIFConfAddress3, CIFConfCity, CIFConfProvince, CIFConfZipCode, CIFConfAddress4, CIFConfKelurahan,    
--20160829, Elva, LOGEN00196, begin    
                --CIFConfKecamatan, ApprovalStatus, ActualChangeDate)    
                CIFConfKecamatan, ApprovalStatus, ActualChangeDate    
    , AccountIdTA     
    , AccountNameTA     
    , AccountIdUSDTA    
    , AccountNameUSDTA     
    , AccountIdMCTA     
    , AccountNameMCTA    
    , isTA)      
--20160829, Elva, LOGEN00196, end    
            select     
                rn.NasabahId, rn.ShareholderID, rn.CIFNo, tmc.CFNA1, rn.CIFBirthPlace, rn.CIFBirthDay, rn.OfficeId, rn.IsEmployee, rn.CIFNik, rn.NISPAccountId,     
                rn.NISPAccountName, rn.NISPAccountIdUSD, rn.NISPAccountNameUSD, rn.NISPAccountIdMC, rn.NISPAccountNameMC, rn.CreateDate, rn.UserSuid, rn.CheckerSuid,     
                rn.AuthType, rn.DocRiskProfile, rn.DocTermCondition, 'Updated', dateadd(ss, -1, @dUpdateDate),     
                rca.AddressLine1, rca.AddressLine2, rca.AddressLine3, rca.Dati2, rca.Provinsi, rca.ZIPCode, rca.AddressLine4, rca.Kelurahan, rca.Kecamatan,    
                rn.ApprovalStatus, @dUpdateDate    
--20160829, Elva, LOGEN00196, begin    
    , rn.AccountIdTA     
    , rn.AccountNameTA     
    , rn.AccountIdUSDTA    
    , rn.AccountNameUSDTA     
    , rn.AccountIdMCTA     
    , rn.AccountNameMCTA     
    , rn.isTA    
--20160829, Elva, LOGEN00196, end      
            from ReksaMasterNasabah_TM rn      
            join #tempCFNAME tmc          
                on rn.CIFNo = tmc.CFCIF#        
            left join ReksaCIFConfirmAddr_TM rca        
                on rn.NasabahId = rca.Id     
                and rca.DataType = 2         
    
            if @@error != 0          
            begin         
                set @cErrMsg = 'Error Insert Data New Reksa Master Nasabah (CFNAME)'          
                goto ERROR_HANDLER          
            end      
    
            update a          
            set LastUpdate = @dUpdateDate     
                , CIFName = b.CFNA1     
            from ReksaMasterNasabah_TM a    
            join #tempCFNAME b    
                on a.CIFNo = b.CFCIF#    
                    
            if @@error != 0          
            begin          
                set @cErrMsg = 'Error Update Data Reksa Master Nasabah (CFNAME)'          
                goto ERROR_HANDLER          
            end         
   
            if exists(select top 1 1 from ReksaMasterNasabah_TH a    
                join #tempCFNAME b    
                    on a.CIFNo = b.CFCIF#     
                where a.AuthType = 4 and a.LastUpdate > @dLastProcess)          
            begin      
                update a          
                set LastUpdate = @dUpdateDate     
                    , CIFName = b.CFNA1     
                from ReksaMasterNasabah_TM a    
                join #tempCFNAME b    
                    on a.CIFNo = b.CFCIF#    
                where a.AuthType = 4           
                    and a.LastUpdate > @dLastProcess    
                        
                if @@error != 0          
                begin          
                    set @cErrMsg = 'Error Update Data Reksa Master Nasabah dengan Statu Pending Approval (CFNAME)'          
                    goto ERROR_HANDLER          
                end             
            end            
        end    
                
            
        if @pbOutTran = 0          
            commit tran       
                
        drop table #tempCFNAME          
    End    
--20160314, sandi, LOGAM07888, end        
End          
          
return 0          
          
ERROR_HANDLER:          
if @pbOutTran = 0          
 if(@@trancount>0)          
   rollback tran          
          
if isnull(@cErrMsg,'') = ''              
   set @cErrMsg = 'Unknown Error'          
          
--exec @nOK = set_raiserror @@procid, @nErrno output          
raiserror (@cErrMsg          ,16,1)
          
return 1          
--20100702, indra_w, BAING10033, end
GO