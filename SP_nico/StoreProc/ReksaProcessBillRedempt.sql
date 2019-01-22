CREATE procedure [dbo].[ReksaProcessBillRedempt]
/*      
  CREATED BY    : Mutiara
  CREATION DATE : 20080410    
  DESCRIPTION   :  
  REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE      
  -----------------------------------------------------------------------       
    20080416, indra_w, REKSADN002, perbaikan
    20080425, indra_w, REKSADN002, ubah cara round
    20080609, indra_w, REKSADN006, Fortis
    20100521, volvin, LOGAM03356, ubah ambil tgl utk hari libur
    20121008, liliana, BAALN11003, Amountnya jangan di round
    20130129, liliana, BATOY12006, ganti total bill
    20130129, liliana, BATOY12006, perbaikan
    20130220, liliana, BATOY12006, tambah kolom reksa bill
    20130402, liliana, BATOY12006, round 2
    20130515, liliana, BAFEM12011, tambahan perhitungan
    20160902, liliana, LOGEN00196, switching jgn masuk
  END REVISED      
*/      
as      
set nocount on      
      
declare @nOK    tinyint  
    ,@nErrNo   int  
    ,@cErrMsg   varchar(100)  
    ,@nUserSuid   int  
    ,@dCurrDate   datetime  
    ,@dCurrWorkingDate datetime  
    ,@nProdId   int  
    ,@nBillId   int  
    ,@cTranCCY   char(3)  
--20080416, indra_w, REKSADN002, begin
    ,@cPeriod   char(8)
--20080416, indra_w, REKSADN002, end
    ,@dTranDate   datetime    
--20080609, indra_w, REKSADN006, begin
    ,@nRedempIncFee tinyint
--20080609, indra_w, REKSADN006, end
  
exec @nOK = set_usersuid @nUserSuid output      
if @nOK != 0 or @@error != 0 return 1      
    
exec @nOK = cek_process_table @nProcID = @@procid       
if @nOK != 0 or @@error != 0 return 1      
    
exec @nOK = set_process_table @@procid, null, @nUserSuid, 1      
if @nOK != 0 or @@error != 0 return 1      
    
select @dCurrDate = current_working_date     
    ,@dTranDate = dateadd(day, datediff(day, getdate(), current_working_date), getdate())    
from control_table  
    
select @dCurrWorkingDate = current_working_date    
from fnGetWorkingDate()    
--20080416, indra_w, REKSADN002, begin
select @cPeriod = convert(char(8), @dCurrWorkingDate, 112)    
--20080416, indra_w, REKSADN002, end

--20080609, indra_w, REKSADN006, begin
--Begin Transaction  
--20080609, indra_w, REKSADN006, end
    declare bill_cur cursor local fast_forward for   
--20080609, indra_w, REKSADN006, begin
--  select ProdId, TranCCY  
--  from ReksaTransaction_TT  
--  where TranType in (3,4)  
--      and isnull(BillId, 0) = 0  
--      and GoodFund = @dCurrDate  
--  Group by ProdId, TranCCY  
--  order by ProdId  
    select a.ProdId, a.TranCCY, b.RedempIncFee
    from ReksaTransaction_TT a join ReksaProduct_TM b
            on a.ProdId = b.ProdId
    where a.TranType in (3,4)  
        and isnull(a.BillId, 0) = 0  
        and a.GoodFund = @dCurrDate 
--20160902, liliana, LOGEN00196, begin
		and isnull(a.ExtStatus,0) not in (10,20)
--20160902, liliana, LOGEN00196, end         
    Group by a.ProdId, a.TranCCY, b.RedempIncFee
    order by a.ProdId  
--20080609, indra_w, REKSADN006, end  
    open bill_cur   
  
    while 1=1  
    begin  
--20080609, indra_w, REKSADN006, begin
--      fetch bill_cur into @nProdId, @cTranCCY
        fetch bill_cur into @nProdId, @cTranCCY, @nRedempIncFee
--20080609, indra_w, REKSADN006, end
        if @@fetch_status!=0 break  
--20080609, indra_w, REKSADN006, begin
        begin transaction
