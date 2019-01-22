CREATE proc [dbo].[ReksaMaintainProduct]
/*
	CREATED BY    : indra
	CREATION DATE : 
	DESCRIPTION   : insert / update / delete dbo.ReksaProduct_TM
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

exec ReksaMaintainProduct 
	@pnType					= 1
	,@pnProdId				= 11
	,@pcProdCode			= 'ABS'
	,@pcProdName			= 'ABU BAKAR2'
	,@pcProdCCY				= 'IDR'
	,@pnTypeId				= 1
	,@pnManInvId			= 1
	,@pnCustodyId			= 1
	,@pmNAV					= 3
	,@pmMinTotalUnit		= 0
	,@pmMaxTotalUnit		= 0
	,@pmMaxDailyUnit		= 1
	,@pnMaxDailyCust		= 3
	,@pdPeriodStart			= '20071024'
	,@pdPeriodEnd			= '20071024'
	,@pdMatureDate			= '20071024'
	,@pdChangeDate			= '20071025'
	,@pdValueDate			= '20071026'
	,@pnCloseEndBit			= 1
	,@pbIsDeviden			= 0
	,@pnDevidenPeriod		= 0
	,@pdDevidenDate			= '20071026'
	,@pnCalcId				= 1
	,@pxmlNEmployeeSFee		= '<ROOT><RS></RS></ROOT>'
	,@pxmlEmployeeSFee		= '<ROOT><RS></RS></ROOT>'
	,@pmUpFrontFee			= 0
	,@pmSubcFeeBased		= 4
	,@pmRedempFeeBased		= 5
	,@pmMaintenanceFee		= 6
	,@pxmlNEmployeeRFee		= '<ROOT><RS></RS></ROOT>'
	,@pxmlEmployeeRFee		= ''
	,@pcMIAccountId			= '123456'
	,@pcCTDAccountId		= '123456'
	,@pnNIK					= 10060
	,@pcGuid				= ''



	END REVISED
*/
	@pnType					tinyint		-- 1: new; 2: update; 3: delete
	,@pnProdId				int			= NULL
	,@pcProdCode			varchar(10) = null output
	,@pcProdName			varchar(40)
	,@pcProdCCY				char(3)
	,@pnTypeId				int
	,@pnManInvId			int
	,@pnCustodyId			int
	,@pmNAV					decimal(25,13)
	,@pmMinTotalUnit		decimal(25,13)
	,@pmMaxTotalUnit		decimal(25,13)
	,@pmMaxDailyUnit		decimal(25,13)
	,@pnMaxDailyCust		decimal(25,13)
	,@pdPeriodStart			datetime
	,@pdPeriodEnd			datetime
	,@pdMatureDate			datetime
	,@pdChangeDate			datetime
	,@pdValueDate			datetime
	,@pnCloseEndBit			tinyint
	,@pbIsDeviden			bit
	,@pnDevidenPeriod		tinyint
	,@pdDevidenDate			datetime
	,@pnCalcId				int
	,@pxmlNEmployeeSFee		varchar(4000)
	,@pxmlEmployeeSFee		varchar(4000)
	,@pmUpFrontFee			decimal(25,13)
	,@pmSubcFeeBased		decimal(25,13)
	,@pmRedempFeeBased		decimal(25,13)
	,@pmMaintenanceFee		decimal(25,13)
	,@pxmlNEmployeeRFee		varchar(4000)
	,@pxmlEmployeeRFee		varchar(4000)
	,@pcMIAccountId			varchar(19)
	,@pcCTDAccountId		varchar(19)
	,@pnNIK					int
	,@pcGuid				varchar(50)
	,@pxmlMaintenanceFee	varchar(4000)
	,@pnDevidentPct			float
	,@pnEffectiveAfter		int
as

set nocount on

