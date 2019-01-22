CREATE proc [dbo].[ReksaSrcWaperd]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20090518
	DESCRIPTION   : Search WAPERD

	exec ReksaSrcWaperd '91009','', 1
	exec ReksaSrcWaperd '9101','', 0
	exec ReksaSrcWaperd '','', 0

	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20110801, victor, BAALN10011, tambah kolom expire
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
	select e.employee_id, wa.WaperdNo
--20110801, victor, BAALN10011, begin	
		, wa.DateExpire
--20110801, victor, BAALN10011, end
	from dbo.employee_id e with (nolock)
	join dbo.ReksaWaperd_TR wa
		on e.employee_id = wa.NIK
	where employee_id = @cCol1
	order by e.employee_id
End
else
begin
	if @cCol1 is not null and @cCol2 is null
		select top 200 e.employee_id, wa.WaperdNo
--20110801, victor, BAALN10011, begin	
		, wa.DateExpire
--20110801, victor, BAALN10011, end		
		from dbo.employee_id e with (nolock)
		join dbo.ReksaWaperd_TR wa
			on e.employee_id = wa.NIK
		where employee_id like rtrim(ltrim(@cCol1)) + '%'
		order by employee_id

	else if @cCol2 is not null and @cCol1 is null
		select top 200 e.employee_id, wa.WaperdNo
--20110801, victor, BAALN10011, begin	
		, wa.DateExpire
--20110801, victor, BAALN10011, end		
		from dbo.employee_id e with (nolock)
		join dbo.ReksaWaperd_TR wa
			on e.employee_id = wa.NIK
		where wa.WaperdNo like @cCol2 + '%'
		order by employee_id

	else if @cCol2 is not null and @cCol1 is not null
		select top 200 e.employee_id, wa.WaperdNo
--20110801, victor, BAALN10011, begin	
		, wa.DateExpire
--20110801, victor, BAALN10011, end		
		from dbo.employee_id e with (nolock)
		join dbo.ReksaWaperd_TR wa
			on e.employee_id = wa.NIK
		where employee_id like rtrim(ltrim(@cCol1)) + '%'
			and wa.WaperdNo like rtrim(ltrim(@cCol2)) + '%'
		order by employee_id

	else
		select top 200 e.employee_id, wa.WaperdNo
--20110801, victor, BAALN10011, begin	
		, wa.DateExpire
--20110801, victor, BAALN10011, end		
		from dbo.employee_id e with (nolock)
		join dbo.ReksaWaperd_TR wa
			on e.employee_id = wa.NIK
		order by employee_id
end
--20071221, indra_w, REKSADN002, end
return 0

ERROR:
if isnull(@cErrMsg ,'') = ''
	set @cErrMsg = 'Error !'

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror (@cErrMsg ,16,1)
return 1
GO