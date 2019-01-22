alter proc [dbo].[ReksaMaintainParameter]            
/*            
 CREATED BY    : 
 CREATION DATE : 
 DESCRIPTION   : Maintain Parameter2 Pro Reksa            
 REVISED BY    :            
             
 declare @nGuid uniqueidentifier            
 select @nGuid = newid()            
-- exec ReksaMaintainParameter 1, 'GFM', 'BBBOLD', 'Blackberry Bold#7000000', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 2, 'GFM', 'BBBOLD', 'Blackberry Bold Resmi#6950000', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 3, 'GFM', 'MACBOOKAIR', 'Apple MacBook Air 2.4GHz', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 1, 'GFP', 'BBBOLD', '150000000.0#6#20090101#20091231', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 2, 'GFP', 'BBBOLD', '201000000.00#8#20090330#20090630', null, 2, null, null, 32622, @nGuid            
 exec ReksaMaintainParameter 3, 'GFP', 'TESTING', '201000000.00#8#20090330#20090630', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 1, 'EVT', 'REKSASHOW', 'Road show Reksadana', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 2, 'EVT', 'REKSASHOW', 'Road show Reksadana IDR', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 3, 'EVT', 'REKSASHOW', 'Road show Reksadana IDR', null, 2, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 1, 'WPR', '33108', 'WAPERD/060/BANDUNG', null, null, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 2, 'WPR', '33108', 'WAPERD/060/1/2009', null, null, null, null, 32622, @nGuid            
-- exec ReksaMaintainParameter 3, 'WPR', '32622', 'WAPERD/060/BANDUNG', null, null, null, null, 32622, @nGuid            
 exec ReksaMaintainParameter 1, 'RSB', 'DT2', '0.5#0.5', '', 0, 0, null, 10010, null            
             
             
  DATE,  USER,   PROJECT,  NOTE            
  -----------------------------------------------------------------------            
            
 END REVISED            
*/            
 @pnType    tinyint  -- 1 : new, 2: update, 3:delete            
 ,@pcInterfaceId varchar(20)             
 ,@pcCode   varchar(10) = NULL       
 ,@pcDesc   varchar(max)= NULL             
 ,@pcOfficeId  char(5)  = NULL            
 ,@pnProdId   int   = NULL            
 ,@pnId    int   = NULL--             
 ,@pcValueDate  datetime = NULL            
 ,@pnNIK    int            
 ,@pcGuid   varchar(50)            
as            
            
set nocount on            
            
declare @cErrMsg   varchar(100)            
  , @nOK    int            
  , @nErrNo   int            
  , @cDesc1   varchar(100)            
  , @cDesc2   varchar(100)            
  , @cDesc3   varchar(100)            
  , @cDesc4   varchar(100)            
  , @cDesc5   varchar(100)           
  , @cDesc6   varchar(100)           
  , @nProdIdRegSub int            
  , @nProductId    int      
  , @nGParamId int      
  , @nRiskProfile int      
              
  select @nProductId = ProdId from dbo.ReksaProduct_TM where ProdCode= @pcCode              
              
declare @tmpsplit table (            
 num int,            
 value varchar(100)            
)            
            
If @pnType not in (1,2,3)            
 set @cErrMsg = 'Tipe Proses tidak dikenal!'            
else if isnull(@pcCode,'') = ''  and @pnType in (1,2)            
 set @cErrMsg = 'Kode Harus Diisi!'            
else if isnull(@pcDesc,'') = ''  and @pnType in (1,2)            
 set @cErrMsg = 'Deskripsi/Nilai Harus Diisi!'            
else if @pnProdId = 0 and @pnType in (1,2)             
 and @pcInterfaceId not in ('MNI','CTD','RTY','RHT', 'RSC', 'GFM', 'EVT', 'WPR','RSB', 'PFP', 'MSC'        
 , 'SWC'        
 , 'RPP'        
 , 'ANP', 'KNP'      
 , 'PRE'  
, 'CTR', 'OFF'  
 )             
 set @cErrMsg = 'Produk Tidak Valid!'            
else If @pnType in (1,2) and @pcInterfaceId = 'SAC' and isnull(ltrim(@pcOfficeId),'') = ''            
 set @cErrMsg = 'Office Id Agent harus diisi!'             
else If @pnType in (1,2) and @pcInterfaceId = 'RDD'             
 and exists(select top 1 1 from ReksaProduct_TM where ProdId = @pnProdId and CalcId in (3,4))            
 set @cErrMsg = 'Pembagian Deviden Tidak Variable, Tidak perlu Jadwal!'            
            
if isnull(@cErrMsg,'') != ''            
 goto ERROR            
            
