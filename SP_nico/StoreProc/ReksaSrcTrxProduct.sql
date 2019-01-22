CREATE proc [dbo].[ReksaSrcTrxProduct]
/*
	CREATED BY    : liliana
	CREATION DATE : 20141021
	DESCRIPTION   : search product berdasarkan product code
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
*/

@cCol1		varchar(10)=null,
@cCol2		varchar(40)=null,
@bValidate	tinyint=0,
@cJenisTrx	varchar(100) = '@cJenisTrx' 

as

set nocount on

declare @cErrMsg		varchar(100)
	, @nOK				int
	, @nErrNo			int
	, @cTrx				varchar(20)
	, @cCIFNo			varchar(20)

if @cCol1='' select @cCol1=null
if @cCol2='' select @cCol2=null

create table #Product (
	ProdId		int
)

if(@cJenisTrx != '@cJenisTrx')
begin
	declare @tmpsplit table (    
	 num int,    
	 value varchar(100)    
	)

	 insert into @tmpsplit (num, value)    
	 select * from dbo.Split(@cJenisTrx, '#', 0, len(@cJenisTrx))
	     
	 select @cTrx = value from @tmpsplit where num = 1  
	 select @cCIFNo = value from @tmpsplit where num = 2   
	 
	 if @cTrx in ('REDEMP', 'SWCNONRDB', 'SWCNONRDB', 'SWCRDB')
	 begin
		insert #Product (ProdId)
		select distinct ProdId 
		from dbo.ReksaCIFData_TM
		where CIFNo = @cCIFNo
	 end
end


if @bValidate = 1
Begin
	--SUBS
	if(@cTrx = 'SUBS')
	begin
		select ProdCode, ProdName, ProdId, ProdCCY
		from dbo.ReksaProduct_TM with (nolock)
		where ProdCode = @cCol1
			and CloseEndBit = 0
			and Status = 1
	end
	--REDEMP
	else if(@cTrx = 'REDEMP')
	begin
		select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
		from dbo.ReksaProduct_TM rp with (nolock)
		join #Product p
			on p.ProdId = rp.ProdId
		where rp.ProdCode = @cCol1
			and rp.Status = 1
	end
	--BOOKING 
	else if(@cTrx = 'BOOK')
	begin
		select ProdCode, ProdName, ProdId, ProdCCY
		from dbo.ReksaProduct_TM with (nolock)
		where ProdCode = @cCol1
			and CloseEndBit = 1	
			and Status = 0
	end
	--RDB
	else if(@cTrx = 'SUBSRDB')
	begin
		select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
		from ReksaProduct_TM rp with (nolock)
		join dbo.ReksaRegulerSubscription_TR rs
			on rs.ProductId = rp.ProdId
			and rp.Status = 1
		where rp.ProdCode = @cCol1
		order by rp.ProdCode	
	end	
	--SWITCHING NON RDB
	else if(@cTrx = 'SWCNONRDB')
	begin
		select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY  
		from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
		join dbo.ReksaProduct_TM rp 
			on rs.ProdSwitchOut = rp.ProdCode 
		join #Product p
			on p.ProdId = rp.ProdId
		where  rs.ProdSwitchOut = @cCol1
			and rp.Status = 1
	end	
	--SWITCHING RDB
	else if(@cTrx = 'SWCRDB')
	begin
		select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY  
		from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
		join dbo.ReksaProduct_TM rp 
			on rs.ProdSwitchOut = rp.ProdCode 
		join dbo.ReksaRegulerSubscription_TR rrs
			on rrs.ProductId = rp.ProdId				
		join #Product p
			on p.ProdId = rp.ProdId
		where  rs.ProdSwitchOut = @cCol1
			and rp.Status = 1
	end			
