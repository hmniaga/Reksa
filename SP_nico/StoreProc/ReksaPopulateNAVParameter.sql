
CREATE proc [dbo].[ReksaPopulateNAVParameter]  
/*  
 CREATED BY    : victor  
 CREATION DATE : 20071025  
 DESCRIPTION   : ambil data dari file yang diimport, insert ke tabel dbo.ReksaNAVParam_TH  

    exec ReksaPopulateNAVParameter '<ROOT><RS Tanggal="20090227" KodeProduk="DT2" NAV="1075.32" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDH" NAV="1453.5789" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDI" NAV="0.99367334" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDISP" NAV="951.8325" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDM" NAV="1000" Deviden="0.8426954734513" Kurs="1" NAVMFee="1001.3" ></RS><RS Tanggal="20090227" KodeProduk="RDM3" NAV="1000" Deviden="1.292352000702" Kurs="1" NAVMFee="999.8" ></RS><RS Tanggal="20090227" KodeProduk="RDP" NAV="1258.15" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDS" NAV="1000" Deviden="0.507963230943" Kurs="1" NAVMFee="1002.54125" ></RS><RS Tanggal="20090227" KodeProduk="RDTL" NAV="1079.76" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RFG" NAV="886.5" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDPS1" NAV="1136.33" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDPS3" NAV="1104.27" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDPS4" NAV="1157.48" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDPS5" NAV="1124.93" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="FOIP" NAV="" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="FRDFE" NAV="2311.3" Deviden="0" Kurs="1" NAVMFee="" ></RS><RS Tanggal="20090227" KodeProduk="RDPDU" NAV="1.0206" Deviden="0" Kurs="1" NAVMFee="" ></RS></ROOT>',
        0, null

 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20071126, victor, REKSADN002, tambah pengecekan tanggal tidak boleh > current date  
  20071207, indra_w, REKSADN002, support idola  
  20071218, indra_w, REKSADN002, cek jika gagal insert ke tabel dbo.ReksaNAVParam_TH  
  20080414, mutiara, REKSADN002, rubah tipe data  
  20090723, oscar, REKSADN013, tambah kolom NAVMFee
  20090723, oscar, REKSADN013, cek tgl maks H-2
  20090814, oscar, REKSADN013, perbaikan UAT, handle kl NAVMFee diisi = 0
  20150326, dhanan, LOGAM06839, additional checking for outstanding sync and minimum NAV date
  20151106, liliana, LIBST13020, lepas pengecekan sinkronisasi request by PO
  
 END REVISED  
  
 declare @a varchar(4000)  
 set @a = '<ROOT>  
    <RS Tanggal="20071025" KodeProduk="ABU" NAV="1000" Deviden="0.285025022" Kurs="1.00"></RS>  
    <RS Tanggal="20071025" KodeProduk="XXX" NAV="1200" Deviden="0.285041776" Kurs="1.00"></RS>  
     </ROOT>'  
 exec dbo.ReksaPopulateNAVParameter @a, 0, ''  
*/  
@pcInput     text,  
@pnNIK      int,  
@pcGuid      varchar(50)  
  
as  
  
set nocount on  
  
declare @cErrMsg   varchar(100),  
  @nOK    int,  
  @nDoc    int,  
  @dToday    datetime  
--20090723, oscar, REKSADN013, begin
    , @dMinDate datetime
--20090723, oscar, REKSADN013, end
--20150326, dhanan, LOGAM06839, begin
    , @dPrevWorkingDate datetime
    , @cCustodyCode     varchar(10)
--20150326, dhanan, LOGAM06839, end
  
declare @TempTable table  
(  
 Tanggal     datetime,  
 KodeProduk    varchar(10),  
--20071207, indra_w, REKSADN002, begin  
--20080414, mutiara, REKSADN002, begin  
-- NAV      decimal(20,10),  
 NAV      decimal(25,13),  
--20071207, indra_w, REKSADN002, end  
-- Deviden     float,  
-- Kurs     money  
 Deviden     decimal(25,13),  
 Kurs     decimal(25,13)  
--20080414, mutiara, REKSADN002, end  
--20090723, oscar, REKSADN013, begin
    , NAVMFee   varchar(26) --decimal(25,13)
--20090723, oscar, REKSADN013, end
)  
  
