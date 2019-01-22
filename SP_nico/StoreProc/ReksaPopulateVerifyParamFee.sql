
CREATE proc [dbo].[ReksaPopulateVerifyParamFee]  
/*  
 CREATED BY    : liliana  
 CREATION DATE : 20121029
 DESCRIPTION   : menampilkan list parameter fee yg akan di authorize  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------    
  20130222, liliana, BATOY12006, tampilkan data old
  20130418, liliana, BATOY12006, utk redemp fee data2 ini tidak perlu ditampilkan
 END REVISED  
   
 exec dbo.ReksaPopulateVerifyParamFee 'RKPF01'  
 
*/ 
@cJenis        varchar(20)
  
as  
  
set nocount on  
  
declare @bCheck      bit
  
set @bCheck = 0  

if(@cJenis = 'RKPF01') --subs
begin  
	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin		   
		   --rp.MinPctFeeEmployee as MinPercentFeeEmployee,
		   --rp.MaxPctFeeEmployee as MaxPercentFeeEmployee,
		   --rp.MinPctFeeNonEmployee as MinPercentFeeNonEmployee,
		   --rp.MaxPctFeeNonEmployee as MaxPercentFeeNonEmployee,
		   rpf.MinPctFeeEmployee as Old_MinPercentFeeEmployee,
		   rp.MinPctFeeEmployee as New_MinPercentFeeEmployee,
		   rpf.MaxPctFeeEmployee as Old_MaxPercentFeeEmployee,
		   rp.MaxPctFeeEmployee as New_MaxPercentFeeEmployee,
		   rpf.MinPctFeeNonEmployee as Old_MinPercentFeeNonEmployee,
		   rp.MinPctFeeNonEmployee as New_MinPercentFeeNonEmployee,
		   rpf.MaxPctFeeNonEmployee as Old_MaxPercentFeeNonEmployee,
		   rp.MaxPctFeeNonEmployee as New_MaxPercentFeeNonEmployee,
--20130222, liliana, BATOY12006, end		   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin
	--where TrxType = 'SUBS'
	--	  and StatusOtor = 0
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'SUBS'
		  and rp.StatusOtor = 0
--20130222, liliana, BATOY12006, end			
end
else if(@cJenis = 'RKPF02') --redemp
begin
	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin		   
		 --  rp.MinPctFeeEmployee as MinPercentFeeEmployee,
		 --  rp.MaxPctFeeEmployee as MaxPercentFeeEmployee,
		 --  rp.MinPctFeeNonEmployee as MinPercentFeeNonEmployee,
		 --  rp.MaxPctFeeNonEmployee as MaxPercentFeeNonEmployee,
		 --  case when rp.IsFlat = 1 then 'Yes'
			--	when rp.IsFlat = 0 then 'No'
			--else ''
			--end as IsFlat,
		 --  rp.NonFlatPeriod,
		 --  case when rp.RedempIncFee = 1 then 'Yes'
			--	when rp.RedempIncFee = 0 then 'No'
			--else ''
		 --  end as 'PembagianFee',
		   rpf.MinPctFeeEmployee as Old_MinPercentFeeEmployee,
		   rp.MinPctFeeEmployee as New_MinPercentFeeEmployee,
--20130418, liliana, BATOY12006, begin		   
		   --rpf.MaxPctFeeEmployee as Old_MaxPercentFeeEmployee,
		   --rp.MaxPctFeeEmployee as New_MaxPercentFeeEmployee,
--20130418, liliana, BATOY12006, end		   
		   rpf.MinPctFeeNonEmployee as Old_MinPercentFeeNonEmployee,
		   rp.MinPctFeeNonEmployee as New_MinPercentFeeNonEmployee,
--20130418, liliana, BATOY12006, begin			   
		 --  rpf.MaxPctFeeNonEmployee as Old_MaxPercentFeeNonEmployee,
		 --  rp.MaxPctFeeNonEmployee as New_MaxPercentFeeNonEmployee,
		 --  case when rpf.IsFlat = 1 then 'Yes'
			--	when rpf.IsFlat = 0 then 'No'
			--else ''
			--end as Old_Flat,		   
		 --  case when rp.IsFlat = 1 then 'Yes'
			--	when rp.IsFlat = 0 then 'No'
			--else ''
			--end as New_Flat,
		 --  rpf.NonFlatPeriod as Old_NonFlatPeriod,
		 --  rp.NonFlatPeriod as New_NonFlatPeriod,
