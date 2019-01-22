
CREATE proc [dbo].[ReksaOAOGetDocumentFiles]      
/*        
 CREATED BY    :       
 CREATION DATE :       
 DESCRIPTION   : select 1 data term      
 REVISED BY    :        
 DATE,  USER,   PROJECT,  NOTE        
 -----------------------------------------------------------------------        
       
 END REVISED  
     
   exec ReksaOAOGetDocumentFiles 'MasterNasabah','0000000000000000312'  
     
*/      
@pcMenuName varchar(500)  
,@pcParameter varchar(100)  
as      
      
declare @cMessage varchar(80),      
  @nErrNo  int,      
  @nOK  int      
       
  
              
if(@pcMenuName = 'Blank')  
begin     
    select   
     CIFNo as CIFNo, NamaFile, JenisFile, ResultId  
     FROM dbo.ReksaOAODocumentFiles_TM    
     where 1 = 2  
end  
  
  
 return 0      
 ---------------------------------------------------------------      
ERR_HANDLER:      
 if (@@trancount > 0)      
  rollback tran      
 if @cMessage is null       
  set @cMessage = 'Error'      
 --exec @nOK = set_raiserror @@procid, @nErrNo output      
 --if ((@nOK <> 0) or (@@error <> 0))      
 -- return 1      
 raiserror (@cMessage      ,16,1);
return 1
GO