
CREATE proc [dbo].[ReksaMaintainPendingTransaksi]            
/*            
 CREATED BY    :             
 CREATION DATE :          
 DESCRIPTION   :         
 REVISED BY    :            
  DATE,  USER,   PROJECT,  NOTE            
  -----------------------------------------------------------------------            

 END REVISED            
            
*/            
@pnPendingId				int
as        
            
set nocount on            
            
declare @nOK            tinyint,     
  @cErrMsg              varchar(200),
  @nErrNo               int,
  @bIsSwc				bit,
  @dCurrWorkingDate		datetime,  
  @dNextWorkingDate		datetime,
  @dCurrDate			datetime,
  @pnTranId				int,
  @pdNAVValueDate		datetime,
  @nCutOff				int,  
  @dCutOff				datetime,    
  @bProcessStatus		bit,
  @pnClientId			int,
  @nReksaTranType		int,
  @pnProdId				int,
  @pnRedemptionUnit     decimal(25,13),
  @dGoodFund			datetime,
  @nWindowPeriod		int,
  @nManInvId			int,
  @nNDayBefore          int,
  @nExtStatus			varchar(50),
  @nProdIdException		int,
  @mLastNAV				decimal(25,13)
  
set @bIsSwc = 0

if exists(select top 1 1 from dbo.CIFPendingTransactionSwcReksadana_TT_v 
	where PendingId = @pnPendingId
	)
begin
	set @bIsSwc = 1
end


if @bIsSwc = 1
begin
	select @nReksaTranType = TranType, 
		   @pnProdId = ProdSwitchOut,
		   @pnClientId = ClientIdSwcOut,
		   @pnRedemptionUnit = TranUnit,
		   @nExtStatus = ExtStatus
	from dbo.CIFPendingTransactionSwcReksadana_TT_v
	where PendingId = @pnPendingId
end
else
begin
	select @nReksaTranType = TranType, 
		   @pnProdId = ProdId, 
		   @pnClientId = ClientId,
		   @pnRedemptionUnit = TranUnit,
		   @nExtStatus = ExtStatus
	from dbo.CIFPendingTransactionReksadana_TT_v
	where PendingId = @pnPendingId
end

 select @dCurrWorkingDate = current_working_date,  
     @dNextWorkingDate = next_working_date    
 from dbo.fnGetWorkingDate()  
 
select @dCurrDate = current_working_date              
from dbo.control_table  
 
 select @nCutOff = CutOff, @bProcessStatus = ProcessStatus              
 from dbo.ReksaUserProcess_TR     
 where ProcessId = 1       
               
 set @dCutOff = dateadd (minute, @nCutOff, @dCurrWorkingDate)          
 
 
if (@dCurrWorkingDate < @dCutOff) and (@bProcessStatus = 0)              
begin              
    set @pdNAVValueDate = @dCurrWorkingDate          
end              
else              
begin                         
    If @dCurrDate != convert(datetime, convert(char(8),@dCurrWorkingDate,112))    
    begin                    
        set @pdNAVValueDate = @dCurrWorkingDate         
    end       
    else              
    begin    
		set @pdNAVValueDate = @dNextWorkingDate               
    end           
end
              

