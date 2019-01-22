
CREATE proc [dbo].[ReksaNFSGetFormatFile]                  
/*                  
	CREATED BY    : Lita                  
	CREATION DATE : 20160204
	DESCRIPTION   : Get Format File (DOWNLOAD FORMAT FILE)
	DATE,  USER,   PROJECT,  NOTE                  
	-----------------------------------------------------------------------                      
	END REVISED

	exec ReksaNFSGetFormatFile 'DOWN001'

*/  
@pcFileCode		varchar(10) 
as                  
set nocount on

	select FileCode, FileDesc, FieldSeparator, [FormatFile], FilterFileDialog, FieldKey1
	from ReksaNFSFileMaster_TM 
	where FileCode = @pcFileCode

return 0
GO