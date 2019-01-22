
CREATE Proc [dbo].[ReksaMaintainValueDate]  
/*  
    CREATED BY    : Indra  
    CREATION DATE : 20080423  
    DESCRIPTION   : Prosedur untuk mengubah nav value date  
    REVISED BY    :  
        DATE,       USER,   PROJECT,    NOTE  
        -----------------------------------------------------------------------  
        20080604, indra_w, REKSADN005, Proteksi Dinamis Seri I  
        20080814, indra_w, REKSADN006, nebeng ke fortis  
        20120717, liliana, BARUS12005, agar support switching  
        20120725, liliana, BARUS12005, ganti message  
        20120731, liliana, BARUS12005, Utk switching tidak bisa mengubah nav value date jika sudah lwt cut off  
        20150907, liliana, LIBST13020, ...
        20170228, sandi, LOGAM08640, exception flag TA  
    END REVISED  
  
*/  
--20120717, liliana, BARUS12005, begin  
    --@pnTranId         int  
    @pnTranCode         varchar(20)  
--20120717, liliana, BARUS12005, end  
    , @pdNewValueDate   datetime  
    , @pnNIK            int  
    , @pcGuid           varchar(50)  
--20120717, liliana, BARUS12005, begin  
    , @pnTranType       int  
--20120717, liliana, BARUS12005, end      
As  
  
Set Nocount On  
Declare  
    @nErrNo             int  
    ,@nOK               int   
    ,@cErrMsg           varchar(100)  
    ,@nTranType         tinyint  
    ,@cPeriod           char(8)  
    ,@dCurrWorkingDate  datetime  
    ,@nBillId           int  
--20080604, indra_w, REKSADN005, begin  
--20120717, liliana, BARUS12005, begin  
    ,@pdOldValueDate        datetime  
    ,@pdOldGoodFund         datetime  
    ,@pdNewGoodFund         datetime  
--20120717, liliana, BARUS12005, end  
    ,@nStatus           tinyint  
    ,@nProdId           int  
    ,@nWindowPeriod int  
--20080604, indra_w, REKSADN005, end  
  
--20120717, liliana, BARUS12005, begin  
--20150907, liliana, LIBST13020, begin  
--if(@pnTranType in (1,2,3,4))  
if(@pnTranType in (1,2,3,4,8))  
--20150907, liliana, LIBST13020, end  
begin  
--20120717, liliana, BARUS12005, end      
select @nTranType = TranType  
--20080604, indra_w, REKSADN005, begin  
    , @nStatus = Status  
    , @nProdId = ProdId   
--20080604, indra_w, REKSADN005, end  
from ReksaTransaction_TT  
--20120717, liliana, BARUS12005, begin  
--where TranId = @pnTranId  
where TranCode = @pnTranCode  
end  
--20150907, liliana, LIBST13020, begin  
--else if(@pnTranType in (5,6))  
else if(@pnTranType in (5,6,9))  
--20150907, liliana, LIBST13020, end  
begin  
select @nTranType = TranType  
    , @nStatus = Status  
from dbo.ReksaSwitchingTransaction_TM  
where TranCode = @pnTranCode  
end  
--20120717, liliana, BARUS12005, end  
  
select @cPeriod = convert(char(8), @pdNewValueDate, 112)   
select @pdNewValueDate = @cPeriod  
select @dCurrWorkingDate = current_working_date  
from dbo.fnGetWorkingDate()   
  
--20120717, liliana, BARUS12005, begin  
--if @pdNewValueDate < @dCurrWorkingDate  
--Begin  
--  Set @cErrMsg='Tanggal NAV tidak boleh kecil dari hari ini'  
--  Goto Error  
--End  
if @pdNewValueDate != @dCurrWorkingDate  
Begin  
    Set @cErrMsg='Tanggal NAV harus sama dengan hari ini'  
    Goto Error  
End  
--20120717, liliana, BARUS12005, end  
  
--20080604, indra_w, REKSADN005, begin  
If @nStatus = 0  
Begin  
--20120725, liliana, BARUS12005, begin  
    --Set @cErrMsg='Transaksi Belum Diotorisasi, harap otorisasi dulu'  
    Set @cErrMsg='Transaksi Belum Diotorisasi BS, harap otorisasi dulu'  
--20120725, liliana, BARUS12005, end  
    Goto Error  
End  
  
select @nWindowPeriod = isnull(WindowPeriod,0)  
from ReksaProduct_TM   
where ProdId = @nProdId  
  
--20080814, indra_w, REKSADN006, begin  
--if @nWindowPeriod = 1 and dbo.fnIsWindowPeriod(@nProdId, @pdNewValueDate) = 0  
if @nWindowPeriod = 1 and dbo.fnIsWindowPeriod(@nProdId, @pdNewValueDate, 0) = 0  
--20080814, indra_w, REKSADN006, end  
    and @nTranType in (3,4)  
