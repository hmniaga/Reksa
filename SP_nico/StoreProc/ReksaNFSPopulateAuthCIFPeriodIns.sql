
CREATE proc [dbo].[ReksaNFSPopulateAuthCIFPeriodIns]
/*
    CREATED BY    : 
    CREATION DATE : 
    DESCRIPTION   : Populate data detail otorisasi NSF Institusi
    REVISED BY    :
    
    DATE, USER, PROJECT, NOTE
    -----------------------------------------------------------------------        
    END REVISED     
    EXEC dbo.ReksaNFSPopulateAuthCIFPeriodIns 1,'144 - 20180809'
*/
    @pnCIFNumber	bigint 
	,@LogId int = null

AS
    SET NOCOUNT ON    
    DECLARE 
		@XML AS XML
	   ,@hDoc AS INT
	   ,@TypeUpload varchar(5)
	   ,@cCommand           nvarchar(max)
       ,@cField            varchar(40)
       ,@cValue            varchar(1000)
       ,@nGroupProgId      bigint
       ,@nProgId           bigint
       ,@nGiftId           bigint
       ,@cGroupProgCode    varchar(10)
       ,@cGroupProgName    varchar(40)     

select @XML = RawData from ReksaNFSFileRequest_TT
where LogId = @LogId
     
	CREATE TABLE #tmp_AuthDetailNew (      
     CIFNo bigint                            
	,SID	varchar(15)                 
	,CompanyName	varchar(100)        
	,CountryOfDomicile	varchar(2)      
	,CountryOfDomicileDesc	varchar(30) 
	,SIUPNo	varchar(100)                
	,SIUPExpDate	varchar(8)          
	,SKDNo	varchar(20)                 
	,SKDExpDate	varchar(8)              
	,NPWPNo	varchar(20)                 
	,NPWPRegDate	varchar(8)          
	,CountryOfEstablishment	varchar(2)  
	,PlaceOfEstablishment 	varchar(100)
	,DateOfEstablishment	varchar(8)  
	,ArticlesAssociatioNo	varchar(20) 
	,CompanyType 	int                 
	,CompanyTypeDesc	varchar(50)     
	,CompanyChar	int                 
	,CompanyCharDesc	varchar(50)     
	,IncomeLevel	int                 
	,IncomeLevelDesc	varchar(50)     
	,InvestorRiskProfile	int         
	,InvestorRiskProfileDesc	varchar
	,InvestmentObjective	int         
	,InvestmentObjectiveDesc	varchar
	,SourceOfFund	int                 
	,SourceOfFundDesc	varchar(50)     
	,AssetOwner	int                     
	,AssetOwnerDesc	varchar(20)         
	,CompanyAddress	varchar(200)        
	,CompanyCityCode	int             
	,CompanyCityName	varchar(100)    
	,CompanyPostalCode	varchar(5)      
	,CountryOfCompany	varchar(2)      
	,OfficePhone	varchar(100)        
	,Facsimile	varchar(30)             
	,Email	varchar(256)                
	,StatementType	int                 
	,Auth1FirstName	varchar(40)         
	,Auth1MiddleName	varchar(40)     
	,Auth1LastName	varchar(40)         
	,Auth1Position	varchar(120)        
	,Auth1MobilePhone	varchar(30)     
	,Auth1Email	varchar(256)            
	,Auth1NPWP	varchar(15)             
	,Auth1KTPNo	varchar(20)             
	,Auth1KTPExpDate	varchar(8)      
	,Auth1PassportNo	varchar(20)     
	,Auth1PassportExpDate	varchar(8)  
	,Auth2FirstName	varchar(40)         
	,Auth2MiddleName	varchar(40)     
	,Auth2LastName	varchar(40)         
	,Auth2Position	varchar(120)        
	,Auth2MobilePhone	varchar(30)     
	,Auth2Email	varchar(256)            
	,Auth2NPWP	varchar(15)             
	,Auth2KTPNo	varchar(20)             
	,Auth2KTPExpDate	varchar(8)      
	,Auth2PassportNo	varchar(20)     
	,Auth2PassportExpDate	varchar(8)  
	,AssetPast1Y	int                 
	,AssetPast2Y	int                 
	,AssetPast3Y	int                 
	,ProfitPast1Y	int                 
	,ProfitPast2Y	int                 
	,ProfitPast3Y	int                 
	,FATCA	int                         
	,TINStatus	varchar(30)             
	,TINCountry	varchar(2)              
	,GIIN	varchar(30)                 
	,SubsOwnerName	varchar(100)        
	,SubsOwnerAddress	varchar(100)    
	,SubsOwnerTIN	varchar(10)         
	,REDMBIC1	varchar(11)             
	,REDMMemberCode1	varchar(17)     
	,REDMBankName1	varchar(100)        
	,REDMBankCountry1	varchar(2)      
	,REDMBankBranch1	varchar(20)     
	,REDMAccCcy1	varchar(3)  
	,REDMAccNo1	varchar(30)             
	,REDMAccName1	varchar(100)        
	,REDMBIC2	varchar(11)             
	,REDMMemberCode2	varchar(17)     
	,REDMBankName2	varchar(100)        
	,REDMBankCountry2	varchar(2)      
	,REDMBankBranch2	varchar(20)     
	,REDMAccCCy2	varchar(3)          
	,REDMAccNo2	varchar(30)             
	,REDMAccName2	varchar(100)        
	,REDMBIC3	varchar(11)             
	,REDMMemberCode3	varchar(17)     
	,REDMBankName3	varchar(100)        
	,REDMBankCountry3	varchar(2)      
	,REDMBankBranch3	varchar(20)     
	,REDMAccCCy3	varchar(3)          
	,REDMAccNo3	varchar(30)             
	,REDMAccName3	varchar(100)                              
    ) 
	    
    CREATE TABLE #tmp_AuthDetailOld (      
     CIFNo bigint                            
	,SID	varchar(15)                 
	,CompanyName	varchar(100)        
	,CountryOfDomicile	varchar(2)      
	,CountryOfDomicileDesc	varchar(30) 
	,SIUPNo	varchar(100)                
	,SIUPExpDate	varchar(8)          
	,SKDNo	varchar(20)                 
	,SKDExpDate	varchar(8)              
	,NPWPNo	varchar(20)                 
	,NPWPRegDate	varchar(8)          
	,CountryOfEstablishment	varchar(2)  
	,PlaceOfEstablishment 	varchar(100)
	,DateOfEstablishment	varchar(8)  
	,ArticlesAssociatioNo	varchar(20) 
	,CompanyType 	int                 
	,CompanyTypeDesc	varchar(50)     
	,CompanyChar	int                 
	,CompanyCharDesc	varchar(50)     
	,IncomeLevel	int                 
	,IncomeLevelDesc	varchar(50)     
	,InvestorRiskProfile	int         
	,InvestorRiskProfileDesc	varchar(30)
	,InvestmentObjective	int         
	,InvestmentObjectiveDesc	varchar(30)
	,SourceOfFund	int                 
	,SourceOfFundDesc	varchar(50)     
	,AssetOwner	int                     
	,AssetOwnerDesc	varchar(20)         
	,CompanyAddress	varchar(200)        
	,CompanyCityCode	int             
	,CompanyCityName	varchar(100)    
	,CompanyPostalCode	varchar(5)      
	,CountryOfCompany	varchar(2)      
	,OfficePhone	varchar(100)        
	,Facsimile	varchar(30)             
	,Email	varchar(256)                
	,StatementType	int                 
	,Auth1FirstName	varchar(40)         
	,Auth1MiddleName	varchar(40)     
	,Auth1LastName	varchar(40)         
	,Auth1Position	varchar(120)        
	,Auth1MobilePhone	varchar(30)     
	,Auth1Email	varchar(256)            
	,Auth1NPWP	varchar(15)             
	,Auth1KTPNo	varchar(20)             
	,Auth1KTPExpDate	varchar(8)      
	,Auth1PassportNo	varchar(20)     
	,Auth1PassportExpDate	varchar(8)  
	,Auth2FirstName	varchar(40)         
	,Auth2MiddleName	varchar(40)     
	,Auth2LastName	varchar(40)         
	,Auth2Position	varchar(120)        
	,Auth2MobilePhone	varchar(30)     
	,Auth2Email	varchar(256)            
	,Auth2NPWP	varchar(15)             
	,Auth2KTPNo	varchar(20)             
	,Auth2KTPExpDate	varchar(8)      
	,Auth2PassportNo	varchar(20)     
	,Auth2PassportExpDate	varchar(8)  
	,AssetPast1Y	int                 
	,AssetPast2Y	int                 
	,AssetPast3Y	int                 
	,ProfitPast1Y	int                 
	,ProfitPast2Y	int                 
	,ProfitPast3Y	int                 
	,FATCA	int                         
	,TINStatus	varchar(30)             
	,TINCountry	varchar(2)              
	,GIIN	varchar(30)                 
	,SubsOwnerName	varchar(100)        
	,SubsOwnerAddress	varchar(100)    
	,SubsOwnerTIN	varchar(10)         
	,REDMBIC1	varchar(11)             
	,REDMMemberCode1	varchar(17)     
	,REDMBankName1	varchar(100)        
	,REDMBankCountry1	varchar(2)      
	,REDMBankBranch1	varchar(20)     
	,REDMAccCcy1	varchar(3)          
	,REDMAccNo1	varchar(30)             
	,REDMAccName1	varchar(100)        
	,REDMBIC2	varchar(11)             
	,REDMMemberCode2	varchar(17)     
	,REDMBankName2	varchar(100)        
	,REDMBankCountry2	varchar(2)      
	,REDMBankBranch2	varchar(20)     
	,REDMAccCCy2	varchar(3)    
	,REDMAccNo2	varchar(30)             
	,REDMAccName2	varchar(100)        
	,REDMBIC3	varchar(11)             
	,REDMMemberCode3	varchar(17)     
	,REDMBankName3	varchar(100)        
	,REDMBankCountry3	varchar(2)      
	,REDMBankBranch3	varchar(20)     
	,REDMAccCCy3	varchar(3)          
	,REDMAccNo3	varchar(30)             
	,REDMAccName3	varchar(100)                                   
    ) 
   


    CREATE TABLE #tmp_FinalDetail (     
        [No]                int
        ,[Field]            varchar(40)
        ,[OldValue]         varchar(1000)
        ,[NewValue]         varchar(1000)
        ,[FieldType]        char(1)             
    )
    
    CREATE TABLE #tmp_FieldDescription (
        [No]                int
        ,[Field]            varchar(40)     
    )   
    
    /*** STRUKTUR TABLE FINAL ***/
    INSERT #tmp_FinalDetail SELECT 1,'CIFNo', '', '', 'S'                           
 INSERT #tmp_FinalDetail SELECT 2,'SID', '', '', 'S'              
 INSERT #tmp_FinalDetail SELECT 3,'CompanyName', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 4,'CountryOfDomicile', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 5,'CountryOfDomicileDesc', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 6,'SIUPNo', '', '', 'S'        
 INSERT #tmp_FinalDetail SELECT 7,'SIUPExpDate', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 8,'SKDNo', '', '', 'S'               
 INSERT #tmp_FinalDetail SELECT 9,'SKDExpDate', '', '', 'S'    
 INSERT #tmp_FinalDetail SELECT 10,'NPWPNo', '', '', 'S'               
 INSERT #tmp_FinalDetail SELECT 11,'NPWPRegDate', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 12,'CountryOfEstablishment', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 13,'PlaceOfEstablishment', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 14,'DateOfEstablishment', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 15,'ArticlesAssociatioNo', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 16,'CompanyType', '', '', 'S' 	        
 INSERT #tmp_FinalDetail SELECT 17,'CompanyTypeDesc', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 18,'CompanyChar', '', '', 'S'	      
 INSERT #tmp_FinalDetail SELECT 19,'CompanyCharDesc', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 20,'IncomeLevel', '', '', 'S'	      
 INSERT #tmp_FinalDetail SELECT 21,'IncomeLevelDesc', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 22,'InvestorRiskProfile', '', '', 'S'	         
 INSERT #tmp_FinalDetail SELECT 23,'InvestorRiskProfileDesc', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 24,'InvestmentObjective', '', '', 'S'	 
 INSERT #tmp_FinalDetail SELECT 25,'InvestmentObjectiveDesc', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 26,'SourceOfFund', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 27,'SourceOfFundDesc', '', '', 'S'     
 INSERT #tmp_FinalDetail SELECT 28,'AssetOwner', '', '', 'S'	       
 INSERT #tmp_FinalDetail SELECT 29,'AssetOwnerDesc', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 30,'CompanyAddress', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 31,'CompanyCityCode', '', '', 'S'	             
 INSERT #tmp_FinalDetail SELECT 32,'CompanyCityName', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 33,'CompanyPostalCode', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 34,'CountryOfCompany', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 35,'OfficePhone', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 36,'Facsimile', '', '', 'S'            
 INSERT #tmp_FinalDetail SELECT 37,'Email', '', '', 'S'	             
 INSERT #tmp_FinalDetail SELECT 38,'StatementType', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 39,'Auth1FirstName', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 40,'Auth1MiddleName', '', '', 'S'     
 INSERT #tmp_FinalDetail SELECT 41,'Auth1LastName', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 42,'Auth1Position', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 43,'Auth1MobilePhone', '', '', 'S'    
 INSERT #tmp_FinalDetail SELECT 44,'Auth1Email', '', '', 'S'	           
 INSERT #tmp_FinalDetail SELECT 45,'Auth1NPWP', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 46,'Auth1KTPNo', '', '', 'S'           
 INSERT #tmp_FinalDetail SELECT 47,'Auth1KTPExpDate', '', '', 'S'	    
 INSERT #tmp_FinalDetail SELECT 48,'Auth1PassportNo', '', '', 'S'   
 INSERT #tmp_FinalDetail SELECT 49,'Auth1PassportExpDate', '', '', 'S' 
 INSERT #tmp_FinalDetail SELECT 50,'Auth2FirstName', '', '', 'S'	 
 INSERT #tmp_FinalDetail SELECT 51,'Auth2MiddleName', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 52,'Auth2LastName', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 53,'Auth2Position', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 54,'Auth2MobilePhone', '', '', 'S'   
 INSERT #tmp_FinalDetail SELECT 55,'Auth2Email', '', '', 'S'	            
 INSERT #tmp_FinalDetail SELECT 56,'Auth2NPWP', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 57,'Auth2KTPNo', '', '', 'S'           
 INSERT #tmp_FinalDetail SELECT 58,'Auth2KTPExpDate', '', '', 'S'     
 INSERT #tmp_FinalDetail SELECT 59,'Auth2PassportNo', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 60,'Auth2PassportExpDate', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 61,'AssetPast1Y', '', '', 'S'	     
 INSERT #tmp_FinalDetail SELECT 62,'AssetPast2Y', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 63,'AssetPast3Y', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 64,'ProfitPast1Y', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 65,'ProfitPast2Y', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 66,'ProfitPast3Y', '', '', 'S'	                 
 INSERT #tmp_FinalDetail SELECT 67,'FATCA', '', '', 'S'	                         
 INSERT #tmp_FinalDetail SELECT 68,'TINStatus', '', '', 'S'            
 INSERT #tmp_FinalDetail SELECT 69,'TINCountry', '', '', 'S'          
 INSERT #tmp_FinalDetail SELECT 70,'GIIN', '', '', 'S'                
 INSERT #tmp_FinalDetail SELECT 71,'SubsOwnerName', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 72,'SubsOwnerAddress', '', '', 'S'    
 INSERT #tmp_FinalDetail SELECT 73,'SubsOwnerTIN', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 74,'REDMBIC1', '', '', 'S'	            
 INSERT #tmp_FinalDetail SELECT 75,'REDMMemberCode1', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 76,'REDMBankName1', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 77,'REDMBankCountry1', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 78,'REDMBankBranch1', '', '', 'S'   
 INSERT #tmp_FinalDetail SELECT 79,'REDMAccCcy1', '', '', 'S'	         
 INSERT #tmp_FinalDetail SELECT 80,'REDMAccNo1', '', '', 'S'     
 INSERT #tmp_FinalDetail SELECT 81,'REDMAccName1', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 82,'REDMBIC2', '', '', 'S'	         
 INSERT #tmp_FinalDetail SELECT 83,'REDMMemberCode2', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 84,'REDMBankName2', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 85,'REDMBankCountry2', '', '', 'S'  
 INSERT #tmp_FinalDetail SELECT 86,'REDMBankBranch2', '', '', 'S'   
 INSERT #tmp_FinalDetail SELECT 87,'REDMAccCCy2', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 88,'REDMAccNo2', '', '', 'S'         
 INSERT #tmp_FinalDetail SELECT 89,'REDMAccName2', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 90,'REDMBIC3', '', '', 'S'	  
 INSERT #tmp_FinalDetail SELECT 91,'REDMMemberCode3', '', '', 'S'	   
 INSERT #tmp_FinalDetail SELECT 92,'REDMBankName3', '', '', 'S'
 INSERT #tmp_FinalDetail SELECT 93,'REDMBankCountry3', '', '', 'S' 
 INSERT #tmp_FinalDetail SELECT 94,'REDMBankBranch3', '', '', 'S'   
 INSERT #tmp_FinalDetail SELECT 95,'REDMAccCCy3', '', '', 'S'	
 INSERT #tmp_FinalDetail SELECT 96,'REDMAccNo3', '', '', 'S'            
 INSERT #tmp_FinalDetail SELECT 97,'REDMAccName3', '', '', 'S'
                    
    /*** DESCRIPTION ***/   
    
             
 INSERT #tmp_FieldDescription SELECT 2,'SID'          
 INSERT #tmp_FieldDescription SELECT 3,'CompanyName'
 INSERT #tmp_FieldDescription SELECT 4,'CountryOfDomicile'  
 INSERT #tmp_FieldDescription SELECT 5,'CountryOfDomicileDesc'
 INSERT #tmp_FieldDescription SELECT 6,'SIUPNo'    
 INSERT #tmp_FieldDescription SELECT 7,'SIUPExpDate'
 INSERT #tmp_FieldDescription SELECT 8,'SKDNo'           
 INSERT #tmp_FieldDescription SELECT 9,'SKDExpDate'
 INSERT #tmp_FieldDescription SELECT 10,'NPWPNo'           
 INSERT #tmp_FieldDescription SELECT 11,'NPWPRegDate'
 INSERT #tmp_FieldDescription SELECT 12,'CountryOfEstablishment'	
 INSERT #tmp_FieldDescription SELECT 13,'PlaceOfEstablishment'
 INSERT #tmp_FieldDescription SELECT 14,'DateOfEstablishment'
 INSERT #tmp_FieldDescription SELECT 15,'ArticlesAssociatioNo'
 INSERT #tmp_FieldDescription SELECT 16,'CompanyType' 	        
 INSERT #tmp_FieldDescription SELECT 17,'CompanyTypeDesc'	     
 INSERT #tmp_FieldDescription SELECT 18,'CompanyChar'	      
 INSERT #tmp_FieldDescription SELECT 19,'CompanyCharDesc'	     
 INSERT #tmp_FieldDescription SELECT 20,'IncomeLevel'	      
 INSERT #tmp_FieldDescription SELECT 21,'IncomeLevelDesc'	     
 INSERT #tmp_FieldDescription SELECT 22,'InvestorRiskProfile'	         
 INSERT #tmp_FieldDescription SELECT 23,'InvestorRiskProfileDesc'	
 INSERT #tmp_FieldDescription SELECT 24,'InvestmentObjective'	 
 INSERT #tmp_FieldDescription SELECT 25,'InvestmentObjectiveDesc'	
 INSERT #tmp_FieldDescription SELECT 26,'SourceOfFund'	                 
 INSERT #tmp_FieldDescription SELECT 27,'SourceOfFundDesc' 
 INSERT #tmp_FieldDescription SELECT 28,'AssetOwner'	       
 INSERT #tmp_FieldDescription SELECT 29,'AssetOwnerDesc'  
 INSERT #tmp_FieldDescription SELECT 30,'CompanyAddress'	     
 INSERT #tmp_FieldDescription SELECT 31,'CompanyCityCode'	             
 INSERT #tmp_FieldDescription SELECT 32,'CompanyCityName'	   
 INSERT #tmp_FieldDescription SELECT 33,'CompanyPostalCode'	   
 INSERT #tmp_FieldDescription SELECT 34,'CountryOfCompany'  
 INSERT #tmp_FieldDescription SELECT 35,'OfficePhone'
 INSERT #tmp_FieldDescription SELECT 36,'Facsimile'        
 INSERT #tmp_FieldDescription SELECT 37,'Email'	             
 INSERT #tmp_FieldDescription SELECT 38,'StatementType'	                 
 INSERT #tmp_FieldDescription SELECT 39,'Auth1FirstName'	     
 INSERT #tmp_FieldDescription SELECT 40,'Auth1MiddleName' 
 INSERT #tmp_FieldDescription SELECT 41,'Auth1LastName'	     
 INSERT #tmp_FieldDescription SELECT 42,'Auth1Position'	     
 INSERT #tmp_FieldDescription SELECT 43,'Auth1MobilePhone'
 INSERT #tmp_FieldDescription SELECT 44,'Auth1Email'	           
 INSERT #tmp_FieldDescription SELECT 45,'Auth1NPWP'  
 INSERT #tmp_FieldDescription SELECT 46,'Auth1KTPNo'       
 INSERT #tmp_FieldDescription SELECT 47,'Auth1KTPExpDate'	    
 INSERT #tmp_FieldDescription SELECT 48,'Auth1PassportNo'   
 INSERT #tmp_FieldDescription SELECT 49,'Auth1PassportExpDate' 
 INSERT #tmp_FieldDescription SELECT 50,'Auth2FirstName'	 
 INSERT #tmp_FieldDescription SELECT 51,'Auth2MiddleName'
 INSERT #tmp_FieldDescription SELECT 52,'Auth2LastName'	
 INSERT #tmp_FieldDescription SELECT 53,'Auth2Position'	
 INSERT #tmp_FieldDescription SELECT 54,'Auth2MobilePhone'   
 INSERT #tmp_FieldDescription SELECT 55,'Auth2Email'	            
 INSERT #tmp_FieldDescription SELECT 56,'Auth2NPWP'  
 INSERT #tmp_FieldDescription SELECT 57,'Auth2KTPNo'       
 INSERT #tmp_FieldDescription SELECT 58,'Auth2KTPExpDate' 
 INSERT #tmp_FieldDescription SELECT 59,'Auth2PassportNo'
 INSERT #tmp_FieldDescription SELECT 60,'Auth2PassportExpDate'  
 INSERT #tmp_FieldDescription SELECT 61,'AssetPast1Y'	     
 INSERT #tmp_FieldDescription SELECT 62,'AssetPast2Y'	                 
 INSERT #tmp_FieldDescription SELECT 63,'AssetPast3Y'	                 
 INSERT #tmp_FieldDescription SELECT 64,'ProfitPast1Y'	                 
 INSERT #tmp_FieldDescription SELECT 65,'ProfitPast2Y'	                 
 INSERT #tmp_FieldDescription SELECT 66,'ProfitPast3Y'	                 
 INSERT #tmp_FieldDescription SELECT 67,'FATCA'	        
 INSERT #tmp_FieldDescription SELECT 68,'TINStatus'        
 INSERT #tmp_FieldDescription SELECT 69,'TINCountry'      
 INSERT #tmp_FieldDescription SELECT 70,'GIIN'            
 INSERT #tmp_FieldDescription SELECT 71,'SubsOwnerName'
 INSERT #tmp_FieldDescription SELECT 72,'SubsOwnerAddress'
 INSERT #tmp_FieldDescription SELECT 73,'SubsOwnerTIN'
 INSERT #tmp_FieldDescription SELECT 74,'REDMBIC1'	            
 INSERT #tmp_FieldDescription SELECT 75,'REDMMemberCode1'	   
 INSERT #tmp_FieldDescription SELECT 76,'REDMBankName1'
 INSERT #tmp_FieldDescription SELECT 77,'REDMBankCountry1'  
 INSERT #tmp_FieldDescription SELECT 78,'REDMBankBranch1'   
 INSERT #tmp_FieldDescription SELECT 79,'REDMAccCcy1'	         
 INSERT #tmp_FieldDescription SELECT 80,'REDMAccNo1' 
 INSERT #tmp_FieldDescription SELECT 81,'REDMAccName1'
 INSERT #tmp_FieldDescription SELECT 82,'REDMBIC2'	         
 INSERT #tmp_FieldDescription SELECT 83,'REDMMemberCode2'	   
 INSERT #tmp_FieldDescription SELECT 84,'REDMBankName2'
 INSERT #tmp_FieldDescription SELECT 85,'REDMBankCountry2'  
 INSERT #tmp_FieldDescription SELECT 86,'REDMBankBranch2'   
 INSERT #tmp_FieldDescription SELECT 87,'REDMAccCCy2'	   
 INSERT #tmp_FieldDescription SELECT 88,'REDMAccNo2'     
 INSERT #tmp_FieldDescription SELECT 89,'REDMAccName2'
 INSERT #tmp_FieldDescription SELECT 90,'REDMBIC3'	  
 INSERT #tmp_FieldDescription SELECT 91,'REDMMemberCode3'	   
 INSERT #tmp_FieldDescription SELECT 92,'REDMBankName3'
 INSERT #tmp_FieldDescription SELECT 93,'REDMBankCountry3' 
 INSERT #tmp_FieldDescription SELECT 94,'REDMBankBranch3'   
 INSERT #tmp_FieldDescription SELECT 95,'REDMAccCCy3'	
 INSERT #tmp_FieldDescription SELECT 96,'REDMAccNo3'        
 INSERT #tmp_FieldDescription SELECT 97,'REDMAccName3'
            
    /*** INSERT DATA FROM HISTORY TABLE ***/
    EXEC sp_xml_preparedocument @hDoc output,@XML	
	insert into #tmp_AuthDetailNew (CIFNo,SID,CompanyName,CountryOfDomicile,SIUPNo,SIUPExpDate,SKDNo,SKDExpDate,NPWPNo,NPWPRegDate,
	CountryOfEstablishment,PlaceOfEstablishment ,DateOfEstablishment,ArticlesAssociatioNo,CompanyType ,
	CompanyChar,IncomeLevel,InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,CompanyAddress,
	CompanyCityCode,CompanyCityName,CompanyPostalCode,CountryOfCompany,OfficePhone,Facsimile,Email,StatementType,
	Auth1FirstName,Auth1MiddleName,Auth1LastName,Auth1Position,Auth1MobilePhone,Auth1Email,Auth1NPWP,Auth1KTPNo,
	Auth1KTPExpDate,Auth1PassportNo,Auth1PassportExpDate,Auth2FirstName,Auth2MiddleName,Auth2LastName,Auth2Position,
	Auth2MobilePhone,Auth2Email,Auth2NPWP,Auth2KTPNo,Auth2KTPExpDate,Auth2PassportNo,Auth2PassportExpDate,AssetPast1Y,
	AssetPast2Y,AssetPast3Y,ProfitPast1Y,ProfitPast2Y,ProfitPast3Y,FATCA,TINStatus,TINCountry,GIIN,SubsOwnerName,
	SubsOwnerAddress,SubsOwnerTIN,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,REDMBankBranch1,REDMAccCcy1,
	REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,REDMAccNo2,
	REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3)
	select
	CIFNo,SID,CompanyName,CountryOfDomicile,SIUPNo,SIUPExpDate,SKDNo,SKDExpDate,NPWPNo,NPWPRegDate,
	CountryOfEstablishment,PlaceOfEstablishment ,DateOfEstablishment,ArticlesAssociatioNo,CompanyType ,
	CompanyChar,IncomeLevel,InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,CompanyAddress,
	CompanyCityCode,CompanyCityName,CompanyPostalCode,CountryOfCompany,OfficePhone,Facsimile,Email,StatementType,
	Auth1FirstName,Auth1MiddleName,Auth1LastName,Auth1Position,Auth1MobilePhone,Auth1Email,Auth1NPWP,Auth1KTPNo,
	Auth1KTPExpDate,Auth1PassportNo,Auth1PassportExpDate,Auth2FirstName,Auth2MiddleName,Auth2LastName,Auth2Position,
	Auth2MobilePhone,Auth2Email,Auth2NPWP,Auth2KTPNo,Auth2KTPExpDate,Auth2PassportNo,Auth2PassportExpDate,AssetPast1Y,
	AssetPast2Y,AssetPast3Y,ProfitPast1Y,ProfitPast2Y,ProfitPast3Y,FATCA,TINStatus,TINCountry,GIIN,SubsOwnerName,
	SubsOwnerAddress,SubsOwnerTIN,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,REDMBankBranch1,REDMAccCcy1,
	REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,REDMAccNo2,
	REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3
	from OPENXML(@hDoc,'Root/DATA')
	with
		(
			CIFNo bigint 'CIFNo'
			,SID	varchar(15)	'SID'
			,CompanyName	varchar(100)	'CompanyName'
			,CountryOfDomicile	varchar(2)	'CountryOfDomicile'
			,CountryOfDomicileDesc	varchar(30)	'CountryOfDomicileDesc'
			,SIUPNo	varchar(100)	'SIUPNo'
			,SIUPExpDate	varchar(8)	'SIUPExpDate'
			,SKDNo	varchar(20)	'SKDNo'
			,SKDExpDate	varchar(8)	'SKDExpDate'
			,NPWPNo	varchar(20)	'NPWPNo'
			,NPWPRegDate	varchar(8)	'NPWPRegDate'
			,CountryOfEstablishment	varchar(2)	'CountryOfEstablishment'
			,PlaceOfEstablishment 	varchar(100)	'PlaceOfEstablishment'
			,DateOfEstablishment	varchar(8)	'DateOfEstablishment'
			,ArticlesAssociatioNo	varchar(20)	'ArticlesAssociatioNo'
			,CompanyType 	int	'CompanyType'
			,CompanyTypeDesc	varchar(50)	'CompanyTypeDesc'
			,CompanyChar	int	'CompanyChar'
			,CompanyCharDesc	varchar(50)	'CompanyCharDesc'
			,IncomeLevel	int	'IncomeLevel'
			,IncomeLevelDesc	varchar(50)	'IncomeLevelDesc'
			,InvestorRiskProfile	int	'InvestorRiskProfile'
			,InvestorRiskProfileDesc	varchar(20)	'InvestorRiskProfileDesc'
			,InvestmentObjective	int	'InvestmentObjective'
			,InvestmentObjectiveDesc	varchar(30)	'InvestmentObjectiveDesc'
			,SourceOfFund	int	'SourceOfFund'
			,SourceOfFundDesc	varchar(50)	'SourceOfFundDesc'
			,AssetOwner	int	'AssetOwner'
			,AssetOwnerDesc	varchar(20)	'AssetOwnerDesc'
			,CompanyAddress	varchar(200)	'CompanyAddress'
			,CompanyCityCode	int	'CompanyCityCode'
			,CompanyCityName	varchar(100)	'CompanyCityName'
			,CompanyPostalCode	varchar(5)	'CompanyPostalCode'
			,CountryOfCompany	varchar(2)	'CountryOfCompany'
			,OfficePhone	varchar(100)	'OfficePhone'
			,Facsimile	varchar(30)	'Facsimile'
			,Email	varchar(256)	'Email'
			,StatementType	int	'StatementType'
			,Auth1FirstName	varchar(40)	'Auth1FirstName'
			,Auth1MiddleName	varchar(40)	'Auth1MiddleName'
			,Auth1LastName	varchar(40)	'Auth1LastName'
			,Auth1Position	varchar(120)	'Auth1Position'
			,Auth1MobilePhone	varchar(30)	'Auth1MobilePhone'
			,Auth1Email	varchar(256)	'Auth1Email'
			,Auth1NPWP	varchar(15)	'Auth1NPWP'
			,Auth1KTPNo	varchar(20)	'Auth1KTPNo'
			,Auth1KTPExpDate	varchar(8)	'Auth1KTPExpDate'
			,Auth1PassportNo	varchar(20)	'Auth1PassportNo'
			,Auth1PassportExpDate	varchar(8)	'Auth1PassportExpDate'
			,Auth2FirstName	varchar(40)	'Auth2FirstName'
			,Auth2MiddleName	varchar(40)	'Auth2MiddleName'
			,Auth2LastName	varchar(40)	'Auth2LastName'
			,Auth2Position	varchar(120)	'Auth2Position'
			,Auth2MobilePhone	varchar(30)	'Auth2MobilePhone'
			,Auth2Email	varchar(256)	'Auth2Email'
			,Auth2NPWP	varchar(15)	'Auth2NPWP'
			,Auth2KTPNo	varchar(20)	'Auth2KTPNo'
			,Auth2KTPExpDate	varchar(8)	'Auth2KTPExpDate'
			,Auth2PassportNo	varchar(20)	'Auth2PassportNo'
			,Auth2PassportExpDate	varchar(8)	'Auth2PassportExpDate'
			,AssetPast1Y	int	'AssetPast1Y'
			,AssetPast2Y	int	'AssetPast2Y'
			,AssetPast3Y	int	'AssetPast3Y'
			,ProfitPast1Y	int	'ProfitPast1Y'
			,ProfitPast2Y	int	'ProfitPast2Y'
			,ProfitPast3Y	int	'ProfitPast3Y'
			,FATCA	int	'FATCA'
			,TINStatus	varchar(30)	'TINStatus'
			,TINCountry	varchar(2)	'TINCountry'
			,GIIN	varchar(30)	'GIIN'
			,SubsOwnerName	varchar(100)	'SubsOwnerName'
			,SubsOwnerAddress	varchar(100)	'SubsOwnerAddress'
			,SubsOwnerTIN	varchar(10)	'SubsOwnerTIN'
			,REDMBIC1	varchar(11)	'REDMBIC1'
			,REDMMemberCode1	varchar(17)	'REDMMemberCode1'
			,REDMBankName1	varchar(100)	'REDMBankName1'
			,REDMBankCountry1	varchar(2)	'REDMBankCountry1'
			,REDMBankBranch1	varchar(20)	'REDMBankBranch1'
			,REDMAccCcy1	varchar(3)	'REDMAccCcy1'
			,REDMAccNo1	varchar(30)	'REDMAccNo1'
			,REDMAccName1	varchar(100)	'REDMAccName1'
			,REDMBIC2	varchar(11)	'REDMBIC2'
			,REDMMemberCode2	varchar(17)	'REDMMemberCode2'
			,REDMBankName2	varchar(100)	'REDMBankName2'
			,REDMBankCountry2	varchar(2)	'REDMBankCountry2'
			,REDMBankBranch2	varchar(20)	'REDMBankBranch2'
			,REDMAccCCy2	varchar(3)	'REDMAccCCy2'
			,REDMAccNo2	varchar(30)	'REDMAccNo2'
			,REDMAccName2	varchar(100)	'REDMAccName2'
			,REDMBIC3	varchar(11)	'REDMBIC3'
			,REDMMemberCode3	varchar(17)	'REDMMemberCode3'
			,REDMBankName3	varchar(100)	'REDMBankName3'
			,REDMBankCountry3	varchar(2)	'REDMBankCountry3'
			,REDMBankBranch3	varchar(20)	'REDMBankBranch3'
			,REDMAccCCy3	varchar(3)	'REDMAccCCy3'
			,REDMAccNo3	varchar(30)	'REDMAccNo3'
			,REDMAccName3	varchar(100)	'REDMAccName3'
		)
	where CIFNo = @pnCIFNumber			
	EXEC sp_xml_removedocument @hDoc     
    

	EXEC sp_xml_preparedocument @hDoc output,@XML	
	insert into #tmp_AuthDetailOld (CIFNo,SID,CompanyName,CountryOfDomicile,SIUPNo,SIUPExpDate,SKDNo,SKDExpDate,NPWPNo,NPWPRegDate,
	CountryOfEstablishment,PlaceOfEstablishment ,DateOfEstablishment,ArticlesAssociatioNo,CompanyType ,
	CompanyChar,IncomeLevel,InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,CompanyAddress,
	CompanyCityCode,CompanyCityName,CompanyPostalCode,CountryOfCompany,OfficePhone,Facsimile,Email,StatementType,
	Auth1FirstName,Auth1MiddleName,Auth1LastName,Auth1Position,Auth1MobilePhone,Auth1Email,Auth1NPWP,Auth1KTPNo,
	Auth1KTPExpDate,Auth1PassportNo,Auth1PassportExpDate,Auth2FirstName,Auth2MiddleName,Auth2LastName,Auth2Position,
	Auth2MobilePhone,Auth2Email,Auth2NPWP,Auth2KTPNo,Auth2KTPExpDate,Auth2PassportNo,Auth2PassportExpDate,AssetPast1Y,
	AssetPast2Y,AssetPast3Y,ProfitPast1Y,ProfitPast2Y,ProfitPast3Y,FATCA,TINStatus,TINCountry,GIIN,SubsOwnerName,
	SubsOwnerAddress,SubsOwnerTIN,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,REDMBankBranch1,REDMAccCcy1,
	REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,REDMAccNo2,
	REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3)
	select
	CIFNo,SIDOld,CompanyNameOld,CountryOfDomicileOld,SIUPNoOld,SIUPExpDateOld,SKDNoOld,SKDExpDateOld,NPWPNoOld,NPWPRegDateOld,
	CountryOfEstablishmentOld,PlaceOfEstablishmentOld,DateOfEstablishmentOld,ArticlesAssociatioNoOld,CompanyTypeOld,
	CompanyCharOld,IncomeLevelOld,InvestorRiskProfileOld,InvestmentObjectiveOld,SourceOfFundOld,AssetOwnerOld,CompanyAddressOld,
	CompanyCityCodeOld,CompanyCityNameOld,CompanyPostalCodeOld,CountryOfCompanyOld,OfficePhoneOld,FacsimileOld,EmailOld,StatementTypeOld,
	Auth1FirstNameOld,Auth1MiddleNameOld,Auth1LastNameOld,Auth1PositionOld,Auth1MobilePhoneOld,Auth1EmailOld,Auth1NPWPOld,Auth1KTPNoOld,
	Auth1KTPExpDateOld,Auth1PassportNoOld,Auth1PassportExpDateOld,Auth2FirstNameOld,Auth2MiddleNameOld,Auth2LastNameOld,Auth2PositionOld,
	Auth2MobilePhoneOld,Auth2EmailOld,Auth2NPWPOld,Auth2KTPNoOld,Auth2KTPExpDateOld,Auth2PassportNoOld,Auth2PassportExpDateOld,AssetPast1YOld,
	AssetPast2YOld,AssetPast3YOld,ProfitPast1YOld,ProfitPast2YOld,ProfitPast3YOld,FATCA,TINStatusOld,TINCountryOld,GIINOld,SubsOwnerNameOld,
	SubsOwnerAddressOld,SubsOwnerTINOld,REDMBIC1Old,REDMMemberCode1Old,REDMBankName1Old,REDMBankCountry1Old,REDMBankBranch1Old,REDMAccCcy1Old,
	REDMAccNo1Old,REDMAccName1Old,REDMBIC2Old,REDMMemberCode2Old,REDMBankName2Old,REDMBankCountry2Old,REDMBankBranch2Old,REDMAccCCy2Old,REDMAccNo2Old,
	REDMAccName2Old,REDMBIC3Old,REDMMemberCode3Old,REDMBankName3Old,REDMBankCountry3Old,REDMBankBranch3Old,REDMAccCCy3Old,REDMAccNo3Old,REDMAccName3Old
	from OPENXML(@hDoc,'Root/DATA')
	with
	(
	CIFNo bigint  'CIFNo'
	,SIDOld varchar(15)  'SIDOld'
	,CompanyNameOld varchar(100)  'CompanyNameOld'
	,CountryOfDomicileOld varchar(2)  'CountryOfDomicileOld'
	,CountryOfDomicileDescOld varchar(30)  'CountryOfDomicileDescOld'
	,SIUPNoOld varchar(100)  'SIUPNoOld'
	,SIUPExpDateOld varchar(8)  'SIUPExpDateOld'
	,SKDNoOld varchar(20)  'SKDNoOld'
	,SKDExpDateOld varchar(8)  'SKDExpDateOld'
	,NPWPNoOld varchar(20)  'NPWPNoOld'
	,NPWPRegDateOld varchar(8)  'NPWPRegDateOld'
	,CountryOfEstablishmentOld varchar(2)  'CountryOfEstablishmentOld'
	,PlaceOfEstablishmentOld varchar(100)  'PlaceOfEstablishmentOld'
	,DateOfEstablishmentOld varchar(8)  'DateOfEstablishmentOld'
	,ArticlesAssociatioNoOld varchar(20)  'ArticlesAssociatioNoOld'
	,CompanyTypeOld int 'CompanyTypeOld'
	,CompanyTypeDescOld varchar(50)  'CompanyTypeDescOld'
	,CompanyCharOld int 'CompanyCharOld'
	,CompanyCharDescOld varchar(50)  'CompanyCharDescOld'
	,IncomeLevelOld int 'IncomeLevelOld'
	,IncomeLevelDescOld varchar(50)  'IncomeLevelDescOld'
	,InvestorRiskProfileOld int 'InvestorRiskProfileOld'
	,InvestorRiskProfileDescOld varchar(20)  'InvestorRiskProfileDescOld'
	,InvestmentObjectiveOld int 'InvestmentObjectiveOld'
	,InvestmentObjectiveDescOld varchar(30)  'InvestmentObjectiveDescOld'
	,SourceOfFundOld int 'SourceOfFundOld'
	,SourceOfFundDescOld varchar(50)  'SourceOfFundDescOld'
	,AssetOwnerOld int 'AssetOwnerOld'
	,AssetOwnerDescOld varchar(20)  'AssetOwnerDescOld'
	,CompanyAddressOld varchar(200)  'CompanyAddressOld'
	,CompanyCityCodeOld int 'CompanyCityCodeOld'
	,CompanyCityNameOld varchar(100)  'CompanyCityNameOld'
	,CompanyPostalCodeOld varchar(5)  'CompanyPostalCodeOld'
	,CountryOfCompanyOld varchar(2)  'CountryOfCompanyOld'
	,OfficePhoneOld varchar(100)  'OfficePhoneOld'
	,FacsimileOld varchar(30)  'FacsimileOld'
	,EmailOld varchar(256)  'EmailOld'
	,StatementTypeOld int 'StatementTypeOld'
	,Auth1FirstNameOld varchar(40)  'Auth1FirstNameOld'
	,Auth1MiddleNameOld varchar(40)  'Auth1MiddleNameOld'
	,Auth1LastNameOld varchar(40)  'Auth1LastNameOld'
	,Auth1PositionOld varchar(120)  'Auth1PositionOld'
	,Auth1MobilePhoneOld varchar(30)  'Auth1MobilePhoneOld'
	,Auth1EmailOld varchar(256)  'Auth1EmailOld'
	,Auth1NPWPOld varchar(15)  'Auth1NPWPOld'
	,Auth1KTPNoOld varchar(20)  'Auth1KTPNoOld'
	,Auth1KTPExpDateOld varchar(8)  'Auth1KTPExpDateOld'
	,Auth1PassportNoOld varchar(20)  'Auth1PassportNoOld'
	,Auth1PassportExpDateOld varchar(8)  'Auth1PassportExpDateOld'
	,Auth2FirstNameOld varchar(40)  'Auth2FirstNameOld'
	,Auth2MiddleNameOld varchar(40) 'Auth2MiddleNameOld'
	,Auth2LastNameOld varchar(40)  'Auth2LastNameOld'
	,Auth2PositionOld varchar(120)  'Auth2PositionOld'
	,Auth2MobilePhoneOld varchar(30)  'Auth2MobilePhoneOld'
	,Auth2EmailOld varchar(256)  'Auth2EmailOld'
	,Auth2NPWPOld varchar(15) 'Auth2NPWPOld'
	,Auth2KTPNoOld varchar(20)  'Auth2KTPNoOld'
	,Auth2KTPExpDateOld varchar(8)  'Auth2KTPExpDateOld'
	,Auth2PassportNoOld varchar(20)  'Auth2PassportNoOld'
	,Auth2PassportExpDateOld varchar(8)  'Auth2PassportExpDateOld'
	,AssetPast1YOld int 'AssetPast1YOld'
	,AssetPast2YOld int 'AssetPast2YOld'
	,AssetPast3YOld int 'AssetPast3YOld'
	,ProfitPast1YOld int 'ProfitPast1YOld'
	,ProfitPast2YOld int 'ProfitPast2YOld'
	,ProfitPast3YOld int 'ProfitPast3YOld'
	,FATCA  int 'FATCA'
	,TINStatusOld varchar(30)  'TINStatusOld'
	,TINCountryOld varchar(2)  'TINCountryOld'
	,GIINOld varchar(30)  'GIINOld'
	,SubsOwnerNameOld varchar(100)  'SubsOwnerNameOld'
	,SubsOwnerAddressOld varchar(100)  'SubsOwnerAddressOld'
	,SubsOwnerTINOld varchar(10)  'SubsOwnerTINOld'
	,REDMBIC1Old varchar(11)  'REDMBIC1Old'
	,REDMMemberCode1Old varchar(17)  'REDMMemberCode1Old'
	,REDMBankName1Old varchar(100)  'REDMBankName1Old'
	,REDMBankCountry1Old varchar(2)  'REDMBankCountry1Old'
	,REDMBankBranch1Old varchar(20)  'REDMBankBranch1Old'
	,REDMAccCcy1Old varchar(3)  'REDMAccCcy1Old'
	,REDMAccNo1Old varchar(30)  'REDMAccNo1Old'
	,REDMAccName1Old varchar(100)  'REDMAccName1Old'
	,REDMBIC2Old varchar(11)  'REDMBIC2Old'
	,REDMMemberCode2Old varchar(17)  'REDMMemberCode2Old'
	,REDMBankName2Old varchar(100)  'REDMBankName2Old'
	,REDMBankCountry2Old varchar(2)  'REDMBankCountry2Old'
	,REDMBankBranch2Old varchar(20)  'REDMBankBranch2Old'
	,REDMAccCCy2Old varchar(3)  'REDMAccCCy2Old'
	,REDMAccNo2Old varchar(30)  'REDMAccNo2Old'
	,REDMAccName2Old varchar(100)  'REDMAccName2Old'
	,REDMBIC3Old varchar(11)  'REDMBIC3Old'
	,REDMMemberCode3Old varchar(17)  'REDMMemberCode3Old'
	,REDMBankName3Old varchar(100)  'REDMBankName3Old'
	,REDMBankCountry3Old varchar(2)  'REDMBankCountry3Old'
	,REDMBankBranch3Old varchar(20)  'REDMBankBranch3Old'
	,REDMAccCCy3Old varchar(3)  'REDMAccCCy3Old'
	,REDMAccNo3Old varchar(30)  'REDMAccNo3Old'
	,REDMAccName3Old varchar(100)  'REDMAccName3Old'
	)
	where CIFNo = @pnCIFNumber			
	EXEC sp_xml_removedocument @hDoc

    /*** BUILDING COMMAND TO ASSIGN REAL VALUE TO FINAL TABLE ***/
    SET @cCommand = ''
    
    DECLARE csr_AuthDetail CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT [Field] FROM #tmp_FinalDetail
    
    OPEN csr_AuthDetail
    WHILE(1=1)
    BEGIN
        FETCH csr_AuthDetail INTO @cField
    
        IF @@fetch_status <> 0 BREAK
        SET @cCommand = @cCommand + '
            UPDATE tf
            SET tf.[NewValue] = ta.' + @cField + '
            FROM #tmp_FinalDetail tf
            JOIN  #tmp_AuthDetailNew ta
            ON tf.[Field] = ''' + @cField + '''
        ' + char(10)
        
        SET @cCommand = @cCommand + '
            UPDATE tf
            SET tf.[OldValue] = ta.' + @cField + '
            FROM #tmp_FinalDetail tf
            JOIN  #tmp_AuthDetailOld ta
            ON tf.[Field] = ''' + @cField + '''
        ' + char(10)
    END
    CLOSE csr_AuthDetail
    DEALLOCATE csr_AuthDetail
    
    EXEC sp_executesql @cCommand    


        
    /*** UPDATE FIELD DESCRIPTION ***/
    UPDATE tf
    SET tf.[Field] = td.[Field]
    FROM #tmp_FinalDetail tf
    JOIN #tmp_FieldDescription td
    ON tf.[No] = td.[No]
        
    
    
    
    /*** FILTER HIDDEN FIELD ***/
    DELETE FROM #tmp_FinalDetail
    WHERE [No] = 1
    
    /*** SHOW DATA ***/
    SELECT [Field],rtrim(ltrim([OldValue])) as OldValue,rtrim(ltrim([NewValue])) as NewValue FROM #tmp_FinalDetail
	where OldValue <> NewValue
    ORDER BY [No]

            
    DROP TABLE #tmp_AuthDetailNew
    DROP TABLE #tmp_AuthDetailOld
    DROP TABLE #tmp_FinalDetail
    DROP TABLE #tmp_FieldDescription
    
    RETURN 0
GO