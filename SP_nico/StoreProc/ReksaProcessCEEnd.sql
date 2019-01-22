CREATE proc [dbo].[ReksaProcessCEEnd]
/*
    CREATED BY    : indra
    CREATION DATE : 20071017
    DESCRIPTION   : Penutupan Otomatis rekening Close End yang sudah mature
    REVISED BY    :
        DATE,   USER,       PROJECT,    NOTE
        -----------------------------------------------------------------------
        20071205, indra_w, REKSADN002, bersihin table temp
        20071207, indra_w, REKSADN002, support idola
        20071210, indra_w, REKSADN002, tutup rekeningnya
        20071218, indra_w, REKSADN002, perbaikan UAT
        20111025, liliana, BAALN10012, partial maturity
        20111208, sheila, LOGAM02011, perbaikan redemtion all untuk product yang mature di hari libur
        20150130, liliana, LIBST13020, perubahan agent id menjadi office id
        20150608, liliana, LIBST13020, rekening usd
        20150730, liliana, LIBST13020, rekening mcy
        20160830, liliana, LOGEN00196, tax amnesty
    END REVISED
*/
as

set nocount on

declare @cErrMsg            varchar(100)
        , @nOK              int
        , @nErrNo           int
        , @nUserSuid        int
        , @dCurrDate        datetime
        , @dCurrWorkingDate datetime
        , @dNextWorkingDate datetime
        , @dTranDate        datetime
        , @dMatureDate      datetime
        , @nProdId          int
        , @cProdCCY         char(3)
        , @cPrefix          char(3)
        , @nCounter         int
        , @cPeriod          varchar(8)
--20111208, sheila, LOGAM02011, begin
        , @dMaturityDate    datetime
--20111208, sheila, LOGAM02011, end
--20150130, liliana, LIBST13020, begin
        , @cRefID           varchar(20)
--20150130, liliana, LIBST13020, end 


exec @nOK = set_usersuid @nUserSuid output  
if @nOK != 0 or @@error != 0 return 1  

exec @nOK = cek_process_table @nProcID = @@procid   
if @nOK != 0 or @@error != 0 return 1  

exec @nOK = set_process_table @@procid, null, @nUserSuid, 1  
if @nOK != 0 or @@error != 0 return 1  

set @nOK = 0

select @dCurrDate = current_working_date
from control_table

select @dCurrWorkingDate = current_working_date
    , @dNextWorkingDate = next_working_date
    , @dTranDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate()) 
from fnGetWorkingDate()

If @dCurrDate < @dCurrWorkingDate
Begin
    exec @nOK = set_process_table @@procid, null, @nUserSuid, 0  
    if @nOK != 0 or @@error != 0 return 1

    return 0
End

CREATE TABLE #TempReksaTransaction_TT  (
TranId                          int                 identity  ,
TranType                        tinyint             not null  ,
TranDate                        datetime            not null  ,
ProdId                          int                 not null  ,
ClientId                        int                 not null  ,
FundId                          int                 null  ,
AgentId                         int                 not null  ,
TranCCY                         char(3    )         not null  ,
TranAmt                         money               null      ,
TranUnit                        money               null      ,
SubcFee                         money               null      ,
RedempFee                       money               null      ,
SubcFeeBased                    money               null      ,
RedempFeeBased                  money               null      ,
--20071207, indra_w, REKSADN002, begin
NAV                             decimal(20,10)               null      ,
--20071207, indra_w, REKSADN002, end
NAVValueDate                    datetime            null      ,
Kurs                            money               null      ,
UnitBalance                     money               null      ,
UnitBalanceNom                  money               null      ,
ParamId                         int                 null      ,
ProcessDate                     datetime            null      ,
SettleDate                      datetime            null      ,
Settled                         bit                 null      ,
LastUpdate                      datetime            null      ,
UserSuid                        int                 null      ,
CheckerSuid                     int                 null      ,
WMCheckerSuid                   int                 null      ,
WMOtor                          bit                 null      ,
ReverseSuid                     int                 null      ,
Status                          tinyint             null      ,
BillId                          int                 null      ,
ByUnit                          bit                 null      ,
--20150130, liliana, LIBST13020, begin
OfficeId                        varchar(5),
RefID                           varchar(20),
--20150130, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, begin
SelectedAccNo                   varchar(20),
--20150608, liliana, LIBST13020, end
BlockSequence                   int                 null      )

select @cPeriod = convert(char(8), @dCurrWorkingDate, 112)

