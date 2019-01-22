
CREATE proc [dbo].[ReksaPopulateVerifyProdNAV]
/*
	CREATED BY    : Oscar Marino
	CREATION DATE : 20090605
	DESCRIPTION   : tampilkan update NAV produk yg mau diotorisasi
	
	exec ReksaPopulateVerifyProdNAV
	
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20100203, oscar, REKSADN014, tampilkan data >= H-2 saja
		20100215, oscar, REKSADN014, perbaikan UAT hari-5
		20120803, liliana, BAALN11003, ganti nilai nav jadi nav sebelumnya
		20120924, liliana, BAALN11003, tambah harga unit per hari
	END REVISED
*/
as 
set nocount on

declare 
	@bCheck	bit
--20100203, oscar, REKSADN014, begin
	, @dMinDate datetime
	
select @dMinDate = dbo.fnReksaGetEffectiveDate(current_working_date, -2) 
from control_table
--20100203, oscar, REKSADN014, end

set @bCheck = 0

select 
	@bCheck as 'CheckB',
	RefId, 
	a.ProdId,
	b.ProdName, 
--20120803, liliana, BAALN11003, begin
	--b.NAV as 'CurrentNAV',
	a.OldNAV as 'CurrentNAV',
--20120803, liliana, BAALN11003, end
	a.NAV as 'UpdateNAV', 
	a.NAVValueDate, 
	DevidentDate, 
--20100215, oscar, REKSADN014, begin	
	--DevidentAmount, 
	case 
		when DevidentAmount = -1 then '-' 
		else convert(varchar(38), DevidentAmount) end 
	as DevidentAmount, 
--20100215, oscar, REKSADN014, end
--20120924, liliana, BAALN11003, begin
	a.HargaUnitPerHari,
--20120924, liliana, BAALN11003, end
	a.LastUpdate, 
	a.LastUser
from ReksaNAVUpdate_TH a
join ReksaProduct_TM b
	on a.ProdId = b.ProdId
left join ReksaNAVParam_TH c
	on a.ProdId = c.ProdId
	and a.NAVValueDate = c.ValueDate
where a.Status = 0
--20100203, oscar, REKSADN014, begin
and a.NAVValueDate >= @dMinDate
--20100203, oscar, REKSADN014, end
order by a.RefId

return 0
GO