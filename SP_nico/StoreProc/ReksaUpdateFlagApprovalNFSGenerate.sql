CREATE proc [dbo].[ReksaUpdateFlagApprovalNFSGenerate]  
/*  
 CREATED BY    : Andhika J    
 CREATION DATE : 20180703 
 DESCRIPTION   :     
 REVISED BY    :    
  DATE,  USER,   PROJECT,  NOTE    
  -----------------------------------------------------------------------    
  exec ReksaUpdateFlagApprovalNFSGenerate 147,'PSOPRHEAD01U1','A'
 END REVISED     
  
*/   
@pnLogId int  
,@pnNIK varchar(50) = NULL
,@pnType varchar(5)
as  
set nocount on  
  
declare   
	 @nErrNo    int  
	,@nOK    int   
	,@cErrMsg   varchar(100)
	,@XML AS XML
	,@hDoc AS INT
	,@SQL NVARCHAR(MAX)
	,@TypeUpload varchar(5)
	,@Period int 

if (@pnType = 'R') -- else Reject
	begin
		update ReksaNFSFileRequest_TT
		set
			AuthStatus = @pnType,
			AuthDate = getdate(),
			AuthUser = @pnNIK
		where LogId = @pnLogId  and AuthStatus = 'P'
	end
else
	begin

		update ReksaNFSFileRequest_TT
		set
			AuthStatus = @pnType,
			AuthDate = getdate(),
			AuthUser = @pnNIK
		where LogId = @pnLogId  and AuthStatus = 'P'
	end

