
CREATE proc [dbo].[ReksaPopulateVerifySwcReversal]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20111117  
 DESCRIPTION   : menampilkan list switching reversal yang dapat di authorize  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20120117, liliana, BAALN11008, yg udah masuk ReksaTransaction_TT ga keproses lagi
  20120809, dhanan, LOGAM02012, L4846 - perbaikan pengecekan unit balance switching
 END REVISED  
   
 exec dbo.ReksaPopulateVerifySwcReversal null  
 
*/  
@cNik        int  
  
as  
  
set nocount on  
  
declare @bCheck      bit,  
  @dCurrWorkingDate   datetime,  
  @dToday      datetime,
  @cOfficeId      varchar(5)  
  
select @cOfficeId = office_id_sibs  
from dbo.user_nisp_v  
where nik = @cNik   
  
set @bCheck = 0  
  
select @dCurrWorkingDate = current_working_date  
from dbo.control_table  
  
set @dToday = @dCurrWorkingDate   
  
set @dCurrWorkingDate = dateadd(second, -1, (dateadd (day, 1, @dCurrWorkingDate)))  
  
select @bCheck as CheckB, swc.TranId, ci.ClientCode as ClientCodeSwcOut,
ci2.ClientCode as ClientCodeSwcIn,
rp.ProdCode as ProdCodeSwcOut,
rp2.ProdCode as ProdCodeSwciN,
ag.AgentCode, 
case when swc.TranType = 5 then 'Switching Sebagian' 
 when swc.TranType = 6 then 'Switching All' else '' end as TranDesc,
swc.TranCCY, swc.TranAmt, swc.TranUnit 
from dbo.ReksaSwitchingTransaction_TM swc  
--20120117, liliana, BAALN11008, begin
left join dbo.ReksaTransaction_TT rt on swc.TranCode = rt.TranCode
--20120117, liliana, BAALN11008, end
join dbo.ReksaCIFData_TM ci on swc.ClientIdSwcOut = ci.ClientId
join dbo.ReksaCIFData_TM ci2 on swc.ClientIdSwcIn = ci2.ClientId
join dbo.ReksaProduct_TM rp on rp.ProdId = swc.ProdSwitchOut
join dbo.ReksaProduct_TM rp2 on rp2.ProdId = swc.ProdSwitchIn
join dbo.ReksaAgent_TR ag on swc.AgentId = ag.AgentId
join dbo.user_nisp_v us on us.nik = swc.UserSuid
where swc.ReverseSuid is null  
--20120117, liliana, BAALN11008, begin
  and rt.TranCode is null
--20120117, liliana, BAALN11008, end
  and swc.CheckerSuid is not null  
  and swc.Status = 1   
  and swc.NAVValueDate >= @dToday 
  and us.office_id_sibs = @cOfficeId  
--20120809, dhanan, LOGAM02012, begin
  and swc.BillId is null
--20120809, dhanan, LOGAM02012, end
  
return 0
GO