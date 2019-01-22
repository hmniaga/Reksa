CREATE  proc [dbo].[ReksaUpdateOSProcess]      
/*      
    CREATED BY    : Oscar Marino      
    CREATION DATE : 20090511      
    DESCRIPTION   : Proses data XML upload sinkronisasi OS Unit Balance      
          
    ReksaOSUploadProcessLog_TH, Status       
        0 = baru upload      
        1 = approved      
        2 = rejected      
          
    select * from ReksaOSUploadProcessLog_TH      
    where Status = 1      
    select * from ReksaOSUploadLog_TH      
          
    exec ReksaUpdateOSProcess       
        @pnGuid = '2107540F-D28F-401D-9D0D-C44E3515C6FF',      
        @pbDebug = 1      
              
    select rc.ClientCode, rc.UnitBalance, b.UnitBalanceBefore, b.UnitBalanceAfter       
    from ReksaCIFData_TM rc      
    join ReksaOSUploadLog_TH b      
        on rc.ClientCode = b.ClientCode      
    where b.BatchGuid = '51899023-70D6-43DE-9189-D4270BC43F4A'      
              
    REVISED BY    :      
        DATE,   USER,       PROJECT,    NOTE      
        -----------------------------------------------------------------------      
        20090619, oscar, REKSADN014, remark dulu yg update transaksi & fee      
        20090715, oscar, REKSADN014, data yang di tabel _TH tidak usah hitung ulang      
        20100111, oscar, REKSADN014, tambah pengecekan harus >= H-2, parameter proses AdHoc dan ga usah hitung redemption hitung ulang deviden kl ada selisih, simpan data di ReksaChangeRecord_TH      
        20100127, anthony, REKSADN014, tambah penggunaan dbo.fnReksaSetRounding      
        20100203, oscar, REKSADN014, buat check in      
        20100208, oscar, REKSADN014, perbaikan UAT hari-1      
        20100212, oscar, REKSADN014, perbaikan UAT hari-2      
        20100215, oscar, REKSADN014, perbaikan UAT hari-5      
        20100216, oscar, REKSADN014, perbaikan maintenance fee      
        20100324, oscar, REKSADN014, perbaikan error saat proses adhoc      
        20100607, volvin, LOGAM03363, perbaikan maintenance fee agar tidak duplikat      
        20120813, liliana, BAALN11003, sinkronisasi maintenance fee dan perhitungan unit nominal trx deviden      
        20120824, liliana, BAALN11003, pindah ketika otor sinkronisasi outstanding      
        20150706, liliana, LIBST13020, flag jika sedang sinkronisasi      
        20151208, dhanan, LOGAM07303, change ">=" to "=' for filtering NAVValueDate      
        20151208, dhanan, LOGAM07303, update ReksaTransaction_TT       
        20151212, liliana, LIBST13020, ganti remark desc karena bikin erorr  
        20180215, sandi, LOGAM09341, take out data hasil Sync NAV
        20180619, sandi, LOGAM09542, hanya ambil data sync NAV yang ada trx 
    END REVISED      
*/      
    @pnGuid     uniqueidentifier,        
--20100203, oscar, REKSADN014, begin          
--20100111, oscar, REKSADN014, begin          
    @pbAdHoc    bit = 0,      
--20100111, oscar, REKSADN014, end        
--20100203, oscar, REKSADN014, end      
    @pbDebug    bit = 0      
as      
set nocount on      
      
declare       
    @nOK        tinyint,      
    @cErrMsg    varchar(100)      
    , @dValueDate       datetime      
    , @cTemp            datetime      
    , @nJmlHari         int      
      
    , @nTranId  int      
    , @nTranType    tinyint      
    , @nProdId  int      
    , @nClientId    int      
    , @nTranAmt decimal(25,13)      
    , @nTranUnit    decimal(25,13)      
    , @nSubcFee decimal(25,13)      
    , @nRedempFee   decimal(25,13)      
    , @nSubcFeeBased    decimal(25,13)      
    , @nRedempFeeBased  decimal(25,13)      
    , @nNAV decimal(25,13)      
    , @dNAVValueDate    datetime      
    , @nRedempUnit  decimal(25,13)      
    , @nRedempDev       decimal(25,13)      
    , @bByUnit      bit      
    , @nFee         decimal(25,13)      
    , @nFeeBased    decimal(25,13)      
    , @bProcess     bit                    
--20100203, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin      
    , @dMinDate     datetime      
--20120813, liliana, BAALN11003, begin      
    , @dCustodyId   int      
--20120813, liliana, BAALN11003, end
--20180619, sandi, LOGAM09542, begin
	, @dCurrWorkingDate   datetime
	, @dPrevWorkingDate   datetime
	, @nPrevWorkingDate   int
	, @nPeriod     int
--20180619, sandi, LOGAM09542, end       
   
select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) from control_table      
--20100111, oscar, REKSADN014, end         
--20100203, oscar, REKSADN014, end      
          
set @nOK = 0      
      
-- set jumlah hari dalam 1 thn      
select @cTemp=CAST(CAST(year(current_working_date) as varchar(4))+'0201' as datetime) from dbo.fnGetWorkingDate()      
select @cTemp=dateadd(d,-1,(dateadd(m,1,@cTemp)))      
if(day(@cTemp)=28)      
begin      
    set @nJmlHari=365      
end      
else      
begin      
    set @nJmlHari=366      
end      
      
-- validasi      
if (select Status from ReksaOSUploadProcessLog_TH      
    where BatchGuid = @pnGuid) = 0      
begin      
    set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' belum diotorisasi'      
    goto ERR_HANDLER      
end      
      
if (select Status from ReksaOSUploadProcessLog_TH      
    where BatchGuid = @pnGuid) = 2      
begin      
    set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' status ditolak, tidak bisa proses'      
    goto ERR_HANDLER      
end      
      
if (select Status from ReksaOSUploadProcessLog_TH      
    where BatchGuid = @pnGuid) = 3      
begin      
    set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah diproses'      
    goto ERR_HANDLER      
end      
      
if not exists (select top 1 1 from ReksaOSUploadLog_TH a       
    join ReksaOSUploadProcessLog_TH b      
        on a.BatchGuid = b.BatchGuid      
        and b.Status = 1      
    where a.BatchGuid = @pnGuid)      
begin      
    set @cErrMsg = 'Tidak ada data yang bisa diproses'      
    goto ERR_HANDLER      
end                    
--20100203, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin    
if (select NAVValueDate from ReksaOSUploadProcessLog_TH      
    where BatchGuid = @pnGuid) < @dMinDate      
begin      
    set @cErrMsg = 'Tgl NAV < H-2 (Guid = ' + convert(varchar(40), @pnGuid) + ')'      
    goto ERR_HANDLER      
end        
--20100111, oscar, REKSADN014, end      
--20100111, oscar, REKSADN014, begin      
declare @tmpProd table (      
    ProdId   int      
)      
insert into @tmpProd      
select ProdId from ReksaProduct_TM      
where AdHocRecalc = case @pbAdHoc when 0 then AdHocRecalc else 1 end      
      
