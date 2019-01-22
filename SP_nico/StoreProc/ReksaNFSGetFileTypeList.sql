
CREATE proc [dbo].[ReksaNFSGetFileTypeList]                  
/*                  
	CREATED BY    : Lita                  
	CREATION DATE : 20160204
	DESCRIPTION   : GET NFS file type list
	DATE,  USER,   PROJECT,  NOTE                  
	-----------------------------------------------------------------------                      
	END REVISED

	exec ReksaNFSGetFileTypeList 'UPLOAD'
	exec ReksaNFSGetFileTypeList 'DOWNLOAD'

*/  
@pcFileType		varchar(20) 
as                  
set nocount on

	select FileCode, FileDesc 
	from ReksaNFSFileMaster_TM 
	where FileType = case 
			when upper(@pcFileType) = 'UPLOAD' then 'U'
			when upper(@pcFileType) = 'DOWNLOAD' then 'D'
		end
	order by FileCode
return 0
GO