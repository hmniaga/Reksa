using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Reksa.Models;
using Reksa.ViewModels;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using System;
using Newtonsoft.Json.Linq;
using System.Data;
using Kendo.Mvc.UI;
using Kendo.Mvc.Extensions;
using Microsoft.AspNetCore.Http;
using System.Linq;

namespace Reksa.Controllers
{
    public class CustomerController : Controller
    {
        #region "Default Var"
        public string strModule;
        public int _intNIK = 10137;
        public string _strGuid = "77bb8d13-22af-4233-880d-633dfdf16122";
        public string _strMenuName;
        public string _strBranch = "01010";
        public int _intClassificationId;
        private IConfiguration _config;
        private string _strAPIUrl;
        #endregion

        private int _intId;
        private DataSet dsBranch = new DataSet("Branch");
        private readonly IHttpContextAccessor _httpContextAccessor;
        private ISession _session => _httpContextAccessor.HttpContext.Session;

        public CustomerController(IConfiguration iconfig, IHttpContextAccessor httpContextAccessor)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
            _httpContextAccessor = httpContextAccessor; 
        }
        private enum DataType
        {
            Booking = 0,
            Account = 1
        }
        private enum JenisNasabah : int
        {
            INDIVIDUAL = 1,
            CORPORATE = 4
        }
        public ActionResult Customer()
        {
            CustomerListViewModel vModel = new CustomerListViewModel();
            List<ParameterModel> listParam = new List<ParameterModel>();
            CustomerIdentitasModel custModel = new CustomerIdentitasModel();
            custModel.NasabahId = 0;
            vModel.CustomerIdentitas = custModel;
            vModel.OfficeModel = new OfficeModel();
            vModel.OfficeModel.OfficeId = _strBranch;
            RefreshParameter("KNP", _intNIK, out listParam);
            vModel.KepemilikanNPWPKK = listParam;
            RefreshParameter("ANP", _intNIK, out listParam);
            vModel.AlasanTanpaNPWP = listParam;   
            ViewData["Status"] = "Status";
            return View("Customer", vModel);
        }
        public JsonResult RefreshCustomer(string strCIFNo, int intClientId, string idAccordions)
        {
            ViewData["Status"] = "Status";
            bool blnResult = false;
            string ErrMsg = "";

            CustomerListViewModel vModel = new CustomerListViewModel();
            
            if ((idAccordions == "MCI") || (idAccordions == "MCN"))
            {
                List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
                List<RiskProfileModel> listRisk = new List<RiskProfileModel>();
                List<CustomerNPWPModel> listCustNPWP = new List<CustomerNPWPModel>();
                List<KonfirmasiAddressModel> listKonfAddrees = new List<KonfirmasiAddressModel>();
                List<BranchAddressModel> listBranchAddress = new List<BranchAddressModel>();
                CustomerIdentitasModel custModel = new CustomerIdentitasModel();
                vModel.CustomerNPWPModel = new CustomerNPWPModel();

                blnResult = RefreshNasabah(strCIFNo, out listCust, out listRisk, out listCustNPWP, out ErrMsg);

                if (listCust.Count > 0)
                {
                    custModel = listCust[0];
                    int intJnsNas = custModel.CIFType;
                    custModel.CIFTypeName = Enum.GetName(typeof(JenisNasabah), intJnsNas);
                    _intId = custModel.NasabahId;

                    
                    if (listCustNPWP.Count > 0)
                    {
                        vModel.CustomerNPWPModel = listCustNPWP[0];
                    }
                    else
                    {
                        vModel.CustomerNPWPModel.NoNPWPProCIF = listCust[0].CIFNPWP;
                        vModel.CustomerNPWPModel.NamaNPWPProCIF = listCust[0].NamaNPWP;

                        vModel.CustomerNPWPModel.TglNPWP = listCust[0].TglNPWP;
                        vModel.CustomerNPWPModel.NoNPWPKK = listCust[0].NoNPWPKK;
                        vModel.CustomerNPWPModel.NamaNPWPKK = listCust[0].NamaNPWPKK;
                        vModel.CustomerNPWPModel.KepemilikanNPWPKK = listCust[0].KepemilikanNPWPKK;
                        vModel.CustomerNPWPModel.KepemilikanNPWPKKLainnya = listCust[0].KepemilikanNPWPKKLainnya;
                        vModel.CustomerNPWPModel.TglNPWPKK = listCust[0].TglNPWPKK;
                        vModel.CustomerNPWPModel.AlasanTanpaNPWP = listCust[0].AlasanTanpaNPWP;
                        vModel.CustomerNPWPModel.NoDokTanpaNPWP = listCust[0].NoDokTanpaNPWP;
                        vModel.CustomerNPWPModel.TglDokTanpaNPWP = listCust[0].TglDokTanpaNPWP;
                        vModel.CustomerNPWPModel.Opsi = listCust[0].Opsi;
                    }
                }
                else
                {
                    custModel.CIFTypeName = "";
                }
                bool blnDocTermCond = false, blnDocRiskProfile = false;
                int intAddressType = 0;
                blnResult = GetDocStatus(strCIFNo, out blnDocTermCond, out blnDocRiskProfile, out ErrMsg);
                blnResult = GetConfAddress(2, strCIFNo, _strBranch, _intId, out intAddressType, out listKonfAddrees, out listBranchAddress, out ErrMsg);
                string strEmail; DateTime dtExp; DateTime dtRiskProfile;
                dtRiskProfile = listRisk[0].LastUpdate;
                blnResult = CekExpRiskProfile(strCIFNo, dtRiskProfile, out strEmail, out dtExp, out ErrMsg);

                custModel.strAddressType = intAddressType.ToString();
                custModel.Email = strEmail;
                custModel.DateExpRiskProfile = dtExp;
                custModel.blnDocTermCond = blnDocTermCond;
                custModel.blnDocRiskProfile = blnDocRiskProfile;
                
                vModel.CustomerIdentitas = custModel;
                vModel.RiskProfileModel = listRisk[0];
                vModel.CustomerKonfirmasiAddress = listKonfAddrees;
                if(listBranchAddress.Count > 0)
                    vModel.CustomerBranchAddress = listBranchAddress[0];
            }
            if ((idAccordions == "MCI") || (idAccordions == "MCA"))
            {
                List<ActivityModel> listCLientActivity = new List<ActivityModel>();
                List<ListClientModel> listClientModel = new List<ListClientModel>();
                blnResult = ReksaGetListClient(strCIFNo, out listClientModel, out ErrMsg);
                vModel.CustomerListClient = listClientModel;
                vModel.CustomerActivity = listCLientActivity;
            }
            if (idAccordions == "MCB")
            {
                List<BlokirModel> listCLientBlokir = new List<BlokirModel>();
                
                decimal decTotal = 0, decOutStanding = 0;
                blnResult = RefreshBlokir(intClientId, _intNIK, _strGuid, out listCLientBlokir, out decTotal, out decOutStanding, out ErrMsg);
                vModel.BlokirModel = new BlokirModel();
                vModel.BlokirModel.decTotal = decTotal;
                vModel.BlokirModel.decOutStanding = decOutStanding;
                vModel.CustomerBlokir = listCLientBlokir;
            }
            
            return Json( new { blnResult, ErrMsg, vModel });
        }
        public JsonResult GetCIFData(string CIFNo, int NPWP)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<CIFDataModel> CIFData = new List<CIFDataModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetCIFData?CIFNo=" + CIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid + "&NPWP=" + NPWP).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;

