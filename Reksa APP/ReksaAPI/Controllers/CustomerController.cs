using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
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
        [HttpGet("{id}")]
        public JsonResult Refresh([FromQuery]string CIFNO, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            List<CustomerIdentitasModel.IdentitasDetail> listCust = new List<CustomerIdentitasModel.IdentitasDetail>();
            List<CustomerIdentitasModel.RiskProfileDetail> listRisk = new List<CustomerIdentitasModel.RiskProfileDetail>();
            List<CustomerNPWPModel> listCustNPWP = new List<CustomerNPWPModel>();
            cls.ReksaRefreshCustomer(CIFNO, NIK, Guid, ref listCust, ref listRisk, ref listCustNPWP);
            return Json(new { listCust, listRisk, listCustNPWP });
        }

        [Route("api/Customer/GenShareholderId")]
        public string GenShareholderId()
        {
            return cls.ReksaGenerateShareholderID();            
        }

        [Route("api/Customer/GetConfAddress")]
        [HttpGet("{id}")]
        public JsonResult GetConfAddress([FromQuery]int Type, [FromQuery]string CIFNO, [FromQuery]string Branch, [FromQuery]int Id, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            int intAddressType;
            List<CustomerIdentitasModel.KonfirmAddressList> listKonfAddress = new List<CustomerIdentitasModel.KonfirmAddressList>();
            List<CustomerIdentitasModel.AlamatCabangDetail> listBranch = new List<CustomerIdentitasModel.AlamatCabangDetail>();
            string strMessage;
            cls.ReksaGetConfAddress(Type, CIFNO, Branch, Id, out intAddressType, out strMessage, NIK, Guid, ref listKonfAddress, ref listBranch);
            return Json(new { intAddressType, listKonfAddress, listBranch, strMessage });
        }
        [Route("api/Customer/GetAccountRelationDetail")]
        [HttpGet("{id}")]
        public JsonResult GetAccountRelationDetail([FromQuery]string AccountNum, [FromQuery]int Type)
        {
            cls.ReksaGetAccountRelationDetail(AccountNum, Type);
            return Json(new { AccountNum });
        }
        
        [Route("api/Customer/GetListClient")]
        [HttpGet("{id}")]
        public JsonResult GetListClient([FromQuery]string CIFNO)
        {
            List<CustomerAktifitasModel.ClientList> listClient = new List<CustomerAktifitasModel.ClientList>();           
            cls.ReksaGetListClient(CIFNO, ref listClient);
            return Json(new { listClient} );
        }
        [Route("api/Customer/GetListClientRDB")]
        [HttpGet("{id}")]
        public JsonResult GetListClientRDB([FromQuery]string ClientCode)
        {
            List<CustomerAktifitasModel.ClientRDB> listClientRDB = new List<CustomerAktifitasModel.ClientRDB>();
            cls.ReksaGetListClientRDB(ClientCode, ref listClientRDB);
            return Json(new { listClientRDB });
        }       

        [Route("api/Customer/PopulateAktivitas")]
        [HttpGet("{id}")]
        public JsonResult PopulateAktivitas([FromQuery]int ClientId, [FromQuery]DateTime dtStartDate, [FromQuery]DateTime dtEndDate, [FromQuery]int IsBalance, [FromQuery]int intNIK, [FromQuery]int IsAktivitasOnly, [FromQuery]int isMFee, [FromQuery]string strGuid)
        {
            List<CustomerAktifitasModel.PopulateAktifitas> listPopulateAktifitas = new List<CustomerAktifitasModel.PopulateAktifitas>();
            decimal decEffBal, decNomBal;
            cls.ReksaPopulateAktivitas(ClientId, dtStartDate, dtEndDate, IsBalance, intNIK,
                IsAktivitasOnly, isMFee, strGuid,  ref listPopulateAktifitas, out decEffBal, out decNomBal);
            return Json(new { listPopulateAktifitas, decEffBal, decNomBal });
        }

        [Route("api/Customer/RefreshBlokir")]
        [HttpGet("{id}")]
        public JsonResult RefreshBlokir([FromQuery]int intClientId, [FromQuery]int intNIK, [FromQuery]string strGuid)
        {
            List<CustomerBlokirModel> listBlokir = new List<CustomerBlokirModel>();
            decimal decTotal, decOutstandingUnit;
            cls.ReksaRefreshBlokir(intClientId, intNIK, strGuid, ref listBlokir, out decTotal, out decOutstandingUnit);
            return Json(new { listBlokir, decTotal, decOutstandingUnit });
        }        

        [Route("api/Customer/ValidateOfficeId")]
        [HttpGet("{id}")]
        public JsonResult ValidateOfficeId([FromQuery]string OfficeId)
        {
            int isAllowed;
            cls.ReksaValidateOfficeId(OfficeId, out isAllowed);
            return Json(isAllowed);
        }

        [Route("api/Customer/FlagClientId")]
        [HttpGet("{id}")]
        public string FlagClientId([FromQuery]int ClientId, [FromQuery]int NIK, [FromQuery]int Flag)
        {
            string strErr;
            cls.ReksaFlagClientId(ClientId, NIK, Flag, out strErr);
            return strErr;
        }

        [Route("api/Customer/CekExpRiskProfileParam")]
        public JsonResult CekExpRiskProfileParam()
        {
            string strErr;
            int intExpRiskProfileYear;
            int intExpRiskProfileDay;
            cls.ReksaCekExpRiskProfileParam(out intExpRiskProfileYear, out intExpRiskProfileDay, out strErr);
            return Json(new { intExpRiskProfileYear, intExpRiskProfileDay, strErr }); 
        }

        [Route("api/Customer/MaintainBlokir")]
        [HttpGet("{id}")]
        public JsonResult MaintainBlokir([FromQuery]int intType, [FromQuery]int intClientId,
            [FromQuery]int intBlockId, [FromQuery]decimal decBlockAmount, [FromQuery]string strBlockDesc,
            [FromQuery]DateTime dtExpiryDate, [FromQuery]bool isAccepted, [FromQuery]int intNIK, [FromQuery]string strGuid)
        {            
            string strErrMsg;
            cls.ReksaMaintainBlokir(intType, intClientId, intBlockId, decBlockAmount, 
                strBlockDesc, dtExpiryDate, isAccepted, intNIK, strGuid, out strErrMsg);
            return Json(new { strErrMsg });
        }

        [Route("api/Customer/SaveExpRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult MaintainBlokir([FromQuery]DateTime dtRiskProfile, [FromQuery]DateTime dtExpRiskProfile,
            [FromQuery]long CIFNo)
        {
            string strErrMsg;
            cls.ReksaSaveExpRiskProfile(dtRiskProfile, dtExpRiskProfile, CIFNo, out strErrMsg);
            return Json(new { strErrMsg });
        }

        [Route("api/Customer/CekExpRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult CekExpRiskProfile([FromQuery]DateTime DateRiskProfile, [FromQuery]long CIFNo)
        {
            DateTime dtExpiredRiskProfile;
            string strEmail;
            cls.ReksaCekExpRiskProfile(DateRiskProfile, CIFNo, out dtExpiredRiskProfile, out strEmail);
            return Json(new { dtExpiredRiskProfile, strEmail });
        }


        [Route("api/Customer/GetDocStatus")]
        [HttpGet("{id}")]
        public JsonResult GetDocStatus([FromQuery]string CIFNo)
        {
            string strDocTermCond, strDocRiskProfile;
            cls.ReksaGetDocStatus(CIFNo, out strDocTermCond, out strDocRiskProfile);
            return Json(new { strDocTermCond, strDocRiskProfile });
        }        
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