End
else
begin
	--SUBS
	if(@cTrx = 'SUBS')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from dbo.ReksaProduct_TM with (nolock)
			where ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and Status = 1
				and CloseEndBit = 0
			order by ProdCode
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where UPPER(ProdName) like UPPER(@cCol2) + '%'
				and Status = 1
				and CloseEndBit = 0
			order by ProdCode
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(ProdName) like rtrim(ltrim(UPPER(@cCol2))) + '%'
				and Status = 1
				and CloseEndBit = 0
			order by ProdCode
		end
		else
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where Status = 1
				and CloseEndBit = 0
			order by ProdCode
		end
	end
	--REDEMP
	else if(@cTrx = 'REDEMP')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProduct_TM rp with (nolock)
			join #Product p
				on p.ProdId = rp.ProdId
			where rp.ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and rp.Status = 1
			order by rp.ProdCode
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProduct_TM rp with (nolock)
			join #Product p
				on p.ProdId = rp.ProdId
			where UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1
			order by rp.ProdCode	
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProduct_TM rp with (nolock)
			join #Product p
				on p.ProdId = rp.ProdId
			where rp.ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1
			order by rp.ProdCode		
		end
		else
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProduct_TM rp with (nolock)
			join #Product p
				on p.ProdId = rp.ProdId
			where rp.Status = 1
			order by rp.ProdCode	
		end
	end	
	--BOOKING 
	else if(@cTrx = 'BOOK')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from dbo.ReksaProduct_TM with (nolock)
			where ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and Status = 0
				and CloseEndBit = 1
			order by ProdCode
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where UPPER(ProdName) like UPPER(@cCol2) + '%'
				and Status = 0
				and CloseEndBit = 1
			order by ProdCode
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(ProdName) like rtrim(ltrim(UPPER(@cCol2))) + '%'
				and Status = 0
				and CloseEndBit = 1
			order by ProdCode
		end
		else
		begin
			select ProdCode, ProdName, ProdId, ProdCCY
			from ReksaProduct_TM with (nolock)
			where Status = 0
				and CloseEndBit = 1
			order by ProdCode
		end	
	end
	--RDB
	else if(@cTrx = 'SUBSRDB')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProduct_TM rp with (nolock)
			join dbo.ReksaRegulerSubscription_TR rs
				on rs.ProductId = rp.ProdId
			where rp.ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and rp.Status = 1
			order by rp.ProdCode
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select  rp.ProdCode,  rp.ProdName,  rp.ProdId, rp.ProdCCY
			from ReksaProduct_TM rp with (nolock)
			join dbo.ReksaRegulerSubscription_TR rs
				on rs.ProductId = rp.ProdId
			where UPPER( rp.ProdName) like UPPER(@cCol2) + '%'
				and  rp.Status = 1
			order by  rp.ProdCode
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from ReksaProduct_TM rp with (nolock)
			join dbo.ReksaRegulerSubscription_TR rs
				on rs.ProductId = rp.ProdId
			where rp.ProdCode like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(rp.ProdName) like rtrim(ltrim(UPPER(@cCol2))) + '%'
				and rp.Status = 1
			order by rp.ProdCode
		end
		else
		begin
			select rp.ProdCode, rp.ProdName, rp.ProdId, rp.ProdCCY
			from ReksaProduct_TM rp with (nolock)
			join dbo.ReksaRegulerSubscription_TR rs
				on rs.ProductId = rp.ProdId
				and rp.Status = 1
			order by rp.ProdCode
		end	
	end
	--SWITCHING NON RDB
	else if(@cTrx = 'SWCNONRDB')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join #Product p
				on p.ProdId = rp.ProdId
			where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'
				and rp.Status = 1
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join #Product p
				on p.ProdId = rp.ProdId
			where  UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1		
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join #Product p
				on p.ProdId = rp.ProdId
			where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1			
		end
		else
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY  
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
			on rs.ProdSwitchOut = rp.ProdCode 
			join #Product p
			on p.ProdId = rp.ProdId
			where rp.Status = 1	
		end
	end
	--SWITCHING RDB
	else if(@cTrx = 'SWCRDB')
	begin
		if @cCol1 is not null and @cCol2 is null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join dbo.ReksaRegulerSubscription_TR rrs
				on rrs.ProductId = rp.ProdId				
			join #Product p
				on p.ProdId = rp.ProdId
			where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'
				and rp.Status = 1
		end
		else if @cCol2 is not null and @cCol1 is null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join dbo.ReksaRegulerSubscription_TR rrs
				on rrs.ProductId = rp.ProdId					
			join #Product p
				on p.ProdId = rp.ProdId
			where  UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1		
		end
		else if @cCol2 is not null and @cCol1 is not null
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join dbo.ReksaRegulerSubscription_TR rrs
				on rrs.ProductId = rp.ProdId					
			join #Product p
				on p.ProdId = rp.ProdId
			where  rs.ProdSwitchOut like rtrim(ltrim(@cCol1)) + '%'
				and UPPER(rp.ProdName) like UPPER(@cCol2) + '%'
				and rp.Status = 1			
		end
		else
		begin
			select distinct rs.ProdSwitchOut, rp.ProdName, rp.ProdId, rp.ProdCCY  
			from dbo.ReksaProdSwitchingParam_TR rs  with (nolock)  
			join dbo.ReksaProduct_TM rp 
				on rs.ProdSwitchOut = rp.ProdCode 
			join dbo.ReksaRegulerSubscription_TR rrs
				on rrs.ProductId = rp.ProdId					
			join #Product p
				on p.ProdId = rp.ProdId
			where rp.Status = 1	
		end
	end		
	
end

drop table #Product

return 0

ERROR:
if isnull(@cErrMsg ,'') = ''
	set @cErrMsg = 'Error !'

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror (@cErrMsg ,16,1)
return 1
GO