declare @cErrMsg			varchar(100)
		, @nOK				int
		, @nErrNo			int
		, @nFeeId			int
		, @ndoc				int
		, @nManInvId		int
		, @nCustodyId		int
		, @nTypeId			int
		, @dCurrWorkingDate	datetime
		, @nAUMMin		money
		, @nAUMMax		money
		, @nNispPct		float
		, @nFundMgrPct	float
		, @nOldEffectiveAfter int
		, @bNeedOtor	bit
		, @nMaintFee	float

set @bNeedOtor = 0
--pindahan dari bawah
select @dCurrWorkingDate = current_working_date
from control_table
If @pnType not in (1,2,3) 
	set @cErrMsg = 'Kode Tipe Tidak Dikenal!'
else if @pnType in (2,3) and isnull(@pnProdId,0) = 0
	set @cErrMsg = 'Kode Product Tidak Dikenal!'
else if isnull(@pcProdCode,'') = '' and @pnType in (1,2) 
	set @cErrMsg = 'Kode Product Harus Diisi!'
else if @pnType = 3 
		and exists (select top 1 1 from ReksaTransaction_TT where ProdId = @pnProdId)
	set @cErrMsg = 'Tidak Bisa dihapus karena sudah ada transaksi!'
else If @pnType in (1,2) and isnull(@pxmlNEmployeeRFee,'') = ''
	set @cErrMsg = 'Parameter Fee harus Diisi!'
else if isnull(@pnDevidentPct, 0) > 100.0
	set @cErrMsg = 'Persentase deviden tidak boleh > 100%'
else if @pnCloseEndBit = 1 and @pnEffectiveAfter <= 0
	set @cErrMsg = 'Produk Close End harus mengisi H+x Efektif setelah tgl penawaran akhir'
else if @pdPeriodEnd < @dCurrWorkingDate and @pnType = 2 and (select Status from ReksaProduct_TM where ProdId = @pnProdId) = 0
	set @cErrMsg = 'Tgl akhir penawaran harus >= tgl hari ini'
if isnull(@cErrMsg,'') != ''
	goto ERROR
declare @TempNEmployeeSFee table(
	Fee			decimal(25,13)
	,Nominal	decimal(25,13)
)

declare @TempEmployeeSFee table(
	Fee			decimal(25,13)
	,Nominal	decimal(25,13)
)

declare @TempNEmployeeFee table(
	Fee			decimal(25,13)
	,Period		int
	,Nominal	decimal(25,13)
)

declare @TempEmployeeFee table(
	Fee			decimal(25,13)
	,Period		int
	,Nominal	decimal(25,13)
)
declare @TempMaintenanceFee table (
	AUMMin                          money               ,
	AUMMax                          money               ,
	NispPct                         float               ,
	FundMgrPct                      float              
	, MaintFee						float	 
)

If @pnType in (2,3)
Begin
	select @nFeeId = FeeId
	from ReksaProduct_TM
	where ProdId = @pnProdId
end

if @pnType in (1,2)
Begin
	-- isi table yang berisi Subc Fee non Karyawan
	exec @nOK = sp_xml_preparedocument @ndoc output, @pxmlNEmployeeSFee

	if @nOK!=0 or @@error != 0
	begin
		set @cErrMsg='Gagal prepare document xml Non Employee Subc Fee'
		goto ERROR
	end

	insert @TempNEmployeeSFee(Fee,Nominal)
	SELECT Fee, Nominal
	FROM openxml(@ndoc,'/ROOT/RS',1)
--			,Nominal money)
	WITH (Fee	decimal(25,13)
			,Nominal decimal(25,13))

	exec sp_xml_removedocument @ndoc

	-- isi table yang berisi Subc fee karyawan
	exec @nOK = sp_xml_preparedocument @ndoc output, @pxmlEmployeeSFee

	if @nOK!=0 or @@error != 0
	begin
		set @cErrMsg='Gagal prepare document xml Non Employee Subc Fee'
		goto ERROR
	end

	insert @TempEmployeeSFee(Fee, Nominal)
	SELECT Fee,  Nominal
	FROM openxml(@ndoc,'/ROOT/RS',1)
	WITH (Fee	decimal(25,13)
			,Nominal decimal(25,13))

	exec sp_xml_removedocument @ndoc
