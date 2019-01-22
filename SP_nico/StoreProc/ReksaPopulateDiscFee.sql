
CREATE proc [dbo].[ReksaPopulateDiscFee]              
/*              
 CREATED BY    : Mutiara             
 CREATION DATE : 20080327              
 DESCRIPTION   : menampilkan list transaksi reversal yang dapat di authorize              
 REVISED BY    :              
 DATE,  USER,   PROJECT,  NOTE              
 -----------------------------------------------------------------------              

 END REVISED              
               
 exec dbo.ReksaPopulateDiscFee 80002  
*/              
@cNik        int              
              
as              
              
set nocount on              
              
declare @bCheck    bit,              
  @dCurrWorkingDate   datetime,              
  @dToday    datetime            
             
set @bCheck = 0              
              
select @dCurrWorkingDate = current_working_date             
from dbo.control_table              
            
set @dToday = @dCurrWorkingDate              
              
set @dCurrWorkingDate = dateadd(second, -1, (dateadd (day, 1, @dCurrWorkingDate)))              
              
select             
 @bCheck as 'CheckB', a.TranId, b.ClientCode,             
 c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY,
--20080416, mutiara, REKSADN002, begin               
-- a.TranAmt, a.TranUnit,b.CIFName,a.TranCode,isnull(a.RedempDisc,0) as RedempDisc      
 a.TranAmt, a.TranUnit,a.RedempFee, b.CIFName,a.TranCode,isnull(a.RedempDisc,0) as RedempDisc      
--20080416, mutiara, REKSADN002, end
from
 dbo.ReksaTransaction_TT a join dbo.ReksaCIFData_TM b on a.ClientId = b.ClientId            
 join dbo.ReksaProduct_TM c on a.ProdId = c.ProdId            
 join dbo.ReksaAgent_TR d on a.AgentId = d.AgentId            
 join dbo.ReksaTransType_TR e on a.TranType = e.TranType            
 join dbo.user_nisp_v f  on a.UserSuid = f.nik            
where a.ReverseSuid is null  
 and a.CheckerSuid is not null    
--20080416, mutiara, REKSADN002, begin  
--20080416, mutiara, REKSADN002, begin  
and a.Status = 1   
and a.TranType in (3,4)    
--20080416, mutiara, REKSADN002, end  
--20080416, mutiara, REKSADN002, end  
 and a.NAVValueDate >= @dToday  
--20080417, mutiara, REKSADN002, begin
 and a.RedempFee> 0  
--20080417, mutiara, REKSADN002, end
return 0
GO