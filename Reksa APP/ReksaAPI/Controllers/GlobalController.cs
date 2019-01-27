using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Authorization;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{
    
    public class GlobalController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;
        public GlobalController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }

        [Route("api/Global/GetTreeView")]
        [HttpGet("{id}")]
        public JsonResult GetTreeView([FromQuery]int NIK, [FromQuery]string Module, [FromQuery]string MenuName)
        {
            List<AgenModel> list = new List<AgenModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaGetTreeView(NIK, Module, MenuName);
            return Json(list);
        }

        [Route("api/Global/GetSrcAgen")]
        [HttpGet("{id}")]
        public JsonResult GetSrcAgen([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<AgenModel> list = new List<AgenModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcAgen(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBank")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBank([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<BankModel> list = new List<BankModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcBank(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBooking")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBooking([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery] int Validate, [FromQuery]string Criteria)
        {
            List<BookingModel> list = new List<BookingModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcBooking(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcCustomer")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCustomer([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<CustomerModel> list = new List<CustomerModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcCustomer(Col1, Col2, Validate);
            return Json(list);
        }

        [Route("api/Global/GetSrcClient")]
        [HttpGet("{id}")]
        public JsonResult GetSrcClient([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<ClientModel> list = new List<ClientModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcClient(Col1, Col2, Validate, ProdId);
            return Json(list);
        }

        [Route("api/Global/GetSrcCity")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCity([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<CityModel> list = new List<CityModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcCity(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcProduct")]
        [HttpGet("{id}")]
        public JsonResult GetSrcProduct([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int Status)
        {
            List<ProductModel> list = new List<ProductModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcProduct(Col1, Col2, Validate, Status);
            return Json(list);
        }
        [Route("api/Global/GetSrcOffice")]
        [HttpGet("{id}")]
        public JsonResult GetSrcOffice([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<OfficeModel> list = new List<OfficeModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcOffice(Col1, Col2, Validate);
            return Json(list);
        }

        [Route("api/Global/GetSrcReferentor")]
        [HttpGet("{id}")]
        public JsonResult GetSrcReferentor([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<ReferentorModel> list = new List<ReferentorModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcReferentor(Col1, Col2, Validate);
            return Json(list);
        }
    }
}
