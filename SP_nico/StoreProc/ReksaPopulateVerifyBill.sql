
CREATE proc [dbo].[ReksaPopulateVerifyBill]  
/*  
 CREATED BY    : victor  
 CREATION DATE : 20071102  
 DESCRIPTION   : menampilkan list bill yang perlu di authorize  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20071130, victor, REKSADN002, perbaiki selectan field2 yang ingin ditampilkan  
  20071203, victor, REKSADN002, sorry checkb nya lupa di select >.<  
  20080416, indra_w, REKSADN002, tambah bill baru - 5: redemption fee  
  20080722, indra_w, REKSADN006, tambah separator  
  20090904, oscar, REKSADN013, untuk REKSADN015 ambil CWD dari fnGetWorkingDate()  
  20111216, liliana, BAALN11008, tambah bill : 6 - switching fee
  20130107, liliana, BATOY12006, tambah bill : 7 - upfront fee, 8 - selling fee
  20130219, liliana, BATOY12006, tambah utk split fee lain
  20131106, liliana, BAALN11010, ganti header utk jenis bill redempt 
  20140313, liliana, LIBST13021, tambah type : 9 - premi asuransi
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyBill 2, null  
 exec dbo.ReksaPopulateVerifyBill 6, null  
*/  
@pnBillType       int,  
@cNik        int  
  
as  
  
set nocount on  
  
declare @bCheck      bit,  
  @cErrMsg     varchar(100),  
  @nOK      tinyint,  
--  @dNow      datetime,  
  @dToday      datetime  
  
set @bCheck = 0  
set @nOK = 0  
  
select @dToday = current_working_date  
--20090904, oscar, REKSADN013, begin  
--from control_table  
from dbo.fnGetWorkingDate()  
--20090904, oscar, REKSADN013, end  
  
--set @dNow = dateadd(day, datediff(day, getdate(), @dToday), getdate())  
--20080416, indra_w, REKSADN002, begin 
--20111216, liliana, BAALN11008, begin 
--if @pnBillType not in (1, 2, 3, 4, 5)  
--20130107, liliana, BATOY12006, begin
--if @pnBillType not in (1, 2, 3, 4, 5, 6)
--20140313, liliana, LIBST13021, begin
--if @pnBillType not in (1, 2, 3, 4, 5, 6, 7, 8)
if @pnBillType not in (1, 2, 3, 4, 5, 6, 7, 8, 9
	)
--20140313, liliana, LIBST13021, end
--20130107, liliana, BATOY12006, end  
--20111216, liliana, BAALN11008, end
--20080416, indra_w, REKSADN002, end  
begin  
 set @cErrMsg = 'Invalid BillType'  
 goto ERROR  
end  
  
--20071130, victor, REKSADN002, begin  
--select @bCheck as 'CheckB', *  
--20071203, victor, REKSADN002, begin  
--select a.BillId, a.BillName,
--20131106, liliana, BAALN11010, begin
if(@pnBillType = 2)
begin
	select @bCheck as 'CheckB', a.BillId, a.BillName,   
	 (case a.DebitCredit when 'D' then 'Debit' when 'C' then 'Credit' end) as 'DebitCredit',    
	 a.CreateDate, a.ValueDate as PaymentDate
	 , b.ProdCode, c.CustodyCode, a.BillCCY, convert(varchar(40),cast(a.TotalBill as money),1) as TotalBill  
	 , convert(varchar(40),cast(a.Fee as money),1) as Fee, convert(varchar(40),cast(a.FeeBased as money),1) as FeeBased  
	,convert(varchar(40),cast(a.TaxFeeBased as money),1) as TaxFeeBased
	,convert(varchar(40),cast(a.FeeBased3 as money),1) as FeeBased3
	,convert(varchar(40),cast(a.FeeBased4 as money),1) as FeeBased4 
	,convert(varchar(40),cast(a.FeeBased5 as money),1) as FeeBased5
	from dbo.ReksaBill_TM  
	 a, dbo.ReksaProduct_TM b, dbo.ReksaCustody_TR c  
	where a.CheckerSuid is null  
	 and a.BillType = @pnBillType  
	 and a.ValueDate <= @dToday  
	 and a.ProdId = b.ProdId  
	 and a.CustodyId = c.CustodyId  
end
--20140313, liliana, LIBST13021, begin
else if(@pnBillType = 9)
begin
	select @bCheck as 'CheckB', bi.BillId, bi.BillName, 
	(case bi.DebitCredit when 'D' then 'Debit' when 'C' then 'Credit' end) as 'DebitCredit',   
	bi.CreateDate, bi.ValueDate as PaymentDate,
	bi.BillCCY, convert(varchar(40),cast(bi.TotalBill as money),1) as TotalBill  
	from dbo.ReksaBill_TM bi
	where bi.CheckerSuid is null
		 and bi.BillType = @pnBillType
		 and bi.ValueDate <= @dToday 
end
--20140313, liliana, LIBST13021, end
else
begin
--20131106, liliana, BAALN11010, end   
select @bCheck as 'CheckB', a.BillId, a.BillName,   
--20071203, victor, REKSADN002, end  
 (case a.DebitCredit when 'D' then 'Debit' when 'C' then 'Credit' end) as 'DebitCredit',   
--20080722, indra_w, REKSADN006, begin  
 a.CreateDate, a.ValueDate, b.ProdCode, c.CustodyCode, a.BillCCY, convert(varchar(40),cast(a.TotalBill as money),1) as TotalBill  
 , convert(varchar(40),cast(a.Fee as money),1) as Fee, convert(varchar(40),cast(a.FeeBased as money),1) as FeeBased  
--20080722, indra_w, REKSADN006, end  
--20071130, victor, REKSADN002, end  
--20130219, liliana, BATOY12006, begin
,convert(varchar(40),cast(a.TaxFeeBased as money),1) as TaxFeeBased
,convert(varchar(40),cast(a.FeeBased3 as money),1) as FeeBased3
,convert(varchar(40),cast(a.FeeBased4 as money),1) as FeeBased4 
,convert(varchar(40),cast(a.FeeBased5 as money),1) as FeeBased5
--20130219, liliana, BATOY12006, end
from dbo.ReksaBill_TM  
--20071130, victor, REKSADN002, begin  
 a, dbo.ReksaProduct_TM b, dbo.ReksaCustody_TR c  
--20071130, victor, REKSADN002, end  
--20071130, victor, REKSADN002, begin  
--where CheckerSuid is null  
-- and BillType = @pnBillType  
-- and ValueDate <= @dToday  
where a.CheckerSuid is null  
 and a.BillType = @pnBillType  
 and a.ValueDate <= @dToday  
 and a.ProdId = b.ProdId  
 and a.CustodyId = c.CustodyId  
--20071130, victor, REKSADN002, end 
--20131106, liliana, BAALN11010, begin
end
--20131106, liliana, BAALN11010, end 
  
ERROR:  
if isnull(@cErrMsg, '') != ''   
begin  
 set @nOK = 1  
 raiserror ( @cErrMsg  ,16,1);
end  
  
return @nOK
GO