using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;


namespace ReksaAPI.Controllers
{
    public class ReportController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;

        public ReportController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/Report/NFSGetFileTypeList")]
        [HttpGet("{id}")]
        public JsonResult NFSGetFileTypeList([FromQuery]string FileType)
        {
            List<FileModel.NFSFileListType> listFileType = new List<FileModel.NFSFileListType>();
            listFileType = cls.ReksaNFSGetFileTypeList(FileType);
            return Json(new { listFileType });
        }
        [Route("api/Report/NFSGetFormatFile")]
        [HttpGet("{id}")]
        public JsonResult NFSGetFormatFile([FromQuery]string FileCode)
        {
            bool blnResult = false;
            string ErrMsg;
            DataSet dsData = new DataSet();
            blnResult = cls.ReksaNFSGetFormatFile(FileCode, out dsData, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSGetFormatFile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsData });
        }

        [Route("api/Report/NFSGenerateFileUpload")]
        [HttpGet("{id}")]
        public JsonResult NFSGenerateFileUpload([FromQuery]string FileCode, [FromQuery]int TranDate)
        {
            bool blnResult;
            string ErrMsg;
            DataSet ds = new DataSet();
            blnResult = cls.ReksaNFSGenerateFileUpload(FileCode, TranDate, out ds, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSGenerateFileUpload - Core .Net SqlClient Data Provider\n", "");
            return Json( new { blnResult, ErrMsg, ds });
        }

        [Route("api/Report/NFSGenerateFileDownload")]
        [HttpGet("{id}")]
        public JsonResult NFSGenerateFileDownload([FromQuery]string FileCode, [FromQuery]string FileName, [FromQuery]string xmlData, [FromQuery]string UserID)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaNFSGenerateFileDownload(FileCode, FileName, xmlData, UserID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSGenerateFileDownload - Core .Net SqlClient Data Provider\n", "");
            return Json( new { blnResult, ErrMsg });
        }
        [Route("api/Report/KYCGenerateText")]
        [HttpGet("{id}")]
        public JsonResult KYCGenerateText([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string Jenis, [FromQuery]int Bulan, [FromQuery]int Tahun)
        {
            bool blnResult;
            string ErrMsg;
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaGenerateText(NIK, Module, Jenis, Bulan, Tahun, out ErrMsg, out dsResult);
            ErrMsg = ErrMsg.Replace("ReksaGenerateText - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }        

        [Route("api/Report/NFSInsertLogFile")]
        [HttpGet("{id}")]
        public JsonResult NFSInsertLogFile([FromQuery]string FileCode, [FromQuery]string FileName, [FromQuery]string UserID,
            [FromQuery]int TranDate, [FromQuery]string XMLDataGenerate, [FromQuery]string XMLRawData, [FromQuery]bool IsLog,
            [FromQuery]bool IsNeedAuth)
        {
            bool blnResult;
            string ErrMsg = "";
            blnResult = cls.ReksaNFSInsertLogFile(FileCode, FileName, UserID, TranDate, XMLDataGenerate,
                XMLRawData, IsLog, IsNeedAuth, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaNFSInsertLogFile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Report/ReksaReportRDN07")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN07([FromQuery]string PeriodStart, [FromQuery]string PeriodEnd, [FromQuery]int ProdId, [FromQuery]string CustCode)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(PeriodStart, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(PeriodEnd, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaReportRDN07(dtStartDate, dtEndDate, ProdId, CustCode, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN07 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN08")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN08([FromQuery]string PeriodStart, [FromQuery]string PeriodEnd, [FromQuery]int  ProdCode, [FromQuery]string OfficeId)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(PeriodStart, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(PeriodEnd, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaReportRDN08(dtStartDate, dtEndDate, ProdCode, OfficeId, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN08 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN09")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN09([FromQuery]string TranDate, [FromQuery]int Region, [FromQuery]string ProdCode)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtTranDate = new DateTime();
            DateTime.TryParseExact(TranDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtTranDate);

            blnResult = cls.ReksaReportRDN09(dtTranDate, Region, ProdCode, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN09 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN10")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN10([FromQuery]string PeriodStart, [FromQuery]string PeriodEnd, [FromQuery]int ProdCode, [FromQuery]string OfficeId)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(PeriodStart, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(PeriodEnd, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaReportRDN10(dtStartDate, dtEndDate, ProdCode, OfficeId, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN10 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN11")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN11([FromQuery]string TranDate, [FromQuery]int Region, [FromQuery]string ProdCode)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtTranDate = new DateTime();
            DateTime.TryParseExact(TranDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtTranDate);

            blnResult = cls.ReksaReportRDN11(dtTranDate, Region, ProdCode, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN11 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN12")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN12([FromQuery]string Period, [FromQuery]int Region, [FromQuery]string ProdCode, [FromQuery]string CIFStatus)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtPeriod = new DateTime();
            DateTime.TryParseExact(Period, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtPeriod);

            blnResult = cls.ReksaReportRDN12(dtPeriod, Region, ProdCode, CIFStatus, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN12 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }
        [Route("api/Report/ReksaReportRDN13")]
        [HttpGet("{id}")]
        public JsonResult ReksaReportRDN13([FromQuery]string PeriodStart, [FromQuery]string PeriodEnd, [FromQuery]string ProdCode, [FromQuery]string Type)
        {
            bool blnResult;
            string ErrMsg = "";
            DataSet dsReport = new DataSet();

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(PeriodStart, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(PeriodEnd, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaReportRDN13(dtStartDate, dtEndDate, ProdCode, Type, out dsReport, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaReportRDN13 - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsReport });
        }

    }
}
