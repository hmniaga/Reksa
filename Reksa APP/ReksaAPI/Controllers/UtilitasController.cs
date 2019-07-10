using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;
namespace ReksaAPI.Controllers
{
    public class UtilitasController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public object JsonRequestBehavior { get; private set; }

        public UtilitasController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/Utilitas/PopulateProcess")]
        [HttpGet("{id}")]
        public JsonResult PopulateProcess([FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult;
            string ErrMsg;
            List<ProcessModel> listProcess = new List<ProcessModel>();
            blnResult = cls.ReksaPopulateProcess(NIK, Guid, ref listProcess, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateProcess - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listProcess });
        }
        [Route("api/Utilitas/SPProcess")]
        [HttpGet("{id}")]
        public JsonResult SPProcess([FromQuery]string SPName, [FromQuery]int ProcessId, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.SPProcess(SPName, ProcessId, NIK, Guid, out ErrMsg);
            ErrMsg = ErrMsg.Replace(SPName+ " - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Utilitas/PopulateNAVParameter")]
        [HttpGet("{id}")]
        public JsonResult PopulateNAVParameter([FromBody]UploadNAV model, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaPopulateNAVParameter(model, NIK, Guid, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateNAVParameter - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
    }
}
