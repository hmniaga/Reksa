CREATE proc [dbo].[ReksaSrcTrxClientNew]  
/*  
    CREATED BY    : LILIANA  
    CREATION DATE :   
    DESCRIPTION   : Search client reksadana by cif + product code  
    REVISED BY    :  
        DATE,   USER,       PROJECT,    NOTE  
        -----------------------------------------------------------------------  
        20150626, liliana, LIBST13020, tambah untuk redemp  
        20160830, liliana, LOGEN00196, tax amnesty  
    END REVISED  
  
*/  
  
@cCol1      varchar(12)=null,  
@cCol2      varchar(40)=null,  
@bValidate  bit=0,  
@cCriteria  varchar(200) = '@cCriteria'  
as  
  
set nocount on  
  
declare @cErrMsg        varchar(100)  
    , @nOK              int  
    , @nErrNo           int  
    , @cProdCode        varchar(20)  
    , @nProdId          int  
    , @cCIF             varchar(20)  
    , @nReksaTranType   varchar(20)  
--20160830, liliana, LOGEN00196, begin  
 , @bIsTaxAmnesty varchar(10)  
--20160830, liliana, LOGEN00196, end      
  
if @cCol1='' select @cCol1=null  
if @cCol2='' select @cCol2=null  
  
if(@cCriteria != '@cCriteria')  
begin  
    declare @tmpsplit table (      
     num int,      
     value varchar(100)      
    )  
  
     insert into @tmpsplit (num, value)      
     select * from dbo.Split(@cCriteria, '#', 0, len(@cCriteria))      
     select @cCIF = value from @tmpsplit where num = 1    
     select @cProdCode = value from @tmpsplit where num = 2     
     select @nReksaTranType = value from @tmpsplit where num = 3  
--20160830, liliana, LOGEN00196, begin  
  select @bIsTaxAmnesty = value from @tmpsplit where num = 4   
--20160830, liliana, LOGEN00196, end           
       
     select @nProdId = ProdId        
     from dbo.ReksaProduct_TM        
     where ProdCode = @cProdCode    
      
end  
  
