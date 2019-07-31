using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
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
            bool blnResult;
            string ErrMsg;

            List<CustomerIdentitasModel.IdentitasDetail> listCust = new List<CustomerIdentitasModel.IdentitasDetail>();
            List<CustomerIdentitasModel.RiskProfileDetail> listRisk = new List<CustomerIdentitasModel.RiskProfileDetail>();
            List<CustomerNPWPModel> listCustNPWP = new List<CustomerNPWPModel>();
 

            //blnResult = cls.setDataCustomerByProcedure(CIFNO, "ReksaRefreshNasabah", out ErrMsg);
            //if (blnResult)
            //{
                blnResult = false;
                blnResult = cls.ReksaRefreshNasabah(CIFNO, NIK, Guid, ref listCust, ref listRisk, ref listCustNPWP, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaRefreshNasabah - Core .Net SqlClient Data Provider\n", "");
            //}
            return Json(new { blnResult, ErrMsg, listCust, listRisk, listCustNPWP });
        }

        [Route("api/Customer/GenShareholderId")]
        public JsonResult GenShareholderId()
        {
            string shareholderID;
            bool blnResult;
            string ErrMsg;

            blnResult = cls.ReksaGenerateShareholderID(out shareholderID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGenerateShareholderID - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, shareholderID });           
        }
        [Route("api/Customer/GetConfAddress")]
        [HttpGet("{id}")]
        public JsonResult GetConfAddress([FromQuery]int Type, [FromQuery]string CIFNO, [FromQuery]string Branch, [FromQuery]int Id, [FromQuery]int NIK, [FromQuery]string Guid)
        {
            bool blnResult;
            int intAddressType;
            List<CustomerIdentitasModel.KonfirmAddressList> listKonfAddress = new List<CustomerIdentitasModel.KonfirmAddressList>();
            List<CustomerIdentitasModel.AlamatCabangDetail> listBranch = new List<CustomerIdentitasModel.AlamatCabangDetail>();
            string strMessage, ErrMsg;
            blnResult = cls.ReksaGetConfAddress(Type, CIFNO, Branch, Id, NIK, Guid, out intAddressType, out strMessage, out ErrMsg, ref listKonfAddress, ref listBranch);
            ErrMsg = ErrMsg.Replace("ReksaGetConfAddress - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, intAddressType, listKonfAddress, listBranch, strMessage });
        }
        [Route("api/Customer/GetAlamatCabang")]
        [HttpGet("{id}")]
        public JsonResult GetAlamatCabang([FromQuery]string Branch, [FromQuery]string CIFNO, [FromQuery]int Id)
        {
            bool blnResult;
            string ErrMsg;
            List<CustomerIdentitasModel.AlamatCabangDetail> listBranchAddress = new List<CustomerIdentitasModel.AlamatCabangDetail>();
            blnResult = cls.ReksaGetAlamatCabang(Branch, CIFNO, Id, ref listBranchAddress, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetAlamatCabang - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listBranchAddress });
        }
        [Route("api/Customer/GetAccountRelationDetail")]
        [HttpGet("{id}")]
        public JsonResult GetAccountRelationDetail([FromQuery]string AccountNum, [FromQuery]int Type)
        {
            bool blnResult;
            string ErrMsg;
            string NoRek = "";
            string Nama = "";
            string NIK = "";
            blnResult = cls.ReksaGetAccountRelationDetail(AccountNum, Type, out NoRek, out Nama, out NIK, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetAccountRelationDetail - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, NoRek, Nama, NIK });
        }        
        [Route("api/Customer/GetListClient")]
        [HttpGet("{id}")]
        public JsonResult GetListClient([FromQuery]string CIFNO)
        {
            bool blnResult;
            string ErrMsg;
            List<CustomerAktifitasModel.ClientList> listClient = new List<CustomerAktifitasModel.ClientList>();
            blnResult = cls.ReksaGetListClient(CIFNO, ref listClient, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetListClient - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listClient } );
        }
        [Route("api/Customer/GetListClientRDB")]
        [HttpGet("{id}")]
        public JsonResult GetListClientRDB([FromQuery]string ClientCode)
        {
            bool blnResult;
            string ErrMsg;
            List<CustomerAktifitasModel.ClientRDB> listClientRDB = new List<CustomerAktifitasModel.ClientRDB>();
            blnResult = cls.ReksaGetListClientRDB(ClientCode, ref listClientRDB, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetListClientRDB - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listClientRDB });
        }       

        [Route("api/Customer/PopulateAktivitas")]
        [HttpGet("{id}")]
        public JsonResult PopulateAktivitas([FromQuery]int ClientId, [FromQuery]string StartDate, [FromQuery]string EndDate, [FromQuery]int isBalance, [FromQuery]int NIK, [FromQuery]int isAktivitasOnly, [FromQuery]int isMFee, [FromQuery]string GUID)
        {
            bool blnResult;
            string ErrMsg;
            List<CustomerAktifitasModel.PopulateAktifitas> listPopulateAktifitas = new List<CustomerAktifitasModel.PopulateAktifitas>();
            decimal decEffBal, decNomBal;

            DateTime dtStartDate = new DateTime();
            DateTime dtEndDate = new DateTime();
            DateTime.TryParseExact(StartDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStartDate);
            DateTime.TryParseExact(EndDate, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtEndDate);

            blnResult = cls.ReksaPopulateAktivitas(ClientId, dtStartDate, dtEndDate, isBalance, NIK, isAktivitasOnly, isMFee, GUID,  ref listPopulateAktifitas, out decEffBal, out decNomBal, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaPopulateAktivitas - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listPopulateAktifitas, decEffBal, decNomBal });
        }
        [Route("api/Customer/RefreshBlokir")]
        [HttpGet("{id}")]
        public JsonResult RefreshBlokir([FromQuery]int ClientId, [FromQuery]int NIK, [FromQuery]string GUID)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<CustomerBlokirModel> listBlokir = new List<CustomerBlokirModel>();
            decimal decTotal, decOutstandingUnit;
            blnResult = cls.ReksaRefreshBlokir(ClientId, NIK, GUID, ref listBlokir, out decTotal, out decOutstandingUnit, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaRefreshBlokir - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, listBlokir, decTotal, decOutstandingUnit });
        }
        [Route("api/Customer/FlagClientId")]
        [HttpGet("{id}")]
        public JsonResult FlagClientId([FromQuery]int ClientId, [FromQuery]int NIK, [FromQuery]int Flag)
        {
            bool blnResult = false;
            string ErrMsg = "";
            blnResult = cls.ReksaFlagClientId(ClientId, NIK, Flag, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaFlagClientId - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Customer/GetRiskProfileParam")]
        public JsonResult GetRiskProfileParam()
        {
            string ErrMsg;
            bool blnResult;
            int intExpRiskProfileYear;
            int intExpRiskProfileDay;
            blnResult = cls.ReksaCekExpRiskProfileParam(out intExpRiskProfileYear, out intExpRiskProfileDay, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCekExpRiskProfileParam - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, intExpRiskProfileYear, intExpRiskProfileDay, ErrMsg }); 
        }
        [Route("api/Customer/MaintainBlokir")]
        [HttpPost]
        public JsonResult MaintainBlokir([FromQuery]string BlockDesc, [FromQuery]bool isAccepted, [FromQuery]int NIK, [FromQuery]string GUID, [FromBody] CustomerBlokirModel model)
        {
            bool blnResult;
            string ErrMsg;
            blnResult = cls.ReksaMaintainBlokir(model, BlockDesc, isAccepted, NIK, GUID, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaMaintainBlokir - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }

        [Route("api/Customer/SaveExpRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult SaveExpRiskProfile([FromQuery]string RiskProfile, [FromQuery]string ExpRiskProfile,
            [FromQuery]long CIFNo)
        {
            bool blnResult;
            string ErrMsg;

            DateTime dtRiskProfile = new DateTime();
            DateTime dtExpRiskProfile = new DateTime();
            DateTime.TryParseExact(RiskProfile, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtRiskProfile);
            DateTime.TryParseExact(ExpRiskProfile, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtExpRiskProfile);

            blnResult = cls.ReksaSaveExpRiskProfile(dtRiskProfile, dtExpRiskProfile, CIFNo, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaSaveExpRiskProfile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg });
        }
        [Route("api/Customer/CekExpRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult CekExpRiskProfile([FromQuery]string DateRiskProfile, [FromQuery]long CIFNo)
        {
            bool blnResult;
            string ErrMsg;
            DateTime dtExpiredRiskProfile;
            string strEmail;

            DateTime dtRiskProfile = new DateTime();
            DateTime.TryParseExact(DateRiskProfile, "dd'/'MM'/'yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dtRiskProfile);

            blnResult = cls.ReksaCekExpRiskProfile(dtRiskProfile, CIFNo, out dtExpiredRiskProfile, out strEmail, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaCekExpRiskProfile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dtExpiredRiskProfile, strEmail });
        }
        [Route("api/Customer/GetDocStatus")]
        [HttpGet("{id}")]
        public JsonResult GetDocStatus([FromQuery]string CIFNo)
        {
            bool blnResult;
            string ErrMsg;
            string strDocTermCond, strDocRiskProfile;
            blnResult = cls.ReksaGetDocStatus(CIFNo, out strDocTermCond, out strDocRiskProfile, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetDocStatus - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, strDocTermCond, strDocRiskProfile });
        }
        [Route("api/Customer/GetCIFData")]
        [HttpGet("{id}")]
        public JsonResult GetCIFData([FromQuery]string CIFNo, [FromQuery]int NIK, [FromQuery]string GUID, [FromQuery]int NPWP)
        {
            bool blnResult;
            string ErrMsg;
            List<CIFDataModel> CIFData = new List<CIFDataModel>();
            //blnResult = cls.setDataCustomerByProcedure(CIFNo, "ReksaGetCIFData", out ErrMsg);
            //if (blnResult)
            //{
                blnResult = cls.ReksaGetCIFData(CIFNo, NIK, GUID, NPWP, ref CIFData, out ErrMsg);
                ErrMsg = ErrMsg.Replace("ReksaGetCIFData - Core .Net SqlClient Data Provider\n", "");
            //}
            return Json(new { blnResult, ErrMsg, CIFData });
        }
        [Route("api/Customer/GetRiskProfile")]
        [HttpGet("{id}")]
        public JsonResult GetRiskProfile([FromQuery]string CIFNo)
        {
            bool blnResult;
            string ErrMsg;
            string RiskProfile;
            DateTime LastUpdate;
            int IsRegistered;
            int ExpRiskProfileYear;
            blnResult = cls.ReksaGetRiskProfile(CIFNo, out RiskProfile, out LastUpdate, out IsRegistered, out ExpRiskProfileYear, out ErrMsg);
            ErrMsg = ErrMsg.Replace("ReksaGetRiskProfile - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, RiskProfile, LastUpdate, IsRegistered, ExpRiskProfileYear});
        }
        [Route("api/Customer/MaintainNasabah")]
        [HttpGet("{id}")]
        public JsonResult MaintainNasabah([FromQuery]int NIK, [FromQuery]string GUID, [FromBody]MaintainNasabah model)
        {
            bool blnResult = false;
            string ErrMsg = "";

            DataTable dtError = new DataTable();
            blnResult = cls.ReksaMaintainNasabah(model, NIK, GUID, out ErrMsg, out dtError);
            ErrMsg = ErrMsg.Replace("ReksaMaintainNasabah - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, dtError });
        }
        [Route("api/Customer/GetMandatoryFieldStatus")]
        [HttpGet("{id}")]
        public JsonResult GetMandatoryFieldStatus([FromQuery]long CIFNo)
        {
            bool blnResult;
            string ErrMsg, ErrorMessage;
            blnResult = cls.ReksaGetMandatoryFieldStatus(CIFNo, out ErrMsg, out ErrorMessage);
            ErrMsg = ErrMsg.Replace("ReksaGetMandatoryFieldStatus - Core .Net SqlClient Data Provider\n", "");
            return Json(new { blnResult, ErrMsg, ErrorMessage });
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }

    }
}