if @nReksaTranType in (3,4)
begin                    
	--window period    
	select @nWindowPeriod = WindowPeriod,    
		@nManInvId = ManInvId    
	 from dbo.ReksaProduct_TM                 
	 where ProdId = @pnProdId    
	   
	 select @nNDayBefore = NDayBefore            
	 from ReksaWindowPeriod_TM            
	 where ProdId = @pnProdId      
	 
	if @nWindowPeriod = 1       
	Begin            
	if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate, @pnRedemptionUnit) =  0            
	Begin                  
		set @cErrMsg = 'Tidak Boleh Redemp di luar Window Period'         
		goto ERROR                   
	End              

	if dbo.fnIsWindowPeriod(@pnProdId, @pdNAVValueDate, @pnRedemptionUnit) =  2            
	Begin                  
		set @cErrMsg = 'Nilai Redemp melebihi nilai AUM'      
		goto ERROR                           
	End                  
	end     

    select @nProdIdException = ProdId   
    from dbo.ReksaProduct_TM  
    where ProdCode = 'RDS'
 
    select top 1 @mLastNAV = NAV            
    from dbo.ReksaNAVParam_TH            
    where ProdId = @pnProdId            
    order by ValueDate desc 
        
   --set good fund and window period
    if isnull(@nWindowPeriod,0) = 0        
    Begin                    
        if @nManInvId = 1        
        begin  
            if ((@pnRedemptionUnit * @mLastNAV) > 5000000000) and @nManInvId = 1 and @pnProdId != @nProdIdException           
            begin                  
                set @pdNAVValueDate= dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,1)                         
                set @nExtStatus=2            
            end            
        end          
    End    
    else        
    Begin           
        set @pdNAVValueDate = dbo.fnReksaGoodFund(@pnProdId,@pdNAVValueDate,3)     
                    
        if @nNDayBefore != 0        
        Begin   
             set @nExtStatus=6        
        End        
    End   

    If @nExtStatus = 2        
    begin
         set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId, convert(varchar,@pdNAVValueDate,112) ,4)        
    end  
    else
    begin        
        set @dGoodFund = dbo.fnReksaGoodFund(@pnProdId,convert(varchar,@pdNAVValueDate,112) ,2)
    end
end        


if exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType = 6 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientId)     
begin    
    set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan switching all hari ini.'                       
    goto ERROR      
end    
else if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType = 4 and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)    
begin    
    set @cErrMsg = 'Tidak bisa melakukan transaksi karena sudah melakukan redempt all hari ini.'                       
    goto ERROR      
end    
else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcOut = @pnClientId)    
begin    
    set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah di switch out hari ini.'                       
    goto ERROR      
end    
else if @nReksaTranType in (1,2) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (3,4) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)    
begin    
    set @cErrMsg = 'Tidak bisa Subs New/Add karena Client Code sudah pernah redempt hari ini.'                       
    goto ERROR      
end    
else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaSwitchingTransaction_TM where TranType in (5,6) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientIdSwcIn = @pnClientId)    
begin    
    set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah di switch in hari ini.'                       
    goto ERROR      
end    
else if @nReksaTranType in (3,4) and exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (1,2,8) and Status in (0, 1) and NAVValueDate  = convert(char(8),@pdNAVValueDate,112) and ClientId = @pnClientId)    
begin    
    set @cErrMsg = 'Tidak bisa Redempt karena Client Code sudah pernah subs new/add hari ini.'                       
    goto ERROR      
end    


begin tran

if @bIsSwc = 0
begin      
	--trx non swc
	 insert dbo.ReksaTransaction_TT (TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId,              
			TranCCY, TranAmt, TranUnit, SubcFee, RedempFee, NAV, NAVValueDate, UnitBalance, UnitBalanceNom,                         
			UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,ExtStatus,GoodFund                          
			,JangkaWaktu,JatuhTempo,AutoRedemption,GiftCode,BiayaHadiah          
			,RegSubscriptionFlag,Asuransi,Inputter, Seller, Waperd             
			, FrekPendebetan, IsFeeEdit     
			, RedempFeeBased, TotalRedempFeeBased    
			, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased    
			, JenisPerhitunganFee, PercentageFee, Channel  
			, RefID, Referentor, OfficeId, AuthType   
			, DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter              
			, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                     
			, DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers           
		)
	 select TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId,              
			TranCCY, TranAmt, TranUnit, SubcFee, RedempFee, NAV, @pdNAVValueDate, UnitBalance, UnitBalanceNom,                         
			UserSuid, WMOtor, Status, ByUnit, FullAmount, SalesId, SubcFeeBased,@nExtStatus,@dGoodFund                          
			,JangkaWaktu,JatuhTempo,AutoRedemption,GiftCode,BiayaHadiah          
			,RegSubscriptionFlag,Asuransi,Inputter, Seller, Waperd             
			, FrekPendebetan, IsFeeEdit     
			, RedempFeeBased, TotalRedempFeeBased    
			, TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalSubcFeeBased    
			, JenisPerhitunganFee, PercentageFee, Channel  
			, RefID, Referentor, OfficeId, AuthType   
			, DocFCSubscriptionForm, DocFCDevidentAuthLetter, DocFCJoinAcctStatementLetter              
			, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm                     
			, DocTCTermCondition, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
	 from dbo.CIFPendingTransactionReksadana_TT_v    
	 where PendingId = @pnPendingId
		and TranType in (1,2,3,4,8)
		
	if @@error <> 0          
	begin          
		set @cErrMsg = 'Gagal insert data ReksaTransaction_TT'          
		rollback tran          
		goto ERROR          
	end          