--20071126, victor, REKSADN002, begin  
--set @dToday = getdate()  
select @dToday = current_working_date  
--20150326, dhanan, LOGAM06839, begin
     , @dPrevWorkingDate = previous_working_date
--20150326, dhanan, LOGAM06839, end 
from dbo.fnGetWorkingDate()  
--20071126, victor, REKSADN002, end  
  
exec @nOK = sp_xml_preparedocument @nDoc output, @pcInput  
if @nOK!=0 or @@error != 0  
begin  
 set @cErrMsg='Gagal Prepare Document Xml'  
 goto ERROR  
end  
  
--20090723, oscar, REKSADN013, begin
--insert @TempTable (Tanggal, KodeProduk, NAV, Deviden, Kurs)  
-- select Tanggal, KodeProduk, NAV, Deviden, Kurs  
insert @TempTable (Tanggal, KodeProduk, NAV, Deviden, Kurs, NAVMFee)  
--20090814, oscar, REKSADN013, begin
 --select Tanggal, KodeProduk, NAV, Deviden, Kurs, case when NAVMFee = '' then convert(varchar(26), NAV) else NAVMFee end
 select Tanggal, KodeProduk, NAV, Deviden, Kurs, case when NAVMFee = '' or NAVMFee = '0' then convert(varchar(26), NAV) else NAVMFee end
--20090814, oscar, REKSADN013, end
 from openxml (@nDoc, '/ROOT/RS', 1)  
 with   
 (  
  Tanggal    datetime,  
  KodeProduk   varchar(10),  
--20071207, indra_w, REKSADN002, begin  
--20080414, mutiara, REKSADN002, begin  
--  NAV     decimal(20,10),  
  NAV     decimal(25,13),  
--20071207, indra_w, REKSADN002, end  
--  Deviden    float,  
--  Kurs    money  
  Deviden    decimal(25,13),  
  Kurs    decimal(25,13)  
--20080414, mutiara, REKSADN002, end  
    , NAVMFee   varchar(26)
--20090723, oscar, REKSADN013, end
 )  
  
exec sp_xml_removedocument @nDoc  
  
--20071126, victor, REKSADN002, begin  
if exists (select * from @TempTable where Tanggal > dateadd (second, -1, (dateadd (day, 1, @dToday))))  
begin  
 set @cErrMsg = 'Tanggal tidak boleh lebih besar dari hari ini'  
 goto ERROR  
end  
--20071126, victor, REKSADN002, end  
--20090723, oscar, REKSADN013, begin
if exists (select top 1 1 from @TempTable where NAV = 0)  
begin  
 set @cErrMsg = 'NAV tidak Boleh 0, mohon Hubungi PO!'  
 goto ERROR  
end  

select @dMinDate = dbo.fnReksaGetEffectiveDate(@dToday, -2)
if  exists (select * from @TempTable where Tanggal < @dMinDate)
begin
 set @cErrMsg = 'Tanggal tidak boleh lebih kecil dari H-2 (' + convert(varchar(10), @dMinDate, 105) + ')'
 goto ERROR
end
--20071218, indra_w, REKSADN002, begin  
--20150326, dhanan, LOGAM06839, begin

if exists(
    select top 1 1 
    from @TempTable
        where Tanggal < @dToday)
begin
    set @cErrMsg = 'Tanggal tidak boleh lebih kecil dari Tanggal EOD Terakhir'
    goto ERROR
end

declare @Temp_CheckAvailableCustody table(
      CustodyId     int
    , CustodyCode   varchar(10)
    , NAVValueDate  datetime
    )
