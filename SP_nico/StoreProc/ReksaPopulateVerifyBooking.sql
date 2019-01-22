
CREATE proc [dbo].[ReksaPopulateVerifyBooking]
/*
	CREATED BY    : victor
	CREATION DATE : 20071031
	DESCRIPTION   : menampilkan list booking yang perlu di authorize
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071128, victor, REKSADN002, tambah filter cabang
		20071204, victor, REKSADN002, tambah select authtype (new / delete / update)
		20071205, victor, REKSADN002, tambah select booking amount
		20120215, liliana, BAALN11008, tambah kolom RiskProfile ,Waperd, Seller
		20120216, liliana, BAALN11008, ganti urutan kolom
		20120217, liliana, BAALN11008, ganti dengan join dan left join
		20120217, liliana, BAALN11008, alamat konfirmasi
		20120220, liliana, BAALN11008, ganti kolom alamat konfirmasi
		20130218, anthony, BARUS12010, tambah kolom npwp
		20130220, anthony, BARUS12010, edit keterangan
		20130305, anthony, BARUS12010, fcd
		20130321, liliana, BATOY12006, update nama nasabah
		20130408, liliana, BATOY12006, tambah kolom
		20130710, liliana, BAFEM12011, tambah kolom channel
		20130812, liliana, BAALN11010, ganti desc risk profile

	END REVISED
		
	select * from dbo.ReksaBooking_TM
	select * from dbo.ReksaCIFData_TM
	select * from dbo.ReksaProduct_TM
	select * from dbo.ReksaAgent_TR

	exec dbo.ReksaPopulateVerifyBooking null
*/
@cNik								int

as

set nocount on

declare	@bCheck						bit
--20071128, victor, REKSADN002, begin
	,@cOfficeId						varchar(5)

select @cOfficeId = office_id_sibs
from dbo.user_nisp_v
where nik = @cNik
--20071128, victor, REKSADN002, end
set @bCheck = 0

--20120217, liliana, BAALN11008, begin
--select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo, c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId
----20071205, victor, REKSADN002, begin
----20120215, liliana, BAALN11008, begin
----20120216, liliana, BAALN11008, begin
--	, a.BookingAmt
----20120216, liliana, BAALN11008, end
--	, convert(varchar(50),'') as RiskProfile
--	, a.IsEmployee
--	, rc.AddressLine1 as AlamatKonfirmasi
--	, a.Seller
--	, ps.EmployeeName as NamaSeller
----20120215, liliana, BAALN11008, end
----20120216, liliana, BAALN11008, begin
--	--, a.BookingAmt
----20120216, liliana, BAALN11008, end
----20071205, victor, REKSADN002, end
----20071204, victor, REKSADN002, begin
--	,	(
--			case a.AuthType
--				when 1 then 'New'
--				when 3 then 'Delete'
--				when 4 then 'Update'
--			end
--		) 
----20071205, victor, REKSADN002, begin
--	as 'Action'
----20071205, victor, REKSADN002, end
----20071204, victor, REKSADN002, end
----20120215, liliana, BAALN11008, begin
--into #tempReport
----20120215, liliana, BAALN11008, end
--from dbo.ReksaBooking_TM a, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d
----20071128, victor, REKSADN002, begin
--	, dbo.user_nisp_v e
----20071128, victor, REKSADN002, end
----20120215, liliana, BAALN11008, begin
--	, SQL_Employee.dbo.EmployeePeopleSoft ps
--	, dbo.ReksaCIFConfirmAddr_TM rc
----20120215, liliana, BAALN11008, end
--where a.ProdId = c.ProdId
--	and a.AgentId = d.AgentId
--	and a.CheckerSuid is null
--	and a.AuthType in (1,3)
----20071128, victor, REKSADN002, begin
----20120215, liliana, BAALN11008, begin
--	and ps.EmployeeId = a.Seller
--	and rc.CIFNo =  a.CIFNo
----20120215, liliana, BAALN11008, end
--	and a.UserSuid = e.nik
--	and e.office_id_sibs = @cOfficeId
----20071128, victor, REKSADN002, end
--union all
--select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo, c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId
----20071205, victor, REKSADN002, begin
----20120215, liliana, BAALN11008, begin
----20120216, liliana, BAALN11008, begin
--	, a.BookingAmt
----20120216, liliana, BAALN11008, end
--	, convert(varchar(50),'') as RiskProfile
--	, a.IsEmployee
--	, rc.AddressLine1 as AlamatKonfirmasi
--	, a.Seller
--	, ps.EmployeeName as NamaSeller
----20120215, liliana, BAALN11008, end
----20120216, liliana, BAALN11008, begin
--	--, a.BookingAmt
----20120216, liliana, BAALN11008, end	
----20071205, victor, REKSADN002, end
----20071204, victor, REKSADN002, begin
--	,	(
--			case a.AuthType
--				when 1 then 'New'
--				when 3 then 'Delete'
--				when 4 then 'Update'
--			end
--		)
----20071204, victor, REKSADN002, end
----20071205, victor, REKSADN002, begin
--	as 'Action'
----20071205, victor, REKSADN002, end
--from dbo.ReksaBooking_TH a, dbo.ReksaProduct_TM c, dbo.ReksaAgent_TR d
----20071128, victor, REKSADN002, begin
----20120215, liliana, BAALN11008, begin
--	, SQL_Employee.dbo.EmployeePeopleSoft ps
--	, dbo.ReksaCIFConfirmAddr_TM rc
----20120215, liliana, BAALN11008, end
--	, dbo.user_nisp_v e
----20071128, victor, REKSADN002, end
--where a.ProdId = c.ProdId
--	and a.AgentId = d.AgentId
--	and a.CheckerSuid is null
--	and a.AuthType = 4
----20071128, victor, REKSADN002, begin
----20120215, liliana, BAALN11008, begin
--	and ps.EmployeeId = a.Seller
--	and rc.CIFNo =  a.CIFNo
----20120215, liliana, BAALN11008, end
--	and a.UserSuid = e.nik
--	and e.office_id_sibs = @cOfficeId
----20071128, victor, REKSADN002, end

