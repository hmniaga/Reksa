CREATE proc [dbo].[ReksaSrcTrxClient]
/*
	CREATED BY    : LILIANA
	CREATION DATE : 20120507
	DESCRIPTION   : Seacrh client reksadana
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130515, liliana, BAFEM12011, jika redemp sebagian tampilkan semua
		20140818, liliana, LIBST13021, ganti tanggal jatuh tempo
	END REVISED

exec ReksaSrcClient 1, '', 0, '@cCriteria'

*/

@cCol1		varchar(12)=null,
@cCol2		varchar(40)=null,
@bValidate	bit=0,
@cCriteria	varchar(100) = null
as

set nocount on

declare @cErrMsg			varchar(100)
	, @nOK				int
	, @nErrNo			int
	, @nProdId			int
	, @nTranType		int
	, @nReksaTranType   int

if @cCol1='' select @cCol1=null
if @cCol2='' select @cCol2=null

if(@cCriteria != '@cCriteria')
begin
	declare @tmpsplit table (    
	 num int,    
	 value varchar(100)    
	)

	 insert into @tmpsplit (num, value)    
	 select * from dbo.Split(@cCriteria, '#', 0, len(@cCriteria))    
	 select @nProdId = value from @tmpsplit where num = 1  
	 select @nTranType = value from @tmpsplit where num = 2   
	 
	 select @nReksaTranType = ReksaTranType      
	from dbo.ReksaClientTranTypeMapping_TR      
	where ClientTranType = @nTranType  
	
end

if @bValidate = 1
Begin
	if(@nReksaTranType in (1,2))
	begin
			select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
			, rc.JoinDate
--20140818, liliana, LIBST13021, end			
			from dbo.ReksaCIFData_TM rc
			left join dbo.ReksaRegulerSubscriptionClient_TM rg
			on rc.ClientId = rg.ClientId
			where rc.ClientCode = @cCol1
				and rc.ProdId = isnull(@nProdId, rc.ProdId)
				and rc.CIFStatus = 'A'
				and isnull(rc.Flag,0) != 1
				and rg.ClientId is null
	end
	else if(@nReksaTranType in (8))
	begin
			select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
			, rc.JoinDate
--20140818, liliana, LIBST13021, end			
			from dbo.ReksaCIFData_TM rc
			join dbo.ReksaRegulerSubscriptionClient_TM rg
			on rc.ClientId = rg.ClientId
			where rc.ClientCode = @cCol1
				and rc.ProdId = isnull(@nProdId, rc.ProdId)
				and rc.CIFStatus = 'A'
				and rg.Status = 1
	end
--20130515, liliana, BAFEM12011, begin	
	--else if(@nReksaTranType in (3))
	--begin
	--		select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
	--		from dbo.ReksaCIFData_TM rc
	--		left join dbo.ReksaRegulerSubscriptionClient_TM rg
	--		on rc.ClientId = rg.ClientId
	--		where rc.ClientCode = @cCol1
	--			and rc.ProdId = isnull(@nProdId, rc.ProdId)
	--			and rc.CIFStatus = 'A'
	--			and rg.ClientId is null
	--end
--20130515, liliana, BAFEM12011, end	
	else 
	begin
			select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo
--20140818, liliana, LIBST13021, begin
			, JoinDate
--20140818, liliana, LIBST13021, end			
			from dbo.ReksaCIFData_TM with (nolock)
			where ClientCode = @cCol1
				and ProdId = isnull(@nProdId,ProdId)
				and CIFStatus = 'A'
	end
End
else
begin
	if(@nReksaTranType in (1,2))
	begin
		if @cCol1 is not null and @cCol2 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and isnull(rc.Flag,0) != 1
					and rg.ClientId is null
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and isnull(rc.Flag,0) != 1
					and rg.ClientId is null
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is not null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and isnull(rc.Flag,0) != 1
					and rg.ClientId is null
				order by rc.ClientCode
			End
			else
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and isnull(rc.Flag,0) != 1
					and rg.ClientId is null
				order by rc.ClientCode
			End
		
	end
	else if(@nReksaTranType in (8))
	begin
		if @cCol1 is not null and @cCol2 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.Status = 1
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.Status = 1
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is not null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.Status = 1
				order by rc.ClientCode
			End
			else
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.Status = 1
				order by rc.ClientCode
			End
		
	end
--20130515, liliana, BAFEM12011, begin	
	--else if(@nReksaTranType in (3))
	else if(@nReksaTranType in (30))
--20130515, liliana, BAFEM12011, end	
	begin
		if @cCol1 is not null and @cCol2 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.ClientId is null
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.ClientId is null
				order by rc.ClientCode	
			End
			else if @cCol2 is not null and @cCol1 is not null
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'
					and rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.ClientId is null
				order by rc.ClientCode
			End
			else
			Begin
				select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo
--20140818, liliana, LIBST13021, begin
				, rc.JoinDate
--20140818, liliana, LIBST13021, end				
				from dbo.ReksaCIFData_TM rc
				left join dbo.ReksaRegulerSubscriptionClient_TM rg
				on rc.ClientId = rg.ClientId
				where rc.ProdId = isnull(@nProdId, rc.ProdId)
					and rc.CIFStatus = 'A'
					and rg.ClientId is null
				order by rc.ClientCode
			End
		
	end	
	else 
	begin
			if @cCol1 is not null and @cCol2 is null
			Begin
				select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo
--20140818, liliana, LIBST13021, begin
				, JoinDate
--20140818, liliana, LIBST13021, end				
				from ReksaCIFData_TM with (nolock)
				where  ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and ProdId = isnull(@nProdId,ProdId)
					and CIFStatus = 'A'
				order by ClientCode
			End
			else if @cCol2 is not null and @cCol1 is null
			Begin
				select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo
--20140818, liliana, LIBST13021, begin
				, JoinDate
--20140818, liliana, LIBST13021, end					
				from ReksaCIFData_TM with (nolock)
				where  CIFName like rtrim(ltrim(@cCol2)) + '%'
					and ProdId = isnull(@nProdId,ProdId)
					and CIFStatus = 'A'
				order by ClientCode
			End
			else if @cCol2 is not null and @cCol1 is not null
			Begin
				select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo
--20140818, liliana, LIBST13021, begin
				, JoinDate
--20140818, liliana, LIBST13021, end					
				from ReksaCIFData_TM with (nolock)
				where  ClientCode like rtrim(ltrim(@cCol1)) + '%'
					and CIFName like rtrim(ltrim(@cCol2)) + '%'
					and ProdId = isnull(@nProdId,ProdId)
					and CIFStatus = 'A'
				order by ClientCode
			End
			else
			Begin
				select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo
--20140818, liliana, LIBST13021, begin
				, JoinDate
--20140818, liliana, LIBST13021, end					
				from ReksaCIFData_TM with (nolock)
					where ProdId = isnull(@nProdId,ProdId)
					and CIFStatus = 'A'
				order by ClientCode
			End
	end
end

return 0

ERROR:
if isnull(@cErrMsg ,'') = ''
	set @cErrMsg = 'Error !'

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror (@cErrMsg,16,1)
return 1
GO