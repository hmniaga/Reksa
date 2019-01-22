CREATE proc [dbo].[ReksaUpdateDocuments]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20140924
 DESCRIPTION   :  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  
 END REVISED  
 
*/  
 @pnTranId							int,
 @pbDocFCSubscriptionForm			bit,
 @pbDocFCDevidentAuthLetter			bit,
 @pbDocFCJoinAcctStatementLetter	bit,
 @pbDocFCIDCopy						bit,
 @pbDocFCOthers						bit,
 @pbDocTCSubscriptionForm			bit,
 @pbDocTCTermCondition				bit,
 @pbDocTCProspectus					bit,
 @pbDocTCFundFactSheet				bit,
 @pbDocTCOthers						bit,
 @pcDocFCOthersList					varchar(max),
 @pcDocTCOthersList					varchar(max),
 @pbIsSwitching						bit
as  
  
set nocount on  
  
declare 
	@cErrMsg	varchar(100)  
  , @nOK		int  
  , @nErrNo		int  
 
if @pbIsSwitching = 1
begin
	update dbo.ReksaSwitchingTransaction_TM
	set DocFCSubscriptionForm  = @pbDocFCSubscriptionForm                
		, DocFCDevidentAuthLetter  = @pbDocFCDevidentAuthLetter               
		, DocFCJoinAcctStatementLetter  = @pbDocFCJoinAcctStatementLetter          
		, DocFCIDCopy            = @pbDocFCIDCopy                 
		, DocFCOthers            = @pbDocFCOthers             
		, DocTCSubscriptionForm  = @pbDocTCSubscriptionForm                  
		, DocTCTermCondition     = @pbDocTCTermCondition                 
		, DocTCProspectus        = @pbDocTCProspectus                 
		, DocTCFundFactSheet     = @pbDocTCFundFactSheet                 
		, DocTCOthers			 = @pbDocTCOthers
	where TranId = @pnTranId
end
else
begin 
	update dbo.ReksaTransaction_TT
	set DocFCSubscriptionForm  = @pbDocFCSubscriptionForm                
		, DocFCDevidentAuthLetter  = @pbDocFCDevidentAuthLetter               
		, DocFCJoinAcctStatementLetter  = @pbDocFCJoinAcctStatementLetter          
		, DocFCIDCopy            = @pbDocFCIDCopy                 
		, DocFCOthers            = @pbDocFCOthers             
		, DocTCSubscriptionForm  = @pbDocTCSubscriptionForm                  
		, DocTCTermCondition     = @pbDocTCTermCondition                 
		, DocTCProspectus        = @pbDocTCProspectus                 
		, DocTCFundFactSheet     = @pbDocTCFundFactSheet                 
		, DocTCOthers			 = @pbDocTCOthers
	where TranId = @pnTranId
end

delete from ReksaOtherDocuments_TM        
where TranId = @pnTranId   
	and isnull(IsSwitching, 0) = @pbIsSwitching           
	and DocType = 'FC' -- from customer        
     
if @@error <> 0        
begin        
	set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (FC)'                
	goto ERROR        
end        

insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching)        
select @pnTranId, 'FC', left(result, 255), @pbIsSwitching  
from dbo.Split(@pcDocFCOthersList, '#', 0, len(@pcDocFCOthersList))        
    
if @@error <> 0        
begin        
	set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (FC)'                
	goto ERROR        
end        
      
delete from ReksaOtherDocuments_TM        
where TranId = @pnTranId  
	and isnull(IsSwitching, 0) = @pbIsSwitching      
	and DocType = 'TC' -- ke customer        
    
if @@error <> 0        
begin        
	set @cErrMsg = 'Gagal hapus data ReksaOtherDocuments_TM (TC)'              
	goto ERROR        
end        

insert into ReksaOtherDocuments_TM (TranId, DocType, OtherDoc, IsSwitching)        
select @pnTranId, 'TC', left(result, 255), @pbIsSwitching 
from dbo.Split(@pcDocTCOthersList, '#', 0, len(@pcDocTCOthersList))        
    
if @@error <> 0        
begin        
	set @cErrMsg = 'Gagal insert data ReksaOtherDocuments_TM (TC)'              
	goto ERROR        
end         
                
 
return 0  
  
ERROR:  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Error !'  
  
exec @nOK = set_raiserror @@procid, @nErrNo output    
if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1)
return 1
GO