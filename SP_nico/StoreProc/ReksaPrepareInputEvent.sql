CREATE proc [dbo].[ReksaPrepareInputEvent]
/*              
 CREATED BY    : Philip             
 CREATION DATE : 20090722              
 DESCRIPTION   : recordset kosong utk datagrid
 REVISED BY    :              
 DATE,  USER,   PROJECT,  NOTE              
 -----------------------------------------------------------------------       
 END REVISED       
*/
as

select top 0
	SeqNo, Peserta, ClientCode, ClientName, NoRekening, ProdCode, GiftCode,
	Cost, Profit, AgentCode, SalesCode
from [ReksaEventDetail_TM]

return 0
GO