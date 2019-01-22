CREATE proc [dbo].[ReksaSrcSwitching]    
/*    
 CREATED BY    : liliana    
 CREATION DATE : 20111115    
 DESCRIPTION   :    
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
  20150420, liliana, LIBST13020, tambah trantype utk membedakan jenis swc
  20150413, liliana, LIBST13020, ganti by Ref ID
  20150420, liliana, LIBST13020, tambah length
  20150608, liliana, LIBST13020, tambah criteria
  20150715, liliana, LIBST13020, tampilkan semua jika cif kosong
 END REVISED    
*/    

--20150420, liliana, LIBST13020, begin  
--@cCol1  varchar(25)=null,    
--@cCol2  varchar(25)=null,    
@cCol1  varchar(50)=null,    
@cCol2  varchar(100)=null,  
--20150420, liliana, LIBST13020, end
@bValidate bit=0    
--20150608, liliana, LIBST13020, begin
,@cCriteria			varchar(100)	= '@cCriteria'
--20150608, liliana, LIBST13020, end
    
as    
    
set nocount on    
    
declare @cErrMsg   varchar(100)    
 , @nOK    int    
 , @nErrNo   int    
 

if @cCol1='' select @cCol1=null  
if @cCol2='' select @cCol2=null 
--20150715, liliana, LIBST13020, begin
	 
if @cCriteria in ('@cCriteria','')
begin
	set @cCriteria = null
end
--20150715, liliana, LIBST13020, end	   

--20150608, liliana, LIBST13020, begin  
--if @bValidate = 1  
--Begin
----20150413, liliana, LIBST13020, begin   
-- --select TranCode, TranId, TranDate
-- select RefID, TranId, TranDate 
----20150413, liliana, LIBST13020, end 
-- from dbo.ReksaSwitchingTransaction_TM with (nolock)
----20150413, liliana, LIBST13020, begin 
-- --where TranCode = @cCol1  
-- where RefID = @cCol1
----20150413, liliana, LIBST13020, end 
----20150420, liliana, LIBST13020, begin
--	and TranType in (5,6)
----20150420, liliana, LIBST13020, end 
--End  
--else  
--begin  
   
-- if @cCol1 is not null and @cCol2 is null  
-- Begin  
----20150413, liliana, LIBST13020, begin  
--	 --select top 200 TranCode, TranId, TranDate 
--	 select top 200 RefID, TranId, TranDate 
----20150413, liliana, LIBST13020, end	 
--	 from dbo.ReksaSwitchingTransaction_TM with (nolock)
----20150413, liliana, LIBST13020, begin 	 
--	 --where TranCode like rtrim(ltrim(@cCol1)) + '%'
--	 where RefID like rtrim(ltrim(@cCol1)) + '%'
----20150413, liliana, LIBST13020, end	  
----20150420, liliana, LIBST13020, begin
--		and TranType in (5,6)
----20150420, liliana, LIBST13020, end 
----20150413, liliana, LIBST13020, begin 	 	  
--	 --order by TranCode  
--	 order by RefID
----20150413, liliana, LIBST13020, end	 
-- End  
-- else if @cCol2 is not null and @cCol1 is null  
-- Begin  
----20150413, liliana, LIBST13020, begin  
--	 --select top 200 TranCode, TranId, TranDate 
--	 select top 200 RefID, TranId, TranDate 
----20150413, liliana, LIBST13020, end	
--	 from dbo.ReksaSwitchingTransaction_TM with (nolock)
----20150413, liliana, LIBST13020, begin 	 
--	 --where TranCode like rtrim(ltrim(@cCol1)) + '%'
--	 where RefID like rtrim(ltrim(@cCol1)) + '%'
----20150413, liliana, LIBST13020, end	  
----20150420, liliana, LIBST13020, begin
--		and TranType in (5,6)
----20150420, liliana, LIBST13020, end 		  
----20150413, liliana, LIBST13020, begin 	 	  
--	 --order by TranCode  
--	 order by RefID
----20150413, liliana, LIBST13020, end	   
-- End  
-- else if @cCol2 is not null and @cCol1 is not null  
-- Begin  
----20150413, liliana, LIBST13020, begin  
--	 --select top 200 TranCode, TranId, TranDate 
--	 select top 200 RefID, TranId, TranDate 
----20150413, liliana, LIBST13020, end	 
--	 from dbo.ReksaSwitchingTransaction_TM with (nolock)
----20150413, liliana, LIBST13020, begin 	 
--	 --where TranCode like rtrim(ltrim(@cCol1)) + '%'
--	 where RefID like rtrim(ltrim(@cCol1)) + '%'
----20150413, liliana, LIBST13020, end
----20150420, liliana, LIBST13020, begin
--		and TranType in (5,6)
----20150420, liliana, LIBST13020, end 	 
----20150413, liliana, LIBST13020, begin 	 	  
--	 --order by TranCode  
--	 order by RefID
----20150413, liliana, LIBST13020, end	 
-- End  
-- else  
-- Begin  
----20150413, liliana, LIBST13020, begin  
--	 --select top 200 TranCode, TranId, TranDate 
--	 select top 200 RefID, TranId, TranDate 
----20150413, liliana, LIBST13020, end
--	 from dbo.ReksaSwitchingTransaction_TM with (nolock)
----20150420, liliana, LIBST13020, begin
--	where TranType in (5,6)
----20150420, liliana, LIBST13020, end 	 
----20150413, liliana, LIBST13020, begin 	 	  
--	 --order by TranCode  
--	 order by RefID
----20150413, liliana, LIBST13020, end	  
-- End  
--end
if @bValidate = 1  
Begin
 select rs.RefID, convert(varchar(25), rs.TranDate, 105) as [TanggalTransaksi], rs.TranId
 from dbo.ReksaSwitchingTransaction_TM rs with (nolock)
 join dbo.ReksaCIFData_TM rc 
	on rc.ClientId = rs.ClientIdSwcOut
 where rs.RefID = @cCol1
	and rs.TranType in (5,6)
