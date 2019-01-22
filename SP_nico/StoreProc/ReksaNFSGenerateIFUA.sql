
CREATE  proc [dbo].[ReksaNFSGenerateIFUA]    
/*                      
 CREATED BY    : liliana                      
 CREATION DATE : 20160819    
 DESCRIPTION   : GENERATE IFUA for new client code     
 REVISED BY    :                      
 DATE,  USER,   PROJECT,  NOTE                      
 -----------------------------------------------------------------------     
        
 END REVISED     
 
*/    
 @pcCIFNo  varchar(13)    
, @pcErrMsg varchar(500) output      
, @pcTrxTA bit = 0  
    
as                      
set nocount on    
                      
declare    
  @nNasabahId bigint      
 , @nOK    tinyint    
 , @nErrNo      int    
 , @nCounterIFUATA int   
 , @cCounterPfixIFUATA varchar(5)    
 , @cClientCodeDummyTA varchar(6)     
    
set @pcErrMsg = ''    
    
-- INSERT IFUA     
select @nNasabahId = NasabahId     
from ReksaMasterNasabah_TM     
where CIFNo = @pcCIFNo    
  
select @nCounterIFUATA = convert(bigint, ParamValue) + 1    
from ReksaNFSParam_TR    
where ParamCode = 'NFSIFUACOUNTERTA'    
    
select @cCounterPfixIFUATA = ParamValue    
from ReksaNFSParam_TR    
where ParamCode = 'NFSIFUAPFIXTA'    
    
BEGIN TRY    
BEGIN TRAN    
    
if @pcTrxTA = 1  
begin  
    set @cClientCodeDummyTA = @cCounterPfixIFUATA + right('000000'+convert(varchar, @nCounterIFUATA),5)

    if not exists (select top 1 1 from dbo.ReksaIFUAMapping_TM where CIFNo = @pcCIFNo and AccType = 'TA'
		)    
    begin   
        insert into dbo.ReksaIFUAMapping_TM (NasabahId, ClientCodeReksa, CIFNo, ClientCodeKSEI, AccType, LastUpdatedDate)    
        select NasabahId, '' , CIFNo, @cClientCodeDummyTA, 'TA', getdate()     
        from dbo.ReksaMasterNasabah_TM      
        where CIFNo = @pcCIFNo       
         
        update dbo.ReksaNFSParam_TR    
        set ParamValue = case when @nCounterIFUATA = 99999 then 10000 else @nCounterIFUATA end    
        where ParamCode = 'NFSIFUACOUNTERTA'    
 
    end  
end     
    
COMMIT TRAN    
    
END TRY    
BEGIN CATCH    
    set @pcErrMsg = error_message()    
    goto ERROR     
END CATCH    
    
return 0    
    
ERROR:    
                                            
    IF @@trancount > 0    
        ROLLBACK TRAN    
                
 if isnull(@pcErrMsg ,'') = ''      
   set @pcErrMsg = 'UNKNOWN ERROR !'
GO