--pecah parameter            
if @pcInterfaceId = 'GFP'     
begin            
 -- pecah dulu parameternya            
 insert into @tmpsplit (num, value)            
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))            
 select @cDesc1 = value from @tmpsplit where num = 1 -- min subscription            
 select @cDesc2 = value from @tmpsplit where num = 2 -- term            
 select @cDesc3 = value from @tmpsplit where num = 3 -- tgl efektif            
 select @cDesc4 = value from @tmpsplit where num = 4 -- tgl expire            
            
 -- cek parameter pertama dan kedua hrs numeric            
 if isnumeric(isnull(@cDesc1, '')) = 0            
 begin            
  set @cErrMsg = 'Parameter nominal subscription salah: ' + isnull(@cDesc1, '')            
  goto ERROR            
 end            
             
 -- min jumlah subscription            
 if convert(money, @cDesc1) < convert(money, dbo.fnReksaGetParam('RSUBSMINAM'))            
 begin            
  set @cErrMsg = 'Jumlah penempatan harus > ' + dbo.fnReksaGetParam('RSUBSMINAM')             
  goto ERROR            
 end            
             
 -- cek kelipatan subscription            
 if convert(money, @cDesc1) % convert(money, dbo.fnReksaGetParam('RSUBSAMNT')) > 0            
 begin            
  set @cErrMsg = 'Jumlah penempatan harus kelipatan ' + dbo.fnReksaGetParam('RSUBSAMNT')            
  goto ERROR            
 end            
             
 if isnumeric(isnull(@cDesc2, '')) = 0            
 begin            
  set @cErrMsg = 'Parameter jangka waktu salah: ' + isnull(@cDesc2, '')            
  goto ERROR            
 end            
            
 -- cek min jk waktu            
 if convert(int, @cDesc2) < convert(int, dbo.fnReksaGetParam('RSUBSMINTM'))            
 begin            
  set @cErrMsg = 'Jangka Waktu harus > ' + dbo.fnReksaGetParam('RSUBSMINTM') + ' bulan'            
  goto ERROR            
 end            
             
 -- cek kelipatan jk waktu            
 if convert(int, @cDesc2) % convert(int, dbo.fnReksaGetParam('RSUBSTERM')) > 0            
 begin            
  set @cErrMsg = 'Jangka Waktu harus kelipatan ' + dbo.fnReksaGetParam('RSUBSTERM') + ' bulan'            
  goto ERROR            
 end            
             
 -- parameter ketiga dan keempat hrs date            
 if isdate(isnull(@cDesc3, '')) =  0            
 begin            
  set @cErrMsg = 'Parameter Tgl Efektif salah: ' + isnull(@cDesc3, '')            
  goto ERROR            
 end            
            
 if isdate(isnull(@cDesc4, '')) =  0            
 begin            
  set @cErrMsg = 'Parameter Tgl Expire salah: ' + isnull(@cDesc4, '')            
  goto ERROR            
 end               
             
 if convert(datetime, @cDesc3) >= convert(datetime, @cDesc4)            
 begin            
  set @cErrMsg = 'Tgl Efektif hrs < Tgl Expire'            
  goto ERROR            
 end            
end            
    
if @pcInterfaceId = 'GFM'    
begin            
 -- pecah dulu parameternya            
 insert into @tmpsplit (num, value)            
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))            
            
select @cDesc1 = value from @tmpsplit where num = 1 -- desc hadiah            
 select @cDesc2 = value from @tmpsplit where num = 2 -- harga hadiah            
            
 -- cek parameter kedua hrs numeric            
 if isnumeric(isnull(@cDesc2, '')) = 0            
 begin            
  set @cErrMsg = 'Parameter harga gift salah: ' + isnull(@cDesc2, '')            
  goto ERROR            
 end            
end            
if @pcInterfaceId = 'RSB'      
begin            
 -- pecah dulu parameternya            
 insert into @tmpsplit (num, value)            
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))            
            
 select @cDesc1 = value from @tmpsplit where num = 1 -- subs fee            
 select @cDesc2 = value from @tmpsplit where num = 2 -- redemption fee            
 select @cDesc3 = value from @tmpsplit where num = 3 -- redemption fee non asuransi            
 select @cDesc4 = value from @tmpsplit where num = 4 -- swc fee asuransi       
 select @cDesc5 = value from @tmpsplit where num = 5 -- swc fee non asuransi       
            
 -- cek parameter pertama & kedua hrs numeric            
 if isnumeric(isnull(@cDesc1, '')) = 0            
 begin            
  set @cErrMsg = 'Parameter subscription fee salah: ' + isnull(@cDesc1, '')            
  goto ERROR            
 end            
            
 if isnumeric(isnull(@cDesc2, '')) = 0            
 begin            
  set @cErrMsg = 'Parameter redemption fee salah: ' + isnull(@cDesc2, '')            
  goto ERROR            
 end            
   if isnumeric(isnull(@cDesc3, '')) = 0              
  begin              
   set @cErrMsg = 'Parameter redemption fee salah: ' + isnull(@cDesc3, '')              
   goto ERROR              
  end              
   if isnumeric(isnull(@cDesc4, '')) = 0              
  begin              
   set @cErrMsg = 'Parameter switching fee RDB salah: ' + isnull(@cDesc3, '')              
   goto ERROR              
  end     
    
    if isnumeric(isnull(@cDesc5, '')) = 0              
  begin              
   set @cErrMsg = 'Parameter switching fee RDB salah: ' + isnull(@cDesc3, '')              
   goto ERROR              
  end      
