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
using Microsoft.AspNetCore.Authorization;

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
        [Authorize]
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
            return View("Customer", vModel);
        }
        public JsonResult RefreshNasabah(string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<CustomerIdentitasModel> listCust = new List<CustomerIdentitasModel>();
            List<RiskProfileModel> listRisk = new List<RiskProfileModel>();
            List<CustomerNPWPModel> listCustNPWP = new List<CustomerNPWPModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + CIFNo + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
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
            return Json(new { blnResult, ErrMsg, listCust, listRisk, listCustNPWP });
        }
        public JsonResult ReksaGetListClient(string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ListClientModel> listClientModel = new List<ListClientModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetListClient?CIFNO=" + CIFNo).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenClient = strObject["listClient"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);
                    listClientModel = JsonConvert.DeserializeObject<List<ListClientModel>>(strJsonClient);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listClientModel });
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
                    var request = client.PostAsync("/api/Customer/MaintainBlokir?BlockDesc=" + BlockDesc + "&isAccepted=false&NIK=" + _intNIK + "&GUID=" + _strGuid, Content);
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
        public JsonResult FlagClientId(string ClientId, int Flag)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ListClientModel> listClientModel = new List<ListClientModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/FlagClientId?ClientId=" + ClientId + "NIK=" + _intNIK + "Flag=" + Flag).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strTokenClient = strObject["listClient"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);
                    listClientModel = JsonConvert.DeserializeObject<List<ListClientModel>>(strJsonClient);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listClientModel });
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

                    //if (blnResult)
                    //{
                    //    int.TryParse(CIFData[0].JnsNas, out int intJnsNas);
                    //    CIFData[0].JnsNas = Enum.GetName(typeof(JenisNasabah), intJnsNas);
                    //    CIFData[0].intJnsNas = intJnsNas;
                    //}

                }
            }
            catch (Exception ex)
            {
                ErrMsg = ex.Message;
            }
            return Json(new { blnResult, ErrMsg, CIFData });
        }
        public JsonResult GetKonfAddress(string CIFNo, string KodeKantor)
        {
            bool blnResult = false;
            string ErrMsg = "";
            int intAddressType = 0;
            List<KonfirmasiAddressModel> listKonfAddrees = new List<KonfirmasiAddressModel>();
            List<BranchAddressModel> listBranchAddress = new List<BranchAddressModel>();

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetConfAddress?Type=2&CIFNO=" + CIFNo + "&Branch=" + KodeKantor + "&Id=0&Guid=" + _strGuid + "&NIK=" + _intNIK).Result;
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

                    intAddressType = JsonConvert.DeserializeObject<int>(strJsonAddressType);
                    listKonfAddrees = JsonConvert.DeserializeObject<List<KonfirmasiAddressModel>>(strJsonKonfAddress);
                    listBranchAddress = JsonConvert.DeserializeObject<List<BranchAddressModel>>(strJsonBranchAddress);

                    _session.SetString("listConfAdress", JsonConvert.SerializeObject(listKonfAddrees));
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, intAddressType, listKonfAddrees, listBranchAddress });
        }
        public JsonResult GetRiskProfile(string CIFNo)
        {
            bool blnResult = false;
            string RiskProfile = "";
            DateTime LastUpdate = new DateTime();
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
            return Json(new { blnResult, ErrMsg, RiskProfile, LastUpdate, IsRegistered, ExpRiskProfileYear });
        }
        public JsonResult GetDocStatus(string CIFNo)
        {
            bool blnResult = false, blnDocTermCond = false, blnDocRiskProfile = false;
            string ErrMsg = "";
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetDocStatus?CIFNo=" + CIFNo).Result;
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
            return Json(new { blnResult, ErrMsg, blnDocTermCond, blnDocRiskProfile });
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
            }
            return Json(new { blnResult, ErrMsg, ShareHolderID });
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
            }
            return Json(new { blnResult, ErrMsg, NoRek, Nama, NIK });
        }
        public JsonResult GetAlamatCabang(string CIFNO, string Branch, int intId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<BranchAddressModel> listBranchAddress = new List<BranchAddressModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);
                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetAlamatCabang?Branch=" + Branch + "&CIFNO=" + CIFNO + "&Id=" + intId).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    JObject strObject = JObject.Parse(strJson);

                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    JToken strBranch = strObject["listBranchAddress"];
                    string strJsonBranchAddress = JsonConvert.SerializeObject(strBranch);
                    listBranchAddress = JsonConvert.DeserializeObject<List<BranchAddressModel>>(strJsonBranchAddress);

                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listBranchAddress });
        }
        public JsonResult GetListClientRDB(string ClientCode)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<ClientRDBModel> listClientRDB = new List<ClientRDBModel>();
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
                    listClientRDB = JsonConvert.DeserializeObject<List<ClientRDBModel>>(JsonClientRDB);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, listClientRDB });
        }
        public JsonResult PopulateAktivitas(int ClientId, string StartDate, string EndDate, bool IsBalance, bool IsAktivitasOnly, bool isMFee)
        {
            bool blnResult = false;
            string ErrMsg = "";
            decimal decEffBal = 0, decNomBal = 0;

            List<ActivityModel> listActivity = new List<ActivityModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/PopulateAktivitas?ClientId=" + ClientId + "&StartDate=" + StartDate + "&EndDate=" + EndDate + "&isBalance=" + IsBalance + "&NIK=" + _intNIK + "&isAktivitasOnly=" + IsAktivitasOnly + "&isMFee=" + isMFee + "&GUID=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                    decEffBal = strObject.SelectToken("decEffBal").Value<decimal>();
                    decNomBal = strObject.SelectToken("decNomBal").Value<decimal>();

                    JToken strTokenClient = strObject["listPopulateAktifitas"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);
                    listActivity = JsonConvert.DeserializeObject<List<ActivityModel>>(strJsonClient);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, decEffBal, decNomBal, listActivity });
        }
        public JsonResult RefreshBlokir(int ClientId)
        {
            bool blnResult = false;
            string ErrMsg = "";
            List<BlokirModel> listCLientBlokir = new List<BlokirModel>();
            decimal decTotal = 0, decOutstandingUnit = 0;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/RefreshBlokir?ClientId=" + ClientId + "&NIK=" + _intNIK + "&GUID=" + _strGuid).Result;
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
            return Json(new { blnResult, ErrMsg, decTotal, decOutstandingUnit, listCLientBlokir });
        }
        public JsonResult CekExpRiskProfile(string CIFNo, string RiskProfile)
        {
            bool blnResult = false;
            string strEmail = "";
            string ErrMsg = "";
            DateTime dtExprRiskProfile = new DateTime();

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    long lngCIFNO;
                    long.TryParse(CIFNo, out lngCIFNO);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/CekExpRiskProfile?DateRiskProfile=" + RiskProfile + "&CIFNo=" + lngCIFNO).Result;
                    string Response = response.Content.ReadAsStringAsync().Result;
                    var Object = JObject.Parse(Response);

                    blnResult = Object.SelectToken("blnResult").Value<bool>();
                    ErrMsg = Object.SelectToken("errMsg").Value<string>();
                    strEmail = Object.SelectToken("strEmail").Value<string>();

                    JToken TokenExpiredRiskProfile = Object["dtExpiredRiskProfile"];
                    string strJsonExpiredRiskProfile = JsonConvert.SerializeObject(TokenExpiredRiskProfile);
                    dtExprRiskProfile = JsonConvert.DeserializeObject<DateTime>(strJsonExpiredRiskProfile);
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
            }
            return Json(new { blnResult, ErrMsg, dtExprRiskProfile, strEmail });
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
        public JsonResult SaveExpRiskProfile(string RiskProfile, string ExpRiskProfile, string CIFNo)
        {
            bool blnResult = false;
            string ErrMsg = "";
            long lngCIFNo;
            long.TryParse(CIFNo, out lngCIFNo);
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/SaveExpRiskProfile?RiskProfile=" + RiskProfile + "&ExpRiskProfile=" + ExpRiskProfile + "&CIFNo=" + lngCIFNo).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    blnResult = strObject.SelectToken("blnResult").Value<bool>();
                    ErrMsg = strObject.SelectToken("errMsg").Value<string>();
                }
            }
            catch (Exception e)
            {
                ErrMsg = e.Message;
                return Json(new { blnResult, ErrMsg });
            }
            return Json(new { blnResult, ErrMsg });
        }
        private void RefreshParameter(string strGroup, int intNIK, out List<ParameterModel> listParam)
        {
            listParam = new List<ParameterModel>();
            try
            {
                using (HttpClient client = new HttpClient())
                {

                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Parameter/Refresh?ProdId=&TreeInterface=" + strGroup + "&NIK=" + _intNIK + "&Guid=" + _strGuid).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;
                    listParam = JsonConvert.DeserializeObject<List<ParameterModel>>(strJson);
                }
            }
            catch (Exception e)
            {
                string strErr = e.ToString();
            }
        }
    }
}

