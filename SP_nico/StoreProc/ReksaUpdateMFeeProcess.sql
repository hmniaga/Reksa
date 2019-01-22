CREATE proc [dbo].[ReksaUpdateMFeeProcess]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20120607  
 DESCRIPTION   : proses sinkronisasi maintenance fee (timpa data dari custody)  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20121017, liliana, BAALN11003, berdasar trx date bkn value date  
  20121214, liliana, LOGAM05065, jika blom pernah diinsert , masih bs di sinkronisasi  
  20130108, liliana, LOGAM05065, perbaikan  
  20130115, liliana, BATOY12006, tambah tax fee, feebased 3, feebased 4, feebased 5  
  20130404, liliana, BATOY12006, Ganti jadi 100% + tax%  
  20130408, liliana, BATOY12006, fix  
  20140313, liliana, LIBST13021, biar lebih cepat querynya  
  20141002, liliana, LIBST13021, tambah index  
  20150126, Ferry, LIBST13020, ganti agentid dengan officeid
  20151228, liliana, LIODD15275, update outstanding
  
 END REVISED  
*/  
 @pnGuid   uniqueidentifier,  
 @pbAdHoc  bit = 0,  
 @pbDebug  bit = 0  
as  
set nocount on  
  
declare   
 @nOK  tinyint,  
 @cErrMsg varchar(100)  
 , @dValueDate  datetime  
 , @cTemp   datetime  
 , @nJmlHari   int  
  
 , @nTranId int  
 , @nTranType tinyint  
 , @nProdId int  
 , @nClientId int  
 , @nTranAmt decimal(25,13)  
 , @nTranUnit decimal(25,13)  
 , @nSubcFee decimal(25,13)  
 , @nRedempFee decimal(25,13)  
 , @nSubcFeeBased decimal(25,13)  
 , @nRedempFeeBased decimal(25,13)  
 , @nNAV decimal(25,13)  
 , @dNAVValueDate datetime  
 , @nRedempUnit decimal(25,13)  
 , @nRedempDev  decimal(25,13)  
 , @bByUnit  bit  
 , @nFee   decimal(25,13)  
 , @nFeeBased decimal(25,13)  
 , @bProcess  bit                
 , @dMinDate  datetime  
--20121214, liliana, LOGAM05065, begin  
 , @dDateStart datetime  
 , @dDateEnd  datetime  
--20121214, liliana, LOGAM05065, end  
--20130404, liliana, BATOY12006, begin  
 , @mTotalPctFeeBased  decimal(25,13)  
 , @mDefaultPctTaxFee  decimal(25,13)  
 , @mSubTotalPctFeeBased  decimal(25,13)  
--20130404, liliana, BATOY12006, end   
--20151228, liliana, LIODD15275, begin
 , @bIsRecalculate		int
--20151228, liliana, LIODD15275, end 
   
   
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
if (select Status from ReksaMFeeUploadProcessLog_TH  
 where BatchGuid = @pnGuid) = 0  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' belum diotorisasi'  
 goto ERR_HANDLER  
end  
  
if (select Status from ReksaMFeeUploadProcessLog_TH  
 where BatchGuid = @pnGuid) = 2  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' status ditolak, tidak bisa proses'  
 goto ERR_HANDLER  
end  
  
if (select Status from ReksaMFeeUploadProcessLog_TH  
 where BatchGuid = @pnGuid) = 3  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah diproses'  
 goto ERR_HANDLER  
end  
  
if not exists (select top 1 1 from ReksaMFeeUploadLog_TH rm   
 join ReksaMFeeUploadProcessLog_TH rp  
  on rm.BatchGuid = rp.BatchGuid  
  and rp.Status = 1  
 where rm.BatchGuid = @pnGuid)  
begin  
 set @cErrMsg = 'Tidak ada data yang bisa diproses'  
 goto ERR_HANDLER  
end   
--20130404, liliana, BATOY12006, begin  
select @mDefaultPctTaxFee = PercentageTaxFeeDefault  
from dbo.control_table  
  
set @mSubTotalPctFeeBased = 100  
  
select @mTotalPctFeeBased = @mSubTotalPctFeeBased + @mDefaultPctTaxFee  
--20130404, liliana, BATOY12006, end 
--20151228, liliana, LIODD15275, begin
select @bIsRecalculate = [Type]
from dbo.ReksaMFeeUploadProcessLog_TH
where BatchGuid = @pnGuid
--20151228, liliana, LIODD15275, end               
  
declare @tmpProd table (  
 ProdId  int  
)  
  
insert into @tmpProd  
select ProdId from dbo.ReksaProduct_TM  
where AdHocRecalc = case @pbAdHoc when 0 then AdHocRecalc else 1 end  
  