Begin      
    set @cErrMsg = 'Tanggal Baru di luar Window Period'      
    goto Error      
End      
--20080604, indra_w, REKSADN005, end  
--20120731, liliana, BARUS12005, begin  
--20150907, liliana, LIBST13020, begin  
--if(@nTranType in (5,6) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessStatus = 1 and ProcessId = 1))  
if(@nTranType in (5,6,9) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessStatus = 1 and ProcessId = 1))  
--20150907, liliana, LIBST13020, end  
begin  
    set @cErrMsg = 'Sudah lewat cutoff. Tidak dapat mengubah nilai NAV Date untuk transaksi switching.'      
    goto Error   
end  
--20120731, liliana, BARUS12005, end  
  
--20120717, liliana, BARUS12005, begin  
--20150907, liliana, LIBST13020, begin  
--if(@nTranType in (1,2,3,4))  
if(@nTranType in (1,2,3,4,8))  
--20150907, liliana, LIBST13020, end  
begin  
--20120717, liliana, BARUS12005, end  
-- untuk Subc, PO belum cut off, atau untuk redemption  
--20150907, liliana, LIBST13020, begin  
--If (@nTranType in (1,2) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = 1 and ProcessStatus = 0))  
If (@nTranType in (1,2,8) and exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = 1 and ProcessStatus = 0))  
--20150907, liliana, LIBST13020, end  
    or @nTranType in (3,4)  
Begin  
--20120717, liliana, BARUS12005, begin  
    select @pdOldValueDate = NAVValueDate,  
           @pdOldGoodFund = GoodFund  
    from dbo.ReksaTransaction_TT  
    where TranCode = @pnTranCode  
  
--20120717, liliana, BARUS12005, end  
    Update ReksaTransaction_TT  
    set NAVValueDate = @pdNewValueDate  
--20080604, indra_w, REKSADN005, begin  
        , GoodFund  = case when @nTranType in (3,4) then   
                                    case    when ExtStatus = 2 then dbo.fnReksaGoodFund (ProdId,@pdNewValueDate,4)  
                                                else dbo.fnReksaGoodFund (ProdId,@pdNewValueDate,2)  
                                    end  
                                else null  
                            end  
--20080604, indra_w, REKSADN005, end
--20170228, sandi, LOGAM08640, begin  
        --, ExtStatus = 5  
--20170228, sandi, LOGAM08640, end        
        , GFSUid = @pnNIK  
        , GFChangeDate = getdate()  
--20120717, liliana, BARUS12005, begin        
    --where TranId = @pnTranId  
        where TranCode = @pnTranCode  
--20120717, liliana, BARUS12005, end  
  
    if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Update NAV Value Date (1)'  
        Goto Error  
    End
--20170228, sandi, LOGAM08640, begin  
	Update ReksaTransaction_TT
	set ExtStatus = 5
	where TranCode = @pnTranCode
		and isnull(ExtStatus, 0) <> 74
	
	if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Update Ext Status (1)'  
        Goto Error  
    End          
--20170228, sandi, LOGAM08640, end      
--20120717, liliana, BARUS12005, begin  
  
    select @pdNewGoodFund = GoodFund  
    from dbo.ReksaTransaction_TT  
    where TranCode = @pnTranCode  
  
    insert dbo.ReksaAdjustNAVDateAuditTrail_TH (TranCode, TranType, OldNAVDate, NewNAVDate, OldGoodFund, NewGoodFund, UserSUID, UpdateDate)  
    select @pnTranCode, @nTranType, @pdOldValueDate, @pdNewValueDate, @pdOldGoodFund, @pdNewGoodFund, @pnNIK, getdate()  
      
    if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Insert ke Audit Trail (1)'  
        Goto Error  
    End  
--20120717, liliana, BARUS12005, end  
End  
Else -- sisanya jika PO sudah cut off, bedanya, harus bikin bill  
Begin  
    Begin Tran  
--20120717, liliana, BARUS12005, begin  
        select @pdOldValueDate = NAVValueDate  
        from dbo.ReksaTransaction_TT  
        where TranCode = @pnTranCode  
      
