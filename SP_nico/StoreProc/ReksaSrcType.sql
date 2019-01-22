CREATE proc [dbo].[ReksaSrcType]
/*
	CREATED BY    : indra
	CREATION DATE : 20071017
	DESCRIPTION   : Seacrh product berdasarkan product code
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

exec ReksaSrcType '','DANA', 0

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
	select TypeCode, TypeName, TypeId
	from ReksaType_TR with (nolock)
	where TypeCode = @cCol1
End
else
begin
	
	if @cCol1 is not null and @cCol2 is null
		select TypeCode, TypeName, TypeId
		from ReksaType_TR with (nolock)
		where TypeCode like rtrim(ltrim(@cCol1)) + '%'
		order by TypeId

	else if @cCol2 is not null and @cCol1 is null
		select TypeCode, TypeName, TypeId
		from ReksaType_TR with (nolock)
		where TypeName like @cCol2 + '%'
		order by TypeId

	else if @cCol2 is not null and @cCol1 is not null
		select TypeCode, TypeName, TypeId
		from ReksaType_TR with (nolock)
		where TypeCode like rtrim(ltrim(@cCol1)) + '%'
			and TypeName like rtrim(ltrim(@cCol2)) + '%'
		order by TypeId

	else
		select TypeCode, TypeName, TypeId
		from ReksaType_TR with (nolock)
		order by TypeId

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