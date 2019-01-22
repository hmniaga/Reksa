CREATE proc [dbo].[ReksaSrcTransaksiRefID]
/*
    CREATED BY    : liliana
    CREATION DATE : 20141108
    DESCRIPTION   : Seacrh transaksi berdasarkan REF ID (grouping transaksi)
    REVISED BY    :
        DATE,   USER,       PROJECT,    NOTE
        -----------------------------------------------------------------------
        20150420, liliana, LIBST13020, tambah length
        20150608, liliana, LIBST13020, tambah kriteria
        20150715, liliana, LIBST13020, tampilkan semua jika cif kosong
        20151104, liliana, LIBST13020, SRDB
    END REVISED
*/

--20150420, liliana, LIBST13020, begin
--@cCol1                varchar(10)=null,
--@cCol2                varchar(40)=null,
@cCol1              varchar(50)=null,
@cCol2              varchar(100)=null,
--20150420, liliana, LIBST13020, end
@bValidate          bit=0,
@cCriteria          varchar(100)    = '@cCriteria'
as

set nocount on

declare @cErrMsg        varchar(100)
    , @nOK              int
    , @nErrNo           int
    , @nTranType        int
--20150608, liliana, LIBST13020, begin
    , @cCIFNo           varchar(20)
--20150608, liliana, LIBST13020, end

if @cCriteria = '@cCriteria'
set @cCriteria = null

if @cCol1='' select @cCol1=null
if @cCol2='' select @cCol2=null
--20150608, liliana, LIBST13020, begin

if(@cCriteria != '@cCriteria')
begin
    declare @tmpsplit table (    
     num int,    
     value varchar(100)    
    )

     insert into @tmpsplit (num, value)    
     select * from dbo.Split(@cCriteria, '#', 0, len(@cCriteria))    
     select @cCriteria = value from @tmpsplit where num = 1  
     select @cCIFNo = value from @tmpsplit where num = 2 
--20150715, liliana, LIBST13020, begin
     
     if @cCIFNo = ''
     begin
        set @cCIFNo = null
    end
--20150715, liliana, LIBST13020, end        
end
--20150608, liliana, LIBST13020, end

if @bValidate = 1
Begin
    if @cCriteria in ('SUBS')
    begin
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end        
        from dbo.ReksaTransaction_TT tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (1,2)
            and isnull(tt.ExtStatus, 0) not in (10, 20)
            and tt.RefID = @cCol1
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
        union all
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
        from dbo.ReksaTransaction_TH tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (1,2)
            and isnull(tt.ExtStatus, 0) not in (10, 20)
            and tt.RefID = @cCol1   
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end            
    end
    else if @cCriteria in ('REDEMP')
    begin
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
        from dbo.ReksaTransaction_TT tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (3,4)
            and isnull(tt.ExtStatus, 0) not in (10, 20)
            and tt.RefID = @cCol1
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end            
        union all
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
        from dbo.ReksaTransaction_TH tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (3,4)
            and isnull(tt.ExtStatus, 0) not in (10, 20)
            and tt.RefID = @cCol1   
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end            
    end
    else if @cCriteria in ('SUBSRDB')
    begin
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
        from dbo.ReksaTransaction_TT tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (8)
            and tt.RefID = @cCol1
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end             
        union all
--20150608, liliana, LIBST13020, begin  
        --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
        select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
        from dbo.ReksaTransaction_TH tt
        join dbo.ReksaCIFData_TM rc
            on tt.ClientId = rc.ClientId
        where tt.TranType in (8)
            and tt.RefID = @cCol1   
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
			and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end            
    end 
End
else
begin
    if @cCriteria in ('SUBS')
    begin
        if @cCol1 is not null and @cCol2 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                        
        end
        else if @cCol2 is not null and @cCol1 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin              
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
        end
        else if @cCol2 is not null and @cCol1 is not null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                    
        end
        else
        Begin
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end            
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (1,2)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
        End
    end
    else if @cCriteria in ('REDEMP')
    begin
        if @cCol1 is not null and @cCol2 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'    
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
            --and rc.CIFNo = @cCIFNo
            and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                    
        end
        else if @cCol2 is not null and @cCol1 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end            
        end
        else if @cCol2 is not null and @cCol1 is not null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'    
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
        end
        else
        Begin
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
            union all
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (3,4)
                and isnull(tt.ExtStatus, 0) not in (10, 20)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end                
        End 
    end 
    else if @cCriteria in ('SUBSRDB')
    begin
        if @cCol1 is not null and @cCol2 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                    
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'    
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                        
        end
        else if @cCol2 is not null and @cCol1 is null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
--20150608, liliana, LIBST13020, begin
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                    
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
--20150608, liliana, LIBST13020, begin
                --and rc.CIFName like '%' + @cCol2 + '%'
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                 
        end
        else if @cCol2 is not null and @cCol1 is not null
        Begin
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                 
            union all
--20150608, liliana, LIBST13020, begin  
            --select distinct tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
                and tt.RefID like rtrim(ltrim(@cCol1)) + '%'    
--20150608, liliana, LIBST13020, begin
                and convert(varchar(25), tt.TranDate, 105) like '%' + @cCol2 + '%'
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                 
        end
        else
        Begin
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TT tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end 
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end            
            union all
--20150608, liliana, LIBST13020, begin      
            --select distinct top 100 tt.RefID, + rc.CIFNo + ' - ' + rc.CIFName as [Description]
            select distinct top 100 tt.RefID,  convert(varchar(25), tt.TranDate, 105) as [TanggalTransaksi]
--20150608, liliana, LIBST13020, end
            from dbo.ReksaTransaction_TH tt
            join dbo.ReksaCIFData_TM rc
                on tt.ClientId = rc.ClientId
            where tt.TranType in (8)
--20150608, liliana, LIBST13020, begin
--20150715, liliana, LIBST13020, begin
                --and rc.CIFNo = @cCIFNo
                and rc.CIFNo = isnull(@cCIFNo, rc.CIFNo)
--20150715, liliana, LIBST13020, end
--20150608, liliana, LIBST13020, end
--20151104, liliana, LIBST13020, begin
				and isnull(tt.ExtStatus, 0) not in (10, 20)
--20151104, liliana, LIBST13020, end                
        End
    
    end
end

return 0

ERROR:
if isnull(@cErrMsg ,'') = ''
    set @cErrMsg = 'Error !'

--exec @nOK = set_raiserror @@procid, @nErrNo output  
--if @nOK != 0 return 1  
  
raiserror (@cErrMsg,16,1)
return 1
GO