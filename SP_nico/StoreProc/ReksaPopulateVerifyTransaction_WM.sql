
CREATE proc [dbo].[ReksaPopulateVerifyTransaction_WM]    
/*    
 CREATED BY    : victor    
 CREATION DATE : 20071109    
 DESCRIPTION   : menampilkan list transaksi yang perlu di authorize oleh WM    
 REVISED BY    :    
 DATE,  USER,   PROJECT,  NOTE    
 -----------------------------------------------------------------------    
 20071204, victor, REKSADN002, tambah select TranCode    
 20071213, victor, REKSADN002, hanya tampilkan yang status = 1    
 20071218, indra_w, REKSADN002, perbaikan UAT
 20080402, indra_w, REKSADN002, tampilin Full Amount
 20080415, mutiara, REKSADN002, full amount dan pnambahan kolom fee
 20090323, oscar, REKSADN012, munculkan data khusus untuk PO (071/072)
 END REVISED    
    
 exec dbo.ReksaPopulateVerifyTransaction_WM null    
*/    
@cNik        int    
    
as    
    
set nocount on    
    
declare @bCheck      bit    
--20090323, oscar, REKSADN012, begin
		,@nClassificationId	int
		,@nOK tinyint
		,@cErrMsg varchar(100)
		,@nErrNo int
		
set @nOK = 0
select @nClassificationId = classification_id from user_table_classification_v
where module = 'Pro Reksa 2'
and nik = @cNik

-- menu ini khusus PO (071/072)
if @nClassificationId not in (71, 72)
begin
	set @cErrMsg = 'Menu ini khusus untuk user Partnership Operation (071/072)'
	goto ERROR_HANDLER
end
--20090323, oscar, REKSADN012, end
set @bCheck = 0    
    
--20071204, victor, REKSADN002, begin    
--select @bCheck as 'CheckB', a.TranId, b.ClientCode, c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY,     
--20071218, indra_w, REKSADN002, begin    
select @bCheck as 'CheckB', a.TranId, a.TranCode, a.NAVValueDate as ValueDate, b.ClientCode  
--20080402, indra_w, REKSADN002, begin 
, b.CIFName 
--20080415, mutiara, REKSADN002, begin
--,case    
-- when (a.FullAmount=0) then 'Non Full Amount'    
-- when (a.FullAmount=1) then 'Full Amount'    
-- end as FullAmount    
--20080402, indra_w, REKSADN002, end 
 ,case    
	when (a.FullAmount=0) then 'No'    
	when (a.FullAmount is null) then 'No'    
	when (a.FullAmount=1) then 'Yes'    
 end as FullAmount 
--20080415, mutiara, REKSADN002, end
    
 , c.ProdCode, d.AgentCode, e.TranDesc, a.TranCCY,     
--20071218, indra_w, REKSADN002, end    
--20071204, victor, REKSADN002, end    
 a.TranAmt, a.TranUnit, a.SubcFee, a.RedempFee
--20080415, mutiara, REKSADN002, begin
,a.SubcFee,a.RedempFee 
--20080415, mutiara, REKSADN002, end    
from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d,    
 dbo.ReksaTransType_TR e    
where a.ClientId = b.ClientId    
 and a.ProdId = c.ProdId    
 and a.AgentId = d.AgentId    
 and a.TranType = e.TranType    
    
--20071213, victor, REKSADN002, begin    
 --and a.Status in (1, 2)    
 and a.Status = 1    
--20071213, victor, REKSADN002, end    
 and a.CheckerSuid is not null  -- sudah diotorisasi bs    
 and a.WMCheckerSuid is null    
 and a.WMOtor = 1    
    
--20090323, oscar, REKSADN012, begin
ERROR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	--exec @nOK=set_raiserror @@procid, @nErrNo output
	--if @nOK!=0 return 1
	raiserror (@cErrMsg,16,1);
	set @nOK = 1
end

--return 0
return @nOK
--20090323, oscar, REKSADN012, end
GO