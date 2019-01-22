
alter proc [dbo].[ReksaPopulateRejectBooking]  
/*  
 CREATED BY    : liliana    
 CREATION DATE : 20110105  
 DESCRIPTION   :     
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
    20110623, liliana, BAALN10011, penambahan utk fitur otorisasi
    20110923, liliana, BAALN10011,  perbaikan
    20110926, liliana, BAALN10011, tambahan 
    20111010, victor, BAALN10011, perbaikan tanggal
    20111108, liliana, BAALN10011, Ganti jadi next working date
 END REVISED                                     
 exec ReksaPopulateRejectBooking 'B'  
  
*/   
@pcJenis  varchar(1) -- A = sesudah cut off by WM, B = sesudah bill dibentuk  
as  
set nocount on  
  
declare @bCheck  bit  
--20111108, liliana, BAALN10011, begin
declare @dNextWorkingDate	datetime, @dWorkingDate	datetime

select @dNextWorkingDate = next_working_date, @dWorkingDate = current_working_date 
from dbo.fnGetWorkingDate()   
--20111108, liliana, BAALN10011, end
  
set @bCheck = 0  
  
 if (@pcJenis = 'A')  
 begin  
  select @bCheck as 'Check',   
  rb.BookingId as 'BookingId',  
--20110923, liliana, BAALN10011, begin  
  --rb.ProdId as 'KodeProduk',   
 rp.ProdCode as 'KodeProduk', 
--20110923, liliana, BAALN10011, end  
  rp.ProdName as 'NamaProduk',   
  rb.BookingCode as 'BookingCode',   
  rb.CIFName as 'NamaNasabah',   
  rb.BookingAmt as 'NominalBooking',    
  rb.LastUpdate as 'TanggalBooking',    
  rb.NISPAccId as 'RekeningRelasi',    
  rb.NISPAccName as 'NamaRekeningRelasi',    
  rb.AgentId as 'AgentCode',    
  rb.Seller as 'NIKSeller',    
  ei.name as 'NamaSeller'   
   from ReksaBooking_TM rb  
   join ReksaProduct_TM rp on rb.ProdId= rp.ProdId  
   left join dbo.employee_id  ei on rb.Seller = ei.employee_id  
--20110623, liliana, BAALN10011, begin
   left join ReksaRejectBooking_TMP rrb on rrb.BookingId = rb.BookingId
--20110623, liliana, BAALN10011, end   
--20110923, liliana, BAALN10011, begin
   --where rp.[Status] = 1 and rp.CloseEndBit = 1   
    where rp.CloseEndBit = 1 
--20111010, victor, BAALN10011, begin    
   --and   convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodEnd, rp.EffectiveAfter),103)  =  convert(varchar,dateadd(dd,-1,getdate()),103)    
--20111108, liliana, BAALN10011, begin     
   --and   convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodEnd, rp.EffectiveAfter),103)  =  convert(varchar,dateadd(dd,1,getdate()),103) 
   and   convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodEnd, rp.EffectiveAfter),103)  =  convert(varchar,@dNextWorkingDate,103) 
--20111108, liliana, BAALN10011, end        
--20111010, victor, BAALN10011, end   
--20110923, liliana, BAALN10011, end   
--20110623, liliana, BAALN10011, begin
	and rrb.StatusApproval is null
--20110623, liliana, BAALN10011, end   
 end  
 else if(@pcJenis = 'B')  
 begin  
  select @bCheck as 'Check',   
  rt.TranId as 'TranId',
--20110923, liliana, BAALN10011, begin      
  --rc.ProdId as 'KodeProduk',  
 rp.ProdCode as 'KodeProduk',   
--20110923, liliana, BAALN10011, end  
  rp.ProdName as 'NamaProduk',  
  rc.ClientCode as 'ClientCode',  
  rc.CIFName as 'NamaNasabah',  
--20110926, liliana, BAALN10011, begin  
  --rc.SubcNominal as 'NominalSubscription',
  case when rt.TranType  in (1,2,8)   
   then   
    case when rt.FullAmount = 1 then rt.TranAmt  
      else rt.TranAmt - rt.SubcFee  
    end  
  else 0 end as 'NominalSubscription', 
--20110926, liliana, BAALN10011, end    
  rc.JoinDate as 'ValueDate',  
  rc.NISPAccId as 'RekeningRelasi',  
  rc.NISPAccName as 'NamaRekeningRelasi',  
  rc.AgentId as 'AgentCode',  
  rc.Seller as 'NIKSeller',  
  ei.name as 'NamaSeller'   
  from ReksaCIFData_TM rc  
  join ReksaTransaction_TT rt on rt.ClientId = rc.ClientId  
  join ReksaProduct_TM rp on rc.ProdId= rp.ProdId  
  left join dbo.employee_id  ei on rc.Seller = ei.employee_id  
--20110623, liliana, BAALN10011, begin
  left join ReksaDeleteTrans_TMP rrt on rrt.TranId = rt.TranId
--20110623, liliana, BAALN10011, end     
  where rp.[Status] = 1 and rp.CloseEndBit = 1 and rc.CIFStatus != 'T'  
--20110623, liliana, BAALN10011, begin
--20110923, liliana, BAALN10011, begin
--20110926, liliana, BAALN10011, begin
 --and  convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodStart, rp.EffectiveAfter),103)  = convert(varchar,getdate(),103) 
--20111108, liliana, BAALN10011, begin        
 --and  convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodEnd, rp.EffectiveAfter),103)  = convert(varchar,getdate(),103) 
 and  convert(varchar,dbo.fnReksaGetEffectiveDate(rp.PeriodEnd, rp.EffectiveAfter),103)  = convert(varchar,@dWorkingDate,103)  
--20111108, liliana, BAALN10011, end   
--20110926, liliana, BAALN10011, end    
--20110923, liliana, BAALN10011, end
	and rrt.StatusApproval is null
--20110623, liliana, BAALN10011, end      
 end  
   
return 0
GO