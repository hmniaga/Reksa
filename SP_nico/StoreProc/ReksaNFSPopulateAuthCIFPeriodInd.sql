CREATE proc [dbo].[ReksaNFSPopulateAuthCIFPeriodInd]
/*
    CREATED BY    : 
    CREATION DATE : 
    DESCRIPTION   : Populate data detail otorisasi NSF Individu
    REVISED BY    :
    
    DATE, USER, PROJECT, NOTE
    -----------------------------------------------------------------------        
    END REVISED     
    EXEC dbo.ReksaNFSPopulateAuthCIFPeriodInd 1,'144 - 20180809'
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
     CIFNo	Bigint                            
	,SID varchar(15)                        
	,FirstName varchar(100)                 
	,MiddleName varchar(30)                 
	,LastName varchar(30)                   
	,CountryOfNationality varchar(3)        
	,CountryOfNationalityDesc varchar(30)   
	,IDNo varchar(30)                       
	,IDExpDate varchar(8)                   
	,NPWPNo varchar(15)                     
	,NPWRegDate varchar(8)                  
	,CountryOfBirth varchar(2)              
	,PlaceOfBirth varchar(100)              
	,DateOfBirth varchar(8)                 
	,Gender int                             
	,GenderDesc varchar(10)                 
	,Education int                          
	,EducationDesc varchar(30)              
	,MotherName varchar(100)                
	,Religion int                           
	,ReligionDesc varchar(20)               
	,Occupation int                         
	,OccupationDesc varchar(100)            
	,IncomeLevel int                        
	,IncomeLevelDesc varchar(50)            
	,MaritalStatus int                      
	,MaritalStatusDesc varchar(30)          
	,SpouseName varchar(100)                
	,InvestorRiskProfile int                
	,InvestorRiskProfileDesc varchar(20)    
	,InvestmentObjective int                
	,InvestmentObjectiveDesc varchar(30)    
	,SourceOfFund int                       
	,SourceOfFundDesc varchar(50)           
	,AssetOwner int                         
	,AssetOwnerDesc varchar(20)             
	,KTPAddress varchar(100)                
	,KTPCityCode varchar(4)                 
	,KTPCityCodeDesc varchar(50)            
	,KTPPostalCode varchar(5)               
	,CorrAddress varchar(100)               
	,CorrCityCode varchar(4)                
	,CorrCityName varchar(100)              
	,CorrPostalCode varchar(5)              
	,CorrCountry varchar(2)                 
	,DomicileAddress varchar(100)           
	,DomicileCityCode varchar(4)            
	,DomicileCityName varchar(100)          
	,DomicilePostalCode varchar(5)          
	,DomicileCountry varchar(2)             
	,HomePhone varchar(30)                  
	,MobilePhone varchar(30)                
	,Facsimile varchar(30)                  
	,Email varchar(256)                     
	,StatementType int                      
	,FATCA int                              
	,TINStatus varchar(30)                  
	,TINCountry varchar(2)                  
	,REDMBIC1 varchar(11)                   
	,REDMMemberCode1 varchar(17)            
	,REDMBankName1 varchar(100)             
	,REDMBankCountry1 varchar(2)            
	,REDMBankBranch1 varchar(20)            
	,REDMAccCcy1 varchar(3)                 
	,REDMAccNo1 varchar(30)                 
	,REDMAccName1 varchar(100)              
	,REDMBIC2 varchar(11)                   
	,REDMMemberCode2 varchar(17)            
	,REDMBankName2 varchar(100)             
	,REDMBankCountry2 varchar(2)            
	,REDMBankBranch2 varchar(20)            
	,REDMAccCCy2 varchar(3)                 
	,REDMAccNo2 varchar(30)                 
	,REDMAccName2 varchar(100)              
	,REDMBIC3 varchar(11)                   
	,REDMMemberCode3 varchar(17)            
	,REDMBankName3 varchar(100)             
	,REDMBankCountry3 varchar(2)            
	,REDMBankBranch3 varchar(20)            
	,REDMAccCCy3 varchar(3)                 
	,REDMAccNo3 varchar(30)                 
	,REDMAccName3 varchar(100)                           
    ) 
	    
    CREATE TABLE #tmp_AuthDetailOld (      
     CIFNo	Bigint                            
	,SID varchar(15)                        
	,FirstName varchar(100)                 
	,MiddleName varchar(30)                 
	,LastName varchar(30)                   
	,CountryOfNationality varchar(3)        
	,CountryOfNationalityDesc varchar(30)   
	,IDNo varchar(30)                       
	,IDExpDate varchar(8)                   
	,NPWPNo varchar(15)                     
	,NPWRegDate varchar(8)                  
	,CountryOfBirth varchar(2)              
	,PlaceOfBirth varchar(100)              
	,DateOfBirth varchar(8)                 
	,Gender int                             
	,GenderDesc varchar(10)                 
	,Education int                          
	,EducationDesc varchar(30)              
	,MotherName varchar(100)                
	,Religion int                           
	,ReligionDesc varchar(20)               
	,Occupation int                         
	,OccupationDesc varchar(100)            
	,IncomeLevel int                        
	,IncomeLevelDesc varchar(50)            
	,MaritalStatus int                      
	,MaritalStatusDesc varchar(30)          
	,SpouseName varchar(100)                
	,InvestorRiskProfile int                
	,InvestorRiskProfileDesc varchar(20)    
	,InvestmentObjective int                
	,InvestmentObjectiveDesc varchar(30)    
	,SourceOfFund int                       
	,SourceOfFundDesc varchar(50)           
	,AssetOwner int                         
	,AssetOwnerDesc varchar(20)             
	,KTPAddress varchar(100)                
	,KTPCityCode varchar(4)                 
	,KTPCityCodeDesc varchar(50)            
	,KTPPostalCode varchar(5)               
	,CorrAddress varchar(100)               
	,CorrCityCode varchar(4)                
	,CorrCityName varchar(100)              
	,CorrPostalCode varchar(5)              
	,CorrCountry varchar(2)                 
	,DomicileAddress varchar(100)           
	,DomicileCityCode varchar(4)            
	,DomicileCityName varchar(100)          
	,DomicilePostalCode varchar(5)          
	,DomicileCountry varchar(2)             
	,HomePhone varchar(30)                  
	,MobilePhone varchar(30)                
	,Facsimile varchar(30)                  
	,Email varchar(256)                     
	,StatementType int                      
	,FATCA int                              
	,TINStatus varchar(30)                  
	,TINCountry varchar(2)                  
	,REDMBIC1 varchar(11)                   
	,REDMMemberCode1 varchar(17)            
	,REDMBankName1 varchar(100)             
	,REDMBankCountry1 varchar(2)            
	,REDMBankBranch1 varchar(20)            
	,REDMAccCcy1 varchar(3)                 
	,REDMAccNo1 varchar(30)                 
	,REDMAccName1 varchar(100)              
	,REDMBIC2 varchar(11)                   
	,REDMMemberCode2 varchar(17)            
	,REDMBankName2 varchar(100)             
	,REDMBankCountry2 varchar(2)            
	,REDMBankBranch2 varchar(20)            
	,REDMAccCCy2 varchar(3)                 
	,REDMAccNo2 varchar(30)                 
	,REDMAccName2 varchar(100)              
	,REDMBIC3 varchar(11)                   
	,REDMMemberCode3 varchar(17)            
	,REDMBankName3 varchar(100)             
	,REDMBankCountry3 varchar(2)            
	,REDMBankBranch3 varchar(20)        
	,REDMAccCCy3 varchar(3)                 
	,REDMAccNo3 varchar(30)                 
	,REDMAccName3 varchar(100)                           
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
	INSERT #tmp_FinalDetail SELECT 3,'FirstName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 4,'MiddleName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 5,'LastName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 6,'CountryOfNationality', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 7,'CountryOfNationalityDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 8,'IDNo', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 9,'IDExpDate', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 10,'NPWPNo', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 11,'NPWRegDate', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 12,'CountryOfBirth', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 13,'PlaceOfBirth', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 14,'DateOfBirth', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 15,'Gender', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 16,'GenderDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 17,'Education', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 18,'EducationDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 19,'MotherName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 20,'Religion', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 21,'ReligionDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 22,'Occupation', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 23,'OccupationDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 24,'IncomeLevel', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 25,'IncomeLevelDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 26,'MaritalStatus', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 27,'MaritalStatusDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 28,'SpouseName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 29,'InvestorRiskProfile', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 30,'InvestorRiskProfileDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 31,'InvestmentObjective', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 32,'InvestmentObjectiveDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 33,'SourceOfFund', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 34,'SourceOfFundDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 35,'AssetOwner', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 36,'AssetOwnerDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 37,'KTPAddress', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 38,'KTPCityCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 39,'KTPCityCodeDesc', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 40,'KTPPostalCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 41,'CorrAddress', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 42,'CorrCityCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 43,'CorrCityName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 44,'CorrPostalCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 45,'CorrCountry', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 46,'DomicileAddress', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 47,'DomicileCityCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 48,'DomicileCityName', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 49,'DomicilePostalCode', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 50,'DomicileCountry', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 51,'HomePhone', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 52,'MobilePhone', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 53,'Facsimile', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 54,'Email', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 55,'StatementType', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 56,'FATCA', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 57,'TINStatus', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 58,'TINCountry', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 59,'REDMBIC1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 60,'REDMMemberCode1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 61,'REDMBankName1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 62,'REDMBankCountry1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 63,'REDMBankBranch1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 64,'REDMAccCcy1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 65,'REDMAccNo1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 66,'REDMAccName1', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 67,'REDMBIC2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 68,'REDMMemberCode2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 69,'REDMBankName2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 70,'REDMBankCountry2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 71,'REDMBankBranch2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 72,'REDMAccCCy2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 73,'REDMAccNo2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 74,'REDMAccName2', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 75,'REDMBIC3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 76,'REDMMemberCode3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 77,'REDMBankName3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 78,'REDMBankCountry3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 79,'REDMBankBranch3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 80,'REDMAccCCy3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 81,'REDMAccNo3', '', '', 'S'
	INSERT #tmp_FinalDetail SELECT 82,'REDMAccName3', '', '', 'S'
                    
    /*** DESCRIPTION ***/   
    
	INSERT #tmp_FieldDescription SELECT 2,'SID'
	INSERT #tmp_FieldDescription SELECT 3,'FirstName'
	INSERT #tmp_FieldDescription SELECT 4,'MiddleName'
	INSERT #tmp_FieldDescription SELECT 5,'LastName'
	INSERT #tmp_FieldDescription SELECT 6,'CountryOfNationality'
	INSERT #tmp_FieldDescription SELECT 7,'CountryOfNationalityDesc'
	INSERT #tmp_FieldDescription SELECT 8,'IDNo'
	INSERT #tmp_FieldDescription SELECT 9,'IDExpDate'
	INSERT #tmp_FieldDescription SELECT 10,'NPWPNo'
	INSERT #tmp_FieldDescription SELECT 11,'NPWRegDate'
	INSERT #tmp_FieldDescription SELECT 12,'CountryOfBirth'
	INSERT #tmp_FieldDescription SELECT 13,'PlaceOfBirth'
	INSERT #tmp_FieldDescription SELECT 14,'DateOfBirth'
	INSERT #tmp_FieldDescription SELECT 15,'Gender'
	INSERT #tmp_FieldDescription SELECT 16,'GenderDesc'
	INSERT #tmp_FieldDescription SELECT 17,'Education'
	INSERT #tmp_FieldDescription SELECT 18,'EducationDesc'
	INSERT #tmp_FieldDescription SELECT 19,'MotherName'
	INSERT #tmp_FieldDescription SELECT 20,'Religion'
	INSERT #tmp_FieldDescription SELECT 21,'ReligionDesc'
	INSERT #tmp_FieldDescription SELECT 22,'Occupation'
	INSERT #tmp_FieldDescription SELECT 23,'OccupationDesc'
	INSERT #tmp_FieldDescription SELECT 24,'IncomeLevel'
	INSERT #tmp_FieldDescription SELECT 25,'IncomeLevelDesc'
	INSERT #tmp_FieldDescription SELECT 26,'MaritalStatus'
	INSERT #tmp_FieldDescription SELECT 27,'MaritalStatusDesc'
	INSERT #tmp_FieldDescription SELECT 28,'SpouseName'
	INSERT #tmp_FieldDescription SELECT 29,'InvestorRiskProfile'
	INSERT #tmp_FieldDescription SELECT 30,'InvestorRiskProfileDesc'
	INSERT #tmp_FieldDescription SELECT 31,'InvestmentObjective'
	INSERT #tmp_FieldDescription SELECT 32,'InvestmentObjectiveDesc'
	INSERT #tmp_FieldDescription SELECT 33,'SourceOfFund'
	INSERT #tmp_FieldDescription SELECT 34,'SourceOfFundDesc'
	INSERT #tmp_FieldDescription SELECT 35,'AssetOwner'
	INSERT #tmp_FieldDescription SELECT 36,'AssetOwnerDesc'
	INSERT #tmp_FieldDescription SELECT 37,'KTPAddress'
	INSERT #tmp_FieldDescription SELECT 38,'KTPCityCode'
	INSERT #tmp_FieldDescription SELECT 39,'KTPCityCodeDesc'
	INSERT #tmp_FieldDescription SELECT 40,'KTPPostalCode'
	INSERT #tmp_FieldDescription SELECT 41,'CorrAddress'
	INSERT #tmp_FieldDescription SELECT 42,'CorrCityCode'
	INSERT #tmp_FieldDescription SELECT 43,'CorrCityName'
	INSERT #tmp_FieldDescription SELECT 44,'CorrPostalCode'
	INSERT #tmp_FieldDescription SELECT 45,'CorrCountry'
	INSERT #tmp_FieldDescription SELECT 46,'DomicileAddress'
	INSERT #tmp_FieldDescription SELECT 47,'DomicileCityCode'
	INSERT #tmp_FieldDescription SELECT 48,'DomicileCityName'
	INSERT #tmp_FieldDescription SELECT 49,'DomicilePostalCode'
	INSERT #tmp_FieldDescription SELECT 50,'DomicileCountry'
	INSERT #tmp_FieldDescription SELECT 51,'HomePhone'
	INSERT #tmp_FieldDescription SELECT 52,'MobilePhone'
	INSERT #tmp_FieldDescription SELECT 53,'Facsimile'
	INSERT #tmp_FieldDescription SELECT 54,'Email'
	INSERT #tmp_FieldDescription SELECT 55,'StatementType'
	INSERT #tmp_FieldDescription SELECT 56,'FATCA'
	INSERT #tmp_FieldDescription SELECT 57,'TINStatus'
	INSERT #tmp_FieldDescription SELECT 58,'TINCountry'
	INSERT #tmp_FieldDescription SELECT 59,'REDMBIC1'
	INSERT #tmp_FieldDescription SELECT 60,'REDMMemberCode1'
	INSERT #tmp_FieldDescription SELECT 61,'REDMBankName1'
	INSERT #tmp_FieldDescription SELECT 62,'REDMBankCountry1'
	INSERT #tmp_FieldDescription SELECT 63,'REDMBankBranch1'
	INSERT #tmp_FieldDescription SELECT 64,'REDMAccCcy1'
	INSERT #tmp_FieldDescription SELECT 65,'REDMAccNo1'
	INSERT #tmp_FieldDescription SELECT 66,'REDMAccName1'
	INSERT #tmp_FieldDescription SELECT 67,'REDMBIC2'
	INSERT #tmp_FieldDescription SELECT 68,'REDMMemberCode2'
	INSERT #tmp_FieldDescription SELECT 69,'REDMBankName2'
	INSERT #tmp_FieldDescription SELECT 70,'REDMBankCountry2'
	INSERT #tmp_FieldDescription SELECT 71,'REDMBankBranch2'
	INSERT #tmp_FieldDescription SELECT 72,'REDMAccCCy2'
	INSERT #tmp_FieldDescription SELECT 73,'REDMAccNo2'
	INSERT #tmp_FieldDescription SELECT 74,'REDMAccName2'
	INSERT #tmp_FieldDescription SELECT 75,'REDMBIC3'
	INSERT #tmp_FieldDescription SELECT 76,'REDMMemberCode3'
	INSERT #tmp_FieldDescription SELECT 77,'REDMBankName3'
	INSERT #tmp_FieldDescription SELECT 78,'REDMBankCountry3'
	INSERT #tmp_FieldDescription SELECT 79,'REDMBankBranch3'
	INSERT #tmp_FieldDescription SELECT 80,'REDMAccCCy3'
	INSERT #tmp_FieldDescription SELECT 81,'REDMAccNo3'
	INSERT #tmp_FieldDescription SELECT 82,'REDMAccName3'
            
    /*** INSERT DATA FROM HISTORY TABLE ***/
    EXEC sp_xml_preparedocument @hDoc output,@XML	
	insert into #tmp_AuthDetailNew (CIFNo,SID,FirstName,MiddleName,LastName,CountryOfNationality,IDNo,IDExpDate,NPWPNo,NPWRegDate,
	CountryOfBirth,PlaceOfBirth,DateOfBirth,Gender,Education,MotherName,Religion,Occupation,IncomeLevel,MaritalStatus,SpouseName,
	InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,KTPAddress,KTPCityCode,KTPPostalCode,CorrAddress,CorrCityCode,
	CorrCityName,CorrPostalCode,CorrCountry,DomicileAddress,DomicileCityCode,DomicileCityName,DomicilePostalCode,DomicileCountry,
	HomePhone,MobilePhone,Facsimile,Email,StatementType,FATCA,TINStatus,TINCountry,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,
	REDMBankBranch1,REDMAccCcy1,REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,
	REDMAccNo2,REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3)
	select CIFNo,SID,FirstName,MiddleName,LastName,CountryOfNationality,IDNo,IDExpDate,NPWPNo,NPWRegDate,
	CountryOfBirth,PlaceOfBirth,DateOfBirth,Gender,Education,MotherName,Religion,Occupation,IncomeLevel,MaritalStatus,SpouseName,
	InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,KTPAddress,KTPCityCode,KTPPostalCode,CorrAddress,CorrCityCode,
	CorrCityName,CorrPostalCode,CorrCountry,DomicileAddress,DomicileCityCode,DomicileCityName,DomicilePostalCode,DomicileCountry,
	HomePhone,MobilePhone,Facsimile,Email,StatementType,FATCA,TINStatus,TINCountry,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,
	REDMBankBranch1,REDMAccCcy1,REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,
	REDMAccNo2,REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3
	from OPENXML(@hDoc,'Root/DATA')	
	with
	(
	 CIFNo	Bigint 'CIFNo'			
	,SID	varchar(15) 'SID'
	,FirstName	varchar(100) 'FirstName'
	,MiddleName	varchar(30) 'MiddleName'
	,LastName	varchar(30) 'LastName'
	,CountryOfNationality	varchar(3) 'CountryOfNationality'
	,CountryOfNationalityDesc	varchar(30) 'CountryOfNationalityDesc'
	,IDNo	varchar(30)  'IDNo'
	,IDExpDate	varchar(8) 'IDExpDate'
	,NPWPNo	varchar(15) 'NPWPNo'
	,NPWRegDate	varchar(8) 'NPWRegDate'
	,CountryOfBirth	varchar(2) 'CountryOfBirth'
	,PlaceOfBirth	varchar(100) 'PlaceOfBirth'
	,DateOfBirth	varchar(8) 'DateOfBirth'
	,Gender	int 'Gender'
	,GenderDesc	varchar(10) 'GenderDesc'
	,Education	int 'Education'
	,EducationDesc	varchar(30) 'EducationDesc'
	,MotherName	varchar(100) 'MotherName'
	,Religion	int 'Religion'
	,ReligionDesc	varchar(20) 'ReligionDesc'
	,Occupation	int 'Occupation'
	,OccupationDesc	varchar(100) 'OccupationDesc'
	,IncomeLevel	int 'IncomeLevel'
	,IncomeLevelDesc	varchar(50) 'IncomeLevelDesc'
	,MaritalStatus	int 'MaritalStatus'
	,MaritalStatusDesc	varchar(30) 'MaritalStatusDesc'
	,SpouseName	varchar(100) 'SpouseName'
	,InvestorRiskProfile	int 'InvestorRiskProfile'
	,InvestorRiskProfileDesc	varchar(20) 'InvestorRiskProfileDesc'
	,InvestmentObjective	int 'InvestmentObjective'
	,InvestmentObjectiveDesc	varchar(30) 'InvestmentObjectiveDesc'
	,SourceOfFund	int 'SourceOfFund'
	,SourceOfFundDesc	varchar(50) 'SourceOfFundDesc'
	,AssetOwner	int 'AssetOwner'
	,AssetOwnerDesc	varchar(20) 'AssetOwnerDesc'
	,KTPAddress	varchar(100) 'KTPAddress'
	,KTPCityCode	varchar(4) 'KTPCityCode'
	,KTPCityCodeDesc	varchar(50) 'KTPCityCodeDesc'
	,KTPPostalCode	varchar(5) 'KTPPostalCode'
	,CorrAddress	varchar(100) 'CorrAddress'
	,CorrCityCode	varchar(4) 'CorrCityCode'
	,CorrCityName	varchar(100) 'CorrCityName'
	,CorrPostalCode	varchar(5) 'CorrPostalCode'
	,CorrCountry	varchar(2) 'CorrCountry'
	,DomicileAddress	varchar(100) 'DomicileAddress'
	,DomicileCityCode	varchar(4) 'DomicileCityCode'
	,DomicileCityName	varchar(100) 'DomicileCityName'
	,DomicilePostalCode	varchar(5) 'DomicilePostalCode'
	,DomicileCountry	varchar(2) 'DomicileCountry'
	,HomePhone	varchar(30) 'HomePhone'
	,MobilePhone	varchar(30) 'MobilePhone'
	,Facsimile	varchar(30) 'Facsimile'
	,Email	varchar(256) 'Email'
    ,StatementType	int 'StatementType'
	,FATCA	int 'FATCA'
	,TINStatus	varchar(30) 'TINStatus'
	,TINCountry	varchar(2) 'TINCountry'
	,REDMBIC1	varchar(11) 'REDMBIC1'
	,REDMMemberCode1	varchar(17) 'REDMMemberCode1'
	,REDMBankName1	varchar(100) 'REDMBankName1'
	,REDMBankCountry1	varchar(2) 'REDMBankCountry1'
	,REDMBankBranch1	varchar(20) 'REDMBankBranch1'
	,REDMAccCcy1	varchar(3) 'REDMAccCcy1'
	,REDMAccNo1	varchar(30) 'REDMAccNo1'
	,REDMAccName1	varchar(100) 'REDMAccName1'
	,REDMBIC2	varchar(11) 'REDMBIC2'
	,REDMMemberCode2	varchar(17) 'REDMMemberCode2'
	,REDMBankName2	varchar(100) 'REDMBankName2'
	,REDMBankCountry2	varchar(2) 'REDMBankCountry2'
	,REDMBankBranch2	varchar(20) 'REDMBankBranch2'
	,REDMAccCCy2	varchar(3) 'REDMAccCCy2'
	,REDMAccNo2	varchar(30) 'REDMAccNo2'
	,REDMAccName2	varchar(100) 'REDMAccName2'
	,REDMBIC3	varchar(11) 'REDMBIC3'
	,REDMMemberCode3	varchar(17) 'REDMMemberCode3'
	,REDMBankName3	varchar(100) 'REDMBankName3'
	,REDMBankCountry3	varchar(2) 'REDMBankCountry3'
	,REDMBankBranch3	varchar(20) 'REDMBankBranch3'
	,REDMAccCCy3	varchar(3) 'REDMAccCCy3'
	,REDMAccNo3	varchar(30) 'REDMAccNo3'
	,REDMAccName3	varchar(100) 'REDMAccName3'
	,ClientCode	varchar(20) 'ClientCode' 
	)
	where CIFNo = @pnCIFNumber			
	EXEC sp_xml_removedocument @hDoc     
    

	EXEC sp_xml_preparedocument @hDoc output,@XML	
	insert into #tmp_AuthDetailOld (CIFNo,SID,FirstName,MiddleName,LastName,CountryOfNationality,IDNo,IDExpDate,NPWPNo,NPWRegDate,
	CountryOfBirth,PlaceOfBirth,DateOfBirth,Gender,Education,MotherName,Religion,Occupation,IncomeLevel,MaritalStatus,SpouseName,
	InvestorRiskProfile,InvestmentObjective,SourceOfFund,AssetOwner,KTPAddress,KTPCityCode,KTPPostalCode,CorrAddress,CorrCityCode,
	CorrCityName,CorrPostalCode,CorrCountry,DomicileAddress,DomicileCityCode,DomicileCityName,DomicilePostalCode,DomicileCountry,
	HomePhone,MobilePhone,Facsimile,Email,StatementType,FATCA,TINStatus,TINCountry,REDMBIC1,REDMMemberCode1,REDMBankName1,REDMBankCountry1,
	REDMBankBranch1,REDMAccCcy1,REDMAccNo1,REDMAccName1,REDMBIC2,REDMMemberCode2,REDMBankName2,REDMBankCountry2,REDMBankBranch2,REDMAccCCy2,
	REDMAccNo2,REDMAccName2,REDMBIC3,REDMMemberCode3,REDMBankName3,REDMBankCountry3,REDMBankBranch3,REDMAccCCy3,REDMAccNo3,REDMAccName3)
	select CIFNo,SIDOld,FirstNameOld,MiddleNameOld,LastNameOld,CountryOfNationalityOld,IDNoOld,IDExpDateOld,NPWPNoOld,NPWRegDateOld,
	CountryOfBirthOld,PlaceOfBirthOld,DateOfBirthOld,GenderOld,EducationOld,MotherNameOld,ReligionOld,OccupationOld,IncomeLevelOld,MaritalStatusOld,SpouseNameOld,
	InvestorRiskProfileOld,InvestmentObjectiveOld,SourceOfFundOld,AssetOwnerOld,KTPAddressOld,KTPCityCodeOld,KTPPostalCodeOld,CorrAddressOld,CorrCityCodeOld,
	CorrCityNameOld,CorrPostalCodeOld,CorrCountryOld,DomicileAddressOld,DomicileCityCodeOld,DomicileCityNameOld,DomicilePostalCodeOld,DomicileCountryOld,
	HomePhoneOld,MobilePhoneOld,FacsimileOld,EmailOld,StatementTypeOld,FATCAOld,TINStatusOld,TINCountryOld,REDMBIC1Old,REDMMemberCode1Old,REDMBankName1Old,REDMBankCountry1Old,
	REDMBankBranch1Old,REDMAccCcy1Old,REDMAccNo1Old,REDMAccName1Old,REDMBIC2Old,REDMMemberCode2Old,REDMBankName2Old,REDMBankCountry2Old,REDMBankBranch2Old,REDMAccCCy2Old,
	REDMAccNo2Old,REDMAccName2Old,REDMBIC3Old,REDMMemberCode3Old,REDMBankName3Old,REDMBankCountry3Old,REDMBankBranch3Old,REDMAccCCy3Old,REDMAccNo3Old,REDMAccName3Old
	from OPENXML(@hDoc,'Root/DATA')	
	with
	(
	CIFNo	Bigint 'CIFNo',			
	SIDOld varchar(15) 'SIDOld',
	FirstNameOld varchar(100) 'FirstNameOld',
	MiddleNameOld varchar(30) 'MiddleNameOld',
	LastNameOld varchar(30) 'LastNameOld',
	CountryOfNationalityOld varchar(3) 'CountryOfNationalityOld',
	CountryOfNationalityDescOld varchar(30) 'CountryOfNationalityDescOld',
	IDNoOld varchar(30)  'IDNoOld',
	IDExpDateOld varchar(8) 'IDExpDateOld',
	NPWPNoOld varchar(15) 'NPWPNoOld',
	NPWRegDateOld varchar(8) 'NPWRegDateOld',
	CountryOfBirthOld varchar(2) 'CountryOfBirthOld',
	PlaceOfBirthOld varchar(100) 'PlaceOfBirthOld',
	DateOfBirthOld varchar(8) 'DateOfBirthOld',
	GenderOld int 'GenderOld',
	GenderDescOld varchar(10) 'GenderDescOld',
	EducationOld int 'EducationOld',
	EducationDescOld varchar(30) 'EducationDescOld',
	MotherNameOld varchar(100) 'MotherNameOld',
	ReligionOld int 'ReligionOld',
	ReligionDescOld varchar(20) 'ReligionDescOld',
	OccupationOld int 'OccupationOld',
	OccupationDescOld varchar(100) 'OccupationDescOld',
	IncomeLevelOld int 'IncomeLevelOld',
	IncomeLevelDescOld varchar(50) 'IncomeLevelDescOld',
	MaritalStatusOld int 'MaritalStatusOld',
	MaritalStatusDescOld varchar(30) 'MaritalStatusDescOld',
	SpouseNameOld varchar(100) 'SpouseNameOld',
	InvestorRiskProfileOld int 'InvestorRiskProfileOld',
	InvestorRiskProfileDescOld varchar(20) 'InvestorRiskProfileDescOld',
	InvestmentObjectiveOld int 'InvestmentObjectiveOld',
	InvestmentObjectiveDescOld varchar(30) 'InvestmentObjectiveDescOld',
	SourceOfFundOld int 'SourceOfFundOld',
	SourceOfFundDescOld varchar(50) 'SourceOfFundDescOld',
	AssetOwnerOld int 'AssetOwnerOld',
	AssetOwnerDescOld varchar(20) 'AssetOwnerDescOld',
	KTPAddressOld varchar(100) 'KTPAddressOld',
	KTPCityCodeOld varchar(4) 'KTPCityCodeOld',
	KTPCityCodeDescOld varchar(50) 'KTPCityCodeDescOld',
	KTPPostalCodeOld varchar(5) 'KTPPostalCodeOld',
	CorrAddressOld varchar(100) 'CorrAddressOld',
	CorrCityCodeOld varchar(4) 'CorrCityCodeOld',
	CorrCityNameOld varchar(100) 'CorrCityNameOld',
	CorrPostalCodeOld varchar(5) 'CorrPostalCodeOld',
	CorrCountryOld varchar(2) 'CorrCountryOld',
	DomicileAddressOld varchar(100) 'DomicileAddressOld',
	DomicileCityCodeOld varchar(4) 'DomicileCityCodeOld',
	DomicileCityNameOld varchar(100) 'DomicileCityNameOld',
	DomicilePostalCodeOld varchar(5) 'DomicilePostalCodeOld',
	DomicileCountryOld varchar(2) 'DomicileCountryOld',
	HomePhoneOld varchar(30) 'HomePhoneOld',
	MobilePhoneOld varchar(30) 'MobilePhoneOld',
	FacsimileOld varchar(30) 'FacsimileOld',
	EmailOld varchar(256) 'EmailOld',
    StatementTypeOld int 'StatementTypeOld',
	FATCAOld int 'FATCAOld',
	TINStatusOld varchar(30) 'TINStatusOld',
	TINCountryOld varchar(2) 'TINCountryOld',
	REDMBIC1Old varchar(11) 'REDMBIC1Old',
	REDMMemberCode1Old varchar(17) 'REDMMemberCode1Old',
	REDMBankName1Old varchar(100) 'REDMBankName1Old',
	REDMBankCountry1Old varchar(2) 'REDMBankCountry1Old',
	REDMBankBranch1Old varchar(20) 'REDMBankBranch1Old',
	REDMAccCcy1Old varchar(3) 'REDMAccCcy1Old',
	REDMAccNo1Old varchar(30) 'REDMAccNo1Old',
	REDMAccName1Old varchar(100) 'REDMAccName1Old',
	REDMBIC2Old varchar(11) 'REDMBIC2Old',
	REDMMemberCode2Old varchar(17) 'REDMMemberCode2Old',
	REDMBankName2Old varchar(100) 'REDMBankName2Old',
	REDMBankCountry2Old varchar(2) 'REDMBankCountry2Old',
	REDMBankBranch2Old varchar(20) 'REDMBankBranch2Old',
	REDMAccCCy2Old varchar(3) 'REDMAccCCy2Old',
	REDMAccNo2Old varchar(30) 'REDMAccNo2Old',
	REDMAccName2Old varchar(100) 'REDMAccName2Old',
	REDMBIC3Old varchar(11) 'REDMBIC3Old',
	REDMMemberCode3Old varchar(17) 'REDMMemberCode3Old',
	REDMBankName3Old varchar(100) 'REDMBankName3Old',
	REDMBankCountry3Old varchar(2) 'REDMBankCountry3Old',
	REDMBankBranch3Old varchar(20) 'REDMBankBranch3Old',
	REDMAccCCy3Old varchar(3) 'REDMAccCCy3Old',
	REDMAccNo3Old varchar(30) 'REDMAccNo3Old',
	REDMAccName3Old varchar(100) 'REDMAccName3Old'
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