end            
if @pcInterfaceId = 'PFP'        
begin             
insert into @tmpsplit (num, value)              
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))              
              
 select @cDesc1 = value from @tmpsplit where num = 1 -- min jangka waktu              
 select @cDesc2 = value from @tmpsplit where num = 2 -- kelipatan             
              
 -- cek parameter pertama & kedua hrs numeric              
 if isnumeric(isnull(@cDesc1, '')) = 0   begin              
  set @cErrMsg = 'Parameter min jangka waktu salah: ' + isnull(@cDesc1, '')              
  goto ERROR              
 end              
              
 if isnumeric(isnull(@cDesc2, '')) = 0              
 begin              
  set @cErrMsg = 'Parameter kelipatan salah: ' + isnull(@cDesc2, '')              
  goto ERROR              
 end              
             
 if(convert(int,@cDesc1) < convert(int,@cDesc2))            
 begin            
   set @cErrMsg = 'Min Jangka Waktu harus lebih besar atau sama dengan Kelipatan'              
   goto ERROR             
 end            
            
 if(convert(int,@cDesc1) % convert(int,@cDesc2) != 0)            
 begin            
    set @cErrMsg = 'Kelipatan harus merupakan kelipatan dari Min Jangka Waktu'              
   goto ERROR             
 end            
             
 if(convert(int,@pcCode) >= convert(int,@cDesc1))            
 begin            
 set @cErrMsg = 'Frekuensi Pendebetan harus lebih kecil dari Min Jangka Waktu'              
   goto ERROR             
 end            
             
 if(convert(int,@pcCode) > convert(int,@cDesc2))            
 begin            
   set @cErrMsg = 'Frekuensi Pendebetan harus lebih kecil atau sama dengan Kelipatan'              
   goto ERROR             
 end            
            
end            
if @pcInterfaceId = 'RTY'     
begin       
      
insert into @tmpsplit (num, value)                
select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))                
                
select @cDesc1 = value from @tmpsplit where num = 1  -- type desc IN           
select @cDesc2 = value from @tmpsplit where num = 2 -- type desc EN            
      
end      
if @pcInterfaceId = 'WPR' and @pnType in (1, 2)                
begin               
insert into @tmpsplit (num, value)                
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))                
                
 select @cDesc1 = value from @tmpsplit where num = 1  --warped no            
 select @cDesc2 = value from @tmpsplit where num = 2 --nama              
 select @cDesc3 = value from @tmpsplit where num = 3 --job title             
 select @cDesc4 = value from @tmpsplit where num = 4 -- tgl expire          
               
end              
if @pcInterfaceId = 'SWC' and @pnType in (1, 2, 3)               
begin               
insert into @tmpsplit (num, value)                
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))                
                
 select @cDesc1 = value from @tmpsplit where num = 1  --switch in          
 select @cDesc2 = value from @tmpsplit where num = 2 --min redempt              
 select @cDesc3 = value from @tmpsplit where num = 3 --jenis min redempt         
 select @cDesc6 = value from @tmpsplit where num = 4 --switching fee           
select @cDesc4 = value from @tmpsplit where num = 5 --switching fee karyawan           
end        

            
if @pcInterfaceId in ('ANP', 'KNP')      
begin      
 if(@pnType in (1, 2))      
 begin      
  if @pnType = 1 and exists(select top 1 1 from dbo.ReksaGlobalParam_TR where GroupId = @pcInterfaceId and Id = @pcCode)      
  begin      
   set @cErrMsg = 'Kode sudah digunakan'      
   goto ERROR      
  end      
      
  if exists(select top 1 1 from dbo.ReksaGlobalParam_TR where GroupId = @pcInterfaceId and Id != @pcCode and lower(Value) = lower(@pcDesc))      
  begin      
   set @cErrMsg = 'Deskripsi sudah digunakan'      
   goto ERROR      
  end      
 end      
       
 if(@pnType in (2, 3))      
 begin      
  if exists(select top 1 1 from dbo.ReksaCIFDataNPWP_TR a join dbo.ReksaGlobalParam_TR b on b.GroupId = @pcInterfaceId and a.AlasanTanpaNPWP = b.Id join ReksaGlobalParam_TT c on b.GroupId = c.GroupId and b.Id = c.Id where c.ParamId = @pnId)      
  begin      
   set @cErrMsg = 'Parameter masih digunakan, tidak dapat diubah/hapus.'      
   goto ERROR      
  end      
 end      
      
 insert dbo.ReksaGlobalParam_TT (GroupId, GroupDesc, Id, Value, UserInput, DateInput, TipeAction, StatusOtor)      
 select @pcInterfaceId,      
  case @pcInterfaceId      
   when 'ANP' then 'Reason for No NPWP'      
   when 'KNP' then 'NPWP Ownership'      
  end,      
  @pcCode, @pcDesc, @pnNIK, getdate(), @pnType, 0      
      
 set @nGParamId = @@identity      
      
 if @@error != 0      
 begin      
  set @cErrMsg = 'Error Insert Parameter Global ' + @pcInterfaceId      
  goto ERROR      
 end      
