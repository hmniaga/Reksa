CREATE proc [dbo].[ReksaNFSCekPendingDetailOtorisasi]
/*
	CREATED BY    : Andhika J
	CREATION DATE : 2018
	DESCRIPTION   : Get Value Detail pending per CIF
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
 @pnCIFNumber bigint
,@LogId int = null
as
set nocount on
declare @XML AS XML
	   ,@hDoc AS INT
	   ,@TypeUpload varchar(5)

select @TypeUpload = SUBSTRING(FileName,5,3) from ReksaNFSFileRequest_TT
where LogId = @LogId

 if (@TypeUpload = 'IND')
	begin	
			exec ReksaNFSPopulateAuthCIFPeriodInd @pnCIFNumber,@LogId
	end
 else
	begin
			exec ReksaNFSPopulateAuthCIFPeriodIns @pnCIFNumber,@LogId
	end


return 0
GO