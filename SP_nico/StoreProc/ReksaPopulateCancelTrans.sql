
CREATE procedure [dbo].[ReksaPopulateCancelTrans]
/*    
 CREATED BY  : Mutiara     
 CREATED DATE : 20080409    
 DESCRIPTION  : Untuk membatalkan transaksi    
 REVISED BY  :    
 DATE,  USER,  PROJECT,  NOTE    
 ------------------------------------------------------------------------    
 20151124, liliana, LIBST13020, hanya produk open end   
 END REVISED     
 sp_helptext ReksaPopulateCancelTransaction    
 exec ReksaPopulateCancelTransaction    
*/    
as    
    
declare @dCurrWorkingDate datetime  
  ,@nProcessStatusS int  
  ,@nProcessStatusR int    
  ,@bCheck    bit  
  
set @bCheck =0  
    
select @dCurrWorkingDate = current_working_date       
from dbo.control_table       
    
select @nProcessStatusS=ProcessStatus     
from ReksaUserProcess_TR    
where ProcessName like '%Process Subcription%'    
    
select @nProcessStatusR=ProcessStatus     
from ReksaUserProcess_TR    
where ProcessName like '%Process Redemption%'    
    
    
if((@nProcessStatusS=1) and (@nProcessStatusR=0))    
begin    
 select    
 @bCheck as 'Check'  
 ,b.ClientCode    
 ,c.ProdCode    
 ,a.TranCode    
 ,b.CIFName    
 ,d.AgentCode    
 ,e.TranDesc    
 ,c.FullMonthMtcFee    
 ,a.TranCCY    
 ,a.TranAmt    
 ,a.TranUnit    
 ,a.GoodFund    
 ,f.name    
 ,a.CheckerSuid    
 ,a.SettleDate    
 ,a.TranId   
 ,case     
  when (a.Settled = 0) then 'Belum diOtorisasi'    
  else 'Sudah diOtorisasi'    
 end as Status    
 from    
 ReksaTransaction_TT a join ReksaCIFData_TM b on a.ClientId = b.ClientId    
 join dbo.ReksaProduct_TM c on a.ProdId = c.ProdId    
 join dbo.ReksaAgent_TR d on a.AgentId = d.AgentId    
 join dbo.ReksaTransType_TR e on a.TranType = e.TranType    
 join dbo.user_nisp_v f  on a.UserSuid = f.nik    
 where          
 a.ReverseSuid is null      
 and a.CheckerSuid is not null      
 and a.Status = 1    
 and NAVValueDate>=@dCurrWorkingDate    
 and a.TranType in (1,2)  
--20151124, liliana, LIBST13020, begin
 and c.CloseEndBit = 0
--20151124, liliana, LIBST13020, end     
end    
else if((@nProcessStatusS=0) and (@nProcessStatusR=1))    
begin    
 select   
 @bCheck as 'Check'  
 ,b.ClientCode    
 ,c.ProdCode    
 ,a.TranCode    
 ,b.CIFName    
 ,d.AgentCode    
 ,e.TranDesc    
 ,c.FullMonthMtcFee    
 ,a.TranCCY    
 ,a.TranAmt    
 ,a.TranUnit    
 ,a.GoodFund    
 ,f.name    
 ,a.CheckerSuid    
 ,a.SettleDate   
 ,a.TranId   
 ,case     
  when (a.Settled = 0) then 'Belum diOtorisasi'    
  else 'Sudah diOtorisasi'    
 end as Status    
 from    
 ReksaTransaction_TT a join ReksaCIFData_TM b on a.ClientId = b.ClientId    
 join dbo.ReksaProduct_TM c on a.ProdId = c.ProdId    
 join dbo.ReksaAgent_TR d on a.AgentId = d.AgentId    
 join dbo.ReksaTransType_TR e on a.TranType = e.TranType    
 join dbo.user_nisp_v f  on a.UserSuid = f.nik    
 where          
 a.ReverseSuid is null      
 and a.CheckerSuid is not null      
 and a.Status = 1    
 and NAVValueDate>=@dCurrWorkingDate    
 and a.TranType in (3,4) 
--20151124, liliana, LIBST13020, begin
 and c.CloseEndBit = 0
--20151124, liliana, LIBST13020, end           
end    
--Justru kalo 2-2nya 1, berarti data trantype 1,2,3,4 ditampilin semua.     
else  if((@nProcessStatusS=1) and (@nProcessStatusR=1))    
begin    
 select   
 @bCheck as 'Check'  
 ,b.ClientCode    
 ,c.ProdCode    
 ,a.TranCode    
 ,b.CIFName    
 ,d.AgentCode    
 ,e.TranDesc    
 ,c.FullMonthMtcFee    
 ,a.TranCCY    
 ,a.TranAmt    
 ,a.TranUnit    
 ,a.GoodFund    
 ,f.name    
 ,a.CheckerSuid    
 ,a.SettleDate    
 ,a.TranId  
 ,case     
  when (a.Settled = 0) then 'Belum diOtorisasi'    
  else 'Sudah diOtorisasi'    
 end as Status    
 from           
 ReksaTransaction_TT a join ReksaCIFData_TM b on a.ClientId = b.ClientId    
 join dbo.ReksaProduct_TM c on a.ProdId = c.ProdId    
 join dbo.ReksaAgent_TR d on a.AgentId = d.AgentId    
 join dbo.ReksaTransType_TR e on a.TranType = e.TranType    
 join dbo.user_nisp_v f  on a.UserSuid = f.nik    
 where          
 a.ReverseSuid is null      
 and a.CheckerSuid is not null      
 and a.Status = 1    
 and NAVValueDate>=@dCurrWorkingDate  
--20151124, liliana, LIBST13020, begin
 and c.CloseEndBit = 0
--20151124, liliana, LIBST13020, end        
end    
    
return 0
GO