
CREATE Proc [dbo].[ReksaPopulateValueDate]
/*
	CREATED BY    : Indra
	CREATION DATE : 20080423
	DESCRIPTION   : Untuk menampilkan data2 transaksi yang dapat di ubah tanggal value datenya
	REVISED BY    :
		DATE,		USER, 	PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120717, liliana, BARUS12005, tambah transaksi switching
	END REVISED
	ReksaPopulateValueDate 7, ''
*/
 @pnNIK						int
 , @pcGuid					varchar(50)	= NULL
As

Set Nocount On
Declare
	@nErrNo					int
	,@bCheck				bit
	,@nOK					int 
	,@cErrMsg				varchar(100)
	,@dCurrentWorkingDate	datetime
	,@dNextWorkingDate		datetime

select @dCurrentWorkingDate = current_working_date
	, @dNextWorkingDate = next_working_date
from dbo.fnGetWorkingDate()

set @bCheck = 0 

select @bCheck as 'CheckB', a.TranId, a.TranCode, a.TranDate as TranDate,  b.ClientCode
--20120717, liliana, BARUS12005, begin	
--	, c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY
	,'' as ClientCodeSwitchOut
	, '' as ClientCodeSwitchIn
	, c.ProdCode
	, '' as ProdCodeSwitchOut
	, '' as ProdCodeSwitchIn
	, d.AgentCode, e.TranDesc, a.TranCCY
--20120717, liliana, BARUS12005, end	
	, a.TranAmt, a.TranUnit, case a.ByUnit when 1 then 'By Unit' else 'By Nominal' end
--20120717, liliana, BARUS12005, begin
	--, a.NAVValueDate as ValueDate, b.CIFName, f.name as Inputer
	, a.NAVValueDate as ValueDate
	, b.CIFName
	, '' as CIFNameSwcOut
	, '' as CIFNameSwcIn, f.name as Inputer
	, a.TranType
--20120717, liliana, BARUS12005, end
from         
 ReksaTransaction_TT a join ReksaCIFData_TM b on a.ClientId = b.ClientId        
 join dbo.ReksaProduct_TM c on a.ProdId = c.ProdId        
 join dbo.ReksaAgent_TR d on a.AgentId = d.AgentId        
 join dbo.ReksaTransType_TR e on a.TranType = e.TranType        
 join dbo.user_nisp_v f  on a.UserSuid = f.nik  
where a.Status in (0,1)
  and a.NAVValueDate >= @dNextWorkingDate    
--20120717, liliana, BARUS12005, begin
union
select @bCheck as 'CheckB', rs.TranId, rs.TranCode, rs.TranDate as TranDate
	, '' as ClientCode
	,  rc.ClientCode as ClientCodeSwitchOut
	,  rc1.ClientCode as ClientCodeSwitchIn
	, '' as ProdCode
	, rp.ProdCode as ProdCodeSwitchOut
	, rp2.ProdCode as ProdCodeSwitchIn
	, ra.AgentCode
	, case when rs.TranType = 5 then 'Switching Sebagian' 
		   when rs.TranType = 6 then 'Switching All' 
		   else null end as TranDesc
	, rs.TranCCY
	, rs.TranAmt, rs.TranUnit
	, case rs.ByUnit when 1 then 'By Unit' else 'By Nominal' end
	, rs.NAVValueDate as ValueDate
	, '' as CIFName
	, rc.CIFName as CIFNameSwcOut
	, rc1.CIFName as CIFNameSwcIn
	, un.name as Inputer
	, rs.TranType
from         
 dbo.ReksaSwitchingTransaction_TM rs 
 join dbo.ReksaCIFData_TM rc on rs.ClientIdSwcOut = rc.ClientId     
 join dbo.ReksaCIFData_TM rc1 on rs.ClientIdSwcIn = rc1.ClientId      
 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdId      
 join dbo.ReksaProduct_TM rp2 on rs.ProdSwitchIn = rp2.ProdId      
 join dbo.ReksaAgent_TR ra on rs.AgentId = ra.AgentId          
 join dbo.user_nisp_v un  on rs.UserSuid = un.nik  
where rs.Status in (0,1)
  and rs.NAVValueDate >= @dNextWorkingDate    
--20120717, liliana, BARUS12005, end      

if @@error != 0
Begin
	Set @cErrMsg='Gagal Populate Data'
	Goto Error
End

Return 0

Error:
If @cErrMsg Is Not Null
Begin
	--Exec @nOK=set_raiserror @@procid, @nErrNo Output
	--If @nOK!=0 Return 1
	Raiserror (@cErrMsg,16,1);

End

Return 1
GO