----------------------------------

	-- isi table yang berisi Fee non Karyawan
	exec @nOK = sp_xml_preparedocument @ndoc output, @pxmlNEmployeeRFee

	if @nOK!=0 or @@error != 0
	begin
		set @cErrMsg='Gagal prepare document xml Non Employee Fee'
		goto ERROR
	end

	insert @TempNEmployeeFee(Fee,Period,Nominal)
	SELECT Fee, Period,Nominal
	FROM openxml(@ndoc,'/ROOT/RS',1)
	WITH (Fee	decimal(25,13)
			,Period int
			,Nominal decimal(25,13))
	exec sp_xml_removedocument @ndoc

	-- isi table yang berisi fee karyawan
	exec @nOK = sp_xml_preparedocument @ndoc output, @pxmlEmployeeRFee

	if @nOK!=0 or @@error != 0
	begin
		set @cErrMsg='Gagal prepare document xml Non Employee Fee'
		goto ERROR
	end

	insert @TempEmployeeFee(Fee,Period,Nominal)
	SELECT Fee, Period, Nominal
	FROM openxml(@ndoc,'/ROOT/RS',1)
	WITH (Fee	decimal(25,13)
			,Period int
			,Nominal decimal(25,13))

	exec sp_xml_removedocument @ndoc

	--tabel maintenance fee AUM
	exec @nOK = sp_xml_preparedocument @ndoc output, @pxmlMaintenanceFee

	if @nOK!=0 or @@error != 0
	begin
		set @cErrMsg='Gagal prepare document xml Maintenance Fee AUM'
		goto ERROR
	end

	insert @TempMaintenanceFee(AUMMin, AUMMax, NispPct, FundMgrPct, MaintFee)
	SELECT AUMMin, AUMMax, NispPct, FundMgrPct, MaintFee
	FROM openxml(@ndoc,'/ROOT/RS',1)
	WITH (
		AUMMin		money,
		AUMMax		money,
		NispPct		float,
		FundMgrPct	float
		, MaintFee	float
	)

	exec sp_xml_removedocument @ndoc
	
	if exists (select top 1 1 from @TempMaintenanceFee)
	begin
		declare fee_csr cursor for
		select AUMMin, AUMMax, NispPct, FundMgrPct
			, MaintFee
		from @TempMaintenanceFee
		
		open fee_csr
		while 1=1
		begin
			fetch fee_csr into @nAUMMin, @nAUMMax, @nNispPct, @nFundMgrPct
				, @nMaintFee
			if @@fetch_status <> 0 break
			
			if @nAUMMin > @nAUMMax
			begin
				set @cErrMsg = 'Nilai AUM Min harus < AUM Maks'
				close fee_csr
				deallocate fee_csr
				goto ERROR
			end
			
			if @nNispPct + @nFundMgrPct <> 100.0
			begin
				set @cErrMsg = 'Total pembagian maintenance fee harus 100%'
				close fee_csr
				deallocate fee_csr
				goto ERROR			
			end
			set @nMaintFee = isnull(@nMaintFee, 0.0)
		end
		close fee_csr
		deallocate fee_csr
	end
End

