﻿using System;
using System.Collections.Generic;
using System.Data;
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
            return Json( new { blnResult, ErrMsg, ds });
        }

        [Route("api/Report/NFSGenerateFileDownload")]
        [HttpGet("{id}")]
        public JsonResult NFSGenerateFileDownload([FromQuery]string FileCode, [FromQuery]string FileName, [FromQuery]string xmlData, [FromQuery]string UserID)
        { 
            DataSet dsResult = new DataSet();
            dsResult = cls.ReksaNFSGenerateFileDownload(FileCode, FileName, xmlData, UserID);
            return Json(dsResult);
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
            return Json(new { blnResult, ErrMsg });
        }

       
    }
}