if @pbAdHoc = 1      
begin      
    -- cek data di batch apa ada yg di luar produk      
    if exists (      
        select top 1 1 from ReksaOSUploadLog_TH a      
        join ReksaCIFData_TM b      
            on a.ClientCode = b.ClientCode      
        left join @tmpProd prod      
            on b.ProdId = prod.ProdId      
        where prod.ProdId is null      
        and a.BatchGuid = @pnGuid      
    )      
    begin      
--20100324, oscar, REKSADN014, begin      
--      set @cErrMsg = 'Kode produk salah/tidak sesuai'      
--      goto ERR_HANDLER      
        return 0      
--20100324, oscar, REKSADN014, end      
    end      
end      
      
--20100111, oscar, REKSADN014, end           
--20100203, oscar, REKSADN014, end      
--20120813, liliana, BAALN11003, begin      
    select @dCustodyId = CustodyId       
    from dbo.ReksaOSUploadProcessLog_TH      
    where BatchGuid = @pnGuid      
--20120813, liliana, BAALN11003, end      
      
-- mulai proses      
begin tran      
      
select @dValueDate = NAVValueDate      
from ReksaOSUploadProcessLog_TH      
where BatchGuid = @pnGuid      
--20150706, liliana, LIBST13020, begin      
Update ReksaUserProcess_TR      
set LastUser = 778      
 , PrevLastRun = LastRun      
 , LastRun = getdate()      
 , ProcessStatus = 1      
where ProcessId = 10      
      
--20150706, liliana, LIBST13020, end      
      
--debug      
if @pbDebug = 1      
    select @dValueDate            
--20100203, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin      
/*      
 * Update Unit Balance before di ReksaOSUploadLog_TH      
 */      
update ReksaOSUploadLog_TH      
set UnitBalanceBefore = isnull(b.UnitBalance, cif.UnitBalance)      
from ReksaOSUploadLog_TH a      
join ReksaCIFData_TM cif      
    on a.ClientCode = cif.ClientCode      
left join ReksaCIFDataHist_TM b      
    on cif.ClientId = b.ClientId      
    and b.TransactionDate = @dValueDate      
where a.BatchGuid = @pnGuid      
      
if @@error <> 0      
begin      
    set @cErrMsg = 'Gagal update data unit balance terbaru'      
    goto ERR_HANDLER      
end      
--20100111, oscar, REKSADN014, end       
--20100203, oscar, REKSADN014, end      
/*      
 * Perbaikan Transaksi      
 */      
--20090619, oscar, REKSADN014, begin      
-- update transaksi      
--20090715, oscar, REKSADN014, begin      
--select rt.TranId, rt.TranType, rt.ProdId, rt.ClientId, rt.TranAmt, rt.TranUnit, rt.SubcFee, rt.RedempFee, rt.SubcFeeBased, rt.RedempFeeBased      
--  , rt.NAV, rt.NAVValueDate, rt.UnitBalance, rt.UnitBalanceNom, rt.RedempUnit, rt.RedempDev, rt.ByUnit, os.UnitBalanceAfter - rt.UnitBalance as Selisih      
--  , rt.BillId      
--into #TempTransaction      
--from ReksaTransaction_TH rt      
--join ReksaCIFData_TM cif      
--  on rt.ClientId = cif.ClientId      
--join ReksaOSUploadLog_TH os      
--  on os.ClientCode = cif.ClientCode      
--  and os.BatchGuid = @pnGuid      
----join ReksaProduct_TM rp      
----    on rt.ProdId = rp.ProdId      
----    and rp.IsDeviden = 0            -- non deviden      
--where rt.NAVValueDate >= @dValueDate      
--and rt.Status = 1      
--union all      
select rt.TranId, rt.TranType, rt.ProdId, rt.ClientId, rt.TranAmt, rt.TranUnit, rt.SubcFee, rt.RedempFee, rt.SubcFeeBased, rt.RedempFeeBased      
    , rt.NAV, rt.NAVValueDate, rt.UnitBalance, rt.UnitBalanceNom, rt.RedempUnit, rt.RedempDev, rt.ByUnit, os.UnitBalanceAfter - rt.UnitBalance as Selisih      
    , rt.BillId      
into #TempTransaction      
--20090715, oscar, REKSADN014, end      
from ReksaTransaction_TT rt      
join ReksaCIFData_TM cif      
    on rt.ClientId = cif.ClientId      
join ReksaOSUploadLog_TH os      
    on os.ClientCode = cif.ClientCode      
    and os.BatchGuid = @pnGuid      
--join ReksaProduct_TM rp      
--  on rt.ProdId = rp.ProdId      
--  and rp.IsDeviden = 0            -- non deviden      
--20151208, dhanan, LOGAM07303, begin      
--where rt.NAVValueDate >= @dValueDate      
where rt.NAVValueDate = @dValueDate      
--20151208, dhanan, LOGAM07303, end      
and rt.Status = 1      
      
--debug      
if @pbDebug = 1      
begin      
    print 'Transaction'      
    select 'before', NAVValueDate, ClientId, ProdId, NAV, Selisih, UnitBalance, UnitBalanceNom, TranAmt, TranUnit, BillId from #TempTransaction      
end      
      
-- adjust transaksi hari itu dulu      
--update #TempTransaction      
--set UnitBalance = dbo.fnReksaSetRounding(rt.ProdId, 2, convert(decimal(25, 13), os.UnitBalanceAfter)),      
--  UnitBalanceNom = dbo.fnReksaSetRounding(rt.ProdId, 2, convert(decimal(25, 13), os.UnitBalanceAfter) * rt.NAV)      
--from #TempTransaction rt      
--join ReksaCIFData_TM cif      
--  on rt.ClientId = cif.ClientId      
--join ReksaOSUploadLog_TH os      
--  on os.ClientCode = cif.ClientCode      
--  and os.BatchGuid = @pnGuid      
--where rt.TranDate >= @dValueDate      
      
update #TempTransaction         
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
--set UnitBalance = cast(UnitBalance as decimal(25,13)) + cast(Selisih as decimal(25,13))      
set UnitBalance = dbo.fnReksaSetRounding(ProdId, 2, UnitBalance) + dbo.fnReksaSetRounding(ProdId, 2, Selisih)      
--20100127, anthony, REKSADN014, end       
--20100203, oscar, REKSADN014, end      
      
if @@error <> 0      
begin      
    --drop table #TempNAVParam_TH      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal update unit balance'      
    goto ERR_HANDLER      
end       
      
update #TempTransaction             
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
--set UnitBalanceNom = cast(UnitBalance as decimal(25,13)) * cast(NAV as decimal(25,13))      
set UnitBalanceNom = dbo.fnReksaSetRounding(ProdId, 3, (UnitBalance * NAV))      
--20100127, anthony, REKSADN014, end       
--20100203, oscar, REKSADN014, end      
      
if @@error <> 0      
begin      
    --drop table #TempNAVParam_TH      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal hitung ulang nominal'      
    goto ERR_HANDLER      
end       
      
--debug      
if @pbDebug = 1      
begin      
    print 'Transaction'      
    select 'after', NAVValueDate, ClientId, ProdId, NAV, Selisih, UnitBalance, UnitBalanceNom, TranAmt, TranUnit, BillId from #TempTransaction      
end      
      