--20160830, liliana, LOGEN00196, begin  
if (@bIsTaxAmnesty = '1')  
begin  
 if @bValidate = 1  
 Begin  
  if(@nReksaTranType in ('SUBS'))  
  begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee   
    , 'N' as IsRDB               
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
    on rc.ClientId = rg.ClientId  
    where rc.ClientCode = @cCol1  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and isnull(rc.Flag,0) != 1  
     and rg.ClientId is null  
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
  end   
  else if(@nReksaTranType in ('SWCNONRDB'))  
  begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee    
    , 'N' as IsRDB                  
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
    where rc.ClientCode = @cCol1  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.ClientId is null  
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
  end  
  else if(@nReksaTranType in ('SUBSRDB', 'SWCRDB'))  
  begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee       
    , 'Y' as IsRDB               
    from dbo.ReksaCIFData_TM rc  
    join dbo.ReksaRegulerSubscriptionClient_TM rg  
    on rc.ClientId = rg.ClientId  
    where rc.ClientCode = @cCol1  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.Status = 1  
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
  end   
  else   
  begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee      
    , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
    on rc.ClientId = rg.ClientId  
    where rc.ClientCode = @cCol1  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'     
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)                
  end  
 End  
 else  
 begin  
  if(@nReksaTranType in ('SUBS'))  
  begin  
   if @cCol1 is not null and @cCol2 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee  
     , 'N' as IsRDB                       
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'  
      and isnull(rc.Flag,0) != 1  
      and rg.ClientId is null  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode    
    End  
    else if @cCol2 is not null and @cCol1 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee  
     , 'N' as IsRDB                                     
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'  
      and isnull(rc.Flag,0) != 1  
      and rg.ClientId is null  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode    
    End  
    else if @cCol2 is not null and @cCol1 is not null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , 'N' as IsRDB                         
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'  
      and isnull(rc.Flag,0) != 1  
      and rg.ClientId is null  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode  
    End  
    else  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee     
     , 'N' as IsRDB                     
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFStatus = 'A'  
      and rc.CIFNo = @cCIF  
      and isnull(rc.Flag,0) != 1  
      and rg.ClientId is null  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode  
    End  
           
  end  
  else if(@nReksaTranType in ('SWCNONRDB'))  
  begin     
   if @cCol1 is not null and @cCol2 is null  
   Begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee  
    , 'N' as IsRDB                        
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
    where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.ClientId is null  
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
   End  
   else if @cCol2 is not null and @cCol1 is null  
   Begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee   
    , 'N' as IsRDB               
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
    where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.ClientId is null   
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
   End  
   else if @cCol2 is not null and @cCol1 is not null  
   Begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee   
    , 'N' as IsRDB                     
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
    where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
     and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
     and rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.ClientId is null   
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
   End  
   else  
   Begin  
    select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
    , rc.JoinDate, rc.IsEmployee  
    , 'N' as IsRDB                        
    from dbo.ReksaCIFData_TM rc  
    left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
    where rc.ProdId = isnull(@nProdId, rc.ProdId)  
     and rc.CIFNo = @cCIF  
     and rc.CIFStatus = 'A'  
     and rg.ClientId is null   
     and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
   End  
  end   
  else if(@nReksaTranType in ('SUBSRDB', 'SWCRDB'))  
  begin  
   if @cCol1 is not null and @cCol2 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , 'Y' as IsRDB                            
     from dbo.ReksaCIFData_TM rc  
     join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFStatus = 'A'  
      and rc.CIFNo = @cCIF  
      and rg.Status = 1  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode    
    End  
    else if @cCol2 is not null and @cCol1 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee    
     , 'Y' as IsRDB                                  
     from dbo.ReksaCIFData_TM rc  
     join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFStatus = 'A'  
      and rc.CIFNo = @cCIF  
      and rg.Status = 1  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode    
    End  
    else if @cCol2 is not null and @cCol1 is not null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee   
     , 'Y' as IsRDB                       
     from dbo.ReksaCIFData_TM rc  
     join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFStatus = 'A'  
      and rc.CIFNo = @cCIF  
      and rg.Status = 1  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode  
    End  
    else  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee     
     , 'Y' as IsRDB                                
     from dbo.ReksaCIFData_TM rc  
     join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFStatus = 'A'  
      and rc.CIFNo = @cCIF  
      and rg.Status = 1  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)  
     order by rc.ClientCode  
    End  
           
  end  
  else   
  begin  
    if @cCol1 is not null and @cCol2 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)            
     order by rc.ClientCode  
    End  
    else if @cCol2 is not null and @cCol1 is null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'       
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)       
     order by rc.ClientCode  
    End  
    else if @cCol2 is not null and @cCol1 is not null  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
      and rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
      and rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'  
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)            
     order by rc.ClientCode  
    End  
    else  
    Begin  
     select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
     , rc.JoinDate, rc.IsEmployee      
     , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
     from dbo.ReksaCIFData_TM rc  
     left join dbo.ReksaRegulerSubscriptionClient_TM rg  
     on rc.ClientId = rg.ClientId  
     where rc.ProdId = isnull(@nProdId, rc.ProdId)  
      and rc.CIFNo = @cCIF  
      and rc.CIFStatus = 'A'    
      and rc.ClientId in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)          
     order by rc.ClientCode  
    End                      
  end  
 end  
  
end  
else  
begin  
--20160830, liliana, LOGEN00196, end    
if @bValidate = 1  
Begin  
    if(@nReksaTranType in ('SUBS'))  
    begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                  
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
            on rc.ClientId = rg.ClientId  
            where rc.ClientCode = @cCol1  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and isnull(rc.Flag,0) != 1  
                and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
    end   
    else if(@nReksaTranType in ('SWCNONRDB'))  
    begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                      
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
            where rc.ClientCode = @cCol1  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
    end  
    else if(@nReksaTranType in ('SUBSRDB', 'SWCRDB'))  
    begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee          
--20150626, liliana, LIBST13020, begin  
            , 'Y' as IsRDB  