if @pbAdHoc = 1  
begin  
 -- cek data di batch apa ada yg di luar produk  
 if exists (  
  select top 1 1 from dbo.ReksaMFeeUploadLog_TH mf  
  join dbo.ReksaCIFData_TM rc  
   on mf.ClientId = rc.ClientId  
  left join @tmpProd prod  
   on rc.ProdId = prod.ProdId  
  where prod.ProdId is null  
  and mf.BatchGuid = @pnGuid  
 )  
 begin  
  return 0  
 end  
end  
--20121214, liliana, LOGAM05065, begin  
create table #tempMtncFee (  
 ClientId   int,  
 AgentId    int,   
 TransactionDate  datetime,  
 ValueDate   datetime,  
 ProdId    int,  
 CCY     varchar(3),  
 AmountBefore  decimal(25,13),  
 AmountAfter   decimal(25,13),  
 Selisih    decimal(25,13),  
 NAV     decimal(25,13),  
 UnitBalance   decimal(25,13),  
 SubcUnit   decimal(25,13),  
 IsNew    bit, -- jika blom pernah ada di ReksaMtncFeeDetail_TM IsNew = 1  
 IsPesona   bit  
--20130115, liliana, BATOY12006, begin  
 ,PercentageMFeeBased  decimal(25,13)  
 ,PercentageTaxFeeBased  decimal(25,13)  
 ,PercentageFeeBased3  decimal(25,13)  
 ,PercentageFeeBased4  decimal(25,13)  
 ,PercentageFeeBased5  decimal(25,13)  
 ,MFeeBased  decimal(25,13)  
 ,TaxFeeBased decimal(25,13)  
 ,FeeBased3  decimal(25,13)  
 ,FeeBased4  decimal(25,13)  
 ,FeeBased5  decimal(25,13)  
 ,TotalFeeBased decimal(25,13)  
--20130115, liliana, BATOY12006, end  
--20130404, liliana, BATOY12006, begin  
 ,SelisihFeeBased  decimal(25,13)  
--20130404, liliana, BATOY12006, end   
--20150126, Ferry, LIBST13020, begin
 ,OfficeId varchar(5)
--20150126, Ferry, LIBST13020, end
)  
--20141002, liliana, LIBST13021, begin  
CREATE INDEX Temp_tempMtncFee_idx     
--20150126, Ferry, LIBST13020, begin
 --ON #tempMtncFee (ClientId, AgentId, ValueDate, TransactionDate, ProdId)    
 ON #tempMtncFee (ClientId, OfficeId, ValueDate, TransactionDate, ProdId)    
--20150126, Ferry, LIBST13020, end
--20141002, liliana, LIBST13021, end  
  
  
select @dDateStart = min(ReverseTanggalTransaksi),  
    @dDateEnd = max(ReverseTanggalTransaksi)  
from dbo.ReksaMFeeUploadLog_TH  
where BatchGuid = @pnGuid  
  
select @nProdId = ProdId  
from dbo.ReksaMFeeUploadLog_TH  
where BatchGuid = @pnGuid  
  
--20130108, liliana, LOGAM05065, begin  
--select *   
--into #ReksaMtncFeeDetail_TM  
--20150126, Ferry, LIBST13020, begin
--insert dbo.ReksaMtncFeeDetail_TMP (ClientId, AgentId, TransactionDate, ValueDate, ProdId, CCY,   
insert dbo.ReksaMtncFeeDetail_TMP (ClientId, OfficeId, TransactionDate, ValueDate, ProdId, CCY,  
--20150126, Ferry, LIBST13020, end
 Amount, NAV, UnitBalance, SubcUnit, [Type], UserSuid, OutstandingDate  
)  
--20150126, Ferry, LIBST13020, begin
select ClientId, OfficeId, TransactionDate, ValueDate, ProdId, CCY,   
--20150126, Ferry, LIBST13020, end
 Amount, NAV, UnitBalance, SubcUnit, [Type], UserSuid, OutstandingDate  
--20130108, liliana, LOGAM05065, end  
from dbo.ReksaMtncFeeDetail_TM  
where TransactionDate >= @dDateStart  
   and TransactionDate <= @dDateEnd  
   and ProdId = @nProdId  
--20121214, liliana, LOGAM05065, end  
  
-- mulai proses  
begin tran  
  
--20121214, liliana, LOGAM05065, begin    
--20150126, Ferry, LIBST13020, begin
--insert #tempMtncFee (ClientId, AgentId, TransactionDate, ValueDate, ProdId, CCY,  
insert #tempMtncFee (ClientId, OfficeId, TransactionDate, ValueDate, ProdId, CCY,  
--20150126, Ferry, LIBST13020, end
  AmountBefore, AmountAfter, Selisih, NAV, UnitBalance, SubcUnit, IsNew, IsPesona)  
