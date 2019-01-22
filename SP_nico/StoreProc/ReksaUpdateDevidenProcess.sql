CREATE proc [dbo].[ReksaUpdateDevidenProcess]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120618
	DESCRIPTION   : proses sinkronisasi deviden
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120713, liliana, BAALN11003, ganti jadi client id
		20120725, liliana, BAALN11003, perbaikan utk bagian update
		20121008, liliana, BAALN11003, perubahan ketika update bill id
		20121008, liliana, BAALN11003, Bill di bulatkan 2 angka belakang koma
	END REVISED
*/
	@dValueDate		datetime,
	@pnRefId		int,
	@pbDebug		bit = 0
as
set nocount on

declare 
	@nOK		tinyint,
	@cErrMsg	varchar(100),
	@cTranCode	varchar(20),
	@dTranDate	datetime,
	@dCurrWorkingDate	datetime,
	@dNextWorkingDate	datetime,
	@dPrevWorkingDate	datetime,
	@nProdId			int,
	@cPeriod			char(8),
	@cProdCCY			char(3),
	@nCalcId			int
	
	set @nOK = 0
	set @cTranCode = ''
	 
	select @dCurrWorkingDate = dbo.fnReksaGetEffectiveDate(@dValueDate, 0)
	select @dNextWorkingDate = dbo.fnReksaGetEffectiveDate(@dValueDate, 1)
	select @dPrevWorkingDate = dbo.fnReksaGetEffectiveDate(@dValueDate, -1)

	select @dTranDate = dateadd(day, datediff(day, getdate(), @dCurrWorkingDate), getdate()) 
	
	set @cPeriod = convert(char(8), @dValueDate, 112)  
	
	select @nProdId = ProdId 
	from dbo.ReksaNAVUpdate_TH
	where RefId = @pnRefId
	
	select @cProdCCY = ProdCCY,
		   @nCalcId = CalcId
	from dbo.ReksaProduct_TM
	where ProdId = @nProdId
	
	create table #ReksaTransaction_TT (
		TranCode			varchar(8),
		TranType			tinyint,
		TranDate			datetime,
		ProdId				int,
		ClientId			int,
		FundId				int,
		AgentId				int,
		TranCCY				varchar(3),
		TranAmt				decimal(25,13),
		TranUnit			decimal(25,13),
		SubcFee				decimal(25,13),
		RedempFee			decimal(25,13),
		SubcFeeBased		decimal(25,13),
		RedempFeeBased		decimal(25,13),
		NAV					decimal(25,13),
		NAVValueDate		datetime,
		Kurs				decimal(25,13),
		UnitBalance			decimal(25,13),
		UnitBalanceNom		decimal(25,13),
		ParamId				int,
		ProcessDate			datetime,
		SettleDate			datetime,
		Settled				bit,
		LastUpdate			datetime,
		UserSuid			int,
		CheckerSuid			int,
		WMCheckerSuid		int,
		WMOtor				bit,
		ReverseSuid			int,
		Status				tinyint,
		BillId				int,
		ByUnit				bit,
		BlockSequence		int
	)
	
	create table #ReksaBill_TM (
			BillType			tinyint,
			BillName			varchar(100),
			DebitCredit			char(1),
			CreateDate			datetime,
			ValueDate			datetime,
			ProdId				int,
			CustodyId			int,
			BillCCY				char(3),
			TotalBill			decimal(25,13),
			Fee					decimal(25,13),
			FeeBased			decimal(25,13)
		)
	
	if not exists(select top 1 1 from dbo.ReksaOSUploadProcessLog_TH where NAVValueDate = @dPrevWorkingDate and Status = 3)
	begin
		set @cErrMsg = 'Sinkronisasi Deviden tidak dapat dijalankan, krn hari sebelumnya tidak melakukan Sinkronisasi Outstanding!'
		goto ERR_HANDLER
	end
	
	
	If @nCalcId not in (2,5) -- kalo bukan Proteksi, kredit dulu, kalo proteksi jangan di kredit  
	Begin	
	
		Insert #ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
			, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
			, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
			, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence) 
		select @cTranCode, 5, @dValueDate, @nProdId, rc.ClientId, null, rc.AgentId, rp.ProdCCY, 
			isnull(rl.UnitBalanceAfter,0) * nav.Deviden  
			, (isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV
			, 0, 0, 0, 0, nav.NAV, @dValueDate, nav.Kurs
			, isnull(rl.UnitBalanceAfter,0) -  ((isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV)
			, (isnull(rl.UnitBalanceAfter,0) -  ((isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV)) * nav.NAV
			, rp.ParamId, @dTranDate, @dTranDate, 1, @dTranDate, 7, 7  
			, null, 0, null, 1, null, 1, 0  
		from dbo.ReksaCIFData_TM rc
			join dbo.ReksaOSUploadLog_TH rl
				on rl.ClientCode = rc.ClientCode
			join dbo.ReksaOSUploadProcessLog_TH ro
				on ro.BatchGuid = rl.BatchGuid
				and ro.Status = 3
				and ro.NAVValueDate = @dPrevWorkingDate
			join dbo.ReksaProduct_TM rp
				on rc.ProdId = rp.ProdId
			join ReksaNAVParam_TH nav  
				on rc.ProdId = nav.ProdId  
				and nav.ValueDate = @dValueDate   
		where rp.IsDeviden = 1
			and rc.CIFStatus = 'A'  
			and rp.Status = 1 
		order by rc.ProdId, rc.ClientId  
		
		if @@error != 0
		Begin
			set @cErrMsg = 'Gagal insert data trancode type 5!'
			goto ERR_HANDLER
		End
	
	end
	
	Insert #ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
		, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
		, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
		, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence) 
	select @cTranCode, 6, @dValueDate, @nProdId, rc.ClientId, null, rc.AgentId, rp.ProdCCY, 
			isnull(rl.UnitBalanceAfter,0) * nav.Deviden  
			, (isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV
			, 0, 0, 0, 0, nav.NAV, @dValueDate, nav.Kurs
			, isnull(rl.UnitBalanceAfter,0) -  ((isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV)
			, (isnull(rl.UnitBalanceAfter,0) -  ((isnull(rl.UnitBalanceAfter,0) * nav.Deviden) / nav.NAV)) * nav.NAV
			, rp.ParamId, @dTranDate, @dTranDate, 1, @dTranDate, 7, 7  
			, null, 0, null, 1, null, 1, 0  
		from dbo.ReksaCIFData_TM rc
			join dbo.ReksaOSUploadLog_TH rl
				on rl.ClientCode = rc.ClientCode
			join dbo.ReksaOSUploadProcessLog_TH ro
				on ro.BatchGuid = rl.BatchGuid
				and ro.Status = 3
				and ro.NAVValueDate = @dPrevWorkingDate
			join dbo.ReksaProduct_TM rp
				on rc.ProdId = rp.ProdId
			join ReksaNAVParam_TH nav  
				on rc.ProdId = nav.ProdId  
				and nav.ValueDate = @dValueDate   
		where rp.IsDeviden = 1
			and rc.CIFStatus = 'A'  
			and rp.Status = 1 
		order by rc.ProdId, rc.ClientId  
	
	if @@error != 0
	Begin
		set @cErrMsg = 'Gagal insert data trancode type 6!'
		goto ERR_HANDLER
	End 
	
	if(@pbDebug = 1)
	begin
		select * from #ReksaTransaction_TT
	end
			
	--kalau belum ada trx deviden
	if not exists(select top 1 1 from dbo.ReksaTransaction_TT where TranType in (5,6) and NAVValueDate = @dValueDate)
	begin
			begin tran
			
			Insert dbo.ReksaTransaction_TT(TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
				, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
				, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
				, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence) 
			select TranCode, TranType, TranDate, ProdId, ClientId, FundId, AgentId, TranCCY, TranAmt  
				, TranUnit, SubcFee, RedempFee, SubcFeeBased, RedempFeeBased, NAV, NAVValueDate, Kurs, UnitBalance  
				, UnitBalanceNom, ParamId, ProcessDate, SettleDate, Settled, LastUpdate, UserSuid, CheckerSuid  
				, WMCheckerSuid, WMOtor, ReverseSuid, Status, BillId, ByUnit, BlockSequence
			from #ReksaTransaction_TT
			
			--insert bill
			Insert dbo.ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
					, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)  
			select 3, @cPeriod + ' - Deviden - '+ rd.CustodyName, 'D', @dTranDate, @dValueDate   
				, tt.ProdId, rd.CustodyId, tt.TranCCY  
--20121008, liliana, BAALN11003, begin				
				--, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.TranAmt,0),0) else round(isnull(tt.TranAmt,0),2) end)  
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.TranAmt,0),2) else round(isnull(tt.TranAmt,0),2) end)  
--20121008, liliana, BAALN11003, end				
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.SubcFee,0),0) else round(isnull(tt.SubcFee,0),2) end)  
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.SubcFeeBased,0),0) else round(isnull(tt.SubcFeeBased,0),2) end)  				
			from ReksaTransaction_TT tt join ReksaProduct_TM rp  
					on tt.ProdId = rp.ProdId  
				join ReksaCustody_TR rd
					on rp.CustodyId = rd.CustodyId  
			where tt.TranType in (6)  
				and tt.ProdId = @nProdId  
				and tt.TranCCY = @cProdCCY  
				and isnull(tt.BillId, 0) = 0  
				and tt.NAVValueDate = @dValueDate
			group by rd.CustodyName, tt.ProdId, rd.CustodyId, tt.TranCCY  
	  
			If @@error!= 0  
			Begin  
				set @cErrMsg = 'Gagal Process Subc By Nominal!'  
				goto ERR_HANDLER  
			End  

			Update dbo.ReksaTransaction_TT  
			set BillId = scope_identity()  
			from ReksaTransaction_TT tt join ReksaProduct_TM rp  
					on tt.ProdId = rp.ProdId  
			where isnull(tt.BillId, 0) = 0  
					and tt.TranType in (6)  
					and tt.NAVValueDate = @dValueDate
					and tt.ProdId = @nProdId  
					and tt.TranCCY = @cProdCCY  
			
			commit tran	
	
	end
	else
	begin
		begin tran
		
		if(@pbDebug = 1)
		begin
			print 'before'
			select * from dbo.ReksaTransaction_TT
			where TranType in (5,6)
			and	NAVValueDate = @dValueDate
			and ProdId = @nProdId 
		end
		
		insert into dbo.ReksaChangeRecord_TH
		(TransactionDate, TranId, ClientCode, 
		FieldName, OldValue, NewValue, Remarks)
