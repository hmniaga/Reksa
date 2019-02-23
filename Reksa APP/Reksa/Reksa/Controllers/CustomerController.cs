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
        private int _intType = 0;
        private int _intValidationNPWP = 0;
        private int _intOpsiNPWP = 0;
        private DataSet dsBranch = new DataSet("Branch");

        public CustomerController(IConfiguration iconfig)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
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

                RefreshNasabah(strCIFNo, out listCust, out listRisk, out listCustNPWP);

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

                    switch (listCust[0].ApprovalStatus.ToString().Trim())
                    {
                        case "A":
                            {
                                ViewData["Status"] = "Aktif";
                                break;
                            }
                        case "N":
                            {
                                ViewData["Status"] = "Menunggu Otorisasi";
                                break;
                            }
                        case "T":
                            {
                                ViewData["Status"] = "Tutup";
                                break;
                            }
                    }
                }
                else
                {
                    custModel.CIFTypeName = "";
                }
                bool blnDocTermCond = false, blnDocRiskProfile = false;
                int intAddressType = 0;
                GetDocStatus(strCIFNo, out blnDocTermCond, out blnDocRiskProfile);                
                GetConfAddress(2, strCIFNo, _strBranch, _intId, _intNIK, _strGuid, out intAddressType, out listKonfAddrees, out listBranchAddress);
                string strEmail; DateTime dtExp; DateTime dtRiskProfile;
                dtRiskProfile = listRisk[0].LastUpdate;
                CekExpRiskProfile(strCIFNo, dtRiskProfile, out strEmail, out dtExp);

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
                ReksaGetListClient(strCIFNo, out listClientModel);
                vModel.CustomerListClient = listClientModel;
                vModel.CustomerActivity = listCLientActivity;
            }
            if (idAccordions == "MCB")
            {
                List<BlokirModel> listCLientBlokir = new List<BlokirModel>();
                
                decimal decTotal = 0, decOutStanding = 0;
                RefreshBlokir(intClientId, _intNIK, _strGuid, out listCLientBlokir, out decTotal, out decOutStanding);
                vModel.BlokirModel = new BlokirModel();
                vModel.BlokirModel.decTotal = decTotal;
                vModel.BlokirModel.decOutStanding = decOutStanding;
                vModel.CustomerBlokir = listCLientBlokir;
            }
            
            return Json(vModel);
        }
        public JsonResult ViewActivityData(int intSelectedClient, string strStart, string strEnd)
        {           
            DateTime dtStart = new DateTime();
            DateTime dtEnd = new DateTime();
            DateTime.TryParse(strStart, out dtStart);
            DateTime.TryParse(strEnd, out dtEnd);
            CustomerListViewModel vModel = new CustomerListViewModel();
            List<ActivityModel> listActivity = new List<ActivityModel>();
            PopulateAktivitas(intSelectedClient, dtStart, dtEnd, false, _intNIK, false,false, _strGuid, out listActivity);
            vModel.CustomerActivity = listActivity;
            return Json(vModel);
        }        
        public ActionResult GetDataRDB(string strClientCode)
        {
            List<ClientRDBModel> listRDB = new List<ClientRDBModel>();
            GetDataRDB(strClientCode, out listRDB);
            return Json(new { listRDB });
        }
        public ActionResult GetShareHolderID()
        {
            string strShareHolderID = GenShareHolderID();
            return Json(new { strShareHolderID });
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

        [HttpPost]
        public ActionResult MaintainBlokir([FromBody] BlokirModel blokirModel)
        {

            MaintainBlokirData(blokirModel);
            return View("Customer");
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
        private void RefreshNasabah(string strCIFNo, out List<CustomerIdentitasModel> listCust, out List<RiskProfileModel> listRisk, out List<CustomerNPWPModel> listCustNPWP)
        {           
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/Refresh?CIFNO=" + strCIFNo + "&NIK="+ _intNIK +"&Guid="+ _strGuid).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;

                JObject strObject = JObject.Parse(strJson);
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
        private void RefreshBlokir(int intClientId, int intNIK, string strGuid, out List<BlokirModel> listCLientBlokir, out decimal decTotal, out decimal decOutstandingUnit)
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
        private void GetConfAddress(int Type, string CIFNO, string Branch, int intId, int intNIK, string strGuid, out int intJsonAddressType, out List<KonfirmasiAddressModel> listConfAddress, out List<BranchAddressModel> listBranchAddress)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);
                HttpResponseMessage response = client.GetAsync("/api/Customer/GetConfAddress?Type="+ Type + "&CIFNO="+ CIFNO + "&Branch="+ _strBranch + "&Id="+ intId + "&Guid="+ _strGuid + "&NIK=" + _intNIK).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
                JObject strObject = JObject.Parse(strJson);
                JToken intAddressType = strObject["intAddressType"];
                JToken strKonfAddress = strObject["listKonfAddress"];
                JToken strBranch = strObject["listBranch"];
                JToken strMessage = strObject["strMessage"];
                string strJsonAddressType = JsonConvert.SerializeObject(intAddressType);
                string strJsonKonfAddress = JsonConvert.SerializeObject(strKonfAddress);
                string strJsonBranchAddress = JsonConvert.SerializeObject(strBranch);

                intJsonAddressType = JsonConvert.DeserializeObject<int>(strJsonAddressType);
                listConfAddress = JsonConvert.DeserializeObject<List<KonfirmasiAddressModel>>(strJsonKonfAddress);
                listBranchAddress = JsonConvert.DeserializeObject<List<BranchAddressModel>>(strJsonBranchAddress);
            }
        }
        private void GetDocStatus(string strCIFNo, out bool blnDocTermCond, out bool blnDocRiskProfile)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/GetDocStatus?CIFNo=" + strCIFNo).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
                //listParam = JsonConvert.DeserializeObject<List<ParameterModel>>(strJson);
                var JO = JObject.Parse(strJson);
                blnDocTermCond = JO.SelectToken("strDocTermCond").Value<bool>();
                blnDocRiskProfile = JO.SelectToken("strDocRiskProfile").Value<bool>();                
            }
        }
        private void CekExpRiskProfile(string strCIFNo, DateTime dtRiskProfile, out string strEmail, out DateTime dtExpiredRiskProfile)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                long lngCIFNO;
                long.TryParse(strCIFNo, out lngCIFNO);
                string strdtRisk = dtRiskProfile.ToLongDateString();
                HttpResponseMessage response = client.GetAsync("/api/Customer/CekExpRiskProfile?DateRiskProfile="+ strdtRisk + "&CIFNo="+ lngCIFNO).Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
                var JO = JObject.Parse(strJson);
                strEmail = JO.SelectToken("strEmail").Value<string>();
                dtExpiredRiskProfile = JO.SelectToken("dtExpiredRiskProfile").Value<DateTime>();
            }
        }
        private void ReksaGetListClient(string strCIFNo, out List<ListClientModel> listCust)
        {
            listCust = new List<ListClientModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetListClient?CIFNO=" + strCIFNo).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    JToken strTokenClient = strObject["listClient"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);

                    listCust = JsonConvert.DeserializeObject<List<ListClientModel>>(strJsonClient);
                    
                }
                catch (Exception e)
                {
                    string strErr = e.ToString();
                }
            }
        }
        private void GetDataRDB(string ClientCode, out List<ClientRDBModel> listCust)
        {
            listCust = new List<ClientRDBModel>();
            using (HttpClient client = new HttpClient())
            {
                try
                {
                    client.BaseAddress = new Uri(_strAPIUrl);
                    MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                    client.DefaultRequestHeaders.Accept.Add(contentType);

                    HttpResponseMessage response = client.GetAsync("/api/Customer/GetListClientRDB?ClientCode=" + ClientCode).Result;
                    string strJson = response.Content.ReadAsStringAsync().Result;

                    JObject strObject = JObject.Parse(strJson);
                    JToken strTokenClient = strObject["listClientRDB"];
                    string strJsonClient = JsonConvert.SerializeObject(strTokenClient);

                    listCust = JsonConvert.DeserializeObject<List<ClientRDBModel>>(strJsonClient);

                }
                catch (Exception e)
                {
                    string strErr = e.ToString();
                }
            }
        }
        private string GenShareHolderID()
        {
            string ShareHolderID = "";
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                MediaTypeWithQualityHeaderValue contentType = new MediaTypeWithQualityHeaderValue("application/json");
                client.DefaultRequestHeaders.Accept.Add(contentType);

                HttpResponseMessage response = client.GetAsync("/api/Customer/GenShareholderId").Result;
                string strJson = response.Content.ReadAsStringAsync().Result;
                ShareHolderID = JsonConvert.DeserializeObject<string>(strJson);
            }
            return ShareHolderID;
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
        private void MaintainBlokirData(BlokirModel blokir)
        {
            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(_strAPIUrl);
                var Content = new StringContent(JsonConvert.SerializeObject(blokir));
                Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/json");

                var request = client.PostAsync("/api/Customer/MaintainBlokir", Content);

                var response = request.Result.Content.ReadAsStringAsync().Result;

            }
        }
    }
}
