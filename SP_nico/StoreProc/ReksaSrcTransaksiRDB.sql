CREATE proc [dbo].[ReksaSrcTransaksiRDB]
/*
	CREATED BY    : liliana
	CREATION DATE : 20131208
	DESCRIPTION   : Seacrh transaksi berdasarkan kode transaksi RDB
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
*/

@cCol1		varchar(10)=null,
@cCol2		varchar(40)=null,
@bValidate	bit=0

as

set nocount on

declare @cErrMsg			varchar(100)
	, @nOK				int
	, @nErrNo			int


if @cCol1='' select @cCol1=null
if @cCol2='' select @cCol2=null

if @bValidate = 1
Begin
	select tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
	from dbo.ReksaTransaction_TT tt
	join dbo.ReksaCIFData_TM rc
		on rc.ClientId = tt.ClientId
	join dbo.ReksaTransType_TR tr
		on tr.TranType = tt.TranType
	where tt.TranType = 8
		and tt.CheckerSuid != 777 
		and tt.TranCode = @cCol1
	union all
	select tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
	from dbo.ReksaTransaction_TH tt
	join dbo.ReksaCIFData_TM rc
		on rc.ClientId = tt.ClientId
	join dbo.ReksaTransType_TR tr
		on tr.TranType = tt.TranType
	where tt.TranType = 8
		and tt.CheckerSuid != 777 
		and tt.TranCode = @cCol1
End
else
begin
	if @cCol1 is not null and @cCol2 is null
	Begin
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TT tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777 
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
		union all
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TH tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777	
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
		order by tt.TranCode
	End
	else if @cCol2 is not null and @cCol1 is null
	Begin	
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TT tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777 
			and rc.ClientCode like @cCol2 + '%'
		union all
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TH tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777	
			and rc.ClientCode like @cCol2 + '%'
		order by tt.TranCode
	End
	else if @cCol2 is not null and @cCol1 is not null
	Begin
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TT tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777 
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
		union all
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TH tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777	
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and tt.TranCode like rtrim(ltrim(@cCol1)) + '%'
		order by tt.TranCode	
	End
	else
	Begin
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TT tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777 
		union all
		select top 200 tt.TranCode, rc.ClientCode, tt.TranId, tt.TranDate
		from dbo.ReksaTransaction_TH tt
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
		join dbo.ReksaTransType_TR tr
			on tr.TranType = tt.TranType
		where tt.TranType = 8
			and tt.CheckerSuid != 777
		order by tt.TranCode
	End
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