-- update tabel transaksi      
--20090715, oscar, REKSADN014, begin      
--update ReksaTransaction_TH      
--set UnitBalance = cast(b.UnitBalance as decimal(25, 13)),      
--  UnitBalanceNom = cast(b.UnitBalanceNom as decimal(25, 13))      
--from ReksaTransaction_TH a      
--join #TempTransaction b      
--  on a.TranId =  b.TranId      
--  and a.TranType = b.TranType      
--  and a.ProdId = b.ProdId      
--  and a.ClientId = b.ClientId      
--  and a.NAVValueDate = b.NAVValueDate      
--  and a.ByUnit = b.ByUnit      
      
------ debug      
----select 'ReksaTransaction_TH', @@rowcount      
          
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  set @cErrMsg = 'Gagal update tabel transaksi (TH)'      
--  goto ERR_HANDLER      
--end      
--20090715, oscar, REKSADN014, end      
          
--20151208, dhanan, LOGAM07303, begin      
--update ReksaTransaction_TT          
----20100203, oscar, REKSADN014, begin      
----20100127, anthony, REKSADN014, begin      
----set UnitBalance = cast(b.UnitBalance as decimal(25, 13)),      
--set UnitBalance = dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalance),      
----    UnitBalanceNom = cast(b.UnitBalanceNom as decimal(25, 13))      
--  UnitBalanceNom = dbo.fnReksaSetRounding(a.ProdId, 3, b.UnitBalanceNom)      
----20100127, anthony, REKSADN014, end      
----20100203, oscar, REKSADN014, end      
--from ReksaTransaction_TT a      
--join #TempTransaction b      
--  on a.TranId =  b.TranId      
--  and a.TranType = b.TranType      
--  and a.ProdId = b.ProdId      
--  and a.ClientId = b.ClientId      
--  and a.NAVValueDate = b.NAVValueDate      
--  and a.ByUnit = b.ByUnit       
--20151208, dhanan, LOGAM07303, end      
      
----debug      
--select 'ReksaTransaction_TT', @@rowcount      
      
if @@error <> 0      
begin      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal update tabel transaksi (TT)'      
    goto ERR_HANDLER      
end              
--20100203, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin      
      
insert into ReksaChangeRecord_TH      
(TransactionDate, TranId, ClientCode,       
FieldName, OldValue, NewValue, Remarks)      
select getdate(), a.TranId, c.ClientCode,       
--20151212, liliana, LIBST13020, begin      
--'NAV', a.NAV, b.NAV, 'Sync OS Unit Ref ' + convert(varchar(40), @pnGuid)      
'NAV', a.NAV, b.NAV, 'Sync OS ' + convert(varchar(40), @pnGuid)      
--20151212, liliana, LIBST13020, end      
from ReksaTransaction_v a       
join #TempTransaction b      
    on a.TranId = b.TranId      
join ReksaCIFData_TM c      
    on a.ClientId = c.ClientId      
where a.NAV <> b.NAV      
union      
select getdate(), a.TranId, c.ClientCode,       
--20151212, liliana, LIBST13020, begin      
--'TranUnit', a.TranUnit, b.TranUnit, 'Sync OS Unit Ref ' + convert(varchar(40), @pnGuid)      
'TranUnit', a.TranUnit, b.TranUnit, 'Sync OS ' + convert(varchar(40), @pnGuid)      
--20151212, liliana, LIBST13020, end      
from ReksaTransaction_v a       
join #TempTransaction b      
    on a.TranId = b.TranId      
join ReksaCIFData_TM c      
    on a.ClientId = c.ClientId        
where a.TranUnit <> b.TranUnit      
union      
select getdate(), a.TranId, c.ClientCode,      
--20151212, liliana, LIBST13020, begin       
--'UnitBalance', a.UnitBalance, b.UnitBalance, 'Sync OS Unit Ref ' + convert(varchar(40), @pnGuid)      
'UnitBalance', a.UnitBalance, b.UnitBalance, 'Sync OS ' + convert(varchar(40), @pnGuid)      
--20151212, liliana, LIBST13020, end      
from ReksaTransaction_v a       
join #TempTransaction b      
    on a.TranId = b.TranId      
join ReksaCIFData_TM c      
    on a.ClientId = c.ClientId        
where a.UnitBalance <> b.UnitBalance      
union      
select getdate(), a.TranId, c.ClientCode,       
--20151212, liliana, LIBST13020, begin       
--'TranAmt', a.TranAmt, b.TranAmt, 'Sync OS Unit Ref ' + convert(varchar(40), @pnGuid)      
'TranAmt', a.TranAmt, b.TranAmt, 'Sync OS ' + convert(varchar(40), @pnGuid)      
--20151212, liliana, LIBST13020, end       
from ReksaTransaction_v a       
join #TempTransaction b      
    on a.TranId = b.TranId      
join ReksaCIFData_TM c      
    on a.ClientId = c.ClientId        
where a.TranAmt <> b.TranAmt      
union      
select getdate(), a.TranId, c.ClientCode,       
--20151212, liliana, LIBST13020, begin      
--'UnitBalanceNom', a.UnitBalanceNom, b.UnitBalanceNom, 'Sync OS Unit Ref ' + convert(varchar(40), @pnGuid)      
'UnitBalanceNom', a.UnitBalanceNom, b.UnitBalanceNom, 'Sync OS ' + convert(varchar(40), @pnGuid)      
--20151212, liliana, LIBST13020, end      
from ReksaTransaction_v a       
join #TempTransaction b      
    on a.TranId = b.TranId      
join ReksaCIFData_TM c      
    on a.ClientId = c.ClientId        
where a.UnitBalanceNom <> b.UnitBalanceNom      
      
if @@error <> 0      
begin      
    set @cErrMsg = 'Gagal mencatat perubahan data'      
    goto ERR_HANDLER      
end      
      
--20151208, dhanan, LOGAM07303, begin      
/*      
 * Update ReksaTransaction      
 */      
if @pbDebug = 1      
begin      
    print 'ReksaTransaction_TT'      
    select 'before', a.*      
    from ReksaTransaction_TT a      
    join #TempTransaction b      
        on a.TranId =  b.TranId      
        and a.TranType = b.TranType      
        and a.ProdId = b.ProdId      
        and a.ClientId = b.ClientId      
        and a.NAVValueDate = b.NAVValueDate      
and a.ByUnit = b.ByUnit      
end      
      
update ReksaTransaction_TT          
set UnitBalance = dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalance),      
    UnitBalanceNom = dbo.fnReksaSetRounding(a.ProdId, 3, b.UnitBalanceNom)      
from ReksaTransaction_TT a      
join #TempTransaction b      
    on a.TranId =  b.TranId      
    and a.TranType = b.TranType      
    and a.ProdId = b.ProdId      
    and a.ClientId = b.ClientId      
    and a.NAVValueDate = b.NAVValueDate      
    and a.ByUnit = b.ByUnit      
      
if @pbDebug = 1      
begin      
    print 'ReksaTransaction_TT'      
    select 'after', a.*      
    from ReksaTransaction_TT a      
    join #TempTransaction b      
        on a.TranId =  b.TranId      
        and a.TranType = b.TranType      
        and a.ProdId = b.ProdId      
        and a.ClientId = b.ClientId      
        and a.NAVValueDate = b.NAVValueDate      
        and a.ByUnit = b.ByUnit      
end      
--20151208, dhanan, LOGAM07303, end      
--20100111, oscar, REKSADN014, end       
--20100203, oscar, REKSADN014, end      
/*      
 * Update CIFDataHist (buat report RDN12)      
 */      