--20080609, indra_w, REKSADN006, end    
    --proses yang subcription by Nominal  
        Insert ReksaBill_TM (BillType, BillName, DebitCredit, CreateDate, ValueDate  
--20130220, liliana, BATOY12006, begin      
            --, ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased) 
            , ProdId, CustodyId, BillCCY, TotalBill, Fee, FeeBased
            , TaxFeeBased, FeeBased3, FeeBased4, FeeBased5
            ) 
--20130220, liliana, BATOY12006, end            
--20080416, indra_w, REKSADN002, begin 
            select 2, @cPeriod + ' - Redemption - '+ c.CustodyName, 'C', @dTranDate, @dCurrWorkingDate  
--20080416, indra_w, REKSADN002, end
            , a.ProdId, c.CustodyId, a.TranCCY  
--20080425, indra_w, REKSADN002, begin
--20080609, indra_w, REKSADN006, begin
--          ,sum(case   
--                      when a.TranCCY = 'IDR' then round(a.TranAmt - a.RedempFee, 0)  
--                      else round(a.TranAmt - a.RedempFee, 2)  
--          end) 
--20121008, liliana, BAALN11003, begin 
            --,sum(case   
            --          when a.TranCCY = 'IDR' then 
            --                  case when @nRedempIncFee = 0 then round(a.TranAmt - a.RedempFee, 0)  
            --                          else round(a.TranAmt - (a.RedempFee - a.RedempFeeBased), 0)
            --                  end
            --          else 
            --                  case when @nRedempIncFee = 0 then round(a.TranAmt - a.RedempFee, 2) 
            --                          else  round(a.TranAmt - (a.RedempFee - a.RedempFeeBased), 2)
            --                  end
            --end)  
--20130129, liliana, BATOY12006, begin          
            --,sum(case when @nRedempIncFee = 0 then a.TranAmt - a.RedempFee  
            --          else a.TranAmt - (a.RedempFee - a.RedempFeeBased)
            --      end
            --  ) 
--20130129, liliana, BATOY12006, begin              
            --, sum(a.TranAmt + a.RedempFee) 
--20130515, liliana, BAFEM12011, begin
            --, sum(a.TranAmt) 
            ,sum(case   
                        when a.TranCCY = 'IDR' then 
                                case when @nRedempIncFee = 0 then round(a.TranAmt - a.RedempFee, 2)  
                                        else round(a.TranAmt, 2)
                                end
                        else 
                                case when @nRedempIncFee = 0 then round(a.TranAmt - a.RedempFee, 2) 
                                        else  round(a.TranAmt, 2)
                                end
            end)    
--20130515, liliana, BAFEM12011, end            
--20130129, liliana, BATOY12006, end            
--20130129, liliana, BATOY12006, end                
--20121008, liliana, BAALN11003, end
--20080425, indra_w, REKSADN002, end
--          , 0 as 'SubcFee'  
--          , 0 as 'SubcFeeBased'  
            , case when @nRedempIncFee = 0 then 0
--20130402, liliana, BATOY12006, begin          
                    --else sum(case when a.TranCCY = 'IDR' then round(isnull(a.RedempFee,0), 0) else round(isnull(a.RedempFee,0), 2) end)
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.RedempFee,0), 2) else round(isnull(a.RedempFee,0), 2) end)
--20130402, liliana, BATOY12006, end                    
                end
            , case when @nRedempIncFee = 0 then 0
--20130402, liliana, BATOY12006, begin                  
                    --else sum(case when a.TranCCY = 'IDR' then round(isnull(a.RedempFeeBased,0),0) else round(isnull(a.RedempFeeBased,0),2) end )
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.RedempFeeBased,0),2) else round(isnull(a.RedempFeeBased,0),2) end )
--20130402, liliana, BATOY12006, end                    
                end
