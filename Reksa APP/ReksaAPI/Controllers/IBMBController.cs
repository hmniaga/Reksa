using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ReksaAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{
    public class IBMBController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;

        public object JsonRequestBehavior { get; private set; }

        public IBMBController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }        
        [Route("api/IBMB/RefreshKinerjaProduk")]
        [HttpGet("{id}")]
        public JsonResult RefreshKinerjaProduk([FromQuery]int NIK, [FromQuery]string Module)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<KinerjaProduk> listKinerjaProduk = new List<KinerjaProduk>();
            blnResult = cls.ReksaRefreshKinerjaProduk(NIK, Module, out ErrMsg, out listKinerjaProduk);
            ErrMsg = ErrMsg.Replace("ReksaRefreshKinerjaProduk - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listKinerjaProduk });
        }
        [Route("api/IBMB/MaintainKinerja")]
        [HttpGet("{id}")]
        public JsonResult MaintainKinerja([FromBody]KinerjaProduk model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            blnResult = cls.ReksaMaintainKinerja(model, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainKinerja - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
