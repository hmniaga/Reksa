using System;
using System.Collections.Generic;
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
            List<SearchModel.Product> listProduct = new List<SearchModel.Product>();
            blnResult = cls.ReksaRefreshProduct(ProdId, NIK, GUID, out listProduct, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshProduct - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listProduct });
        }
        [Route("api/Master/InqUnitNasabahDitwrkan")]
        [HttpGet("{id}")]
        public JsonResult InqUnitNasabahDitwrkan([FromQuery]string CIFNo, [FromQuery]string ProdCode, [FromQuery]int NIK, [FromQuery]string GUID, [FromQuery]DateTime CurrDate)
        {
            decimal sisaUnit;
            sisaUnit = cls.ReksaInqUnitNasabahDitwrkan(CIFNo, ProdCode, NIK, GUID, CurrDate);
            return Json(sisaUnit);
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
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}