--20121214, liliana, LOGAM05065, end  
--20150126, Ferry, LIBST13020, begin
--select rm.ClientId, rm.AgentId, rm.TransactionDate, rm.ValueDate, rm.ProdId, rm.CCY,  
select rm.ClientId, rm.OfficeId, rm.TransactionDate, rm.ValueDate, rm.ProdId, rm.CCY,  
--20150126, Ferry, LIBST13020, end
    rm.Amount as AmountBefore,  
    mu.NominalMaintenanceFeeAfter as AmountAfter,  
    mu.NominalMaintenanceFeeAfter - rm.Amount as Selisih,  
    rm.NAV,  
    rm.UnitBalance,  
    rm.SubcUnit  
--20121214, liliana, LOGAM05065, begin      
--into #tempMtncFee  
--from dbo.ReksaMtncFeeDetail_TM rm  
  , 0  
  , rp.IsPesonaAmanah  
--20130108, liliana, LOGAM05065, begin    
--from #ReksaMtncFeeDetail_TM rm  
from dbo.ReksaMtncFeeDetail_TMP rm  
--20130108, liliana, LOGAM05065, end  
join dbo.ReksaProduct_TM rp  
 on rp.ProdId = rm.ProdId  
--20121214, liliana, LOGAM05065, end  
join dbo.ReksaMFeeUploadLog_TH mu  
 on rm.ClientId = mu.ClientId  
--20121017, liliana, BAALN11003, begin  
 --and mu.ReverseTanggalTransaksi = rm.ValueDate  
 and mu.ReverseTanggalTransaksi = rm.TransactionDate  
--20121017, liliana, BAALN11003, end  
where mu.BatchGuid = @pnGuid  
and rm.Type = 1  
--20121214, liliana, LOGAM05065, begin  
  
--insert juga yg belom pernah ada di ReksaMtncFeeDetail_TM  
--20150126, Ferry, LIBST13020, begin
--insert #tempMtncFee (ClientId, AgentId, TransactionDate, ProdId, CCY,  
insert #tempMtncFee (ClientId, OfficeId, TransactionDate, ProdId, CCY,  
--20150126, Ferry, LIBST13020, end
  AmountBefore, AmountAfter, Selisih, IsNew, IsPesona)  
--20150126, Ferry, LIBST13020, begin
--select mu.ClientId, mu.AgentId, mu.ReverseTanggalTransaksi, mu.ProdId, rp.ProdCCY,  
select mu.ClientId, rmn.OfficeId, mu.ReverseTanggalTransaksi, mu.ProdId, rp.ProdCCY,  
--20150126, Ferry, LIBST13020, end
  0, mu.NominalMaintenanceFeeAfter, 0 - mu.NominalMaintenanceFeeAfter, 1, rp.IsPesonaAmanah  
from dbo.ReksaMFeeUploadLog_TH mu  
--20130108, liliana, LOGAM05065, begin   
--left join dbo.#ReksaMtncFeeDetail_TM rm  
left join dbo.ReksaMtncFeeDetail_TMP rm  
--20130108, liliana, LOGAM05065, end  
 on rm.ClientId = mu.ClientId  
 and mu.ReverseTanggalTransaksi = rm.TransactionDate  
join dbo.ReksaProduct_TM rp  
 on rp.ProdId = mu.ProdId  
--20150126, Ferry, LIBST13020, begin
left join dbo.ReksaCIFData_TM rcd
 on rcd.ClientId = rm.ClientId
left join dbo.ReksaMasterNasabah_TM rmn
 on rmn.CIFNo = rcd.CIFNo
--20150126, Ferry, LIBST13020, end
where mu.BatchGuid = @pnGuid  
 and rm.ClientId is null  
 and rm.TransactionDate is null  
   
--update value date   
update #tempMtncFee  
set ValueDate =    
  case when (exists(select top 1 1 from dbo.ReksaHolidayTable_TM where ValueDate = TransactionDate)   
   or DATEPART(dw, TransactionDate) in (1,7))   
   then dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(TransactionDate, 0), -1)  
  else   
   TransactionDate  
  end  
where IsNew = 1  
 and isnull(IsPesona,0) = 0  
   
update #tempMtncFee  
set ValueDate =    
  case when (exists(select top 1 1 from dbo.ReksaHolidayTable_TM where ValueDate = TransactionDate)   
   or DATEPART(dw, TransactionDate) in (1,7))   
   then dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(TransactionDate, 0), -2)  
  else   
   dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(TransactionDate, 0), -1)  
  end  
where IsNew = 1  
 and isnull(IsPesona,0) = 1   
--20121214, liliana, LOGAM05065, end  
--20130115, liliana, BATOY12006, begin  
--cari persen nya  
update pa  
set PercentageMFeeBased = isnull(rl.Percentage, 0)  
from #tempMtncFee pa  
join dbo.ReksaListGLFee_TM rl  
--20130408, liliana, BATOY12006, begin  
 --on ts.ProdId = rl.ProdId  
 on pa.ProdId = rl.ProdId  