                    JObject Object = JObject.Parse(Response);
                    JToken TokenResult = Object["blnResult"];
                    JToken TokenErrMsg = Object["errMsg"];
                    JToken TokenCIFData = Object["cifData"];
                    string JsonResult = JsonConvert.SerializeObject(TokenResult);
                    string JsonErrMsg = JsonConvert.SerializeObject(TokenErrMsg);
                    string JsonCIFData = JsonConvert.SerializeObject(TokenCIFData);

                    blnResult = JsonConvert.DeserializeObject<bool>(JsonResult);
                    ErrMsg = JsonConvert.DeserializeObject<string>(JsonErrMsg);
                    CIFData = JsonConvert.DeserializeObject<List<CIFDataModel>>(JsonCIFData);

                    if (blnResult)
                    {
                        int.TryParse(CIFData[0].JnsNas, out int intJnsNas);
                        CIFData[0].JnsNas = Enum.GetName(typeof(JenisNasabah), intJnsNas);
                        CIFData[0].intJnsNas = intJnsNas;
                    }

                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, CIFData });
            }
            return Json(new { blnResult, ErrMsg, CIFData });
        }
        public JsonResult GekExpRiskProfile(string CIFNo, string RiskProfile)
        {
            bool blnResult = false;
            DateTime dtRiskProfile, dtExp = new DateTime();
            DateTime.TryParse(RiskProfile, out dtRiskProfile);
            string strEmail = "";
            string ErrMsg = "";

            if (RiskProfile != "")
            {
                blnResult = CekExpRiskProfile(CIFNo, dtRiskProfile, out strEmail, out dtExp, out ErrMsg);
            }
            return Json(new { blnResult, ErrMsg, dtExp, strEmail });
        }
        public JsonResult SetDocStatus(string CIFNo)
        {
            bool blnResult = false, blnDocTermCond = false, blnDocRiskProfile = false;
            string ErrMsg = "";
            blnResult = GetDocStatus(CIFNo, out blnDocTermCond, out blnDocRiskProfile, out ErrMsg);

            return Json(new { blnResult, ErrMsg, blnDocTermCond, blnDocRiskProfile });
        }        
        public JsonResult GetRiskProfileParam()
        {
            bool blnResult = false;
            int intExpRiskProfileYear = 0;
            int intExpRiskProfileDay = 0;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetRiskProfileParam").Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    intExpRiskProfileYear = Object.SelectToken("intExpRiskProfileYear").Value<int>();
                    intExpRiskProfileDay = Object.SelectToken("intExpRiskProfileDay").Value<int>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, intExpRiskProfileYear, intExpRiskProfileDay });
            }
            return Json(new { blnResult, ErrMsg, intExpRiskProfileYear, intExpRiskProfileDay });
        }
        public JsonResult GetRiskProfile(string CIFNo)
        {
            bool blnResult = false;
            string RiskProfile = "";
            DateTime LastUpdate = new DateTime() ;
            int IsRegistered = 0;
            int ExpRiskProfileYear = 0;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetRiskProfile?CIFNo=" + CIFNo).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    RiskProfile = Object.SelectToken("riskProfile").Value<string>();
                    LastUpdate = Object.SelectToken("lastUpdate").Value<DateTime>();
                    IsRegistered = Object.SelectToken("isRegistered").Value<int>();
                    ExpRiskProfileYear = Object.SelectToken("expRiskProfileYear").Value<int>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, RiskProfile, LastUpdate, IsRegistered, ExpRiskProfileYear });
            }
            return Json( new { blnResult, ErrMsg, RiskProfile, LastUpdate, IsRegistered, ExpRiskProfileYear });
        }
        public JsonResult GetDataRDB(string strClientCode)
        {
            bool blnResult;
            List<ClientRDBModel> listRDB = new List<ClientRDBModel>();
            blnResult = GetDataRDB(strClientCode, out listRDB, out string ErrMsg);
            return Json(new { blnResult, ErrMsg, listRDB });
        }        
        public JsonResult GetAlamatCabang(string CIFNO, string Branch, int intId)
        {
            CustomerListViewModel vModel = new CustomerListViewModel();
            GetAlamatCabang(CIFNO, Branch, intId, out List<BranchAddressModel> listBranchAddress);
            if (listBranchAddress.Count > 0)
            {
                vModel.CustomerBranchAddress = listBranchAddress[0];
            }                
            return Json(vModel);
        }
        public JsonResult GetShareHolderID()
        {
            string ShareHolderID = "";
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GenShareholderId").Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(strJson);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    JToken TokenData = Object["shareholderID"];
                    string JsonData = JsonConvert.SerializeObject(TokenData);

                    ShareHolderID = JsonConvert.DeserializeObject<string>(JsonData);
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, ShareHolderID });
            }

            return Json(new { blnResult, ErrMsg, ShareHolderID });
        }
        public JsonResult GetKonfAddress(string CIFNo, string KodeKantor)
        {
            bool blnResult = false;
            string ErrMsg = "";
            int intAddressType;
            List<KonfirmasiAddressModel> listKonfAddrees = new List<KonfirmasiAddressModel>();
            List<BranchAddressModel> listBranchAddress = new List<BranchAddressModel>();
            blnResult  = GetConfAddress(2, CIFNo, KodeKantor, 0, 
                out intAddressType, out listKonfAddrees, out listBranchAddress, out ErrMsg);
            return Json(new { blnResult, ErrMsg, intAddressType, listKonfAddrees, listBranchAddress });
        }
        public JsonResult GetAccountRelationDetail(string AccountNum, int Type)
        {
            bool blnResult = false;
            string ErrMsg = "";
            string NoRek = "";
            string Nama = "";
            string NIK = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetAccountRelationDetail?AccountNum=" + AccountNum + "&Type=" + Type).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    NoRek = Object.SelectToken("noRek").Value<string>();
                    Nama = Object.SelectToken("nama").Value<string>();
                    NIK = Object.SelectToken("nik").Value<string>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
                return Json(new { blnResult, ErrMsg, NoRek, Nama, NIK });
            }
            return Json(new { blnResult, ErrMsg, NoRek, Nama, NIK });
        }
        public JsonResult ViewActivityData(int intSelectedClient, string strStart, string strEnd)
        {
            DateTime dtStart = new DateTime();
            DateTime dtEnd = new DateTime();
            DateTime.TryParse(strStart, out dtStart);
            DateTime.TryParse(strEnd, out dtEnd);
            CustomerListViewModel vModel = new CustomerListViewModel();
            List<ActivityModel> listActivity = new List<ActivityModel>();
            PopulateAktivitas(intSelectedClient, dtStart, dtEnd, false, _intNIK, false, false, _strGuid, out listActivity);
            vModel.CustomerActivity = listActivity;
            return Json(vModel);
        }
        public ActionResult SaveExpRiskProfile(string strRiskProfile, string strExpRiskProfile, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            long lngCIFNo;
            DateTime dtRiskProfile = new DateTime();
            DateTime dtExpRiskProfile = new DateTime();
            DateTime.TryParse(strRiskProfile, out dtRiskProfile);
            DateTime.TryParse(strExpRiskProfile, out dtExpRiskProfile);
            long.TryParse(CIFNo, out lngCIFNo);
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/SaveExpRiskProfile?dtRiskProfile=" + dtRiskProfile + "&dtExpRiskProfile=" + dtExpRiskProfile + "&CIFNo=" + lngCIFNo).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg});
            }
            return Json(new { blnResult, ErrMsg});
        }
        public ActionResult MaintainNasabah([FromBody] MaintainNasabah model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            DataTable dtError = new DataTable();
            try
            {
                string[] selectedId;
                model.SelectedId = (model.SelectedId + "***").Replace("|***", "");
                selectedId = model.SelectedId.Split('|');

                var sessionDataset = _session.GetString("listConfAdress");
                List<KonfirmasiAddressModel> listConfAdress = JsonConvert.DeserializeObject<List<KonfirmasiAddressModel>>(sessionDataset);

                List<KonfirmasiAddressModel> filteredList = new List<KonfirmasiAddressModel>();
                int intselectedId = 0;
                foreach (string s in selectedId)
                {
                    int.TryParse(s, out intselectedId);
                    filteredList = listConfAdress.Where(m => (m.Sequence == intselectedId)).ToList();
                }
                model.KonfirmasiAddressModel = filteredList;
                var Content = new StringContent(JsonConvert.SerializeObject(model));
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Customer/MaintainNasabah?NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken TokenError = strObject["dtError"];
                    string JsonError = JsonConvert.SerializeObject(TokenError);
                    dtError = JsonConvert.DeserializeObject<DataTable>(JsonError);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg, dtError });
            }
            return Json(new { blnResult, ErrMsg, dtError });
        }
        private JsonResult Json(object p, object allowGet)
        {
            throw new NotImplementedException();
        }
        private void RefreshParameter(string strGroup, int intNIK, out List<ParameterModel> listParam)
        {
            listParam = new List<ParameterModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=&TreeInterface=" + strGroup + "&NIK=" + _intNIK + "&Guid="+ _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    listParam = JsonConvert.DeserializeObject<List<ParameterModel>>(strJson);
                }
                catch (Exception e)
                {
                    string strErr = e.ToString();
                }
            }
        }
        private bool RefreshNasabah(string strCIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listCustNPWP, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listCust = new List<CustomerIdentitasModel>();
            listRisk = new List<RiskProfileModel>();
            listCustNPWP = new List<CustomerNPWPModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + strCIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenCust = strObject["listCust"];
                    JToken strTokenRisk = strObject["listRisk"];
                    JToken strTokenCustNPWP = strObject["listCustNPWP"];
                    string strJsonCust = JsonConvert.SerializeObject(strTokenCust);
                    string strJsonRisk = JsonConvert.SerializeObject(strTokenRisk);
                    string strJsonCustNPWP = JsonConvert.SerializeObject(strTokenCustNPWP);

                    listCust = JsonConvert.DeserializeObject<List<CustomerIdentitasModel>>(strJsonCust);
                    listRisk = JsonConvert.DeserializeObject<List<RiskProfileModel>>(strJsonRisk);
                    listCustNPWP = JsonConvert.DeserializeObject<List<CustomerNPWPModel>>(strJsonCustNPWP);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        private bool RefreshBlokir(int intClientId, int intNIK, string strGuid, out List<BlokirModel> listCLientBlokir, out decimal decTotal, out decimal decOutstandingUnit, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listCLientBlokir = new List<BlokirModel>();
            decTotal = 0; decOutstandingUnit = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/RefreshBlokir?intClientId=" + intClientId + "&intNIK=" + intNIK + "&strGuid=" + strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    JToken strTokenBlokir = strObject["listBlokir"];
                    JToken strTokendecTotal = strObject["decTotal"];
                    JToken strTokendecOutstandingUnit = strObject["decOutstandingUnit"];
                    string strJsonBlokir = JsonConvert.SerializeObject(strTokenBlokir);
                    string strJsondecTotal = JsonConvert.SerializeObject(strTokendecTotal);
                    string strJsondecOutstandingUnit = JsonConvert.SerializeObject(strTokendecOutstandingUnit);

                    decTotal = JsonConvert.DeserializeObject<decimal>(strJsondecTotal);
                    decOutstandingUnit = JsonConvert.DeserializeObject<decimal>(strJsondecOutstandingUnit);
                    listCLientBlokir = JsonConvert.DeserializeObject<List<BlokirModel>>(strJsonBlokir);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        private bool GetConfAddress(int Type, string CIFNO, string Branch, int intId, 
            out int intJsonAddressType, 
            out List<KonfirmasiAddressModel> listConfAddress, 
            out List<BranchAddressModel> listBranchAddress,
            out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            intJsonAddressType = 0;
            listConfAddress = new List<KonfirmasiAddressModel>();
            listBranchAddress = new List<BranchAddressModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetConfAddress?Type=" + Type + "&CIFNO=" + CIFNO + "&Branch=" + Branch + "&Id=" + intId + "&Guid=" + _strGuid + "&NIK=" + _intNIK).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    JObject Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    JToken TokentAddressType = Object["intAddressType"];
                    JToken TokenKonfAddress = Object["listKonfAddress"];
                    JToken TokenBranch = Object["listBranch"];
                    JToken TokenMessage = Object["strMessage"];
                    string strJsonAddressType = JsonConvert.SerializeObject(TokentAddressType);
                    string strJsonKonfAddress = JsonConvert.SerializeObject(TokenKonfAddress);
                    string strJsonBranchAddress = JsonConvert.SerializeObject(TokenBranch);

                    intJsonAddressType = JsonConvert.DeserializeObject<int>(strJsonAddressType);
                    listConfAddress = JsonConvert.DeserializeObject<List<KonfirmasiAddressModel>>(strJsonKonfAddress);
                    listBranchAddress = JsonConvert.DeserializeObject<List<BranchAddressModel>>(strJsonBranchAddress);

                    _session.SetString("listConfAdress", JsonConvert.SerializeObject(listConfAddress));
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        private bool GetDocStatus(string strCIFNo, out bool blnDocTermCond, out bool blnDocRiskProfile, out string ErrMsg)
        {
            bool blnResult = false;
            blnDocTermCond = false;
            blnDocRiskProfile = false;
            ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetDocStatus?CIFNo=" + strCIFNo).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    blnDocTermCond = Object.SelectToken("strDocTermCond").Value<bool>();
                    blnDocRiskProfile = Object.SelectToken("strDocRiskProfile").Value<bool>();
                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return blnResult;
        }
        private bool CekExpRiskProfile(string strCIFNo, DateTime dtRiskProfile, out string strEmail, out DateTime dtExpiredRiskProfile, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            strEmail = "";
            dtExpiredRiskProfile = new DateTime();

            if(dtRiskProfile == null)
            {
                return true;
            }

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    long lngCIFNO;
                    long.TryParse(strCIFNo, out lngCIFNO);
                    string strdtRisk = dtRiskProfile.ToLongDateString();
                    HttpResponseMessage response = client.GetAsync("/api/Customer/CekExpRiskProfile?DateRiskProfile=" + strdtRisk + "&CIFNo=" + lngCIFNO).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    strEmail = Object.SelectToken("strEmail").Value<string>();

                    JToken TokenExpiredRiskProfile = Object["dtExpiredRiskProfile"];
                    string strJsonExpiredRiskProfile = JsonConvert.SerializeObject(TokenExpiredRiskProfile);
                    dtExpiredRiskProfile = JsonConvert.DeserializeObject<DateTime>(strJsonExpiredRiskProfile);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        private bool ReksaGetListClient(string strCIFNo, out List<ListClientModel> listCust, out string ErrMsg)
        {
            bool blnResult = false;
            ErrMsg = "";
            listCust = new List<ListClientModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetListClient?CIFNO=" + strCIFNo).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenClient = strObject["listClient"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);

                    listCust = JsonConvert.DeserializeObject<List<ListClientModel>>(strJsonClient);

                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }
        private bool GetDataRDB(string ClientCode, out List<ClientRDBModel> listCust, out string ErrMsg)
        {
            ErrMsg = "";
            bool blnResult = false;
            listCust = new List<ClientRDBModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetListClientRDB?ClientCode=" + ClientCode).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);
                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    JToken TokenClientRDB = Object["listClientRDB"];
                    string JsonClientRDB = JsonConvert.SerializeObject(TokenClientRDB);
                    listCust = JsonConvert.DeserializeObject<List<ClientRDBModel>>(JsonClientRDB);                    
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return blnResult;
        }       
        private void PopulateAktivitas(int ClientId, DateTime dtStartDate, DateTime dtEndDate, 
        bool IsBalance, int intNIK, bool IsAktivitasOnly, bool isMFee, string strGuid,
        out List<ActivityModel> listActivity)
        {
            listActivity = new List<ActivityModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    string strStartDate = dtStartDate.ToLongDateString();
                    string strEndDate = dtEndDate.ToLongDateString();
                    HttpResponseMessage response = client.GetAsync("/api/Customer/PopulateAktivitas?ClientId=" + ClientId + 
                        "&dtStartDate=" + strStartDate + "&dtEndDate=" + strEndDate + "&IsBalance="
                        + IsBalance + "&intNIK=" + intNIK + "&IsAktivitasOnly=" + IsAktivitasOnly + "&isMFee="
                        + isMFee + "&strGuid=" + strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    JToken strTokenClient = strObject["listPopulateAktifitas"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);

                    listActivity = JsonConvert.DeserializeObject<List<ActivityModel>>(strJsonClient);

                }
                catch (Exception e)
                {
                    string strErr = e.ToString();
                }
            }

        }
        private void GetAlamatCabang(string CIFNO, string Branch, int intId, out List<BranchAddressModel> listBranchAddress)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Customer/GetAlamatCabang?Branch="+ Branch + "&CIFNO=" + CIFNO + "&Id=" + intId).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
                JObject strObject = JObject.Parse(strJson);
                JToken strBranch = strObject["listBranchAddress"];
                string strJsonBranchAddress = JsonConvert.SerializeObject(strBranch);
                listBranchAddress = JsonConvert.DeserializeObject<List<BranchAddressModel>>(strJsonBranchAddress);

            }
        }
        public ActionResult MaintainBlokir([FromBody]BlokirModel model)
        {
            bool blnResult = false;
            string ErrMsg = "";
            try
            {
                string BlockDesc = "";
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    var Content = new StringContent(JsonConvert.SerializeObject(model));
                    Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");
                    var request = client.PostAsync("/api/Customer/MaintainBlokir?BlockDesc="+ BlockDesc + "&isAccepted=false&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
                    var response = request.Result.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(response);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg });
        }
    }
}