--20111025, liliana, BAALN10012, begin
--declare prod_cur cursor local fast_forward for 
--  select ProdId, ProdCCY, left(ProdCode,3)
--  from ReksaProduct_TM
--  where MatureDate >= @dCurrWorkingDate
--      and MatureDate < @dNextWorkingDate 
----20071210, indra_w, REKSADN002, begin
--      and Status = 1
--      and CloseEndBit = 1            
----20071210, indra_w, REKSADN002, end
--  order by ProdId
declare prod_cur cursor local fast_forward for 
--20111208, sheila, LOGAM02011, begin
--  select rp.ProdId, rp.ProdCCY, left(rp.ProdCode,3)
    select rp.ProdId, rp.ProdCCY, left(rp.ProdCode,3), rp.MatureDate
--20111208, sheila, LOGAM02011, end
    from ReksaProduct_TM rp
    left join ReksaPartialMaturityParam_TM pm on rp.ProdCode = pm.KodeProduk and pm.IsMaturity = 1
    where 
        pm.KodeProduk is null
        and rp.Status = 1
        and rp.CloseEndBit = 1  
        and rp.MatureDate >= @dCurrWorkingDate
        and rp.MatureDate < @dNextWorkingDate
    order by rp.ProdId
--20111025, liliana, BAALN10012, end

open prod_cur 

while 1=1
begin
--20111208, sheila, LOGAM02011, begin
--  fetch prod_cur into @nProdId, @cProdCCY, @cPrefix
    fetch prod_cur into @nProdId, @cProdCCY, @cPrefix, @dMaturityDate
--20111208, sheila, LOGAM02011, end
    if @@fetch_status!=0    break

    select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate()) 

--20071205, indra_w, REKSADN002, begin
    delete #TempReksaTransaction_TT
--20071205, indra_w, REKSADN002, end
    Begin Tran
--20150130, liliana, LIBST13020, begin
        exec ReksaGenerateRefID 'REDEMP', @cRefID output 
        
--20150130, liliana, LIBST13020, end    
        -- ini buat ngelock doank biar ngga ada yang pake
        Update ReksaClientCounter_TR with(rowlock)
        set Trans = @nCounter
            , @nCounter = isnull(Trans, 0)
        where ProdId = @nProdId             

        insert #TempReksaTransaction_TT(TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY
--20150130, liliana, LIBST13020, begin
            , OfficeId, RefID
--20150130, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, begin
            , SelectedAccNo
--20150608, liliana, LIBST13020, end        
            , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate
            , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate
            , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence)
--20111208, sheila, LOGAM02011, begin
--      select 4, @dTranDate, ProdId, ClientId, null, AgentId, @cProdCCY
        select 4, case when @dMaturityDate > @dTranDate then dateadd(day, datediff(day, getdate(), @dNextWorkingDate), getdate()) 
                     else @dTranDate end, 
            ProdId, ClientId, null, AgentId, @cProdCCY
--20111208, sheila, LOGAM02011, end
--20071218, indra_w, REKSADN002, begin
--20150130, liliana, LIBST13020, begin
            , b.OfficeId, @cRefID
--20150130, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, begin
--20150730, liliana, LIBST13020, begin
            --, case when @cProdCCY = 'USD' then b.NISPAccountIdUSD else b.NISPAccountId end
            , case when @cProdCCY = 'IDR' and isnull(b.NISPAccountId,'') != '' then b.NISPAccountId 
                    when @cProdCCY = 'USD' and isnull(b.NISPAccountIdUSD,'') != '' then b.NISPAccountIdUSD
                    else b.NISPAccountIdMC end
--20150730, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end    
            , UnitNominal, UnitBalance, 0, 0, 0, null, 0, @dCurrWorkingDate
--20071218, indra_w, REKSADN002, end
            , 1, 0, 0, 0, null, null, 0, @dTranDate
            , 7, 7, null, 0, null, 1, 0, 1, 0
--20150130, liliana, LIBST13020, begin          
        --from ReksaCIFData_TM
        from ReksaCIFData_TM a
        join dbo.ReksaMasterNasabah_TM b
            on a.CIFNo = b.CIFNo
--20150130, liliana, LIBST13020, end
        where ProdId = @nProdId
            and CIFStatus = 'A'
            and UnitNominal > 0

        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End

        insert ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY
            , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate
            , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate
--20150130, liliana, LIBST13020, begin
            , OfficeId, RefID, AuthType
--20150130, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, begin
            , SelectedAccNo
--20150608, liliana, LIBST13020, end            
            , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence)
        select @cPrefix+right('00000'+convert(varchar(5),@nCounter + TranId),5), TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY
            , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate
            , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate
--20150130, liliana, LIBST13020, begin
            , OfficeId, RefID, 1
--20150130, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, begin
            , SelectedAccNo
--20150608, liliana, LIBST13020, end            
            , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence
        from #TempReksaTransaction_TT
