
CREATE proc [dbo].[ReksaPopulateRedemptDate]    
/*          
 CREATED BY    : Mutiara         
 CREATION DATE : 20080327          
 DESCRIPTION   :         
 REVISED BY    :          
  DATE,  USER,   PROJECT,  NOTE          
  -----------------------------------------------------------------------          
          
 END REVISED          
           
 exec ReksaPopulateRedemptDate 80001        
*/          
@cNik        int          
          
as          
          
set nocount on          
          
declare @bCheck     bit  
		,@dcurrent_working_date datetime  
		,@dNext_Working_Date datetime  
         
set @bCheck = 0  
          
select	@dcurrent_working_date = current_working_date
		,@dNext_Working_Date = next_working_date
from dbo.control_table      
          
select         
 @bCheck as 'CheckB', a.TranId, b.ClientCode,         
 c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY,         
 a.TranAmt, a.TranUnit,a.GoodFund,a.SettleDate,b.CIFName,a.TranCode        
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
 and a.NAVValueDate >= @dcurrent_working_date        
 and GoodFund>=@dNext_Working_Date  
 and a.TranType in (3,4)    
return 0
GO