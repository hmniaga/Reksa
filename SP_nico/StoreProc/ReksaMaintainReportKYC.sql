
CREATE PROC [dbo].[ReksaMaintainReportKYC]
/*
	CREATED BY    : 
	CREATION DATE : 
	DESCRIPTION   : maintain history report kyc reksa
	EXAMPLE       : 
		EXEC ReksaMaintainReportKYC '99999', 'ProReksa'
	REVISED BY    : 
		DATE,  USER,   PROJECT,  NOTE
		-----------------------------------------------------------------------
	END REVISED
*/
	@pnNIK			int,
	@pcModule		varchar(25)
AS
	SET NOCOUNT ON

	DECLARE
		@nBulan		int,
		@nTahun		int,
		@nPeriod	int

	BEGIN TRAN
		CREATE TABLE #ReksaKYC_TMP
		(
			ResultText	NVARCHAR(MAX)
		)

		SELECT @nBulan = DATEPART(MM, GETDATE()) - 1, @nTahun = DATEPART(YYYY, GETDATE())
		SET @nPeriod = ((@nTahun - 1) * 100) + @nBulan

		DELETE FROM ReksaReportKYC_TH
		WHERE Period = @nPeriod

		SET @nPeriod = (@nTahun * 100) + @nBulan

		INSERT INTO #ReksaKYC_TMP
		EXEC [ReksaGenerateText] @pnNIK, @pcModule, 'A', @nBulan, @nTahun

		INSERT INTO ReksaReportKYC_TH
		SELECT @nPeriod, 'A', ResultText
		FROM #ReksaKYC_TMP

		TRUNCATE TABLE #ReksaKYC_TMP

		INSERT INTO #ReksaKYC_TMP
		EXEC [ReksaGenerateText] @pnNIK, @pcModule, 'B', @nBulan, @nTahun

		INSERT INTO ReksaReportKYC_TH
		SELECT @nPeriod, 'B', ResultText
		FROM #ReksaKYC_TMP

		DROP TABLE #ReksaKYC_TMP
	COMMIT TRAN
RETURN 0
GO