--20130408, liliana, BATOY12006, begin
--select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo, c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId
select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo,convert(varchar(100),'') as CIFName , c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId  
--20130408, liliana, BATOY12006, end
	, a.BookingAmt
	, convert(varchar(50),'') as RiskProfile
	, a.IsEmployee
--20120217, liliana, BAALN11008, begin	
	--, rc.AddressLine1 as AlamatKonfirmasi
--20120220, liliana, BAALN11008, begin	
	--, convert(varchar(200),'') as AlamatKonfirmasi
	, rc.AddressLine1 as AlamatKonfirmasi
--20120220, liliana, BAALN11008, end	
--20120217, liliana, BAALN11008, end	
	, a.Seller
	, ps.EmployeeName as NamaSeller
	,	(
			case a.AuthType
				when 1 then 'New'
				when 3 then 'Delete'
				when 4 then 'Update'
			end
		) 
	as 'Action'
--20130218, anthony, BARUS12010, begin
--20130220, anthony, BARUS12010, begin
	--, f.NoNPWPKK, f.NamaNPWPKK, f.KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	, f.NoNPWPKK, f.NamaNPWPKK, isnull(knp.Value, '') KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	--, f.AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
	, isnull(anp.Value, '') AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
--20130220, anthony, BARUS12010, end
--20130218, anthony, BARUS12010, end
--20130710, liliana, BAFEM12011, begin
	, cl.ChannelDesc as TransactionChannel
--20130710, liliana, BAFEM12011, end
into #tempReport
from dbo.ReksaBooking_TM a
	join dbo.ReksaProduct_TM c 
	on a.ProdId = c.ProdId
--20130710, liliana, BAFEM12011, begin
	join dbo.ReksaChannelList_TM cl
	on cl.ChannelCode = a.Channel
--20130710, liliana, BAFEM12011, end	
	join dbo.ReksaAgent_TR d
	on a.AgentId = d.AgentId
	join dbo.user_nisp_v e
	on a.UserSuid = e.nik
	left join EmployeePeopleSoft ps
	on ps.EmployeeId = a.Seller
--20120217, liliana, BAALN11008, begin	
	--left join dbo.ReksaCIFConfirmAddr_TM rc
	--on convert(bigint,rc.CIFNo) =  convert(bigint,a.CIFNo)
--20120217, liliana, BAALN11008, end
--20120220, liliana, BAALN11008, begin	
	left join dbo.ReksaCIFConfirmAddr_TM rc
	on rc.Id = a.BookingId
	and rc.DataType = 0
--20120220, liliana, BAALN11008, end	
--20130218, anthony, BARUS12010, begin
--20130710, liliana, BAFEM12011, begin
--join dbo.ReksaBookingNPWP_TR f
left join dbo.ReksaBookingNPWP_TR f
--20130710, liliana, BAFEM12011, end
on a.BookingId = f.BookingId
--20130218, anthony, BARUS12010, end
--20130220, anthony, BARUS12010, begin
--20130305, anthony, BARUS12010, begin
--left join dbo.ReksaGlobalParam_TT knp
left join dbo.ReksaGlobalParam_TR knp
--20130305, anthony, BARUS12010, end
on f.KepemilikanNPWPKK = knp.Id
	and knp.GroupId = 'KNP'
--20130305, anthony, BARUS12010, begin
--left join dbo.ReksaGlobalParam_TT anp
left join dbo.ReksaGlobalParam_TR anp
--20130305, anthony, BARUS12010, end
on f.AlasanTanpaNPWP = anp.Id
	and anp.GroupId = 'ANP'
--20130220, anthony, BARUS12010, end
where a.CheckerSuid is null
	and a.AuthType in (1,3)
	and e.office_id_sibs = @cOfficeId

union all
--20130408, liliana, BATOY12006, begin
--select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo, c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId
select @bCheck as 'CheckB', a.BookingId, a.BookingCode, a.CIFNo, convert(varchar(50),'') as CIFName, c.ProdCode, d.AgentCode, a.NISPAccId, a.NonNISPAccId  
--20130408, liliana, BATOY12006, end
	, a.BookingAmt
	, convert(varchar(50),'') as RiskProfile
	, a.IsEmployee
