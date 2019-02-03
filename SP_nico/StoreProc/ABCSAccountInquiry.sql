/*create table dbo.ABCSAccountInq_TM(
AccountId		varchar(20) NOT NULL,
SubSystemId		bigint,
TransactionBranch	varchar(5),
ProductCode			varchar(10),
CurrencyType		varchar(3),
AccountType			varchar(5),
MultiCurrencyAllowed	varchar(5),
AccountStatus			varchar(5),
CurrentBalance			money)

create unique clustered index iuc_ABCSAccountInq_TM on ABCSAccountInq_TM (AccountId)

*/

alter proc dbo.ABCSAccountInquiry
/*
insert ABCSAccountInq_TM select '1111',1,'999','113','IDR','D','Y','1',10000


declare
    @pcAccountID			varchar(20)='1111',
    @pnSubSystemNId			int,
    @pcTransactionBranch	varchar(5),                
    @pcProductCode			varchar(10),               
    @pcCurrencyType			varchar(3) ,
    @pcAccountType			varchar(5),
    @pcMultiCurrencyAllowed varchar(5),
    @pcAccountStatus		varchar(5),
    @pcTellerId				varchar(5)

exec ABCSAccountInquiry
    @pcAccountID			=@pcAccountID,
    @pnSubSystemNId			=@pnSubSystemNId,
    @pcTransactionBranch	=@pcTransactionBranch,                
    @pcProductCode			=@pcProductCode	output,               
    @pcCurrencyType			=@pcCurrencyType output,
    @pcAccountType			=@pcAccountType output,
    @pcMultiCurrencyAllowed =@pcMultiCurrencyAllowed output,
    @pcAccountStatus		=@pcAccountStatus output,
    @pcTellerId				='7'

	select 
    @pcAccountID,
    @pnSubSystemNId,
    @pcTransactionBranch,                
    @pcProductCode	,               
    @pcCurrencyType ,
    @pcAccountType ,
    @pcMultiCurrencyAllowed ,
    @pcAccountStatus 

*/
    @pcAccountID			varchar(20),
    @pnSubSystemNId			int,
    @pcTransactionBranch	varchar(5),                
    @pcProductCode			varchar(10)= null  output ,               
    @pcCurrencyType			varchar(3) =null output ,
    @pcAccountType			varchar(5)=null output,
    @pcMultiCurrencyAllowed varchar(5)=null output ,
    @pcAccountStatus		varchar(5)=null output,
    @pcTellerId				varchar(5)=null output

as
set nocount on
                      
if not exists(select top 1 * from ABCSAccountInq_TM where AccountId=@pcAccountID)
begin
	raiserror ('Rekening tidak ditemukan', 16,1);
	return 1
end
select     @pcProductCode =ProductCode,               
		   @pcCurrencyType =CurrencyType,
		   @pcAccountType	=AccountType,
		   @pcMultiCurrencyAllowed =MultiCurrencyAllowed,
		   @pcAccountStatus		=AccountStatus
from ABCSAccountInq_TM a
where AccountId =@pcAccountID

return 0
