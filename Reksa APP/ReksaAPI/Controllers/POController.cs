using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;


namespace ReksaAPI.Controllers
{
    public class POController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public POController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }
        [Route("api/PO/PopulateJurnalRTGS")]
        [HttpGet("{id}")]
        public JsonResult PopulateJurnalRTGS([FromQuery]int ClassificationId, [FromQuery]string Module)
        {
            bool blnResult;
            string ErrMsg;
            List<JurnalRTGS> listJurnalRTGS = new List<JurnalRTGS>();
            blnResult = cls.ReksaPopulateJurnalRTGS(ClassificationId, Module, out listJurnalRTGS, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateJurnalRTGS - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listJurnalRTGS });
        }
        [Route("api/PO/GetXmlRTGS")]
        [HttpGet("{id}")]
        public JsonResult GetXmlRTGS([FromQuery]string Guid, [FromQuery]int NIK, [FromQuery]string Module)
        {
            string strXML;
            strXML = cls.ReksaGetXmlRTGS(Guid, NIK, Module);
            return Json(new { strXML });
        }
        [Route("api/PO/ProsesJurnalRTGSSKN")]
        [HttpGet("{id}")]
        public JsonResult ProsesJurnalRTGSSKN([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaProsesJurnalRTGSSKN(NIK, Module, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaProsesJurnalRTGSSKN - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/PO/ProcessResponseXmlRTGS")]
        [HttpGet("{id}")]
        public JsonResult ProcessResponseXmlRTGS([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                string XMLInput = cls.ReksaGetXmlRTGS(GUID, NIK, Module);
                string strOutPut = "";
                if (XMLInput != "")
                {
                    blnResult = cls.ReksaProcessResponseXmlRTGS(NIK, Module, GUID, strOutPut,out ErrMsg);
                    ErrMsg = ErrMsg.Replace("ReksaProcessResponseXmlRTGS - Core .Net SqlClient Data Provider\n", "");
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
    }
}
