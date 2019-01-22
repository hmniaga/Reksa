CREATE proc [dbo].[ReksaPopulateVerifyNewAccount]
/*

	CREATED BY    : nico
	CREATION DATE : 20071031
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20071128, victor, REKSADN002, tambah filter cabang
		20071218, indra_w, REKSADN002, tambah field action (new / update / delete)
		20120202, liliana, BAALN11008, tambah kolom Risk Profile Nasabah, NPWP, Alamat Konfirmasi yang dicheck
		20120202, liliana, BAALN11008, fix
		20120202, liliana, BAALN11008, Ganti jadi Yes/No
		20120411, liliana, BAALN11026, alamat konfirmasi
		20120627, liliana, BAALN12010, nambah kolom shareholder id yg ada disebelah kanannya CIFNO
		20130218, anthony, BARUS12010, tambah kolom npwp
		20130220, anthony, BARUS12010, edit keterangan
		20130305, anthony, BARUS12010, fcd
		20130612, anthony, LOGAM05399, fixbug
		20130618, liliana, BAFEM12011, pindah posisi >:(
		20130812, liliana, BAALN11010, ganti desc risk profile
		20141212, dhanan, LOGAM06451, update alamat konfirmasi jika ada perubahan
		
	END REVISED

*/
@cNik		int
as
declare
	@bBol bit
--20071128, victor, REKSADN002, begin
	,@cOfficeId						varchar(5)

select @cOfficeId = office_id_sibs
from dbo.user_nisp_v
where nik = @cNik
--20071128, victor, REKSADN002, end

select @bBol =0
--20120627, liliana, BAALN12010, begin
--select @bBol as 'CheckB' ,a.ClientId , a.ClientCode ,a.CIFNo ,a.CIFName  , b.ProdCode , c.AgentCode ,a.NISPAccId ,a.NonNISPAccId 
select @bBol as 'CheckB' ,a.ClientId , a.ClientCode ,a.CIFNo, a.ShareholderID
,a.CIFName  , b.ProdCode , c.AgentCode ,a.NISPAccId ,a.NonNISPAccId 
--20120627, liliana, BAALN12010, end
--20071218, indra_w, REKSADN002, begin
--20120202, liliana, BAALN11008, begin
	, convert(varchar(50),'') as RiskProfileNasabah
	, convert(varchar(50),'') as NPWP
	, convert(varchar(200),'') as AlamatKonfirmasi
--20120202, liliana, BAALN11008, begin	
	--, case when a.IsEmployee = 1 then 'Y'
	--	   when a.IsEmployee = 0 then 'N' end as IsEmployee
		, case when a.IsEmployee = 1 then 'Yes'
		   when a.IsEmployee = 0 then 'No' end as IsEmployee
--20120202, liliana, BAALN11008, end		   
--20120202, liliana, BAALN11008, end
	,
	( 
		case a.AuthType
			when 1 then 'New'
			when 3 then 'Delete'
			when 4 then 'Update'
		end
	) as 'Action'
--20071218, indra_w, REKSADN002, end
--20120202, liliana, BAALN11008, begin
--20130218, anthony, BARUS12010, begin
--20130220, anthony, BARUS12010, begin
	--, f.NoNPWPKK, f.NamaNPWPKK, f.KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	, f.NoNPWPKK, f.NamaNPWPKK, isnull(knp.Value, '') KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	--, f.AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
	, isnull(anp.Value, '') AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
--20130220, anthony, BARUS12010, end
--20130218, anthony, BARUS12010, end
into #temp
--20120202, liliana, BAALN11008, end
from dbo.ReksaCIFData_TM a join ReksaProduct_TM b
on a.ProdId = b.ProdId
join ReksaAgent_TR c
on a.AgentId =c.AgentId
--20071128, victor, REKSADN002, begin
join dbo.user_nisp_v d
on a.UserSuid = d.nik
--20071128, victor, REKSADN002, end
--20130218, anthony, BARUS12010, begin
--20130612, anthony, LOGAM05399, begin
--join dbo.ReksaCIFDataNPWP_TR f
left join dbo.ReksaCIFDataNPWP_TR f
--20130612, anthony, LOGAM05399, end
on a.ClientId = f.ClientId
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
where CheckerSuid is null
and a.AuthType in (1,3)
--20071128, victor, REKSADN002, begin
and d.office_id_sibs = @cOfficeId
--20071128, victor, REKSADN002, end
union all
--20120627, liliana, BAALN12010, begin
--select @bBol as 'CheckB' ,a.ClientId , b.ClientCode ,b.CIFNo ,a.CIFName  , c.ProdCode , d.AgentCode ,a.NISPAccId ,a.NonNISPAccId 
select @bBol as 'CheckB' ,a.ClientId , b.ClientCode ,b.CIFNo, b.ShareholderID
,a.CIFName  , c.ProdCode , d.AgentCode ,a.NISPAccId ,a.NonNISPAccId 
--20120627, liliana, BAALN12010, end
--20071218, indra_w, REKSADN002, begin
--20120202, liliana, BAALN11008, begin
	, convert(varchar(50),'') as RiskProfileNasabah
	, convert(varchar(50),'') as NPWP
	, convert(varchar(200),'') as AlamatKonfirmasi