end      
If @pcInterfaceId = 'SAC'            
Begin       
   if(@pnType = 1)      
   begin      
  if exists(select top 1 1 from dbo.ReksaAgent_TR where AgentCode = @pcCode and ProdId = @pnProdId)    
   begin            
    set @cErrMsg = 'Agent Code sudah terdaftar'            
    goto ERROR            
   end        
    end      
        
  if exists(select top 1 1 from dbo.ReksaAgent_TT where AgentCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Agent Code tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end    
  if @pnType = 3 and @pcInterfaceId = 'SAC'    
  begin    
     select @pcCode = AgentCode , @pcDesc = AgentDesc    
     from ReksaAgent_TR    
     where ProdId = @pnProdId    
       and OfficeId = @pcOfficeId    
  end    
        
  insert dbo.ReksaAgent_TT (AgentCode, ProdId, AgentDesc, OfficeId, UserInput, DateInput, TipeAction, StatusOtor)            
  select @pcCode, @pnProdId, @pcDesc, @pcOfficeId, @pnNIK, getdate(), @pnType, 0            
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Parameter Agent'            
   goto ERROR            
  end            
end      
Else If @pcInterfaceId = 'PRE'    
begin  
  if(isnumeric(@pcDesc) = 0)  
  begin  
   set @cErrMsg = 'Persentase harus diisi angka!'          
   goto ERROR      
  end  
  
  if exists(select top 1 1 from dbo.ReksaPremiAsuransi_TT where StatusOtor = 0)          
  begin          
   set @cErrMsg = 'Premi Asuransi sedang dalam proses otorisasi.'          
   goto ERROR          
  end     
      
  insert dbo.ReksaPremiAsuransi_TT (Percentage, ProcessType, DateInput, Inputter, StatusOtor)          
  select @pcDesc, @pnType, getdate(), @pnNIK, 0          
          
  if @@error != 0          
  begin          
   set @cErrMsg = 'Error Insert Parameter Premi Asuransi'          
   goto ERROR          
  end    
end  
Else If @pcInterfaceId = 'CTR'    
begin  
  if exists(select top 1 1 from dbo.ReksaCountryRestriction_TT where StatusOtor = 0 and CountryCode = @pcCode)          
  begin          
   set @cErrMsg = 'Country Code tersebut sedang dalam proses otorisasi.'          
   goto ERROR          
  end     
      
  insert dbo.ReksaCountryRestriction_TT (CountryCode, CountryName, ProcessType, DateInput, Inputter, StatusOtor)          
  select @pcCode, @pcDesc, @pnType, getdate(), @pnNIK, 0          
          
  if @@error != 0          
  begin          
   set @cErrMsg = 'Error Insert Parameter Country Restriction'          
   goto ERROR          
  end    
end  
Else If @pcInterfaceId = 'OFF'    
begin  
  if exists(select top 1 1 from dbo.ReksaOffice_TT where StatusOtor = 0 and OfficeId = @pcCode)          
  begin          
   set @cErrMsg = 'Office Id tersebut sedang dalam proses otorisasi.'          
   goto ERROR          
  end     
      
  insert dbo.ReksaOffice_TT (OfficeId, OfficeDesc, ProcessType, DateInput, Inputter, StatusOtor)          
  select @pcCode, @pcDesc, @pnType, getdate(), @pnNIK, 0          
          
  if @@error != 0          
  begin          
   set @cErrMsg = 'Error Insert Parameter Office'          
   goto ERROR          
  end    
end  
--20150130, liliana, LIBST13020, end   
Else If @pcInterfaceId = 'SFC'            
begin      
   if(@pnType = 1)      
   begin           
   if exists(select top 1 1 from dbo.ReksaFundCode_TR where FundCode = @pcCode)            
   begin            
    set @cErrMsg = 'Fund Code sudah terdaftar'            
    goto ERROR            
   end        
    end      
        
  if exists(select top 1 1 from dbo.ReksaFundCode_TT where FundCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Fund Code tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end    
        
  Insert dbo.ReksaFundCode_TT (FundCode, ProdId, FundDesc, UserInput, DateInput, TipeAction, StatusOtor)            
  select @pcCode, @pnProdId, @pcDesc, @pnNIK, getdate(), @pnType, 0             
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Parameter Fund'            
   goto ERROR            
  end            
end      
Else If @pcInterfaceId = 'SBC'       
begin      
   if(@pnType = 1)      
   begin           
          if exists(select top 1 1 from dbo.ReksaBankCode_TR where BankCode = @pcCode and ProdId = @pnProdId)    
   begin            
    set @cErrMsg = 'Bank Code sudah terdaftar'            
    goto ERROR            
   end        
    end      
        
  if exists(select top 1 1 from dbo.ReksaBankCode_TT where BankCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Bank Code tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end        
        
  Insert dbo.ReksaBankCode_TT (BankCode, ProdId, BankDesc, UserInput, DateInput, TipeAction, StatusOtor)           
  select @pcCode, @pnProdId, @pcDesc, @pnNIK, getdate(), @pnType, 0          
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Parameter Bank'            
   goto ERROR            
  end      
end      
Else If @pcInterfaceId = 'MNI'            
 Begin            
 insert into @tmpsplit (num, value)            
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))            
 select @cDesc1 = value from @tmpsplit where num = 1 -- Man Inv Name  
 select @cDesc2 = value from @tmpsplit where num = 2 -- NFS Man Inv Code    
   if(@pnType = 1)      
   begin           
   if exists(select top 1 1 from dbo.ReksaManInv_TR where ManInvCode = @pcCode)            
   begin            
    set @cErrMsg = 'Code Manager Investasi sudah terdaftar'            
    goto ERROR            
   end        
    end      
        
  if exists(select top 1 1 from dbo.ReksaManInv_TT where ManInvCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Code Manager Investasi tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end              
            
  Insert dbo.ReksaManInv_TT (ManInvCode, ManInvName, UserInput, DateInput, TipeAction, StatusOtor, NFSManInvCode)             
  select @pcCode, @cDesc1, @pnNIK, getdate(), @pnType, 0, @cDesc2   
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Manager Investasi'            
   goto ERROR            
  end            
End        
Else If @pcInterfaceId = 'CTD'            
Begin         
 insert into @tmpsplit (num, value)            
 select * from dbo.Split(@pcDesc, '#', 0, len(@pcDesc))            
 select @cDesc1 = value from @tmpsplit where num = 1 -- Custody Name  
 select @cDesc2 = value from @tmpsplit where num = 2 -- NFS Custody Code    
  if(@pnType = 1)      
  begin         
   if exists(select top 1 1 from dbo.ReksaCustody_TR where CustodyCode = @pcCode)            
   begin            
    set @cErrMsg = 'Code Custody sudah terdaftar'            
    goto ERROR            
   end      
  end      
        
  if exists(select top 1 1 from dbo.ReksaCustody_TT where CustodyCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Code Custody tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end        
       
  Insert dbo.ReksaCustody_TT (CustodyCode, CustodyName,  UserInput, DateInput, TipeAction, StatusOtor, NFSCustodyCode)          
  select @pcCode, @cDesc1, @pnNIK, getdate(), @pnType, 0, @cDesc2  
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Custody'            
   goto ERROR            
  end        
end      
Else If @pcInterfaceId = 'RTY'            
Begin      
  if(@pnType = 1)      
  begin         
   if exists(select top 1 1 from dbo.ReksaType_TR where TypeCode = @pcCode)            
   begin            
    set @cErrMsg = 'Type Reksadana sudah terdaftar'            
    goto ERROR            
   end      
  end      
        
  if exists(select top 1 1 from dbo.ReksaType_TT where TypeCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Type Reksadana tsb sedang dalam proses otorisasi.'            
   goto ERROR            
  end        
       
  Insert dbo.ReksaType_TT (TypeCode, TypeName, TypeNameEnglish, UserInput, DateInput, TipeAction, StatusOtor      
  )            
  select @pcCode, @cDesc1, @cDesc2, @pnNIK, getdate(), @pnType, 0      
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Type'            
   goto ERROR            
  end      
end       
Else If @pcInterfaceId = 'RDD'            
Begin      
  if @pnType = 1 and exists(select top 1 1 from dbo.ReksaDevSchedule_TR where ValueDate = @pcValueDate and ProdId = @pnProdId)            
  begin            
   set @cErrMsg = 'Schedule sudah terdaftar'            
   goto ERROR            
  end       
        
   if exists(select top 1 1 from dbo.ReksaDevSchedule_TT where ValueDate = @pcValueDate and ProdId = @pnProdId and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Schedule sedang dalam proses otorisasi'            
   goto ERROR            
  end       
       
  Insert dbo.ReksaDevSchedule_TT (ProdId, ValueDate, UserInput, DateInput, TipeAction, StatusOtor)           
  select @pnProdId, @pcValueDate, @pnNIK, getdate(), @pnType, 0             
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Parameter Deviden'            
   goto ERROR            
  end       
end      
Else If @pcInterfaceId = 'RHT'       
begin      
  if @pnType = 1 and exists(select top 1 1 from dbo.ReksaHolidayTable_TM where ValueDate = @pcValueDate)            
  begin            
   set @cErrMsg = 'Tanggal libur sudah terdaftar'            
   goto ERROR            
  end       
        
  if exists(select top 1 1 from dbo.ReksaHolidayTable_TT where ValueDate = @pcValueDate and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Tanggal libur sedang dalam proses otorisasi'            
   goto ERROR            
  end       
        
  Insert dbo.ReksaHolidayTable_TT (HolidayDesc, ValueDate, UserInput, DateInput, TipeAction, StatusOtor)                  
  select @pcDesc, convert(char(8),@pcValueDate,112), @pnNIK, getdate(), @pnType, 0            
           
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Parameter Hari Libur'            
   goto ERROR            
  end       
end      
Else If @pcInterfaceId = 'RSC'            
Begin      
  if @pnType = 1 and exists(select top 1 1 from dbo.ReksaSales_TR where SalesCode = @pcCode)            
  begin            
   set @cErrMsg = 'Sales Code sudah terdaftar'            
   goto ERROR            
  end       
        
  if exists(select top 1 1 from dbo.ReksaSales_TT where SalesCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Sales Code sedang dalam proses otorisasi'        
   goto ERROR            
  end       
        
  Insert dbo.ReksaSales_TT(SalesCode, SalesName, UserInput, DateInput, TipeAction, StatusOtor)            
  select @pcCode, @pcDesc, @pnNIK, getdate(), @pnType, 0            
            
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error Insert Sales Code'            
   goto ERROR            
  end        
end      
--master gift            
else if @pcInterfaceId = 'GFM'            
begin       
 if @pnType = 1 and exists (select top 1 1 from dbo.ReksaGift_TR where GiftCode = @pcCode)            
  begin            
   set @cErrMsg = 'Kode Gift sudah terdaftar'            
   goto ERROR            
  end       
        
  if exists(select top 1 1 from dbo.ReksaGift_TT where GiftCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Kode Gift sedang dalam proses otorisasi'            
   goto ERROR            
  end          
      
  -- cek dl ke tabel ReksaGiftProduct_TR            
  if @pnType = 3 and exists (select top 1 1 from dbo.ReksaGiftProduct_TR where GiftCode = @pcCode)            
  begin            
   set @cErrMsg = 'Gagal hapus data karena masih terikat dgn produk'            
   goto ERROR            
  end         
       
  insert dbo.ReksaGift_TT(GiftCode, GiftDesc, GiftCost, UserInput, DateInput, TipeAction, StatusOtor)              
  select @pcCode, @cDesc1, convert(money, @cDesc2), @pnNIK, getdate(), @pnType, 0            
              
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error insert Gift Master'            
   goto ERROR            
  end       
end      
-- gift produk             
 else if @pcInterfaceId = 'GFP'            
 begin            
 If @pnType = 1        
 begin      
   -- cek apakah kode sudah ada di tabel ReksaGift_TR            
   if not exists (select top 1 1 from dbo.ReksaGift_TR where GiftCode = @pcCode)            
   begin            
    set @cErrMsg = 'Gift Code belum terdaftar'            
    goto ERROR            
   end            
               
   -- cek produk            
   if not exists (select top 1 1 from dbo.ReksaRegulerSubscription_TR where ProductId = @pnProdId)            
   begin            
    set @cErrMsg = 'Produk bukan reguler subscription'            
    goto ERROR            
   end               
         
   if exists(select top 1 1 from dbo.ReksaGiftProduct_TR where GiftCode = @pcCode and ProdId = @pnProdId and MinSubscription = convert(float, @cDesc1)      
  and Term = convert(int, @cDesc2) and ValueDate = convert(datetime, @cDesc3) and ExpireDate = convert(datetime, @cDesc4)      
    )      
    begin      
   set @cErrMsg = 'Data dengan detail tersebut sudah pernah diinput'            
   goto ERROR      
    end      
  end      
      
  -- cek tgl expire            
  if @pnType in (1,2) and convert(datetime, @cDesc4) <= (select current_working_date from control_table)            
  begin            
   set @cErrMsg = 'Tanggal Expire tidak boleh <= tgl hari ini'            
   goto ERROR            
  end          
        
  if exists(select top 1 1 from dbo.ReksaGiftProduct_TT where GiftCode = @pcCode and ProdId = @pnProdId and MinSubscription = convert(float, @cDesc1)      
 and Term = convert(int, @cDesc2) and ValueDate = convert(datetime, @cDesc3) and ExpireDate = convert(datetime, @cDesc4) and StatusOtor = 0      
   )      
   begin      
  set @cErrMsg = 'Data dengan detail tersebut sedang dalam proses otorisasi'            
  goto ERROR      
   end      
        
  insert dbo.ReksaGiftProduct_TT             
  (GiftProductId, GiftCode, ProdId, MinSubscription, Term, ValueDate, ExpireDate,      
   UserInput, DateInput, TipeAction, StatusOtor)          
  select @pnId, @pcCode, @pnProdId, convert(float, @cDesc1), convert(int, @cDesc2), convert(datetime, @cDesc3), convert(datetime, @cDesc4),      
   @pnNIK, getdate(), @pnType, 0 
               
 if @@error != 0            
  begin            
   set @cErrMsg = 'Error insert Gift Produk'            
   goto ERROR            
  end            
 end         
-- event type            
 else if @pcInterfaceId = 'EVT'            
 begin            
  if @pnType = 1 and exists (select top 1 1 from dbo.ReksaEventType_TR where EventTypeCode = @pcCode)            
  begin            
   set @cErrMsg = 'Kode event sudah ada'            
   goto ERROR            
  end            
         
  if exists(select top 1 1 from dbo.ReksaEventType_TT where EventTypeCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Kode event sedang dalam proses otorisasi'            
   goto ERROR            
  end          
          
  insert dbo.ReksaEventType_TT (EventTypeCode, EventTypeDesc, UserInput, DateInput, TipeAction, StatusOtor)            
  select @pcCode, @pcDesc, @pnNIK, getdate(), @pnType, 0            
              
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error insert Event Type'            
   goto ERROR            
  end            
end            
--frekuensi pendebetan            
else if @pcInterfaceId = 'PFP'              
 begin              
  if @pnType = 1 and exists (select top 1 1 from dbo.ReksaFrekPendebetanParam_TR where FrekuensiPendebetan = @pcCode)              
  begin              
   set @cErrMsg = 'Frekuensi pendebetan sudah ada'              
   goto ERROR              
  end       
        
  if exists(select top 1 1 from dbo.ReksaFrekPendebetanParam_TT where FrekuensiPendebetan = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Frekuensi pendebetan sedang dalam proses otorisasi'            
   goto ERROR            
  end       
        
 if @pcCode = 1 and @pnType = 3          
 begin            
    set @cErrMsg = 'Parameter default tidak boleh dihapus!'              
    goto ERROR              
 end              
              
  insert dbo.ReksaFrekPendebetanParam_TT (FrekuensiPendebetan, MinJangkaWaktu, Kelipatan, UserInput, DateInput, TipeAction, StatusOtor)              
  select convert(int,@pcCode), convert(int,@cDesc1), convert(int,@cDesc2), @pnNIK, getdate(), @pnType, 0             
                
  if @@error != 0              
  begin              
   set @cErrMsg = 'Error insert Frekuensi Pendebetan'              
   goto ERROR              
  end              
end      
--Min subscription            
else if @pcInterfaceId = 'MSC'              
 begin              
  if @pnType = 1 and exists (select top 1 1 from dbo.ReksaRegulerSubscriptionParam_TR rs       
  join dbo.ReksaProduct_TM rp on rs.ProductId = rp.ProdId where rs.ParamId = 'SubscMin' and rp.ProdCode= @pcCode and rs.IsEmployee =convert(bit,@pnProdId))              
  begin              
   set @cErrMsg = 'Minimum subscription sudah ada'              
   goto ERROR              
  end          
        
  if exists(select top 1 1 from dbo.ReksaRegulerSubscriptionParam_TT rs       
  join dbo.ReksaProduct_TM rp on rs.ProductId = rp.ProdId where rs.ParamId = 'SubscMin' and rp.ProdCode= @pcCode and rs.IsEmployee =convert(bit,@pnProdId)         
  and rs.StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Minimum subscription sedang dalam proses otorisasi'            
   goto ERROR            
  end          
            
  insert dbo.ReksaRegulerSubscriptionParam_TT (ParamId, ParamDesc, ProductId, IsEmployee, ParamValue, UserInput, DateInput, TipeAction, StatusOtor)              
  select 'SubscMin', 'Minimum Subscription', @nProductId, convert(bit,@pnProdId), convert(int,@pcDesc), @pnNIK, getdate(), @pnType, 0             
                
  if @@error != 0              
  begin              
   set @cErrMsg = 'Error insert Minimum subscription'              
   goto ERROR              
  end              
end       
else if @pcInterfaceId = 'RPP'              
 begin        
  if @pnType = 1 and exists (select top 1 1 from dbo.ReksaProductRiskProfile_TM where ProductCode = @pcCode)              
  begin       
   set @cErrMsg = 'Parameter Risk profile product sudah ada'              
   goto ERROR              
  end         
      
  if exists(select top 1 1 from dbo.ReksaProductRiskProfile_TT where ProductCode = @pcCode and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Parameter Risk profile sedang dalam proses otorisasi'               
   goto ERROR            
  end      
      
  select @nRiskProfile = RiskProfile      
  from dbo.ReksaDescRiskProfile_TR  
  where RiskProfileDescEN = @pcDesc   
  
  if @nRiskProfile is null            
  begin            
   set @cErrMsg = 'Parameter Risk Profile tidak ditemukan'               
   goto ERROR            
  end     
          
  insert dbo.ReksaProductRiskProfile_TT (ProductCode, RiskProfile, UserInput, DateInput, TipeAction, StatusOtor)        
  select @pcCode,       
  @nRiskProfile , @pnNIK, getdate(), @pnType, 0       
         
  if @@error != 0              
  begin              
   set @cErrMsg = 'Error insert risk profile product'              
   goto ERROR              
  end         
end         
--switching        
else if @pcInterfaceId = 'SWC'              
 begin         
  if @pnType = 1 and exists (select top 1 1 from dbo.ReksaProdSwitchingParam_TR where ProdSwitchOut = @pcCode and ProdSwitchIn = @cDesc1)              
  begin              
   set @cErrMsg = 'Parameter switching sudah ada'              
   goto ERROR              
  end          
        
  if exists(select top 1 1 from dbo.ReksaProdSwitchingParam_TT where ProdSwitchOut = @pcCode and ProdSwitchIn = @cDesc1 and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Parameter switching sedang dalam proses otorisasi'            
   goto ERROR            
  end              
          
  insert dbo.ReksaProdSwitchingParam_TT (ProdSwitchOut, ProdSwitchIn, MinSwitchRedempt, JenisSwitchRedempt, SwitchingFee, SwitchingFeeKaryawan,       
  UserInput, DateInput, TipeAction, StatusOtor)              
  select @pcCode, @cDesc1, convert(decimal(25,13),@cDesc2),@cDesc3, convert(decimal(25,13),@cDesc6), convert(decimal(25,13),@cDesc4),      
  @pnNIK, getdate(), @pnType, 0            
              
  if @@error != 0              
  begin              
   set @cErrMsg = 'Error insert parameter switching'              
   goto ERROR              
  end         
end            
-- waperd            
else if @pcInterfaceId = 'WPR'            
 begin                
  if (isnumeric(@pcCode) = 0)            
  begin            
   set @cErrMsg = 'NIK harus diisi angka'            
   goto ERROR            
  end                
             
  if @pnType = 1 and exists (select top 1 1 from ReksaWaperd_TR where NIK = @pcCode)            
  begin            
   set @cErrMsg = 'NIK Waperd sudah ada'            
   goto ERROR            
  end            
              
    if @pnType in (1, 2) and not exists (select top 1 1 from dbo.PSEmployee_v WHERE EMPLID = @pcCode)      
  begin            
   set @cErrMsg = 'NIK tidak terdaftar di people soft'            
   goto ERROR            
  end         
      
  if exists(select top 1 1 from dbo.ReksaWaperd_TT where NIK = @pcCode and StatusOtor = 0)              
  begin            
   set @cErrMsg = 'NIK Waperd sedang dalam proses otorisasi'            
   goto ERROR            
  end              
              
  insert dbo.ReksaWaperd_TT (NIK, WaperdNo, Nama, JobTitle, DateExpire, UserInput, DateInput, TipeAction, StatusOtor)           
  select @pcCode, @cDesc1, @cDesc2, @cDesc3, CONVERT(DATETIME,@cDesc4),@pnNIK, getdate(), @pnType, 0                    
              
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error insert Waperd'            
   goto ERROR            
  end            
end         
else if @pcInterfaceId = 'RSB'            
 begin            
  select @nProdIdRegSub = ProdId            
  from dbo.ReksaProduct_TM            
  where ProdCode = @pcCode            
              
  if @pnType = 1 and exists(select top 1 1 from dbo.ReksaRegulerSubscription_TR where ProductId = @nProdIdRegSub)            
  begin            
   set @cErrMsg = 'Kode Produk sudah ada'            
   goto ERROR            
  end          
      
  if exists(select top 1 1 from dbo.ReksaRegulerSubscription_TT where ProductId = @nProdIdRegSub and StatusOtor = 0)            
  begin            
   set @cErrMsg = 'Kode Produk sedang dalam proses otorisasi'            
   goto ERROR            
  end           
  
  insert dbo.ReksaRegulerSubscription_TT (ProductId, SubsFee, RedemptFee, RedemptFeeNonAsuransi,   
    SwcFeeAsuransi, SwcFeeNonAsuransi,  
    UserInput, DateInput, TipeAction, StatusOtor)              
  select @nProdIdRegSub, convert(float, @cDesc1), convert(float, @cDesc2), convert(float, @cDesc3),  
    convert(float, @cDesc4), convert(float, @cDesc5),  
    @pnNIK, getdate(), @pnType, 0      
  if @@error != 0            
  begin            
   set @cErrMsg = 'Error insert RegSubscr'            
   goto ERROR            
  end            
end         
            
return 0            
            
ERROR:            
if isnull(@cErrMsg ,'') = ''            
 set @cErrMsg = 'Error !'            
            
--exec @nOK = set_raiserror @@procid, @nErrNo output              
--if @nOK != 0 return 1              
              
raiserror (@cErrMsg  ,16,1);
return 1
GO