-- debug      
if @pbDebug = 1      
begin      
    print 'ReksaCIFDataHist_TM'      
    select top 10 'before', a.*       
    from ReksaCIFDataHist_TM a      
    join ReksaCIFData_TM cif      
        on a.ClientId = cif.ClientId      
    join ReksaOSUploadLog_TH b      
        on cif.ClientCode = b.ClientCode      
        and b.BatchGuid = @pnGuid      
    where a.NAVDate >= @dValueDate      
    order by a.ClientId, a.NAVDate      
end      
  
--20180215, sandi, LOGAM09341, begin  
select   
 a.ClientId, b.ClientCode, a.ProdId, b.UnitBalanceBefore, b.UnitBalanceAfter, c.NAVValueDate  
into #tmpSyncAll   
from ReksaCIFData_TM a with(nolock)     
join ReksaOSUploadLog_TH b with(nolock)     
    on a.ClientCode = b.ClientCode  
join ReksaOSUploadProcessLog_TH c with(nolock)     
    on b.BatchGuid = c.BatchGuid      
where b.BatchGuid = @pnGuid  
  
select 
--20180619, sandi, LOGAM09542, begin  
	--b.ClientCode  
	distinct b.ClientCode	
--20180619, sandi, LOGAM09542, end 
into #tmpSyncOffshore  
from ReksaCIFData_TM a with(nolock)     
join ReksaOSUploadLog_TH b with(nolock)     
    on a.ClientCode = b.ClientCode  
join ReksaOSUploadProcessLog_TH c with(nolock)     
    on b.BatchGuid = c.BatchGuid   
--20180619, sandi, LOGAM09542, begin
--join ReksaNAVUpdate_TH d with(nolock) 
	--on c.NAVValueDate = d.NAVValueDate        
	--and a.ProdId = d.ProdId  
	--and d.Status = 3 
join ReksaSyncNAVTrx_TH d with(nolock)  
	on c.NAVValueDate = d.NAVValueDate      
	and a.ClientId = d.ClientId  
	and d.Keterangan = 'After'  
--20180619, sandi, LOGAM09542, end
where b.BatchGuid = @pnGuid  
  
delete a  
from #tmpSyncAll a  
join #tmpSyncOffshore b  
 on a.ClientCode = b.ClientCode  
  
--20180215, sandi, LOGAM09341, end  
      
update ReksaCIFDataHist_TM      
set UnitBalance = case       
    when a.UnitBalance + (cast(b.UnitBalanceAfter as decimal(25, 13))- cast(b.UnitBalanceBefore as decimal(25, 13))) < 0 then 0      
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
    --else a.UnitBalance + (cast(b.UnitBalanceAfter as decimal(25, 13))- cast(b.UnitBalanceBefore as decimal(25, 13)))      
    else a.UnitBalance + dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceAfter) - dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceBefore)      
--20100127, anthony, REKSADN014, begin      
--20100203, oscar, REKSADN014, end      
    end      
from ReksaCIFDataHist_TM a  
--20180215, sandi, LOGAM09341, begin      
--join ReksaCIFData_TM cif      
--    on a.ClientId = cif.ClientId      
--join ReksaOSUploadLog_TH b      
--    on b.ClientCode = cif.ClientCode      
--    and b.BatchGuid = @pnGuid      
--join ReksaOSUploadProcessLog_TH c      
--    on b.BatchGuid = c.BatchGuid      
----20151208, dhanan, LOGAM07303, begin      
--    --and a.NAVDate >= c.NAVValueDate      
--    and a.NAVDate = c.NAVValueDate      
----20151208, dhanan, LOGAM07303, end      
--    and a.TransactionDate >= c.NAVValueDate      
--    and b.BatchGuid = @pnGuid  
join #tmpSyncAll b      
    on a.ClientId = b.ClientId  
  and a.NAVDate = b.NAVValueDate      
  and a.TransactionDate >= b.NAVValueDate  
--20180215, sandi, LOGAM09341, end          
          
if @@error <> 0      
begin      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal update data history batch ' + convert(varchar(50), @pnGuid)       
    goto ERR_HANDLER      
end      
      
update ReksaCIFDataHist_TM             
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
--set UnitNominal = cast(a.UnitBalance as decimal(25, 13)) * cast(a.NAV as decimal(25, 13))      
set UnitNominal = dbo.fnReksaSetRounding(a.ProdId, 3, a.UnitBalance*a.NAV)      
--20100127, anthony, REKSADN014, end       
--20100203, oscar, REKSADN014, end      
from ReksaCIFDataHist_TM a      
join ReksaCIFData_TM cif      
    on a.ClientId = cif.ClientId      
join ReksaOSUploadLog_TH b      
    on b.ClientCode = cif.ClientCode      
join ReksaOSUploadProcessLog_TH c      
    on b.BatchGuid = c.BatchGuid      
--20151208, dhanan, LOGAM07303, begin      
    --and a.NAVDate >= c.NAVValueDate      
    and a.NAVDate = c.NAVValueDate      
--20151208, dhanan, LOGAM07303, end      
    and a.TransactionDate >= c.NAVValueDate      
    and b.BatchGuid = @pnGuid      
      
if @@error <> 0      
begin      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal hitung ulang nominal pada history batch ' + convert(varchar(50), @pnGuid)       
    goto ERR_HANDLER      
end      
      
-- debug      
if @pbDebug = 1      
begin      
    print 'ReksaCIFDataHist_TM'      
    select top 10 'after', a.*       
    from ReksaCIFDataHist_TM a      
    join ReksaCIFData_TM cif      
        on a.ClientId = cif.ClientId      
    join ReksaOSUploadLog_TH b      
        on cif.ClientCode = b.ClientCode      
        and b.BatchGuid = @pnGuid      
    where a.NAVDate >= @dValueDate      
    order by a.ClientId, a.NAVDate      
end      
      
/*      
 * Update CIFData_TM      
 */      
--debug      
if @pbDebug = 1      
begin      
    print 'CIFData_TM'      
    select top 10 'before', a.ClientCode, a.ProdId, a.NAV, a.UnitBalance, a.UnitNominal       
    from ReksaCIFData_TM a      
    join ReksaOSUploadLog_TH b      
        on a.ClientCode = b.ClientCode      
        and b.BatchGuid = @pnGuid      
end       
   
update ReksaCIFData_TM      
set UnitBalance = case       
    when cast(UnitBalance as decimal(25, 13)) + (cast(b.UnitBalanceAfter as decimal(25, 13)) - cast(b.UnitBalanceBefore as decimal(25, 13))) < 0 then 0      
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
    --else cast(UnitBalance as decimal(25, 13)) + (cast(b.UnitBalanceAfter as decimal(25, 13)) - cast(b.UnitBalanceBefore as decimal(25, 13)))      
    else dbo.fnReksaSetRounding(a.ProdId, 2, UnitBalance) + (dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceAfter) - dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceBefore))      
--20100127, anthony, REKSADN014, end      
--20100203, oscar, REKSADN014, end      
    end      
from ReksaCIFData_TM a  
--20180215, sandi, LOGAM09341, begin      
--join ReksaOSUploadLog_TH b      
--    on a.ClientCode = b.ClientCode      
--join ReksaOSUploadProcessLog_TH c      
--    on b.BatchGuid = c.BatchGuid      
----  and a.NAVDate = c.NAVValueDate      
--where b.BatchGuid = @pnGuid     
join #tmpSyncAll b      
    on a.ClientCode = b.ClientCode   
