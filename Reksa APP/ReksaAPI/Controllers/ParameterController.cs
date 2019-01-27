using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{
    public class ParameterController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public ParameterController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }

        [Route("api/Parameter/Refresh")]
        [HttpGet("{id}")]
        public JsonResult Refresh([FromQuery]int ProdId, [FromQuery]string TreeInterface,  [FromQuery]int NIK, [FromQuery]string Guid)
        {
            List<ParameterModel> list = new List<ParameterModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaRefreshParameter(ProdId, TreeInterface, NIK, Guid);
            return Json(list);
        }
    }
}
