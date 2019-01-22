CREATE proc [dbo].[ReksaPopulateJurnalSKN]
/*
    CREATED BY    : liliana
    CREATION DATE : 20151202
    DESCRIPTION   : 
    REVISED BY    :
        DATE,   USER,       PROJECT,    NOTE
        -----------------------------------------------------------------------
        20151221, liliana, LIBST15001, yg failed juga ditampilin 
        20151223, liliana, LIBST15001, tampilkan yg success juga 
        20160118, liliana, LIBST15001, Prev working date
    END REVISED
    
    exec dbo.ReksaPopulateJurnalSKN null, null, null
*/
@pnClassificationId                       int,
@pcModule                               varchar(25),
@pcErrMsg                               varchar(100)    output

as

set nocount on

declare
      @dtPrevWorkingDate    datetime
    , @dtCurrWorkingDate    datetime
    , @dtNextWorkingDate    datetime
    , @cStatus              varchar(50)

select 
      @dtPrevWorkingDate = previous_working_date
    , @dtCurrWorkingDate = current_working_date
    , @dtNextWorkingDate = next_working_date
from fnGetWorkingDate()

set @cStatus = ''

if @pnClassificationId  = 71
--20151221, liliana, LIBST15001, begin
begin
--20151221, liliana, LIBST15001, end
set @cStatus ='READY'

--20151221, liliana, LIBST15001, begin
--if @pnClassificationId = 72
--set @cStatus ='PENDING'
--20151221, liliana, LIBST15001, end

select TranGuid, TranDate, TranStatus, TranRemarks, BillId, DebitAccountId, DebitCcy,
    FeeAmount, TransferAmount, BeneficiaryAccountNumber, BeneficiaryName, 
    BeneficiaryAddress1, BeneficiaryAddress2, BeneficiaryAddress3, BeneficiaryBankMemberCode,
    BeneficiaryBankName, BeneficiaryBankAddress1, BeneficiaryBankAddress2, BeneficiaryBankAddress3,
    PaymentDetails1, PaymentDetails2
from dbo.ReksaJurnalRTGS_TM
    where TranDate >= dateadd(dd,-2,@dtPrevWorkingDate)
    and JenisJurnal = 'SKN'
    and TranStatus = @cStatus    
order by BillId desc, TranDate desc
--20151221, liliana, LIBST15001, begin
end
else if @pnClassificationId = 72
begin
    select TranGuid, TranDate, TranStatus, TranRemarks, BillId, DebitAccountId, DebitCcy,
        FeeAmount, TransferAmount, BeneficiaryAccountNumber, BeneficiaryName, 
        BeneficiaryAddress1, BeneficiaryAddress2, BeneficiaryAddress3, BeneficiaryBankMemberCode,
        BeneficiaryBankName, BeneficiaryBankAddress1, BeneficiaryBankAddress2, BeneficiaryBankAddress3,
        PaymentDetails1, PaymentDetails2
    from dbo.ReksaJurnalRTGS_TM
--20151223, liliana, LIBST15001, begin     
        --where TranDate >= dateadd(dd,-14,@dtPrevWorkingDate)
        where 
        (
            TranDate >= dateadd(dd,-14,@dtPrevWorkingDate)
--20151223, liliana, LIBST15001, end        
        and JenisJurnal = 'SKN'
        and TranStatus in ('PENDING', 'FAILURE') 
--20151223, liliana, LIBST15001, begin  
        )
          OR (  
--20160118, liliana, LIBST15001, begin
          --TranDate >= dateadd(dd,0,@dtCurrWorkingDate)     
		  TranDate >= dateadd(dd,0,@dtPrevWorkingDate)
		  AND TranDate < dateadd(dd,1,@dtCurrWorkingDate)
--20160118, liliana, LIBST15001, end                 
          AND JenisJurnal = 'SKN'  
          AND TranStatus = 'SUCCESS'     
          )  
--20151223, liliana, LIBST15001, end            
    order by BillId desc, TranDate desc

end
--20151221, liliana, LIBST15001, end

return 0
GO