--20120713, liliana, BAALN11003, begin
		--select getdate(), tt.TranId, tt.ClientCode, 
		select getdate(), tt.TranId, rc.ClientCode, 
--20120713, liliana, BAALN11003, end
		'TranAmt', tt.TranAmt, rt.TranAmt, 'Sync Deviden Ref ' + convert(varchar(6), @pnRefId)
		from dbo.ReksaTransaction_TT tt 
		join #ReksaTransaction_TT rt
			on tt.NAVValueDate = rt.NAVValueDate
				and tt.ClientId = rt.ClientId
				and tt.ProdId = rt.ProdId
				and tt.TranType = rt.TranType
--20120713, liliana, BAALN11003, begin
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
--20120713, liliana, BAALN11003, end
		where tt.TranAmt <> rt.TranAmt
		union
--20120713, liliana, BAALN11003, begin
		--select getdate(), tt.TranId, tt.ClientCode,
		select getdate(), tt.TranId, rc.ClientCode,  
--20120713, liliana, BAALN11003, end
		'TranUnit', tt.TranUnit, rt.TranUnit, 'Sync Deviden Ref ' + convert(varchar(6), @pnRefId)
		from dbo.ReksaTransaction_TT tt 
		join #ReksaTransaction_TT rt
			on tt.NAVValueDate = rt.NAVValueDate
				and tt.ClientId = rt.ClientId
				and tt.ProdId = rt.ProdId
				and tt.TranType = rt.TranType
