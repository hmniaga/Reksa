CREATE proc [dbo].[ReksaPopulateVerifyLimitFeeIBMB]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20130404
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
    20131106, liliana, BAALN11010, tambah kolom dan effective date
	20181119, Lita, BOSITXXXXX, add RDB
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyLimitFeeIBMB null  
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
--20131106, liliana, BAALN11010, begin
    ,@dToday                        datetime
    ,@dLastBatchID                  int
    ,@dBatchInsertDate              datetime
    ,@pdEffectiveDate               datetime

set @dToday = getdate()

select @dLastBatchID = max(BatchID)
from dbo.EBWUnitTrustProductInfo_TMP

select @dBatchInsertDate = InsertDate
from dbo.EBWUnitTrustProductInfo_TMP
where BatchID = @dLastBatchID

if(convert(varchar,@dBatchInsertDate,112) = convert(varchar,@dToday,112))
begin
    set @pdEffectiveDate = convert(varchar,dateadd(dd,1,@dToday),106)
end
else
begin
    set @pdEffectiveDate = convert(varchar,@dToday,106)
end
--20131106, liliana, BAALN11010, end
  
set @bCheck = 0  
  
select @bCheck as CheckB,
    rf.Id, 
    case when rf.ProcessType = 'A' then 'Add'
         when rf.ProcessType = 'U' then 'Update'
         when rf.ProcessType = 'D' then 'Delete'
    else rf.ProcessType end as ActionType,
    rp.ProdCode as KodeProduk,
    rp.ProdName as NamaProduk,
    rp.ProdCCY as MataUang,
    rt.TypeName as TypeReksadana,
    case when rf.IsVisibleIBMB = 1 then 'Yes'
         else 'No' end as TampilDiInfoDetailProdukIBMB, 
    case when rf.CanSubsNew = 1 then 'Yes'
         else 'No' end as DapatTrxSubsNewIBMB,
    case when rf.CanTrxIBank = 1 then 'Yes'
         else 'No' end as DapatTrxInternetBanking,
    case when rf.CanTrxMBank = 1 then 'Yes'
         else 'No' end as DapatTrxMobileBanking,
    convert(varchar(40),cast(rf.MinSubsNew as money),1) as MinSubscriptionNew,
    convert(varchar(40),cast(rf.MinSubsAdd as money),1) as MinSubscriptionAdd,
    convert(varchar(40),cast(rf.MinRedemption as money),1) as MinRedemption,
--20131106, liliana, BAALN11010, begin
    case when isnull(rf.MinRedemptionByUnit,0) = 0 then 'nominal' else 'unit' end as MinRedemptionBy,
--20131106, liliana, BAALN11010, end    
    convert(varchar(40),cast(rf.MinSwitching as money),1) as MinSwitching,
--20131106, liliana, BAALN11010, begin
    case when isnull(rf.MinSwitchingByUnit,0) = 0 then 'nominal' else 'unit' end as MinSwitchingBy,
--20131106, liliana, BAALN11010, end    
    convert(varchar(40),cast(rf.PctFeeSubs as money),2) as PercentageFeeSubscription,
    convert(varchar(40),cast(rf.PctFeeRedemp as money),2) as PercentageFeeRedemption,
    convert(varchar(40),cast(rf.PctFeeSwitching as money),2) as PercentageFeeSwitching,
    convert(varchar(40),cast(rf.PctHoldAmount as money),2) as PercentageHoldAmount,
--20181119, Lita, BOSITXXXXX, begin
	case when rf.CanTrxRDB = 1 then 'Yes' else 'No' end as DapatTrxRDB,
	convert(varchar(40),cast(rf.RDBMinSubs as money),1) as RDBMinSubs, 
	convert(varchar(40),cast(rf.RDBPctFeeSubsNoIns as money),1) as RDBPercentageFeeSubsNoIns,
	convert(varchar(40),cast(rf.RDBPctFeeSubsWithIns as money),1) as RDBPercentageFeeSubsWithIns,
	convert(varchar(40),cast(rf.RDBPctFeeRedempNoIns as money),1) as RDBPercentageFeeRedemptionNoIns,
	convert(varchar(40),cast(rf.RDBPctFeeRedempWithIns as money),1) as RDBPercentageFeeRedemptionWithIns,
--20181119, Lita, BOSITXXXXX, end
    rf.Inputter, 
    us.fullname as UserInputName,
    rf.DateInput
--20131106, liliana, BAALN11010, begin
    , @pdEffectiveDate as EffectiveDate
--20131106, liliana, BAALN11010, end    
from dbo.ReksaProductIBMB_TT rf
    join dbo.ReksaProduct_TM rp
        on rp.ProdId = rf.ProdId
    join dbo.ReksaType_TR rt
        on rt.TypeId = rp.TypeId
    join dbo.user_nisp_v us
        on us.nik = rf.Inputter
where rf.StatusOtor = 0

  
return 0
GO