--20120217, liliana, BAALN11008, begin		
	--, rc.AddressLine1 as AlamatKonfirmasi
--20120220, liliana, BAALN11008, begin		
	--, convert(varchar(200),'') as AlamatKonfirmasi
	, rc.AddressLine1 as AlamatKonfirmasi
--20120220, liliana, BAALN11008, end	
--20120217, liliana, BAALN11008, end	
	, a.Seller
	, ps.EmployeeName as NamaSeller
	,	(
			case a.AuthType
				when 1 then 'New'
				when 3 then 'Delete'
				when 4 then 'Update'
			end
		)
	as 'Action'
--20130218, anthony, BARUS12010, begin
--20130220, anthony, BARUS12010, begin
	--, f.NoNPWPKK, f.NamaNPWPKK, f.KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	, f.NoNPWPKK, f.NamaNPWPKK, isnull(knp.Value, '') KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	--, f.AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
	, isnull(anp.Value, '') AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
--20130220, anthony, BARUS12010, end
--20130218, anthony, BARUS12010, end
--20130710, liliana, BAFEM12011, begin
	, cl.ChannelDesc as TransactionChannel
--20130710, liliana, BAFEM12011, end
from dbo.ReksaBooking_TH a
	join dbo.ReksaProduct_TM c
	on a.ProdId = c.ProdId
--20130710, liliana, BAFEM12011, begin
	join dbo.ReksaChannelList_TM cl
	on cl.ChannelCode = a.Channel
--20130710, liliana, BAFEM12011, end	
	join dbo.ReksaAgent_TR d
	on a.AgentId = d.AgentId
	join dbo.user_nisp_v e
	on a.UserSuid = e.nik
	left join EmployeePeopleSoft ps
	on ps.EmployeeId = a.Seller
--20120217, liliana, BAALN11008, begin	
	--left join dbo.ReksaCIFConfirmAddr_TM rc
	--on rc.CIFNo =  a.CIFNo
--20120217, liliana, BAALN11008, end	
--20120220, liliana, BAALN11008, begin	
	left join dbo.ReksaCIFConfirmAddr_TM rc
	on rc.Id = a.BookingId
	and rc.DataType = 0
--20120220, liliana, BAALN11008, end
--20130218, anthony, BARUS12010, begin
--20130710, liliana, BAFEM12011, begin
--join dbo.ReksaBookingNPWP_TR f
left join dbo.ReksaBookingNPWP_TR f
--20130710, liliana, BAFEM12011, end
on a.BookingId = f.BookingId
--20130218, anthony, BARUS12010, end
--20130220, anthony, BARUS12010, begin
--20130305, anthony, BARUS12010, begin
--left join dbo.ReksaGlobalParam_TT knp
left join dbo.ReksaGlobalParam_TR knp
--20130305, anthony, BARUS12010, end
on f.KepemilikanNPWPKK = knp.Id
	and knp.GroupId = 'KNP'
--20130305, anthony, BARUS12010, begin
--left join dbo.ReksaGlobalParam_TT anp
left join dbo.ReksaGlobalParam_TR anp
--20130305, anthony, BARUS12010, end
on f.AlasanTanpaNPWP = anp.Id
	and anp.GroupId = 'ANP'
--20130220, anthony, BARUS12010, end
where a.CheckerSuid is null
	and a.AuthType = 4
	and e.office_id_sibs = @cOfficeId
	
--20120215, liliana, BAALN11008, begin 
--20120217, liliana, BAALN11008, end

update te
set RiskProfile =
--20130812, liliana, BAALN11010, begin 
  --  case   
	 -- when cif.CFUIC8 = 'A' then 'Conservatif'  
	 -- when cif.CFUIC8 = 'B' then 'Balance' 
	 -- when cif.CFUIC8 = 'C' then 'Growth'  
	 -- when cif.CFUIC8 = 'D' then 'Agresif'
	    
	 -- when cif.CFUIC8 is null then ''  
	 -- else ''   
	 --end
	 rd.RiskProfileDesc
--20130812, liliana, BAALN11010, end	 
--20130321, liliana, BATOY12006, begin
 , CIFName	  = cif.CFNA1
--20130321, liliana, BATOY12006, end	 
from #tempReport te
join CFMAST_v cif 
    on convert(bigint, te.CIFNo) = convert(bigint, cif.CFCIF)
--20120217, liliana, BAALN11008, begin
--20120220, liliana, BAALN11008, begin	
--update te
--set AlamatKonfirmasi = rc.AddressLine1
--from #tempReport te
--join dbo.ReksaCIFConfirmAddr_TM rc
--on  rc.CIFNo =  te.CIFNo
--20120220, liliana, BAALN11008, end	
--20120217, liliana, BAALN11008, end
--20130812, liliana, BAALN11010, begin 
join dbo.ReksaDescRiskProfile_TR rd
	on rd.RiskProfileCFMAST = cif.CFUIC8
--20130812, liliana, BAALN11010, end    

select * from #tempReport

drop table #tempReport
--20120215, liliana, BAALN11008, end

return 0
GO