--20130408, liliana, BATOY12006, end   
where rl.TrxType = 'MFEE'  
   and rl.Sequence = 1  
  
update pa  
set PercentageTaxFeeBased = isnull(rl.Percentage, 0)  
from #tempMtncFee pa  
join dbo.ReksaListGLFee_TM rl  
--20130408, liliana, BATOY12006, begin  
 --on ts.ProdId = rl.ProdId  
 on pa.ProdId = rl.ProdId  
--20130408, liliana, BATOY12006, end   
where rl.TrxType = 'MFEE'  
   and rl.Sequence = 2  
  
update pa  
set PercentageFeeBased3 = isnull(rl.Percentage, 0)  
from #tempMtncFee pa  
join dbo.ReksaListGLFee_TM rl  
--20130408, liliana, BATOY12006, begin  
 --on ts.ProdId = rl.ProdId  
 on pa.ProdId = rl.ProdId  
--20130408, liliana, BATOY12006, end   
where rl.TrxType = 'MFEE'  
   and rl.Sequence = 3     
     
update pa  
set PercentageFeeBased4 = isnull(rl.Percentage, 0)  
from #tempMtncFee pa  
join dbo.ReksaListGLFee_TM rl  
--20130408, liliana, BATOY12006, begin  
 --on ts.ProdId = rl.ProdId  
 on pa.ProdId = rl.ProdId  
--20130408, liliana, BATOY12006, end   
where rl.TrxType = 'MFEE'  
   and rl.Sequence = 4     
     
update pa  
set PercentageFeeBased5 = isnull(rl.Percentage, 0)  
from #tempMtncFee pa  
join dbo.ReksaListGLFee_TM rl  
--20130408, liliana, BATOY12006, begin  
 --on ts.ProdId = rl.ProdId  
 on pa.ProdId = rl.ProdId  
--20130408, liliana, BATOY12006, end   
where rl.TrxType = 'MFEE'  
   and rl.Sequence = 5   
     
update #tempMtncFee  
--20130404, liliana, BATOY12006, begin  
--set MFeeBased = cast(cast(PercentageMFeeBased/100.00 as decimal(25,13)) * AmountAfter as decimal(25,13)),  
--    TaxFeeBased = cast(cast(PercentageTaxFeeBased/100.00 as decimal(25,13)) * AmountAfter as decimal(25,13)),   
--    FeeBased3 = cast(cast(PercentageFeeBased3/100.00 as decimal(25,13)) * AmountAfter as decimal(25,13)),    
--    FeeBased4 = cast(cast(PercentageFeeBased4/100.00 as decimal(25,13)) * AmountAfter as decimal(25,13)),  
--    FeeBased5 = cast(cast(PercentageFeeBased5/100.00 as decimal(25,13)) * AmountAfter as decimal(25,13))  
set MFeeBased = cast(cast(PercentageMFeeBased/@mTotalPctFeeBased as decimal(25,13)) * AmountAfter as decimal(25,13)),  
    TaxFeeBased = cast(cast(PercentageTaxFeeBased/@mTotalPctFeeBased as decimal(25,13)) * AmountAfter as decimal(25,13)),   
    FeeBased3 = cast(cast(PercentageFeeBased3/@mTotalPctFeeBased as decimal(25,13)) * AmountAfter as decimal(25,13)),    
    FeeBased4 = cast(cast(PercentageFeeBased4/@mTotalPctFeeBased as decimal(25,13)) * AmountAfter as decimal(25,13)),  
    FeeBased5 = cast(cast(PercentageFeeBased5/@mTotalPctFeeBased as decimal(25,13)) * AmountAfter as decimal(25,13))      
--20130404, liliana, BATOY12006, end       
      
update #tempMtncFee  
set TotalFeeBased = isnull(MFeeBased, 0) +  isnull(TaxFeeBased, 0) + isnull(FeeBased3, 0) + isnull(FeeBased4, 0) + isnull(FeeBased5, 0)       
--20130115, liliana, BATOY12006, end  
--20130404, liliana, BATOY12006, begin  
  
update #tempMtncFee  
set SelisihFeeBased = isnull(AmountAfter, 0) - isnull(TotalFeeBased, 0)  
  
update #tempMtncFee  
set MFeeBased = isnull(MFeeBased, 0) + isnull(SelisihFeeBased, 0)  
--20130404, liliana, BATOY12006, end  
  
--debug  
if @pbDebug = 1  
begin  
 print 'Maintenance Fee'  
 select * from #tempMtncFee  
end  
  
