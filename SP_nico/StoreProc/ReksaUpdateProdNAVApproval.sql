CREATE proc [dbo].[ReksaUpdateProdNAVApproval]
/*
    CREATED BY    : Oscar Marino
    CREATION DATE : 20090605
    DESCRIPTION   : Otorisasi perubahan NAV, Tgl NAV, Nominal Pembagi Deviden, Tgl Pembagi Deviden
    
    update ReksaNAVUpdate_TH set Status = 0 where RefId = 2
    
    exec ReksaUpdateProdNAVApproval 2, 1, 32622
    
    REVISED BY    :
        DATE,   USER,       PROJECT,    NOTE
        -----------------------------------------------------------------------
        20120831, liliana, BAALN11003, ketika otor langsung efektif.
        20121008, liliana, BAALN11003, pengecekan EOD
        20150414, dhanan, LOGAM07071, can reject for non-active product
        20170412, liliana, BOSOD17090, trigger by user
    END REVISED
*/
    @pnRefId    int,
    @pbAuth     bit,    -- 0 = rejected, 1 = accepted 
    @pnNIK      int
as 
set nocount on

declare
    @nOK tinyint,
    @cErrMsg varchar(100)
    
set @nOK = 0

-- validasi
if not exists (select top 1 1 from ReksaNAVUpdate_TH where RefId = @pnRefId and Status = 0)
begin
    set @cErrMsg = 'Data tidak ditemukan atau sudah diotorisasi'
    goto ERR_HANDLER
end
--20121008, liliana, BAALN11003, begin
--cek apakah sedang EOD atau tidak
if exists(select top 1 1 from dbo.control_table where end_of_day = 1 and begin_of_day = 0)          
begin          
 set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'          
 goto ERR_HANDLER          
end
--20121008, liliana, BAALN11003, end

-- cek status produk
if not exists (select * from ReksaProduct_TM a join ReksaNAVUpdate_TH b
    on a.ProdId = b.ProdId and b.RefId = @pnRefId where a.Status = 1)
--20150414, dhanan, LOGAM07071, begin
    and @pbAuth = 1
--20150414, dhanan, LOGAM07071, end
begin
    set @cErrMsg = 'Produk sudah belum/tidak aktif'
    goto ERR_HANDLER
end 

-- mulai proses
begin tran

update ReksaNAVUpdate_TH
set Status = case @pbAuth when 1 then 1 when 0 then 2 end, -- 1 = accept, 2 = reject
    Supervisor = @pnNIK
where RefId = @pnRefId

if @@error <> 0
begin
    set @cErrMsg = 'Gagal update ReksaNAVUpdate_TH'
--20120831, liliana, BAALN11003, begin
    rollback tran
--20120831, liliana, BAALN11003, end    
    goto ERR_HANDLER
end

-- proses
---- belum tau jelasnya, jd update status dulu aja
--if @pbAuth = 1 -- accept
--begin
--  exec @nOK = ReksaUpdateProdNAVProcess @pnRefId, @pnNIK
--  if @nOK <> 0 or @@error <> 0
--  begin
--      set @cErrMsg = 'Gagal proses perhitungan ulang hasil sinkronisasi NAV'
--      goto ERR_HANDLER
--  end
--end
--20120831, liliana, BAALN11003, begin
if @pbAuth = 1 -- accept
begin
--20170412, liliana, BOSOD17090, begin
    --exec @nOK = ReksaUpdateProdNAVProcess @pnRefId, @pnNIK
    exec @nOK = ReksaUpdateProdNAVProcess @pnRefId, @pnNIK, 0, 0, 1
--20170412, liliana, BOSOD17090, end    
    if @nOK <> 0 or @@error <> 0
    begin
        set @cErrMsg = 'Gagal proses perhitungan ulang hasil sinkronisasi NAV'
        rollback tran
        goto ERR_HANDLER
    end
end
--20120831, liliana, BAALN11003, end
    
commit tran
    
ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
    if @@trancount > 0 rollback tran
    raiserror (@cErrMsg ,16,1)
    set @nOK = 1
end

return @nOK
GO