--20180215, sandi, LOGAM09341, end  
      
if @@error <> 0      
begin      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal update unit balance di ReksaCIFData_TM, batch ' + convert(varchar(50), @pnGuid)       
    goto ERR_HANDLER      
end      
      
update ReksaCIFData_TM      
--20100203, oscar, REKSADN014, begin      
--20100127, anthony, REKSADN014, begin      
--set UnitNominal = cast(UnitBalance as decimal(25, 13)) * cast(a.NAV as decimal(25, 13))      
set UnitNominal = dbo.fnReksaSetRounding(ProdId, 3, UnitBalance*NAV)      
--20100127, anthony, REKSADN014, end      
--20100203, oscar, REKSADN014, end      
from ReksaCIFData_TM a      
join ReksaOSUploadLog_TH b      
    on a.ClientCode = b.ClientCode      
join ReksaOSUploadProcessLog_TH c      
    on b.BatchGuid = c.BatchGuid      
--  and a.NAVDate = c.NAVValueDate      
where b.BatchGuid = @pnGuid      
      
if @@error <> 0      
begin      
    drop table #TempTransaction      
    set @cErrMsg = 'Gagal hitung ulang nominal di ReksaCIFData_TM, batch ' + convert(varchar(50), @pnGuid)       
    goto ERR_HANDLER      
end      
      
--debug      
if @pbDebug = 1      
begin      
    print 'CIFData_TM'      
    select top 10 'after', a.ClientCode, a.ProdId, a.NAV, a.UnitBalance, a.UnitNominal      
    from ReksaCIFData_TM a      
    join ReksaOSUploadLog_TH b      
        on a.ClientCode = b.ClientCode      
        and b.BatchGuid = @pnGuid      
end  
       
--20180215, sandi, LOGAM09341, begin  
drop table #tmpSyncAll  
drop table #tmpSyncOffshore  
--20180215, sandi, LOGAM09341, end    
    
/*      
 * Perbaikan maintenance fee      
 */      
---- tabel ReksaMtncFee_TM      
--select a.* into #TempMtncFeeDetail      
--from ReksaMtncFeeDetail_TM a      
--join ReksaCIFData_TM cif      
--  on a.ClientId = cif.ClientId      
--join ReksaOSUploadLog_TH b      
--  on cif.ClientCode = b.ClientCode      
--  and b.BatchGuid = @pnGuid      
--where a.BillId is null      
--and a.ValueDate >= @dValueDate      
      
--create index TempMtncFeeDetail_idx on #TempMtncFeeDetail (ValueDate, ClientId, ProdId)      
--20120813, liliana, BAALN11003, begin      
----debug      
--if @pbDebug = 1      
--begin      
--  print 'ReksaMtncFeeDetail_TM'      
----20100203, oscar, REKSADN014, begin      
----20100111, oscar, REKSADN014, begin      
--  --select a.*      
--  select top 100 cif.ClientCode, a.*      
----20100111, oscar, REKSADN014, end      
----20100203, oscar, REKSADN014, end      
--  from ReksaMtncFeeDetail_TM a      
--  join ReksaProduct_TM b      
--      on a.ProdId = b.ProdId      
--  join ReksaProductParam_TM c      
--      on b.ParamId = c.ParamId      
--  join ReksaProductFee_TR d      
--      on c.FeeId = d.FeeId      
--  join ReksaCIFData_TM cif      
--      on a.ClientId = cif.ClientId      
--  join ReksaOSUploadLog_TH h      
--      on cif.ClientCode = h.ClientCode      
--      and h.BatchGuid = @pnGuid      
--  where a.ValueDate >= @dValueDate      
--  order by a.ValueDate      
--end      
      
----update #TempMtncFeeDetail      
--update ReksaMtncFeeDetail_TM      
----20100203, oscar, REKSADN014, begin      
----20100216, oscar, REKSADN014, begin      
----set UnitBalance = case when cast(a.UnitBalance as decimal(25, 13)) + (cast(b.UnitBalanceAfter as decimal(25, 13)) - cast(b.UnitBalanceBefore as decimal(25, 13))) < 0 then 0       
--set UnitBalance = hist.UnitBalance      
----20100127, anthony, REKSADN014, begin      
--  --else cast(a.UnitBalance as decimal(25, 13)) + (cast(b.UnitBalanceAfter as decimal(25, 13)) - cast(b.UnitBalanceBefore as decimal(25, 13))) end       
--  --else dbo.fnReksaSetRounding(a.ProdId, 2, a.UnitBalance) + (dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceAfter) - dbo.fnReksaSetRounding(a.ProdId, 2, b.UnitBalanceBefore)) end       
----20100127, anthony, REKSADN014, begin      
----20100203, oscar, REKSADN014, end      
----20100216, oscar, REKSADN014, end      
----20100215, oscar, REKSADN014, begin      
--  , NAV = nav.NAV      
----from #TempMtncFeeDetail a      
--from ReksaMtncFeeDetail_TM a      
--join ReksaCIFData_TM cif      
--  on a.ClientId = cif.ClientId      
--join ReksaOSUploadLog_TH b      
--  on cif.ClientCode = b.ClientCode      
--  and b.BatchGuid = @pnGuid      
--join ReksaNAVParam_TH nav      
--  on a.ProdId = nav.ProdId          
--  and nav.ValueDate = case       
--      when (exists(select top 1 1 from ReksaHolidayTable_TM where ValueDate = a.ValueDate)       
--          or DATEPART(dw, a.ValueDate) in (1,7))       
----20100216, oscar, REKSADN014, begin      
--          --then dbo.fnReksaGetEffectiveDate(a.ValueDate, -1)      
--          then dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(a.ValueDate, 0), -1)      
--      else       
--          a.ValueDate      
--      end      
--join ReksaCIFDataHist_TM hist      
--  on hist.ClientId = a.ClientId      
--  and hist.TransactionDate = dateadd(dd, -1, a.ValueDate)      
----20100216, oscar, REKSADN014, end      
----tambah      
----where a.BillId is null      
--where 1=1      
--and a.ValueDate >= @dValueDate      
----20100215, oscar, REKSADN014, end      
          
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  --drop table #TempMtncFeeDetail      
--  set @cErrMsg = 'Gagal update unit balance di detail maintenance fee'      
--  goto ERR_HANDLER      
--end         
      