--20120202, liliana, BAALN11008, begin		
	--, case when a.IsEmployee = 1 then 'Y'
	--	   when a.IsEmployee = 0 then 'N' end as IsEmployee
	, case when a.IsEmployee = 1 then 'Yes'
		   when a.IsEmployee = 0 then 'No' end as IsEmployee	
--20120202, liliana, BAALN11008, end
--20120202, liliana, BAALN11008, end
	,
	( 
		case a.AuthType
			when 1 then 'New'
			when 3 then 'Delete'
			when 4 then 'Update'
		end
	) as 'Action'
--20071218, indra_w, REKSADN002, end
--20130218, anthony, BARUS12010, begin
--20130220, anthony, BARUS12010, begin
	--, f.NoNPWPKK, f.NamaNPWPKK, f.KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	, f.NoNPWPKK, f.NamaNPWPKK, isnull(knp.Value, '') KepemilikanNPWPKK, f.KepemilikanNPWPKKLainnya, f.TglNPWPKK
	--, f.AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
	, isnull(anp.Value, '') AlasanTanpaNPWP, f.NoDokTanpaNPWP, f.TglDokTanpaNPWP
--20130220, anthony, BARUS12010, end
--20130218, anthony, BARUS12010, end
from dbo.ReksaCIFData_TH a join  dbo.ReksaCIFData_TM b
	on a.ClientId = b.ClientId
join ReksaProduct_TM c
on b.ProdId = c.ProdId
join ReksaAgent_TR d
on a.AgentId =d.AgentId
--20071128, victor, REKSADN002, begin
join dbo.user_nisp_v e
on a.UserSuid = e.nik
--20071128, victor, REKSADN002, end
--20130218, anthony, BARUS12010, begin
--20130612, anthony, LOGAM05399, begin
--join dbo.ReksaCIFDataNPWP_TR f
left join dbo.ReksaCIFDataNPWP_TR f
--20130612, anthony, LOGAM05399, end
on b.ClientId = f.ClientId
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
--20071128, victor, REKSADN002, begin
and e.office_id_sibs = @cOfficeId
--20071128, victor, REKSADN002, end
--20120202, liliana, BAALN11008, begin

update te
set NPWP = cf.CFSSNO
from #temp  te
join dbo.CFAIDN cf
on convert(bigint,te.CIFNo) = convert(bigint,cf.CFCIF#)
where cf.CFSSCD = 'NPWP'

update te
set NPWP = cf.CFSSNO
from #temp  te
join dbo.CFAIDN cf
on convert(bigint,te.CIFNo) = convert(bigint,cf.CFCIF)
where cf.CFSSCD = 'NPWP'
--20120202, liliana, BAALN11008, begin
--and te.CIFNPWP = '' 
and te.NPWP = '' 
--20120202, liliana, BAALN11008, end

update te
set RiskProfileNasabah = 
--20130812, liliana, BAALN11010, begin
  --  case   
	 -- when cif.CFUIC8 = 'A' then 'Conservatif'  
	 -- when cif.CFUIC8 = 'B' then 'Balance'   
	 -- when cif.CFUIC8 = 'C' then 'Growth'  
	 -- when cif.CFUIC8 = 'D' then 'Agresif'  
	 -- when cif.CFUIC8 is null then ''  
	 -- else ''   
	 --end
	 dr.RiskProfileDesc
--20130812, liliana, BAALN11010, end
from #temp te
join CFMAST_v cif 
    on convert(bigint, te.CIFNo) = convert(bigint, cif.CFCIF)
--20130812, liliana, BAALN11010, begin
join dbo.ReksaDescRiskProfile_TR dr
	on dr.RiskProfileCFMAST = cif.CFUIC8
--20130812, liliana, BAALN11010, end
    
update te 
set AlamatKonfirmasi = ca.AddressLine1
from #temp te
join dbo.ReksaCIFConfirmAddr_TM ca
--20120411, liliana, BAALN11026, begin
--on convert(bigint, te.CIFNo) = convert(bigint, ca.CIFNo) 
on te.ClientId = ca.Id
and ca.DataType = 1
--20120411, liliana, BAALN11026, end

update te 
set AlamatKonfirmasi = ca.AddressLine1
from #temp te
join dbo.ReksaCIFConfirmAddr_TH ca
--20120411, liliana, BAALN11026, begin
--on convert(bigint, te.CIFNo) = convert(bigint, ca.CIFNo)
on te.ClientId = ca.Id
and ca.DataType = 1
--20120411, liliana, BAALN11026, end
--20141212, dhanan, LOGAM06451, begin
--and AlamatKonfirmasi = ''
and (AlamatKonfirmasi = '' or ca.Status = 4)
--20141212, dhanan, LOGAM06451, end

--20130618, liliana, BAFEM12011, begin
--select * from #temp
select CheckB, ClientId, [Action], ClientCode, CIFNo, ShareholderID,
	CIFName, ProdCode, AgentCode, NISPAccId, NonNISPAccId,
	RiskProfileNasabah, NPWP, AlamatKonfirmasi, IsEmployee,
	NoNPWPKK, NamaNPWPKK, KepemilikanNPWPKK, KepemilikanNPWPKKLainnya, TglNPWPKK,
	AlasanTanpaNPWP, NoDokTanpaNPWP, TglDokTanpaNPWP
from #temp

--20130618, liliana, BAFEM12011, end

drop table #temp
--20120202, liliana, BAALN11008, end
GO