end
else if @bIsSwc = 1
begin
	--trx swc
	 insert dbo.ReksaSwitchingTransaction_TM (TranCode, TranType, TranDate, ProdSwitchOut, ProdSwitchIn,         
		  ClientIdSwcOut, ClientIdSwcIn, FundIdSwcOut, FundIdSwcIn, SelectedAccNo, AgentId,         
		  SalesId, TranCCY, TranAmt, TranUnit, SwitchingFee, NAVSwcOut, NAVSwcIn, NAVValueDate,         
		  UnitBalanceSwcOut, UnitBalanceNomSwcOut, UnitBalanceSwcIn, UnitBalanceNomSwcIn, Status, ByUnit,         
		  Inputter, UserSuid, ReverseSuid, CheckerSuid, Seller, Waperd, InputDate, AuthDate              
		  , IsFeeEdit,DocFCSubscriptionForm,DocFCDevidentAuthLetter                       
		  ,DocFCJoinAcctStatementLetter,DocFCIDCopy,DocFCOthers                                   
		 ,DocTCSubscriptionForm,DocTCTermCondition,DocTCProspectus,DocTCFundFactSheet                            
		 ,DocTCOthers,PercentageFee,JenisPerhitunganFee, SwitchingFeeBased, 
		 TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased               
		 , Channel, RefID, OfficeId, Referentor, AuthType, IsNew, ExtStatus           
	  )        
	  select TranCode, TranType, TranDate, ProdSwitchOut, ProdSwitchIn,         
		  ClientIdSwcOut, ClientIdSwcIn, FundIdSwcOut, FundIdSwcIn, SelectedAccNo, AgentId,         
		  SalesId, TranCCY, TranAmt, TranUnit, SwitchingFee, NAVSwcOut, NAVSwcIn, @pdNAVValueDate,         
		  UnitBalanceSwcOut, UnitBalanceNomSwcOut, UnitBalanceSwcIn, UnitBalanceNomSwcIn, Status, ByUnit,         
		  Inputter, UserSuid, ReverseSuid, CheckerSuid, Seller, Waperd, InputDate, AuthDate              
		  , IsFeeEdit,DocFCSubscriptionForm,DocFCDevidentAuthLetter                       
		  ,DocFCJoinAcctStatementLetter,DocFCIDCopy,DocFCOthers                                   
		 ,DocTCSubscriptionForm,DocTCTermCondition,DocTCProspectus,DocTCFundFactSheet                            
		 ,DocTCOthers,PercentageFee,JenisPerhitunganFee, SwitchingFeeBased, 
		 TaxFeeBased, FeeBased3, FeeBased4, FeeBased5, TotalFeeBased               
		 , Channel, RefID, OfficeId, Referentor, AuthType, IsNew, ExtStatus
	  from dbo.CIFPendingTransactionSwcReksadana_TT_v	                
	 where PendingId = @pnPendingId       
	        
	if @@error <> 0                
	begin                
	  set @cErrMsg = 'Gagal insert data ReksaSwitchingTransaction_TM'                
	  rollback tran                
	  goto ERROR                
	end            

end

commit tran
         
return 0        
      
ERROR:  
if @@trancount >0  
    rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
    set @cErrMsg = 'Error !'  
  
exec @nOK = set_raiserror @@procid, @nErrNo output    
if @nOK != 0 return 1   
    
raiserror ( @cErrMsg  ,16,1);

return 1
GO