--20080609, indra_w, REKSADN006, end
--20130220, liliana, BATOY12006, begin
--20130402, liliana, BATOY12006, begin      
            --, case when @nRedempIncFee = 0 then 0
            --      else sum(case when a.TranCCY = 'IDR' then round(isnull(a.TaxFeeBased,0),0) else round(isnull(a.TaxFeeBased,0),2) end )
            --  end
            --, case when @nRedempIncFee = 0 then 0
            --      else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased3,0),0) else round(isnull(a.FeeBased3,0),2) end )
            --  end
            --, case when @nRedempIncFee = 0 then 0
            --      else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased4,0),0) else round(isnull(a.FeeBased4,0),2) end )
            --  end     
            --, case when @nRedempIncFee = 0 then 0
            --      else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased5,0),0) else round(isnull(a.FeeBased5,0),2) end )
            --  end
            , case when @nRedempIncFee = 0 then 0
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.TaxFeeBased,0),2) else round(isnull(a.TaxFeeBased,0),2) end )
                end
            , case when @nRedempIncFee = 0 then 0
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased3,0),2) else round(isnull(a.FeeBased3,0),2) end )
                end
            , case when @nRedempIncFee = 0 then 0
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased4,0),2) else round(isnull(a.FeeBased4,0),2) end )
                end     
            , case when @nRedempIncFee = 0 then 0
                    else sum(case when a.TranCCY = 'IDR' then round(isnull(a.FeeBased5,0),2) else round(isnull(a.FeeBased5,0),2) end )
                end         
--20130402, liliana, BATOY12006, end                        
--20130220, liliana, BATOY12006, end
        from ReksaTransaction_TT a join ReksaProduct_TM b  
                on a.ProdId = b.ProdId   
            join ReksaCustody_TR c on b.CustodyId = c.CustodyId  
        where a.TranType in (3,4)  
            and a.ProdId = @nProdId  
            and a.TranCCY = @cTranCCY  
            and a.Status = 1  
            and isnull(a.BillId, 0) = 0  
--20100521, volvin, LOGAM03356, begin
--          and a.GoodFund = @dCurrWorkingDate  
            and a.GoodFund = @dCurrDate 
--20100521, volvin, LOGAM03356, end
--20160902, liliana, LOGEN00196, begin
			and isnull(a.ExtStatus,0) not in (10,20)
--20160902, liliana, LOGEN00196, end 
        group by c.CustodyName, a.ProdId, c.CustodyId, a.TranCCY  
    
        If @@error!= 0  
        Begin  
            set @cErrMsg = 'Gagal Process Subc By Nominal!'  
            goto ErrorHandler  
        End  
  
        set @nBillId = scope_identity()  
  
        Update ReksaTransaction_TT  
        set  BillId = @nBillId  
        where isnull(BillId, 0) = 0  
--20080416, indra_w, REKSADN002, begin
            and TranType in (3,4)  
--20080416, indra_w, REKSADN002, end
            and ProdId = @nProdId  
            and TranCCY = @cTranCCY  
            and Status = 1  
--20100521, volvin, LOGAM03356, begin
--          and GoodFund = @dCurrWorkingDate   
            and GoodFund = @dCurrDate 
--20100521, volvin, LOGAM03356, end
--20160902, liliana, LOGEN00196, begin
			and isnull(ExtStatus,0) not in (10,20)
--20160902, liliana, LOGEN00196, end 
  
        If @@error!= 0  
        Begin  
            set @cErrMsg = 'Gagal Update Data Bill Subc By Nominal!'  
            goto ErrorHandler  
        End  
--20080609, indra_w, REKSADN006, begin

        if @nRedempIncFee = 1
        Begin
            update ReksaRedempFee_TM
            set MainBillId = @nBillId
                , BillId = @nBillId
                , Settled = 1
                , SettleDate = @dCurrWorkingDate
                , UserSuid = 7
                , CheckerSuid = 7
            where isnull(BillId, 0) = 0
                    and ProdId = @nProdId
--20100521, volvin, LOGAM03356, begin
--                  and ValueDate = @dCurrWorkingDate  
                    and ValueDate = @dCurrDate 
--20100521, volvin, LOGAM03356, end

            If @@error!= 0  
            Begin  
                set @cErrMsg = 'Gagal Update Data Redemp Fee!'  
                goto ErrorHandler  
            End  
        end

        commit tran
--20080609, indra_w, REKSADN006, end
    end  
  
    close bill_cur  
    deallocate bill_cur  
--20080609, indra_w, REKSADN006, begin
--Commit tran  
--20080609, indra_w, REKSADN006, end
    
    
exec @nOK = set_process_table @@procid, null, @nUserSuid, 0      
if @nOK != 0 or @@error != 0 return 1      
      
return 0      
      
ErrorHandler:      
if @@trancount>0 rollback tran      
--exec @nOK = set_raiserror @@procid, @nErrNo output      
--if @nOK<>0 or @@error<>0 return 1      
raiserror (@cErrMsg ,16,1);
return 1
GO