----update #TempMtncFeeDetail      
--update ReksaMtncFeeDetail_TM      
----20100208, oscar, REKSADN014, begin      
----set Amount = dbo.fnReksaSetRounding(a.ProdId,3,cast(cast(d.MaintenanceFee/100.00 as decimal(25,13)) * cast(a.UnitBalance as decimal(25,13)) * a.NAV as decimal(25,13))/@nJmlHari*(dbo.fnReksaCalcDevidentPct(a.ProdId, 'N')/100.0))      
--set Amount = dbo.fnReksaSetRounding(a.ProdId,3,cast(cast(d.MaintenanceFee/100.00 as decimal(25,13)) * cast(a.UnitBalance as decimal(25,13)) * a.NAV as decimal(25,13))/@nJmlHari)      
----20100208, oscar, REKSADN014, end      
----from #TempMtncFeeDetail a      
--from ReksaMtncFeeDetail_TM a      
--  join ReksaProduct_TM b      
--      on a.ProdId = b.ProdId      
--  join ReksaProductParam_TM c      
--      on b.ParamId = c.ParamId      
--  join ReksaProductFee_TR d      
--      on c.FeeId = d.FeeId      
--  join ReksaCIFData_TM cif      
--      on a.ClientId = cif.ClientId      
--  join ReksaOSUploadLog_TH h      
--      on cif.ClientCode = h.ClientCode      
--      and h.BatchGuid = @pnGuid      
----tambah      
----where a.BillId is null      
--where a.ValueDate >= @dValueDate      
      
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  --drop table #TempMtncFeeDetail      
--  set @cErrMsg = 'Gagal hitung ulang detail maintenance fee'      
--  goto ERR_HANDLER      
--end         
      
----debug      
--if @pbDebug = 1      
--begin        
----20100203, oscar, REKSADN014, begin      
----20100111, oscar, REKSADN014, begin      
--  --select a.*      
--  select top 100 cif.ClientCode, a.*      
----20100111, oscar, REKSADN014, end         
----20100203, oscar, REKSADN014, end      
--  from ReksaMtncFeeDetail_TM a      
--  join ReksaProduct_TM b      
--      on a.ProdId = b.ProdId      
--  join ReksaProductParam_TM c      
--      on b.ParamId = c.ParamId      
--  join ReksaProductFee_TR d      
--      on c.FeeId = d.FeeId      
--  join ReksaCIFData_TM cif      
--      on a.ClientId = cif.ClientId      
--  join ReksaOSUploadLog_TH h      
--      on cif.ClientCode = h.ClientCode      
--      and h.BatchGuid = @pnGuid      
--  where a.ValueDate >= @dValueDate      
--  order by a.ValueDate      
--end      
      
------ debug      
--if @pbDebug = 1      
--begin      
--  print 'ReksaMtncFee_TM'      
--  select top 10       
--      'after',      
--      a.ValueDate,       
--      a.ProdId,       
--      a.AgentId,       
--      a.Amount,       
--      a.TotalUnit,       
--      a.TotalNominal      
--  from ReksaMtncFee_TM a      
--  join #TempTransaction b      
--      on a.ProdId = b.ProdId      
--  join ReksaMtncFeeDetail_TM c      
--      on a.AgentId = c.AgentId      
--      and a.ProdId = c.ProdId      
--      and a.ValueDate = c.ValueDate      
--      and c.ClientId = b.ClientId      
--  where a.ValueDate >= @dValueDate      
--  order by a.ValueDate, a.ProdId, a.AgentId      
--end      
      
----update ReksaMtncFeeDetail_TM      
----set Amount = b.Amount,      
----    UnitBalance = b.UnitBalance      
----from ReksaMtncFeeDetail_TM a      
----join #TempMtncFeeDetail b      
----    on a.ClientId = b.ClientId      
----    and a.ProdId = b.ProdId      
----    and a.ValueDate = b.ValueDate      
----    and a.AgentId = b.AgentId      
      
----if @@error <> 0      
----begin      
----    drop table #TempTransaction      
----    drop table #TempMtncFeeDetail      
----    set @cErrMsg = 'Gagal update data detail maintenance fee'      
----    goto ERR_HANDLER      
----end       
      
---- hitung ulang ReksaMtncFee_TM      
--update ReksaMtncFee_TM      
--set Amount = b.Amount,      
--  TotalUnit = b.TotalUnit,      
--  TotalNominal = b.TotalNominal      
--from ReksaMtncFee_TM a      
--join (      
--  select      
--      a.ValueDate,       
--      a.ProdId,       
--      a.AgentId,       
--      sum(a.Amount) as Amount,       
--      sum(a.UnitBalance) as TotalUnit,       
----20100203, oscar, REKSADN014, begin      
----20100127, anthony, REKSADN014, begin              
--      --sum(a.NAV * a.UnitBalance) as TotalNominal      
--      sum(dbo.fnReksaSetRounding(a.ProdId, 3, a.NAV * a.UnitBalance)) as TotalNominal      
----20100127, anthony, REKSADN014, end      
----20100203, oscar, REKSADN014, end      
--  from ReksaMtncFeeDetail_TM a      
--  join ReksaCIFData_TM b      
--      on a.AgentId = b.AgentId      
----20100607, volvin, LOGAM03363, begin      
--      and a.ClientId = b.ClientId      
----20100607, volvin, LOGAM03363, end      
--  join ReksaOSUploadLog_TH c      
--      on b.ClientCode = c.ClientCode      
--      and c.BatchGuid = @pnGuid      
--  where a.ValueDate >= @dValueDate      
--  group by a.ValueDate, a.ProdId, a.AgentId      
--) b      
--  on a.ProdId = b.ProdId      
--  and a.AgentId = b.AgentId      
--  and a.ValueDate = b.ValueDate      
      
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  --drop table #TempMtncFeeDetail      
--  set @cErrMsg = 'Gagal hitung ulang data maintenance fee'      
--  goto ERR_HANDLER      
--end      
      
------ debug      
--if @pbDebug = 1      
--begin      
--  print 'ReksaMtncFee_TM'      
--  select top 10       
--      'after',      
--      a.ValueDate,       
--      a.ProdId,       
--      a.AgentId,       
--      a.Amount,       
--      a.TotalUnit,       
--      a.TotalNominal      
--  from ReksaMtncFee_TM a      
--  join #TempTransaction b      
--      on a.ProdId = b.ProdId      
--  join ReksaMtncFeeDetail_TM c      
--      on a.AgentId = c.AgentId      
--      and a.ProdId = c.ProdId      
--      and a.ValueDate = c.ValueDate      
--      and c.ClientId = b.ClientId      
--  where a.ValueDate >= @dValueDate      
--  order by a.ValueDate, a.ProdId, a.AgentId      
--end      
----20090619, oscar, REKSADN014, end      
----20100212, oscar, REKSADN014, begin      
----20100215, oscar, REKSADN014, begin      
----hitung ulang bill      
--update ReksaBill_TM       
--set TotalBill = b.Amount      
--from ReksaBill_TM a      
--join (      
--  select BillId,       
--      sum(dbo.fnReksaSetRounding(ProdId, 3, Amount)) as Amount      
--  from ReksaMtncFee_TM       
--  where Settled = 0      
--  and BillId is not null      
--  and ValueDate >= @dValueDate      
--  group by BillId      
--) b      
--on a.BillId = b.BillId      
      
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  --drop table #TempMtncFeeDetail      
--  set @cErrMsg = 'Gagal hitung ulang bill maintenance fee'      
--  goto ERR_HANDLER      
--end      
----20100215, oscar, REKSADN014, end        
----20100212, oscar, REKSADN014, end      
--20120813, liliana, BAALN11003, end      
/*      
 * Perbaikan redemption fee      
 */            
--20100203, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin      
--ga usah hitung redemption fee      
---- debug      
--if @pbDebug = 1      
--begin      
--  print 'Hitung Ulang Fee'      
--  select 'before', TranId, TranType, ProdId, ClientId, TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased from #TempTransaction      
--end      
       