If @pnType = 1 -- new
Begin
	Begin Transaction

		Insert ReksaProductFee_TR(SubcFeeBased, RedempFeeBased, MaintenanceFee, UpFrontFee)
		select @pmSubcFeeBased, @pmRedempFeeBased, @pmMaintenanceFee, @pmUpFrontFee

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee'
			goto ERROR
		End

		select @nFeeId = scope_identity()

		-- Subc Fee Non Karyawan 
		insert ReksaSubcPeriod_TM(FeeId, IsEmployee, Fee, Nominal)
		select @nFeeId, 0, Fee, Nominal
		from @TempNEmployeeSFee
		order by Nominal

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Subc Fee Non Karyawan'
			goto ERROR
		End

		-- Subc Fee Karyawan
		insert ReksaSubcPeriod_TM(FeeId, IsEmployee, Fee, Nominal)
		select @nFeeId, 1, Fee, Nominal
		from @TempEmployeeSFee
		order by Nominal

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Subc Fee Karyawan'
			goto ERROR
		End

		-- Redemp Fee Non Karyawan 
		insert ReksaRedemPeriod_TM(FeeId, IsEmployee, Fee, Period, Nominal)
		select @nFeeId, 0, Fee, Period, Nominal
		from @TempNEmployeeFee
		order by Period

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee Non Karyawan'
			goto ERROR
		End

		-- Redemp Fee Karyawan
		insert ReksaRedemPeriod_TM(FeeId, IsEmployee, Fee, Period, Nominal)
		select @nFeeId, 1, Fee, Period, Nominal
		from @TempEmployeeFee
		order by Period

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee Karyawan'
			goto ERROR
		End

		Insert ReksaProduct_TM(ProdCode, ProdName, ProdCCY, TypeId, ManInvId, CustodyId, NAV
			, MinTotalUnit, MaxTotalUnit, MaxDailyUnit, MaxDailyNom, MaxDailyCust, PeriodStart
			, PeriodEnd, MatureDate, ChangeDate, ValueDate, CloseEndBit, IsDeviden
			,DevidenPeriod, DevidenDate, CalcId, FeeId, MIAccountId, CTDAccountId, DevidentPct
			,EffectiveAfter)
		select @pcProdCode, @pcProdName, @pcProdCCY, @pnTypeId, @pnManInvId, @pnCustodyId, @pmNAV
			, @pmMinTotalUnit, @pmMaxTotalUnit, @pmMaxDailyUnit, dbo.fnReksaSetRounding(@pnProdId,3,@pmMaxDailyUnit * @pmNAV), @pnMaxDailyCust, @pdPeriodStart
			, @pdPeriodEnd, @pdMatureDate, @pdChangeDate, @pdValueDate, @pnCloseEndBit, @pbIsDeviden
			, @pnDevidenPeriod, @pdDevidenDate, @pnCalcId, @nFeeId, @pcMIAccountId, @pcCTDAccountId
			, @pnDevidentPct, @pnEffectiveAfter

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Data Product'
			goto ERROR
		End

		set @pnProdId = scope_identity()

		insert ReksaClientCounter_TR (ProdId, Counter, Booking, Trans)
		select @pnProdId, 0, 0, 0

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Table Counter'
			goto ERROR
		End

		-- insert ke table param efektif jika tanggal efektif perubahan = hari ini
		if @pdValueDate = @dCurrWorkingDate
		Begin
			insert ReksaProductParam_TM (ProdId, TypeId, ManInvId, CustodyId, NAV, MinTotalUnit, MaxTotalUnit
				, MaxDailyUnit, MaxDailyNom, MaxDailyCust, PeriodStart, PeriodEnd, MatureDate, ChangeDate
				, ValueDate, CloseEndBit, IsDeviden, DevidenPeriod, FeeId, DevidentPct
				, EffectiveAfter)
			select ProdId, TypeId, ManInvId, CustodyId, NAV, MinTotalUnit, MaxTotalUnit
				, MaxDailyUnit, MaxDailyNom, MaxDailyCust, PeriodStart, PeriodEnd, MatureDate, ChangeDate
				, ValueDate, CloseEndBit, IsDeviden, DevidenPeriod, FeeId
				, DevidentPct, EffectiveAfter
			from ReksaProduct_TM
			where ProdId = @pnProdId

			if @@error != 0
			Begin
				set @cErrMsg='Gagal Insert Param Efektif'
				goto ERROR
			End

			Update ReksaProduct_TM
			set ParamId = scope_identity()
			where ProdId = @pnProdId

			if @@error != 0
			Begin
				set @cErrMsg='Gagal Update Param Efektif'
				goto ERROR
			End
		End