--20120713, liliana, BAALN11003, begin
		join dbo.ReksaCIFData_TM rc
			on rc.ClientId = tt.ClientId
--20120713, liliana, BAALN11003, end
		where tt.TranUnit <> rt.TranUnit
			
		update tt
		set TranAmt = rt.TranAmt,
			TranUnit = rt.TranUnit,
			UnitBalance  = rt.UnitBalance,
			UnitBalanceNom = rt.UnitBalanceNom
		from dbo.ReksaTransaction_TT tt
			join #ReksaTransaction_TT rt
				on tt.NAVValueDate = rt.NAVValueDate
				and tt.ClientId = rt.ClientId
				and tt.ProdId = rt.ProdId
				and tt.TranType = rt.TranType
				
		if(@pbDebug = 1)
		begin
			print 'after'
			select * from dbo.ReksaTransaction_TT
			where TranType in (5,6)
			and	NAVValueDate = @dValueDate
			and ProdId = @nProdId 
		end
		

		--update bill
		Insert #ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
					, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)  
		select 3, @cPeriod + ' - Deviden - '+ rd.CustodyName, 'D', @dTranDate, @dValueDate   
				, tt.ProdId, rd.CustodyId, tt.TranCCY  
--20121008, liliana, BAALN11003, begin				
				--, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.TranAmt,0),0) else round(isnull(tt.TranAmt,0),2) end)  
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.TranAmt,0),2) else round(isnull(tt.TranAmt,0),2) end)  
--20121008, liliana, BAALN11003, end				
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.SubcFee,0),0) else round(isnull(tt.SubcFee,0),2) end)  
				, sum(case when tt.TranCCY = 'IDR' then round(isnull(tt.SubcFeeBased,0),0) else round(isnull(tt.SubcFeeBased,0),2) end)  
			from ReksaTransaction_TT tt join ReksaProduct_TM rp  
					on tt.ProdId = rp.ProdId  
				join ReksaCustody_TR rd
					on rp.CustodyId = rd.CustodyId  
			where tt.TranType in (6)  
				and tt.ProdId = @nProdId  
				and tt.TranCCY = @cProdCCY  