--20130418, liliana, BATOY12006, end			   
		   case when re.RedempIncFee = 1 then 'Yes'
				when re.RedempIncFee = 0 then 'No'
			else ''
		   end as 'Old_PembagianFee',		   
		   case when rp.RedempIncFee = 1 then 'Yes'
				when rp.RedempIncFee = 0 then 'No'
			else ''
		   end as 'New_PembagianFee',		 
--20130222, liliana, BATOY12006, end		   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin
	--where TrxType = 'REDEMP'
	--	  and StatusOtor = 0	
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'REDEMP'
		  and rp.StatusOtor = 0	
--20130222, liliana, BATOY12006, end			

end
else if(@cJenis = 'RKPF03') --switching
begin
	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin		   
		   --rp.MinPctFeeEmployee as MinPercentFeeEmployee,
		   --rp.MaxPctFeeEmployee as MaxPercentFeeEmployee,
		   --rp.MinPctFeeNonEmployee as MinPercentFeeNonEmployee,
		   --rp.MaxPctFeeNonEmployee as MaxPercentFeeNonEmployee,
		   --rp.SwitchingFee as PercentageSwitchingFee,
		   rpf.MinPctFeeEmployee as Old_MinPercentFeeEmployee,
		   rp.MinPctFeeEmployee as New_MinPercentFeeEmployee,
		   rpf.MaxPctFeeEmployee as Old_MaxPercentFeeEmployee,
		   rp.MaxPctFeeEmployee as New_MaxPercentFeeEmployee,
		   rpf.MinPctFeeNonEmployee as Old_MinPercentFeeNonEmployee,
		   rp.MinPctFeeNonEmployee as New_MinPercentFeeNonEmployee,
		   rpf.MaxPctFeeNonEmployee as Old_MaxPercentFeeNonEmployee,
		   rp.MaxPctFeeNonEmployee as New_MaxPercentFeeNonEmployee,
		   rpf.SwitchingFee as Old_PercentageSwitchingFee,
		   rp.SwitchingFee as New_PercentageSwitchingFee,
--20130222, liliana, BATOY12006, end		   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin				
	--where TrxType = 'SWC'
	--	  and StatusOtor = 0
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'SWC'
		  and rp.StatusOtor = 0		
--20130222, liliana, BATOY12006, end		  
end
else if(@cJenis = 'RKPF04') --Maintenance fee
begin
	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin			   
		   --rp.PeriodEfektifMFee,
		   rpf.PeriodEfektifMFee as Old_PeriodEfektifMFee,
		   rp.PeriodEfektifMFee as New_PeriodEfektifMFee,
--20130222, liliana, BATOY12006, end		   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin			
	--where TrxType = 'MFEE'
	--	  and StatusOtor = 0
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'MFEE'
		  and rp.StatusOtor = 0	
--20130222, liliana, BATOY12006, end		  
end
else if(@cJenis = 'RKPF05') --UpFront fee
begin
	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin			   
		   --rp.PctSellingUpfrontDefault as PercentDefault,
		   rpf.PctSellingUpfrontDefault as Old_PercentDefault,
		   rp.PctSellingUpfrontDefault as New_PercentDefault,
--20130222, liliana, BATOY12006, end		   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin			
	--where TrxType = 'UPFRONT'
	--	  and StatusOtor = 0
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'UPFRONT'
		  and rp.StatusOtor = 0		
--20130222, liliana, BATOY12006, end		  

end
else if(@cJenis = 'RKPF06') --Selling fee
begin

	select @bCheck as CheckB, 
		   rp.SubsId,
		   case when rp.ProcessType = 'A' then 'Add'
				when rp.ProcessType = 'U' then 'Update'
				when rp.ProcessType = 'D' then 'Delete'
			else ''
		   end as ProcessType,
		   re.ProdCode as Product,
--20130222, liliana, BATOY12006, begin			   
		   --rp.PctSellingUpfrontDefault as PercentDefault,
		   rpf.PctSellingUpfrontDefault as Old_PercentDefault,
		   rp.PctSellingUpfrontDefault as New_PercentDefault,
--20130222, liliana, BATOY12006, end			   
		   rp.DateInput as InputDate,
		   rp.Inputter as Inputter
	from dbo.ReksaParamFee_TT rp
		join dbo.ReksaProduct_TM re
			on re.ProdId = rp.ProdId
--20130222, liliana, BATOY12006, begin			
	--where TrxType = 'SELLING'
	--	  and StatusOtor = 0
	left join dbo.ReksaParamFee_TM rpf
			on rp.TrxType = rpf.TrxType
			and rp.ProdId = rpf.ProdId
	where rp.TrxType = 'SELLING'
		  and rp.StatusOtor = 0			
--20130222, liliana, BATOY12006, end		  

end

  
return 0
GO