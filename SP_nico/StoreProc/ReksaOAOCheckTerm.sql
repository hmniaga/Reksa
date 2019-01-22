CREATE proc [dbo].[ReksaOAOCheckTerm]      
/*        
 CREATED BY    :  liliana     
 CREATION DATE :       
 DESCRIPTION   : 
 REVISED BY    :        
 DATE,  USER,   PROJECT,  NOTE        
 -----------------------------------------------------------------------        
       
 END REVISED  
       
*/      
@pcCIFNo			varchar(20)  
, @pnProdCode		varchar(50) = ''
, @pcParameterTerm	varchar(100)
, @pbIsYes			bit		output 
as      
      
declare @cMessage varchar(80),      
  @nErrNo	int,      
  @nOK		int,
  @nUmur	int,
  @nProductRiskProfile	int,
  @nCustomerRiskProfile  int,
  @cCIFNo19           varchar(19),
  @pnProdId				int       
       
set @pbIsYes = 0
set @cCIFNo19 = right(('0000000000000000000'+@pcCIFNo),19) 

select @pnProdId = ProdId
from dbo.ReksaProduct_TM
where ProdCode = @pnProdCode

if @pcParameterTerm = 'Umur'
begin  
  exec ReksaHitungUmur @pcCIFNo, @nUmur output    
  
	if(@nUmur >= 55)  
	begin
		set @pbIsYes = 1 
	end  
end
else if @pcParameterTerm = 'RiskProfile'
begin
	SELECT @nProductRiskProfile = rprp.RiskProfile        
    FROM [dbo].[ReksaProduct_TM] rp        
	LEFT JOIN [dbo].[ReksaProductRiskProfile_TM] rprp        
		ON rp.[ProdCode] = rprp.[ProductCode]        
	 WHERE rp.[ProdId] = @pnProdId        
              
    -- GET CUSTOMER RISK       
    select right(CFCIF,13) as CFCIF19, *  
    into #Temp_CFMAST  
    from dbo.CFMAST_v  
    where CFCIF = @cCIFNo19   
      
    select *  
    into #Temp_ReksaCIFData_TM2  
    from dbo.ReksaCIFData_TM  
    where [CIFNo] = @pcCIFNo      
    
    SELECT @nCustomerRiskProfile = CASE        
        WHEN LOWER(cf.[CFUIC8]) = 'a' THEN 1        
        WHEN LOWER(cf.[CFUIC8]) = 'b' THEN 2        
        WHEN LOWER(cf.[CFUIC8]) = 'c' THEN 3        
        WHEN LOWER(cf.[CFUIC8]) = 'd' THEN 4   
        WHEN LOWER(cf.[CFUIC8]) = 'e' THEN 5     
        ELSE 0        
        END         
    FROM [dbo].#Temp_ReksaCIFData_TM2 rc    
    JOIN [dbo].#Temp_CFMAST cf    
        on cf.CFCIF19 = rc.CIFNo                 
          
    IF(@nCustomerRiskProfile < @nProductRiskProfile)        
    BEGIN         
		set @pbIsYes = 1         
	END 
	
	drop table #Temp_ReksaCIFData_TM2
	drop table #Temp_CFMAST
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