--20120725, liliana, BAALN11003, begin
				--and isnull(tt.BillId, 0) = 0  
--20120725, liliana, BAALN11003, end				
				and tt.NAVValueDate = @dValueDate
			group by rd.CustodyName, tt.ProdId, rd.CustodyId, tt.TranCCY  
		
		if(@pbDebug = 1)
		begin
			select * from #ReksaBill_TM
		end

--20120713, liliana, BAALN11003, begin		
		--update bi
		--set TotalBill = tr.TotalBill,
		--	Fee = tr.Fee,
		--	FeeBased = tr.FeeBased
		--from dbo.ReksaBill_TM bi
		--	join #ReksaBill_TM tr
		--		on bi.BillType = tr.BillType
		--		and bi.DebitCredit = tr.DebitCredit
		--		and bi.ValueDate = tr.ValueDate
		--		and bi.ProdId = tr.ProdId
		--		and bi.CustodyId = tr.CustodyId
		--		and bi.BillCCY = tr.BillCCY
		delete bi
		from dbo.ReksaBill_TM bi
		join #ReksaBill_TM tr
				on bi.BillType = tr.BillType
				and bi.DebitCredit = tr.DebitCredit
				and bi.ValueDate = tr.ValueDate
				and bi.ProdId = tr.ProdId
				and bi.CustodyId = tr.CustodyId
				and bi.BillCCY = tr.BillCCY
		
		insert dbo.ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
		, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)
		select BillType, BillName, DebitCredit, CreateDate, ValueDate  
		, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased 
		from #ReksaBill_TM
		
		
		If @@error!= 0  
		Begin  
			set @cErrMsg = 'Gagal Process Bill (2)!'  
			goto ERR_HANDLER  
		End  

		Update dbo.ReksaTransaction_TT  
		set BillId = scope_identity()  
		from ReksaTransaction_TT tt join ReksaProduct_TM rp  
				on tt.ProdId = rp.ProdId  
--20121008, liliana, BAALN11003, begin
		--where isnull(tt.BillId, 0) = 0  
		--		and tt.TranType in (6) 
			where 
					tt.TranType in (6)   
--20121008, liliana, BAALN11003, end				
				and tt.NAVValueDate = @dValueDate
				and tt.ProdId = @nProdId  
				and tt.TranCCY = @cProdCCY  
		 
--20120713, liliana, BAALN11003, end
		
		commit tran
	end
	
	
	drop table #ReksaTransaction_TT
	drop table #ReksaBill_TM

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
	if @@trancount > 0 rollback tran
	raiserror (@cErrMsg,16,1)
	set @nOK = 1
end

return @nOK
GO