--20150626, liliana, LIBST13020, end                  
            from dbo.ReksaCIFData_TM rc  
            join dbo.ReksaRegulerSubscriptionClient_TM rg  
            on rc.ClientId = rg.ClientId  
            where rc.ClientCode = @cCol1  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.Status = 1  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
    end   
    else   
    begin  
--20150626, liliana, LIBST13020, begin  
            --select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo  
            --, JoinDate, IsEmployee              
            --from dbo.ReksaCIFData_TM with (nolock)  
            --where ClientCode = @cCol1  
            --  and ProdId = isnull(@nProdId,ProdId)  
            --  and CIFNo = @cCIF  
            --  and CIFStatus = 'A'  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee      
            , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
            on rc.ClientId = rg.ClientId  
            where rc.ClientCode = @cCol1  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
--20150626, liliana, LIBST13020, end  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
    end  
End  
else  
begin  
    if(@nReksaTranType in ('SUBS'))  
    begin  
   if @cCol1 is not null and @cCol2 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee  
--20150626, liliana, LIBST13020, begin  
                , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                          
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'  
                    and isnull(rc.Flag,0) != 1  
                    and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode    
            End  
            else if @cCol2 is not null and @cCol1 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee  
--20150626, liliana, LIBST13020, begin  
                , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                                      
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'  
                    and isnull(rc.Flag,0) != 1  
                    and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode    
            End  
            else if @cCol2 is not null and @cCol1 is not null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                          
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'  
                    and isnull(rc.Flag,0) != 1  
                    and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode  
            End  
            else  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                          
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFStatus = 'A'  
                    and rc.CIFNo = @cCIF  
                    and isnull(rc.Flag,0) != 1  
                    and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode  
            End  
          
    end  
    else if(@nReksaTranType in ('SWCNONRDB'))  
    begin     
        if @cCol1 is not null and @cCol2 is null  
        Begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee  
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                          
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
            where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
        End  
        else if @cCol2 is not null and @cCol1 is null  
        Begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee          
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                  
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
            where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
        End  
        else if @cCol2 is not null and @cCol1 is not null  
        Begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                      
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
            where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.ClientId is null  
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                    
        End  
        else  
        Begin  
            select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
            , rc.JoinDate, rc.IsEmployee  
--20150626, liliana, LIBST13020, begin  
            , 'N' as IsRDB  
--20150626, liliana, LIBST13020, end                          
            from dbo.ReksaCIFData_TM rc  
            left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
            where rc.ProdId = isnull(@nProdId, rc.ProdId)  
                and rc.CIFNo = @cCIF  
                and rc.CIFStatus = 'A'  
                and rg.ClientId is null   
--20160830, liliana, LOGEN00196, begin  
    and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                   
        End  
    end   
    else if(@nReksaTranType in ('SUBSRDB', 'SWCRDB'))  
    begin  
        if @cCol1 is not null and @cCol2 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'Y' as IsRDB  
--20150626, liliana, LIBST13020, end                              
                from dbo.ReksaCIFData_TM rc  
                join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFStatus = 'A'  
                    and rc.CIFNo = @cCIF  
                    and rg.Status = 1  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                       
                order by rc.ClientCode    
            End  
            else if @cCol2 is not null and @cCol1 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'Y' as IsRDB  
--20150626, liliana, LIBST13020, end                                  
                from dbo.ReksaCIFData_TM rc  
                join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFStatus = 'A'  
                    and rc.CIFNo = @cCIF  
                    and rg.Status = 1  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode    
            End  
            else if @cCol2 is not null and @cCol1 is not null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'Y' as IsRDB  
--20150626, liliana, LIBST13020, end                              
                from dbo.ReksaCIFData_TM rc  
                join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFStatus = 'A'  
                    and rc.CIFNo = @cCIF  
                    and rg.Status = 1  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode  
            End  
            else  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
--20150626, liliana, LIBST13020, begin  
                , 'Y' as IsRDB  
--20150626, liliana, LIBST13020, end                                  
    from dbo.ReksaCIFData_TM rc  
                join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFStatus = 'A'  
                    and rc.CIFNo = @cCIF  
                    and rg.Status = 1  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                        
                order by rc.ClientCode  
            End  
          
    end  
    else   
    begin  