--20121214, liliana, LOGAM05065, begin  
--update #tempMtncFee  
--set UnitBalance = hist.UnitBalance  
-- , NAV = nav.NAV  
--from #tempMtncFee tm  
--join dbo.ReksaCIFData_TM cif  
-- on tm.ClientId = cif.ClientId  
--join dbo.ReksaMFeeUploadLog_TH mf  
-- on cif.ClientId = mf.ClientId  
----20121017, liliana, BAALN11003, begin  
-- --and tm.ValueDate = mf.ReverseTanggalTransaksi  
-- and tm.TransactionDate = mf.ReverseTanggalTransaksi  
----20121017, liliana, BAALN11003, end  
-- and mf.BatchGuid = @pnGuid  
--join dbo.ReksaNAVParam_TH nav  
-- on tm.ProdId = nav.ProdId   
-- and nav.ValueDate = case   
--  when (exists(select top 1 1 from dbo.ReksaHolidayTable_TM where ValueDate = mf.ReverseTanggalTransaksi)   
--   or DATEPART(dw, mf.ReverseTanggalTransaksi) in (1,7))   
--   then dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(mf.ReverseTanggalTransaksi, 0), -1)  
--  else   
--   mf.ReverseTanggalTransaksi  
--  end  
--join ReksaCIFDataHist_TM hist  
-- on hist.ClientId = tm.ClientId  
-- and hist.TransactionDate = dateadd(dd, -1, mf.ReverseTanggalTransaksi)  
update tm  
set NAV = nav.NAV  
from #tempMtncFee tm  
join dbo.ReksaNAVParam_TH nav  
 on tm.ProdId = nav.ProdId   
 and nav.ValueDate = tm.ValueDate  
  
update tm  
set UnitBalance = hist.UnitBalance  
from #tempMtncFee tm  
join dbo.ReksaCIFData_TM cif  
 on tm.ClientId = cif.ClientId  
join dbo.ReksaCIFDataHist_TM hist  
 on hist.ClientId = cif.ClientId  
 and hist.TransactionDate = dateadd(dd, -1, tm.ValueDate)  
--20121214, liliana, LOGAM05065, end   
   
if @@error <> 0  
begin  
 drop table #tempMtncFee  
 set @cErrMsg = 'Gagal update unit balance di detail maintenance fee'  
 goto ERR_HANDLER  
end   
  
update rm  
set UnitBalance = mu.UnitBalance  
 , NAV = mu.NAV  
from dbo.ReksaMtncFeeDetail_TM rm  
join #tempMtncFee mu  
 on rm.ClientId = mu.ClientId  
--20121017, liliana, BAALN11003, begin  
 --and mu.ValueDate = rm.ValueDate  
 and mu.TransactionDate = rm.TransactionDate   
--20121017, liliana, BAALN11003, end  
--20121214, liliana, LOGAM05065, begin  
where mu.IsNew = 0  
--20121214, liliana, LOGAM05065, end 
--20151228, liliana, LIODD15275, begin

if @bIsRecalculate = 1
begin
	update rmfd
	set UnitBalance = rmfu.UnitBalance,
		NAV = rmfu.NAV
	from dbo.ReksaMtncFeeDetail_TM rmfd
	join #tempMtncFee mu  
		on rmfd.ClientId = mu.ClientId  
		and mu.TransactionDate = rmfd.TransactionDate   
	join dbo.ReksaCIFData_TM rc
		on rmfd.ClientId = rc.ClientId
	join dbo.ReksaRecalcMFeeUploadLog_TH rmfu
		on rmfu.ClientCode = rc.ClientCode
		and rmfu.ReverseTanggalTransaksi  = rmfd.TransactionDate 
	where rmfu.BatchGuid = @pnGuid
end
--20151228, liliana, LIODD15275, end 
  
update rm  
set Amount = mu.AmountAfter  
--20130115, liliana, BATOY12006, begin  
 , MFeeBased = mu.MFeeBased  
 , TaxFeeBased = mu.TaxFeeBased  
 , FeeBased3 = mu.FeeBased3  
 , FeeBased4 = mu.FeeBased4  
 , FeeBased5 = mu.FeeBased5  
 , TotalFeeBased = mu.TotalFeeBased  
--20130115, liliana, BATOY12006, end  
from dbo.ReksaMtncFeeDetail_TM rm  
join #tempMtncFee mu  
 on rm.ClientId = mu.ClientId  
--20121017, liliana, BAALN11003, begin   
 --and mu.ValueDate = rm.ValueDate  
 and mu.TransactionDate = rm.TransactionDate  
--20121017, liliana, BAALN11003, end  
--20121214, liliana, LOGAM05065, begin  
where mu.IsNew = 0  
  
