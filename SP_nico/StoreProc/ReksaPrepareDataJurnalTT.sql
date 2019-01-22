CREATE proc [dbo].[ReksaPrepareDataJurnalTT]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120925
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20130515, liliana, ODKIB12036, perbaikan
		20130611, liliana, ODKIB12036, tambah pengecekan jika tanggal = holiday currency, tgl valuta dimajukan
		20130614, liliana, ODKIB12036, tambahan notifikasi
		20131018, dhanan, LOGAM05676, perbaikan utk valas 7092
	END REVISED

*/
@pnNIK					int,
@pnTranBranch			int,
@pnBillId				int,
@pcJenisJurnal			varchar(10)   -- PB /TT
--20130614, liliana, ODKIB12036, begin
, @pbIsCurrencyHoliday		varchar(1) = '' output
, @pdNewValueDate			datetime = null output
--20130614, liliana, ODKIB12036, end
as
set nocount on
declare
	@nErrNo					int
	,@nOK					int 
	,@cErrMsg				varchar(100)
	,@cPOGNC				varchar(20)
	,@cBillCCY				varchar(3) 
	,@nProcId				int
	,@mTTBuy				money
	,@mTTSell				money	
	,@mBNBuy				money
	,@mBNSell				money	
	,@dCurrentDate			datetime
	,@cCurrentDate			varchar(10)
	,@cCurrDateYYYYMMDD		varchar(8)
	,@cCurrDateDDMM			varchar(4)
	,@cPOOfficeId			varchar(5)
	,@cTrxTTOfficeId		varchar(5)
	,@cValueDate			varchar(8)
	
set @cCurrDateYYYYMMDD = convert(varchar(8), getdate(), 112)
set @cCurrDateDDMM = substring(@cCurrDateYYYYMMDD,7,2) + substring(@cCurrDateYYYYMMDD,5,2)		

--20130611, liliana, ODKIB12036, begin		
select @dCurrentDate = [current_working_date]
from dbo.control_table
--20130611, liliana, ODKIB12036, end
--20130611, liliana, ODKIB12036, begin
select @cBillCCY = Currency 
from dbo.ReksaTTOutgoing_TT
where BillId = @pnBillId

while (exists(select top 1 1 from dbo.SWPAR4_v where SHCURR = @cBillCCY
	and SHDAT8 = convert(varchar,@dCurrentDate,112))
	)
Begin
	set @dCurrentDate = dateadd(dd, 1, @dCurrentDate)
--20130614, liliana, ODKIB12036, begin
    set @pbIsCurrencyHoliday = 'Y'
--20130614, liliana, ODKIB12036, end	
end
 
--20130611, liliana, ODKIB12036, end
--20130614, liliana, ODKIB12036, begin
set @pdNewValueDate = @dCurrentDate
--20130614, liliana, ODKIB12036, end
	
set @cCurrentDate = convert(int, replace(convert(varchar(8),convert(datetime, @dCurrentDate), 4),'.',''))

set @cValueDate = convert(varchar,@dCurrentDate,112)

----------------------------------------------------------------------------------------------------
	
--20130611, liliana, ODKIB12036, begin
--select @cBillCCY = Currency 
--from dbo.ReksaTTOutgoing_TT
--where BillId = @pnBillId
--20130611, liliana, ODKIB12036, end

set @nProcId = @@procid

exec @nOK = set_gl_number @nProcId, 'ReksaTTPerantara', @cPOGNC output, @cBillCCY

if @nOK != 0 or isnull(@cPOGNC, '') = ''
Begin
	set @cErrMsg = 'Gagal ambil GNC TT Perantara!' 
	goto ERROR
end

select @cPOOfficeId = office_id_sibs
from office_information_all_v
where office_id = '965'

if @nOK != 0 or isnull(@cPOOfficeId, '') = ''
Begin
	set @cErrMsg = 'Gagal ambil PO Office Id!' 
	goto ERROR