--20150626, liliana, LIBST13020, begin    
            --if @cCol1 is not null and @cCol2 is null  
            --Begin  
            --  select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo  
            --  , JoinDate, IsEmployee            
            --  from ReksaCIFData_TM with (nolock)  
            --  where  ClientCode like rtrim(ltrim(@cCol1)) + '%'  
            --      and ProdId = isnull(@nProdId,ProdId)  
            --      and CIFStatus = 'A'  
            --      and CIFNo = @cCIF  
            --  order by ClientCode  
            --End  
            --else if @cCol2 is not null and @cCol1 is null  
            --Begin  
            --  select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo  
            --  , JoinDate, IsEmployee                        
            --  from ReksaCIFData_TM with (nolock)  
            --  where  CIFName like rtrim(ltrim(@cCol2)) + '%'  
            --      and ProdId = isnull(@nProdId,ProdId)  
            --      and CIFStatus = 'A'  
            --      and CIFNo = @cCIF  
            --  order by ClientCode  
            --End  
            --else if @cCol2 is not null and @cCol1 is not null  
            --Begin  
            --  select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo  
            --  , JoinDate, IsEmployee                        
            --  from ReksaCIFData_TM with (nolock)  
            --  where  ClientCode like rtrim(ltrim(@cCol1)) + '%'  
            --      and CIFName like rtrim(ltrim(@cCol2)) + '%'  
            --      and ProdId = isnull(@nProdId,ProdId)  
            --      and CIFStatus = 'A'  
            --      and CIFNo = @cCIF  
            --  order by ClientCode  
            --End  
            --else  
            --Begin  
            --  select ClientCode, left(CIFName + ' - '+ CIFAddress1, 40), ClientId, CIFNo  
            --  , JoinDate, IsEmployee                        
            --  from ReksaCIFData_TM with (nolock)  
            --      where ProdId = isnull(@nProdId,ProdId)  
            --      and CIFStatus = 'A'  
            --      and CIFNo = @cCIF  
            --  order by ClientCode  
            --End  
            if @cCol1 is not null and @cCol2 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
                , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                                  
                order by rc.ClientCode  
            End  
            else if @cCol2 is not null and @cCol1 is null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
                , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'       
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                             
                order by rc.ClientCode  
            End  
            else if @cCol2 is not null and @cCol1 is not null  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
                , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.CIFName like rtrim(ltrim(@cCol2)) + '%'  
                    and rc.ClientCode like rtrim(ltrim(@cCol1)) + '%'  
                    and rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'    
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                                
                order by rc.ClientCode  
            End  
            else  
            Begin  
                select rc.ClientCode, left(rc.CIFName + ' - '+ rc.CIFAddress1, 40), rc.ClientId, rc.CIFNo  
                , rc.JoinDate, rc.IsEmployee      
                , case when rg.ClientId is not null then 'Y' else 'N' end as IsRDB            
                from dbo.ReksaCIFData_TM rc  
                left join dbo.ReksaRegulerSubscriptionClient_TM rg  
                on rc.ClientId = rg.ClientId  
                where rc.ProdId = isnull(@nProdId, rc.ProdId)  
                    and rc.CIFNo = @cCIF  
                    and rc.CIFStatus = 'A'  
--20160830, liliana, LOGEN00196, begin  
     and rc.ClientId not in (select ClientIdTax from dbo.ReksaClientCodeTAMapping_TM where IsTaxAmnesty = 1)           
--20160830, liliana, LOGEN00196, end                                  
                order by rc.ClientCode  
            End           
--20150626, liliana, LIBST13020, end              
    end  
end  
--20160830, liliana, LOGEN00196, begin  
end  
--20160830, liliana, LOGEN00196, end  
  
return 0  
  
ERROR:  
if isnull(@cErrMsg ,'') = ''  
    set @cErrMsg = 'Error !'  
  
--exec @nOK = set_raiserror @@procid, @nErrNo output    
--if @nOK != 0 return 1    
    
raiserror (@cErrMsg  ,16,1)
return 1
GO