--insert yg belum ada  
--20150126, Ferry, LIBST13020, begin
--insert dbo.ReksaMtncFeeDetail_TM (ClientId, AgentId, ProdId, CCY  
insert dbo.ReksaMtncFeeDetail_TM (ClientId, OfficeId, ProdId, CCY  
--20150126, Ferry, LIBST13020, end
 , Amount, TransactionDate, ValueDate, UserSuid, Type  
 , OutstandingDate    
--20130115, liliana, BATOY12006, begin  
  ,MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130115, liliana, BATOY12006, end   
 , NAV, UnitBalance, SubcUnit, ProtekLastUnit)  
--20150126, Ferry, LIBST13020, begin
--select tm.ClientId, tm.AgentId, tm.ProdId, tm.CCY  
select tm.ClientId, tm.OfficeId, tm.ProdId, tm.CCY  
--20150126, Ferry, LIBST13020, end
 , tm.AmountAfter, tm.TransactionDate, tm.ValueDate, 7, 1     
 , case when tm.IsPesona = 1 then tm.ValueDate   
     else dbo.fnReksaGetEffectiveDate(dbo.fnReksaGetEffectiveDate(tm.ValueDate, 0), -1)  
   end  
--20130115, liliana, BATOY12006, begin  
  ,tm.MFeeBased, tm.TaxFeeBased, tm.FeeBased3, tm.FeeBased4, tm.FeeBased5, tm.TotalFeeBased  
--20130115, liliana, BATOY12006, end     
 , tm.NAV, tm.UnitBalance, tm.UnitBalance * tm.NAV, NULL  
from #tempMtncFee tm  
where tm.IsNew = 1  
order by tm.TransactionDate  
--20121214, liliana, LOGAM05065, end     
   
  
insert into dbo.ReksaMFeeChangeRecord_TH  
(SyncDate, MntcTrxDate, MntcValueDate, ProdId, ClientCode,   
FieldName, OldValue, NewValue, Remarks)  
select getdate(), rm.TransactionDate, rm.ValueDate, rm.ProdId, rc.ClientCode,   
'Amount Maintenance Fee', mu.AmountBefore, rm.Amount, 'Sync M Fee Ref ' + convert(varchar(40), @pnGuid)  
--20121214, liliana, LOGAM05065, begin  
--from dbo.ReksaMtncFeeDetail_TM rm  
--20130108, liliana, LOGAM05065, begin  
--from #ReksaMtncFeeDetail_TM rm  
from dbo.ReksaMtncFeeDetail_TMP rm  
--20130108, liliana, LOGAM05065, end  
--20121214, liliana, LOGAM05065, end  
join #tempMtncFee mu  
 on rm.ClientId = mu.ClientId  
--20121017, liliana, BAALN11003, begin  
 --and mu.ValueDate = rm.ValueDate  
 and mu.TransactionDate = rm.TransactionDate  
--20121017, liliana, BAALN11003, end   
 and rm.Type = 1  
join ReksaCIFData_TM rc  
 on rm.ClientId = rc.ClientId  
where rm.Amount <> mu.AmountBefore  
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal mencatat perubahan data'  
 goto ERR_HANDLER  
end  
  
  
-- hitung ulang ReksaMtncFee_TM  
update dbo.ReksaMtncFee_TM  
set Amount = b.Amount,  
 TotalUnit = b.TotalUnit,  
 TotalNominal = b.TotalNominal  
from ReksaMtncFee_TM rm  
join (  
 select  
--20121017, liliana, BAALN11003, begin   
  --rd.ValueDate,   
  rd.TransactionDate,   
--20121017, liliana, BAALN11003, end  
  rd.ProdId,   
--20150126, Ferry, LIBST13020, begin
  --rd.AgentId,   
  rd.OfficeId,   
--20150126, Ferry, LIBST13020, end
  sum(rd.Amount) as Amount,   
  sum(rd.UnitBalance) as TotalUnit,   
  sum(dbo.fnReksaSetRounding(rd.ProdId, 3, rd.NAV * rd.UnitBalance)) as TotalNominal  
 from ReksaMtncFeeDetail_TM rd  
 join ReksaCIFData_TM rc  
--20150126, Ferry, LIBST13020, begin
  --on rd.AgentId = rc.AgentId  
  --and rd.ClientId = rc.ClientId  
  on rd.ClientId = rc.ClientId
--20150126, Ferry, LIBST13020, end
 join ReksaMFeeUploadLog_TH rl  
  on rc.ClientId = rl.ClientId  
  and rl.BatchGuid = @pnGuid  
--20121017, liliana, BAALN11003, begin    
  --and rd.ValueDate = rl.ReverseTanggalTransaksi  
  --group by rd.ValueDate, rd.ProdId, rd.AgentId  
  and rd.TransactionDate = rl.ReverseTanggalTransaksi  
--20150126, Ferry, LIBST13020, begin
  --group by rd.TransactionDate, rd.ProdId, rd.AgentId  
  group by rd.TransactionDate, rd.ProdId, rd.OfficeId
--20150126, Ferry, LIBST13020, end
--20121017, liliana, BAALN11003, end    
) b  
 on rm.ProdId = b.ProdId  
--20150126, Ferry, LIBST13020, begin
 --and rm.AgentId = b.AgentId  
 and rm.OfficeId = b.OfficeId
--20150126, Ferry, LIBST13020, end
--20121017, liliana, BAALN11003, begin    
 --and rm.ValueDate = b.ValueDate  
 and rm.TransactionDate = b.TransactionDate   
--20121017, liliana, BAALN11003, end  
--20121214, liliana, LOGAM05065, begin  
--20130108, liliana, LOGAM05065, begin  
--delete rm  
--from ReksaMtncFee_TM rm  
--join (  
-- select  
--  rd.TransactionDate,   
--  rd.ProdId,   
--  rd.AgentId,   
--  sum(rd.Amount) as Amount,   
--  sum(rd.UnitBalance) as TotalUnit,   
--  sum(dbo.fnReksaSetRounding(rd.ProdId, 3, rd.NAV * rd.UnitBalance)) as TotalNominal  
-- from ReksaMtncFeeDetail_TM rd  
-- join ReksaCIFData_TM rc  
--  on rd.AgentId = rc.AgentId  
--  and rd.ClientId = rc.ClientId  
-- join ReksaMFeeUploadLog_TH rl  
--  on rc.ClientId = rl.ClientId  
--  and rl.BatchGuid = @pnGuid  
--  and rd.TransactionDate = rl.ReverseTanggalTransaksi  
--  group by rd.TransactionDate, rd.ProdId, rd.AgentId    
--) b  
-- on rm.ProdId = b.ProdId  
-- and rm.AgentId = b.AgentId  
-- and rm.TransactionDate = b.TransactionDate   
  
  
--insert dbo.ReksaMtncFee_TM (AgentId, TransactionDate, ValueDate, ProdId, CCY, Amount, Settled, SettleDate, Type, UserSuid, TotalAccount, TotalUnit, TotalNominal)  
--select rd.AgentId, rd.TransactionDate, rd.ValueDate, rd.ProdId, rd.CCY, sum(rd.Amount), 1, getdate(), 1, 7, count(*), sum(rd.UnitBalance), sum(rd.SubcUnit)  
--from dbo.ReksaMtncFeeDetail_TM rd  
-- join ReksaCIFData_TM rc  
--  on rd.AgentId = rc.AgentId  
--  and rd.ClientId = rc.ClientId  
-- join ReksaMFeeUploadLog_TH rl  
--  on rc.ClientId = rl.ClientId  
--  and rd.TransactionDate = rl.ReverseTanggalTransaksi  
--  and rl.BatchGuid = @pnGuid  
--group by rd.AgentId, rd.TransactionDate, rd.ValueDate, rd.ProdId, rd.CCY  
--order by rd.TransactionDate  
delete from dbo.ReksaMtncFee_TM  
where TransactionDate >= @dDateStart and TransactionDate <= @dDateEnd  
and ProdId = @nProdId  
  
--20150126, Ferry, LIBST13020, begin
--insert dbo.ReksaMtncFee_TM (AgentId, TransactionDate, ValueDate, ProdId, CCY, Amount, Settled, SettleDate, Type, UserSuid, TotalAccount, TotalUnit, TotalNominal  
insert dbo.ReksaMtncFee_TM (OfficeId, TransactionDate, ValueDate, ProdId, CCY, Amount, Settled, SettleDate, Type, UserSuid, TotalAccount, TotalUnit, TotalNominal  
--20150126, Ferry, LIBST13020, end
--20130115, liliana, BATOY12006, begin  
  ,MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
--20130115, liliana, BATOY12006, end  
)  
--20150126, Ferry, LIBST13020, begin
--select AgentId, TransactionDate, ValueDate, ProdId, CCY, sum(Amount), 1, getdate(), 1, 7, count(*), sum(UnitBalance), sum(SubcUnit)  
select OfficeId, TransactionDate, ValueDate, ProdId, CCY, sum(Amount), 1, getdate(), 1, 7, count(*), sum(UnitBalance), sum(SubcUnit)  
--20150126, Ferry, LIBST13020, end
--20130115, liliana, BATOY12006, begin  
  ,sum(MFeeBased), sum(TaxFeeBased), sum(FeeBased3), sum(FeeBased4), sum(FeeBased5), sum(TotalFeeBased)  
--20130115, liliana, BATOY12006, end  
from dbo.ReksaMtncFeeDetail_TM  
where TransactionDate >= @dDateStart and TransactionDate <= @dDateEnd  
  and ProdId = @nProdId  
--20150126, Ferry, LIBST13020, begin
--group by AgentId, TransactionDate, ValueDate, ProdId, CCY  
group by OfficeId, TransactionDate, ValueDate, ProdId, CCY  
--20150126, Ferry, LIBST13020, end
order by TransactionDate      
--20130108, liliana, LOGAM05065, end  
--20121214, liliana, LOGAM05065, end   
  
if @@error <> 0  
begin  
 drop table #tempMtncFee  
 set @cErrMsg = 'Gagal hitung ulang data maintenance fee'  
 goto ERR_HANDLER  
end  
  
--hitung ulang bill  
--20140313, liliana, LIBST13021, begin    
--update ReksaBill_TM     
--set TotalBill = b.Amount    
--from ReksaBill_TM rb    
--join (    
-- select rm.BillId,     
--  sum(dbo.fnReksaSetRounding(rm.ProdId, 3, rm.Amount)) as Amount    
-- from ReksaMtncFee_TM rm    
-- join dbo.ReksaMFeeUploadLog_TH rf    
----20121017, liliana, BAALN11003, begin     
-- --on rm.ValueDate = rf.ReverseTanggalTransaksi    
-- on rm.TransactionDate = rf.ReverseTanggalTransaksi     
----20121017, liliana, BAALN11003, end     
-- and rm.ProdId = rf.ProdId    
-- where rm.Settled = 0    
-- and rm.BillId is not null    
-- group by rm.BillId    
--) b    
--on rb.BillId = b.BillId    
select * into #temp_ReksaMtncFee_TM     
from ReksaMtncFee_TM     
 where Settled = 0     
  and BillId is not null   
--20141002, liliana, LIBST13021, begin  
  
create index Temp_temp_ReksaMtncFee_TM_idx    
on #temp_ReksaMtncFee_TM (TransactionDate, ProdId)    
    
create table #temp_ReksaBillSum    
 (    
 BillId int    
 , Amount decimal(25,13)    
 )    
   
insert #temp_ReksaBillSum    
select rm.BillId,     
 sum(dbo.fnReksaSetRounding(rm.ProdId, 3, isnull(rm.Amount,0))) as Amount    
from #temp_ReksaMtncFee_TM rm    
 join dbo.ReksaMFeeUploadLog_TH rf    
  on rm.TransactionDate = rf.ReverseTanggalTransaksi     
   and rm.ProdId = rf.ProdId    
group by rm.BillId    
    
create index Temp_temp_ReksaBillSum_idx  on #temp_ReksaBillSum (BillId)    
--20141002, liliana, LIBST13021, end    
    
update ReksaBill_TM     
set TotalBill = b.Amount    
from ReksaBill_TM rb    
--20141002, liliana, LIBST13021, begin  
--join (    
-- select rm.BillId,     
--  sum(dbo.fnReksaSetRounding(rm.ProdId, 3, rm.Amount)) as Amount    
-- from #temp_ReksaMtncFee_TM rm    
--  join dbo.ReksaMFeeUploadLog_TH rf    
--   on rm.TransactionDate = rf.ReverseTanggalTransaksi     
--    and rm.ProdId = rf.ProdId    
-- group by rm.BillId    
--) b   
join #temp_ReksaBillSum b   
--20141002, liliana, LIBST13021, end   
on rb.BillId = b.BillId    
    
drop table #temp_ReksaMtncFee_TM    
--20140313, liliana, LIBST13021, end  
  
if @@error <> 0  
begin  
 drop table #tempMtncFee  
 set @cErrMsg = 'Gagal hitung ulang bill maintenance fee'  
 goto ERR_HANDLER  
end  
  
/*  
 * Update status batch (3 = completed)  
 */  
update dbo.ReksaMFeeUploadProcessLog_TH  
set [Status] = 3,  
 LastUpdate = getdate()  
where BatchGuid = @pnGuid  
  
if @@error <> 0  
begin  
 drop table #tempMtncFee  
 set @cErrMsg = 'Gagal update status proses batch ' + convert(varchar(50), @pnGuid)   
 goto ERR_HANDLER  
end  
  
drop table #tempMtncFee  
--20130108, liliana, LOGAM05065, begin  
delete dbo.ReksaMtncFeeDetail_TMP  
--20130108, liliana, LOGAM05065, end  
--20141002, liliana, LIBST13021, begin  
drop table #temp_ReksaBillSum    
--20141002, liliana, LIBST13021, end  
  
-- buat debug  
if @pbDebug = 0  
 commit tran  
else  
 rollback tran  
  
ERR_HANDLER:  
if isnull(@cErrMsg, '') <> ''  
begin  
 if @@trancount > 0 rollback tran  
 raiserror (@cErrMsg  ,16,1)
 set @nOK = 1  
end  
  
return @nOK
GO