end

select @cTrxTTOfficeId = OfficeTT
from dbo.control_table

if @nOK != 0 or isnull(@cTrxTTOfficeId, '') = ''
Begin
	set @cErrMsg = 'Gagal ambil GL TT Office Id!' 
	goto ERROR
end


select @mTTBuy = TTBuyingRate, @mTTSell = TTSellingRate,
	   @mBNBuy = BNBuyingRate, @mBNSell = BNSellingRate
from SIBSCurrencyTable_TM_v
where PBOId = '500'
	and CurrencyCode = @cBillCCY

if @@error!=0 or isnull(@mTTSell, 0) = 0
Begin
	set @cErrMsg = 'Gagal ambil Rate TT Sell!' 
	goto ERROR
end

if(@pcJenisJurnal = 'PB')
begin

		select TTGuid, BillId, rtl.ProdId, DebittingAccountFee as DebittingAccount, 'IDR' as DebittingCurrency,
			@cPOGNC as CredittingAccount, @cBillCCY as CredittingCurrency,	
			FullAmountFee *	@mTTSell as DebittingAmount, FullAmountFee as CredittingAmount,		 
			@cTrxTTOfficeId as BranchCodeDebitting, @cPOOfficeId as BranchCodeCrediting,
--20131018, dhanan, LOGAM05676, begin			
			--@mTTBuy as TTBuy, @mTTSell as TTSell, @mBNBuy as BNBuy, @mBNSell as BNSell, 
			1 as TTBuy, @mTTSell as TTSell, 1 as BNBuy, @mBNSell as BNSell, 
--20131018, dhanan, LOGAM05676, end			
			'TT Perantara '+ rp.ProdCode + '/' + convert(varchar,getdate(),112) as Remark1,
			@cCurrentDate as EffectiveDate, ProcessStatusFee as StatusJurnal
		from dbo.ReksaTTOrderingLog_TM rtl
			join dbo.ReksaProduct_TM rp
				on rtl.ProdId = rp.ProdId
		where BillId = @pnBillId

end
else if(@pcJenisJurnal = 'TT')
begin
		select TTGuid, BillId, ProdId, ApplicantName, BankRef, BeneAcctNo, BeneAddr1, BeneAddr2, BeneAddr3,
			BeneBankAddr1, BeneBankAddr2, BeneBankAddr3, BeneBankName, BeneBankSwiftId,	BeneficiaryAffiliationStatus, BeneficiaryCategory,
			BeneficiaryCountryOfResidentCode, BeneficiaryName, @mBNBuy as BNBuy, @mBNSell as BNSell, Branch, CIFNumber, ClientRef, DealNumber,	DebitAccountCcy,
			DebittingAcctNo, DebittingAmountWithoutFee, DetailsOfCharges, FullAmountFee, IntBankAddr1, IntBankAddr2, IntBankAddr3,
			IntBankName, IntBankSwiftId, NostroBICCode,	NostroFee, OrderingCustAddr1, OrderingCustAddr2, OrderingCustAddr3,	PayDetail1,
			PayDetail2,	PayDetail3, PayDetail4,	PaymentPurpose,	ProvFee, RemitterCategory, RemitterCountryOfResidentCode, RemittingAmt,	
			RemittingCcy, Resident,	SenderRecvInfo1, SenderRecvInfo2, SenderRecvInfo3, SenderRecvInfo4,	SenderRecvInfo5, SenderRecvInfo6,
			TaxFee,	TransferFee, @mTTBuy as TTBuy, @mTTSell as TTSell,	@cValueDate as ValueDate, @cPOGNC as DebittingAccountFee, FeeCurrencyCode,
			ProcessStatusTT as StatusJurnal
		from dbo.ReksaTTOrderingLog_TM 
		where BillId = @pnBillId
end
	
return 0

ERROR:  
If @@trancount > 0   
 rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Unknown Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1);
return 1
GO