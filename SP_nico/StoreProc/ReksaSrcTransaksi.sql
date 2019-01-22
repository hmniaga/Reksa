CREATE proc [dbo].[ReksaSrcTransaksi]
/*
	CREATED BY    : victor
	CREATION DATE : 20071108
	DESCRIPTION   : Seacrh transaksi berdasarkan kode transaksi
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
	select a.TranCode, b.ClientCode, a.TranId, a.TranDate
	from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
	with (nolock)
	where a.TranCode = @cCol1
		and a.ClientId = b.ClientId
		and a.TranType = c.TranType
	union all
	select a.TranCode, b.ClientCode, a.TranId, a.TranDate
	from dbo.ReksaTransaction_TH a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
	with (nolock)
	where a.TranCode = @cCol1
		and a.ClientId = b.ClientId
		and a.TranType = c.TranType
End
else
begin
	
	if @cCol1 is not null and @cCol2 is null
	Begin
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where a.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		union all
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TH a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where a.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		order by a.TranCode
	End
	else if @cCol2 is not null and @cCol1 is null
	Begin
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where b.ClientCode like @cCol2 + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		union all
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TH a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where b.ClientCode like @cCol2 + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		order by a.TranCode
	End
	else if @cCol2 is not null and @cCol1 is not null
	Begin
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where a.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and b.ClientCode like rtrim(ltrim(@cCol2)) + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		union all
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TH a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where a.TranCode like rtrim(ltrim(@cCol1)) + '%'
			and b.ClientCode like rtrim(ltrim(@cCol2)) + '%'
			and a.ClientId = b.ClientId
			and a.TranType = c.TranType
		order by a.TranCode
	End
	else
	Begin
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TT a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where  a.ClientId = b.ClientId
			and a.TranType = c.TranType
		union all
		select top 200 a.TranCode, b.ClientCode, a.TranId, a.TranDate
		from dbo.ReksaTransaction_TH a, dbo.ReksaCIFData_TM b, dbo.ReksaTransType_TR c
		with (nolock)
		where  a.ClientId = b.ClientId
			and a.TranType = c.TranType
		order by a.TranCode
	End
end

return 0

ERROR:
if isnull(@cErrMsg ,'') = ''
	set @cErrMsg = 'Error !'

exec @nOK = set_raiserror @@procid, @nErrNo output  
if @nOK != 0 return 1  
  
raiserror (@cErrMsg ,16,1)
return 1
GO