--declare fee_csr cursor for       
--  select TranId, TranType, ProdId, ClientId, TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased      
--      , NAV, NAVValueDate, RedempUnit, RedempDev, ByUnit      
--  from #TempTransaction      
--  where TranType in (3,4) -- redemption      
          
--open fee_csr      
--while 1=1      
--begin      
--  fetch fee_csr into       
--      @nTranId, @nTranType, @nProdId, @nClientId, @nTranAmt, @nTranUnit, @nSubcFee, @nRedempFee, @nSubcFeeBased, @nRedempFeeBased,       
--      @nNAV, @dNAVValueDate, @nRedempUnit, @nRedempDev, @bByUnit      
--  if @@fetch_status <> 0 break      
          
--  select @bProcess = case @pbDebug when 0 then 1 else 0 end      
--  exec @nOK = ReksaCalcFee      
--      @pnProdId = @nProdId,      
--      @pnClientId = @nClientId,      
--      @pnTranType = @nTranType,      
--      @pmTranAmt = @nTranAmt,      
--      @pmUnit = @nTranUnit,      
--      @pnFee = @nFee output,      
--      @pnNIK = 7,      
--      @pcGuid = '',      
--      @pmNAV = @nNAV,      
--      @pbProcess = @bProcess,      
--      @pmFeeBased = @nFeeBased output,      
--      @pbByUnit = @bByUnit,      
--      @pmErrMsg = @cErrMsg output,      
--      @pbDebug = @pbDebug,      
--      @pdValueDate = @dNAVValueDate      
              
--  if @nOK <> 0 or isnull(@cErrMsg, '') <> ''      
--      continue      
          
--  if @nFee < 0.0 set @nFee = 0.0      
--  if @nFeeBased < 0.0 set @nFeeBased = 0.0       
          
--  update #TempTransaction set      
--      --SubcFee = case @nTranType       
--      --  when 1 then @nFee      
--      --  when 2 then @nFee      
--      --  else SubcFee      
--      --end,      
--      --SubcFeeBased = case @nTranType      
--      --  when 1 then @nFeeBased      
--      --  when 2 then @nFeeBased      
--      --  else SubcFeeBased      
--      --end,      
--      RedempFee = case @nTranType      
--          when 3 then @nFee      
--          when 4 then @nFee      
--          else RedempFee      
--  end,      
--      RedempFeeBased = case @nTranType      
--          when 3 then @nFeeBased      
--          when 4 then @nFeeBased      
--          else RedempFeeBased      
--      end      
--  where TranId =  @nTranId      
--  and TranType = @nTranType      
--  and ProdId = @nProdId      
--  and ClientId = @nClientId      
--  and NAVValueDate = @dNAVValueDate      
--end      
--close fee_csr      
--deallocate fee_csr      
      
---- debug      
--if @pbDebug = 1      
--begin      
--  select 'after', TranId, TranType, ProdId, ClientId, TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased from #TempTransaction      
--end      
      
--update ReksaTransaction_TT set      
--  --SubcFee = case when b.SubcFee < 0.0 then 0.0 else b.SubcFee end,      
--  --SubcFeeBased = case when b.SubcFeeBased < 0.0 then 0.0 else b.SubcFeeBased end,      
--  RedempFee = case when b.RedempFee < 0.0 then 0.0 else b.RedempFee end,      
--  RedempFeeBased = case when b.RedempFeeBased < 0.0 then 0.0 else b.RedempFeeBased end      
--from ReksaTransaction_TT a      
--join #TempTransaction b      
--on a.TranId =  b.TranId      
--and a.TranType = b.TranType      
--and a.ProdId = b.ProdId      
--and a.ClientId = b.ClientId      
--and a.NAVValueDate = b.NAVValueDate      
      
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  set @cErrMsg = 'Gagal update data redemption fee (1)'      
--  goto ERR_HANDLER      
--end      
--20100111, oscar, REKSADN014, end      
          
--20090715, oscar, REKSADN014, begin          
--update ReksaTransaction_TH set      
--  --SubcFee = case when b.SubcFee < 0.0 then 0.0 else b.SubcFee end,      
--  --SubcFeeBased = case when b.SubcFeeBased < 0.0 then 0.0 else b.SubcFeeBased end,      
--  RedempFee = case when b.RedempFee < 0.0 then 0.0 else b.RedempFee end,      
--  RedempFeeBased = case when b.RedempFeeBased < 0.0 then 0.0 else b.RedempFeeBased end      
--from ReksaTransaction_TH a      
--join #TempTransaction b      
--on a.TranId =  b.TranId      
--and a.TranType = b.TranType      
--and a.ProdId = b.ProdId      
--and a.ClientId = b.ClientId      
--and a.NAVValueDate = b.NAVValueDate      
      
--if @@error <> 0      
--begin      
--  drop table #TempTransaction      
--  set @cErrMsg = 'Gagal update data redemption fee (2)'      
--  goto ERR_HANDLER      
--end      
--20090715, oscar, REKSADN014, end      
      
-- update bill redemption      
--20100111, oscar, REKSADN014, begin      
--ga usah hitung redemption fee      
--if exists (select top 1 1 from ReksaBill_TM a join #TempTransaction b      
--  on a.BillId = b.BillId      
--  and b.TranType in (3,4))      
--begin      
--  if @pbDebug = 1      
--  begin      
--      select 'bill before', *       
--      from ReksaBill_TM a       
--      join #TempTransaction b      
--      on a.BillId = b.BillId      
--      and b.TranType in (3,4)      
      
--      select ra.BillId,      
--          ra.ProdId,      
--          rc.CustodyId,      
--          ra.TranCCY,      
--          sum(case         
--              when ra.TranCCY = 'IDR' then       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 0)        
--                              else round(ra.TranAmt - (ra.RedempFee - ra.RedempFeeBased), 0)      
--                      end      
--              else       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 2)       
--                              else  round(ra.TranAmt - (ra.RedempFee - ra.RedempFeeBased), 2)      
--                      end      
--          end) as TotalBill,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFee,0), 0) else round(isnull(ra.RedempFee,0), 2) end)      
--          end as Fee,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFeeBased,0),0) else round(isnull(ra.RedempFeeBased,0),2) end )      
--          end as FeeBased       
--      from ReksaTransaction_TT ra      
--      join #TempTransaction rt      
--          on ra.BillId = rt.BillId      
--   join ReksaProduct_TM rp      
--          on ra.ProdId = rp.ProdId      
--      join ReksaCustody_TR rc      
--          on rc.CustodyId = rp.CustodyId      
--      group by ra.BillId, ra.ProdId, rc.CustodyId, ra.TranCCY, rp.RedempIncFee              
--  end      
      