--20090723, oscar, REKSADN013, begin
		--parameter maintenance fee by AUM
		--insert into ReksaProductMaintenanceFee_TR (ProdId, AUMMin, AUMMax, NispPct, FundMgrPct)
		insert into ReksaProductMaintenanceFee_TR (ProdId, AUMMin, AUMMax, NispPct, FundMgrPct, MaintFee)
		select @pnProdId, AUMMin, AUMMax, NispPct, FundMgrPct
			, MaintFee
		from @TempMaintenanceFee	
		
		if @@error!=0
		begin
			set @cErrMsg = 'Error Insert Maintenance Fee AUM'
			goto ERROR
		end			
	commit tran
End
else if @pnType = 2 -- update
Begin
	Begin Transaction
		Insert ReksaProductFee_TR( SubcFeeBased, RedempFeeBased, MaintenanceFee, UpFrontFee)
		select @pmSubcFeeBased, @pmRedempFeeBased, @pmMaintenanceFee, @pmUpFrontFee

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee (2)'
			goto ERROR
		End

		select @nFeeId = scope_identity()

		-- Subc Fee Non Karyawan 
		insert ReksaSubcPeriod_TM(FeeId, IsEmployee, Fee, Nominal)
		select @nFeeId, 0, Fee, Nominal
		from @TempNEmployeeSFee
		order by Nominal

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Subc Fee Non Karyawan'
			goto ERROR
		End

		-- Subc Fee Karyawan
		insert ReksaSubcPeriod_TM(FeeId, IsEmployee, Fee, Nominal)
		select @nFeeId, 1, Fee, Nominal
		from @TempEmployeeSFee
		order by Nominal

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Subc Fee Karyawan'
			goto ERROR
		End

		-- Redemp Fee Non Karyawan
		insert ReksaRedemPeriod_TM(FeeId, IsEmployee, Fee, Period, Nominal)
		select @nFeeId, 0, Fee, Period, Nominal
		from @TempNEmployeeFee
		order by Period

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee Non Karyawan (2)'
			goto ERROR
		End

		-- Redemp Fee Karyawan
		insert ReksaRedemPeriod_TM(FeeId, IsEmployee, Fee, Period, Nominal)
		select @nFeeId, 1, Fee, Period, Nominal
		from @TempEmployeeFee
		order by Period

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Insert Fee Karyawan (2)'
			goto ERROR
		End

		--cek perubahan H+x efektif
		select @nOldEffectiveAfter = isnull(EffectiveAfter, 0)
		from ReksaProduct_TM where ProdId = @pnProdId
		
		--if @nOldEffectiveAfter <> @pnEffectiveAfter set @bNeedOtor = 1
		-- perubahan H+x efektif hanya untuk status = 1
		if ((@nOldEffectiveAfter <> @pnEffectiveAfter) and ((select Status from ReksaProduct_TM where ProdId = @pnProdId and CloseEndBit = 1) <> 0)) 
		begin
			set @cErrMsg = 'Perubahan H+x Efektif hanya untuk produk status BELUM AKTIF'
			goto ERROR
		end
		--set @bNeedOtor = 1

		Update ReksaProduct_TM
		set ProdCode		= @pcProdCode
			, ProdName		= @pcProdName
			, ProdCCY		= @pcProdCCY
			, TypeId		= @pnTypeId
			, ManInvId		= @pnManInvId
			, CustodyId		= @pnCustodyId
			, NAV			= @pmNAV
			, MinTotalUnit	= @pmMinTotalUnit
			, MaxTotalUnit	= @pmMaxTotalUnit
			, MaxDailyUnit	= @pmMaxDailyUnit
			, MaxDailyNom	= dbo.fnReksaSetRounding(@pnProdId,3,@pmMaxDailyUnit * @pmNAV)
			, MaxDailyCust	= @pnMaxDailyCust
			, PeriodStart	= @pdPeriodStart
			, PeriodEnd		= @pdPeriodEnd
			, MatureDate	= @pdMatureDate
			, ChangeDate	= @pdChangeDate
			, ValueDate		= @pdValueDate
			, CloseEndBit	= @pnCloseEndBit
			, IsDeviden		= @pbIsDeviden
			, DevidenPeriod	= @pnDevidenPeriod
			, DevidenDate	= @pdDevidenDate
			, CalcId		= @pnCalcId
			, FeeId 		= @nFeeId
			, MIAccountId	= @pcMIAccountId
			, CTDAccountId	= @pcCTDAccountId
			, DevidentPct	= @pnDevidentPct
			, EffectiveAfter = @pnEffectiveAfter
		where ProdId = @pnProdId

		if @@error != 0
		Begin
			set @cErrMsg='Gagal Update Data Product'
			goto ERROR
		End
		
		if @pdValueDate = @dCurrWorkingDate
		Begin
			insert ReksaProductParam_TM (ProdId, TypeId, ManInvId, CustodyId, NAV, MinTotalUnit, MaxTotalUnit
				, MaxDailyUnit, MaxDailyNom, MaxDailyCust, PeriodStart, PeriodEnd, MatureDate, ChangeDate
				, ValueDate, CloseEndBit, IsDeviden, DevidenPeriod, FeeId, DevidentPct, EffectiveAfter)
			select ProdId, TypeId, ManInvId, CustodyId, NAV, MinTotalUnit, MaxTotalUnit
				, MaxDailyUnit, MaxDailyNom, MaxDailyCust, PeriodStart, PeriodEnd, MatureDate, ChangeDate
				, ValueDate, CloseEndBit, IsDeviden, DevidenPeriod, FeeId
				, DevidentPct, EffectiveAfter
			from ReksaProduct_TM
			where ProdId = @pnProdId

			if @@error != 0
			Begin
				set @cErrMsg='Gagal Insert Param Efektif'
				goto ERROR
			End

			Update ReksaProduct_TM
			set ParamId = scope_identity()
			where ProdId = @pnProdId

			if @@error != 0
			Begin
				set @cErrMsg='Gagal Update Param Efektif'
				goto ERROR
			End
		End
		delete ReksaProductMaintenanceFee_TR
		where ProdId = @pnProdId
		
		if @@error!=0
		begin
			set @cErrMsg = 'Error Delete Maintenance Fee AUM (2)'
			goto ERROR
		end
		
		insert into ReksaProductMaintenanceFee_TR (ProdId, AUMMin, AUMMax, NispPct, FundMgrPct, MaintFee)
		select @pnProdId, AUMMin, AUMMax, NispPct, FundMgrPct
			, MaintFee
		from @TempMaintenanceFee	
		
		if @@error!=0
		begin
			set @cErrMsg = 'Error Insert Maintenance Fee AUM (2)'
			goto ERROR
		end		
	commit tran
End
else if @pnType = 3 -- delete
Begin
	-- delete product
	delete ReksaProduct_TM
	where ProdId = @pnProdId
	
	if @@error!=0
	Begin
		set @cErrMsg = 'Error Delete Product!' 
		goto ERROR
	End

	-- delete feenya 
	delete ReksaProductFee_TR
	where FeeId = @nFeeId

	if @@error!=0
	Begin
		set @cErrMsg = 'Error Delete Fee Product!' 
		goto ERROR
	End

	--hapus maintenance fee-nya
	delete ReksaProductMaintenanceFee_TR
	where ProdId = @pnProdId
	
	if @@error!=0
	begin
		set @cErrMsg = 'Error Delete Maintenance Fee AUM'
		goto ERROR
	end
End

return 0

ERROR:
if @@trancount > 0
	Rollback Tran

if isnull(@cErrMsg ,'') = ''
	set @cErrMsg = 'Error !'

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror ( @cErrMsg ,16,1)
return 1
GO