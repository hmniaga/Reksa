CREATE proc  [dbo].[set_raiserror] 
/*
	CREATED BY    : 
	CREATION DATE : 
	DESCRIPTION   : Menentukan No Raiserror dari sp atau trigger2
	REVISED BY    :
		DATE, USER, PROJECT, NOTE
		-----------------------------------------------------------------------

	END REVISED
*/
@nProcIdent		int,
@nErrorNo		int output

as
set nocount on 
set xact_abort on

declare 

	@sp_name			varchar(30)

select @sp_name=rtrim(object_name(@nProcIdent))

set @nErrorNo = 100000
/*
select @nErrorNo = error_no
	from raiserror_table_v
	where stored_procedure_name = @sp_name

if @nErrorNo is null
begin
   declare @nGenerate int

   if right(@sp_name,2)='_t'
      select @nGenerate=max(error_no)+10 
		from raiserror_table_v
      where error_no<200000
   else
      select @nGenerate=max(error_no)+10 
		from raiserror_table_v

   insert into raiserror_table_v
   select @nGenerate,@sp_name

   select @nErrorNo=@nGenerate
end
*/
return 0