--20150715, liliana, LIBST13020, begin	
	--and rc.CIFNo = @cCriteria
	and rc.CIFNo = isnull(@cCriteria, rc.CIFNo)
--20150715, liliana, LIBST13020, end	
End  
else  
begin  
   
 if @cCol1 is not null and @cCol2 is null  
 Begin  
	 select top 200 rs.RefID, convert(varchar(25), rs.TranDate, 105) as [TanggalTransaksi], rs.TranId
	 from dbo.ReksaSwitchingTransaction_TM rs with (nolock)
	 join dbo.ReksaCIFData_TM rc 
		on rc.ClientId = rs.ClientIdSwcOut	 
	 where rs.RefID like rtrim(ltrim(@cCol1)) + '%'
		and rs.TranType in (5,6)
--20150715, liliana, LIBST13020, begin	
		--and rc.CIFNo = @cCriteria
		and rc.CIFNo = isnull(@cCriteria, rc.CIFNo)
--20150715, liliana, LIBST13020, end
	 order by rs.RefID	 
 End  
 else if @cCol2 is not null and @cCol1 is null  
 Begin  
	 select top 200 rs.RefID, convert(varchar(25), rs.TranDate, 105) as [TanggalTransaksi], rs.TranId
	 from dbo.ReksaSwitchingTransaction_TM rs with (nolock)
	 join dbo.ReksaCIFData_TM rc 
		on rc.ClientId = rs.ClientIdSwcOut		 
	 where convert(varchar(25), rs.TranDate, 105) like '%' + @cCol2 + '%'
		and rs.TranType in (5,6)
--20150715, liliana, LIBST13020, begin	
		--and rc.CIFNo = @cCriteria
		and rc.CIFNo = isnull(@cCriteria, rc.CIFNo)
--20150715, liliana, LIBST13020, end
	 order by rs.RefID	   
 End  
 else if @cCol2 is not null and @cCol1 is not null  
 Begin  
	 select top 200 rs.RefID, convert(varchar(25), rs.TranDate, 105) as [TanggalTransaksi], rs.TranId
	 from dbo.ReksaSwitchingTransaction_TM rs with (nolock)
	 join dbo.ReksaCIFData_TM rc 
		on rc.ClientId = rs.ClientIdSwcOut		 
	 where rs.RefID like rtrim(ltrim(@cCol1)) + '%'
		and convert(varchar(25), rs.TranDate, 105) like '%' + @cCol2 + '%'
		and rs.TranType in (5,6)
--20150715, liliana, LIBST13020, begin	
		--and rc.CIFNo = @cCriteria
		and rc.CIFNo = isnull(@cCriteria, rc.CIFNo)
--20150715, liliana, LIBST13020, end
	 order by rs.RefID	 
 End  
 else  
 Begin  
	 select top 200 rs.RefID, convert(varchar(25), rs.TranDate, 105) as [TanggalTransaksi], rs.TranId
	 from dbo.ReksaSwitchingTransaction_TM rs with (nolock)
	 join dbo.ReksaCIFData_TM rc 
		on rc.ClientId = rs.ClientIdSwcOut		 
	where rs.TranType in (5,6)
--20150715, liliana, LIBST13020, begin	
		--and rc.CIFNo = @cCriteria
		and rc.CIFNo = isnull(@cCriteria, rc.CIFNo)
--20150715, liliana, LIBST13020, end
	 order by rs.RefID	  
 End  
end

--20150608, liliana, LIBST13020, end   
    
return 0    
    
ERROR:    
if isnull(@cErrMsg ,'') = ''    
 set @cErrMsg = 'Error !'    
    
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK != 0 return 1      
      
raiserror (@cErrMsg    ,16,1);
return 1
GO