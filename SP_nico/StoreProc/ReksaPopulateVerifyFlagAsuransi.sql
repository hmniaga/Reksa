
CREATE proc [dbo].[ReksaPopulateVerifyFlagAsuransi]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20131206  
 DESCRIPTION   : 
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20150326, liliana, LIBST13020, edit asuransi po new
 END REVISED 
 
 exec ReksaPopulateVerifyFlagAsuransi 10010
 
*/  
@cNik        int  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  

--20150326, liliana, LIBST13020, begin
create table #tempTampil (
	CheckB				bit,
	JenisTrx			varchar(100),
	Id					int,
	TranCode			varchar(20),
	ProcessType			varchar(50),
	ClientCode			varchar(20),
	ClientCodeSwcOut	varchar(20),
	ClientCodeSwcIn		varchar(20),
	ProductCode			varchar(20),
	ProductName			varchar(100),
	ProductCodeSwcOut	varchar(20),
	ProductNameSwcOut	varchar(100),
	ProductCodeSwcIn	varchar(20),
	ProductNameSwcIn	varchar(100),
	Currency			varchar(3),
	TranAmount			varchar(40),
	TranUnit			varchar(40),
	JangkaWaktu			int,
	JatuhTempo			varchar(40),
	FrekPendebetan		int,
	Asuransi			varchar(10),
	AutoRedemption		varchar(10),
	Inputter			varchar(50),
	UserInputName		varchar(50),
	DateInput			datetime
)

insert #tempTampil (CheckB, JenisTrx, Id, TranCode, ProcessType,
	ClientCode, ProductCode, ProductName, Currency, TranAmount,
	JangkaWaktu, JatuhTempo, FrekPendebetan, Asuransi,
	AutoRedemption, Inputter, UserInputName, DateInput			
)
--20150326, liliana, LIBST13020, end
select @bCheck as CheckB,
--20150326, liliana, LIBST13020, begin
	'SUBSRDB' as JenisTrx,
--20150326, liliana, LIBST13020, end
	rf.Id, 
	rf.TranCode, 
	case when rf.ProcessType = 'A' then 'Insert'
		 when rf.ProcessType = 'U' then 'Update'
		 when rf.ProcessType = 'D' then 'Delete'
	end as ProcessType,
	rc.ClientCode,
	rp.ProdCode as ProductCode,
	rp.ProdName as ProductName,
	tt.TranCCY as Currency,
	convert(varchar(40),cast(tt.TranAmt as money),1) as TranAmount,
	tt.JangkaWaktu,
	convert(varchar(40),tt.JatuhTempo,11) as JatuhTempo,
	tt.FrekPendebetan,	
	case when rf.Asuransi = 1 then 'Yes' 
		else 'No' end as Asuransi,
	case when rf.AutoRedemption = 1 then 'Yes'
		else 'No' end as AutoRedemption,
	rf.Inputter, 
	us.fullname as UserInputName,
	rf.DateInput
from dbo.ReksaMaintainTrx_TT rf
	join dbo.ReksaTransaction_TT tt
		on tt.TranCode = rf.TranCode
		and tt.TranType = 8
		and tt.CheckerSuid != 777
	join dbo.ReksaCIFData_TM rc
		on tt.ClientId = rc.ClientId
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = tt.ProdId
	join dbo.user_nisp_v us
		on us.nik = rf.Inputter
where rf.StatusOtor = 0
--20150326, liliana, LIBST13020, begin
	  and rf.TranType = 'SUBSRDB'
--20150326, liliana, LIBST13020, end
union all
select @bCheck as CheckB,
--20150326, liliana, LIBST13020, begin
	'SUBSRDB' as JenisTrx,
--20150326, liliana, LIBST13020, end
	rf.Id, 
	rf.TranCode, 
	case when rf.ProcessType = 'A' then 'Insert'
		 when rf.ProcessType = 'U' then 'Update'
		 when rf.ProcessType = 'D' then 'Delete'
	end as ProcessType,
	rc.ClientCode,
	rp.ProdCode as ProductCode,
	rp.ProdName as ProductName,
	tt.TranCCY as Currency,
	convert(varchar(40),cast(tt.TranAmt as money),1) as TranAmount,
	tt.JangkaWaktu,
	convert(varchar(40),tt.JatuhTempo,11) as JatuhTempo,
	tt.FrekPendebetan,	
	case when rf.Asuransi = 1 then 'Yes' 
		else 'No' end as Asuransi,
	case when rf.AutoRedemption = 1 then 'Yes'
		else 'No' end as AutoRedemption,
	rf.Inputter, 
	us.fullname as UserInputName,
	rf.DateInput
from dbo.ReksaMaintainTrx_TT rf
	join dbo.ReksaTransaction_TH tt
		on tt.TranCode = rf.TranCode
		and tt.TranType = 8
		and tt.CheckerSuid != 777
	join dbo.ReksaCIFData_TM rc
		on tt.ClientId = rc.ClientId
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = tt.ProdId
	join dbo.user_nisp_v us
		on us.nik = rf.Inputter
where rf.StatusOtor = 0
--20150326, liliana, LIBST13020, begin
	  and rf.TranType = 'SUBSRDB'

insert #tempTampil (CheckB, JenisTrx, Id, TranCode, ProcessType,
	ClientCodeSwcOut, ClientCodeSwcIn, ProductCodeSwcOut, ProductNameSwcOut, 
	ProductCodeSwcIn, ProductNameSwcIn, Currency, TranUnit,
	JangkaWaktu, JatuhTempo, FrekPendebetan, Asuransi,
	AutoRedemption, Inputter, UserInputName, DateInput			
)
select @bCheck as CheckB,
	'SWCRDB' as JenisTrx,
	rf.Id, 
	rf.TranCode, 
	case when rf.ProcessType = 'A' then 'Insert'
		 when rf.ProcessType = 'U' then 'Update'
		 when rf.ProcessType = 'D' then 'Delete'
	end as ProcessType,
	rc.ClientCode,
	rc1.ClientCode,
	rp.ProdCode,
	rp.ProdName,
	rp1.ProdCode,
	rp1.ProdName,
	tt.TranCCY as Currency,
	convert(varchar(40),cast(tt.TranUnit as money),1),
	tt.JangkaWaktu,
	convert(varchar(40),tt.JatuhTempo,11) as JatuhTempo,
	tt.FrekPendebetan,	
	case when rf.Asuransi = 1 then 'Yes' 
		else 'No' end as Asuransi,
	case when rf.AutoRedemption = 1 then 'Yes'
		else 'No' end as AutoRedemption,
	rf.Inputter, 
	us.fullname as UserInputName,
	rf.DateInput
from dbo.ReksaMaintainTrx_TT rf
	join dbo.ReksaSwitchingTransaction_TM tt
		on tt.TranCode = rf.TranCode
		and tt.TranType = 9
	join dbo.ReksaCIFData_TM rc
		on tt.ClientIdSwcOut = rc.ClientId
	join dbo.ReksaCIFData_TM rc1
		on tt.ClientIdSwcIn = rc1.ClientId		
	join dbo.ReksaProduct_TM rp
		on rp.ProdId = tt.ProdSwitchOut
	join dbo.ReksaProduct_TM rp1
		on rp1.ProdId = tt.ProdSwitchIn		
	join dbo.user_nisp_v us
		on us.nik = rf.Inputter
where rf.StatusOtor = 0
	  and rf.TranType = 'SWCRDB'


select *
from #tempTampil

drop table #tempTampil 

--20150326, liliana, LIBST13020, end
  
return 0
GO