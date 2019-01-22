CREATE proc [dbo].[ReksaMaintainOutgoingTT]
/*
	CREATED BY    : 
	CREATION DATE : 
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED

*/
@pnNIK					int,
@pnBillId				int,
@pbIsProcess			bit,
@pcAlasanDelete			varchar(100)
, @pbIsCurrencyHoliday		varchar(1) = '' output
, @pdNewValueDate			datetime = null output
as
set nocount on
declare
	@nErrNo				int
	,@nOK				int 
	,@cErrMsg			varchar(100)
	,@dFeeFullAmt		decimal(25,13)
	,@cFeeCurr			char(3)
	,@cCIFGNC			varchar(20)
	,@cNoRekProduk		varchar(20)
	,@cBICCode				varchar(20)
	,@cBillCCY			varchar(3)
	,@dCurrentDate		datetime

select @cBillCCY = Currency 
from dbo.ReksaTTOutgoing_TT
where BillId = @pnBillId	

select @dCurrentDate = [current_working_date]
from dbo.control_table
	
if(@pbIsProcess = 0) -- delete 
begin
	update dbo.ReksaTTOutgoing_TT
	set TranStatus = 4,
		UserProcess = @pnNIK,
		DateProcess = getdate(),
		AlasanDelete = @pcAlasanDelete
	where BillId = @pnBillId
end
else if(@pbIsProcess = 1) --proses
begin
	set @cBICCode = 'NISPIDJAXXX'
	
	select @cFeeCurr = Currency
	from dbo.ReksaTTOutgoing_TT
	where BillId = @pnBillId
	
	if not exists(select top 1 1 from dbo.ReksaTTFullAmountFee_TR where Currency = @cFeeCurr)
	begin
		set @cErrMsg = 'Fee Full Amount untuk currency '+@cFeeCurr+' belum diset!' 
		goto ERROR	
	end
	else
	begin
		select @dFeeFullAmt = FeeFullAmount, @cBICCode = BICCode
		from dbo.ReksaTTFullAmountFee_TR
		where Currency = @cFeeCurr
	end
	
	select @cNoRekProduk = NoRekProduk
	from dbo.ReksaTTOutgoing_TT 
	where BillId = @pnBillId
	
	select @cCIFGNC = CIFNO
	from dbo.DDMAST
	where ACCTNO =  @cNoRekProduk

	delete dbo.ReksaTTOrderingLog_TM
	where BillId = @pnBillId
	while (exists(select top 1 1 from dbo.SWPAR4_v where SHCURR = @cBillCCY
		and SHDAT8 = convert(varchar,@dCurrentDate,112))
		)
	Begin
		set @dCurrentDate = dateadd(dd, 1, @dCurrentDate)
		set @pbIsCurrencyHoliday = 'Y'
	end
	
	set @pdNewValueDate = @dCurrentDate
	 
	--insert TT ORDERING
	insert dbo.ReksaTTOrderingLog_TM(TTGuid, BillId, ProdId, ApplicantName, BankRef, BeneAcctNo, BeneAddr1, BeneAddr2, BeneAddr3,
	BeneBankAddr1, BeneBankAddr2, BeneBankAddr3, BeneBankName, BeneBankSwiftId,	BeneficiaryAffiliationStatus, BeneficiaryCategory,
	BeneficiaryCountryOfResidentCode, BeneficiaryName, BNBuy, BNSell, Branch, CIFNumber, ClientRef, DealNumber,	DebitAccountCcy,
	DebittingAcctNo, DebittingAmountWithoutFee, DetailsOfCharges, FullAmountFee, IntBankAddr1, IntBankAddr2, IntBankAddr3,
	IntBankName, IntBankSwiftId, NostroBICCode,	NostroFee, OrderingCustAddr1, OrderingCustAddr2, OrderingCustAddr3,	PayDetail1,
	PayDetail2,	PayDetail3, PayDetail4,	PaymentPurpose,	ProvFee, RemitterCategory, RemitterCountryOfResidentCode, RemittingAmt,	
	RemittingCcy, Resident,	SenderRecvInfo1, SenderRecvInfo2, SenderRecvInfo3, SenderRecvInfo4,	SenderRecvInfo5, SenderRecvInfo6,
	TaxFee,	TransferFee, TTBuy,	TTSell,	ValueDate, DebittingAccountFee, FeeCurrencyCode, 
	ProcessStatusFee, ErrorDescriptionFee, ProcessStatusTT,	ErrorDescriptionTT,						
	RemittanceNumber, SubmitDate, UserSubmitter, AuthDate,	UserAuth, LastRun
	)
	select rt.TranGuid, rt.BillId, rt.ProdId, rt.NamaPemohon, 28, rt.BeneficiaryAccNo, rc.AlamatPenerima1, rc.AlamatPenerima2, rc.AlamatPenerima3,
		rc.BeneficiaryBankAddress, '', '', rc.BeneficiaryBankName, rt.BeneficiaryBankCode, '', '', 
		'', rt.NamaPenerima, null, null, null, @cCIFGNC, rt.BillId, null, rt.Currency,
		rt.NoRekProduk, rt.NominalTransfer, 'F', @dFeeFullAmt, null, null,null,
		null, null, @cBICCode, 0, rc.AlamatPemohon1, rc.AlamatPemohon2, '', rc.PaymentRemarks1,
		rc.PaymentRemarks2, '', '', '', 0, '', '', rt.NominalTransfer,
		rt.Currency, '', '', '', '', '', '', '',
		0, 0, null, null, @dCurrentDate, rt.GLBiayaFullAmt, @cFeeCurr,
		0, null, 0, null,
		null, getdate(), @pnNIK, null, null, getdate()
	from dbo.ReksaTTOutgoing_TT rt
		join dbo.ReksaTTCompletion_TM rc
			on rc.ProdId = rt.ProdId
	where rt.BillId = @pnBillId
	
	If @@error != 0
	Begin
		set @cErrMsg = 'Error Create TT ORDERING!' 
		goto ERROR
	End	

	update dbo.ReksaTTOutgoing_TT
	set TranStatus = 3,
		UserProcess = @pnNIK,
		DateProcess = getdate()
	where BillId = @pnBillId
	
end
	
return 0

ERROR:  
If @@trancount > 0   
 rollback tran  
  
if isnull(@cErrMsg ,'') = ''  
 set @cErrMsg = 'Unknown Error !'  
  
exec @nOK = set_raiserror @@procid, @nErrNo output    
if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1);
return 1
GO