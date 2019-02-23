using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Data;
using ReksaAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Rendering;

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
            List<SearchModel.Agen> list = new List<SearchModel.Agen>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaGetTreeView(NIK, Module, MenuName);
            return Json(list);
        }
        [Route("api/Global/PopulateCombo")]
        [HttpGet]
        public JsonResult PopulateCombo()
        {
            List<SearchModel.FrekuensiDebet> list = new List<SearchModel.FrekuensiDebet>();
            list = cls.ReksaPopulateCombo();
            return Json(list);
        }        
        [Route("api/Global/HitungUmur")]
        [HttpGet("{id}")]
        public JsonResult HitungUmur([FromQuery]string CIFNo)
        {
            int intUmur = 0;
            DataSet dsOut = new DataSet();
            intUmur = cls.ReksaHitungUmur(CIFNo);
            return Json(intUmur);
        }
        [Route("api/Global/GetNoNPWPCounter")]
        [HttpGet("{id}")]
        public JsonResult GetNoNPWPCounter([FromQuery]string CIFNo)
        {
            string strNoDocNPWP = "";
            strNoDocNPWP = cls.ReksaGetNoNPWPCounter();
            return Json(strNoDocNPWP);
        }
        [Route("api/Global/ValidateCBOOfficeId")]
        [HttpGet("{id}")]
        public JsonResult ValidateCBOOfficeId([FromQuery]string OfficeID)
        {
            string IsEnable = ""; string strErrorMessage = ""; string strErrorCode = "";
            cls.ReksaValidateCBOOfficeId(OfficeID, out IsEnable, out strErrorMessage, out strErrorCode);
            return Json(new {IsEnable, strErrorMessage, strErrorCode});
        }       
        [Route("api/Global/GetSrcAgen")]
        [HttpGet("{id}")]
        public JsonResult GetSrcAgen([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<SearchModel.Agen> list = new List<SearchModel.Agen>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcAgen(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBank")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBank([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<SearchModel.Bank> list = new List<SearchModel.Bank>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcBank(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcBooking")]
        [HttpGet("{id}")]
        public JsonResult GetSrcBooking([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery] int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Booking> list = new List<SearchModel.Booking>();
            list = cls.ReksaSrcBooking(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcCustomer")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCustomer([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            if (cls.setCFMAST(""))
            {
                list = cls.ReksaSrcCustomer(Col1, Col2, Validate);
                //cls.clearDATA("CFMAST_v");
            }
            return Json(list);
        }
        [Route("api/Global/GetSrcClient")]
        [HttpGet("{id}")]
        public JsonResult GetSrcClient([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int ProdId)
        {
            List<SearchModel.Client> list = new List<SearchModel.Client>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcClient(Col1, Col2, Validate, ProdId);
            return Json(list);
        }
        [Route("api/Global/GetSrcCity")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCity([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.City> list = new List<SearchModel.City>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaSrcCity(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcCIFAll")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCIFAll([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Customer> list = new List<SearchModel.Customer>();
            if (cls.setCFMAST(""))
            {
                list = cls.ReksaSrcCIFAll(Col1, Col2, Validate);
                cls.clearDATA("CFMAST_v");
            }
            return Json(list);
        }
        [Route("api/Global/GetSrcCurrency")]
        [HttpGet("{id}")]
        public JsonResult GetSrcCurrency([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Currency> list = new List<SearchModel.Currency>();
            list = cls.ReksaSrcCurrency(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcProduct")]
        [HttpGet("{id}")]
        public JsonResult GetSrcProduct([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]int Status)
        {
            List<SearchModel.Product> list = new List<SearchModel.Product>();
            list = cls.ReksaSrcProduct(Col1, Col2, Validate, Status);
            return Json(list);
        }
        [Route("api/Global/GetSrcOffice")]
        [HttpGet("{id}")]
        public JsonResult GetSrcOffice([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Office> list = new List<SearchModel.Office>();
            list = cls.ReksaSrcOffice(Col1, Col2, Validate);
            return Json(list);
        }
        [Route("api/Global/GetSrcReferentor")]
        [HttpGet("{id}")]
        public JsonResult GetSrcReferentor([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Referentor> list = new List<SearchModel.Referentor>();
            list = cls.ReksaSrcReferentor(Col1, Col2, Validate);
            return Json(list);
        }

        [Route("api/Global/GetSrcSwitching")]
        [HttpGet("{id}")]
        public JsonResult GetSrcSwitching([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            list = cls.ReksaSrcSwitching(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcSwitchingRDB")]
        [HttpGet("{id}")]
        public JsonResult GetSrcSwitchingRDB([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.Switching> list = new List<SearchModel.Switching>();
            list = cls.ReksaSrcSwitchingRDB(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcTrxClientNew")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTrxClientNew([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.TransaksiClientNew> list = new List<SearchModel.TransaksiClientNew>();
            list = cls.ReksaSrcTrxClientNew(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcTransaksiRefID")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTransaksiRefID([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string Criteria)
        {
            List<SearchModel.TransaksiRefID> list = new List<SearchModel.TransaksiRefID>();
            list = cls.ReksaSrcTransaksiRefID(Col1, Col2, Validate, Criteria);
            return Json(list);
        }
        [Route("api/Global/GetSrcTrxProduct")]
        [HttpGet("{id}")]
        public JsonResult GetSrcTrxProduct([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate, [FromQuery]string JenisTrx)
        {
            List<SearchModel.TransaksiProduct> list = new List<SearchModel.TransaksiProduct>();
            list = cls.ReksaSrcTrxProduct(Col1, Col2, Validate, JenisTrx);
            return Json(list);
        }
        [Route("api/Global/GetSrcWaperd")]
        [HttpGet("{id}")]
        public JsonResult GetSrcWaperd([FromQuery]string Col1, [FromQuery]string Col2, [FromQuery]int Validate)
        {
            List<SearchModel.Waperd> list = new List<SearchModel.Waperd>();
            list = cls.ReksaSrcWaperd(Col1, Col2, Validate);
            return Json(list);
        }

    }
}