--  update ReksaBill_TM set      
--      TotalBill = b.TotalBill,      
--      Fee = b.Fee,      
--      FeeBased = b.FeeBased      
--  from ReksaBill_TM a      
--  join (      
--      select ra.BillId,      
--          ra.ProdId,      
--          rc.CustodyId,      
--          ra.TranCCY,      
--          sum(case         
--              when ra.TranCCY = 'IDR' then       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 0)        
--                              else round(ra.TranAmt - (ra.RedempFee - ra.RedempFeeBased), 0)      
--                      end      
--              else       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 2)       
--                              else  round(ra.TranAmt - (ra.RedempFee - ra.RedempFeeBased), 2)      
--                      end      
--          end) as TotalBill,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFee,0), 0) else round(isnull(ra.RedempFee,0), 2) end)      
--          end as Fee,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFeeBased,0),0) else round(isnull(ra.RedempFeeBased,0),2) end )      
--          end as FeeBased       
--      from ReksaTransaction_TT ra      
--      join #TempTransaction rt      
--          on ra.BillId = rt.BillId      
--      join ReksaProduct_TM rp      
--          on ra.ProdId = rp.ProdId      
--      join ReksaCustody_TR rc      
--          on rc.CustodyId = rp.CustodyId      
--      group by ra.BillId, ra.ProdId, rc.CustodyId, ra.TranCCY, rp.RedempIncFee       
--  ) b      
--      on a.BillId = b.BillId      
--      and a.ProdId = b.ProdId      
--      and a.CustodyId = b.CustodyId      
--      and a.BillCCY = b.TranCCY      
--  join #TempTransaction c      
--      on a.BillId = c.BillId      
--      and c.TranType in (3, 4)      
              
--  if @@error <> 0      
--  begin      
--      set @cErrMsg = 'Gagal hitung ulang data bill'      
--      goto ERR_HANDLER      
--  end      
              
--  if @pbDebug = 1      
--      select 'bill after', *     
--      from ReksaBill_TM a       
--      join #TempTransaction b      
--      on a.BillId = b.BillId      
--      and b.TranType in (3,4)       
--end      
--20100111, oscar, REKSADN014, end      
      
--20090715, oscar, REKSADN014, begin      
--20100111, oscar, REKSADN014, begin       
--ga usah hitung redemption fee      
--if exists (select top 1 1 from ReksaBill_TH a join #TempTransaction b      
--  on a.BillId = b.BillId      
--  and b.TranType in (3,4))      
--begin      
--  if @pbDebug = 1      
--      select 'bill before', *       
--      from ReksaBill_TH a       
--      join #TempTransaction b      
--      on a.BillId = b.BillId      
--      and b.TranType in (3,4)      
      
--  update ReksaBill_TH set      
--      TotalBill = b.TotalBill,      
--      Fee = b.Fee,      
--      FeeBased = b.FeeBased      
--  from ReksaBill_TH a      
--  join (      
--      select ra.BillId,      
--          ra.ProdId,      
--          rc.CustodyId,      
--          ra.TranCcy,      
--          sum(case         
--              when ra.TranCCY = 'IDR' then       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 0)        
--                              else round(ra.TranAmt - (ra.RedempFee - a.RedempFeeBased), 0)      
--                      end      
--              else       
--                      case when rp.RedempIncFee = 0 then round(ra.TranAmt - ra.RedempFee, 2)       
--                              else  round(ra.TranAmt - (ra.RedempFee - ra.RedempFeeBased), 2)      
--                      end      
--          end) as TotalBill,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFee,0), 0) else round(isnull(ra.RedempFee,0), 2) end)      
--          end as Fee,      
--          case when rp.RedempIncFee = 0 then 0      
--              else sum(case when ra.TranCCY = 'IDR' then round(isnull(ra.RedempFeeBased,0),0) else round(isnull(ra.RedempFeeBased,0),2) end )      
--          end as FeeBased       
--      from ReksaTransaction_TH ra      
--      join #TempTransaction rt      
--          on ra.BillId = rt.BillId      
--      join ReksaProduct_TM rp      
--          on ra.ProdId = rp.ProdId      
--      join ReksaCustody_TR rc      
--          on rc.CustodyId = rp.CustodyId      
--      group by ra.BillId, ra.ProdId, rc.CustodyId, ra.TranCCY       
--  ) b      
--      on a.BillId = b.BillId      
--      and a.ProdId = b.ProdId      
--      and a.CustodyId = b.CustodyId      
--      and a.BillCCY = b.TranCCY      
--  join #TempTransaction c      
--      on a.BillId = c.BillId      
--      and c.TranType in (3, 4)      
      
--  if @pbDebug = 1      
--      select 'bill after', *       
--      from ReksaBill_TH a       
--      join #TempTransaction b      
--      on a.BillId = b.BillId      
--      and b.TranType in (3,4)                   
--end      
--20100111, oscar, REKSADN014, end      
--20090715, oscar, REKSADN014, end        
--20100203, oscar, REKSADN014, end
--20180619, sandi, LOGAM09542, begin
select @dCurrWorkingDate = current_working_date, @dPrevWorkingDate = previous_working_date      
from dbo.fnGetWorkingDate()  

select @nPrevWorkingDate = convert(int, convert(char(8),@dPrevWorkingDate,112))      

--Jika EOM      
if (datediff (month, @dPrevWorkingDate, @dCurrWorkingDate)) = 1      
begin      
	select @nPeriod = convert(int, convert(char(8),dateadd(dd, -day(@dCurrWorkingDate),@dCurrWorkingDate),112))   
	
	update a
	set a.NAV = b.NAV,
		a.UnitBalance = b.UnitBalance,
		a.UnitNominal = b.UnitNominal,
		a.SubcUnit = b.SubcUnit,
		a.SubcNominal = b.SubcNominal  
	from ReksaCIFData_TM_EOM a
	join ReksaCIFData_TM b
		on a.ClientId = b.ClientId
		and a.NAVDate = b.NAVDate      
	where a.Period = @nPeriod
end
--20180619, sandi, LOGAM09542, end      
      
/*      
 * Update status batch (3 = completed)      
 */      
update ReksaOSUploadProcessLog_TH      
set [Status] = 3,      
    LastUpdate = getdate()      
where BatchGuid = @pnGuid      
      
if @@error <> 0      
begin      
    drop table #TempTransaction      
    --drop table #TempMtncFeeDetail      
    set @cErrMsg = 'Gagal update status proses batch ' + convert(varchar(50), @pnGuid)       
    goto ERR_HANDLER      
end      
--20120813, liliana, BAALN11003, begin      
--20120824, liliana, BAALN11003, begin      
--exec @nOK = ReksaProcessMFeeByOSUnit @dValueDate, @pnGuid, @dCustodyId, @pbDebug      
          
--if @nOK <> 0 or @@error <> 0      
--begin      
--  set @cErrMsg = 'Proses process maintenance fee gagal'      
--  goto ERR_HANDLER      
--end       
--20120824, liliana, BAALN11003, end      
--20120813, liliana, BAALN11003, end      
      
drop table #TempTransaction      
--drop table #TempMtncFeeDetail      
--20150706, liliana, LIBST13020, begin      
Update ReksaUserProcess_TR      
set LastUser = NULL      
 , ProcessStatus = 0      
where ProcessId = 10      
      
--20150706, liliana, LIBST13020, end      
      
-- buat debug      
if @pbDebug = 0      
    commit tran      
else      
    rollback tran      
      
ERR_HANDLER:      
if isnull(@cErrMsg, '') <> ''      
begin      
--20150706, liliana, LIBST13020, begin      
    Update ReksaUserProcess_TR      
    set LastUser = NULL      
     , ProcessStatus = 0      
    where ProcessId = 10      
      
--20150706, liliana, LIBST13020, end      
    if @@trancount > 0 rollback tran      
    raiserror (@cErrMsg      ,16,1);
    set @nOK = 1      
end      
      
return @nOK
GO