--20120717, liliana, BARUS12005, end      
        Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate    
                            , ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased)    
        select 1, @cPeriod + ' - Subscription - '+ c.CustodyName, 'C', getdate(), @dCurrWorkingDate    
                , a.ProdId, c.CustodyId, a.TranCCY    
                , case when a.FullAmount = 1 then case when a.TranCCY = 'IDR' then round(a.TranAmt,0)    
                                                        else round(a.TranAmt,2)    
                                                     end    
                    else case when a.TranCCY = 'IDR' then round(a.TranAmt, 0) - round(a.SubcFee, 0)    
                                else round(a.TranAmt, 2) - round(a.SubcFee, 2)    
                            end    
                    end  
                , case when a.TranCCY = 'IDR' then round(a.SubcFee, 0) else round(a.SubcFee, 2) end    
       , case when a.TranCCY = 'IDR' then round(a.SubcFeeBased, 0) else round(a.SubcFeeBased, 2) end    
        from ReksaTransaction_TT a join ReksaProduct_TM b    
                on a.ProdId = b.ProdId    
                    join ReksaCustody_TR c    
                on b.CustodyId = c.CustodyId    
--20120717, liliana, BARUS12005, begin                
        --where a.TranId = @pnTranId  
            where a.TranCode = @pnTranCode  
--20120717, liliana, BARUS12005, end  
  
        if @@error != 0   
        Begin  
            Set @cErrMsg='Gagal Generate Bill'  
            Goto Error  
        End       
  
        select @nBillId = scope_identity()   
  
        Update ReksaTransaction_TT  
        set NAVValueDate = @pdNewValueDate
--20170228, sandi, LOGAM08640, begin  
			--, ExtStatus = 5  
--20170228, sandi, LOGAM08640, end          
            , BillId = @nBillId  
            , GFSUid = @pnNIK  
            , GFChangeDate = getdate()  
--20120717, liliana, BARUS12005, begin            
        --where TranId = @pnTranId  
        where TranCode = @pnTranCode  
--20120717, liliana, BARUS12005, end  
  
        if @@error != 0   
        Begin  
            Set @cErrMsg='Gagal Update NAV Value Date (2)'  
            Goto Error  
        End
--20170228, sandi, LOGAM08640, begin  
		Update ReksaTransaction_TT
		set ExtStatus = 5
		where TranCode = @pnTranCode
			and isnull(ExtStatus, 0) <> 74

		if @@error != 0   
		Begin  
			Set @cErrMsg='Gagal Update Ext Status (2)'  
			Goto Error  
		End          
--20170228, sandi, LOGAM08640, end           
--20120717, liliana, BARUS12005, begin  
    insert dbo.ReksaAdjustNAVDateAuditTrail_TH (TranCode, TranType, OldNAVDate, NewNAVDate, UserSUID, UpdateDate)  
    select @pnTranCode, @nTranType, @pdOldValueDate, @pdNewValueDate, @pnNIK, getdate()  
      
    if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Insert ke Audit Trail (2)'  
        Goto Error  
    End  
--20120717, liliana, BARUS12005, end          
    commit tran  
End  
--20120717, liliana, BARUS12005, begin  
end  
--20150907, liliana, LIBST13020, begin  
--else if(@nTranType in (5,6))  
else if(@nTranType in (5,6,9))  
--20150907, liliana, LIBST13020, end  
begin  
  
    select @pdOldValueDate = NAVValueDate  
    from dbo.ReksaSwitchingTransaction_TM  
    where TranCode = @pnTranCode  
      
    Update ReksaSwitchingTransaction_TM  
    set NAVValueDate = @pdNewValueDate
--20170228, sandi, LOGAM08640, begin  
		--, ExtStatus = 5  
--20170228, sandi, LOGAM08640, end        
        , GFSUid = @pnNIK  
        , GFChangeDate = getdate()  
    where TranCode = @pnTranCode  
  
    if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Update NAV Value Date (3)'  
        Goto Error  
    End
--20170228, sandi, LOGAM08640, begin  
	Update ReksaSwitchingTransaction_TM
	set ExtStatus = 5
	where TranCode = @pnTranCode
		and isnull(ExtStatus, 0) <> 74

	if @@error != 0   
	Begin  
		Set @cErrMsg='Gagal Update Ext Status (3)'  
		Goto Error  
	End          
--20170228, sandi, LOGAM08640, end      
      
    insert dbo.ReksaAdjustNAVDateAuditTrail_TH (TranCode, TranType, OldNAVDate, NewNAVDate, UserSUID, UpdateDate)  
    select @pnTranCode, @nTranType, @pdOldValueDate, @pdNewValueDate, @pnNIK, getdate()  
      
    if @@error != 0   
    Begin  
        Set @cErrMsg='Gagal Insert ke Audit Trail (3)'  
        Goto Error  
    End  
      
End  
--20120717, liliana, BARUS12005, end  
  
Return 0  
  
Error:  
if @@trancount >0   
    rollback tran  
  
if isnull(@cErrMsg,'') = ''  
    set @cErrMsg = 'Unknown Error'  
  
--Exec @nOK=set_raiserror @@procid, @nErrNo Output  
--If @nOK!=0 Return 1  
Raiserror (@cErrMsg ,16,1);  
  
Return 1
GO