--20160830, liliana, LOGEN00196, begin
		where ClientId not in (select ClientIdTax from ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)
			

        insert ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY
            , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate
            , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate
            , OfficeId, RefID, AuthType
            , SelectedAccNo        
            , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence
            , ExtStatus
            )
        select @cPrefix+right('00000'+convert(varchar(5),@nCounter + TranId),5), TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY
            , TranAmt, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate
            , Kurs, UnitBalance, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate
            , OfficeId, RefID, 1
            , SelectedAccNo        
            , UserSuid, CheckerSuid, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence
            , 74
        from #TempReksaTransaction_TT
		where ClientId in (select ClientIdTax from ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)
						
--20160830, liliana, LOGEN00196, end        

        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End

        select @nCounter = @nCounter + max(TranId)
        from #TempReksaTransaction_TT

        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End

        Update ReksaClientCounter_TR with(rowlock)
        set Trans = @nCounter
        where ProdId = @nProdId      

        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End

        Update ReksaProduct_TM
        set Status = 3
        where ProdId = @nProdId

        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End
--20071210, indra_w, REKSADN002, begin
        update ReksaCIFData_TM
        set CIFStatus = 'T'
            , LastUpdate = @dTranDate
        where ProdId = @nProdId
            and CIFStatus = 'A'
--20071210, indra_w, REKSADN002, end
--20071210, indra_w, REKSADN002, begin
        if @@error!= 0
        Begin
            set @nOK = 1
            Goto NEXT
        End

        Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate
                , ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)
--20071218, indra_w, REKSADN002, begin
--      select 2, @cPeriod + ' - Redemption - '+ c.CustodyName, 'D', @dTranDate, @dNextWorkingDate
        select 5, @cPeriod + ' - Redemption - '+ c.CustodyName, 'D', @dTranDate, @dNextWorkingDate
--20071218, indra_w, REKSADN002, end
            , a.ProdId, c.CustodyId, a.TranCCY
            , sum(case when a.TranCCY = 'IDR' then round(isnull(a.TranAmt,0), 0) else round(isnull(a.TranAmt,0), 2) end )
            , sum(case when a.TranCCY = 'IDR' then round(isnull(a.SubcFee,0), 0) else round(isnull(a.SubcFee,0), 2) end )
            , sum(case when a.TranCCY = 'IDR' then round(isnull(a.SubcFeeBased,0), 0) else round(isnull(a.SubcFeeBased,0), 2) end )
        from ReksaTransaction_TT a join ReksaProduct_TM b
                on a.ProdId = b.ProdId
            join ReksaCustody_TR c
                on b.CustodyId = c.CustodyId
        where a.TranType in (3,4)
            and isnull(a.BillId, 0) = 0
            and a.Status = 1
            and b.CloseEndBit = 1
            and b.ProdId = @nProdId
        group by c.CustodyName, a.ProdId, c.CustodyId, a.TranCCY

        If @@error!= 0
        Begin
            set @nOK = 1
            goto NEXT
        End

        Update a
        set BillId = c.BillId
        from ReksaTransaction_TT a join ReksaProduct_TM b
                on a.ProdId = b.ProdId
            join ReksaBill_TM c
                on a.ProdId = c.ProdId
                    and b.CustodyId = c.CustodyId
                    and a.TranCCY = c.BillCCY
        where  a.TranType in (3,4)
            and a.Status = 1
            and b.CloseEndBit = 1
            and b.ProdId = @nProdId
            and isnull(a.BillId, 0) = 0
--20071218, indra_w, REKSADN002, begin
            and c.BillType = 5
            and a.NAVValueDate = @dCurrWorkingDate

        If @@error!= 0
        Begin
            set @nOK = 1
            goto NEXT
        End

        update ReksaBill_TM
        set BillType = 2
        where BillType = 5
            and ProdId = @nProdId
            and ValueDate = @dNextWorkingDate
--20071218, indra_w, REKSADN002, end
        If @@error!= 0
        Begin
            set @nOK = 1
            goto NEXT
        End
--20071210, indra_w, REKSADN002, end
    commit tran

    continue
    NEXT:
        if @@trancount > 0
            rollback tran
end


close prod_cur
deallocate prod_cur

If @nOK = 1 
Begin
    Set @cErrMsg = 'Error Process Data'
    Goto ERROR
End

--20071210, indra_w, REKSADN002, begin
---- buat Bill
--Begin Tran
--  
--Commit tran
--20071210, indra_w, REKSADN002, end

exec @nOK = set_process_table @@procid, null, @nUserSuid, 0  
if @nOK != 0 or @@error != 0 return 1

return 0

ERROR:
If @@trancount > 0 
    rollback tran

if isnull(@cErrMsg ,'') = ''
    set @cErrMsg = 'Unknown Error !'

exec @nOK = set_process_table @@procid, null, @nUserSuid, 2  
if @nOK != 0 or @@error != 0 return 1

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror (@cErrMsg ,16,1);
return 1
GO