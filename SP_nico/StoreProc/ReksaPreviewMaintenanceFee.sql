CREATE Proc [dbo].[ReksaPreviewMaintenanceFee]  
/*  
 CREATED BY    :   
 CREATION DATE :  
 DESCRIPTION   :   
 REVISED BY    :  
  DATE,  USER,  PROJECT,  NOTE  
  -----------------------------------------------------------------------  
	20160108, liliana, LIODD15275, pengecekan jika produk tsb sudah diproses billnya
	20160108, liliana, LIODD15275, tampilkan prod code
 END REVISED  
*/  

 @pdStartDate       datetime  
 , @pdEndDate       datetime  
 , @pnNIK           int  
 , @pcGuid          varchar(50)  
 , @pcProdId        varchar(max)  
As  
  
Set Nocount On  
Declare  
 @nErrNo        int  
 ,@nOK          int   
 ,@cErrMsg      varchar(100)  
 ,@nBillId      int  
 ,@nProdId      int  
 ,@dCurrWorkingDate datetime  
 ,@dNextWorkingDate datetime  
 ,@dTranDate        datetime
 ,@docHdl           int  
 ,@xXMLData         XML  
--20160108, liliana, LIODD15275, begin
 , @cInvalidData	varchar(8000)
--20160108, liliana, LIODD15275, end 
   
  
select  @dCurrWorkingDate = current_working_date  
  , @dNextWorkingDate = next_working_date  
  , @dTranDate = getdate()  
from dbo.fnGetWorkingDate()  
  
  
if @pdEndDate >= @dCurrWorkingDate   
Begin  
 Set @cErrMsg = 'Tanggal akhir harus lebih kecil dari hari ini'  
 Goto Error  
End  
  
  
set @pdStartDate = convert(char(8), @pdStartDate, 112)  
set @pdEndDate = convert(char(8), @pdEndDate, 112)  
  
if @pdStartDate > @pdEndDate  
begin  
 set @cErrMsg = 'Tgl mulai hrs <= tgl akhir'  
 goto Error  
end  

if @pdStartDate >= @dCurrWorkingDate  
begin  
 set @cErrMsg = 'Tanggal mulai harus lebih kecil dari hari ini'  
 goto Error  
end 


-- baca XML  
create table #xml  (  
    CheckB          bit,
    ProdId          int,
    ProdCode        varchar(20),
    ProdName        varchar(100),
    CustodyCode     varchar(20)
)  

create index IDX_TEMPE_XML ON #xml(ProdId) 

CREATE TABLE #ReksaBill_TM(
    [BillType] [tinyint] NULL,
    [BillName] [varchar](100) NULL,
    [DebitCredit] [char](1) NULL,
    [CreateDate] [datetime] NULL,
    [ValueDate] [datetime] NULL,
    [ProdCode] [varchar](20) NULL,
    [CustodyCode] [varchar](20) NULL,
    [BillCCY] [char](3) NULL,
    [TotalBill] [decimal](25, 13) NULL,
    [Fee] [decimal](25, 13) NULL,
    [FeeBased] [decimal](25, 13) NULL,
    [CheckerSuid] [int] NULL,
    [TaxFeeBased] [decimal](25, 13) NULL,
    [FeeBased3] [decimal](25, 13) NULL,
    [FeeBased4] [decimal](25, 13) NULL,
    [FeeBased5] [decimal](25, 13) NULL
) 

create index IDX_TEMPEBILL_XML ON #ReksaBill_TM(ProdCode) 


CREATE TABLE #ReksaMtncFee_TM(
    [BillId] [int] NULL,
    [OfficeId] [varchar](10) NULL,
    [TransactionDate] [datetime] NULL,
    [ValueDate] [datetime] NULL,
    [ProdId] [int] NULL,
    [CCY] [char](3) NULL,
    [Amount] [decimal](26, 13) NULL,
    [Settled] [bit] NULL,
    [SettleDate] [datetime] NULL,
    [Type] [tinyint] NULL,
    [UserSuid] [int] NULL,
    [TotalAccount] [int] NULL,
    [TotalUnit] [decimal](26, 13) NULL,
    [TotalNominal] [decimal](26, 13) NULL,
    [MFeeBased] [decimal](25, 13) NULL,
    [TaxFeeBased] [decimal](25, 13) NULL,
    [FeeBased3] [decimal](25, 13) NULL,
    [FeeBased4] [decimal](25, 13) NULL,
    [FeeBased5] [decimal](25, 13) NULL,
    [TotalFeeBased] [decimal](25, 13) NULL
)
 
create index IDX_TEMPEMTNC_XML ON #ReksaMtncFee_TM(OfficeId, ProdId , TransactionDate)   
   
   
set @xXMLData = convert(xml,@pcProdId)    
   
if @@error <> 0  
begin  
    set @cErrMsg = 'Gagal Convert Data ke XML'   
    goto Error  
end  
  
-- baca isi tabel  
insert into #xml (  
 CheckB, ProdId, ProdCode, ProdName, CustodyCode  
)  
select       
  Detail.Loc.value('@CheckB', 'bit') as 'CheckB',      
  Detail.Loc.value('@ProdId', 'int') as 'ProdId',       
  Detail.Loc.value('@ProdCode', 'varchar(20)') as 'ProdCode',    
  Detail.Loc.value('@ProdName', 'varchar(100)') as 'ProdName',     
  Detail.Loc.value('@CustodyCode', 'varchar(20)') as 'CustodyCode'
 from @xXMLData.nodes('/A/I') as Detail(Loc)    
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal baca data XML'  
 goto Error  
