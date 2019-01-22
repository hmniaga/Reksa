CREATE proc [dbo].[ReksaSrcTransSwitchOut]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20111103  
 DESCRIPTION   : Search product berdasarkan product switch out 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  

 END REVISED  
*/  

@cCol1  varchar(25)=null,  
@cCol2  varchar(25)=null,  
@bValidate bit=0  
  
as  
  
set nocount on  
  
declare @cErrMsg   varchar(100)  
 , @nOK    int  
 , @nErrNo   int  
  
  
if @cCol1=''   
 select @cCol1=null  
else  
 select @cCol1= upper(@cCol1)  
  
if @cCol2=''   
 select @cCol2=null  
else   
 select @cCol2= upper(@cCol2)  
  
if @bValidate = 1  
Begin  
 select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId  
 from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
 where  rs.ProdSwitchOut = @cCol1
End  
else  
begin  
   
 if @cCol1 is not null and @cCol2 is null  
 Begin  
	 select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId    
	 from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
	 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
	 where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'   
 End  
 else if @cCol2 is not null and @cCol1 is null  
 Begin  
	 select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId    
	 from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
	 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
	 where  rp.ProdName  like rtrim(ltrim(@cCol2)) + '%'
 End  
 else if @cCol2 is not null and @cCol1 is not null  
 Begin  
  select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId    
	 from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
	 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
	 where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'  
     and rp.ProdName like rtrim(ltrim(@cCol2)) + '%' 
 End  
 else
 Begin  
	 select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId    
	 from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
	 join dbo.ReksaProduct_TM rp on rs.ProdSwitchOut = rp.ProdCode 
 End  
end  
  
return 0  
  
ERROR:  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1)
return 1
GO