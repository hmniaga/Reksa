CREATE proc [dbo].[ReksaPopulateVerifyDocuments]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20150520
 DESCRIPTION   :  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20150617, liliana, LIBST13020, baca ke TH juga
  20150619, liliana, LIBST13020, ganti table
 END REVISED 

 
*/  
 @pnTranId							int,
 @pbIsEdit							bit,
 @pbIsSwitching						bit,
 @pbIsBooking						bit,
 @pcRefID							varchar(50) = ''
as  
  
set nocount on  
  
declare 
	@cErrMsg	varchar(100)  
  , @nOK		int  
  , @nErrNo		int  

if isnull(@pcRefID,'') !=''
begin
	if(@pbIsSwitching = 1)
	begin
		select @pnTranId = TranId
--20150619, liliana, LIBST13020, begin		
		--from dbo.ReksaSwitchingTransaction_TMP
		from dbo.ReksaSwitchingTransaction_TM	
--20150619, liliana, LIBST13020, end		
		where RefID = @pcRefID
	end
	else  if(@pbIsBooking = 1)
	begin
		select @pnTranId = BookingId
		from dbo.ReksaBooking_TM
		where RefID = @pcRefID
--20150619, liliana, LIBST13020, begin

		if isnull(@pnTranId,0) = 0
		begin
			select @pnTranId = BookingId
			from dbo.ReksaBooking_TH
			where RefID = @pcRefID	
		end
--20150619, liliana, LIBST13020, end		
	end
	else
	begin
		select @pnTranId = TranId
		from dbo.ReksaTransaction_TT
		where RefID = @pcRefID	
--20150617, liliana, LIBST13020, begin
		
		if isnull(@pnTranId,0) = 0
		begin
			select @pnTranId = TranId
			from dbo.ReksaTransaction_TH
			where RefID = @pcRefID			
		end
--20150617, liliana, LIBST13020, end		
	end

end

if(@pbIsSwitching = 1)
begin
	if(@pbIsEdit = 1)
	begin
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaSwitchingTransaction_TMP
		where TranId = 	@pnTranId
			and AuthType = 4	 
	end
	else
	begin
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaSwitchingTransaction_TM
		where TranId = 	@pnTranId
	end

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsSwitching, 0) = 1     
		and DocType = 'FC' -- from customer  	

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsSwitching, 0) = 1     
		and DocType = 'TC' -- to customer  		
end
else  if(@pbIsBooking = 1)
begin
	if(@pbIsEdit = 1)
	begin
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaBooking_TH
		where BookingId = @pnTranId
			and AuthType = 4	 
	end
	else
	begin
--20150619, liliana, LIBST13020, begin
		if exists(select top 1 1 from dbo.ReksaBooking_TM where BookingId = @pnTranId)
		begin
--20150619, liliana, LIBST13020, end	
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaBooking_TM
		where BookingId = @pnTranId
--20150619, liliana, LIBST13020, begin
		end
		else
		begin
			select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
			, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
			, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
			from dbo.ReksaBooking_TH
			where BookingId = @pnTranId		
		end
--20150619, liliana, LIBST13020, end		
	end

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsBooking, 0) = 1     
		and DocType = 'FC' -- from customer  	

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsBooking, 0) = 1     
		and DocType = 'TC' -- to customer  		
end
else
begin
	if(@pbIsEdit = 1)
	begin
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaTransaction_TMP
		where TranId = @pnTranId
			and AuthType = 4	 
	end
	else
	begin
--20150617, liliana, LIBST13020, begin
		if exists(select top 1 1 from dbo.ReksaTransaction_TT where TranId = @pnTranId)
		begin
--20150617, liliana, LIBST13020, end	
		select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
		, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
		, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
		from dbo.ReksaTransaction_TT
		where TranId = @pnTranId
--20150617, liliana, LIBST13020, begin
		end
		else
		begin
			select DocFCSubscriptionForm,DocFCDevidentAuthLetter,DocFCJoinAcctStatementLetter          
			, DocFCIDCopy, DocFCOthers, DocTCSubscriptionForm, DocTCTermCondition                    
			, DocTCProspectus, DocTCFundFactSheet, DocTCOthers  
			from dbo.ReksaTransaction_TH
			where TranId = @pnTranId		
		end
--20150617, liliana, LIBST13020, end		
	end

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsBooking, 0) = 0     
		and isnull(IsSwitching, 0) = 0
		and DocType = 'FC' -- from customer  	

	select OtherDoc
	from dbo.ReksaOtherDocuments_TM
	where TranId = @pnTranId 
		and isnull(IsBooking, 0) = 0     
		and isnull(IsSwitching, 0) = 0    
		and DocType = 'TC' -- to customer 
end                
 
return 0  
  
ERROR:  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg ,16,1);
return 1
GO