end  
  
-- cek isi data  
if not exists (select top 1 1 from #xml where CheckB = 1)  
begin  
 set @cErrMsg = 'Mohon memilih produk terlebih dahulu'  
 goto Error 
end 
--20160108, liliana, LIODD15275, begin

select distinct rm.BillId
into #tempBill
from ReksaMtncFee_TM rm
join #xml x 
	on x.ProdId = rm.ProdId
where x.CheckB = 1
	and isnull(rm.BillId,'') != ''
   and rm.TransactionDate >= @pdStartDate  
   and rm.TransactionDate < dateadd(dd, 1, @pdEndDate)	

--20160108, liliana, LIODD15275, begin
--select @cInvalidData = coalesce(@cInvalidData + ', ', '') +  convert(varchar(12),rb.ProdId)
select @cInvalidData = coalesce(@cInvalidData + ', ', '') +  convert(varchar(50),rp.ProdCode)    
--20160108, liliana, LIODD15275, end
from dbo.ReksaBill_TM rb  
join #tempBill tb
	on rb.BillId = tb.BillId
--20160108, liliana, LIODD15275, begin
join dbo.ReksaProduct_TM rp
	on rp.ProdId = rb.ProdId
--20160108, liliana, LIODD15275, end	
where rb.BillType = 4 

if (isnull(@cInvalidData,'') <> '')  
begin  
 set @cErrMsg = 'Produk berikut ini : ' + @cInvalidData + ' sudah pernah di cut off !'       
 goto Error  
end 

drop table #tempBill
--20160108, liliana, LIODD15275, end 
  
    
  insert #ReksaMtncFee_TM (OfficeId, ProdId, CCY  
       , Amount , TransactionDate, ValueDate   
       , Settled, SettleDate, UserSuid, Type, TotalAccount, TotalUnit, TotalNominal  
       , MFeeBased, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased  
       )  
  select a.OfficeId, a.ProdId, a.CCY, sum(a.Amount)  
   , @dCurrWorkingDate, @dCurrWorkingDate  
   , 0, null, 7, 2, max(a.TotalAccount), max(a.TotalUnit), max(a.TotalNominal)  
   , sum(a.MFeeBased), sum(a.TaxFeeBased), sum(a.FeeBased3), sum(a.FeeBased4), sum(a.FeeBased5), sum(a.TotalFeeBased)      
  from ReksaMtncFee_TM a 
  join ReksaProduct_TM b  
    on a.ProdId = b.ProdId  
  join #xml x
   on a.ProdId = x.ProdId
  where isnull(a.BillId, 0) = 0  
   and a.Type = 1   
   and x.CheckB = 1
    and a.TransactionDate >= @pdStartDate  
    and a.TransactionDate <  dateadd(dd, 1, @pdEndDate)         
  Group By a.OfficeId, a.ProdId, a.CCY  
  
  If @@Error!= 0  
  Begin  
   set @cErrMsg = 'Error Generate data Bulanan! (' + convert(varchar(20), @nProdId) + ')'  
   goto Error  
  End  
  
  Insert #ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
    , ProdCode, CustodyCode, BillCCY, TotalBill, Fee, FeeBased  
    , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5  
    )       
  select 4,  convert(char(8), @pdStartDate, 112) + ' - ' + convert(char(8), @pdEndDate, 112) + ' - MtcFee - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate  
   , b.ProdCode, c.CustodyCode, a.CCY    
   , round(sum(isnull(a.Amount,0)),4)     
   , 0      
   , round(sum(isnull(a.MFeeBased,0)),4)  
   , round(sum(isnull(a.TaxFeeBased,0)),4)  
   , round(sum(isnull(a.FeeBased3,0)),4)  
   , round(sum(isnull(a.FeeBased4,0)),4)  
   , round(sum(isnull(a.FeeBased5,0)),4)   
  from #ReksaMtncFee_TM a 
  join ReksaProduct_TM b  
    on a.ProdId = b.ProdId  
   join ReksaCustody_TR c  
    on b.CustodyId = c.CustodyId  
  where a.Type = 2  
   and isnull(a.BillId, 0) = 0    
   and a.TransactionDate = @dCurrWorkingDate 
  group by c.CustodyName, b.ProdCode, c.CustodyCode, a.CCY  
  
  If @@Error!= 0  
  Begin  
   set @cErrMsg = 'Gagal Process Maintenance Fee!'  
   goto Error  
  End  


select 
    [ProdCode],
    [CustodyCode],
    [BillCCY],
    [TotalBill],
    [Fee],
    [FeeBased],
    [TaxFeeBased] ,
    [FeeBased3] ,
    [FeeBased4] ,
    [FeeBased5] 
from #ReksaBill_TM
order by CustodyCode

drop table #ReksaBill_TM
drop table #ReksaMtncFee_TM
drop table #xml
  
Return 0  
  
Error:  
If @@trancount > 0  
 rollback tran  
  
if isnull(@cErrMsg,'') = ''  
 set @cErrMsg = 'Unknown Error'  
  
--Exec @nOK=set_raiserror @@procid, @nErrNo Output  
--If @nOK!=0 Return 1  
RaisError (@cErrMsg  ,16,1);
  
Return 1
GO