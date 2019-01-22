CREATE proc [dbo].[ReksaUpdateMFeePopulateVerify]
/*
    CREATED BY    : liliana
    CREATION DATE : 
    DESCRIPTION   : menampilkan list batch upload M Fee yg perlu disinkronsasi
    
    exec ReksaUpdateMFeePopulateVerify 
    
    REVISED BY    :
        DATE,   USER,       PROJECT,    NOTE
        -----------------------------------------------------------------------
		20151124, liliana, LIODD15275, tambah parameter utk recalc
    END REVISED
*/
--20151124, liliana, LIODD15275, begin
@nIsRecalculate				int,
@pnNIK						int  
--20151124, liliana, LIODD15275, end
as

set nocount on

declare @bCheck                     bit,
        @cErrMsg                    varchar(100),
        @nOK                        tinyint     
        ,@dMinDate                  datetime

set @bCheck = 0
set @nOK = 0


--select @bCheck as 'CheckB',
--  upper(mf.BatchGuid) as 'BatchGuid',    
--  mf.RefId,
--  rp.ProdCode as ProductCode,
--  rd.CustodyCode as CustodyCode,
--  ml.ClientCode as ClientCode,
--  ml.TanggalTransaksi as TanggalTransaksi,
--  ml.ReverseTanggalTransaksi as ReverseTanggalTransaksi,
--  ml.NominalMaintenanceFeeBefore,
--  ml.NominalMaintenanceFeeAfter,
--  ml.LastUser,
--  ml.LastUpdate
--from dbo.ReksaMFeeUploadProcessLog_TH mf
--  join dbo.ReksaMFeeUploadLog_TH ml
--      on ml.BatchGuid = mf.BatchGuid
--  join dbo.ReksaProduct_TM rp
--      on rp.ProdId = mf.ProdId
--  join dbo.ReksaCustody_TR rd
--      on rd.CustodyId = mf.CustodyId
--  where mf.Status = 0 -- uploaded
--      and mf.Supervisor is null       

select @bCheck as 'CheckB',
    upper(mf.BatchGuid) as 'BatchGuid',    
    mf.RefId,
    rp.ProdCode as ProductCode,
    rd.CustodyCode as CustodyCode,
    mf.LastUser
--20151124, liliana, LIODD15275, begin
	, [Type]			
--20151124, liliana, LIODD15275, end      
from dbo.ReksaMFeeUploadProcessLog_TH mf
    join dbo.ReksaProduct_TM rp
        on rp.ProdId = mf.ProdId
    join dbo.ReksaCustody_TR rd
        on rd.CustodyId = mf.CustodyId
    where mf.Status = 0 -- uploaded
        and mf.Supervisor is null   
--20151124, liliana, LIODD15275, begin
		and [Type] = @nIsRecalculate			
--20151124, liliana, LIODD15275, end        


ERROR:
if isnull(@cErrMsg, '') != '' 
begin
    set @nOK = 1
    raiserror (@cErrMsg,16,1)
end

return @nOK
GO