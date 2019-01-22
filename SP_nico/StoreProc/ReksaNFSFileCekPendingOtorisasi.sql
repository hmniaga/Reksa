
CREATE proc [dbo].[ReksaNFSFileCekPendingOtorisasi]
/*
	CREATED BY    : Andhika J
	CREATION DATE : 2018
	DESCRIPTION   : Get Value Period
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
 @pcTypeGet char(1) -- A : Onload / Refresh , G : Getvalue beradasarkan  LogId 
,@LogId int = null
as
set nocount on
declare @XML AS XML
	   ,@hDoc AS INT
	   ,@Separator char(1)
	   ,@FileName varchar(20)
	   ,@FormatFile varchar(5) 
	   ,@FilterFile varchar(20)
	   ,@GenerateData xml
	   ,@pcTypeUpload varchar(5)

if (@pcTypeGet = 'A')
	begin
		select LogId,Period,
		case when substring(FileName,5,3) = 'IND'
			 then 'Individu'
		else 'Institusi'
		end TypeUpload
		from ReksaNFSFileRequest_TT
		where AuthStatus = 'P'
	end
else
	begin

			select @XML = RawData,@pcTypeUpload = SUBSTRING(FileName,5,3),@FileName = FileName,@Separator = FieldSeparator,
			@FormatFile = FormatFile,@FilterFile = FilterFileDialog,@GenerateData = GenerateData
			from dbo.ReksaNFSFileRequest_TT tt with(nolock)
			join ReksaNFSFileMaster_TM tm on tt.FileCode = tm.FileCode
			where LogId = @LogId
		
		 if (@pcTypeUpload = 'IND')
			begin
				EXEC sp_xml_preparedocument @hDoc output,@XML
				select CIFNo as 'No CIF',SID ,FirstName 'Nama ',IDNo 'No KTP',GenderDesc 'Jenis Kelamin',KTPAddress 'Alamat KTP ',
				@FileName as FileName,@Separator as FieldSeparator ,@FormatFile as FormatFile,@FilterFile as FilterFileDialog,@GenerateData as GenerateData
				
									from OPENXML(@hDoc,'Root/DATA')
									with
									(
									CIFNo	bigint 'CIFNo'
									,SID	varchar(15) 'SID'
									,FirstName	varchar(100) 'FirstName'
									,IDNo	varchar(30)  'IDNo'
									,Gender	int 'Gender'
									,GenderDesc	varchar(10) 'GenderDesc'
									,KTPAddress	varchar(100) 'KTPAddress'
									)
									EXEC sp_xml_removedocument @hDoc
			end
		else
			begin
				EXEC sp_xml_preparedocument @hDoc output,@XML
				select CIFNo as 'No CIF',SID ,CompanyName 'Nama Perusahaan ',SIUPNo 'No SIUP',SKDNo 'No SKD',CompanyAddress 'Alamat Perusahaan ',
				@FileName as FileName,@Separator as FieldSeparator ,@FormatFile as FormatFile,@FilterFile as FilterFileDialog,@GenerateData as GenerateData
									from OPENXML(@hDoc,'Root/DATA')
									with
									(
									CIFNo	bigint 'CIFNo'
									,SID	varchar(15) 'SID'
									,CompanyName	varchar(100) 'CompanyName'
									,SIUPNo	varchar(100)  'SIUPNo'
									,SKDNo	varchar(20) 'SKDNo'
									,CompanyAddress	varchar(200) 'CompanyAddress'
									)
									EXEC sp_xml_removedocument @hDoc
			end

	end


return 0
GO