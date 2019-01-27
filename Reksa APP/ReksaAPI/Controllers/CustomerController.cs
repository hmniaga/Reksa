using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Xml;
using ReksaAPI.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace ReksaAPI.Controllers
{   
    public class CustomerController : Controller
    {
        private IConfiguration _config;
        clsDataAccess cls;

        public object JsonRequestBehavior { get; private set; }

        public CustomerController(IConfiguration iconfig)
        {
            _config = iconfig;
            cls = new clsDataAccess(_config);
        }

        [Route("api/Customer/Refresh")]
        [HttpGet("{id}"), Authorize]
        public JsonResult Refresh([FromQuery]string CIFNO, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
            List<RiskProfileModel> listRisk = new List<RiskProfileModel>();
            cls.ReksaRefreshCustomer(CIFNO, NIK, Guid, ref listCust, ref listRisk);
            return Json(new { listCust, listRisk });
        }

        [Route("api/Customer/GenShareholderId")]
        public string GenShareholderId()
        {
            return cls.ReksaGenerateShareholderID();            
        }

        [Route("api/Customer/GetConfAddress")]
        [HttpGet("{id}"), Authorize]
        public JsonResult GetConfAddress([FromQuery]int Type, [FromQuery]string CIFNO, [FromQuery]string Branch, [FromQuery]int Id, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            List<KonfirmasiAddressModel> listKonfAddress = new List<KonfirmasiAddressModel>();
            List<BranchModel> listBranch = new List<BranchModel>();
            string strMessage;
            cls.ReksaGetConfAddress(Type, CIFNO, Branch, Id, out strMessage, NIK, Guid, ref listKonfAddress, ref listBranch);
            return Json(new { listKonfAddress, listBranch, strMessage });
        }
        [Route("api/Customer/GetListClient")]
        [HttpGet("{id}")]
        public JsonResult GetListClient([FromQuery]string CIFNO)
        {
            List<ListClientModel> listClient = new List<ListClientModel>();
           
            cls.ReksaGetListClient(CIFNO, ref listClient);
            return Json(new { listClient});
        }        

        [Route("api/Customer/PopulateAktivitas")]
        [HttpGet("{id}")]
        public JsonResult PopulateAktivitas([FromQuery]int ClientId, [FromQuery]DateTime dtStartDate, [FromQuery]DateTime dtEndDate, [FromQuery]int IsBalance, [FromQuery]int intNIK, [FromQuery]int IsAktivitasOnly, [FromQuery]int isMFee, [FromQuery]string strGuid)
        {
            List<PopulateAktifitasModel> listPopulateAktifitas = new List<PopulateAktifitasModel>();
            decimal decEffBal, decNomBal;
            cls.ReksaPopulateAktivitas(ClientId, dtStartDate, dtEndDate, IsBalance, intNIK,
                IsAktivitasOnly, isMFee, strGuid,  ref listPopulateAktifitas, out decEffBal, out decNomBal);
            return Json(new { listPopulateAktifitas, decEffBal, decNomBal });
        }

        [Route("api/Customer/RefreshBlokir")]
        [HttpGet("{id}")]
        public JsonResult RefreshBlokir([FromQuery]int intClientId, [FromQuery]int intNIK, [FromQuery]string strGuid)
        {
            List<BlokirModel> listBlokir = new List<BlokirModel>();
            decimal decTotal, decOutstandingUnit;
            cls.ReksaRefreshBlokir(intClientId, intNIK, strGuid, ref listBlokir, out decTotal, out decOutstandingUnit);
            return Json(new { listBlokir, decTotal, decOutstandingUnit });
        }

        [Route("api/Customer/CekExpRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult CekExpRiskProfile([FromQuery]DateTime DateRiskProfile, [FromQuery]long CIFNo)
        {
            List<CustomerIdentitasModel> list = new List<CustomerIdentitasModel>();
            DataSet dsOut = new DataSet();
            list = cls.ReksaCekExpRiskProfile(DateRiskProfile, CIFNo);
            return Json(list);
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