insert @Temp_CheckAvailableCustody
select distinct a.CustodyId , a.CustodyCode, @dPrevWorkingDate
from dbo.ReksaCustody_TR a  
    join dbo.ReksaProduct_TM b  
        on a.CustodyId = b.CustodyId  
where b.Status = 1  

select @cCustodyCode = ac.CustodyCode
from @Temp_CheckAvailableCustody ac 
    left join ReksaOSUploadProcessLog_TH ol with(nolock)
        on ac.CustodyId = ol.CustodyId
            and ac.NAVValueDate = ol.NAVValueDate
            and ol.Status = 3
where ol.CustodyId is null

--20151106, liliana, LIBST13020, begin
--if @cCustodyCode is not null
--begin
--    set @cErrMsg = 'EOD tidak dapat dijalankan, krn hari sebelumnya tidak melakukan Sinkronisasi Outstanding untuk '+@cCustodyCode
--    goto ERROR
--end
--20151106, liliana, LIBST13020, end
--20150326, dhanan, LOGAM06839, end
begin tran  
--20071218, indra_w, REKSADN002, end  
--20090723, oscar, REKSADN013, end
--20090723, oscar, REKSADN013, begin
-- hapus dulu data yg sudah ada
delete from ReksaNAVParam_TH
from ReksaNAVParam_TH a
join ReksaProduct_TM b
    on a.ProdId = b.ProdId
join @TempTable t
    on t.KodeProduk = b.ProdCode
    and a.ValueDate = t.Tanggal
--insert dbo.ReksaNAVParam_TH (ProdId, ValueDate, NAV, Deviden, Kurs, LastUpdate, LastUser)  
-- select b.ProdId, a.Tanggal, a.NAV, a.Deviden, a.Kurs, @dToday, @pnNIK  
insert dbo.ReksaNAVParam_TH (ProdId, ValueDate, NAV, Deviden, Kurs, LastUpdate, LastUser, NAVMFee)  
 select b.ProdId, a.Tanggal, a.NAV, a.Deviden, a.Kurs, @dToday, @pnNIK, convert(decimal(25,13), isnull(a.NAVMFee, a.NAV))  
--20090723, oscar, REKSADN013, end
 from @TempTable a, dbo.ReksaProduct_TM b  
 where a.KodeProduk = b.ProdCode  
--20071218, indra_w, REKSADN002, begin  
if @@rowcount != (select count(*) from @TempTable)  
begin  
 rollback tran  
 set @cErrMsg = 'Gagal proses, periksa product code atau format file .xls nya'  
 goto ERROR  
end  
--20090723, oscar, REKSADN013, begin
--isi ke ReksaNAVUpdate_TH kalo H-2
if exists (select Tanggal from @TempTable where Tanggal < @dToday)
begin
    delete from ReksaNAVUpdate_TH
    from ReksaNAVUpdate_TH a
    join ReksaProduct_TM b
        on a.ProdId = b.ProdId
    join @TempTable t
        on t.KodeProduk = b.ProdCode
        and a.NAVValueDate = t.Tanggal
        and t.Tanggal >= @dMinDate
        and t.Tanggal < @dToday
    
    insert into dbo.ReksaNAVUpdate_TH (ProdId, NAV, NAVValueDate, DevidentDate, DevidentAmount, LastUpdate, LastUser, Status)
     select b.ProdId, convert(decimal(25,13), a.NAV), a.Tanggal, a.Tanggal, convert(decimal(25,13), a.Deviden), @dToday, @pnNIK, 0
     from @TempTable a join dbo.ReksaProduct_TM b  
     on a.KodeProduk = b.ProdCode 
     and a.Tanggal >= @dMinDate
     and a.Tanggal < @dToday
end
--20090723, oscar, REKSADN013, end
commit tran  
--20071218, indra_w, REKSADN002, end  
  
ERROR:  
if isnull(@cErrMsg, '') <> ''   
begin  
 set @nOK = 1  
 raiserror (@cErrMsg  ,16,1);
end  
  
return @nOK
GO