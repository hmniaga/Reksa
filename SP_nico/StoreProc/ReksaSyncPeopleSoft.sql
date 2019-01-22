CREATE Proc [dbo].[ReksaSyncPeopleSoft]   
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20110510  
 DESCRIPTION   :   
 REVISED BY    :  
  DATE,  USER,  PROJECT,  NOTE  
  -----------------------------------------------------------------------  
 END REVISED  
  
  exec ReksaSyncPeopleSoft
*/    
as  
set nocount On  
declare  
 @nErrNo    int  
 ,@nOK    int   
 ,@cErrMsg   varchar(100)  
 
 update ba
 set ba.JobTitle = ps.JOBTITLE,
 ba.Nama = ps.NAME
 from dbo.ReksaWaperd_TR ba
 join dbo.PSEmployee_v ps
 on ba.NIK = ps.EMPLID
 
 update ba
 set ba.Keterangan = 'Resign'
 from dbo.ReksaWaperd_TR ba
 left join dbo.PSEmployee_v ps
 on ba.NIK = ps.EMPLID
 where ps.NAME is null and ps.JOBTITLE is null
 
return 0  
  
ERROR:    
If @@trancount > 0     
 rollback tran    
    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Unknown Error !'    
    
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK != 0 return 1      
      
raiserror (@cErrMsg    ,16,1)
return 1
GO