if exists (select top 1 1 from ReksaNFSFileRequest_TT where LogId = @pnLogId and AuthStatus = 'A')
	begin
		

		SELECT @Period = Period , @XML = RawData,@TypeUpload = SUBSTRING(FileName,5,3) from ReksaNFSFileRequest_TT
        where LogId = @pnLogId and AuthStatus = 'A'


		if (@TypeUpload = 'IND' and @pnType = 'A') -- Jika Individu dan status Approve 
			begin
				

				if exists (select top 1 1 from ReksaNFSFileRequest_TM where LogId = @pnLogId and @TypeUpload = 'IND' and @pnType = 'A')
				   begin
						delete from ReksaNFSFileRequest_TM where LogId = @pnLogId and Type = 'IND'
						
						EXEC sp_xml_preparedocument @hDoc output,@XML
						insert into ReksaNFSFileRequest_TM (LogId,Period,Type,SACode,SID,SIDOld,FirstName,FirstNameOld,MiddleName,MiddleNameOld,LastName,LastNameOld,CountryOfNationality,CountryOfNationalityOld,CountryOfNationalityDesc,CountryOfNationalityDescOld
						,IDNo,IDNoOld,IDExpDate,IDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfBirth,CountryOfBirthOld,PlaceOfBirth,PlaceOfBirthOld,DateOfBirth,DateOfBirthOld,Gender,GenderOld,GenderDesc,GenderDescOld,Education,EducationOld,
						EducationDesc,EducationDescOld,MotherName,MotherNameOld,Religion,ReligionOld,ReligionDesc,ReligionDescOld,Occupation,OccupationOld,OccupationDesc,OccupationDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,MaritalStatus,
						MaritalStatusOld,
						MaritalStatusDesc,MaritalStatusDescOld,SpouseName,SpouseNameOld,InvestorRiskProfile,InvestorRiskProfileOld,InvestorRiskProfileDesc,InvestorRiskProfileDescOld
						,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld
						,SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,KTPAddress,KTPAddressOld,KTPCityCode,KTPCityCodeOld,KTPCityCodeDesc,KTPCityCodeDescOld,KTPPostalCode,KTPPostalCodeOld,
						CorrAddress,CorrAddressOld,CorrCityCode,CorrCityCodeOld,CorrCityName,CorrCityNameOld,CorrPostalCode,CorrPostalCodeOld,CorrCountry,CorrCountryOld,DomicileAddress,DomicileAddressOld,DomicileCityCode,DomicileCityCodeOld,DomicileCityName,
						DomicileCityNameOld,
						DomicilePostalCode,DomicilePostalCodeOld,DomicileCountry,DomicileCountryOld,HomePhone,HomePhoneOld,MobilePhone,MobilePhoneOld,Facsimile,FacsimileOld,
						Email,EmailOld,StatementType,StatementTypeOld,FATCA,FATCAOld,TINStatus,TINStatusOld,TINCountry,TINCountryOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,REDMBankBranch1,






						REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,
						REDMBankBranch2Old,REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,
						REDMBankBranch3Old,REDMAccCCy3,
						REDMAccCCy3Old,REDMAccNo3,REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIF)
						select @pnLogId,@Period,@TypeUpload,SACode,SID,SIDOld,FirstName,FirstNameOld,MiddleName,MiddleNameOld,LastName,LastNameOld,CountryOfNationality,CountryOfNationalityOld,CountryOfNationalityDesc,CountryOfNationalityDescOld
						,IDNo,IDNoOld,IDExpDate,IDExpDateOld,NPWPNo,NPWPNoOld,NPWRegDate,NPWRegDateOld,CountryOfBirth,CountryOfBirthOld,PlaceOfBirth,PlaceOfBirthOld,DateOfBirth,DateOfBirthOld,Gender,GenderOld,GenderDesc,GenderDescOld,Education,EducationOld,
						EducationDesc,EducationDescOld,MotherName,MotherNameOld,Religion,ReligionOld,ReligionDesc,ReligionDescOld,Occupation,OccupationOld,OccupationDesc,OccupationDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,MaritalStatus,
						MaritalStatusOld,MaritalStatusDesc,MaritalStatusDescOld,SpouseName,SpouseNameOld,InvestorRiskProfile,InvestorRiskProfileOld,InvestorRiskProfileDesc,InvestorRiskProfileDescOld
						,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld
						,SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,KTPAddress,KTPAddressOld,KTPCityCode,KTPCityCodeOld,KTPCityCodeDesc,KTPCityCodeDescOld,KTPPostalCode,KTPPostalCodeOld,
						CorrAddress,CorrAddressOld,CorrCityCode,CorrCityCodeOld,CorrCityName,CorrCityNameOld,CorrPostalCode,CorrPostalCodeOld,CorrCountry,CorrCountryOld,DomicileAddress,DomicileAddressOld,DomicileCityCode,DomicileCityCodeOld,DomicileCityName,
						DomicileCityNameOld,
						DomicilePostalCode,DomicilePostalCodeOld,DomicileCountry,DomicileCountryOld,HomePhone,HomePhoneOld,MobilePhone,MobilePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,FATCA,FATCAOld,TINStatus,TINStatusOld,
						TINCountry,TINCountryOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,






						REDMAccName1Old,REDMBIC2,
						REDMBIC2Old,REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3
						,REDMBIC3Old
		,
						REDMMemberCode3,REDMMemberCode3Old,REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIFNo


						from OPENXML(@hDoc,'Root/DATA')
						with
						(
						SACode	varchar(5) 'SACode'
						,SID	varchar(15) 'SID'
						,SIDOld	varchar(15) 'SIDOld'
						,FirstName	varchar(100) 'FirstName'
						,FirstNameOld	varchar(100) 'FirstNameOld'
						,MiddleName	varchar(30) 'MiddleName'
						,MiddleNameOld	varchar(30) 'MiddleNameOld'
						,LastName	varchar(30) 'LastName'
						,LastNameOld	varchar(30) 'LastNameOld'
						,CountryOfNationality	varchar(3) 'CountryOfNationality'
						,CountryOfNationalityOld	varchar(3) 'CountryOfNationalityOld'
						,CountryOfNationalityDesc	varchar(30) 'CountryOfNationalityDesc'
						,CountryOfNationalityDescOld	varchar(30) 'CountryOfNationalityDescOld'
						,IDNo	varchar(30)  'IDNo'
						,IDNoOld	varchar(30) 'IDNoOld'
						,IDExpDate	varchar(8) 'IDExpDate'
						,IDExpDateOld	varchar(8) 'IDExpDateOld'
						,NPWPNo	varchar(15) 'NPWPNo'
						,NPWPNoOld	varchar(15) 'NPWPNoOld'
						,NPWRegDate	varchar(8) 'NPWRegDate'
						,NPWRegDateOld	varchar(8) 'NPWRegDateOld'
						,CountryOfBirth	varchar(2) 'CountryOfBirth'
						,CountryOfBirthOld	varchar(2) 'CountryOfBirthOld'
						,PlaceOfBirth	varchar(100) 'PlaceOfBirth'
						,PlaceOfBirthOld	varchar(100) 'PlaceOfBirthOld'
						,DateOfBirth	varchar(8) 'DateOfBirth'
						,DateOfBirthOld	varchar(8) 'DateOfBirthOld'
						,Gender	int 'Gender'
						,GenderOld	int 'GenderOld'
						,GenderDesc	varchar(10) 'GenderDesc'
						,GenderDescOld	varchar(10) 'GenderDescOld'
						,Education	int 'Education'
						,EducationOld	int 'EducationOld'
						,EducationDesc	varchar(30) 'EducationDesc'
						,EducationDescOld	varchar(30) 'EducationDescOld'
						,MotherName	varchar(100) 'MotherName'
						,MotherNameOld	varchar(100) 'MotherNameOld'
						,Religion	int 'Religion'
						,ReligionOld	int 'ReligionOld'
						,ReligionDesc	varchar(20) 'ReligionDesc'
						,ReligionDescOld	varchar(20) 'ReligionDescOld'
						,Occupation	int 'Occupation'
						,OccupationOld	int 'OccupationOld'
						,OccupationDesc	varchar(100) 'OccupationDesc'
						,OccupationDescOld	varchar(100) 'OccupationDescOld'
						,IncomeLevel	int 'IncomeLevel'
						,IncomeLevelOld	int 'IncomeLevelOld'
						,IncomeLevelDesc	varchar(50) 'IncomeLevelDesc'
						,IncomeLevelDescOld	varchar(50) 'IncomeLevelDescOld'
						,MaritalStatus	int 'MaritalStatus'
						,MaritalStatusOld	int 'MaritalStatusOld'
						,MaritalStatusDesc	varchar(30) 'MaritalStatusDesc'
						,MaritalStatusDescOld	varchar(30) 'MaritalStatusDescOld'
						,SpouseName	varchar(100) 'SpouseName'
						,SpouseNameOld	varchar(100) 'SpouseNameOld' 
						,InvestorRiskProfile	int 'InvestorRiskProfile'
						,InvestorRiskProfileOld	int 'InvestorRiskProfileOld'
						,InvestorRiskProfileDesc	varchar(20) 'InvestorRiskProfileDesc'
						,InvestorRiskProfileDescOld	varchar(20) 'InvestorRiskProfileDescOld'
						,InvestmentObjective	int 'InvestmentObjective'
						,InvestmentObjectiveOld	int 'InvestmentObjectiveOld'
						,InvestmentObjectiveDesc	varchar(30) 'InvestmentObjectiveDesc'
						,InvestmentObjectiveDescOld	varchar(30) 'InvestmentObjectiveDescOld'
						,SourceOfFund	int 'SourceOfFund'
						,SourceOfFundOld	int 'SourceOfFundOld'
						,SourceOfFundDesc	varchar(50) 'SourceOfFundDesc'
						,SourceOfFundDescOld	varchar(50) 'SourceOfFundDescOld'
						,AssetOwner	int 'AssetOwner'
						,AssetOwnerOld	int 'AssetOwnerOld'
						,AssetOwnerDesc	varchar(20) 'AssetOwnerDesc'
						,AssetOwnerDescOld	varchar(20) 'AssetOwnerDescOld'
						,KTPAddress	varchar(100) 'KTPAddress'
						,KTPAddressOld	varchar(100) 'KTPAddressOld'
						,KTPCityCode	varchar(4) 'KTPCityCode'
						,KTPCityCodeOld	varchar(4) 'KTPCityCodeOld'
						,KTPCityCodeDesc	varchar(50) 'KTPCityCodeDesc'
						,KTPCityCodeDescOld	varchar(50) 'KTPCityCodeDescOld'
						,KTPPostalCode	varchar(5) 'KTPPostalCode'
						,KTPPostalCodeOld	varchar(5) 'KTPPostalCodeOld'
						,CorrAddress	varchar(100) 'CorrAddress'
						,CorrAddressOld	varchar(100) 'CorrAddressOld'
						,CorrCityCode	varchar(4) 'CorrCityCode'
						,CorrCityCodeOld	varchar(4) 'CorrCityCodeOld'
						,CorrCityName	varchar(100) 'CorrCityName'
						,CorrCityNameOld	varchar(100) 'CorrCityNameOld'
						,CorrPostalCode	varchar(5) 'CorrPostalCode'
						,CorrPostalCodeOld	varchar(5) 'CorrPostalCodeOld'
						,CorrCountry	varchar(2) 'CorrCountry'
						,CorrCountryOld	varchar(2) 'CorrCountryOld'
						,DomicileAddress	varchar(100) 'DomicileAddress'
						,DomicileAddressOld	varchar(100) 'DomicileAddressOld'
						,DomicileCityCode	varchar(4) 'DomicileCityCode'
						,DomicileCityCodeOld	varchar(4) 'DomicileCityCodeOld'
						,DomicileCityName	varchar(100) 'DomicileCityName'
						,DomicileCityNameOld	varchar(100) 'DomicileCityNameOld'
						,DomicilePostalCode	varchar(5) 'DomicilePostalCode'
						,DomicilePostalCodeOld	varchar(5) 'DomicilePostalCodeOld'
						,DomicileCountry	varchar(2) 'DomicileCountry'
						,DomicileCountryOld	varchar(2) 'DomicileCountryOld'
						,HomePhone	varchar(30) 'HomePhone'
						,HomePhoneOld	varchar(30) 'HomePhoneOld'
						,MobilePhone	varchar(30) 'MobilePhone'
						,MobilePhoneOld	varchar(30) 'MobilePhoneOld'
						,Facsimile	varchar(30) 'Facsimile'
						,FacsimileOld	varchar(30) 'FacsimileOld'
						,Email	varchar(256) 'Email'
						,EmailOld	varchar(256) 'EmailOld'
						,StatementType	int 'StatementType'
						,StatementTypeOld	int 'StatementTypeOld'
						,FATCA	int 'FATCA'
						,FATCAOld	int 'FATCAOld'
						,TINStatus	varchar(30) 'TINStatus'
						,TINStatusOld	varchar(30) 'TINStatusOld'
						,TINCountry	varchar(2) 'TINCountry'
						,TINCountryOld	varchar(2) 'TINCountryOld'
						,REDMBIC1	varchar(11) 'REDMBIC1'
						,REDMBIC1Old	varchar(11) 'REDMBIC1Old'
						,REDMMemberCode1	varchar(17) 'REDMMemberCode1'
						,REDMMemberCode1Old	varchar(17) 'REDMMemberCode1Old'
						,REDMBankName1	varchar(100) 'REDMBankName1'
						,REDMBankName1Old	varchar(100) 'REDMBankName1Old'
						,REDMBankCountry1	varchar(2) 'REDMBankCountry1'
						,REDMBankCountry1Old	varchar(2) 'REDMBankCountry1Old'
						,REDMBankBranch1	varchar(20) 'REDMBankBranch1'
						,REDMBankBranch1Old	varchar(20) 'REDMBankBranch1Old'
						,REDMAccCcy1	varchar(3) 'REDMAccCcy1'
						,REDMAccCcy1Old	varchar(3) 'REDMAccCcy1Old'
						,REDMAccNo1	varchar(30) 'REDMAccNo1'
						,REDMAccNo1Old	varchar(30) 'REDMAccNo1Old'
						,REDMAccName1	varchar(100) 'REDMAccName1'
						,REDMAccName1Old	varchar(100) 'REDMAccName1Old'
						,REDMBIC2	varchar(11) 'REDMBIC2'
						,REDMBIC2Old	varchar(11) 'REDMBIC2Old'
						,REDMMemberCode2	varchar(17) 'REDMMemberCode2'
						,REDMMemberCode2Old	varchar(17) 'REDMMemberCode2Old'
						,REDMBankName2	varchar(100) 'REDMBankName2'
						,REDMBankName2Old	varchar(100) 'REDMBankName2Old'
						,REDMBankCountry2	varchar(2) 'REDMBankCountry2'
						,REDMBankCountry2Old	varchar(2) 'REDMBankCountry2Old'
						,REDMBankBranch2	varchar(20) 'REDMBankBranch2'
						,REDMBankBranch2Old	varchar(20) 'REDMBankBranch2Old'
						,REDMAccCCy2	varchar(3) 'REDMAccCCy2'
						,REDMAccCCy2Old	varchar(3) 'REDMAccCCy2Old'
						,REDMAccNo2	varchar(30) 'REDMAccNo2'
						,REDMAccNo2Old	varchar(30) 'REDMAccNo2Old'
						,REDMAccName2	varchar(100) 'REDMAccName2'
						,REDMAccName2Old	varchar(100) 'REDMAccName2Old'
						,REDMBIC3	varchar(11) 'REDMBIC3'
						,REDMBIC3Old	varchar(11) 'REDMBIC3Old'
						,REDMMemberCode3	varchar(17) 'REDMMemberCode3'
						,REDMMemberCode3Old	varchar(17) 'REDMMemberCode3Old'
						,REDMBankName3	varchar(100) 'REDMBankName3'
						,REDMBankName3Old	varchar(100) 'REDMBankName3Old'
						,REDMBankCountry3	varchar(2) 'REDMBankCountry3'
						,REDMBankCountry3Old	varchar(2) 'REDMBankCountry3Old'
						,REDMBankBranch3	varchar(20) 'REDMBankBranch3'
						,REDMBankBranch3Old	varchar(20) 'REDMBankBranch3Old'
						,REDMAccCCy3	varchar(3) 'REDMAccCCy3'
						,REDMAccCCy3Old	varchar(3) 'REDMAccCCy3Old'
						,REDMAccNo3	varchar(30) 'REDMAccNo3'
						,REDMAccNo3Old	varchar(30) 'REDMAccNo3Old'
						,REDMAccName3	varchar(100) 'REDMAccName3'
						,REDMAccName3Old	varchar(100) 'REDMAccName3Old'
						,ClientCode	varchar(20) 'ClientCode'
						,ClientCodeOld varchar(20) 'ClientCodeOld'
						,CIFNo bigint 'CIFNo'
						)
						EXEC sp_xml_removedocument @hDoc
				   end
				else
				   begin
					EXEC sp_xml_preparedocument @hDoc output,@XML
						insert into ReksaNFSFileRequest_TM (LogId,Period,Type,SACode,SID,SIDOld,FirstName,FirstNameOld,MiddleName,MiddleNameOld,LastName,LastNameOld,CountryOfNationality,CountryOfNationalityOld,CountryOfNationalityDesc,CountryOfNationalityDescOld
						,IDNo,IDNoOld,IDExpDate,IDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfBirth,CountryOfBirthOld,PlaceOfBirth,PlaceOfBirthOld,DateOfBirth,DateOfBirthOld,Gender,GenderOld,GenderDesc,GenderDescOld,Education,EducationOld,
						EducationDesc,EducationDescOld,MotherName,MotherNameOld,Religion,ReligionOld,ReligionDesc,ReligionDescOld,Occupation,OccupationOld,OccupationDesc,OccupationDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,MaritalStatus,
						MaritalStatusOld,
						MaritalStatusDesc,MaritalStatusDescOld,SpouseName,SpouseNameOld,InvestorRiskProfile,InvestorRiskProfileOld,InvestorRiskProfileDesc,InvestorRiskProfileDescOld
						,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld
						,SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,KTPAddress,KTPAddressOld,KTPCityCode,KTPCityCodeOld,KTPCityCodeDesc,KTPCityCodeDescOld,KTPPostalCode,KTPPostalCodeOld,
						CorrAddress,CorrAddressOld,CorrCityCode,CorrCityCodeOld,CorrCityName,CorrCityNameOld,CorrPostalCode,CorrPostalCodeOld,CorrCountry,CorrCountryOld,DomicileAddress,DomicileAddressOld,DomicileCityCode,DomicileCityCodeOld,DomicileCityName,
						DomicileCityNameOld,
						DomicilePostalCode,DomicilePostalCodeOld,DomicileCountry,DomicileCountryOld,HomePhone,HomePhoneOld,MobilePhone,MobilePhoneOld,Facsimile,FacsimileOld,
						Email,EmailOld,StatementType,StatementTypeOld,FATCA,FATCAOld,TINStatus,TINStatusOld,TINCountry,TINCountryOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,REDMBankBranch1,






						REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,
						REDMBankBranch2Old,REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,
						REDMBankBranch3Old,REDMAccCCy3,
						REDMAccCCy3Old,REDMAccNo3,REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIF)
						select @pnLogId,@Period,@TypeUpload,SACode,SID,SIDOld,FirstName,FirstNameOld,MiddleName,MiddleNameOld,LastName,LastNameOld,CountryOfNationality,CountryOfNationalityOld,CountryOfNationalityDesc,CountryOfNationalityDescOld
						,IDNo,IDNoOld,IDExpDate,IDExpDateOld,NPWPNo,NPWPNoOld,NPWRegDate,NPWRegDateOld,CountryOfBirth,CountryOfBirthOld,PlaceOfBirth,PlaceOfBirthOld,DateOfBirth,DateOfBirthOld,Gender,GenderOld,GenderDesc,GenderDescOld,Education,EducationOld,
						EducationDesc,EducationDescOld,MotherName,MotherNameOld,Religion,ReligionOld,ReligionDesc,ReligionDescOld,Occupation,OccupationOld,OccupationDesc,OccupationDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,MaritalStatus,
						MaritalStatusOld,MaritalStatusDesc,MaritalStatusDescOld,SpouseName,SpouseNameOld,InvestorRiskProfile,InvestorRiskProfileOld,InvestorRiskProfileDesc,InvestorRiskProfileDescOld
						,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld
						,SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,KTPAddress,KTPAddressOld,KTPCityCode,KTPCityCodeOld,KTPCityCodeDesc,KTPCityCodeDescOld,KTPPostalCode,KTPPostalCodeOld,
						CorrAddress,CorrAddressOld,CorrCityCode,CorrCityCodeOld,CorrCityName,CorrCityNameOld,CorrPostalCode,CorrPostalCodeOld,CorrCountry,CorrCountryOld,DomicileAddress,DomicileAddressOld,DomicileCityCode,DomicileCityCodeOld,DomicileCityName,
						DomicileCityNameOld,
						DomicilePostalCode,DomicilePostalCodeOld,DomicileCountry,DomicileCountryOld,HomePhone,HomePhoneOld,MobilePhone,MobilePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,FATCA,FATCAOld,TINStatus,TINStatusOld,
						TINCountry,TINCountryOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,






						REDMAccName1Old,REDMBIC2,
						REDMBIC2Old,REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,
						REDMBIC3Old
		,
						REDMMemberCode3,REDMMemberCode3Old,REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIFNo


						from OPENXML(@hDoc,'Root/DATA')
						with
						(
						SACode	varchar(5) 'SACode'
						,SID	varchar(15) 'SID'
						,SIDOld	varchar(15) 'SIDOld'
						,FirstName	varchar(100) 'FirstName'
						,FirstNameOld	varchar(100) 'FirstNameOld'
						,MiddleName	varchar(30) 'MiddleName'
						,MiddleNameOld	varchar(30) 'MiddleNameOld'
						,LastName	varchar(30) 'LastName'
						,LastNameOld	varchar(30) 'LastNameOld'
						,CountryOfNationality	varchar(3) 'CountryOfNationality'
						,CountryOfNationalityOld	varchar(3) 'CountryOfNationalityOld'
						,CountryOfNationalityDesc	varchar(30) 'CountryOfNationalityDesc'
						,CountryOfNationalityDescOld	varchar(30) 'CountryOfNationalityDescOld'
						,IDNo	varchar(30)  'IDNo'
						,IDNoOld	varchar(30) 'IDNoOld'
						,IDExpDate	varchar(8) 'IDExpDate'
						,IDExpDateOld	varchar(8) 'IDExpDateOld'
						,NPWPNo	varchar(15) 'NPWPNo'
						,NPWPNoOld	varchar(15) 'NPWPNoOld'
						,NPWRegDate	varchar(8) 'NPWRegDate'
						,NPWRegDateOld	varchar(8) 'NPWRegDateOld'
						,CountryOfBirth	varchar(2) 'CountryOfBirth'
						,CountryOfBirthOld	varchar(2) 'CountryOfBirthOld'
						,PlaceOfBirth	varchar(100) 'PlaceOfBirth'
						,PlaceOfBirthOld	varchar(100) 'PlaceOfBirthOld'
						,DateOfBirth	varchar(8) 'DateOfBirth'
						,DateOfBirthOld	varchar(8) 'DateOfBirthOld'
						,Gender	int 'Gender'
						,GenderOld	int 'GenderOld'
						,GenderDesc	varchar(10) 'GenderDesc'
						,GenderDescOld	varchar(10) 'GenderDescOld'
						,Education	int 'Education'
						,EducationOld	int 'EducationOld'
						,EducationDesc	varchar(30) 'EducationDesc'
						,EducationDescOld	varchar(30) 'EducationDescOld'
						,MotherName	varchar(100) 'MotherName'
						,MotherNameOld	varchar(100) 'MotherNameOld'
						,Religion	int 'Religion'
						,ReligionOld	int 'ReligionOld'
						,ReligionDesc	varchar(20) 'ReligionDesc'
						,ReligionDescOld	varchar(20) 'ReligionDescOld'
						,Occupation	int 'Occupation'
						,OccupationOld	int 'OccupationOld'
						,OccupationDesc	varchar(100) 'OccupationDesc'
						,OccupationDescOld	varchar(100) 'OccupationDescOld'
						,IncomeLevel	int 'IncomeLevel'
						,IncomeLevelOld	int 'IncomeLevelOld'
						,IncomeLevelDesc	varchar(50) 'IncomeLevelDesc'
						,IncomeLevelDescOld	varchar(50) 'IncomeLevelDescOld'
						,MaritalStatus	int 'MaritalStatus'
						,MaritalStatusOld	int 'MaritalStatusOld'
						,MaritalStatusDesc	varchar(30) 'MaritalStatusDesc'
						,MaritalStatusDescOld	varchar(30) 'MaritalStatusDescOld'
						,SpouseName	varchar(100) 'SpouseName'
						,SpouseNameOld	varchar(100) 'SpouseNameOld' 
						,InvestorRiskProfile	int 'InvestorRiskProfile'
						,InvestorRiskProfileOld	int 'InvestorRiskProfileOld'
						,InvestorRiskProfileDesc	varchar(20) 'InvestorRiskProfileDesc'
						,InvestorRiskProfileDescOld	varchar(20) 'InvestorRiskProfileDescOld'
						,InvestmentObjective	int 'InvestmentObjective'
						,InvestmentObjectiveOld	int 'InvestmentObjectiveOld'
						,InvestmentObjectiveDesc	varchar(30) 'InvestmentObjectiveDesc'
						,InvestmentObjectiveDescOld	varchar(30) 'InvestmentObjectiveDescOld'
						,SourceOfFund	int 'SourceOfFund'
						,SourceOfFundOld	int 'SourceOfFundOld'
						,SourceOfFundDesc	varchar(50) 'SourceOfFundDesc'
						,SourceOfFundDescOld	varchar(50) 'SourceOfFundDescOld'
						,AssetOwner	int 'AssetOwner'
						,AssetOwnerOld	int 'AssetOwnerOld'
						,AssetOwnerDesc	varchar(20) 'AssetOwnerDesc'
						,AssetOwnerDescOld	varchar(20) 'AssetOwnerDescOld'
						,KTPAddress	varchar(100) 'KTPAddress'
						,KTPAddressOld	varchar(100) 'KTPAddressOld'
						,KTPCityCode	varchar(4) 'KTPCityCode'
						,KTPCityCodeOld	varchar(4) 'KTPCityCodeOld'
						,KTPCityCodeDesc	varchar(50) 'KTPCityCodeDesc'
						,KTPCityCodeDescOld	varchar(50) 'KTPCityCodeDescOld'
						,KTPPostalCode	varchar(5) 'KTPPostalCode'
						,KTPPostalCodeOld	varchar(5) 'KTPPostalCodeOld'
						,CorrAddress	varchar(100) 'CorrAddress'
						,CorrAddressOld	varchar(100) 'CorrAddressOld'
						,CorrCityCode	varchar(4) 'CorrCityCode'
						,CorrCityCodeOld	varchar(4) 'CorrCityCodeOld'
						,CorrCityName	varchar(100) 'CorrCityName'
						,CorrCityNameOld	varchar(100) 'CorrCityNameOld'
						,CorrPostalCode	varchar(5) 'CorrPostalCode'
						,CorrPostalCodeOld	varchar(5) 'CorrPostalCodeOld'
						,CorrCountry	varchar(2) 'CorrCountry'
						,CorrCountryOld	varchar(2) 'CorrCountryOld'
						,DomicileAddress	varchar(100) 'DomicileAddress'
						,DomicileAddressOld	varchar(100) 'DomicileAddressOld'
						,DomicileCityCode	varchar(4) 'DomicileCityCode'
						,DomicileCityCodeOld	varchar(4) 'DomicileCityCodeOld'
						,DomicileCityName	varchar(100) 'DomicileCityName'
						,DomicileCityNameOld	varchar(100) 'DomicileCityNameOld'
						,DomicilePostalCode	varchar(5) 'DomicilePostalCode'
						,DomicilePostalCodeOld	varchar(5) 'DomicilePostalCodeOld'
						,DomicileCountry	varchar(2) 'DomicileCountry'
						,DomicileCountryOld	varchar(2) 'DomicileCountryOld'
						,HomePhone	varchar(30) 'HomePhone'
						,HomePhoneOld	varchar(30) 'HomePhoneOld'
						,MobilePhone	varchar(30) 'MobilePhone'
						,MobilePhoneOld	varchar(30) 'MobilePhoneOld'
						,Facsimile	varchar(30) 'Facsimile'
						,FacsimileOld	varchar(30) 'FacsimileOld'
						,Email	varchar(256) 'Email'
						,EmailOld	varchar(256) 'EmailOld'
						,StatementType	int 'StatementType'
						,StatementTypeOld	int 'StatementTypeOld'
						,FATCA	int 'FATCA'
						,FATCAOld	int 'FATCAOld'
						,TINStatus	varchar(30) 'TINStatus'
						,TINStatusOld	varchar(30) 'TINStatusOld'
						,TINCountry	varchar(2) 'TINCountry'
						,TINCountryOld	varchar(2) 'TINCountryOld'
						,REDMBIC1	varchar(11) 'REDMBIC1'
						,REDMBIC1Old	varchar(11) 'REDMBIC1Old'
						,REDMMemberCode1	varchar(17) 'REDMMemberCode1'
						,REDMMemberCode1Old	varchar(17) 'REDMMemberCode1Old'
						,REDMBankName1	varchar(100) 'REDMBankName1'
						,REDMBankName1Old	varchar(100) 'REDMBankName1Old'
						,REDMBankCountry1	varchar(2) 'REDMBankCountry1'
						,REDMBankCountry1Old	varchar(2) 'REDMBankCountry1Old'
						,REDMBankBranch1	varchar(20) 'REDMBankBranch1'
						,REDMBankBranch1Old	varchar(20) 'REDMBankBranch1Old'
						,REDMAccCcy1	varchar(3) 'REDMAccCcy1'
						,REDMAccCcy1Old	varchar(3) 'REDMAccCcy1Old'
						,REDMAccNo1	varchar(30) 'REDMAccNo1'
						,REDMAccNo1Old	varchar(30) 'REDMAccNo1Old'
						,REDMAccName1	varchar(100) 'REDMAccName1'
						,REDMAccName1Old	varchar(100) 'REDMAccName1Old'
						,REDMBIC2	varchar(11) 'REDMBIC2'
						,REDMBIC2Old	varchar(11) 'REDMBIC2Old'
						,REDMMemberCode2	varchar(17) 'REDMMemberCode2'
						,REDMMemberCode2Old	varchar(17) 'REDMMemberCode2Old'
						,REDMBankName2	varchar(100) 'REDMBankName2'
						,REDMBankName2Old	varchar(100) 'REDMBankName2Old'
						,REDMBankCountry2	varchar(2) 'REDMBankCountry2'
						,REDMBankCountry2Old	varchar(2) 'REDMBankCountry2Old'
						,REDMBankBranch2	varchar(20) 'REDMBankBranch2'
						,REDMBankBranch2Old	varchar(20) 'REDMBankBranch2Old'
						,REDMAccCCy2	varchar(3) 'REDMAccCCy2'
						,REDMAccCCy2Old	varchar(3) 'REDMAccCCy2Old'
						,REDMAccNo2	varchar(30) 'REDMAccNo2'
						,REDMAccNo2Old	varchar(30) 'REDMAccNo2Old'
						,REDMAccName2	varchar(100) 'REDMAccName2'
						,REDMAccName2Old	varchar(100) 'REDMAccName2Old'
						,REDMBIC3	varchar(11) 'REDMBIC3'
						,REDMBIC3Old	varchar(11) 'REDMBIC3Old'
						,REDMMemberCode3	varchar(17) 'REDMMemberCode3'
						,REDMMemberCode3Old	varchar(17) 'REDMMemberCode3Old'
						,REDMBankName3	varchar(100) 'REDMBankName3'
						,REDMBankName3Old	varchar(100) 'REDMBankName3Old'
						,REDMBankCountry3	varchar(2) 'REDMBankCountry3'
						,REDMBankCountry3Old	varchar(2) 'REDMBankCountry3Old'
						,REDMBankBranch3	varchar(20) 'REDMBankBranch3'
						,REDMBankBranch3Old	varchar(20) 'REDMBankBranch3Old'
						,REDMAccCCy3	varchar(3) 'REDMAccCCy3'
						,REDMAccCCy3Old	varchar(3) 'REDMAccCCy3Old'
						,REDMAccNo3	varchar(30) 'REDMAccNo3'
						,REDMAccNo3Old	varchar(30) 'REDMAccNo3Old'
						,REDMAccName3	varchar(100) 'REDMAccName3'
						,REDMAccName3Old	varchar(100) 'REDMAccName3Old'
						,ClientCode	varchar(20) 'ClientCode'
						,ClientCodeOld varchar(20) 'ClientCodeOld'
						,CIFNo bigint 'CIFNo'
						)
						EXEC sp_xml_removedocument @hDoc
				   end

				
			end
		else if (@TypeUpload = 'INS' and @pnType = 'A') -- else jika institusi dan status approve 
			begin
					
				if exists (select top 1 1 from ReksaNFSFileRequest_TM where LogId = @pnLogId and @TypeUpload = 'INS' and @pnType = 'A')
				   begin
				     delete from ReksaNFSFileRequest_TM where LogId = @pnLogId and Type = 'INS'
					 EXEC sp_xml_preparedocument @hDoc output,@XML

				insert into ReksaNFSFileRequest_TM (LogId,Period,Type,SACode,SID,SIDOld,CompanyName,CompanyNameOld,CountryOfDomicile,CountryOfDomicileOld,CountryOfDomicileDesc,CountryOfDomicileDescOld,SIUPNo,SIUPNoOld,
				SIUPExpDate,SIUPExpDateOld,SKDNo,SKDNoOld,SKDExpDate,SKDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfEstablishment,
				CountryOfEstablishmentOld,PlaceOfEstablishment ,PlaceOfEstablishmentOld ,DateOfEstablishment,DateOfEstablishmentOld,ArticlesAssociatioNo,
				ArticlesAssociatioNoOld,CompanyType ,CompanyTypeOld ,CompanyTypeDesc,CompanyTypeDescOld,CompanyChar,CompanyCharOld,CompanyCharDesc,
				CompanyCharDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,InvestorRiskProfile,InvestorRiskProfileOld,
				InvestorRiskProfileDesc,InvestorRiskProfileDescOld,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld,
				SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,CompanyAddress,
				CompanyAddressOld,CompanyCityCode,CompanyCityCodeOld,CompanyCityName,CompanyCityNameOld,CompanyPostalCode,CompanyPostalCodeOld,CountryOfCompany,
				CountryOfCompanyOld,OfficePhone,OfficePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,Auth1FirstName,Auth1FirstNameOld,
				Auth1MiddleName,Auth1MiddleNameOld,Auth1LastName,Auth1LastNameOld,Auth1Position,Auth1PositionOld,Auth1MobilePhone,Auth1MobilePhoneOld,Auth1Email,
				Auth1EmailOld,Auth1NPWP,Auth1NPWPOld,Auth1KTPNo,Auth1KTPNoOld,Auth1KTPExpDate,Auth1KTPExpDateOld,Auth1PassportNo,Auth1PassportNoOld,Auth1PassportExpDate,
				Auth1PassportExpDateOld,Auth2FirstName,Auth2FirstNameOld,Auth2MiddleName,Auth2MiddleNameOld,Auth2LastName,Auth2LastNameOld,Auth2Position,
				Auth2PositionOld,Auth2MobilePhone,Auth2MobilePhoneOld,Auth2Email,Auth2EmailOld,Auth2NPWP,Auth2NPWPOld,Auth2KTPNo,Auth2KTPNoOld,Auth2KTPExpDate,
				Auth2KTPExpDateOld,Auth2PassportNo,Auth2PassportNoOld,Auth2PassportExpDate,Auth2PassportExpDateOld,AssetPast1Y,AssetPast1YOld,AssetPast2Y,
				AssetPast2YOld,AssetPast3Y,AssetPast3YOld,ProfitPast1Y,ProfitPast1YOld,ProfitPast2Y,ProfitPast2YOld,ProfitPast3Y,ProfitPast3YOld,FATCA,FATCAOld,
				TINStatus,TINStatusOld,TINCountry,TINCountryOld,GIIN,GIINOld,SubsOwnerName,SubsOwnerNameOld,SubsOwnerAddress,SubsOwnerAddressOld,SubsOwnerTIN,
				SubsOwnerTINOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,
				REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,
				REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,
				REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,
				REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,
				REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIF)
				select @pnLogId,@Period,@TypeUpload,SACode,SID,SIDOld,CompanyName,CompanyNameOld,CountryOfDomicile,CountryOfDomicileOld,CountryOfDomicileDesc,CountryOfDomicileDescOld,SIUPNo,SIUPNoOld,
				SIUPExpDate,SIUPExpDateOld,SKDNo,SKDNoOld,SKDExpDate,SKDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfEstablishment,
				CountryOfEstablishmentOld,PlaceOfEstablishment ,PlaceOfEstablishmentOld ,DateOfEstablishment,DateOfEstablishmentOld,ArticlesAssociatioNo,
				ArticlesAssociatioNoOld,CompanyType ,CompanyTypeOld ,CompanyTypeDesc,CompanyTypeDescOld,CompanyChar,CompanyCharOld,CompanyCharDesc,
				CompanyCharDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,InvestorRiskProfile,InvestorRiskProfileOld,
				InvestorRiskProfileDesc,InvestorRiskProfileDescOld,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld,
				SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,CompanyAddress,
				CompanyAddressOld,CompanyCityCode,CompanyCityCodeOld,CompanyCityName,CompanyCityNameOld,CompanyPostalCode,CompanyPostalCodeOld,CountryOfCompany,
				CountryOfCompanyOld,OfficePhone,OfficePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,Auth1FirstName,Auth1FirstNameOld,
				Auth1MiddleName,Auth1MiddleNameOld,Auth1LastName,Auth1LastNameOld,Auth1Position,Auth1PositionOld,Auth1MobilePhone,Auth1MobilePhoneOld,Auth1Email,
				Auth1EmailOld,Auth1NPWP,Auth1NPWPOld,Auth1KTPNo,Auth1KTPNoOld,Auth1KTPExpDate,Auth1KTPExpDateOld,Auth1PassportNo,Auth1PassportNoOld,Auth1PassportExpDate,
				Auth1PassportExpDateOld,Auth2FirstName,Auth2FirstNameOld,Auth2MiddleName,Auth2MiddleNameOld,Auth2LastName,Auth2LastNameOld,Auth2Position,
				Auth2PositionOld,Auth2MobilePhone,Auth2MobilePhoneOld,Auth2Email,Auth2EmailOld,Auth2NPWP,Auth2NPWPOld,Auth2KTPNo,Auth2KTPNoOld,Auth2KTPExpDate,
				Auth2KTPExpDateOld,Auth2PassportNo,Auth2PassportNoOld,Auth2PassportExpDate,Auth2PassportExpDateOld,AssetPast1Y,AssetPast1YOld,AssetPast2Y,
				AssetPast2YOld,AssetPast3Y,AssetPast3YOld,ProfitPast1Y,ProfitPast1YOld,ProfitPast2Y,ProfitPast2YOld,ProfitPast3Y,ProfitPast3YOld,FATCA,FATCAOld,
				TINStatus,TINStatusOld,TINCountry,TINCountryOld,GIIN,GIINOld,SubsOwnerName,SubsOwnerNameOld,SubsOwnerAddress,SubsOwnerAddressOld,SubsOwnerTIN,
				SubsOwnerTINOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,
				REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,
				REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,
				REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,
				REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,
				REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIFNo
				from OPENXML(@hDoc,'Root/DATA')
				with
				(
				SACode	varchar(5)	'SACode'
				,SID	varchar(15)	'SID'
				,SIDOld	varchar(15)	'SIDOld'
				,CompanyName	varchar(100)	'CompanyName'
				,CompanyNameOld	varchar(100)	'CompanyNameOld'
				,CountryOfDomicile	varchar(2)	'CountryOfDomicile'
				,CountryOfDomicileOld	varchar(2)	'CountryOfDomicileOld'
				,CountryOfDomicileDesc	varchar(30)	'CountryOfDomicileDesc'
				,CountryOfDomicileDescOld	varchar(30)	'CountryOfDomicileDescOld'
				,SIUPNo	varchar(100)	'SIUPNo'
				,SIUPNoOld	varchar(100)	'SIUPNoOld'
				,SIUPExpDate	varchar(8)	'SIUPExpDate'
				,SIUPExpDateOld	varchar(8)	'SIUPExpDateOld'
				,SKDNo	varchar(20)	'SKDNo'
				,SKDNoOld	varchar(20)	'SKDNoOld'
				,SKDExpDate	varchar(8)	'SKDExpDate'
				,SKDExpDateOld	varchar(8)	'SKDExpDateOld'
				,NPWPNo	varchar(20)	'NPWPNo'
				,NPWPNoOld	varchar(20)	'NPWPNoOld'
				,NPWPRegDate	varchar(8)	'NPWPRegDate'
				,NPWPRegDateOld	varchar(8)	'NPWPRegDateOld'
				,CountryOfEstablishment	varchar(2)	'CountryOfEstablishment'
				,CountryOfEstablishmentOld	varchar(2)	'CountryOfEstablishmentOld'
				,PlaceOfEstablishment 	varchar(100)	'PlaceOfEstablishment'
				,PlaceOfEstablishmentOld 	varchar(100)	'PlaceOfEstablishmentOld'
				,DateOfEstablishment	varchar(8)	'DateOfEstablishment'
				,DateOfEstablishmentOld	varchar(8)	'DateOfEstablishmentOld'
				,ArticlesAssociatioNo	varchar(20)	'ArticlesAssociatioNo'
				,ArticlesAssociatioNoOld	varchar(20)	'ArticlesAssociatioNoOld'
				,CompanyType 	int	'CompanyType'
				,CompanyTypeOld 	int	'CompanyTypeOld'
				,CompanyTypeDesc	varchar(50)	'CompanyTypeDesc'
				,CompanyTypeDescOld	varchar(50)	'CompanyTypeDescOld'
				,CompanyChar	int	'CompanyChar'
				,CompanyCharOld	int	'CompanyCharOld'
				,CompanyCharDesc	varchar(50)	'CompanyCharDesc'
				,CompanyCharDescOld	varchar(50)	'CompanyCharDescOld'
				,IncomeLevel	int	'IncomeLevel'
				,IncomeLevelOld	int	'IncomeLevelOld'
				,IncomeLevelDesc	varchar(50)	'IncomeLevelDesc'
				,IncomeLevelDescOld	varchar(50)	'IncomeLevelDescOld'
				,InvestorRiskProfile	int	'InvestorRiskProfile'
				,InvestorRiskProfileOld	int	'InvestorRiskProfileOld'
				,InvestorRiskProfileDesc	varchar(20)	'InvestorRiskProfileDesc'
				,InvestorRiskProfileDescOld	varchar(20)	'InvestorRiskProfileDescOld'
				,InvestmentObjective	int	'InvestmentObjective'
				,InvestmentObjectiveOld	int	'InvestmentObjectiveOld'
				,InvestmentObjectiveDesc	varchar(30)	'InvestmentObjectiveDesc'
				,InvestmentObjectiveDescOld	varchar(30)	'InvestmentObjectiveDescOld'
				,SourceOfFund	int	'SourceOfFund'
				,SourceOfFundOld	int	'SourceOfFundOld'
				,SourceOfFundDesc	varchar(50)	'SourceOfFundDesc'
				,SourceOfFundDescOld	varchar(50)	'SourceOfFundDescOld'
				,AssetOwner	int	'AssetOwner'
				,AssetOwnerOld	int	'AssetOwnerOld'
				,AssetOwnerDesc	varchar(20)	'AssetOwnerDesc'
				,AssetOwnerDescOld	varchar(20)	'AssetOwnerDescOld'
				,CompanyAddress	varchar(200)	'CompanyAddress'
				,CompanyAddressOld	varchar(200)	'CompanyAddressOld'
				,CompanyCityCode	int	'CompanyCityCode'
				,CompanyCityCodeOld	int	'CompanyCityCodeOld'
				,CompanyCityName	varchar(100)	'CompanyCityName'
				,CompanyCityNameOld	varchar(100)	'CompanyCityNameOld'
				,CompanyPostalCode	varchar(5)	'CompanyPostalCode'
				,CompanyPostalCodeOld	varchar(5)	'CompanyPostalCodeOld'
				,CountryOfCompany	varchar(2)	'CountryOfCompany'
				,CountryOfCompanyOld	varchar(2)	'CountryOfCompanyOld'
				,OfficePhone	varchar(100)	'OfficePhone'
				,OfficePhoneOld	varchar(100)	'OfficePhoneOld'
				,Facsimile	varchar(30)	'Facsimile'
				,FacsimileOld	varchar(30)	'FacsimileOld'
				,Email	varchar(256)	'Email'
				,EmailOld	varchar(256)	'EmailOld'
				,StatementType	int	'StatementType'
				,StatementTypeOld	int	'StatementTypeOld'
				,Auth1FirstName	varchar(40)	'Auth1FirstName'
				,Auth1FirstNameOld	varchar(40)	'Auth1FirstNameOld'
				,Auth1MiddleName	varchar(40)	'Auth1MiddleName'
				,Auth1MiddleNameOld	varchar(40)	'Auth1MiddleNameOld'
				,Auth1LastName	varchar(40)	'Auth1LastName'
				,Auth1LastNameOld	varchar(40)	'Auth1LastNameOld'
				,Auth1Position	varchar(120)	'Auth1Position'
				,Auth1PositionOld	varchar(120)	'Auth1PositionOld'
				,Auth1MobilePhone	varchar(30)	'Auth1MobilePhone'
				,Auth1MobilePhoneOld	varchar(30)	'Auth1MobilePhoneOld'
				,Auth1Email	varchar(256)	'Auth1Email'
				,Auth1EmailOld	varchar(256)	'Auth1EmailOld'
				,Auth1NPWP	varchar(15)	'Auth1NPWP'
				,Auth1NPWPOld	varchar(15)	'Auth1NPWPOld'
				,Auth1KTPNo	varchar(20)	'Auth1KTPNo'
				,Auth1KTPNoOld	varchar(20)	'Auth1KTPNoOld'
				,Auth1KTPExpDate	varchar(8)	'Auth1KTPExpDate'
				,Auth1KTPExpDateOld	varchar(8)	'Auth1KTPExpDateOld'
				,Auth1PassportNo	varchar(20)	'Auth1PassportNo'
				,Auth1PassportNoOld	varchar(20)	'Auth1PassportNoOld'
				,Auth1PassportExpDate	varchar(8)	'Auth1PassportExpDate'
				,Auth1PassportExpDateOld	varchar(8)	'Auth1PassportExpDateOld'
				,Auth2FirstName	varchar(40)	'Auth2FirstName'
				,Auth2FirstNameOld	varchar(40)	'Auth2FirstNameOld'
				,Auth2MiddleName	varchar(40)	'Auth2MiddleName'
				,Auth2MiddleNameOld	varchar(40)	'Auth2MiddleNameOld'
				,Auth2LastName	varchar(40)	'Auth2LastName'
				,Auth2LastNameOld	varchar(40)	'Auth2LastNameOld'
				,Auth2Position	varchar(120)	'Auth2Position'
				,Auth2PositionOld	varchar(120)	'Auth2PositionOld'
				,Auth2MobilePhone	varchar(30)	'Auth2MobilePhone'
				,Auth2MobilePhoneOld	varchar(30)	'Auth2MobilePhoneOld'
				,Auth2Email	varchar(256)	'Auth2Email'
				,Auth2EmailOld	varchar(256)	'Auth2EmailOld'
				,Auth2NPWP	varchar(15)	'Auth2NPWP'
				,Auth2NPWPOld	varchar(15)	'Auth2NPWPOld'
				,Auth2KTPNo	varchar(20)	'Auth2KTPNo'
				,Auth2KTPNoOld	varchar(20)	'Auth2KTPNoOld'
				,Auth2KTPExpDate	varchar(8)	'Auth2KTPExpDate'
				,Auth2KTPExpDateOld	varchar(8)	'Auth2KTPExpDateOld'
				,Auth2PassportNo	varchar(20)	'Auth2PassportNo'
				,Auth2PassportNoOld	varchar(20)	'Auth2PassportNoOld'
				,Auth2PassportExpDate	varchar(8)	'Auth2PassportExpDate'
				,Auth2PassportExpDateOld	varchar(8)	'Auth2PassportExpDateOld'
				,AssetPast1Y	int	'AssetPast1Y'
				,AssetPast1YOld	int	'AssetPast1YOld'
				,AssetPast2Y	int	'AssetPast2Y'
				,AssetPast2YOld	int	'AssetPast2YOld'
				,AssetPast3Y	int	'AssetPast3Y'
				,AssetPast3YOld	int	'AssetPast3YOld'
				,ProfitPast1Y	int	'ProfitPast1Y'
				,ProfitPast1YOld	int	'ProfitPast1YOld'
				,ProfitPast2Y	int	'ProfitPast2Y'
				,ProfitPast2YOld	int	'ProfitPast2YOld'
				,ProfitPast3Y	int	'ProfitPast3Y'
				,ProfitPast3YOld	int	'ProfitPast3YOld'
				,FATCA	int	'FATCA'
				,FATCAOld	int	'FATCAOld'
				,TINStatus	varchar(30)	'TINStatus'
				,TINStatusOld	varchar(30)	'TINStatusOld'
				,TINCountry	varchar(2)	'TINCountry'
				,TINCountryOld	varchar(2)	'TINCountryOld'
				,GIIN	varchar(30)	'GIIN'
				,GIINOld	varchar(30)	'GIINOld'
				,SubsOwnerName	varchar(100)	'SubsOwnerName'
				,SubsOwnerNameOld	varchar(100)	'SubsOwnerNameOld'
				,SubsOwnerAddress	varchar(100)	'SubsOwnerAddress'
				,SubsOwnerAddressOld	varchar(100)	'SubsOwnerAddressOld'
				,SubsOwnerTIN	varchar(10)	'SubsOwnerTIN'
				,SubsOwnerTINOld	varchar(10)	'SubsOwnerTINOld'
				,REDMBIC1	varchar(11)	'REDMBIC1'
				,REDMBIC1Old	varchar(11)	'REDMBIC1Old'
				,REDMMemberCode1	varchar(17)	'REDMMemberCode1'
				,REDMMemberCode1Old	varchar(17)	'REDMMemberCode1Old'
				,REDMBankName1	varchar(100)	'REDMBankName1'
				,REDMBankName1Old	varchar(100)	'REDMBankName1Old'
				,REDMBankCountry1	varchar(2)	'REDMBankCountry1'
				,REDMBankCountry1Old	varchar(2)	'REDMBankCountry1Old'
				,REDMBankBranch1	varchar(20)	'REDMBankBranch1'
				,REDMBankBranch1Old	varchar(20)	'REDMBankBranch1Old'
				,REDMAccCcy1	varchar(3)	'REDMAccCcy1'
				,REDMAccCcy1Old	varchar(3)	'REDMAccCcy1Old'
				,REDMAccNo1	varchar(30)	'REDMAccNo1'
				,REDMAccNo1Old	varchar(30)	'REDMAccNo1Old'
				,REDMAccName1	varchar(100)	'REDMAccName1'
				,REDMAccName1Old	varchar(100)	'REDMAccName1Old'
				,REDMBIC2	varchar(11)	'REDMBIC2'
				,REDMBIC2Old	varchar(11)	'REDMBIC2Old'
				,REDMMemberCode2	varchar(17)	'REDMMemberCode2'
				,REDMMemberCode2Old	varchar(17)	'REDMMemberCode2Old'
				,REDMBankName2	varchar(100)	'REDMBankName2'
				,REDMBankName2Old	varchar(100)	'REDMBankName2Old'
				,REDMBankCountry2	varchar(2)	'REDMBankCountry2'
				,REDMBankCountry2Old	varchar(2)	'REDMBankCountry2Old'
				,REDMBankBranch2	varchar(20)	'REDMBankBranch2'
				,REDMBankBranch2Old	varchar(20)	'REDMBankBranch2Old'
				,REDMAccCCy2	varchar(3)	'REDMAccCCy2'
				,REDMAccCCy2Old	varchar(3)	'REDMAccCCy2Old'
				,REDMAccNo2	varchar(30)	'REDMAccNo2'
				,REDMAccNo2Old	varchar(30)	'REDMAccNo2Old'
				,REDMAccName2	varchar(100)	'REDMAccName2'
				,REDMAccName2Old	varchar(100)	'REDMAccName2Old'
				,REDMBIC3	varchar(11)	'REDMBIC3'
				,REDMBIC3Old	varchar(11)	'REDMBIC3Old'
				,REDMMemberCode3	varchar(17)	'REDMMemberCode3'
				,REDMMemberCode3Old	varchar(17)	'REDMMemberCode3Old'
				,REDMBankName3	varchar(100)	'REDMBankName3'
				,REDMBankName3Old	varchar(100)	'REDMBankName3Old'
				,REDMBankCountry3	varchar(2)	'REDMBankCountry3'
				,REDMBankCountry3Old	varchar(2)	'REDMBankCountry3Old'
				,REDMBankBranch3	varchar(20)	'REDMBankBranch3'
				,REDMBankBranch3Old	varchar(20)	'REDMBankBranch3Old'
				,REDMAccCCy3	varchar(3)	'REDMAccCCy3'
				,REDMAccCCy3Old	varchar(3)	'REDMAccCCy3Old'
				,REDMAccNo3	varchar(30)	'REDMAccNo3'
				,REDMAccNo3Old	varchar(30)	'REDMAccNo3Old'
				,REDMAccName3	varchar(100)	'REDMAccName3'
				,REDMAccName3Old	varchar(100)	'REDMAccName3Old'
				,ClientCode	varchar(20)	'ClientCode'
				,ClientCodeOld	varchar(20)	'ClientCodeOld'
				,CIFNo	varchar(6)	'CIFNo'

				)

				EXEC sp_xml_removedocument @hDoc
			end
			else
				begin
				EXEC sp_xml_preparedocument @hDoc output,@XML

				insert into ReksaNFSFileRequest_TM (LogId,Period,Type,SACode,SID,SIDOld,CompanyName,CompanyNameOld,CountryOfDomicile,CountryOfDomicileOld,CountryOfDomicileDesc,CountryOfDomicileDescOld,SIUPNo,SIUPNoOld,
				SIUPExpDate,SIUPExpDateOld,SKDNo,SKDNoOld,SKDExpDate,SKDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfEstablishment,
				CountryOfEstablishmentOld,PlaceOfEstablishment ,PlaceOfEstablishmentOld ,DateOfEstablishment,DateOfEstablishmentOld,ArticlesAssociatioNo,
				ArticlesAssociatioNoOld,CompanyType ,CompanyTypeOld ,CompanyTypeDesc,CompanyTypeDescOld,CompanyChar,CompanyCharOld,CompanyCharDesc,
				CompanyCharDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,InvestorRiskProfile,InvestorRiskProfileOld,
				InvestorRiskProfileDesc,InvestorRiskProfileDescOld,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld,
				SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,CompanyAddress,
				CompanyAddressOld,CompanyCityCode,CompanyCityCodeOld,CompanyCityName,CompanyCityNameOld,CompanyPostalCode,CompanyPostalCodeOld,CountryOfCompany,
				CountryOfCompanyOld,OfficePhone,OfficePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,Auth1FirstName,Auth1FirstNameOld,
				Auth1MiddleName,Auth1MiddleNameOld,Auth1LastName,Auth1LastNameOld,Auth1Position,Auth1PositionOld,Auth1MobilePhone,Auth1MobilePhoneOld,Auth1Email,
				Auth1EmailOld,Auth1NPWP,Auth1NPWPOld,Auth1KTPNo,Auth1KTPNoOld,Auth1KTPExpDate,Auth1KTPExpDateOld,Auth1PassportNo,Auth1PassportNoOld,Auth1PassportExpDate,
				Auth1PassportExpDateOld,Auth2FirstName,Auth2FirstNameOld,Auth2MiddleName,Auth2MiddleNameOld,Auth2LastName,Auth2LastNameOld,Auth2Position,
				Auth2PositionOld,Auth2MobilePhone,Auth2MobilePhoneOld,Auth2Email,Auth2EmailOld,Auth2NPWP,Auth2NPWPOld,Auth2KTPNo,Auth2KTPNoOld,Auth2KTPExpDate,
				Auth2KTPExpDateOld,Auth2PassportNo,Auth2PassportNoOld,Auth2PassportExpDate,Auth2PassportExpDateOld,AssetPast1Y,AssetPast1YOld,AssetPast2Y,
				AssetPast2YOld,AssetPast3Y,AssetPast3YOld,ProfitPast1Y,ProfitPast1YOld,ProfitPast2Y,ProfitPast2YOld,ProfitPast3Y,ProfitPast3YOld,FATCA,FATCAOld,
				TINStatus,TINStatusOld,TINCountry,TINCountryOld,GIIN,GIINOld,SubsOwnerName,SubsOwnerNameOld,SubsOwnerAddress,SubsOwnerAddressOld,SubsOwnerTIN,
				SubsOwnerTINOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,
				REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,
				REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,
				REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,
				REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,
				REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIF)
				select @pnLogId,@Period,@TypeUpload,SACode,SID,SIDOld,CompanyName,CompanyNameOld,CountryOfDomicile,CountryOfDomicileOld,CountryOfDomicileDesc,CountryOfDomicileDescOld,SIUPNo,SIUPNoOld,
				SIUPExpDate,SIUPExpDateOld,SKDNo,SKDNoOld,SKDExpDate,SKDExpDateOld,NPWPNo,NPWPNoOld,NPWPRegDate,NPWPRegDateOld,CountryOfEstablishment,
				CountryOfEstablishmentOld,PlaceOfEstablishment ,PlaceOfEstablishmentOld ,DateOfEstablishment,DateOfEstablishmentOld,ArticlesAssociatioNo,
				ArticlesAssociatioNoOld,CompanyType ,CompanyTypeOld ,CompanyTypeDesc,CompanyTypeDescOld,CompanyChar,CompanyCharOld,CompanyCharDesc,
				CompanyCharDescOld,IncomeLevel,IncomeLevelOld,IncomeLevelDesc,IncomeLevelDescOld,InvestorRiskProfile,InvestorRiskProfileOld,
				InvestorRiskProfileDesc,InvestorRiskProfileDescOld,InvestmentObjective,InvestmentObjectiveOld,InvestmentObjectiveDesc,InvestmentObjectiveDescOld,
				SourceOfFund,SourceOfFundOld,SourceOfFundDesc,SourceOfFundDescOld,AssetOwner,AssetOwnerOld,AssetOwnerDesc,AssetOwnerDescOld,CompanyAddress,
				CompanyAddressOld,CompanyCityCode,CompanyCityCodeOld,CompanyCityName,CompanyCityNameOld,CompanyPostalCode,CompanyPostalCodeOld,CountryOfCompany,
				CountryOfCompanyOld,OfficePhone,OfficePhoneOld,Facsimile,FacsimileOld,Email,EmailOld,StatementType,StatementTypeOld,Auth1FirstName,Auth1FirstNameOld,
				Auth1MiddleName,Auth1MiddleNameOld,Auth1LastName,Auth1LastNameOld,Auth1Position,Auth1PositionOld,Auth1MobilePhone,Auth1MobilePhoneOld,Auth1Email,
				Auth1EmailOld,Auth1NPWP,Auth1NPWPOld,Auth1KTPNo,Auth1KTPNoOld,Auth1KTPExpDate,Auth1KTPExpDateOld,Auth1PassportNo,Auth1PassportNoOld,Auth1PassportExpDate,
				Auth1PassportExpDateOld,Auth2FirstName,Auth2FirstNameOld,Auth2MiddleName,Auth2MiddleNameOld,Auth2LastName,Auth2LastNameOld,Auth2Position,
				Auth2PositionOld,Auth2MobilePhone,Auth2MobilePhoneOld,Auth2Email,Auth2EmailOld,Auth2NPWP,Auth2NPWPOld,Auth2KTPNo,Auth2KTPNoOld,Auth2KTPExpDate,
				Auth2KTPExpDateOld,Auth2PassportNo,Auth2PassportNoOld,Auth2PassportExpDate,Auth2PassportExpDateOld,AssetPast1Y,AssetPast1YOld,AssetPast2Y,
				AssetPast2YOld,AssetPast3Y,AssetPast3YOld,ProfitPast1Y,ProfitPast1YOld,ProfitPast2Y,ProfitPast2YOld,ProfitPast3Y,ProfitPast3YOld,FATCA,FATCAOld,
				TINStatus,TINStatusOld,TINCountry,TINCountryOld,GIIN,GIINOld,SubsOwnerName,SubsOwnerNameOld,SubsOwnerAddress,SubsOwnerAddressOld,SubsOwnerTIN,
				SubsOwnerTINOld,REDMBIC1,REDMBIC1Old,REDMMemberCode1,REDMMemberCode1Old,REDMBankName1,REDMBankName1Old,REDMBankCountry1,REDMBankCountry1Old,
				REDMBankBranch1,REDMBankBranch1Old,REDMAccCcy1,REDMAccCcy1Old,REDMAccNo1,REDMAccNo1Old,REDMAccName1,REDMAccName1Old,REDMBIC2,REDMBIC2Old,
				REDMMemberCode2,REDMMemberCode2Old,REDMBankName2,REDMBankName2Old,REDMBankCountry2,REDMBankCountry2Old,REDMBankBranch2,REDMBankBranch2Old,
				REDMAccCCy2,REDMAccCCy2Old,REDMAccNo2,REDMAccNo2Old,REDMAccName2,REDMAccName2Old,REDMBIC3,REDMBIC3Old,REDMMemberCode3,REDMMemberCode3Old,
				REDMBankName3,REDMBankName3Old,REDMBankCountry3,REDMBankCountry3Old,REDMBankBranch3,REDMBankBranch3Old,REDMAccCCy3,REDMAccCCy3Old,REDMAccNo3,
				REDMAccNo3Old,REDMAccName3,REDMAccName3Old,ClientCode,ClientCodeOld,CIFNo
				from OPENXML(@hDoc,'Root/DATA')
				with
				(
				SACode	varchar(5)	'SACode'
				,SID	varchar(15)	'SID'
				,SIDOld	varchar(15)	'SIDOld'
				,CompanyName	varchar(100)	'CompanyName'
				,CompanyNameOld	varchar(100)	'CompanyNameOld'
				,CountryOfDomicile	varchar(2)	'CountryOfDomicile'
				,CountryOfDomicileOld	varchar(2)	'CountryOfDomicileOld'
				,CountryOfDomicileDesc	varchar(30)	'CountryOfDomicileDesc'
				,CountryOfDomicileDescOld	varchar(30)	'CountryOfDomicileDescOld'
				,SIUPNo	varchar(100)	'SIUPNo'
				,SIUPNoOld	varchar(100)	'SIUPNoOld'
				,SIUPExpDate	varchar(8)	'SIUPExpDate'
				,SIUPExpDateOld	varchar(8)	'SIUPExpDateOld'
				,SKDNo	varchar(20)	'SKDNo'
				,SKDNoOld	varchar(20)	'SKDNoOld'
				,SKDExpDate	varchar(8)	'SKDExpDate'
				,SKDExpDateOld	varchar(8)	'SKDExpDateOld'
				,NPWPNo	varchar(20)	'NPWPNo'
				,NPWPNoOld	varchar(20)	'NPWPNoOld'
				,NPWPRegDate	varchar(8)	'NPWPRegDate'
				,NPWPRegDateOld	varchar(8)	'NPWPRegDateOld'
				,CountryOfEstablishment	varchar(2)	'CountryOfEstablishment'
				,CountryOfEstablishmentOld	varchar(2)	'CountryOfEstablishmentOld'
				,PlaceOfEstablishment 	varchar(100)	'PlaceOfEstablishment'
				,PlaceOfEstablishmentOld 	varchar(100)	'PlaceOfEstablishmentOld'
				,DateOfEstablishment	varchar(8)	'DateOfEstablishment'
				,DateOfEstablishmentOld	varchar(8)	'DateOfEstablishmentOld'
				,ArticlesAssociatioNo	varchar(20)	'ArticlesAssociatioNo'
				,ArticlesAssociatioNoOld	varchar(20)	'ArticlesAssociatioNoOld'
				,CompanyType 	int	'CompanyType'
				,CompanyTypeOld 	int	'CompanyTypeOld'
				,CompanyTypeDesc	varchar(50)	'CompanyTypeDesc'
				,CompanyTypeDescOld	varchar(50)	'CompanyTypeDescOld'
				,CompanyChar	int	'CompanyChar'
				,CompanyCharOld	int	'CompanyCharOld'
				,CompanyCharDesc	varchar(50)	'CompanyCharDesc'
				,CompanyCharDescOld	varchar(50)	'CompanyCharDescOld'
				,IncomeLevel	int	'IncomeLevel'
				,IncomeLevelOld	int	'IncomeLevelOld'
				,IncomeLevelDesc	varchar(50)	'IncomeLevelDesc'
				,IncomeLevelDescOld	varchar(50)	'IncomeLevelDescOld'
				,InvestorRiskProfile	int	'InvestorRiskProfile'
				,InvestorRiskProfileOld	int	'InvestorRiskProfileOld'
				,InvestorRiskProfileDesc	varchar(20)	'InvestorRiskProfileDesc'
				,InvestorRiskProfileDescOld	varchar(20)	'InvestorRiskProfileDescOld'
				,InvestmentObjective	int	'InvestmentObjective'
				,InvestmentObjectiveOld	int	'InvestmentObjectiveOld'
				,InvestmentObjectiveDesc	varchar(30)	'InvestmentObjectiveDesc'
				,InvestmentObjectiveDescOld	varchar(30)	'InvestmentObjectiveDescOld'
				,SourceOfFund	int	'SourceOfFund'
				,SourceOfFundOld	int	'SourceOfFundOld'
				,SourceOfFundDesc	varchar(50)	'SourceOfFundDesc'
				,SourceOfFundDescOld	varchar(50)	'SourceOfFundDescOld'
				,AssetOwner	int	'AssetOwner'
				,AssetOwnerOld	int	'AssetOwnerOld'
				,AssetOwnerDesc	varchar(20)	'AssetOwnerDesc'
				,AssetOwnerDescOld	varchar(20)	'AssetOwnerDescOld'
				,CompanyAddress	varchar(200)	'CompanyAddress'
				,CompanyAddressOld	varchar(200)	'CompanyAddressOld'
				,CompanyCityCode	int	'CompanyCityCode'
				,CompanyCityCodeOld	int	'CompanyCityCodeOld'
				,CompanyCityName	varchar(100)	'CompanyCityName'
				,CompanyCityNameOld	varchar(100)	'CompanyCityNameOld'
				,CompanyPostalCode	varchar(5)	'CompanyPostalCode'
				,CompanyPostalCodeOld	varchar(5)	'CompanyPostalCodeOld'
				,CountryOfCompany	varchar(2)	'CountryOfCompany'
				,CountryOfCompanyOld	varchar(2)	'CountryOfCompanyOld'
				,OfficePhone	varchar(100)	'OfficePhone'
				,OfficePhoneOld	varchar(100)	'OfficePhoneOld'
				,Facsimile	varchar(30)	'Facsimile'
				,FacsimileOld	varchar(30)	'FacsimileOld'
				,Email	varchar(256)	'Email'
				,EmailOld	varchar(256)	'EmailOld'
				,StatementType	int	'StatementType'
				,StatementTypeOld	int	'StatementTypeOld'
				,Auth1FirstName	varchar(40)	'Auth1FirstName'
				,Auth1FirstNameOld	varchar(40)	'Auth1FirstNameOld'
				,Auth1MiddleName	varchar(40)	'Auth1MiddleName'
				,Auth1MiddleNameOld	varchar(40)	'Auth1MiddleNameOld'
				,Auth1LastName	varchar(40)	'Auth1LastName'
				,Auth1LastNameOld	varchar(40)	'Auth1LastNameOld'
				,Auth1Position	varchar(120)	'Auth1Position'
				,Auth1PositionOld	varchar(120)	'Auth1PositionOld'
				,Auth1MobilePhone	varchar(30)	'Auth1MobilePhone'
				,Auth1MobilePhoneOld	varchar(30)	'Auth1MobilePhoneOld'
				,Auth1Email	varchar(256)	'Auth1Email'
				,Auth1EmailOld	varchar(256)	'Auth1EmailOld'
				,Auth1NPWP	varchar(15)	'Auth1NPWP'
				,Auth1NPWPOld	varchar(15)	'Auth1NPWPOld'
				,Auth1KTPNo	varchar(20)	'Auth1KTPNo'
				,Auth1KTPNoOld	varchar(20)	'Auth1KTPNoOld'
				,Auth1KTPExpDate	varchar(8)	'Auth1KTPExpDate'
				,Auth1KTPExpDateOld	varchar(8)	'Auth1KTPExpDateOld'
				,Auth1PassportNo	varchar(20)	'Auth1PassportNo'
				,Auth1PassportNoOld	varchar(20)	'Auth1PassportNoOld'
				,Auth1PassportExpDate	varchar(8)	'Auth1PassportExpDate'
				,Auth1PassportExpDateOld	varchar(8)	'Auth1PassportExpDateOld'
				,Auth2FirstName	varchar(40)	'Auth2FirstName'
				,Auth2FirstNameOld	varchar(40)	'Auth2FirstNameOld'
				,Auth2MiddleName	varchar(40)	'Auth2MiddleName'
				,Auth2MiddleNameOld	varchar(40)	'Auth2MiddleNameOld'
				,Auth2LastName	varchar(40)	'Auth2LastName'
				,Auth2LastNameOld	varchar(40)	'Auth2LastNameOld'
				,Auth2Position	varchar(120)	'Auth2Position'
				,Auth2PositionOld	varchar(120)	'Auth2PositionOld'
				,Auth2MobilePhone	varchar(30)	'Auth2MobilePhone'
				,Auth2MobilePhoneOld	varchar(30)	'Auth2MobilePhoneOld'
				,Auth2Email	varchar(256)	'Auth2Email'
				,Auth2EmailOld	varchar(256)	'Auth2EmailOld'
				,Auth2NPWP	varchar(15)	'Auth2NPWP'
				,Auth2NPWPOld	varchar(15)	'Auth2NPWPOld'
				,Auth2KTPNo	varchar(20)	'Auth2KTPNo'
				,Auth2KTPNoOld	varchar(20)	'Auth2KTPNoOld'
				,Auth2KTPExpDate	varchar(8)	'Auth2KTPExpDate'
				,Auth2KTPExpDateOld	varchar(8)	'Auth2KTPExpDateOld'
				,Auth2PassportNo	varchar(20)	'Auth2PassportNo'
				,Auth2PassportNoOld	varchar(20)	'Auth2PassportNoOld'
				,Auth2PassportExpDate	varchar(8)	'Auth2PassportExpDate'
				,Auth2PassportExpDateOld	varchar(8)	'Auth2PassportExpDateOld'
				,AssetPast1Y	int	'AssetPast1Y'
				,AssetPast1YOld	int	'AssetPast1YOld'
				,AssetPast2Y	int	'AssetPast2Y'
				,AssetPast2YOld	int	'AssetPast2YOld'
				,AssetPast3Y	int	'AssetPast3Y'
				,AssetPast3YOld	int	'AssetPast3YOld'
				,ProfitPast1Y	int	'ProfitPast1Y'
				,ProfitPast1YOld	int	'ProfitPast1YOld'
				,ProfitPast2Y	int	'ProfitPast2Y'
				,ProfitPast2YOld	int	'ProfitPast2YOld'
				,ProfitPast3Y	int	'ProfitPast3Y'
				,ProfitPast3YOld	int	'ProfitPast3YOld'
				,FATCA	int	'FATCA'
				,FATCAOld	int	'FATCAOld'
				,TINStatus	varchar(30)	'TINStatus'
				,TINStatusOld	varchar(30)	'TINStatusOld'
				,TINCountry	varchar(2)	'TINCountry'
				,TINCountryOld	varchar(2)	'TINCountryOld'
				,GIIN	varchar(30)	'GIIN'
				,GIINOld	varchar(30)	'GIINOld'
				,SubsOwnerName	varchar(100)	'SubsOwnerName'
				,SubsOwnerNameOld	varchar(100)	'SubsOwnerNameOld'
				,SubsOwnerAddress	varchar(100)	'SubsOwnerAddress'
				,SubsOwnerAddressOld	varchar(100)	'SubsOwnerAddressOld'
				,SubsOwnerTIN	varchar(10)	'SubsOwnerTIN'
				,SubsOwnerTINOld	varchar(10)	'SubsOwnerTINOld'
				,REDMBIC1	varchar(11)	'REDMBIC1'
				,REDMBIC1Old	varchar(11)	'REDMBIC1Old'
				,REDMMemberCode1	varchar(17)	'REDMMemberCode1'
				,REDMMemberCode1Old	varchar(17)	'REDMMemberCode1Old'
				,REDMBankName1	varchar(100)	'REDMBankName1'
				,REDMBankName1Old	varchar(100)	'REDMBankName1Old'
				,REDMBankCountry1	varchar(2)	'REDMBankCountry1'
				,REDMBankCountry1Old	varchar(2)	'REDMBankCountry1Old'
				,REDMBankBranch1	varchar(20)	'REDMBankBranch1'
				,REDMBankBranch1Old	varchar(20)	'REDMBankBranch1Old'
				,REDMAccCcy1	varchar(3)	'REDMAccCcy1'
				,REDMAccCcy1Old	varchar(3)	'REDMAccCcy1Old'
				,REDMAccNo1	varchar(30)	'REDMAccNo1'
				,REDMAccNo1Old	varchar(30)	'REDMAccNo1Old'
				,REDMAccName1	varchar(100)	'REDMAccName1'
				,REDMAccName1Old	varchar(100)	'REDMAccName1Old'
				,REDMBIC2	varchar(11)	'REDMBIC2'
				,REDMBIC2Old	varchar(11)	'REDMBIC2Old'
				,REDMMemberCode2	varchar(17)	'REDMMemberCode2'
				,REDMMemberCode2Old	varchar(17)	'REDMMemberCode2Old'
				,REDMBankName2	varchar(100)	'REDMBankName2'
				,REDMBankName2Old	varchar(100)	'REDMBankName2Old'
				,REDMBankCountry2	varchar(2)	'REDMBankCountry2'
				,REDMBankCountry2Old	varchar(2)	'REDMBankCountry2Old'
				,REDMBankBranch2	varchar(20)	'REDMBankBranch2'
				,REDMBankBranch2Old	varchar(20)	'REDMBankBranch2Old'
				,REDMAccCCy2	varchar(3)	'REDMAccCCy2'
				,REDMAccCCy2Old	varchar(3)	'REDMAccCCy2Old'
				,REDMAccNo2	varchar(30)	'REDMAccNo2'
				,REDMAccNo2Old	varchar(30)	'REDMAccNo2Old'
				,REDMAccName2	varchar(100)	'REDMAccName2'
				,REDMAccName2Old	varchar(100)	'REDMAccName2Old'
				,REDMBIC3	varchar(11)	'REDMBIC3'
				,REDMBIC3Old	varchar(11)	'REDMBIC3Old'
				,REDMMemberCode3	varchar(17)	'REDMMemberCode3'
				,REDMMemberCode3Old	varchar(17)	'REDMMemberCode3Old'
				,REDMBankName3	varchar(100)	'REDMBankName3'
				,REDMBankName3Old	varchar(100)	'REDMBankName3Old'
				,REDMBankCountry3	varchar(2)	'REDMBankCountry3'
				,REDMBankCountry3Old	varchar(2)	'REDMBankCountry3Old'
				,REDMBankBranch3	varchar(20)	'REDMBankBranch3'
				,REDMBankBranch3Old	varchar(20)	'REDMBankBranch3Old'
				,REDMAccCCy3	varchar(3)	'REDMAccCCy3'
				,REDMAccCCy3Old	varchar(3)	'REDMAccCCy3Old'
				,REDMAccNo3	varchar(30)	'REDMAccNo3'
				,REDMAccNo3Old	varchar(30)	'REDMAccNo3Old'
				,REDMAccName3	varchar(100)	'REDMAccName3'
				,REDMAccName3Old	varchar(100)	'REDMAccName3Old'
				,ClientCode	varchar(20)	'ClientCode'
				,ClientCodeOld	varchar(20)	'ClientCodeOld'
				,CIFNo	varchar(6)	'CIFNo'

				)

				EXEC sp_xml_removedocument @hDoc
				end	


			end

			
	
	end

--else
--	begin
--		set @cErrMsg = 'Gagal Update Data Flag Approve'
--		goto Error
--	end

Return 0  
  
Error:  
  
if @@trancount >0   
 rollback tran  
  
if isnull(@cErrMsg, '') = ''  
 set @cErrMsg = 'Unknown Error'  
  
--Exec @nOK=set_raiserror @@procid, @nErrNo Output  
--If @nOK!=0 Return 1  
Raiserror (@cErrMsg  ,16,1)
  
Return 1
GO