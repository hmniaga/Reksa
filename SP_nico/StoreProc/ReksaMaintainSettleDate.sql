
CREATE proc [dbo].[ReksaMaintainSettleDate]            
/*              
 CREATED BY    : 
 CREATION DATE : 
 DESCRIPTION   : Mengupdate kolom SettleDate di tabel ReksaTransaction_TT 
 REVISED BY    :              
 DATE,  USER,   PROJECT,  NOTE              
 -----------------------------------------------------------------------  
 END REVISED      
              
 exec ReksaMaintainSettleDate  1            
*/    
 @nTranId   int        
,@nNewSettleDate datetime    
,@nNIK    int    
,@cGuid    varchar(50)    
    
as              
    
Declare    
 @nErrNo   int    
,@nOK    int     
,@cErrMsg   varchar(100)    
,@dNow    datetime    
,@dNAVValueDate datetime    
set @dNow=getdate()    
    
select  @dNAVValueDate= NAVValueDate 
from	  ReksaTransaction_TT 
where	  TranId=@nTranId 
if (@nNewSettleDate>@dNAVValueDate)
begin
	 update ReksaTransaction_TT    
	 set GoodFund=@nNewSettleDate    
		  ,GFChangeDate=@dNow    
		  ,GFSUid=@nNIK    
	 where TranId=@nTranId   
	If @@error != 0    
	Begin    
		Set @cErrMsg='Error update data'    
		Goto Error    
	End    
end
else
begin
  set @cErrMsg = 'Tanggal good fund tidak boleh lebih kecil dari tanggal NAV Value Date'      
  goto Error      
end	 

return 0   
 
Error:    
If @@trancount > 0
	rollback tran

If @@error != 0
Begin      
	rollback tran    
	--Exec @nOK = set_raiserror @@procid, @nErrNo Output    
	Raiserror (@cErrMsg    ,16,1);
	return 1
End
