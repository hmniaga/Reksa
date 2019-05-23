using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;

namespace ReksaAPI.Controllers
{
    public class MasterController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public MasterController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }        
        [Route("api/Master/RefreshProduct")]
        [HttpGet("{id}")]
        public JsonResult RefreshProduct([FromQuery]int ProdId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataSet dsResult = new DataSet();
            blnResult = cls.ReksaRefreshProduct(ProdId, NIK, GUID, out dsResult, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshProduct - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dsResult });
        }
        [Route("api/Master/InqUnitNasabahDitwrkan")]
        [HttpGet("{id}")]
        public JsonResult InqUnitNasabahDitwrkan([FromQuery]string CIFNo, [FromQuery]string ProdCode, [FromQuery]int NIK, [FromQuery]string GUID, [FromQuery]DateTime CurrDate)
        {
            bool blnResult;
            string ErrMsg;
            decimal sisaUnit;
            blnResult = cls.ReksaInqUnitNasabahDitwrkan(CIFNo, ProdCode, NIK, GUID, CurrDate, out sisaUnit, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaInqUnitNasabahDitwrkan - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, sisaUnit });
        }
        [Route("api/Master/InqUnitDitwrkan")]
        [HttpGet("{id}")]
        public JsonResult InqUnitDitwrkan([FromQuery]string ProdCode, [FromQuery]int NIK, [FromQuery]string GUID, [FromQuery]DateTime CurrDate)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal sisaUnit;
            blnResult = cls.ReksaInqUnitDitwrkan(ProdCode, NIK, GUID, CurrDate, out sisaUnit, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaInqUnitDitwrkan - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, sisaUnit });
        }
        [Route("api/Master/CalcEffectiveDate")]
        [HttpGet("{id}")]
        public JsonResult CalcEffectiveDate([FromQuery]DateTime StartDate, [FromQuery]int NumDays)
        {
            DateTime dateEnd = new DateTime();
            dateEnd = cls.ReksaCalcEffectiveDate(StartDate, NumDays);
            return Json(dateEnd);
        }
        [Route("api/Master/MaintainProduct")]
        [HttpGet("{id}")]
        public JsonResult MaintainProduct([FromBody]MaintainProduct model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            blnResult = cls.ReksaMaintainProduct(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainProduct - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}