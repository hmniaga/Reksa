using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

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
            decimal sisaUnit;
            sisaUnit = cls.ReksaInqUnitDitwrkan(ProdCode, NIK, GUID, CurrDate);
            return Json(new { sisaUnit });
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}